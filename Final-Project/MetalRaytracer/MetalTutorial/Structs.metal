//
//  Structs.metal
//  MetalRaytracer
//
//  Created by Justin A on 11/30/24.
//

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

