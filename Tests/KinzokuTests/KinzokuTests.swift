import XCTest
import Wgpu
@testable import Kinzoku

final class KinzokuTests: XCTestCase {
    func testCompute() throws { // Proper tests! PLEASE! This is just a placeholder so I can actually run code
        var instance = KZInstance()
        var adapter = instance.requestAdapter(callback: { status, adapter, message, userdata in
            XCTAssertEqual(status, .success, "Adapter should have been retrieved successfully at this stage")
        })
        var limits = adapter?.getLimits()
        XCTAssertEqual(limits?.required, false, "Limit is given as WGPUSupportedLimit, should always be false")
        var properties = adapter?.getProperties()
        XCTAssertEqual(properties?.backend, .metal, "Testing on M1 Max, only available backend is Metal")
        var req_limits = WGPURequiredLimits(nextInChain: nil, limits: (limits?.c_supported?.limits)!)
        limits?.c_required = req_limits
        limits?.required = true
        XCTAssertNotNil(limits, "Value should be guranteed by now")
        var unwrapped_limits = limits!
        var device = adapter?.requestDevice(limits: &unwrapped_limits, callback: { status, device, message, userdata in
            XCTAssertEqual(status, .success, "Device should have been retrieved successfully at this stage")
        })
    }
}
