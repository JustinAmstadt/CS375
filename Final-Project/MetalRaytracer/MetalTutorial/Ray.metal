//
//  Ray.metal
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

#ifndef RAY_METAL
#define RAY_METAL

#include <metal_stdlib>

#include "Structs.metal"

using namespace metal;

vector_float3 rayAt(Ray ray, float t) {
    return ray.orig + t * ray.dir;
}

#endif
