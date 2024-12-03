//
//  Buffers.swift
//  MetalRaytracer
//
//  Created by Justin A on 12/2/24.
//

import Foundation
import Metal
import MetalKit

class Buffer {
    var buffer: MTLBuffer
    var countBuffer: MTLBuffer
    
    init(_ buffer: MTLBuffer, _ countBuffer: MTLBuffer) {
        self.buffer = buffer
        self.countBuffer = countBuffer
    }
}

class SphereBuffer: Buffer {
    init(device: MTLDevice, spheres: [Sphere]) {
        let buffer = device.makeBuffer(bytes: spheres,
                                       length: MemoryLayout<Sphere>.stride * spheres.count,
                                       options: .storageModeShared)!
        
        var sphereCount = UInt32(spheres.count)
        let sphereCountBuffer = device.makeBuffer(bytes: &sphereCount,
                                                  length: MemoryLayout<UInt32>.stride,
                                                  options: .storageModeShared)!
        super.init(buffer, sphereCountBuffer)
    }
}

class PlaneBuffer: Buffer {
    init(device: MTLDevice, planes: [Plane]) {
        let buffer = device.makeBuffer(bytes: planes,
                                       length: MemoryLayout<Plane>.stride * planes.count,
                                       options: .storageModeShared)!
        var planeCount = UInt32(planes.count)
        let planeCountBuffer = device.makeBuffer(bytes: &planeCount,
                                                  length: MemoryLayout<UInt32>.stride,
                                                  options: .storageModeShared)!
        super.init(buffer, planeCountBuffer)
    }
}

class DiskBuffer: Buffer {
    init(device: MTLDevice, disks: [Disk]) {
        let buffer = device.makeBuffer(bytes: disks,
                                       length: MemoryLayout<Disk>.stride * disks.count,
                                       options: .storageModeShared)!
        var diskCount = UInt32(disks.count)
        let diskCountBuffer = device.makeBuffer(bytes: &diskCount,
                                                  length: MemoryLayout<UInt32>.stride,
                                                  options: .storageModeShared)!
        super.init(buffer, diskCountBuffer)
    }
}

class TriangleBuffer: Buffer {
    init(device: MTLDevice, triangles: [Triangle]) {
        let buffer = device.makeBuffer(bytes: triangles,
                                       length: MemoryLayout<Triangle>.stride * triangles.count,
                                       options: .storageModeShared)!
        var triangleCount = UInt32(triangles.count)
        let triangleCountBuffer = device.makeBuffer(bytes: &triangleCount,
                                                  length: MemoryLayout<UInt32>.stride,
                                                  options: .storageModeShared)!
        super.init(buffer, triangleCountBuffer)
    }
}

class ModelBuffer: Buffer {
    init(device: MTLDevice, models: [Model]) {
        let buffer = device.makeBuffer(bytes: models,
                                       length: MemoryLayout<Model>.stride * models.count,
                                       options: .storageModeShared)!
        var modelCount = UInt32(models.count)
        let modelCountBuffer = device.makeBuffer(bytes: &modelCount,
                                                  length: MemoryLayout<UInt32>.stride,
                                                  options: .storageModeShared)!
        super.init(buffer, modelCountBuffer)
    }
}

class ModelDataBuffer {
    var verticesBuffer: MTLBuffer
    var indicesBuffer: MTLBuffer
    
    init(device: MTLDevice, vertices: [vector_float3], indices: [UInt32]) {
        self.verticesBuffer = device.makeBuffer(bytes: vertices,
                                        length: MemoryLayout<vector_float3>.stride * vertices.count,
                                       options: .storageModeShared)!
        self.indicesBuffer = device.makeBuffer(bytes: indices,
                                       length: MemoryLayout<UInt32>.stride * indices.count,
                                       options: .storageModeShared)!
    }
}
