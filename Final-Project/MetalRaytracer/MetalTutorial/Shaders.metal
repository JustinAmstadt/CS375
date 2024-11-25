#include <metal_stdlib>

using namespace metal;

struct Ray {
    vector_float3 orig;
    vector_float3 dir;
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

float3 rayColor(Ray ray) {
    vector_float3 unitDirection = normalize(ray.dir);
    float a = 0.5f * (unitDirection.y + 1.0f);
    return (1.0f - a) * float3(0.0f, 0.0f, 0.0f) + a * float3(0.5f, 0.7f, 1.0f);
}

Ray makeRay(float2 uv,
            uint2 tid [[thread_position_in_grid]]) {
    // Pixel coordinates for this thread
    float2 pixel = (float2)tid;
    
    uv = uv * 2.0f - 1.0f;
    vector_float3 pixelCenter = vector_float3(uv, 1.0f);
    vector_float3 cameraCenter = vector_float3(0.0f, 0.0f, 0.0f);
    
    Ray ray;
    ray.orig = cameraCenter;
    ray.dir = pixelCenter - cameraCenter;
    
    return ray;
}

kernel void computeShader(texture2d<float, access::write> outputTexture [[texture(0)]],
                          uint2 tid [[thread_position_in_grid]]) {
    float2 uv = float2(tid) / float2(outputTexture.get_width(), outputTexture.get_height());
    Ray ray = makeRay(uv, tid);
    float3 color = rayColor(ray);
    
    // Simple color gradient based on UV coordinates
    // float3 color = float3(uv.x, uv.y, 0.0);
    
    outputTexture.write(float4(color, 1.0), tid);
}
