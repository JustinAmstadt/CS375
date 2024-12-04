//
//  Structs.swift
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

import Foundation
import simd

struct Vertex {
    var position: simd_float2
    var texCoord: simd_float2
}

struct Sphere {
    var center: vector_float3
    var radius: Float
    var color: simd_float3
}

struct Plane {
    var center: vector_float3
    var normal: vector_float3
    var color: simd_float3
}

struct Disk {
    var center: vector_float3
    var normal: vector_float3
    var radius: Float
    var color: simd_float3
}

struct Triangle {
    var v0: vector_float3
    var v1: vector_float3
    var v2: vector_float3
    var color: simd_float3
}

struct Model {
    var vertexOffset: Int
    var indexOffset: Int
    var indexCount: UInt32
}

struct Camera {
    var position: vector_float3
}
