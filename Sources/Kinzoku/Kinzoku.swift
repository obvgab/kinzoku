// High-Level API from W3's Standards

/// Contains a parseable description that provides necessary or
/// supplemental information about a  object.
protocol KZDescribable { associatedtype Descriptor }
/// Inherets a label for identification.
protocol KZLabeled { var label: String { get } }

/// Effectively the Graphics Processing Unit object, used for providing an adapter
/// to the client for creating graphical contexts. The entroy point for Kinzoku.
protocol KZInstance {
    /// Associated Adapter for the given platform. This should changed
    /// based on the operating system being compiled.
    associatedtype Adapter: KZAdapter
    /// Request an adapter from the  for creating graphical contexts.
    func requestAdapter(_ options: Adapter.Descriptor?) async -> Adapter
}

protocol KZAdapter: KZDescribable {
    associatedtype Device: KZDevice
    func requestDevice(_ descriptor: Device.Descriptor?) async -> Device
}

protocol KZDevice: KZLabeled, KZDescribable {
    associatedtype Queue: KZQueue
    var queue: Queue { get }
    
    associatedtype ShaderModule: KZDescribable
    associatedtype RenderPipeline: KZDescribable
    func createShaderModule(_ descriptor: ShaderModule.Descriptor) -> ShaderModule
    func createRenderPipeline(_ descriptor: RenderPipeline.Descriptor) -> RenderPipeline
    func createRenderPipeline(_ descriptor: RenderPipeline.Descriptor) async -> RenderPipeline
    
    associatedtype CommandEncoder: KZCommandEncoder
    func createCommandEncoder(_ descriptor: CommandEncoder.Descriptor?) -> CommandEncoder
}

protocol KZCommandEncoder: KZDescribable {
    associatedtype RenderPassEncoder: KZRenderPassEncoder
    func beginRenderPass(_ descriptor: RenderPassEncoder.Descriptor) -> RenderPassEncoder
    
    associatedtype CommandBuffer: KZCommandBuffer
    func finish(_ descriptor: CommandBuffer.Descriptor?) -> CommandBuffer
}

protocol KZRenderPassEncoder: KZRenderCommandsMixin, KZDescribable {
    func end()
}

protocol KZRenderCommandsMixin {
    associatedtype RenderPipeline: KZDescribable
    func setPipeline(_ pipeline: RenderPipeline)
    
    func draw(_ vertices: UInt32, _ instances: UInt32, _ firstVertex: UInt32, _ firstInstance: UInt32)
}

protocol KZCommandBuffer: KZLabeled, KZDescribable {}

protocol KZQueue {
    associatedtype CommandBuffer: KZCommandBuffer
    func submit(_ commandBuffers: [CommandBuffer]) // We can associated type this if we want to force KZCommandEncoder to be linked
}
