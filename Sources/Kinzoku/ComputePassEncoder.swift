import Wgpu

public class KZComputePassEncoder {
    public var c: WGPUComputePassEncoder
    var pointer: (
        dynamicOffsets: UnsafeMutablePointer<UInt32>?,
        none: Void
    )
    
    init(_ c: WGPUComputePassEncoder) {
        self.c = c
        pointer.dynamicOffsets = nil
    }
    
    public func setPipeline(pipeline: KZComputePipeline) {
        wgpuComputePassEncoderSetPipeline(c, pipeline.c)
    }
    
    public func setBindGroup(
        index: UInt32 = 0,
        bindGroup: KZBindGroup,
        dynamicOffsets: [UInt32] = []
    ) {
        pointer.dynamicOffsets = manualPointer(dynamicOffsets) // This might not be necessary
        
        wgpuComputePassEncoderSetBindGroup(c, index, bindGroup.c, UInt32(dynamicOffsets.count), pointer.dynamicOffsets)
    }
    
    public func dispatchWorkground(x: UInt32 = 1, y: UInt32 = 1, z: UInt32 = 1) {
        wgpuComputePassEncoderDispatchWorkgroups(c, x, y, z)
    }
    
    public func end() { wgpuComputePassEncoderEnd(c) }
    
    deinit {
        pointer.dynamicOffsets?.deallocate()
    }
}
