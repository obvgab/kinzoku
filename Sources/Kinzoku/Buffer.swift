public extension KZBuffer {
    // I wonder if we can make this function actually async for swift
    func map(mode: KZMapMode = .none, offset: Int = 0, size: Int = 0) {
        wgpuBufferMapAsync(c, mode.rawValue as WGPUMapModeFlags, offset, size, {_,_ in }, nil)
    }
}

public typealias KZVertexBufferLayout = WGPUVertexBufferLayout
extension KZVertexBufferLayout {}
