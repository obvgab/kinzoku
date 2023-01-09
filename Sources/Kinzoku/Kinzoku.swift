import Foundation
import WgpuHeaders

// MARK: - Utility Functions

func manualPointer<T>(_ data: T) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    dataPointer.initialize(to: data)
    
    return dataPointer
}

func manualPointer<T>(_ data: [T]) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: data.count)
    dataPointer.initialize(from: data, count: data.count)
    
    return dataPointer
}

#if os(Linux)
func strdup(_ data: String) -> UnsafeMutablePointer<CChar> {
    let deconstructed = data.cString(using: .utf8)
    
    return manualPointer(deconstructed ?? [])
}
#endif

// MARK: - Library Loading
// Sourced from SourceKitten's dlopen and dlsym method
 
private class Loader {
    fileprivate let handle: UnsafeMutableRawPointer
    
    init() {
        #if os(macOS)
            #if arch(arm64) // Darwin Aarch64
                let path = Bundle.module.path(forResource: "aarch64", ofType: ".dylib")
            #else // Darwin x86_64
                let path = Bundle.module.path(forResource: "x86_64", ofType: ".dylib")
            #endif
        #else
            #if arch(arm64) // Linux Aarch64
                let path = Bundle.module.path(forResource: "aarch64", ofType: ".so")
            #else // Linux x86_64
                let path = Bundle.module.path(forResource: "x86_64", ofType: ".so")
            #endif
        #endif
        
        if let handle = dlopen(path, RTLD_LAZY) {
            self.handle = handle
            return
        }
        
        fatalError("Loading \(path ?? "MISSING") did not resolve library")
    }
    
    func load<T>(_ symbol: String) -> T {
        if let selector = dlsym(handle, symbol) {
            return unsafeBitCast(selector, to: T.self)
        }
        
        fatalError("Symbol for \(symbol) failed: \(String(validatingUTF8: dlerror()) ?? "UNKNOWN")")
    }
}

// MARK: - Selectors for WGPU methods

private let loader = Loader()

internal let wgpuCreateInstance: @convention(c) (UnsafePointer<WGPUInstanceDescriptor>?) -> (WGPUInstance) = loader.load("wgpuCreateInstance")

// Methods of Adapter
internal let wgpuAdapterEnumerateFeatures: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUFeatureName>?) -> Int = loader.load("wgpuAdapterEnumerateFeatures")
internal let wgpuAdapterGetLimits: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUSupportedLimits>?) -> Bool = loader.load("wgpuAdapterGetLimits")
internal let wgpuAdapterGetProperties: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUAdapterProperties>?) -> Void = loader.load("wgpuAdapterGetProperties")
internal let wgpuAdapterHasFeature: @convention(c) (WGPUAdapter, WGPUFeatureName) -> Bool = loader.load("wgpuAdapterHasFeature")
internal let wgpuAdapterRequestDevice: @convention(c) (WGPUAdapter, UnsafePointer<WGPUDeviceDescriptor>?, WGPURequestDeviceCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuAdapterRequestDevice")

// Methods of Buffer
// destroy
// const mapped
internal let wgpuBufferGetMappedRange: @convention(c) (WGPUBuffer, Int, Int) -> UnsafeMutableRawPointer? = loader.load("wgpuBufferGetMappedRange")
internal let wgpuBufferMapAsync: @convention(c) (WGPUBuffer, WGPUMapModeFlags, Int, Int, WGPUBufferMapCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuBufferMapAsync")
// set label
internal let wgpuBufferUnmap: @convention(c) (WGPUBuffer) -> Void = loader.load("wgpuBufferUnmap")

// Methods of CommandEncoder
internal let wgpuCommandEncoderBeginComputePass: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUComputePassDescriptor>?) -> WGPUComputePassEncoder = loader.load("wgpuCommandEncoderBeginComputePass")
// render pass
// clear buffer
internal let wgpuCommandEncoderCopyBufferToBuffer: @convention(c) (WGPUCommandEncoder, WGPUBuffer, UInt64, WGPUBuffer, UInt64, UInt64) -> Void = loader.load("wgpuCommandEncoderCopyBufferToBuffer")
// buffer to texture
// texture to buffer
// texture to texture
internal let wgpuCommandEncoderFinish: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUCommandBufferDescriptor>?) -> WGPUCommandBuffer = loader.load("wgpuCommandEncoderFinish")
// debug marker
// debug pop
// debug push
// query resolve
// set label
// write timestamp

// Methods of ComputePassEncoder
// begin pipeline
internal let wgpuComputePassEncoderDispatchWorkgroups: @convention(c) (WGPUComputePassEncoder, UInt32, UInt32, UInt32) -> Void = loader.load("wgpuComputePassEncoderDispatchWorkgroups")
// workgroups indirect
internal let wgpuComputePassEncoderEnd: @convention(c) (WGPUComputePassEncoder) -> Void = loader.load("wgpuComputePassEncoderEnd")
// end pipeline
// debug marker
// debug pop
// debug push
internal let wgpuComputePassEncoderSetBindGroup: @convention(c) (WGPUComputePassEncoder, UInt32, WGPUBindGroup, UInt32, UnsafePointer<UInt32>?) -> Void = loader.load("wgpuComputePassEncoderSetBindGroup")
// set label
internal let wgpuComputePassEncoderSetPipeline: @convention(c) (WGPUComputePassEncoder, WGPUComputePipeline) -> Void = loader.load("wgpuComputePassEncoderSetPipeline")

// Methods of ComputePipeline
internal let wgpuComputePipelineGetBindGroupLayout: @convention(c) (WGPUComputePipeline, UInt32) -> WGPUBindGroupLayout = loader.load("wgpuComputePipelineGetBindGroupLayout")
// set label

// Methods of Device
internal let wgpuDeviceCreateBindGroup: @convention(c) (WGPUDevice, UnsafePointer<WGPUBindGroupDescriptor>?) -> WGPUBindGroup = loader.load("wgpuDeviceCreateBindGroup")
// bind layout
internal let wgpuDeviceCreateBuffer: @convention(c) (WGPUDevice, UnsafePointer<WGPUBufferDescriptor>?) -> WGPUBuffer = loader.load("wgpuDeviceCreateBuffer")
internal let wgpuDeviceCreateCommandEncoder: @convention(c) (WGPUDevice, UnsafePointer<WGPUCommandEncoderDescriptor>?) -> WGPUCommandEncoder = loader.load("wgpuDeviceCreateCommandEncoder")
internal let wgpuDeviceCreateComputePipeline: @convention(c) (WGPUDevice, UnsafePointer<WGPUComputePipelineDescriptor>?) -> WGPUComputePipeline = loader.load("wgpuDeviceCreateComputePipeline")
// compute async
// pipeline layout
// query set
// render bundle
// render pipeline
// render async
// sampler
internal let wgpuDeviceCreateShaderModule: @convention(c) (WGPUDevice, UnsafePointer<WGPUShaderModuleDescriptor>?) -> WGPUShaderModule = loader.load("wgpuDeviceCreateShaderModule")
// swap chain
// texture
// destroy
// enumerate features
// limits
internal let wgpuDeviceGetQueue: @convention(c) (WGPUDevice) -> WGPUQueue = loader.load("wgpuDeviceGetQueue")
// has feature
// pop error
// push error
// lost callback
// set label
// error callback
internal let wgpuDevicePoll: @convention(c) (WGPUDevice, Bool, UnsafePointer<WGPUWrappedSubmissionIndex>?) -> Bool = loader.load("wgpuDevicePoll")

// Methods of Instance
internal let wgpuInstanceCreateSurface: @convention(c) (WGPUInstance, UnsafePointer<WGPUSurfaceDescriptor>?) -> WGPUSurface = loader.load("wgpuInstanceCreateSurface")
// process events
internal let wgpuInstanceRequestAdapter: @convention(c) (WGPUInstance, UnsafePointer<WGPURequestAdapterOptions>?, WGPURequestAdapterCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuInstanceRequestAdapter")

// Methods of Queue
// on submitted
// set label
internal let wgpuQueueSubmit: @convention(c) (WGPUQueue, UInt32, UnsafePointer<WGPUCommandBuffer>?) -> Void = loader.load("wgpuQueueSubmit")
internal let wgpuQueueWriteBuffer: @convention(c) (WGPUQueue, WGPUBuffer, UInt64, UnsafeRawPointer?, Int) -> Void = loader.load("wgpuQueueWriteBuffer")
// write texture

// Methods of Surface
internal let wgpuSurfaceGetPreferredFormat: @convention(c) (WGPUSurface, WGPUAdapter) -> WGPUTextureFormat = loader.load("wgpuGetPreferredFormat")
