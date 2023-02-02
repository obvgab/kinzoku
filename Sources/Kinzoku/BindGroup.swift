public struct KZBindGroup { internal var c: WGPUBindGroup }
public struct KZBindGroupLayout { internal var c: WGPUBindGroupLayout }

public typealias KZBindGroupEntry = WGPUBindGroupEntry // We can extend c structs without OpaquePointer worries
extension KZBindGroupEntry {
    init(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        binding: UInt32 = 0,
        offset: UInt64 = 0,
        size: UInt64 = 0,
        buffer: KZBuffer? = nil,
        sampler: WGPUSampler? = nil, // Replace
        view: WGPUTextureView? = nil // Replace
    ) {
        self = WGPUBindGroupEntry(
            nextInChain: chain,
            binding: binding,
            buffer: buffer?.c,
            offset: offset,
            size: size,
            sampler: sampler,
            textureView: view
        )
    }
}
