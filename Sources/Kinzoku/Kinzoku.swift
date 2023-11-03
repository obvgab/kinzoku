#if canImport(Metal)
import Metal
#else
import CVulkan
#endif

// Just makin some generics, seeing how we can structure this in Swift from W3's API docs

protocol Describable { associatedtype Descriptor }
protocol Configurable { associatedtype Options }

protocol GPU {
    // Switch OpaquePointer to AdapterOptions later
    associatedtype GPUAdapter: Adapter & Configurable
    func requestAdapter(_ options: GPUAdapter.Options?) async -> GPUAdapter
}
protocol GPUObjectBase {
    var label: String { get }
}

protocol Adapter {
    associatedtype GPUSupportedLimit
    associatedtype GPUSupportedFeatures
    var limits: GPUSupportedLimit { get }
    var features: GPUSupportedFeatures { get }
    
    var isFallback: Bool { get }
    
    associatedtype GPUDevice: Device & Describable
    associatedtype GPUAdapterInfo
    func requestDevice(_ descriptor: GPUDevice.Descriptor?) async -> GPUDevice
    func requestAdapterInfo() async -> GPUAdapterInfo
}

protocol Device: GPUObjectBase {
    associatedtype GPUSupportedLimit
    associatedtype GPUSupportedFeatures
    var limits: GPUSupportedLimit { get }
    var features: GPUSupportedFeatures { get }
    
    associatedtype GPUQueue
    var queue: GPUQueue { get }
    
    associatedtype GPUBuffer: Describable
    associatedtype GPUTexture: Describable
    associatedtype GPUSampler: Describable
    associatedtype GPUExternalTexture: Describable
    func createBuffer(_ descriptor: GPUBuffer.Descriptor) -> GPUBuffer
    func createTexture(_ descriptor: GPUTexture.Descriptor) -> GPUTexture
    func createSampler(_ descriptor: GPUSampler.Descriptor?) -> GPUSampler
    func importExternalTexture(_ descriptor: GPUExternalTexture.Descriptor) -> GPUExternalTexture
    
    associatedtype GPUBindGroup: Describable
    associatedtype GPUPipelineLayout: Describable
    associatedtype GPUBindGroupLayout: Describable
    func createBindGroup(_ descriptor: GPUBindGroup.Descriptor) -> GPUBindGroup
    func createPipelineLayout(_ descriptor: GPUPipelineLayout.Descriptor) -> GPUPipelineLayout
    func createBindGroupLayout(_ descriptor: GPUBindGroupLayout.Descriptor) -> GPUBindGroupLayout
    
    associatedtype GPUShaderModule: Describable
    associatedtype GPUComputePipeline: Describable
    associatedtype GPURenderPipeline: Describable
    func createShaderModule(_ descriptor: GPUShaderModule.Descriptor) -> GPUShaderModule
    func createComputePipeline(_ descriptor: GPUComputePipeline.Descriptor) -> GPUComputePipeline
    func createRenderPipeline(_ descriptor: GPURenderPipeline.Descriptor) -> GPURenderPipeline
    func createComputePipeline(_ descriptor: GPUComputePipeline.Descriptor) async -> GPUComputePipeline
    func createRenderPipeline(_ descriptor: GPURenderPipeline.Descriptor) async -> GPURenderPipeline
    
    associatedtype GPUCommandEncoder: Describable
    associatedtype GPURenderBundleEncoder: Describable
    func createCommandEncoder(_ descriptor: GPUCommandEncoder.Descriptor?) -> GPUCommandEncoder
    func createRenderBundleEncoder(_ descriptor: GPURenderBundleEncoder.Descriptor) -> GPURenderBundleEncoder
    
    associatedtype GPUQuerySet: Describable
    func createQuerySet(_ descriptor: GPUQuerySet.Descriptor) -> GPUQuerySet
}

protocol Buffer: GPUObjectBase {
    var size: UInt64 { get }
    var usage: [GPUFlags] { get }
    
    var mapState: BufferMapState { get }
    
    associatedtype ArrayBuffer // Not sure yet what this should be
    func map(mode: [MapModeFlags], offset: UInt64?, size: UInt64?) async
    func getMappedRange(offset: UInt64?, size: UInt64?) -> ArrayBuffer
    func unmap()
}

enum BufferMapState {
    case unmapped
    case pending
    case mapped
}
enum MapModeFlags {
    case read
    case write
}
enum GPUFlags {
    case mapRead
    case mapWrite
    case copySource
    case copyDestination
    case index
    case vertex
    case uniform
    case storage
    case indirect
    case queryResolve
}
