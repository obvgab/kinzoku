import QuartzCore

public class KZInstance {
    public var c: WGPUInstance
    var pointers: (
        label: [UnsafeMutablePointer<CChar>],
        metalDescriptor: [UnsafePointer<WGPUChainedStruct>],
        layer: [UnsafeMutableRawPointer]
    )
    
    public init(
        _ chain: UnsafePointer<WGPUChainedStruct>? = nil
    ) {
        var descriptor = WGPUInstanceDescriptor(nextInChain: chain)
        c = wgpuCreateInstance(&descriptor)
        
        pointers.label = []
        pointers.metalDescriptor = []
        pointers.layer = []
    }
    
    public func createSurface(
        metalLayer: CAMetalLayer,
        label: String = ""
    ) -> KZSurface {
        let chain = WGPUSurfaceDescriptorFromMetalLayer(
            chain: WGPUChainedStruct(
                next: nil,
                sType: WGPUSType_SurfaceDescriptorFromMetalLayer
            ),
            layer: Unmanaged.passUnretained(metalLayer).toOpaque()
        )
        
        let chainPointer = getCopiedPointer(chain)
        defer { chainPointer.deallocate() }
        let castedPointer = UnsafeRawPointer(chainPointer).bindMemory(to: WGPUChainedStruct.self, capacity: 1)
        
        return createSurface(chain: castedPointer, label: label)
    }
    
    public func createSurface(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = ""
    ) -> KZSurface {
        return label.withCString { label in
            var descriptor = WGPUSurfaceDescriptor(
                nextInChain: chain,
                label: label
            )
            
            return KZSurface(wgpuInstanceCreateSurface(c, &descriptor))
        }
    }
    
    public func processEvents() {
        wgpuInstanceProcessEvents(c)
    }
    
    public func requestAdapter(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        surface: KZSurface? = nil,
        power: KZPowerPreference = .undefined,
        fallback: Bool = false
    ) -> (KZAdapter, KZRequestAdapterStatus, String) {
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
            KZRequestAdapterStatus(rawValue: tuplePointer.pointee.1.rawValue) ?? .unknown,
            tuplePointer.pointee.2
        )
    }
    
    deinit {
        pointers.label.forEach { pointer in pointer.deallocate() }
    }
}
