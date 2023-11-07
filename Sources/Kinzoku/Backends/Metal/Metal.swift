////
//  2F646B1A-8F4E-49F1-A15B-8B8A76564B9C: 10:53 11/6/23
//  Metal.swift by Gab
//

#if canImport(Metal)
import Metal

// MBE = (M)etal (B)ack(E)nd. This type satisfies a protocol, and should be invoked from a KZ context

// Maybe make some of these structs later?

// Descriptors should probably be backend-agnostic fs.

public class MBEAdapter: KZAdapter, KZDescribable {
    public func requestDevice(_ descriptor: MBEDevice.Descriptor?) async -> MBEDevice {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Kinzoku could not find a Metal device.") }
        guard let queue = device.makeCommandQueue() else { fatalError("Kinzoku couldn't acquire a command queue from the Metal device.") }
        
        return MBEDevice(queue: MBEQueue(inner: queue), inner: device, label: "Kinzoku Metal Device")
    }
    
    public struct Descriptor {
        public init(forceFallback: Bool, powerPreference: PowerPreference) {
            self.forceFallback = forceFallback
            self.powerPreference = powerPreference
        }
        
        var forceFallback: Bool = false
        var powerPreference: PowerPreference = .highPerformance
        
        public enum PowerPreference {
            case lowPower
            case highPerformance
        }
    }
}

public class MBEDevice: KZDevice {
    public var label: String
    public var queue: MBEQueue
    internal var inner: MTLDevice
    
    public init(queue: MBEQueue, inner: MTLDevice, label: String) {
        self.queue = queue
        self.inner = inner
        self.label = label
    }
    
    public func createShaderModule(_ descriptor: MBEShaderModule.Descriptor) -> MBEShaderModule {
        // Hard code this for now, should probably have an option to dynamically get a .sprv / .metal file from name
        var metalOptions = MTLCompileOptions()
        // Adjust options here??
        
        guard let library = try? inner.makeLibrary(source: descriptor.code, options: metalOptions) else { fatalError("Kizoku could not parse generated .metal information.") }
        
        return MBEShaderModule(inner: library)
    }
    
    public func createRenderPipeline(_ descriptor: MBERenderPipeline.Descriptor) -> MBERenderPipeline {
        fatalError("USE ASYNC FOR NOW")
    }
    
    public func createRenderPipeline(_ descriptor: MBERenderPipeline.Descriptor) async -> MBERenderPipeline {
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
    
    public func createCommandEncoder(_ descriptor: MBECommandEncoder.Descriptor?) -> MBECommandEncoder {
        guard let buffer = queue.inner.makeCommandBuffer() else { fatalError("Kinzoku could not establish a command context.") }
        
        return MBECommandEncoder(buffer: buffer)
    }
    
    public struct Descriptor {
        public init() {}
    }
}

public class MBEQueue: KZQueue {
    internal var inner: MTLCommandQueue
    
    public init(inner: MTLCommandQueue) {
        self.inner = inner
    }
    
    public func submit(_ commandBuffers: [MBECommandBuffer]) { // Semantically backwards compared to Metal
        for commandBuffer in commandBuffers {
            commandBuffer.inner.commit()
        }
    }
}

public class MBEShaderModule: KZDescribable {
    internal var inner: MTLLibrary
    
    public init(inner: MTLLibrary) {
        self.inner = inner
    }
    
    public struct Descriptor {
        public init(code: String) {
            self.code = code
        }
        
        var code: String
    }
}

public class MBERenderPipeline: KZDescribable {
    internal var inner: MTLRenderPipelineState
    
    public init(inner: MTLRenderPipelineState) {
        self.inner = inner
    }
    
    public struct Descriptor {
        public init(label: String, vertex: Vertex, fragment: Fragment) {
            self.label = label
            self.vertex = vertex
            self.fragment = fragment
        }
        
        var label: String
        // layout?
        var vertex: Vertex
        var fragment: Fragment // Optional?
        
        public struct Vertex {
            public init(entryPoint: String, module: MBEShaderModule) {
                self.entryPoint = entryPoint
                self.module = module
            }
            
            var entryPoint: String
            var module: MBEShaderModule
        }
        
        public struct Fragment {
            var entryPoint: String
            var module: MBEShaderModule
            var targets: [ColorTarget]
            
            public init(entryPoint: String, module: MBEShaderModule, targets: [ColorTarget]) {
                self.entryPoint = entryPoint
                self.module = module
                self.targets = targets
            }
        }
        
        public struct ColorTarget {
            public init() {}
        }
    }
}

public class MBECommandEncoder: KZCommandEncoder {
    internal var inner: MTLCommandEncoder?
    public var buffer: MTLCommandBuffer
    
    public init(inner: MTLCommandEncoder? = nil, buffer: MTLCommandBuffer) {
        self.inner = inner
        self.buffer = buffer
    }
    
    public func finish(_ descriptor: MBECommandBuffer.Descriptor? = nil) -> MBECommandBuffer {
        return MBECommandBuffer(label: descriptor?.label ?? "TEST", inner: buffer)
    }
    
    public func beginRenderPass(_ descriptor: MBERenderPassEncoder.Descriptor) -> MBERenderPassEncoder {
        var metalDescriptor = MTLRenderPassDescriptor() // TODO: Change this, I'm beggin you, It's all hardcoded!!
        metalDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.05, blue: 0, alpha: 1)
        metalDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        metalDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        metalDescriptor.colorAttachments[0].texture = descriptor.texture
        
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: metalDescriptor) else { fatalError("Kinzoku could not establish a render context.") }
        
        inner = encoder
        
        return MBERenderPassEncoder(inner: encoder)
    }
    
    public struct Descriptor { var label: String }
}

public class MBERenderPassEncoder: KZRenderPassEncoder {
    internal var inner: MTLRenderCommandEncoder
    
    public init(inner: MTLRenderCommandEncoder) {
        self.inner = inner
    }
    
    public func setPipeline(_ pipeline: MBERenderPipeline) { inner.setRenderPipelineState(pipeline.inner) }
    public func end() { inner.endEncoding() }

    public func draw(_ vertices: UInt32, _ instances: UInt32, _ firstVertex: UInt32, _ firstInstance: UInt32) {
        // fix primitive type
        inner.drawPrimitives(type: .triangle, vertexStart: Int(firstVertex), vertexCount: Int(vertices), instanceCount: Int(instances), baseInstance: Int(firstInstance))
    }
    
    public struct Descriptor {
        public init(texture: MTLTexture) {
            self.texture = texture
        }
        
        var texture: MTLTexture
    }
}

public class MBECommandBuffer: KZCommandBuffer {
    public var label: String
    internal var inner: MTLCommandBuffer
    
    public init(label: String, inner: MTLCommandBuffer) {
        self.label = label
        self.inner = inner
    }
    
    public struct Descriptor {
        public init(label: String) {
            self.label = label
        }
        
        var label: String
    }
}
#endif
