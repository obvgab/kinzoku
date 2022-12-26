import Wgpu

public class KZInstance {
    public var c: WGPUInstance
    
    public init(
        _ nextInChain: UnsafePointer<WGPUChainedStruct>? = nil // TODO: ChainedStruct Pointer
    ) {
        var descriptor = WGPUInstanceDescriptor(nextInChain: nextInChain)
        c = wgpuCreateInstance(&descriptor)
    }
    
    public func createSurface(
        nextInChain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "surface"
    ) -> KZSurface {
        var descriptor = WGPUSurfaceDescriptor(nextInChain: nextInChain, label: label)
        return KZSurface(wgpuInstanceCreateSurface(c, &descriptor))
    }
    
    // Omitted due to exclusion on macOS
    /*
    public func processEvents() {
        wgpuInstanceProcessEvents(c)
    }
    */
    
    public typealias AdapterRequestCallback = (_ status: KZAdapterRequestStatus?, _ adapter: inout KZAdapter?, _ message: String, _ userdata: UnsafeRawPointer?) -> Void
    public class AdapterRequestCallbackHandle { var callback: AdapterRequestCallback; var adapter: KZAdapter? = nil; var userdata: UnsafeRawPointer?; init(callback: @escaping AdapterRequestCallback) { self.callback = callback } }
    public func requestAdapter(
        nextInChain: UnsafePointer<WGPUChainedStruct>? = nil, // TODO: ChainedStruct pointer
        compatibleSurface: WGPUSurface? = nil, // TODO: Surface struct
        powerPreference: KZPowerPreference = .undefined,
        forceFallbackAdapter: Bool = false,
        callback: @escaping AdapterRequestCallback,
        userdata: UnsafeRawPointer? = nil
    ) -> KZAdapter? {
        var options = WGPURequestAdapterOptions(nextInChain: nextInChain, compatibleSurface: compatibleSurface, powerPreference: WGPUPowerPreference(powerPreference.rawValue), forceFallbackAdapter: forceFallbackAdapter)
        let handle = AdapterRequestCallbackHandle(callback: callback)
        
        wgpuInstanceRequestAdapter(c, &options, {c_status, c_adapter, c_message, unmanagedCallback in
            var message = ""; if let c_message { message = String(cString: c_message) }
            let unmanagedHandle = Unmanaged<AdapterRequestCallbackHandle>.fromOpaque(unmanagedCallback!).takeUnretainedValue()
            
            unmanagedHandle.adapter = KZAdapter(c: c_adapter)
            
            unmanagedHandle.callback(
                KZAdapterRequestStatus(rawValue: c_status.rawValue),
                &unmanagedHandle.adapter,
                message,
                unmanagedHandle.userdata
            )
        }, Unmanaged.passUnretained(handle).toOpaque())
        
        return handle.adapter
    }
}

public enum KZPowerPreference: UInt32 {
    case undefined = 0x00000000
    case lowPower = 0x00000001
    case highPerformance = 0x00000002
    case force32 = 0x7FFFFFFF
}
