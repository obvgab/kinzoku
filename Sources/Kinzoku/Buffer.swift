import Wgpu

public class KZBuffer {
    public var c: WGPUBuffer
    
    init(_ c: WGPUBuffer) {
        self.c = c
    }
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
