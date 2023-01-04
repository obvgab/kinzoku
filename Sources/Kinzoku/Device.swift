import Wgpu

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
    
    #if !os(macOS)
    public func enumerateFeatures() -> [KZFeature] {
        var feature: UnsafeMutablePointer<WGPUFeatureName>? = nil
        let count = wgpuDeviceEnumerateFeatures(c, feature)
        
        guard let buffer = feature?.withMemoryRebound(to: KZFeature.self, capacity: count, { pointer in
            UnsafeBufferPointer(start: pointer, count: count)
        }) else { return [] }
        
        return Array(buffer)
    }
    #endif
    
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
        let entriesPointer = manualPointer(entries); let labelPointer = strdup(label)
        defer { entriesPointer.deallocate(); labelPointer?.deallocate() }
        
        var descriptor = WGPUBindGroupDescriptor(
            nextInChain: chain,
            label: labelPointer,
            layout: layout?.c,
            entryCount: UInt32(entries.count),
            entries: entriesPointer
        )
        
        return KZBindGroup(c: wgpuDeviceCreateBindGroup(c, &descriptor))
    }
    
    public func createBuffer(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        usage: [KZBufferUsage] = [.none],
        size: UInt64 = 0,
        mapped: Bool = false
    ) -> KZBuffer {
        let labelPointer = strdup(label); defer { labelPointer?.deallocate() }
        var usageRaw: UInt32 = 0x00000000; usage.forEach { flag in usageRaw |= flag.rawValue }
        
        var descriptor = WGPUBufferDescriptor(
            nextInChain: chain,
            label: labelPointer,
            usage: usageRaw,
            size: size,
            mappedAtCreation: mapped
        )
        
        return KZBuffer(wgpuDeviceCreateBuffer(c, &descriptor))
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
        let constsPointer = manualPointer(consts); let labelPointer = strdup(label); let entryLabel = strdup(entry);
        defer { constsPointer.deallocate(); labelPointer?.deallocate(); entryLabel?.deallocate() }
        
        var descriptor = WGPUComputePipelineDescriptor(
            nextInChain: chain,
            label: labelPointer,
            layout: layout?.c,
            compute: WGPUProgrammableStageDescriptor(
                nextInChain: stageChain,
                module: module?.c,
                entryPoint: entryLabel,
                constantCount: UInt32(consts.count),
                constants: constsPointer
            )
        )
        
        return KZComputePipeline(c: wgpuDeviceCreateComputePipeline(c, &descriptor))
    }
    
    public func createCommandEncoder(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = ""
    ) -> KZCommandEncoder {
        let labelPointer = strdup(label); defer { labelPointer?.deallocate() }
        
        var descriptor = WGPUCommandEncoderDescriptor(
            nextInChain: chain,
            label: labelPointer
        )
        
        return KZCommandEncoder(wgpuDeviceCreateCommandEncoder(c, &descriptor))
    }
    
    public func getQueue() -> KZQueue {
        return KZQueue(wgpuDeviceGetQueue(c))
    }
    
    public func poll(wait: Bool = false) { // Eventually fully implement submissionIndex
        wgpuDevicePoll(c, wait, nil)
    }
    
    //deinit {}
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
