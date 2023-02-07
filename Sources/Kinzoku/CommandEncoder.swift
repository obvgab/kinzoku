public class KZCommandEncoder {
    public var c: WGPUCommandEncoder
    
    init(
        _ c: WGPUCommandEncoder
    ) {
        self.c = c
    }
    
    public func beginComputePass(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = "",
        writes: [WGPUComputePassTimestampWrite] = [] // Replace
    ) -> KZComputePassEncoder {
        return label.withCString { label in
            var descriptor = WGPUComputePassDescriptor(
                nextInChain: chain,
                label: label,
                timestampWriteCount: UInt32(writes.count),
                timestampWrites: getCopiedPointer(writes)
            )
            defer { descriptor.timestampWrites.deallocate() }
            
            return KZComputePassEncoder(wgpuCommandEncoderBeginComputePass(c, &descriptor))
        }
    }
    
    public func copyBufferToBuffer(
        source: KZBuffer,
        sourceOffset: UInt64 = 0,
        destination: KZBuffer,
        destinationOffset: UInt64 = 0,
        size: UInt64 = 0
    ) {
        wgpuCommandEncoderCopyBufferToBuffer(c, source.c, sourceOffset, destination.c, destinationOffset, size)
    }
    
    public func finish(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        label: String = ""
    ) -> KZCommandBuffer {
        return label.withCString { label in
            var descriptor = WGPUCommandBufferDescriptor(nextInChain: chain, label: label)
            
            return KZCommandBuffer(wgpuCommandEncoderFinish(c, &descriptor))
        }
    }
}
