import WgpuHeaders

public struct KZBindGroup { public var c: WGPUBindGroup }
public struct KZBindGroupLayout { public var c: WGPUBindGroupLayout }

public typealias KZBindGroupEntry = WGPUBindGroupEntry
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
