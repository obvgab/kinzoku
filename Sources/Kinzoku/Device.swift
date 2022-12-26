import Wgpu

public struct KZDevice {
    public var c: WGPUDevice? = nil
}

public enum KZDeviceRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF
}
