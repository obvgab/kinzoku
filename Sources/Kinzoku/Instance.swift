import Wgpu

public class KZInstance {
    public var c: WGPUInstance
    var pointers: (label: [UnsafeMutablePointer<CChar>], none: Void)
    
    public init(
        _ nextInChain: UnsafePointer<WGPUChainedStruct>? = nil // TODO: ChainedStruct Pointer
    ) {
        var descriptor = WGPUInstanceDescriptor(nextInChain: nextInChain)
        c = wgpuCreateInstance(&descriptor)
        pointers.label = []
    }
    
    public func createSurface(
        chain: UnsafePointer<WGPUChainedStruct>? = nil, // TODO: ChainedStruct Pointer
        label: String = ""
    ) -> KZSurface {
        let labelArray = label.cString(using: String.Encoding.utf8)!
        pointers.label.append(UnsafeMutablePointer<CChar>.allocate(capacity: labelArray.count))
        pointers.label.last?.initialize(from: labelArray, count: labelArray.count)
        
        var descriptor = WGPUSurfaceDescriptor(nextInChain: chain, label: pointers.label.last)
        return KZSurface(wgpuInstanceCreateSurface(c, &descriptor))
    }
    
    #if !os(macOS)
    public func processEvents() {
        wgpuInstanceProcessEvents(c)
    }
    #endif
    
    public func requestAdapter(
        chain: UnsafePointer<WGPUChainedStruct>? = nil, // TODO: ChainedStruct pointer
        surface: WGPUSurface? = nil, // TODO: Surface struct
        power: KZPowerPreference = .undefined,
        fallback: Bool = false
    ) -> (KZAdapter, KZAdapterRequestStatus, String) { // Maybe we don't need to provide status and message, future refactor?
        let tuplePointer = UnsafeMutablePointer<(WGPUAdapter, WGPURequestAdapterStatus, String)>.allocate(capacity: 1)
        defer { tuplePointer.deallocate() }
        
        var options = WGPURequestAdapterOptions(
            nextInChain: chain,
            compatibleSurface: surface,
            powerPreference: WGPUPowerPreference(power.rawValue),
            forceFallbackAdapter: fallback
        )
        
        wgpuInstanceRequestAdapter(c, &options, { status, adapter, message, rawTuplePointer in
            let rebound = rawTuplePointer!.bindMemory(to: (WGPUAdapter, WGPURequestAdapterStatus, String).self, capacity: 1)
            
            if let adapter = adapter { rebound.pointee.0 = adapter }
            if let message = message { rebound.pointee.2 = String(cString: message) } else { rebound.pointee.2 = "" }
            
            rebound.pointee.1 = status
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
