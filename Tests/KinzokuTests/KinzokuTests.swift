import XCTest
@testable import Kinzoku

final class KinzokuTests: XCTestCase {
    // https://github.com/gfx-rs/wgpu-native/blob/master/examples/compute/main.c
    func testCompute() throws {
        let numbersBase: [UInt32] = [1, 2, 3, 4]
        let numbers = manualPointer(numbersBase)
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
        
        stagingBuffer.map(mode: .read, size: numbersSize)
        device.poll(wait: true)
        
        let times: UnsafeMutablePointer<UInt32> = stagingBuffer.getMappedRange(offset: 0, size: numbersSize)!
        print("Times: \(times.pointee), \(times.advanced(by: 1).pointee), \(times.advanced(by: 2).pointee), \(times.advanced(by: 3).pointee)")
        XCTAssertEqual([times.pointee, times.advanced(by: 1).pointee, times.advanced(by: 2).pointee, times.advanced(by: 3).pointee], [0, 1, 7 ,2], "Compute incorrectly calculated")
        
        stagingBuffer.unmap()
    }
    
    // https://github.com/gfx-rs/wgpu-native/blob/master/examples/triangle/main.c
    func testTriangle() throws {
        let instance = KZInstance()
        
        // surface
        
        let (adapter, adapterStatus, _) = instance.requestAdapter()
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        XCTAssertNotNil(adapter.c, "Adapter was received, but is nil")
        
        let limits = KZLimits() // Does this become default/undefined equivalent?
        
        let (device, queue, deviceStatus, _) = adapter.requestDevice(label: "Device", limits: limits)
        XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")
        
        // Callbacks should be here, but we might want to rethink those
        
        let _ = try! KZShaderSource(fromWGSL: URL(fileURLWithPath: Bundle.module.path(forResource: "triangle", ofType: "wgsl")!))
    }
}
