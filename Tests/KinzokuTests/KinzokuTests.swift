import XCTest
import Wgpu
@testable import Kinzoku

final class KinzokuTests: XCTestCase {
    @available(macOS 13.0, *)
    func testCompute() throws { // Proper tests! PLEASE! This is just a placeholder so I can actually run code
        let instance = KZInstance()
        
        let (adapter, adapterStatus, _) = instance.requestAdapter()
        XCTAssertEqual(adapterStatus, .success, "Adapter was not properly received")
        
        var limits = adapter.getLimits()
        let (device, queue, deviceStatus, _) = adapter.requestDevice(limits: &limits)
        XCTAssertEqual(deviceStatus, .success, "Device was not properly received")
        XCTAssertNotNil(device.c, "Device was received, but is nil")
        XCTAssertNotNil(queue.c, "Queue was received, but is nil")
        
        let _ = adapter.getProperties()
        
        var source = try! KZShaderSource(fromWGSL: URL(filePath: Bundle.module.path(forResource: "compute", ofType: "wgsl")!))
        XCTAssertNotNil(String(cString: source.c.label), "Label of ShaderSource should be the path, not nil")
        print(String(cString: source.c.label))
        print("Huh?")
    }
}
