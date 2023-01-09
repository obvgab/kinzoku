public class KZQueue {
    public var c: WGPUQueue
    
    init(_ c: WGPUQueue) {
        self.c = c
    }
    
    public func writeBuffer(
        buffer: KZBuffer,
        offset: UInt64 = 0,
        data: UnsafeMutableRawPointer,
        size: Int = 0
    ) {
        wgpuQueueWriteBuffer(c, buffer.c, offset, data, size)
    }
    
    public func submit(
        count: UInt32 = 0,
        buffer: KZCommandBuffer
    ) {
        wgpuQueueSubmit(c, count, &buffer.c)
    }
}
