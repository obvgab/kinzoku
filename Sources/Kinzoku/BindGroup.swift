import Wgpu

public struct KZBindGroup { var c: WGPUBindGroup }
public struct KZBindGroupLayout { var c: WGPUBindGroupLayout }

public struct KZBindGroupLayoutEntry {
    var nextInChain: UnsafePointer<WGPUChainedStruct>? = nil // TODO: ChainedStruct Pointer
    
}
