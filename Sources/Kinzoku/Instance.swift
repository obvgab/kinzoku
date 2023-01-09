import WgpuHeaders

public class KZInstance {
    public var c: WGPUInstance
    var pointers: (
        label: [UnsafeMutablePointer<CChar>],
        none: Void
    )
    
    public init(
        _ chain: UnsafePointer<WGPUChainedStruct>? = nil
    ) {
        var descriptor = WGPUInstanceDescriptor(nextInChain: chain)
        c = wgpuCreateInstance(&descriptor)
        pointers.label = []
    }
    
    public func createSurface(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = ""
    ) -> KZSurface {
        pointers.label.append(strdup(label))
        var descriptor = WGPUSurfaceDescriptor(nextInChain: chain, label: pointers.label.last)
        
        return KZSurface(wgpuInstanceCreateSurface(c, &descriptor))
    }
    
    #if !os(macOS)
    public func processEvents() {
        wgpuInstanceProcessEvents(c)
    }
    #endif
    
    public func requestAdapter(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        surface: KZSurface? = nil,
        power: KZPowerPreference = .undefined,
        fallback: Bool = false
    ) -> (KZAdapter, KZAdapterRequestStatus, String) {
        let tuplePointer = UnsafeMutablePointer<(WGPUAdapter, WGPURequestAdapterStatus, String)>.allocate(capacity: 1)
        defer { tuplePointer.deallocate() }
        
        var options = WGPURequestAdapterOptions(
            nextInChain: chain,
            compatibleSurface: surface?.c,
            powerPreference: WGPUPowerPreference(power.rawValue),
            forceFallbackAdapter: fallback
        )
        
        wgpuInstanceRequestAdapter(c, &options, { status, adapter, message, rawTuplePointer in
            let rebound = rawTuplePointer!.bindMemory(to: (WGPUAdapter, WGPURequestAdapterStatus, String).self, capacity: 1)
            
            let message = (message != nil) ? String(cString: message!) : ""
            rebound.initialize(to: (adapter!, status, message))
        }, tuplePointer)
        
        return (
            KZAdapter(tuplePointer.pointee.0),
            KZAdapterRequestStatus(rawValue: tuplePointer.pointee.1.rawValue) ?? .unknown,
            tuplePointer.pointee.2
        )
    }
    
    deinit {
        pointers.label.forEach { pointer in pointer.deallocate() }
    }
}

public enum KZAdapterRequestStatus: UInt32 {
    case success = 0x00000000
    case unavailable = 0x00000001
    case error = 0x00000002
    case unknown = 0x00000003
    case force32 = 0x7FFFFFFF
}

public enum KZPowerPreference: UInt32 {
    case undefined = 0x00000000
    case lowPower = 0x00000001
    case highPerformance = 0x00000002
    case force32 = 0x7FFFFFFF
}
