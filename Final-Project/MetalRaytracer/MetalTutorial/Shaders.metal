#include <metal_stdlib>

using namespace metal;

struct Ray {
    vector_float3 orig;
    vector_float3 dir;
};

struct Sphere {
    vector_float3 center;
    float radius;
    float3 color;
};

struct Camera {
    vector_float3 position;
};

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0); // Pass position directly (can transform here if needed)
    out.texCoord = in.texCoord; // Pass texture coordinates
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                texture2d<float, access::sample> texture [[texture(0)]]) {
    // Sample the texture
    float4 color = texture.sample(sampler(filter::linear), in.texCoord);
    // float4 color = float4(1.0, 0.2, 0.1, 1.0);
    return color;
}

bool hitSphere(Sphere sphere, Ray ray){
    vector_float3 oc = sphere.center - ray.orig;
    float a = dot(ray.dir, ray.dir);
    float b = -2.0f * dot(ray.dir, oc);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4 * a * c;
    return (discriminant >= 0);
}

float3 rayColor(Ray ray) {
    Sphere sphere;
    sphere.center = vector_float3(0.0f, 0.0f, -1.0f);
    sphere.radius = 0.5f;
    sphere.color = float3 (1.0f, 0.0f, 0.0f);
    
    if (hitSphere(sphere, ray)) {
        return sphere.color;
    }
    
    vector_float3 unitDirection = normalize(ray.dir);
    float a = 0.5f * (unitDirection.y + 1.0f);
    return (1.0f - a) * float3(1.0f, 1.0f, 1.0f) + a * float3(0.5f, 0.7f, 1.0f);
}

Ray makeRay(float2 uv) {
    vector_float3 pixelCenter = vector_float3(uv, 1.0f);
    vector_float3 cameraCenter = vector_float3(0.0f, 0.0f, 0.0f);
    
    Ray ray;
    ray.orig = cameraCenter;
    ray.dir = normalize(pixelCenter - cameraCenter);
    
    return ray;
}

kernel void computeShader(texture2d<float, access::write> outputTexture [[texture(0)]],
                          uint2 tid [[thread_position_in_grid]]) {
    // Ensures that the thread id stays within the bounds of the texture coords
    if (tid.x >= outputTexture.get_width() || tid.y >= outputTexture.get_height()) {
        return;
    }

    float2 pixel = (float2)tid;
    float2 uv = float2(pixel) / float2(outputTexture.get_width(), outputTexture.get_height());
    uv = uv * 2.0f - 1.0f;
    
    Ray ray = makeRay(uv);
    float3 color = rayColor(ray);
    
    // Simple color gradient based on UV coordinates
    // float3 color = float3(uv.x, uv.y, 0.0);
    
    outputTexture.write(float4(color, 1.0), tid);
}
