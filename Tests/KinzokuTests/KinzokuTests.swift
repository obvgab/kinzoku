import XCTest
import Wgpu
@testable import Kinzoku

final class KinzokuTests: XCTestCase {
    // This is slowly going to reflect wgpu-native's actual compute test
    // https://github.com/gfx-rs/wgpu-native/blob/master/examples/compute/main.c
    @available(macOS 13.0, *)
    func testCompute() throws {
        let numbers: [UInt32] = [1, 2, 3, 4]
        let numbersSize = MemoryLayout.size(ofValue: numbers)
        
        let instance = KZInstance()
        
        let (adapter, adapterStatus, _) = instance.requestAdapter()
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        XCTAssertNotNil(adapter.c, "Adapter was received, but is nil")
        
        let limits = getReq() // We should switch this to Swift native later
        
        let (device, queue, deviceStatus, _) = adapter.requestDevice(label: "Device", limits: limits.limits)
        XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")
        
        let source = try! KZShaderSource(fromWGSL: URL(filePath: Bundle.module.path(forResource: "compute", ofType: "wgsl")!))
        XCTAssertNotNil(String(cString: source.c.label), "Label of ShaderSource should be the path, not nil")

        let module = device.createShaderModule(source: source)
        XCTAssertNotNil(module.c, "Module was received, but is nil")
        
        let stagingBuffer = device.createBuffer(label: "StagingBuffer", usage: [.mapRead, .copyDestination], size: UInt64(numbersSize))
        XCTAssertNotNil(stagingBuffer.c, "StagingBuffer was received, but is nil")
        let storageBuffer = device.createBuffer(label: "StorageBuffer", usage: [.storage, .copyDestination, .copySource], size: UInt64(numbersSize))
        XCTAssertNotNil(storageBuffer.c, "StorageBuffer was received, but is nil")
    }
}
