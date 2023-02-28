import XCTest
@testable import Kinzoku

import GLFW

@MainActor
final class KinzokuTests: XCTestCase {
    // https://github.com/gfx-rs/wgpu-native/blob/master/examples/compute/main.c
    func testCompute() throws {
        let numbersBase: [UInt32] = [1, 2, 3, 4]
        let numbers = getCopiedPointer(numbersBase)
        let numbersSize = MemoryLayout<UInt32>.stride * numbersBase.count

        let instance = KZInstance()

        let (adapter, adapterStatus, _) = instance.requestAdapter()
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        XCTAssertNotNil(adapter.c, "Adapter was received, but is nil")

        var limits = KZLimits()
        limits.maxBindGroups = 1

        let (device, queue, deviceStatus, _) = adapter.requestDevice(label: "Device", limits: limits)
        XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")

        let source = try! KZShaderSource(fromWGSL: URL(fileURLWithPath: Bundle.module.path(forResource: "compute", ofType: "wgsl")!))
        XCTAssertNotNil(String(cString: source.c.label), "Label of ShaderSource should be the path, not nil")

        let module = device.createShaderModule(source: source)
        XCTAssertNotNil(module.c, "Module was received, but is nil")

        let stagingBuffer = device.createBuffer(label: "StagingBuffer", usage: [.mapRead, .copyDestination], size: UInt64(numbersSize))
        XCTAssertNotNil(stagingBuffer.c, "StagingBuffer was received, but is nil")
        let storageBuffer = device.createBuffer(label: "StorageBuffer", usage: [.storage, .copyDestination, .copySource], size: UInt64(numbersSize))
        XCTAssertNotNil(storageBuffer.c, "StorageBuffer was received, but is nil")

        let computePipeline = device.createComputePipeline(label: "Compute Pipeline", module: module, entry: "main")
        XCTAssertNotNil(computePipeline.c, "ComputePipeline was received, but is nil")
        let bindGroupLayout = computePipeline.getBindGroupLayout(index: 0)
        XCTAssertNotNil(bindGroupLayout.c, "BindGroupLayout of index 0 was received, but is nil")

        let bindGroup = device.createBindGroup(label: "Bind Group", layout: bindGroupLayout, entries: [KZBindGroupEntry(size: UInt64(numbersSize), buffer: storageBuffer)])
        XCTAssertNotNil(bindGroup.c, "BindGroup was received, but is nil")
        let commandEncoder = device.createCommandEncoder(label: "Command Encoder")
        XCTAssertNotNil(commandEncoder.c, "CommandEncoder was received, but is nil")
        let computePass = commandEncoder.beginComputePass(label: "Compute Pass")
        XCTAssertNotNil(computePass.c, "ComputePass was received, but is nil")

        computePass.setPipeline(pipeline: computePipeline)
        computePass.setBindGroup(bindGroup: bindGroup)
        computePass.dispatchWorkground(x: UInt32(numbersBase.count))
        computePass.end()

        commandEncoder.copyBufferToBuffer(source: storageBuffer, destination: stagingBuffer, size: UInt64(numbersSize))

        let commandBuffer = commandEncoder.finish()
        queue.writeBuffer(buffer: storageBuffer, data: numbers, size: numbersSize)
        queue.submit(count: 1, buffer: commandBuffer)

        stagingBuffer.mapAsync(mode: .read, size: numbersSize)
        device.poll(wait: true)

        let times: UnsafeMutablePointer<UInt32> = stagingBuffer.getMappedRange(offset: 0, size: numbersSize)!
        print("Times: \(times.pointee), \(times.advanced(by: 1).pointee), \(times.advanced(by: 2).pointee), \(times.advanced(by: 3).pointee)")
        XCTAssertEqual([times.pointee, times.advanced(by: 1).pointee, times.advanced(by: 2).pointee, times.advanced(by: 3).pointee], [0, 1, 7 ,2], "Compute incorrectly calculated")

        stagingBuffer.unmap()
    }

    // https://github.com/gfx-rs/wgpu-native/blob/master/examples/triangle/main.c
    func testTriangle() throws {
        let width = 1200
        let height = 700

        try GLFWSession.initialize()

        guard let window = try? GLFWWindow(width: width, height: height, title: "Triangle") else {
            GLFWSession.terminate()
            return
        }

        let nsWindow = window.nsWindow!
        nsWindow.contentView?.wantsLayer = true
        nsWindow.contentView?.layer = CAMetalLayer()
        nsWindow.makeKeyAndOrderFront(nsWindow)

        let instance = KZInstance()
        let surface = instance.createSurface(metalLayer: nsWindow.contentView!.layer! as! CAMetalLayer)

        let (adapter, adapterStatus, _) = instance.requestAdapter()
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        XCTAssertNotNil(adapter.c, "Adapter was received, but is nil")

        let limits = KZLimits() // Does this become default/undefined equivalent?

        let (device, queue, deviceStatus, _) = adapter.requestDevice(label: "Device", limits: limits)
        XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")

        // Callbacks should be here, but we might want to rethink those

        let source = try! KZShaderSource(fromWGSL: URL(fileURLWithPath: Bundle.module.path(forResource: "triangle", ofType: "wgsl")!))
        XCTAssertNotNil(String(cString: source.c.label), "Label of ShaderSource should be the path, not nil")

        let module = device.createShaderModule(source: source)
        XCTAssertNotNil(module.c, "Module was received, but is nil")

        let swapChainFormat = surface.getPreferredFormat(adapter: adapter)

        var blendState = WGPUBlendState(
            color: WGPUBlendComponent(
                operation: WGPUBlendOperation_Add,
                srcFactor: WGPUBlendFactor_One,
                dstFactor: WGPUBlendFactor_Zero
            ),
            alpha: WGPUBlendComponent(
                operation: WGPUBlendOperation_Add,
                srcFactor: WGPUBlendFactor_One,
                dstFactor: WGPUBlendFactor_Zero
            )
        )

        withUnsafePointer(to: &blendState) { blendStatePointer in
            var targetState = WGPUColorTargetState(
                nextInChain: nil,
                format: WGPUTextureFormat(rawValue: swapChainFormat.rawValue),
                blend: blendStatePointer,
                writeMask: WGPUColorWriteMask_All.rawValue
            )

            withUnsafePointer(to: &targetState) { targetStatePointer in
                var fragmentState = WGPUFragmentState(
                    nextInChain: nil,
                    module: module.c,
                    entryPoint: strdup("fs_main"),
                    constantCount: 0,
                    constants: nil,
                    targetCount: 1,
                    targets: targetStatePointer
                )

                withUnsafePointer(to: &fragmentState) { fragmentStatePointer in
                    var pipelineDescriptor = WGPURenderPipelineDescriptor(
                        nextInChain: nil,
                        label: strdup("Render pipeline"),
                        layout: nil,
                        vertex: WGPUVertexState(
                            nextInChain: nil,
                            module: module.c,
                            entryPoint: strdup("vs_main"),
                            constantCount: 0,
                            constants: nil,
                            bufferCount: 0,
                            buffers: nil
                        ),
                        primitive: WGPUPrimitiveState(
                            nextInChain: nil,
                            topology: WGPUPrimitiveTopology_TriangleList,
                            stripIndexFormat: WGPUIndexFormat_Undefined,
                            frontFace: WGPUFrontFace_CCW,
                            cullMode: WGPUCullMode_None
                        ),
                        depthStencil: nil,
                        multisample: WGPUMultisampleState(
                            nextInChain: nil,
                            count: 1,
                            mask: ~0,
                            alphaToCoverageEnabled: false
                        ),
                        fragment: fragmentStatePointer
                    )

                    let pipeline = wgpuDeviceCreateRenderPipeline(
                        device.c,
                        &pipelineDescriptor
                    )

                    var config = WGPUSwapChainDescriptor(
                        nextInChain: nil,
                        label: nil,
                        usage: WGPUTextureUsage_RenderAttachment.rawValue,
                        format: WGPUTextureFormat(rawValue: swapChainFormat.rawValue),
                        width: UInt32(width),
                        height: UInt32(height),
                        presentMode: WGPUPresentMode_Fifo
                    )

                    let swapChain = wgpuDeviceCreateSwapChain(device.c, surface.c, &config)

                    while !window.shouldClose {
                        var nextTexture: WGPUTextureView?
                        for attempt in 0..<2 {
                            nextTexture = wgpuSwapChainGetCurrentTextureView(swapChain)

                            if attempt == 0 && nextTexture == nil {
                                print("wgpuSwapChainGetCurrentTextureView() failed; trying to create a new swap chain...")
                                continue
                            }

                            break
                        }

                        guard let nextTexture = nextTexture else {
                            print("Cannot acquire next swap chain texture\n")
                            return
                        }

                        var encoderDescriptor = WGPUCommandEncoderDescriptor(nextInChain: nil, label: strdup("Command encoder"))
                        let encoder = wgpuDeviceCreateCommandEncoder(device.c, &encoderDescriptor)

                        var colorAttachment = WGPURenderPassColorAttachment(
                            view: nextTexture,
                            resolveTarget: nil,
                            loadOp: WGPULoadOp_Clear,
                            storeOp: WGPUStoreOp_Store,
                            clearValue: WGPUColor(r: 0, g: 1, b: 0, a: 1)
                        )

                        withUnsafePointer(to: &colorAttachment) { colorAttachmentPointer in
                            var renderPassDescriptor = WGPURenderPassDescriptor(
                                nextInChain: nil,
                                label: nil,
                                colorAttachmentCount: 1,
                                colorAttachments: colorAttachmentPointer,
                                depthStencilAttachment: nil,
                                occlusionQuerySet: nil,
                                timestampWriteCount: 0,
                                timestampWrites: nil
                            )
                            let renderPass = wgpuCommandEncoderBeginRenderPass(encoder, &renderPassDescriptor)

                            wgpuRenderPassEncoderSetPipeline(renderPass, pipeline)
                            wgpuRenderPassEncoderDraw(renderPass, 3, 1, 0, 0)
                            wgpuRenderPassEncoderEnd(renderPass)
                            wgpuTextureViewDrop(nextTexture)

                            let queue = wgpuDeviceGetQueue(device.c)

                            var cmdBufferDescriptor = WGPUCommandBufferDescriptor(nextInChain: nil, label: nil)
                            var cmdBuffer = wgpuCommandEncoderFinish(encoder, &cmdBufferDescriptor)

                            wgpuQueueSubmit(queue, 1, &cmdBuffer)
                            wgpuSwapChainPresent(swapChain)
                        }

                        GLFWSession.pollEvents()
                    }

                    GLFWSession.terminate()
                }
            }
        }
    }
}
