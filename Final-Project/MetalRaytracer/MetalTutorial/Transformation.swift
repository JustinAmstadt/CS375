//
//  Transformation.swift
//  MetalRaytracer
//
//  Created by Justin A on 12/4/24.
//

import Foundation
import simd

func makeTranslationMatrix(dx: Float, dy: Float, dz: Float) -> simd_float4x4 {
    return simd_float4x4(
        simd_float4(1, 0, 0, 0),
        simd_float4(0, 1, 0, 0),
        simd_float4(0, 0, 1, 0),
        simd_float4(dx, dy, dz, 1)
    )
}

func makeScalingMatrix(sx: Float, sy: Float, sz: Float) -> simd_float4x4 {
    return simd_float4x4(
        simd_float4(sx, 0,  0,  0),
        simd_float4(0, sy, 0,  0),
        simd_float4(0,  0, sz, 0),
        simd_float4(0,  0,  0, 1)
    )
}

func translateVectors(vectors: [vector_float3], translation: vector_float3) -> [vector_float3] {
    let translationMatrix = makeTranslationMatrix(dx: translation.x, dy: translation.y, dz: translation.z)
    
    return vectors.map { vector in
        let vector4 = vector_float4(vector.x, vector.y, vector.z, 1.0)
        let transformedVector4 = translationMatrix * vector4
        return vector_float3(transformedVector4.x, transformedVector4.y, transformedVector4.z)
    }
}

func scaleVectors(vectors: [vector_float3], scale: vector_float3) -> [vector_float3] {
    let scalingMatrix = makeScalingMatrix(sx: scale.x, sy: scale.y, sz: scale.z)
    
    return vectors.map { vector in
        let vector4 = vector_float4(vector.x, vector.y, vector.z, 1.0)
        let scaledVector4 = scalingMatrix * vector4
        return vector_float3(scaledVector4.x, scaledVector4.y, scaledVector4.z)
    }
}
