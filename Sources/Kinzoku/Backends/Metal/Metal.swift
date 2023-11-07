////
//  2F646B1A-8F4E-49F1-A15B-8B8A76564B9C: 10:53 11/6/23
//  Metal.swift by Gab
//

#if canImport(Metal)
import Metal

// MBE = (M)etal (B)ack(E)nd. This type satisfies a protocol, and should be invoked from a KZ context

// Maybe make some of these structs later?

// Descriptors should probably be backend-agnostic fs.

// Instance might be better as a unified struct, since most backends will just return the adapter object regardless
// This would also make it easier to write agnostic code, since you would just invoke KZInstance as a struct instead
// of it being a protocol.
struct MBEInstance: KZInstance {
    func requestAdapter(_ options: MBEAdapter.Descriptor? = MBEAdapter.Descriptor()) async -> MBEAdapter {
        // TODO: Implement selection with fallback and power preference for intel machines
        return MBEAdapter()
    }
}

class MBEAdapter: KZAdapter, KZDescribable {    
    func requestDevice(_ descriptor: MBEDevice.Descriptor?) async -> MBEDevice {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Kinzoku could not find a Metal device.") }
        guard let queue = device.makeCommandQueue() else { fatalError("Kinzoku couldn't acquire a command queue from the Metal device.") }
        
        return MBEDevice(queue: MBEQueue(inner: queue), inner: device, label: "Kinzoku Metal Device")
    }
    
    struct Descriptor {
        var forceFallback: Bool = false
        var powerPreference: PowerPreference = .highPerformance
        
        enum PowerPreference {
            case lowPower
            case highPerformance
        }
    }
}

class MBEDevice: KZDevice {
    var queue: MBEQueue
    var inner: MTLDevice
    var label: String
    
    init(queue: MBEQueue, inner: MTLDevice, label: String) {
        self.queue = queue
        self.inner = inner
        self.label = label
    }
    
    func createShaderModule(_ descriptor: MBEShaderModule.Descriptor) -> MBEShaderModule {
        // Hard code this for now, should probably have an option to dynamically get a .sprv / .metal file from name
        var metalOptions = MTLCompileOptions()
        // Adjust options here??
        
        guard let library = try? inner.makeLibrary(source: descriptor.code, options: metalOptions) else { fatalError("Kizoku could not parse generated .metal information.") }
        
        return MBEShaderModule(inner: library)
    }
    
    func createRenderPipeline(_ descriptor: MBERenderPipeline.Descriptor) -> MBERenderPipeline {
        fatalError("USE ASYNC FOR NOW")
    }
    
    func createRenderPipeline(_ descriptor: MBERenderPipeline.Descriptor) async -> MBERenderPipeline {
        // Hardcode for testing
        var metalDescriptor = MTLRenderPipelineDescriptor()
        metalDescriptor.label = descriptor.label
        
        if let vertexFunc = descriptor.vertex.module.inner.makeFunction(name: descriptor.vertex.entryPoint) {
            metalDescriptor.vertexFunction = vertexFunc
        }
        if let fragmentFunc = descriptor.fragment.module.inner.makeFunction(name: descriptor.fragment.entryPoint) {
            metalDescriptor.fragmentFunction = fragmentFunc
            metalDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // HARDCODED
        }
        
        guard let pipeline = try? await inner.makeRenderPipelineState(descriptor: metalDescriptor) else { fatalError("Kinzoku could not create a render pipeline.") }
        
        return MBERenderPipeline(inner: pipeline)
    }
    
    func createCommandEncoder(_ descriptor: MBECommandEncoder.Descriptor?) -> MBECommandEncoder {
        guard let buffer = queue.inner.makeCommandBuffer() else { fatalError("Kinzoku could not establish a command context.") }
        
        return MBECommandEncoder(buffer: buffer)
    }
    
    struct Descriptor {
        
    }
}

class MBEQueue: KZQueue {
    var inner: MTLCommandQueue
    
    init(inner: MTLCommandQueue) {
        self.inner = inner
    }
    
    func submit(_ commandBuffers: [MBECommandBuffer]) { // Semantically backwards compared to Metal
        for commandBuffer in commandBuffers {
            commandBuffer.inner.commit()
        }
    }
}

class MBEShaderModule: KZDescribable {
    var inner: MTLLibrary
    
    init(inner: MTLLibrary) {
        self.inner = inner
    }
    
    struct Descriptor {
        var code: String
    }
}

class MBERenderPipeline: KZDescribable {
    var inner: MTLRenderPipelineState
    
    init(inner: MTLRenderPipelineState) {
        self.inner = inner
    }
    
    struct Descriptor {
        var label: String
        // layout?
        var vertex: Vertex
        var fragment: Fragment // Optional?
        
        struct Vertex {
            var entryPoint: String
            var module: MBEShaderModule
        }
        
        struct Fragment {
            var entryPoint: String
            var module: MBEShaderModule
            var targets: [ColorTarget]
        }
        
        struct ColorTarget {
            
        }
    }
}

class MBECommandEncoder: KZCommandEncoder {
    var inner: MTLCommandEncoder?
    var buffer: MTLCommandBuffer
    
    init(inner: MTLCommandEncoder? = nil, buffer: MTLCommandBuffer) {
        self.inner = inner
        self.buffer = buffer
    }
    
    func finish(_ descriptor: MBECommandBuffer.Descriptor? = nil) -> MBECommandBuffer {
        return MBECommandBuffer(label: descriptor?.label ?? "TEST", inner: buffer)
    }
    
    func beginRenderPass(_ descriptor: MBERenderPassEncoder.Descriptor) -> MBERenderPassEncoder {
        var metalDescriptor = MTLRenderPassDescriptor() // TODO: Change this, I'm beggin you
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: metalDescriptor) else { fatalError("Kinzoku could not establish a render context.") }
        
        inner = encoder
        
        return MBERenderPassEncoder(inner: encoder)
    }
    
    struct Descriptor { var label: String }
}

class MBERenderPassEncoder: KZRenderPassEncoder {
    var inner: MTLRenderCommandEncoder
    
    init(inner: MTLRenderCommandEncoder) {
        self.inner = inner
    }
    
    func setPipeline(_ pipeline: MBERenderPipeline) {
        
    }
    
    func end() {
        
    }

    func draw(_ vertices: UInt32, _ instances: UInt32, _ firstVertex: UInt32, _ firstInstance: UInt32) {
        
    }
    
    struct Descriptor {
        
    }
}

class MBECommandBuffer: KZCommandBuffer {
    var label: String
    var inner: MTLCommandBuffer
    
    init(label: String, inner: MTLCommandBuffer) {
        self.label = label
        self.inner = inner
    }
    
    struct Descriptor {
        var label: String
    }
}
#endif
