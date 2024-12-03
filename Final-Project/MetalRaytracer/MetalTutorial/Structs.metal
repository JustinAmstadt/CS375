//
//  Structs.metal
//  MetalRaytracer
//
//  Created by Justin A on 11/30/24.
//

#ifndef STRUCTS_METAL
#define STRUCTS_METAL

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

struct Plane {
    vector_float3 center;
    vector_float3 normal;
    float3 color;
};

struct Disk {
    vector_float3 center;
    vector_float3 normal;
    float radius;
    float3 color;
};

struct Triangle {
    vector_float3 v0;
    vector_float3 v1;
    vector_float3 v2;
    float3 color;
};

struct Model {
    int vertexOffset;
    int indexOffset;
    uint indexCount;
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

#endif
