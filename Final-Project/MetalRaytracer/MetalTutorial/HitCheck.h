//
//  HitCheck.h
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

#ifndef HitCheck_h
#define HitCheck_h

#include "Structs.metal"

extern float hitPlane(Plane plane, Ray ray);
extern float hitSphere(Sphere sphere, Ray ray);
extern float hitDisk(Disk disk, Ray ray);
extern float hitTriangle(vector_float3 v0, vector_float3 v1, vector_float3 v2, Ray ray);
extern float hitTriangle(Triangle triangle, Ray ray);
extern float hitModel(Model model, device const vector_float3 *vertices, device const uint *indices, Ray ray);

#endif /* HitCheck_h */
