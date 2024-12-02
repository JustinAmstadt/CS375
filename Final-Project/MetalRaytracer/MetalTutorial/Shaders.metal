#include <metal_stdlib>

#include "Structs.metal"

using namespace metal;

vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                texture2d<float, access::sample> texture [[texture(0)]]) {
    float4 color = texture.sample(sampler(filter::linear), in.texCoord);
    // float4 color = float4(1.0, 0.2, 0.1, 1.0);
    return color;
}

vector_float3 rayAt(Ray ray, float t) {
    return ray.orig + t * ray.dir;
}

float hitSphere(Sphere sphere, Ray ray){
    vector_float3 oc = ray.orig - sphere.center;
    float a = dot(ray.dir, ray.dir);
    float h = dot(ray.dir, oc);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;
    float discriminant = h * h - a * c;
    
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (h - sqrt(discriminant)) / a; // If there is a hit, return the t value of that hit
    }
}

float hitPlane(vector_float3 planeNormal, vector_float3 planePoint, Ray ray) {
    float denom = dot(ray.dir, planeNormal);
    
    // Check if ray is parallel to plane
    if (fabs(denom) < 1e-6f) {
        return -1.0;
    }
    
    float t = dot(planePoint - ray.orig, planeNormal) / denom;
    
    return (t < 0.0f) ? -1.0f : t;
}

float hitPlane(Plane plane, Ray ray) {
    return hitPlane(plane.normal, plane.center, ray);
}

float hitPlane(Disk disk, Ray ray) {
    return hitPlane(disk.normal, disk.center, ray);
}

float hitPlane(Triangle triangle, vector_float3 edge1, vector_float3 edge2, Ray ray) {
    // Compute the triangle's normal
    vector_float3 normal = cross(edge1, edge2);
    return hitPlane(normal, triangle.v0, ray);
}

float hitDisk(Disk disk, Ray ray) {
    float t = hitPlane(disk, ray);
    if (t > 0.0f) {
        vector_float3 intersectionPoint = rayAt(ray, t);
        vector_float3 fromCenter = disk.center - intersectionPoint; // Vector from disk center to intersection point
        float distanceSqrd = dot(fromCenter, fromCenter); // Distance squared from intersection point to disk center
        return (distanceSqrd <= disk.radius * disk.radius) ? t : -1.0f;
    }
    
    return -1.0f;
}

float hitTriangle(Triangle triangle, Ray ray) {
    // Compute edges
    vector_float3 edge1 = triangle.v1 - triangle.v0;
    vector_float3 edge2 = triangle.v2 - triangle.v0;

    float t = hitPlane(triangle, edge1, edge2, ray);
    
    if (t <= 0.0f) {
        return -1.0f; // Point is outside the triangle
    }

    // Compute intersection point
    vector_float3 p = rayAt(ray, t);

    // Check if the point is inside the triangle using barycentric coordinates
    vector_float3 v0p = p - triangle.v0;
    float d00 = dot(edge1, edge1);
    float d01 = dot(edge1, edge2);
    float d11 = dot(edge2, edge2);
    float d20 = dot(v0p, edge1);
    float d21 = dot(v0p, edge2);

    float denomBary = d00 * d11 - d01 * d01;
    float u = (d11 * d20 - d01 * d21) / denomBary;
    float v = (d00 * d21 - d01 * d20) / denomBary;

    // If u, v, and (u + v) are all in [0, 1], the point is inside the triangle
    return (u >= 0.0f && v >= 0.0f && (u + v) <= 1.0f) ? t : -1.0f;
}


bool isNewColor(float t, float closest) {
    return t > 0.0 && t < closest;
}

float3 rayColor(device const Sphere *spheres, uint sphereCount, Ray ray) {
    float3 outColor;
    bool isHit = false;
    float closest = INFINITY;
    
    for (uint i = 0; i < sphereCount; i++) {
        float t = hitSphere(spheres[i], ray);
        
        if (isNewColor(t, closest)) {
            // vector_float3 pointOnSphere = rayAt(ray, t);
            // vector_float3 normal = normalize(pointOnSphere - spheres[0].center);
            // return 0.5f * (normal + 1.0f);
            outColor = spheres[i].color;
            isHit = true;
            closest = t;
        }
    }
    
    Plane plane;
    plane.center = vector_float3(0.0f, 0.0f, 5.0f);
    plane.normal = normalize(vector_float3(0.0f, 0.0f, 1.0f));
    plane.color = float3(0.0f, 1.0f, 0.0f);
    
    float t = hitPlane(plane, ray);
    
    if (isNewColor(t, closest)) {
        outColor = plane.color;
        isHit = true;
        closest = t;
    }
    
    Disk disk;
    disk.center = vector_float3(-0.8f, -0.3f, 1.0f);
    disk.normal = normalize(vector_float3(1.0f, 0.0f, 1.0f));
    disk.color = float3(1.0f, 1.0f, 1.0f);
    disk.radius = 0.4f;
    
    t = hitDisk(disk, ray);
    
    if (isNewColor(t, closest)) {
        outColor = disk.color;
        isHit = true;
        closest = t;
    }
    
    Triangle triangle;
    triangle.v0 = vector_float3(-0.8f, -0.8f, 2.0f);
    triangle.v1 = vector_float3(0.8f, -0.8f, 2.0f);
    triangle.v2 = vector_float3(0.8f, 0.8f, 2.0f);
    triangle.color = float3(1.0f, 1.0f, 0.0f);
    
    t = hitTriangle(triangle, ray);
    
    if (isNewColor(t, closest)) {
        outColor = triangle.color;
        isHit = true;
        closest = t;
    }

    if (isHit) {
        return outColor;
    } else {
        vector_float3 unitDirection = normalize(ray.dir);
        float a = 0.5f * (unitDirection.y + 1.0f);
        return (1.0f - a) * float3(1.0f, 1.0f, 1.0f) + a * float3(0.5f, 0.7f, 1.0f);
    }
}

Ray makeRay(float2 uv) {
    vector_float3 pixelCenter = vector_float3(uv, 1.0f);
    vector_float3 cameraCenter = vector_float3(0.0f, 0.0f, 0.0f);
    
    Ray ray;
    ray.orig = cameraCenter;
    ray.dir = normalize(pixelCenter - cameraCenter);
    
    return ray;
}

kernel void computeShader(
                          texture2d<float, access::write> outputTexture [[texture(0)]],
                          device const Sphere *spheres [[buffer(0)]],
                          constant uint& sphereCount [[buffer(1)]],
                          uint2 tid [[thread_position_in_grid]],
                          uint2 gridSize [[threads_per_grid]]
                          ) {
    // Ensures that the thread id stays within the bounds of the texture coords
    if (tid.x >= outputTexture.get_width() || tid.y >= outputTexture.get_height()) {
        return;
    }

    float2 uv = (float2(tid) / float2(gridSize)) * 2.0f - 1.0f;
    float aspectRatio = float(outputTexture.get_width()) / float(outputTexture.get_height());
    uv.x *= aspectRatio;
    
    Ray ray = makeRay(uv);
    float3 color = rayColor(spheres, sphereCount, ray);
    
    outputTexture.write(float4(color, 1.0f), tid);
}
