import Wgpu

public class KZDevice {
    public var c: WGPUDevice
    var pointers: (
        source: [UnsafeMutablePointer<WGPUShaderModuleDescriptor>],
        none: Void // none is just used so I can keep this as a tuple
    )
    
    init(_ c: WGPUDevice) {
        self.c = c
        
        pointers.source = []
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
        pointers.source.append(manualPointer(source.c))
        let module = wgpuDeviceCreateShaderModule(c, pointers.source.last) // This returns nil?
        
        return KZShaderModule(c: module!) // This then crashes
    }
    
    public func getQueue() -> KZQueue {
        return KZQueue(c: wgpuDeviceGetQueue(c))
    }
    
    deinit {
        pointers.source.forEach { pointer in pointer.deallocate() }
    }
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
