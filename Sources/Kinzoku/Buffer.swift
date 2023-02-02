public class KZBuffer {
    public var c: WGPUBuffer
    
    init(_ c: WGPUBuffer) {
        self.c = c
    }
    
    // I wonder if we can make this function actually async for swift
    public func map(mode: KZMapMode = .none, offset: Int = 0, size: Int = 0) { wgpuBufferMapAsync(c, mode.rawValue as WGPUMapModeFlags, offset, size, {_,_ in }, nil) }
    public func unmap() { wgpuBufferUnmap(c) }
    public func getMappedRange<T>(offset: Int = 0, size: Int = 0, capacity: Int = 1) -> UnsafeMutablePointer<T>? { // PLEASE IMPROVE THIS, MUCH TO MANUAL
        let rawResult = wgpuBufferGetMappedRange(c, offset, size)
        let castedResult = rawResult?.bindMemory(to: T.self, capacity: capacity)
        
        return castedResult
    }
}

public typealias KZVertexBufferLayout = WGPUVertexBufferLayout
extension KZVertexBufferLayout {
    
}

public enum KZBufferUsage: UInt32 {
    case none = 0x00000000
    case mapRead = 0x00000001
    case mapWrite = 0x00000002
    case copySource = 0x00000004
    case copyDestination = 0x00000008
    case index = 0x00000010
    case vertex = 0x00000020
    case uniform = 0x00000040
    case storage = 0x00000080
    case indirect = 0x00000100
    case queryResolve = 0x00000200
    case force32 = 0x7FFFFFFF
}

public enum KZMapMode: UInt32 {
    case none = 0x00000000
    case read = 0x00000001
    case write = 0x00000002
    case force32 = 0x7FFFFFFF
}
