public typealias KZVertexState = WGPUVertexState
public extension KZVertexState {
    init(
        chain: UnsafePointer<WGPUChainedStruct>? = nil,
        module: KZShaderModule,
        entry: String,
        constants: [KZConstant] = [],
        buffers: [KZVertexBufferLayout] = []
    ) {
        let entryPointer = strdup(entry); let constantPointer = manualPointer(constants); let bufferPointer = manualPointer(buffers)
        defer { free(entryPointer); constantPointer.deallocate(); bufferPointer.deallocate(); } // This probably doesn't work, freeing right after init

        self = WGPUVertexState(
            nextInChain: chain,
            module: module.c,
            entryPoint: entryPointer,
            constantCount: UInt32(constants.count),
            constants: constantPointer,
            bufferCount: UInt32(buffers.count),
            buffers: bufferPointer
        )
    }
}

public typealias KZConstant = WGPUConstantEntry
extension KZConstant {
    
}
