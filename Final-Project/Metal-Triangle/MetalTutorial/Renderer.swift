import Metal
import MetalKit
import simd

struct Vertex {
    var position: simd_float2
    var color: simd_float3
}

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var library: MTLLibrary
    
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    var computeFunction: MTLFunction
    
    var renderPipelineState: MTLRenderPipelineState!
    var computePipeline: MTLComputePipelineState!
    
    var vertexBuffer: MTLBuffer
    var computeInputBuffer: MTLBuffer
    var computeOutputBuffer: MTLBuffer
    
    var input: [Float]
    var output: [Float]
    
    init?(metalKitView: MTKView) {
        //Device and command queue
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        // Init the library
        self.library = device.makeDefaultLibrary()!
        
        // Make functions that connect to the function names given in the Shaders file
        self.vertexFunction = library.makeFunction(name: "vertexFunction")!
        self.fragmentFunction = library.makeFunction(name: "fragmentFunction")!
        self.computeFunction = library.makeFunction(name: "computeShader")!
        self.computePipeline = try! device.makeComputePipelineState(function: computeFunction)
        
        // Init the render pipeline
        var renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
        } catch {
            print("Could not initialize the render pipeline state")
        }
        
        let vertices: [Float] = [
            -0.5, -0.5, //vertex 0
             0.5, -0.5, //vertex 1
             0.0,  0.5  //vertex 2
        ]

        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout.stride(ofValue: vertices[0]), options: MTLResourceOptions.storageModeShared)!
        
        self.input = [1.0, 2.0, 3.0, 4.0]
        self.output = [Float](repeating: 0, count: input.count)
                
        self.computeInputBuffer = device.makeBuffer(bytes: input,
                                                    length: input.count * MemoryLayout<Float>.stride,
                                                    options: [])!
        self.computeOutputBuffer = device.makeBuffer(length: output.count * MemoryLayout<Float>.stride,
                                                     options: [])!
        
        super.init()
    }

    func draw(in view: MTKView) {
        //Create command buffer
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        
        //Retrieve render pass descriptor and change the background color
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        //Create render command encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //Bind render pipeline state
        renderEncoder.setRenderPipelineState(self.renderPipelineState!)
        
        //Bind vertex buffer
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        //Render
        renderEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
        
        //End encoding
        renderEncoder.endEncoding()
        
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipeline)
        
        computeEncoder.setBuffer(computeInputBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(computeOutputBuffer, offset: 0, index: 1)
        
        // Dispatch threads
        let threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroups = MTLSize(width: input.count, height: 1, depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)

        computeEncoder.endEncoding()
        
        //Retrieve drawable and present it to the screen
        let drawable = view.currentDrawable!
        commandBuffer.present(drawable)
            
        //Send our commands to the GPU
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // 6. Read back results
        let resultPointer = computeOutputBuffer.contents().bindMemory(to: Float.self, capacity: output.count)
        for i in 0..<output.count {
            output[i] = resultPointer[i]
        }

        print("Input: \(input)")
        print("Output: \(output)")
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}
