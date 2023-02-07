public class KZDevice {
    public var c: WGPUDevice
    //var pointers: ()
    
    init(_ c: WGPUDevice) {
        self.c = c
    }
    
    /*
    public func createBindGroup(
    
    ) -> KZBindGroup {
        
    }
    */
    
    public func enumerateFeatures() -> [KZFeature] {
        let feature: UnsafeMutablePointer<WGPUFeatureName>? = nil
        let count = wgpuDeviceEnumerateFeatures(c, feature)
        
        guard let buffer = feature?.withMemoryRebound(to: KZFeature.self, capacity: count, { pointer in
            UnsafeBufferPointer(start: pointer, count: count)
        }) else { return [] }
        
        return Array(buffer)
    }
    
    public func createShaderModule(
        source: KZShaderSource
    ) -> KZShaderModule {
        return KZShaderModule(c: wgpuDeviceCreateShaderModule(c, &source.c))
    }
    
    public func createBindGroup(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        layout: KZBindGroupLayout? = nil,
        entries: [KZBindGroupEntry] = []
    ) -> KZBindGroup {
        return label.withCString { label in
            var descriptor = WGPUBindGroupDescriptor(
                nextInChain: chain,
                label: label,
                layout: layout?.c,
                entryCount: UInt32(entries.count),
                entries: getCopiedPointer(entries)
            )
            defer { descriptor.entries.deallocate() }
            
            return KZBindGroup(c: wgpuDeviceCreateBindGroup(c, &descriptor))
        }
    }
    
    public func createBuffer(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        usage: [KZBufferUsage] = [.none],
        size: UInt64 = 0,
        mapped: Bool = false
    ) -> KZBuffer {
        return label.withCString { label in
            var usageRaw: UInt32 = 0x00000000; usage.forEach { flag in usageRaw |= flag.rawValue }
            
            var descriptor = WGPUBufferDescriptor(
                nextInChain: chain,
                label: label,
                usage: usageRaw,
                size: size,
                mappedAtCreation: mapped
            )
            
            return KZBuffer(wgpuDeviceCreateBuffer(c, &descriptor))
        }
    }
    
    public func createComputePipeline(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        stageChain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        layout: KZPipelineLayout? = nil,
        module: KZShaderModule? = nil,
        entry: String = "main",
        consts: [WGPUConstantEntry] = [] // We might want our own struct here
    ) -> KZComputePipeline {
        return label.withCString { label in
            return entry.withCString { entry in
                var descriptor = WGPUComputePipelineDescriptor(
                    nextInChain: chain,
                    label: label,
                    layout: layout?.c,
                    compute: WGPUProgrammableStageDescriptor(
                        nextInChain: stageChain,
                        module: module?.c,
                        entryPoint: entry,
                        constantCount: UInt32(consts.count),
                        constants: getCopiedPointer(consts)
                    )
                )
                defer { descriptor.compute.constants.deallocate() }
                
                return KZComputePipeline(c: wgpuDeviceCreateComputePipeline(c, &descriptor))
            }
        }
    }
    
    public func createRenderPipeline(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        layout: KZPipelineLayout? = nil
        // VertexState
        // PrimitiveState
        // DepthStencilState
        // MultiSampleState
        // FragmentState
    ) {
        
    }
    
    public func createCommandEncoder(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = ""
    ) -> KZCommandEncoder {
        return label.withCString { label in
            var descriptor = WGPUCommandEncoderDescriptor(
                nextInChain: chain,
                label: label
            )
            
            return KZCommandEncoder(wgpuDeviceCreateCommandEncoder(c, &descriptor))
        }
    }
    
    public func getQueue() -> KZQueue {
        return KZQueue(wgpuDeviceGetQueue(c))
    }
    
    public func poll(wait: Bool = false) { // Eventually fully implement submissionIndex
        _ = wgpuDevicePoll(c, wait, nil)
    }
    
    //deinit {}
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
