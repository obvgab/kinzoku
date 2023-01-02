import XCTest
import Wgpu
@testable import Kinzoku

final class KinzokuTests: XCTestCase {
    @available(macOS 13.0, *)
    func testCompute() throws { // Proper tests! PLEASE! This is just a placeholder so I can actually run code
        let instance = KZInstance()
        
        let (adapter, adapterStatus, adapterMessage) = instance.requestAdapter()
        print("Adapter '\(adapterMessage)' - \(adapterStatus) : \(adapter.c)\n")
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        
        let limits = getReq()
        print(limits)
        
        let (device, queue, deviceStatus, deviceMessage) = adapter.requestDevice(label: "Device", limits: limits.limits)
        print("Device '\(deviceMessage)' - \(deviceStatus) : \(device.c)\n")
        //XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")
        
        let properties = adapter.getProperties()
        print(properties)
        
        let source = try! KZShaderSource(fromWGSL: URL(filePath: Bundle.module.path(forResource: "compute", ofType: "wgsl")!))
        print(source.c)
        XCTAssertNotNil(String(cString: source.c.label), "Label of ShaderSource should be the path, not nil")

        let module = device.createShaderModule(source: source)
        XCTAssertNotNil(module.c, "Module was received, but is nil")
    }
}
