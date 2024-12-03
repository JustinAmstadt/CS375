//
//  Shaders.metal
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

#include <metal_stdlib>

#include "HitCheck.h"
#include "Ray.h"

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

bool isNewColor(float t, float closest) {
    return t > 0.0 && t < closest;
}

float3 rayColor(device const Sphere *spheres, uint sphereCount, device const Plane *planes, constant uint& planeCount, device const Disk *disks, constant uint& diskCount, device const Triangle *triangles, constant uint& triangleCount, device const Model *models, constant uint& modelCount, device const vector_float3 *vertices, device const uint *indices, Ray ray) {
    float3 outColor;
    bool isHit = false;
    float closest = INFINITY;
    
    /*
    for (uint i = 0; i < planeCount; i++) {
        float t = hitPlane(planes[i], ray);
        
        if (isNewColor(t, closest)) {
            outColor = planes[i].color;
            isHit = true;
            closest = t;
        }
    }*/
    /*
     for (uint i = 0; i < sphereCount; i++) {
         float t = hitSphere(spheres[i], ray);
         
         if (isNewColor(t, closest)) {
             outColor = spheres[i].color;
             isHit = true;
             closest = t;
         }
     }
     
    for (uint i = 0; i < diskCount; i++) {
        float t = hitDisk(disks[i], ray);
        
        if (isNewColor(t, closest)) {
            outColor = disks[i].color;
            isHit = true;
            closest = t;
        }
    }
     
     */
    for (uint i = 0; i < triangleCount; i++) {
        float t = hitTriangle(triangles[i], ray);
        
        if (isNewColor(t, closest)) {
            outColor = triangles[i].color;
            isHit = true;
            closest = t;
        }
    }
    for (uint i = 0; i < modelCount; i++) {
        float t = hitModel(models[i], vertices, indices, ray);
        
        if (isNewColor(t, closest)) {
            outColor = float3(1.0f, 0.0f, 0.0f);
            isHit = true;
            closest = t;
        }
    }
    
    // if (models[0].indexCount > 18959) return float3(1.0f, 0.0f, 0.0f);

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
    vector_float3 cameraCenter = vector_float3(0.0f, 0.0f, 5.0f);
    
    Ray ray;
    ray.orig = cameraCenter;
    ray.dir = normalize(pixelCenter - cameraCenter);
    
    return ray;
}

kernel void computeShader(
                          texture2d<float, access::write> outputTexture [[texture(0)]],
                          device const Sphere *spheres [[buffer(0)]],
                          constant uint& sphereCount [[buffer(1)]],
                          device const Plane *planes [[buffer(2)]],
                          constant uint& planeCount [[buffer(3)]],
                          device const Disk *disks [[buffer(4)]],
                          constant uint& diskCount [[buffer(5)]],
                          device const Triangle *triangles [[buffer(6)]],
                          constant uint& triangleCount [[buffer(7)]],
                          device const Model *models [[buffer(8)]],
                          constant uint& modelCount [[buffer(9)]],
                          device const vector_float3 *vertices [[buffer(10)]],
                          device const uint *indices [[buffer(11)]],
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
    float3 color = rayColor(spheres, sphereCount, planes, planeCount, disks, diskCount, triangles, triangleCount, models, modelCount, vertices, indices, ray);
    
    outputTexture.write(float4(color, 1.0f), tid);
}
