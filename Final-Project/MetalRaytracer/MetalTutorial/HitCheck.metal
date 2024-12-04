//
//  HitCheck.metal
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

#ifndef HIT_CHECK_METAL
#define HIT_CHECK_METAL

#include <metal_stdlib>

#include "Structs.metal"

#include "Ray.h"
#include "HitCheck.h"

using namespace metal;

static float hitPlane(vector_float3 planeNormal, vector_float3 planePoint, Ray ray) {
    float denom = dot(ray.dir, planeNormal);
    
    // Check if ray is parallel to plane
    if (fabs(denom) < 1e-6f) {
        return -1.0;
    }
    
    float t = dot(planePoint - ray.orig, planeNormal) / denom;
    t = -t;
    
    return (t < 0.0f) ? -1.0f : t;
}

float hitPlane(Plane plane, Ray ray) {
    return hitPlane(plane.normal, plane.center, ray);
}

static float hitPlane(Disk disk, Ray ray) {
    return hitPlane(disk.normal, disk.center, ray);
}

// v0 from the Triangle class
static float hitPlane(vector_float3 v0, vector_float3 edge1, vector_float3 edge2, Ray ray) {
    // Compute the triangle's normal
    vector_float3 normal = cross(edge1, edge2);
    return hitPlane(normal, v0, ray);
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

float hitTriangle(vector_float3 v0, vector_float3 v1, vector_float3 v2, Ray ray) {
    // Compute edges
    vector_float3 edge1 = v1 - v0;
    vector_float3 edge2 = v2 - v0;
    
    const float epsilon = 1e-6f;

    float t = hitPlane(v0, edge1, edge2, ray);
    
    if (t <= epsilon) {
        return -1.0f; // Point is outside the triangle
    }
    
    if (t < epsilon) {
        return -1.0f; // Treat near-plane intersections as misses
    }
    
    // Compute intersection point
    vector_float3 p = rayAt(ray, t);

    // Check if the point is inside the triangle using barycentric coordinates
    vector_float3 v0p = p - v0;
    float d00 = dot(edge1, edge1);
    float d01 = dot(edge1, edge2);
    float d11 = dot(edge2, edge2);
    float d20 = dot(v0p, edge1);
    float d21 = dot(v0p, edge2);

    float denomBary = d00 * d11 - d01 * d01;
    
    if (fabs(denomBary) < epsilon) {
        return -1.0f; // Degenerate triangle or invalid intersection
    }
    
    float u = (d11 * d20 - d01 * d21) / denomBary;
    float v = (d00 * d21 - d01 * d20) / denomBary;

    // If u, v, and (u + v) are all in [0, 1], the point is inside the triangle
    return (u >= epsilon && v >= epsilon && (u + v) <= 1.0f) ? t : -1.0f;
}

float hitTriangle(Triangle triangle, Ray ray) {
    return hitTriangle(triangle.v0, triangle.v1, triangle.v2, ray);
}

float hitModel(Model model, device const vector_float3 *vertices, device const uint *indices, Ray ray) {
    for (uint i = model.indexOffset; i < 100; i += 3) {
        // Get the indices for the triangle
        uint idx0 = indices[model.indexOffset + i];
        uint idx1 = indices[model.indexOffset + i + 1];
        uint idx2 = indices[model.indexOffset + i + 2];
        
        // Get the triangle values
        vector_float3 v0 = vertices[model.vertexOffset + idx0 - 1];
        vector_float3 v1 = vertices[model.vertexOffset + idx1 - 1];
        vector_float3 v2 = vertices[model.vertexOffset + idx2 - 1];

        float t = hitTriangle(v0, v1, v2, ray);
        if (t > 0.0) {
            return t;
        }
    }
    /*
    vector_float3 v0 = vector_float3(1.36807, 3.43544, 2.0);
    vector_float3 v1 = vector_float3(-1.32197, -2.4, 2.0);
    vector_float3 v2 = vector_float3(1.4, 2.4, 2.0);

    float t = hitTriangle(v0, v1, v2, ray);
    if (t > 0.0) {
        return t;
    }
    return -1.0;
     */
}

#endif
