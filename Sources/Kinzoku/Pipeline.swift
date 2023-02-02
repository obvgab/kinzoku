public struct KZComputePipeline {
    public var c: WGPUComputePipeline
    
    public func getBindGroupLayout(index: UInt32) -> KZBindGroupLayout {
        return KZBindGroupLayout(c: wgpuComputePipelineGetBindGroupLayout(c, index))
    }
}

public struct KZRenderPipeline {
    public var c: WGPURenderPipeline
}

public struct KZPipelineLayout { public var c: WGPUPipelineLayout }
