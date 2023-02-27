public extension KZBuffer {
    // I wonder if we can make this function actually async for swift
    func map(mode: KZMapMode = .none, offset: Int = 0, size: Int = 0) {
        wgpuBufferMapAsync(c, mode.rawValue as WGPUMapModeFlags, offset, size, {_,_ in }, nil)
    }

    func getMappedRange<T>(offset: Int = 0, size: Int = 0, capacity: Int = 1) -> UnsafeMutablePointer<T>? {
        let rawResult = wgpuBufferGetMappedRange(c, offset, size)
        let castedResult = rawResult?.bindMemory(to: T.self, capacity: capacity)

        return castedResult
    }
}

public typealias KZVertexBufferLayout = WGPUVertexBufferLayout
extension KZVertexBufferLayout {}
