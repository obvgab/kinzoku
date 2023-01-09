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
        let labelPointer = strdup(label); let writesPointer = manualPointer(writes);
        
        var descriptor = WGPUComputePassDescriptor(
            nextInChain: chain,
            label: labelPointer,
            timestampWriteCount: UInt32(writes.count),
            timestampWrites: writesPointer
        )
        
        return KZComputePassEncoder(wgpuCommandEncoderBeginComputePass(c, &descriptor))
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
        let labelPointer = strdup(label); defer { labelPointer?.deallocate() }
        
        var descriptor = WGPUCommandBufferDescriptor(nextInChain: chain, label: labelPointer)
        
        return KZCommandBuffer(wgpuCommandEncoderFinish(c, &descriptor))
    }
}
