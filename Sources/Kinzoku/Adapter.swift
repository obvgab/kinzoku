import Wgpu

public struct KZAdapter {
    public var c: WGPUAdapter
    
    #if !os(macOS)
    public func enumerateFeatures() -> [KZFeature] {
        var feature: UnsafeMutablePointer<WGPUFeatureName>? = nil
        let count = wgpuAdapterEnumerateFeatures(c, feature)
        
        guard let buffer = feature?.withMemoryRebound(to: KZFeature.self, capacity: count, { pointer in
            UnsafeBufferPointer(start: pointer, count: count)
        }) else { return [] }
        
        return Array(buffer)
    }
    #endif
    
    public func getLimits() -> KZLimits {
        var limitHolder = WGPUSupportedLimits()
        wgpuAdapterGetLimits(c, &limitHolder)
        
        return limitHolder.limits as KZLimits // Throws away Required/Supported
    }
    
    public func getProperties() -> KZProperties {
        var propertiesHolder = WGPUAdapterProperties()
        wgpuAdapterGetProperties(c, &propertiesHolder)
        
        let name = (propertiesHolder.name == nil) ? "Unknown Device" : String(cString: propertiesHolder.name)
        let driverDescription = (propertiesHolder.driverDescription == nil) ? "Empty Description" : String(cString: propertiesHolder.driverDescription)
        
        return KZProperties(
            nextInChain: propertiesHolder.nextInChain,
            
            vendorID: propertiesHolder.vendorID,
            deviceID: propertiesHolder.deviceID,
            
            name: name,
            driverDescripton: driverDescription,
            
            type: KZAdapterType(rawValue: propertiesHolder.adapterType.rawValue) ?? .unknown,
            backend: KZBackendType(rawValue: propertiesHolder.backendType.rawValue) ?? .null
        )
    }
    
    #if !os(macOS)
    public func hasFeature(feature: KZFeature) -> Bool {
        return wgpuAdapterHasFeature(c, WGPUFeatureName(feature.rawValue))
    }
    #endif
    
    public func requestDevice(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String? = nil,
        features: [KZFeature] = [],
        limits: inout KZLimits,
        queueChain: UnsafePointer<WGPUChainedStruct>? = nil,
        queueLabel: String? = nil
    ) -> (KZDevice, KZQueue, KZDeviceRequestStatus, String) { // Maybe we don't need to provide status and message, future refactor?
        let tuplePointer = UnsafeMutablePointer<(WGPUDevice, WGPUQueue, WGPURequestDeviceStatus, String)>.allocate(capacity: 1)
        defer { tuplePointer.deallocate() }
        
        let label = label == nil ? "\(c.hashValue)::KZDevice" : label!
        let queueLabel = queueLabel == nil ? "\(c.hashValue)::KZQueue" : queueLabel!
        
        var features = features.count > 0 ? features.map { name in WGPUFeatureName(name.rawValue) } : [WGPUFeatureName(.zero)]
        var requiredLimits = WGPURequiredLimits(nextInChain: nil, limits: limits)
        
        var descriptor = WGPUDeviceDescriptor(
            nextInChain: chain,
            label: label,
            requiredFeaturesCount: UInt32(features.count),
            requiredFeatures: &features[0],
            requiredLimits: &requiredLimits,
            defaultQueue: WGPUQueueDescriptor(nextInChain: queueChain, label: queueLabel)
        )
        
        wgpuAdapterRequestDevice(c, &descriptor, { status, device, message, rawTuplePointer in
            let rebound = rawTuplePointer!.bindMemory(to: (WGPUDevice, WGPUQueue, WGPURequestDeviceStatus, String).self, capacity: 1)
            
            if let device = device { rebound.pointee.0 = device }
            if let message = message { rebound.pointee.3 = String(cString: message) } else { rebound.pointee.3 = "" }
            
            rebound.pointee.2 = status
            rebound.pointee.1 = wgpuDeviceGetQueue(device)
        }, tuplePointer)
        
        return (
            KZDevice(c: tuplePointer.pointee.0),
            KZQueue(c: tuplePointer.pointee.1),
            KZDeviceRequestStatus(rawValue: tuplePointer.pointee.2.rawValue) ?? .unknown,
            tuplePointer.pointee.3
        )
    }
}

public typealias KZLimits = WGPULimits

public struct KZProperties {
    public var nextInChain: UnsafePointer<WGPUChainedStructOut>? = nil // TODO: ChainedStruct Pointer
    
    public var vendorID: UInt32
    public var deviceID: UInt32
    
    public var name: String
    public var driverDescripton: String
    
    public var type: KZAdapterType
    public var backend: KZBackendType
}

public enum KZAdapterType: UInt32 {
    case dgpu = 0x00000000
    case igpu = 0x00000001
    case cpu = 0x00000002
    case unknown = 0x00000003
    case force32 = 0x7FFFFFFF
}

public enum KZBackendType: UInt32 {
    case null = 0x00000000
    case webGPU = 0x00000001
    case d3d11 = 0x00000002
    case d3d12 = 0x00000003
    case metal = 0x00000004
    case vulkan = 0x00000005
    case openGL = 0x00000006
    case openGLES = 0x00000007
    case force32 = 0x7FFFFFFF
}

public enum KZFeature: UInt32 {
    case undefined = 0x00000000
    case depthClipControl = 0x00000001
    case depth24UnormStencil8 = 0x00000002
    case depth32FloatStencil8 = 0x00000003
    case timestampQuery = 0x00000004
    case pipelineStatisticsQuery = 0x00000005
    case textureCompressionBC = 0x00000006
    case textureCompressionETC2 = 0x00000007
    case textureCompressionASTC = 0x00000008
    case indirectFirstInstance = 0x00000009
    case force32 = 0x7FFFFFFF
}
