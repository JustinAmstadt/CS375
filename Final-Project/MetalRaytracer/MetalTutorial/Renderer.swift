import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var library: MTLLibrary
    
    lazy var computePipeline: MTLComputePipelineState = self.makeComputePipeline()
    lazy var renderPipeline: MTLRenderPipelineState = self.makeRenderPipeline()
    
    lazy var vertexBuffer: MTLBuffer = self.makeVertexBuffer()
    var indexBuffer: MTLBuffer
    
    var texture: MTLTexture
    
    var quadIndices: [ushort]
    
    init?(metalKitView: MTKView) {
        //Device and command queue
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        // Init the library
        self.library = device.makeDefaultLibrary()!
        
        // Create a texture to hold the computed image
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                          width: Int(metalKitView.drawableSize.width),
                                                                          height: Int(metalKitView.drawableSize.height),
                                                                          mipmapped: false)
        textureDescriptor.usage = [.shaderWrite, .shaderRead, .renderTarget]
        self.texture = device.makeTexture(descriptor: textureDescriptor)!
        
        quadIndices = [
            0, 1, 2,
            0, 2, 3
        ]
        
        self.indexBuffer = self.device.makeBuffer(bytes: quadIndices, length: quadIndices.count * MemoryLayout.stride(ofValue: quadIndices[0]), options: MTLResourceOptions.storageModeShared)!
        
        super.init()
    }
    
    func render(view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        if texture.width != Int(view.drawableSize.width) || texture.height != Int(view.drawableSize.height) {
            print("ERROR: The texture's dimensions are different from view.drawableSize dimensions!")
        }
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        
        computePass(commandBuffer)
        renderPass(view, commandBuffer)
        
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
    
    func computePass(_ commandBuffer: MTLCommandBuffer) {
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setTexture(texture, index: 0)
        
        setComputeBuffers(computeEncoder)
        
        // Dispatch threads
        let width = computePipeline.threadExecutionWidth
        let height = computePipeline.maxTotalThreadsPerThreadgroup / width
        let threadGroupSize = MTLSize(width: width, height: height, depth: 1)
        let threadGroups = MTLSize(
            width: (texture.width + width - 1) / width,
            height: (texture.height + height - 1) / height,
            depth: 1
        )
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        computeEncoder.endEncoding()
    }
    
    func setComputeBuffers(_ computeEncoder: MTLComputeCommandEncoder) {
        // Spheres
        
        let spheres: [Sphere] = [
            Sphere(center: vector_float3(0, 0, -2.0), radius: 0.5, color: simd_float3(1, 0, 0)),
            Sphere(center: vector_float3(0, -5.0, -5.0), radius: 1.0, color: simd_float3(1, 1, 0)),
            Sphere(center: vector_float3(-2.5, -1.5, -4.0), radius: 1.0, color: simd_float3(1, 0, 1)),
        ]
        
        let sphereBuffer: SphereBuffer = SphereBuffer(device: device, spheres: spheres)

        computeEncoder.setBuffer(sphereBuffer.buffer, offset: 0, index: 0)
        computeEncoder.setBuffer(sphereBuffer.countBuffer, offset: 0, index: 1)
        
        // Planes
        
        let planes: [Plane] = [
            Plane(center: vector_float3(0.0, 0.0, 5.0), normal: normalize(vector_float3(0.0, 0.0, 1.0)), color: simd_float3(0.0, 1.0, 0.0))
        ]
        
        let planeBuffer: PlaneBuffer = PlaneBuffer(device: device, planes: planes)
        
        computeEncoder.setBuffer(planeBuffer.buffer, offset: 0, index: 2)
        computeEncoder.setBuffer(planeBuffer.countBuffer, offset: 0, index: 3)
        
        // Disks
        
        let disks: [Disk] = [
            Disk(center: vector_float3(-0.8, -0.3, 1.0), normal: normalize(vector_float3(1.0, 0.0, 1.0)),
            radius: 0.4, color: simd_float3(1.0, 1.0, 1.0))
        ]
        
        let diskBuffer: DiskBuffer = DiskBuffer(device: device, disks: disks)
        
        computeEncoder.setBuffer(diskBuffer.buffer, offset: 0, index: 4)
        computeEncoder.setBuffer(diskBuffer.countBuffer, offset: 0, index: 5)
        
        // Triangles
        
        let triangles: [Triangle] = [
            Triangle(v0: vector_float3(-0.8, -0.8, 2.0), v1: vector_float3(0.8, -0.8, 2.0), v2: vector_float3(0.8, 0.8, 2.0), color: simd_float3(1.0, 1.0, 0.0))
        ]
        
        let triangleBuffer: TriangleBuffer = TriangleBuffer(device: device, triangles: triangles)
        
        computeEncoder.setBuffer(triangleBuffer.buffer, offset: 0, index: 6)
        computeEncoder.setBuffer(triangleBuffer.countBuffer, offset: 0, index: 7)
        
        // Models
        
        var vertices: [vector_float3] = []
        var indices: [UInt32] = []
        
        // Keep doing this on these arrays to get the full list of model values packed into these two arrays
        let teapotModel = getObjData(objFile: "teapot.obj", verts: &vertices, indices: &indices)
        
        let models: [Model] = [
            teapotModel
        ]
        
        let modelData = ModelDataBuffer(device: device, vertices: vertices, indices: indices)
        let modelBuffer = ModelBuffer(device: device, models: models)
        
        computeEncoder.setBuffer(modelBuffer.buffer, offset: 0, index: 8)
        computeEncoder.setBuffer(modelBuffer.countBuffer, offset: 0, index: 9)
        computeEncoder.setBuffer(modelData.verticesBuffer, offset: 0, index: 10)
        computeEncoder.setBuffer(modelData.indicesBuffer, offset: 0, index: 11)
    }
    
    func renderPass(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
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
    }
    
    func makeRenderPipeline() -> MTLRenderPipelineState {
        let vertexFunction = library.makeFunction(name: "vertexShader")!
        let fragmentFunction = library.makeFunction(name: "fragmentShader")!
        
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
        return try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func makeComputePipeline() -> MTLComputePipelineState {
        let computeFunction = library.makeFunction(name: "computeShader")!
        return try! device.makeComputePipelineState(function: computeFunction)
    }
    
    func makeVertexBuffer() -> MTLBuffer {
        // Flip the y axis here
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-1.0, 1.0), texCoord: simd_float2(0.0, 1.0)), //vertex 0
            Vertex(position: simd_float2( 1.0, 1.0), texCoord: simd_float2(1.0, 1.0)), //vertex 1
            Vertex(position: simd_float2( 1.0, -1.0), texCoord: simd_float2(1.0, 0.0)), //vertex 2
            Vertex(position: simd_float2(-1.0, -1.0), texCoord: simd_float2(0.0, 0.0))  //vertex 3
        ]

        return device.makeBuffer(bytes: vertices,
                                              length: MemoryLayout<Vertex>.size * vertices.count,
                                              options: .storageModeShared)!
    }
}
