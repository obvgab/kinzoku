import Wgpu

public struct KZDevice {
    public var c: WGPUDevice
    
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
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
