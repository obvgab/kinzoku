// This file is automatically generated from wgpu's C headers. Do not
// edit this file directly. Edit the corresponding generator instead.


public final class KZBuffer {
    var c: WGPUBuffer

    init(_ c: WGPUBuffer) {
        self.c = c
    }

    public func destroy() -> Void {
        return wgpuBufferDestroy(c)
    }

    public func getConstMappedRange<T>(offset: Int, size: Int) -> UnsafeMutablePointer<T>? {
        let result = wgpuBufferGetConstMappedRange(c, offset, size)
        return result?.bindMemory(to: T.self, capacity: 1)
    }

    public func getMappedRange<T>(offset: Int, size: Int) -> UnsafeMutablePointer<T>? {
        let result = wgpuBufferGetMappedRange(c, offset, size)
        return result?.bindMemory(to: T.self, capacity: 1)
    }

    public func mapAsync(mode: WGPUMapModeFlags, offset: Int, size: Int, callback: WGPUBufferMapCallback, userdata: UnsafeMutableRawPointer?) -> Void {
        return wgpuBufferMapAsync(c, mode, offset, size, callback, userdata)
    }

    public func setLabel(label: UnsafeMutablePointer<CChar>?) -> Void {
        return wgpuBufferSetLabel(c, label)
    }

    public func unmap() -> Void {
        return wgpuBufferUnmap(c)
    }

    deinit {
        return wgpuBufferDrop(c)
    }
}

public final class KZCommandBuffer {
    var c: WGPUCommandBuffer

    init(_ c: WGPUCommandBuffer) {
        self.c = c
    }

    public func setLabel(label: UnsafeMutablePointer<CChar>?) -> Void {
        return wgpuCommandBufferSetLabel(c, label)
    }
}