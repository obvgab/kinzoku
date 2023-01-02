import Wgpu

public class KZDevice {
    public var c: WGPUDevice
    var pointers: (
        bufferLabel: [UnsafeMutablePointer<CChar>],
        none: Void
    )
    
    init(_ c: WGPUDevice) {
        self.c = c
        
        pointers.bufferLabel = []
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
    
    public func createBuffer(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        usage: [KZBufferUsage] = [.none],
        size: UInt64 = 0,
        mapped: Bool = false
    ) -> KZBuffer {
        pointers.bufferLabel.append(strdup(label))
        var usageRaw: UInt32 = 0x00000000; usage.forEach { flag in usageRaw |= flag.rawValue }
        
        var descriptor = WGPUBufferDescriptor(
            nextInChain: chain,
            label: pointers.bufferLabel.last,
            usage: usageRaw,
            size: size,
            mappedAtCreation: mapped
        )
        
        return KZBuffer(wgpuDeviceCreateBuffer(c, &descriptor))
    }
    
    public func getQueue() -> KZQueue {
        return KZQueue(c: wgpuDeviceGetQueue(c))
    }
    
    deinit {
        pointers.bufferLabel.forEach { pointer in pointer.deallocate() }
    }
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
