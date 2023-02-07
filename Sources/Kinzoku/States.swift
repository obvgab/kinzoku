public class KZVertexState {
    var c: WGPUVertexState
    
    init(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        module: KZShaderModule,
        entry: String,
        constants: [KZConstant] = [],
        buffers: [KZVertexBufferLayout] = []
    ) {
        c = WGPUVertexState(
            nextInChain: chain,
            module: module.c,
            entryPoint: strdup(entry),
            constantCount: UInt32(constants.count),
            constants: getCopiedPointer(constants),
            bufferCount: UInt32(buffers.count),
            buffers: getCopiedPointer(buffers)
        )
    }
    
    deinit {
        c.entryPoint.deallocate()
        c.constants.deallocate()
        c.buffers.deallocate()
    }
}

public typealias KZConstant = WGPUConstantEntry
extension KZConstant {
    
}
