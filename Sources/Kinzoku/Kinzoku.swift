@_exported import WgpuHeaders
#if os(Linux)
@_exported import Glibc
#endif
@_exported import Foundation

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

internal let wgpuCreateInstance: @convention(c) (UnsafePointer<WGPUInstanceDescriptor>?) -> WGPUInstance = loader.load("wgpuCreateInstance")
internal let wgpuGetProcAddress: @convention(c) (WGPUDevice, UnsafePointer<CChar>?) -> WGPUProc = loader.load("wgpuGetProcAddress")

// Methods of Adapter
internal let wgpuAdapterEnumerateFeatures: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUFeatureName>?) -> Int = loader.load("wgpuAdapterEnumerateFeatures")
internal let wgpuAdapterGetLimits: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUSupportedLimits>?) -> Bool = loader.load("wgpuAdapterGetLimits")
internal let wgpuAdapterGetProperties: @convention(c) (WGPUAdapter, UnsafeMutablePointer<WGPUAdapterProperties>?) -> Void = loader.load("wgpuAdapterGetProperties")
internal let wgpuAdapterHasFeature: @convention(c) (WGPUAdapter, WGPUFeatureName) -> Bool = loader.load("wgpuAdapterHasFeature")
internal let wgpuAdapterRequestDevice: @convention(c) (WGPUAdapter, UnsafePointer<WGPUDeviceDescriptor>?, WGPURequestDeviceCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuAdapterRequestDevice")

// Methods of BindGroup
internal let wgpuBindGroupSetLabel: @convention(c) (WGPUBindGroup, UnsafePointer<CChar>?) -> Void = loader.load("wgpuBindGroupSetLabel")

// Methods of BindGroupLayout
internal let wgpuBindGroupLayoutSetLabel: @convention(c) (WGPUBindGroupLayout, UnsafePointer<CChar>?) -> Void = loader.load("wgpuBindGroupLayoutSetLabel")

// Methods of Buffer
internal let wgpuBufferDestroy: @convention(c) (WGPUBuffer) -> Void = loader.load("wgpuBufferDestroy")
internal let wgpuBufferGetConstMappedRange: @convention(c) (WGPUBuffer, Int, Int) -> UnsafeRawPointer? = loader.load("wgpuBufferGetConstMappedRange")
internal let wgpuBufferGetMappedRange: @convention(c) (WGPUBuffer, Int, Int) -> UnsafeMutableRawPointer? = loader.load("wgpuBufferGetMappedRange")
internal let wgpuBufferMapAsync: @convention(c) (WGPUBuffer, WGPUMapModeFlags, Int, Int, WGPUBufferMapCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuBufferMapAsync")
internal let wgpuBufferSetLabel: @convention(c) (WGPUBuffer, UnsafePointer<CChar>?) -> Void = loader.load("wgpuBufferSetLabel")
internal let wgpuBufferUnmap: @convention(c) (WGPUBuffer) -> Void = loader.load("wgpuBufferUnmap")

// Methods of CommandBuffer
internal let wgpuCommandBufferSetLabel: @convention(c) (WGPUCommandBuffer, UnsafePointer<CChar>?) -> Void = loader.load("wgpuCommandBufferSetLabel")

// Methods of CommandEncoder
internal let wgpuCommandEncoderBeginComputePass: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUComputePassDescriptor>?) -> WGPUComputePassEncoder = loader.load("wgpuCommandEncoderBeginComputePass")
internal let wgpuCommandEncoderBeginRenderPass: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPURenderPassDescriptor>?) -> WGPURenderPassEncoder = loader.load("wgpuCommandEncoderBeginRenderPass")
internal let wgpuCommandEncoderClearBuffer: @convention(c) (WGPUCommandEncoder, WGPUBuffer, UInt64, UInt64) -> Void = loader.load("wgpuCommandEncoderClearBuffer")
internal let wgpuCommandEncoderCopyBufferToBuffer: @convention(c) (WGPUCommandEncoder, WGPUBuffer, UInt64, WGPUBuffer, UInt64, UInt64) -> Void = loader.load("wgpuCommandEncoderCopyBufferToBuffer")
internal let wgpuCommandEncoderCopyBufferToTexture: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUImageCopyBuffer>?, UnsafePointer<WGPUImageCopyTexture>?, UnsafePointer<WGPUExtent3D>?) -> Void = loader.load("wgpuCommandEncoderCopyBufferToTexture")
internal let wgpuCommandEncoderCopyTextureToBuffer: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUImageCopyTexture>?, UnsafePointer<WGPUImageCopyBuffer>?, UnsafePointer<WGPUExtent3D>?) -> Void = loader.load("wgpuCommandEncoderCopyTextureToBuffer")
internal let wgpuCommandEncoderCopyTextureToTexture: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUImageCopyTexture>?, UnsafePointer<WGPUImageCopyTexture>?, UnsafePointer<WGPUExtent3D>?) -> Void = loader.load("wgpuCommandEncoderCopyTextureToTexture")
internal let wgpuCommandEncoderFinish: @convention(c) (WGPUCommandEncoder, UnsafePointer<WGPUCommandBufferDescriptor>?) -> WGPUCommandBuffer = loader.load("wgpuCommandEncoderFinish")
internal let wgpuCommandEncoderInsertDebugMarker: @convention(c) (WGPUCommandEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuCommandEncoderInsertDebugMarker")
internal let wgpuCommandEncoderPopDebugGroup: @convention(c) (WGPUCommandEncoder) -> Void = loader.load("wgpuCommandEncoderPopDebugGroup")
internal let wgpuCommandEncoderPushDebugGroup: @convention(c) (WGPUCommandEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuCommandEncoderPushDebugGroup")
internal let wgpuCommandEncoderResolveQuerySet: @convention(c) (WGPUCommandEncoder, WGPUQuerySet, UInt32, UInt32, WGPUBuffer, UInt64) -> Void = loader.load("wgpuCommandEncoderResolveQuerySet")
internal let wgpuCommandEncoderSetLabel: @convention(c) (WGPUCommandEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuCommandEncoderSetLabel")
internal let wgpuCommandEncoderWriteTimestamp: @convention(c) (WGPUCommandEncoder, WGPUQuerySet, UInt32) -> Void = loader.load("wgpuCommandEncoderWriteTimestamp")

// Methods of ComputePassEncoder
internal let wgpuComputePassEncoderBeginPipelineStatisticsQuery: @convention(c) (WGPUComputePassEncoder, WGPUQuerySet, UInt32) -> Void = loader.load("wgpuComputePassEncoderBeginPipelineStatisticsQuery")
internal let wgpuComputePassEncoderDispatchWorkgroups: @convention(c) (WGPUComputePassEncoder, UInt32, UInt32, UInt32) -> Void = loader.load("wgpuComputePassEncoderDispatchWorkgroups")
internal let wgpuComputePassEncoderDispatchWorkgroupsIndirect: @convention(c) (WGPUComputePassEncoder, UInt32, UInt32, UInt32) -> Void = loader.load("wgpuComputePassEncoderDispatchWorkgroupsIndirect")
internal let wgpuComputePassEncoderEnd: @convention(c) (WGPUComputePassEncoder) -> Void = loader.load("wgpuComputePassEncoderEnd")
internal let wgpuComputePassEncoderEndPipelineStatisticsQuery: @convention(c) (WGPUComputePassEncoder) -> Void = loader.load("wgpuComputePassEncoderEndPipelineStatisticsQuery")
internal let wgpuComputePassEncoderInsertDebugMarker: @convention(c) (WGPUComputePassEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuComputePassEncoderInsertDebugMarker")
internal let wgpuComputePassEncoderPopDebugGroup: @convention(c) (WGPUComputePassEncoder) -> Void = loader.load("wgpuComputePassEncoderPopDebugGroup")
internal let wgpuComputePassEncoderPushDebugGroup: @convention(c) (WGPUComputePassEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuComputePassEncoderPushDebugGroup")
internal let wgpuComputePassEncoderSetBindGroup: @convention(c) (WGPUComputePassEncoder, UInt32, WGPUBindGroup, UInt32, UnsafePointer<UInt32>?) -> Void = loader.load("wgpuComputePassEncoderSetBindGroup")
internal let wgpuComputePassEncoderSetLabel: @convention(c) (WGPUComputePassEncoder, UnsafePointer<CChar>?) -> Void = loader.load("wgpuComputePassEncoderSetLabel")
internal let wgpuComputePassEncoderSetPipeline: @convention(c) (WGPUComputePassEncoder, WGPUComputePipeline) -> Void = loader.load("wgpuComputePassEncoderSetPipeline")

// Methods of ComputePipeline
internal let wgpuComputePipelineGetBindGroupLayout: @convention(c) (WGPUComputePipeline, UInt32) -> WGPUBindGroupLayout = loader.load("wgpuComputePipelineGetBindGroupLayout")
internal let wgpuComputePipelineSetLabel: @convention(c) (WGPUComputePipeline, UnsafePointer<CChar>?) -> Void = loader.load("wgpuComputePipelineSetLabel")

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
internal let wgpuDeviceEnumerateFeatures: @convention(c) (WGPUDevice, UnsafeMutablePointer<WGPUFeatureName>?) -> Int = loader.load("wgpuDeviceEnumerateFeatures")
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
internal let wgpuInstanceProcessEvents: @convention(c) (WGPUInstance) -> Void = loader.load("wgpuInstanceProcessEvents")
internal let wgpuInstanceRequestAdapter: @convention(c) (WGPUInstance, UnsafePointer<WGPURequestAdapterOptions>?, WGPURequestAdapterCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuInstanceRequestAdapter")

// Methods of PipelineLayout
internal let wgpuPipelineLayoutSetLabel: @convention(c) (WGPUPipelineLayout, UnsafePointer<CChar>?) -> Void = loader.load("wgpuPipelineLayoutSetLabel")

// Methods of QuerySet
internal let wgpuQuerySetDestroy: @convention(c) (WGPUQuerySet) -> Void = loader.load("wgpuQuerySetDestroy")
internal let wgpuQuerySetSetLabel: @convention(c) (WGPUQuerySet, UnsafePointer<CChar>?) -> Void = loader.load("wgpuQuerySetSetLabel")

// Methods of Queue
internal let wgpuQueueOnSubmittedWorkDone: @convention(c) (WGPUQueue, WGPUQueueWorkDoneCallback, UnsafeMutableRawPointer?) -> Void = loader.load("wgpuQueueOnSubmittedWorkDone")
internal let wgpuQueueSetLabel: @convention(c) (WGPUQueue, UnsafePointer<CChar>?) -> Void = loader.load("wgpuQueueSetLabel")
internal let wgpuQueueSubmit: @convention(c) (WGPUQueue, UInt32, UnsafePointer<WGPUCommandBuffer>?) -> Void = loader.load("wgpuQueueSubmit")
internal let wgpuQueueWriteBuffer: @convention(c) (WGPUQueue, WGPUBuffer, UInt64, UnsafeRawPointer?, Int) -> Void = loader.load("wgpuQueueWriteBuffer")
internal let wgpuQueueWriteTexture: @convention(c) (WGPUQueue, UnsafePointer<WGPUImageCopyTexture>?, UnsafeRawPointer?, Int, UnsafePointer<WGPUTextureDataLayout>?, UnsafePointer<WGPUExtent3D>?) -> Void = loader.load("wgpuQueueWriteTexture")

// Methods of RenderBundleEncoder
// draw
// draw indexed
// draw indexed indirect
// draw indirect
// finish
// insert debug
// pop debug
// push debug
// bind group
// index buffer
// set label
// set pipeline
// vertex buffer

// Methods of RenderPassEncoder
// occlusion query
// pipeline query
// draw
// draw indexed
// draw indexed indirect
// draw indirect
// end
// end occlusion
// end pipeline
// execute bundles
// insert debug
// pop debug
// push debug
// bind group
// blend constant
// index buffer
// set label
// set pipeline
// scissor rect
// stencil reference
// vertex buffer
// set viewport

// Methods of RenderPipeline
// bind layout
// set label

// Methods of ShaderModule
// get info
internal let wgpuRenderPipelineSetLabel: @convention(c) (WGPUShaderModule, UnsafePointer<CChar>?) -> Void = loader.load("wgpuRenderPipelineSetLabel")

// Methods of Surface
internal let wgpuSurfaceGetPreferredFormat: @convention(c) (WGPUSurface, WGPUAdapter) -> WGPUTextureFormat = loader.load("wgpuGetPreferredFormat")

// Methods of SwapChain
// get current
internal let wgpuSwapChainPresent: @convention(c) (WGPUSwapChain) -> Void = loader.load("wgpuSwapChainPresent")

// Methods of Texture
// create view
internal let wgpuTextureDestroy: @convention(c) (WGPUTexture) -> Void = loader.load("wgpuTextureDestroy")
internal let wgpuTextureSetLabel: @convention(c) (WGPUTexture, UnsafePointer<CChar>?) -> Void = loader.load("wgpuTextureSetLabel")

// Methods of TextureView
internal let wgpuTextureViewSetLabel: @convention(c) (WGPUTextureView, UnsafePointer<CChar>?) -> Void = loader.load("wgpuTextureViewSetLabel")
