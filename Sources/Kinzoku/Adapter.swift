import Wgpu

public struct KZAdapter {
    public var c: WGPUAdapter?
    
    #if !os(macOS)
    public func enumerateFeatures() -> [KZFeature] {
        var feature: UnsafeMutablePointer<WGPUFeature>? = nil
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
        
        return KZLimits(
            required: false,
            c_supported: limitHolder,
            
            nextInChain: limitHolder.nextInChain,
            
            maxTextureDimension1D: limitHolder.limits.maxTextureDimension1D,
            maxTextureDimension2D: limitHolder.limits.maxTextureDimension2D,
            maxTextureDimension3D: limitHolder.limits.maxTextureDimension3D,
            
            maxTextureArrayLayers: limitHolder.limits.maxTextureArrayLayers,
            maxBindGroups: limitHolder.limits.maxBindGroups,
            
            maxDynamicUniformBuffersPerPipelineLayout: limitHolder.limits.maxDynamicUniformBuffersPerPipelineLayout,
            maxDynamicStorageBuffersPerPipelineLayout: limitHolder.limits.maxDynamicStorageBuffersPerPipelineLayout,
            
            maxSampledTexturesPerShaderStage: limitHolder.limits.maxSampledTexturesPerShaderStage,
            maxSamplersPerShaderStage: limitHolder.limits.maxSamplersPerShaderStage,
            maxStorageBuffersPerShaderStage: limitHolder.limits.maxStorageBuffersPerShaderStage,
            maxStorageTexturesPerShaderStage: limitHolder.limits.maxStorageTexturesPerShaderStage,
            maxUniformBuffersPerShaderStage: limitHolder.limits.maxUniformBuffersPerShaderStage,
            
            maxUniformBufferBindingSize: limitHolder.limits.maxUniformBufferBindingSize,
            maxStorageBufferBindingSize: limitHolder.limits.maxStorageBufferBindingSize,
            minUniformBufferOffsetAlignment: limitHolder.limits.minUniformBufferOffsetAlignment,
            minStorageBufferOffsetAlignment: limitHolder.limits.minStorageBufferOffsetAlignment,
            
            maxVertexBuffers: limitHolder.limits.maxVertexBuffers,
            maxVertexAttributes: limitHolder.limits.maxVertexAttributes,
            maxVertexBufferArrayStride: limitHolder.limits.maxVertexBufferArrayStride,
            
            maxInterStageShaderComponents: limitHolder.limits.maxInterStageShaderComponents,
            
            maxComputeWorkgroupStorageSize: limitHolder.limits.maxComputeWorkgroupStorageSize,
            maxComputeInvocationsPerWorkgroup: limitHolder.limits.maxComputeInvocationsPerWorkgroup,
            maxComputeWorkgroupSizeX: limitHolder.limits.maxComputeWorkgroupSizeX,
            maxComputeWorkgroupSizeY: limitHolder.limits.maxComputeWorkgroupSizeY,
            maxComputeWorkgroupSizeZ: limitHolder.limits.maxComputeWorkgroupSizeZ,
            maxComputeWorkgroupsPerDimension: limitHolder.limits.maxComputeWorkgroupsPerDimension
        )
    }
    
    public func getProperties() -> KZProperties {
        var propertiesHolder = WGPUAdapterProperties()
        wgpuAdapterGetProperties(c, &propertiesHolder)
        
        return KZProperties(
            nextInChain: propertiesHolder.nextInChain,
            
            vendorID: propertiesHolder.vendorID,
            deviceID: propertiesHolder.deviceID,
            
            name: String(cString: propertiesHolder.name), // We should seriously handle nil on these Strings
            driverDescripton: "", //String(cString: propertiesHolder.driverDescription),
            
            type: KZAdapterType(rawValue: propertiesHolder.adapterType.rawValue) ?? .unknown,
            backend: KZBackendType(rawValue: propertiesHolder.backendType.rawValue) ?? .null
        )
    }
    
    #if !os(macOS)
    public func hasFeature(feature: KZFeature) -> Bool {
        return wgpuAdapterHasFeature(c, WGPUFeatureName(feature.rawValue))
    }
    #endif
    
    public typealias DeviceRequestCallback = (_ status: KZDeviceRequestStatus?, _ device: inout KZDevice?, _ message: String, _ userdata: UnsafeRawPointer?) -> Void
    public class DeviceRequestCallbackHandle { var callback: DeviceRequestCallback; var device: KZDevice? = nil; var userdata: UnsafeRawPointer?; init(callback: @escaping DeviceRequestCallback) { self.callback = callback } }
    public func requestDevice(
        nextInChain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "device",
        requiredFeatures: [KZFeature] = [],
        limits: inout KZLimits,
        queueNextInChain: UnsafePointer<WGPUChainedStruct>? = nil,
        queueLabel: String = "queue",
        callback: @escaping DeviceRequestCallback,
        userdata: UnsafeRawPointer? = nil
    ) -> KZDevice? {
        if !limits.required { print("Must be a RequiredLimit, not SupportedLimit"); return nil } // Replace with log at some point
        
        let featureCount = UInt32(requiredFeatures.count)
        var features: [WGPUFeatureName] = [WGPUFeatureName(0x00000000)] // Default value to not have an array index issue--should replace later
        if featureCount > 0 { features = requiredFeatures.map { WGPUFeatureName($0.rawValue) } }
        
        var descriptor = WGPUDeviceDescriptor(nextInChain: nextInChain, label: label, requiredFeaturesCount: featureCount, requiredFeatures: &features[0], requiredLimits: &limits.c_required!, defaultQueue: WGPUQueueDescriptor(nextInChain: queueNextInChain, label: queueLabel))
        let handle = DeviceRequestCallbackHandle(callback: callback)
        
        wgpuAdapterRequestDevice(c, &descriptor, { c_status, c_device, c_message, unmanagedCallback in
            var message = ""; if let c_message { message = String(cString: c_message) }
            let unmanagedHandle = Unmanaged<DeviceRequestCallbackHandle>.fromOpaque(unmanagedCallback!).takeUnretainedValue()
            
            unmanagedHandle.device = KZDevice(c: c_device)
            
            unmanagedHandle.callback(
                KZDeviceRequestStatus(rawValue: c_status.rawValue),
                &unmanagedHandle.device,
                message,
                unmanagedHandle.userdata
            )
        }, Unmanaged.passUnretained(handle).toOpaque())
        
        return handle.device
    }
}

public struct KZLimits { // TODO: Make an init function that assigns the c_required/c_supported values
    public var required = false
    public var c_required: WGPURequiredLimits? = nil
    public var c_supported: WGPUSupportedLimits? = nil
    
    public var nextInChain: UnsafePointer<WGPUChainedStructOut>? = nil // TODO: ChainedStruct Pointer
    
    // Limits
    public var maxTextureDimension1D: UInt32
    public var maxTextureDimension2D: UInt32
    public var maxTextureDimension3D: UInt32
    
    public var maxTextureArrayLayers: UInt32
    public var maxBindGroups: UInt32
    
    public var maxDynamicUniformBuffersPerPipelineLayout: UInt32
    public var maxDynamicStorageBuffersPerPipelineLayout: UInt32
    
    public var maxSampledTexturesPerShaderStage: UInt32
    public var maxSamplersPerShaderStage: UInt32
    public var maxStorageBuffersPerShaderStage: UInt32
    public var maxStorageTexturesPerShaderStage: UInt32
    public var maxUniformBuffersPerShaderStage: UInt32
    
    public var maxUniformBufferBindingSize: UInt64
    public var maxStorageBufferBindingSize: UInt64
    public var minUniformBufferOffsetAlignment: UInt32
    public var minStorageBufferOffsetAlignment: UInt32
    
    public var maxVertexBuffers: UInt32
    public var maxVertexAttributes: UInt32
    public var maxVertexBufferArrayStride: UInt32
    
    public var maxInterStageShaderComponents: UInt32
    
    public var maxComputeWorkgroupStorageSize: UInt32
    public var maxComputeInvocationsPerWorkgroup: UInt32
    public var maxComputeWorkgroupSizeX: UInt32
    public var maxComputeWorkgroupSizeY: UInt32
    public var maxComputeWorkgroupSizeZ: UInt32
    public var maxComputeWorkgroupsPerDimension: UInt32
}

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

public enum KZAdapterRequestStatus: UInt32 {
    case success = 0x00000000
    case unavailable = 0x00000001
    case error = 0x00000002
    case unknown = 0x00000003
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
