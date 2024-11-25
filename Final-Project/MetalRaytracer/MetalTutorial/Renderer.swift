import Metal
import MetalKit
import simd

struct Vertex {
    var position: simd_float2
    var texCoord: simd_float2
}

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var library: MTLLibrary
    
    var computePipeline: MTLComputePipelineState!
    var renderPipeline: MTLRenderPipelineState
    
    var computeFunction: MTLFunction
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    
    var vertexBuffer: MTLBuffer
    var indexBuffer: MTLBuffer
    
    var texture: MTLTexture
    
    var vertices: [Vertex]
    var indices: [ushort]
    
    init?(metalKitView: MTKView) {
        //Device and command queue
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        // Init the library
        self.library = device.makeDefaultLibrary()!
        
        // Make functions that connect to the function names given in the Shaders file
        self.computeFunction = library.makeFunction(name: "computeShader")!
        self.computePipeline = try! device.makeComputePipelineState(function: computeFunction)
        
        self.vertexFunction = library.makeFunction(name: "vertexShader")!
        self.fragmentFunction = library.makeFunction(name: "fragmentShader")!
        
        let vertexDescriptor = MTLVertexDescriptor()

        // Position attribute
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Texture coordinate attribute
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float2>.size
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Layout of the vertex buffer
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.renderPipeline = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // Create a texture to hold the computed image
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                          width: Int(metalKitView.drawableSize.width),
                                                                          height: Int(metalKitView.drawableSize.height),
                                                                          mipmapped: false)
        textureDescriptor.usage = [.shaderWrite, .shaderRead, .renderTarget]
        self.texture = device.makeTexture(descriptor: textureDescriptor)!
        
        self.vertices = [
            Vertex(position: simd_float2(-1.0, -1.0), texCoord: simd_float2(0.0, 1.0)), //vertex 0
            Vertex(position: simd_float2( 1.0, -1.0), texCoord: simd_float2(1.0, 1.0)), //vertex 1
            Vertex(position: simd_float2( 1.0,  1.0), texCoord: simd_float2(1.0, 0.0)), //vertex 2
            Vertex(position: simd_float2(-1.0,  1.0), texCoord: simd_float2(0.0, 0.0))  //vertex 3
        ]

        self.vertexBuffer = device.makeBuffer(bytes: &vertices,
                                              length: MemoryLayout<Vertex>.size * vertices.count,
                                              options: .storageModeShared)!
        
        indices = [
            0, 1, 2,
            0, 2, 3
        ]
        
        self.indexBuffer = self.device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout.stride(ofValue: indices[0]), options: MTLResourceOptions.storageModeShared)!
        
        super.init()
    }
    
    func render(view: MTKView) {
        guard let drawable = view.currentDrawable else { return }

        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setTexture(texture, index: 0)
        
        // Dispatch threads
        let threadGroupSize = MTLSize(width: 8, height: 8, depth: 1)
        let threadGroups = MTLSize(width: (texture.width + 7) / 8,
                                   height: (texture.height + 7) / 8,
                                   depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        computeEncoder.endEncoding()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        guard let renderPassDescriptor = renderPassDescriptor else { return }

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // Set up the render pipeline and draw
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: 6, indexType: MTLIndexType.uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)

        renderEncoder.endEncoding()
        
        //Send our commands to the GPU
        commandBuffer.present(drawable)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    func draw(in view: MTKView) {
        render(view: view)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Resize texture if needed
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                          width: Int(size.width),
                                                                          height: Int(size.height),
                                                                          mipmapped: false)
        textureDescriptor.usage = [.shaderWrite, .shaderRead, .renderTarget]
        self.texture = device.makeTexture(descriptor: textureDescriptor)!
    }
}
