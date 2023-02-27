public enum KZAdapterType: UInt32 {
    case discreteGPU = 0x00000000
    case integratedGPU = 0x00000001
    case cPU = 0x00000002
    case unknown = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUAdapterType {
        return WGPUAdapterType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUAdapterType) {
         self = KZAdapterType(rawValue: cRepr.rawValue)!
    }
}
public enum KZAddressMode: UInt32 {
    case `repeat` = 0x00000000
    case mirrorRepeat = 0x00000001
    case clampToEdge = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUAddressMode {
        return WGPUAddressMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUAddressMode) {
         self = KZAddressMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZBackendType: UInt32 {
    case null = 0x00000000
    case webGPU = 0x00000001
    case d3D11 = 0x00000002
    case d3D12 = 0x00000003
    case metal = 0x00000004
    case vulkan = 0x00000005
    case openGL = 0x00000006
    case openGLES = 0x00000007
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBackendType {
        return WGPUBackendType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBackendType) {
         self = KZBackendType(rawValue: cRepr.rawValue)!
    }
}
public enum KZBlendFactor: UInt32 {
    case zero = 0x00000000
    case one = 0x00000001
    case src = 0x00000002
    case oneMinusSource = 0x00000003
    case srcAlpha = 0x00000004
    case oneMinusSourceAlpha = 0x00000005
    case dst = 0x00000006
    case oneMinusDestination = 0x00000007
    case dstAlpha = 0x00000008
    case oneMinusDestinationAlpha = 0x00000009
    case srcAlphaSaturated = 0x0000000A
    case constant = 0x0000000B
    case oneMinusConstant = 0x0000000C
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBlendFactor {
        return WGPUBlendFactor(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBlendFactor) {
         self = KZBlendFactor(rawValue: cRepr.rawValue)!
    }
}
public enum KZBlendOperation: UInt32 {
    case add = 0x00000000
    case subtract = 0x00000001
    case reverseSubtract = 0x00000002
    case min = 0x00000003
    case max = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBlendOperation {
        return WGPUBlendOperation(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBlendOperation) {
         self = KZBlendOperation(rawValue: cRepr.rawValue)!
    }
}
public enum KZBufferBindingType: UInt32 {
    case undefined = 0x00000000
    case uniform = 0x00000001
    case storage = 0x00000002
    case readOnlyStorage = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBufferBindingType {
        return WGPUBufferBindingType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBufferBindingType) {
         self = KZBufferBindingType(rawValue: cRepr.rawValue)!
    }
}
public enum KZBufferMapAsyncStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case deviceLost = 0x00000003
    case destroyedBeforeCallback = 0x00000004
    case unmappedBeforeCallback = 0x00000005
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBufferMapAsyncStatus {
        return WGPUBufferMapAsyncStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBufferMapAsyncStatus) {
         self = KZBufferMapAsyncStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZCompareFunction: UInt32 {
    case undefined = 0x00000000
    case never = 0x00000001
    case less = 0x00000002
    case lessEqual = 0x00000003
    case greater = 0x00000004
    case greaterEqual = 0x00000005
    case equal = 0x00000006
    case notEqual = 0x00000007
    case always = 0x00000008
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUCompareFunction {
        return WGPUCompareFunction(rawValue: rawValue)
    }

    init(_ cRepr: WGPUCompareFunction) {
         self = KZCompareFunction(rawValue: cRepr.rawValue)!
    }
}
public enum KZCompilationInfoRequestStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case deviceLost = 0x00000002
    case unknown = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUCompilationInfoRequestStatus {
        return WGPUCompilationInfoRequestStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPUCompilationInfoRequestStatus) {
         self = KZCompilationInfoRequestStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZCompilationMessageType: UInt32 {
    case error = 0x00000000
    case warning = 0x00000001
    case info = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUCompilationMessageType {
        return WGPUCompilationMessageType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUCompilationMessageType) {
         self = KZCompilationMessageType(rawValue: cRepr.rawValue)!
    }
}
public enum KZComputePassTimestampLocation: UInt32 {
    case beginning = 0x00000000
    case end = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUComputePassTimestampLocation {
        return WGPUComputePassTimestampLocation(rawValue: rawValue)
    }

    init(_ cRepr: WGPUComputePassTimestampLocation) {
         self = KZComputePassTimestampLocation(rawValue: cRepr.rawValue)!
    }
}
public enum KZCreatePipelineAsyncStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case deviceLost = 0x00000002
    case deviceDestroyed = 0x00000003
    case unknown = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUCreatePipelineAsyncStatus {
        return WGPUCreatePipelineAsyncStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPUCreatePipelineAsyncStatus) {
         self = KZCreatePipelineAsyncStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZCullMode: UInt32 {
    case none = 0x00000000
    case front = 0x00000001
    case back = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUCullMode {
        return WGPUCullMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUCullMode) {
         self = KZCullMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZDeviceLostReason: UInt32 {
    case undefined = 0x00000000
    case destroyed = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUDeviceLostReason {
        return WGPUDeviceLostReason(rawValue: rawValue)
    }

    init(_ cRepr: WGPUDeviceLostReason) {
         self = KZDeviceLostReason(rawValue: cRepr.rawValue)!
    }
}
public enum KZErrorFilter: UInt32 {
    case validation = 0x00000000
    case outOfMemory = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUErrorFilter {
        return WGPUErrorFilter(rawValue: rawValue)
    }

    init(_ cRepr: WGPUErrorFilter) {
         self = KZErrorFilter(rawValue: cRepr.rawValue)!
    }
}
public enum KZErrorType: UInt32 {
    case noError = 0x00000000
    case validation = 0x00000001
    case outOfMemory = 0x00000002
    case unknown = 0x00000003
    case deviceLost = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUErrorType {
        return WGPUErrorType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUErrorType) {
         self = KZErrorType(rawValue: cRepr.rawValue)!
    }
}
public enum KZFeatureName: UInt32 {
    case undefined = 0x00000000
    case depthClipControl = 0x00000001
    case depth24UnormStencil8 = 0x00000002
    case depth32FloatStencil8 = 0x00000003
    case timestampQuery = 0x00000004
    case pipelineStatisticsQuery = 0x00000005
    case textureCompressionBC = 0x00000006
    case textureCompressionETC2 = 0x00000007
    case textureCompressionASTC = 0x00000008
    case indirectFirstInstance = 0x00000009
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUFeatureName {
        return WGPUFeatureName(rawValue: rawValue)
    }

    init(_ cRepr: WGPUFeatureName) {
         self = KZFeatureName(rawValue: cRepr.rawValue)!
    }
}
public enum KZFilterMode: UInt32 {
    case nearest = 0x00000000
    case linear = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUFilterMode {
        return WGPUFilterMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUFilterMode) {
         self = KZFilterMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZFrontFace: UInt32 {
    case cCW = 0x00000000
    case cW = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUFrontFace {
        return WGPUFrontFace(rawValue: rawValue)
    }

    init(_ cRepr: WGPUFrontFace) {
         self = KZFrontFace(rawValue: cRepr.rawValue)!
    }
}
public enum KZIndexFormat: UInt32 {
    case undefined = 0x00000000
    case uint16 = 0x00000001
    case uint32 = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUIndexFormat {
        return WGPUIndexFormat(rawValue: rawValue)
    }

    init(_ cRepr: WGPUIndexFormat) {
         self = KZIndexFormat(rawValue: cRepr.rawValue)!
    }
}
public enum KZLoadOp: UInt32 {
    case undefined = 0x00000000
    case clear = 0x00000001
    case load = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPULoadOp {
        return WGPULoadOp(rawValue: rawValue)
    }

    init(_ cRepr: WGPULoadOp) {
         self = KZLoadOp(rawValue: cRepr.rawValue)!
    }
}
public enum KZMipmapFilterMode: UInt32 {
    case nearest = 0x00000000
    case linear = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUMipmapFilterMode {
        return WGPUMipmapFilterMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUMipmapFilterMode) {
         self = KZMipmapFilterMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZPipelineStatisticName: UInt32 {
    case vertexShaderInvocations = 0x00000000
    case clipperInvocations = 0x00000001
    case clipperPrimitivesOut = 0x00000002
    case fragmentShaderInvocations = 0x00000003
    case computeShaderInvocations = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUPipelineStatisticName {
        return WGPUPipelineStatisticName(rawValue: rawValue)
    }

    init(_ cRepr: WGPUPipelineStatisticName) {
         self = KZPipelineStatisticName(rawValue: cRepr.rawValue)!
    }
}
public enum KZPowerPreference: UInt32 {
    case undefined = 0x00000000
    case lowPower = 0x00000001
    case highPerformance = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUPowerPreference {
        return WGPUPowerPreference(rawValue: rawValue)
    }

    init(_ cRepr: WGPUPowerPreference) {
         self = KZPowerPreference(rawValue: cRepr.rawValue)!
    }
}
public enum KZPredefinedColorSpace: UInt32 {
    case undefined = 0x00000000
    case srgb = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUPredefinedColorSpace {
        return WGPUPredefinedColorSpace(rawValue: rawValue)
    }

    init(_ cRepr: WGPUPredefinedColorSpace) {
         self = KZPredefinedColorSpace(rawValue: cRepr.rawValue)!
    }
}
public enum KZPresentMode: UInt32 {
    case immediate = 0x00000000
    case mailbox = 0x00000001
    case fifo = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUPresentMode {
        return WGPUPresentMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUPresentMode) {
         self = KZPresentMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZPrimitiveTopology: UInt32 {
    case pointList = 0x00000000
    case lineList = 0x00000001
    case lineStrip = 0x00000002
    case triangleList = 0x00000003
    case triangleStrip = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUPrimitiveTopology {
        return WGPUPrimitiveTopology(rawValue: rawValue)
    }

    init(_ cRepr: WGPUPrimitiveTopology) {
         self = KZPrimitiveTopology(rawValue: cRepr.rawValue)!
    }
}
public enum KZQueryType: UInt32 {
    case occlusion = 0x00000000
    case pipelineStatistics = 0x00000001
    case timestamp = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUQueryType {
        return WGPUQueryType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUQueryType) {
         self = KZQueryType(rawValue: cRepr.rawValue)!
    }
}
public enum KZQueueWorkDoneStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case deviceLost = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUQueueWorkDoneStatus {
        return WGPUQueueWorkDoneStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPUQueueWorkDoneStatus) {
         self = KZQueueWorkDoneStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZRenderPassTimestampLocation: UInt32 {
    case beginning = 0x00000000
    case end = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPURenderPassTimestampLocation {
        return WGPURenderPassTimestampLocation(rawValue: rawValue)
    }

    init(_ cRepr: WGPURenderPassTimestampLocation) {
         self = KZRenderPassTimestampLocation(rawValue: cRepr.rawValue)!
    }
}
public enum KZRequestAdapterStatus: UInt32 {
    case success = 0x00000000
    case unavailable = 0x00000001
    case error = 0x00000002
    case unknown = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPURequestAdapterStatus {
        return WGPURequestAdapterStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPURequestAdapterStatus) {
         self = KZRequestAdapterStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZRequestDeviceStatus: UInt32 {
    case success = 0x00000000
    case error = 0x00000001
    case unknown = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPURequestDeviceStatus {
        return WGPURequestDeviceStatus(rawValue: rawValue)
    }

    init(_ cRepr: WGPURequestDeviceStatus) {
         self = KZRequestDeviceStatus(rawValue: cRepr.rawValue)!
    }
}
public enum KZSType: UInt32 {
    case invalid = 0x00000000
    case surfaceDescriptorFromMetalLayer = 0x00000001
    case surfaceDescriptorFromWindowsHWND = 0x00000002
    case surfaceDescriptorFromXlibWindow = 0x00000003
    case surfaceDescriptorFromCanvasHTMLSelector = 0x00000004
    case shaderModuleSPIRVDescriptor = 0x00000005
    case shaderModuleWGSLDescriptor = 0x00000006
    case primitiveDepthClipControl = 0x00000007
    case surfaceDescriptorFromWaylandSurface = 0x00000008
    case surfaceDescriptorFromAndroidNativeWindow = 0x00000009
    case surfaceDescriptorFromXcbWindow = 0x0000000A
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUSType {
        return WGPUSType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUSType) {
         self = KZSType(rawValue: cRepr.rawValue)!
    }
}
public enum KZSamplerBindingType: UInt32 {
    case undefined = 0x00000000
    case filtering = 0x00000001
    case nonFiltering = 0x00000002
    case comparison = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUSamplerBindingType {
        return WGPUSamplerBindingType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUSamplerBindingType) {
         self = KZSamplerBindingType(rawValue: cRepr.rawValue)!
    }
}
public enum KZStencilOperation: UInt32 {
    case keep = 0x00000000
    case zero = 0x00000001
    case replace = 0x00000002
    case invert = 0x00000003
    case incrementClamp = 0x00000004
    case decrementClamp = 0x00000005
    case incrementWrap = 0x00000006
    case decrementWrap = 0x00000007
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUStencilOperation {
        return WGPUStencilOperation(rawValue: rawValue)
    }

    init(_ cRepr: WGPUStencilOperation) {
         self = KZStencilOperation(rawValue: cRepr.rawValue)!
    }
}
public enum KZStorageTextureAccess: UInt32 {
    case undefined = 0x00000000
    case writeOnly = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUStorageTextureAccess {
        return WGPUStorageTextureAccess(rawValue: rawValue)
    }

    init(_ cRepr: WGPUStorageTextureAccess) {
         self = KZStorageTextureAccess(rawValue: cRepr.rawValue)!
    }
}
public enum KZStoreOp: UInt32 {
    case undefined = 0x00000000
    case store = 0x00000001
    case discard = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUStoreOp {
        return WGPUStoreOp(rawValue: rawValue)
    }

    init(_ cRepr: WGPUStoreOp) {
         self = KZStoreOp(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureAspect: UInt32 {
    case all = 0x00000000
    case stencilOnly = 0x00000001
    case depthOnly = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureAspect {
        return WGPUTextureAspect(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureAspect) {
         self = KZTextureAspect(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureComponentType: UInt32 {
    case float = 0x00000000
    case sint = 0x00000001
    case uint = 0x00000002
    case depthComparison = 0x00000003
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureComponentType {
        return WGPUTextureComponentType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureComponentType) {
         self = KZTextureComponentType(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureDimension: UInt32 {
    case _1D = 0x00000000
    case _2D = 0x00000001
    case _3D = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureDimension {
        return WGPUTextureDimension(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureDimension) {
         self = KZTextureDimension(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureFormat: UInt32 {
    case undefined = 0x00000000
    case r8Unorm = 0x00000001
    case r8Snorm = 0x00000002
    case r8Uint = 0x00000003
    case r8Sint = 0x00000004
    case r16Uint = 0x00000005
    case r16Sint = 0x00000006
    case r16Float = 0x00000007
    case rG8Unorm = 0x00000008
    case rG8Snorm = 0x00000009
    case rG8Uint = 0x0000000A
    case rG8Sint = 0x0000000B
    case r32Float = 0x0000000C
    case r32Uint = 0x0000000D
    case r32Sint = 0x0000000E
    case rG16Uint = 0x0000000F
    case rG16Sint = 0x00000010
    case rG16Float = 0x00000011
    case rGBA8Unorm = 0x00000012
    case rGBA8UnormSrgb = 0x00000013
    case rGBA8Snorm = 0x00000014
    case rGBA8Uint = 0x00000015
    case rGBA8Sint = 0x00000016
    case bGRA8Unorm = 0x00000017
    case bGRA8UnormSrgb = 0x00000018
    case rGB10A2Unorm = 0x00000019
    case rG11B10Ufloat = 0x0000001A
    case rGB9E5Ufloat = 0x0000001B
    case rG32Float = 0x0000001C
    case rG32Uint = 0x0000001D
    case rG32Sint = 0x0000001E
    case rGBA16Uint = 0x0000001F
    case rGBA16Sint = 0x00000020
    case rGBA16Float = 0x00000021
    case rGBA32Float = 0x00000022
    case rGBA32Uint = 0x00000023
    case rGBA32Sint = 0x00000024
    case stencil8 = 0x00000025
    case depth16Unorm = 0x00000026
    case depth24Plus = 0x00000027
    case depth24PlusStencil8 = 0x00000028
    case depth24UnormStencil8 = 0x00000029
    case depth32Float = 0x0000002A
    case depth32FloatStencil8 = 0x0000002B
    case bC1RGBAUnorm = 0x0000002C
    case bC1RGBAUnormSrgb = 0x0000002D
    case bC2RGBAUnorm = 0x0000002E
    case bC2RGBAUnormSrgb = 0x0000002F
    case bC3RGBAUnorm = 0x00000030
    case bC3RGBAUnormSrgb = 0x00000031
    case bC4RUnorm = 0x00000032
    case bC4RSnorm = 0x00000033
    case bC5RGUnorm = 0x00000034
    case bC5RGSnorm = 0x00000035
    case bC6HRGBUfloat = 0x00000036
    case bC6HRGBFloat = 0x00000037
    case bC7RGBAUnorm = 0x00000038
    case bC7RGBAUnormSrgb = 0x00000039
    case eTC2RGB8Unorm = 0x0000003A
    case eTC2RGB8UnormSrgb = 0x0000003B
    case eTC2RGB8A1Unorm = 0x0000003C
    case eTC2RGB8A1UnormSrgb = 0x0000003D
    case eTC2RGBA8Unorm = 0x0000003E
    case eTC2RGBA8UnormSrgb = 0x0000003F
    case eACR11Unorm = 0x00000040
    case eACR11Snorm = 0x00000041
    case eACRG11Unorm = 0x00000042
    case eACRG11Snorm = 0x00000043
    case aSTC4x4Unorm = 0x00000044
    case aSTC4x4UnormSrgb = 0x00000045
    case aSTC5x4Unorm = 0x00000046
    case aSTC5x4UnormSrgb = 0x00000047
    case aSTC5x5Unorm = 0x00000048
    case aSTC5x5UnormSrgb = 0x00000049
    case aSTC6x5Unorm = 0x0000004A
    case aSTC6x5UnormSrgb = 0x0000004B
    case aSTC6x6Unorm = 0x0000004C
    case aSTC6x6UnormSrgb = 0x0000004D
    case aSTC8x5Unorm = 0x0000004E
    case aSTC8x5UnormSrgb = 0x0000004F
    case aSTC8x6Unorm = 0x00000050
    case aSTC8x6UnormSrgb = 0x00000051
    case aSTC8x8Unorm = 0x00000052
    case aSTC8x8UnormSrgb = 0x00000053
    case aSTC10x5Unorm = 0x00000054
    case aSTC10x5UnormSrgb = 0x00000055
    case aSTC10x6Unorm = 0x00000056
    case aSTC10x6UnormSrgb = 0x00000057
    case aSTC10x8Unorm = 0x00000058
    case aSTC10x8UnormSrgb = 0x00000059
    case aSTC10x10Unorm = 0x0000005A
    case aSTC10x10UnormSrgb = 0x0000005B
    case aSTC12x10Unorm = 0x0000005C
    case aSTC12x10UnormSrgb = 0x0000005D
    case aSTC12x12Unorm = 0x0000005E
    case aSTC12x12UnormSrgb = 0x0000005F
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureFormat {
        return WGPUTextureFormat(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureFormat) {
         self = KZTextureFormat(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureSampleType: UInt32 {
    case undefined = 0x00000000
    case float = 0x00000001
    case unfilterableFloat = 0x00000002
    case depth = 0x00000003
    case sint = 0x00000004
    case uint = 0x00000005
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureSampleType {
        return WGPUTextureSampleType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureSampleType) {
         self = KZTextureSampleType(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureViewDimension: UInt32 {
    case undefined = 0x00000000
    case _1D = 0x00000001
    case _2D = 0x00000002
    case _2DArray = 0x00000003
    case cube = 0x00000004
    case cubeArray = 0x00000005
    case _3D = 0x00000006
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureViewDimension {
        return WGPUTextureViewDimension(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureViewDimension) {
         self = KZTextureViewDimension(rawValue: cRepr.rawValue)!
    }
}
public enum KZVertexFormat: UInt32 {
    case undefined = 0x00000000
    case uint8x2 = 0x00000001
    case uint8x4 = 0x00000002
    case sint8x2 = 0x00000003
    case sint8x4 = 0x00000004
    case unorm8x2 = 0x00000005
    case unorm8x4 = 0x00000006
    case snorm8x2 = 0x00000007
    case snorm8x4 = 0x00000008
    case uint16x2 = 0x00000009
    case uint16x4 = 0x0000000A
    case sint16x2 = 0x0000000B
    case sint16x4 = 0x0000000C
    case unorm16x2 = 0x0000000D
    case unorm16x4 = 0x0000000E
    case snorm16x2 = 0x0000000F
    case snorm16x4 = 0x00000010
    case float16x2 = 0x00000011
    case float16x4 = 0x00000012
    case float32 = 0x00000013
    case float32x2 = 0x00000014
    case float32x3 = 0x00000015
    case float32x4 = 0x00000016
    case uint32 = 0x00000017
    case uint32x2 = 0x00000018
    case uint32x3 = 0x00000019
    case uint32x4 = 0x0000001A
    case sint32 = 0x0000001B
    case sint32x2 = 0x0000001C
    case sint32x3 = 0x0000001D
    case sint32x4 = 0x0000001E
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUVertexFormat {
        return WGPUVertexFormat(rawValue: rawValue)
    }

    init(_ cRepr: WGPUVertexFormat) {
         self = KZVertexFormat(rawValue: cRepr.rawValue)!
    }
}
public enum KZVertexStepMode: UInt32 {
    case vertex = 0x00000000
    case instance = 0x00000001
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUVertexStepMode {
        return WGPUVertexStepMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUVertexStepMode) {
         self = KZVertexStepMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZBufferUsage: UInt32 {
    case none = 0x00000000
    case mapRead = 0x00000001
    case mapWrite = 0x00000002
    case copySource = 0x00000004
    case copyDestination = 0x00000008
    case index = 0x00000010
    case vertex = 0x00000020
    case uniform = 0x00000040
    case storage = 0x00000080
    case indirect = 0x00000100
    case queryResolve = 0x00000200
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUBufferUsage {
        return WGPUBufferUsage(rawValue: rawValue)
    }

    init(_ cRepr: WGPUBufferUsage) {
         self = KZBufferUsage(rawValue: cRepr.rawValue)!
    }
}
public enum KZColorWriteMask: UInt32 {
    case none = 0x00000000
    case red = 0x00000001
    case green = 0x00000002
    case blue = 0x00000004
    case alpha = 0x00000008
    case all = 0x0000000F
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUColorWriteMask {
        return WGPUColorWriteMask(rawValue: rawValue)
    }

    init(_ cRepr: WGPUColorWriteMask) {
         self = KZColorWriteMask(rawValue: cRepr.rawValue)!
    }
}
public enum KZMapMode: UInt32 {
    case none = 0x00000000
    case read = 0x00000001
    case write = 0x00000002
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUMapMode {
        return WGPUMapMode(rawValue: rawValue)
    }

    init(_ cRepr: WGPUMapMode) {
         self = KZMapMode(rawValue: cRepr.rawValue)!
    }
}
public enum KZShaderStage: UInt32 {
    case none = 0x00000000
    case vertex = 0x00000001
    case fragment = 0x00000002
    case compute = 0x00000004
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUShaderStage {
        return WGPUShaderStage(rawValue: rawValue)
    }

    init(_ cRepr: WGPUShaderStage) {
         self = KZShaderStage(rawValue: cRepr.rawValue)!
    }
}
public enum KZTextureUsage: UInt32 {
    case none = 0x00000000
    case copySource = 0x00000001
    case copyDestination = 0x00000002
    case textureBinding = 0x00000004
    case storageBinding = 0x00000008
    case renderAttachment = 0x00000010
    case force32 = 0x7FFFFFFF

    var cRepr: WGPUTextureUsage {
        return WGPUTextureUsage(rawValue: rawValue)
    }

    init(_ cRepr: WGPUTextureUsage) {
         self = KZTextureUsage(rawValue: cRepr.rawValue)!
    }
}
public enum KZNativeSType: UInt32 {
    case extras = 0x60000001
    case rExtras = 0x60000002
    case edLimitsExtras = 0x60000003
    case neLayoutExtras = 0x60000004
    case moduleGLSLDescriptor = 0x60000005
    case ceExtras = 0x60000006
    case force32 = 0x7FFFFFFF

    var tedLimitsExtras: KZNativeSType {
        return .edLimitsExtras
    }

    var cRepr: WGPUNativeSType {
        return WGPUNativeSType(rawValue: rawValue)
    }

    init(_ cRepr: WGPUNativeSType) {
         self = KZNativeSType(rawValue: cRepr.rawValue)!
    }
}
public enum KZNativeFeature: UInt32 {
    case pUSH_CONSTANTS = 0x60000001
    case tEXTURE_ADAPTER_SPECIFIC_FORMAT_FEATURES = 0x60000002
    case mULTI_DRAW_INDIRECT = 0x60000003
    case mULTI_DRAW_INDIRECT_COUNT = 0x60000004
    case vERTEX_WRITABLE_STORAGE = 0x60000005

    var cRepr: WGPUNativeFeature {
        return WGPUNativeFeature(rawValue: rawValue)
    }

    init(_ cRepr: WGPUNativeFeature) {
         self = KZNativeFeature(rawValue: cRepr.rawValue)!
    }
}
public enum KZLogLevel: UInt32 {
    case off = 0x00000000
    case error = 0x00000001
    case warn = 0x00000002
    case info = 0x00000003
    case debug = 0x00000004
    case trace = 0x00000005
    case force32 = 0x7FFFFFFF

    var cRepr: WGPULogLevel {
        return WGPULogLevel(rawValue: rawValue)
    }

    init(_ cRepr: WGPULogLevel) {
         self = KZLogLevel(rawValue: cRepr.rawValue)!
    }
}
public final class KZBuffer {
    var c: WGPUBuffer

    init(_ c: WGPUBuffer) {
        self.c = c
    }

    public func destroy() -> Void {
        return wgpuBufferDestroy(c)
    }

    public func getConstMappedRange<T>(offset: Int, size: Int) -> UnsafeMutablePointer<T>? {
        let result = wgpuBufferGetConstMappedRange(c, offset, size)
        return result?.bindMemory(to: T.self, capacity: 1)
    }

    public func getMappedRange<T>(offset: Int, size: Int) -> UnsafeMutablePointer<T>? {
        let result = wgpuBufferGetMappedRange(c, offset, size)
        return result?.bindMemory(to: T.self, capacity: 1)
    }

    public func mapAsync(mode: WGPUMapModeFlags, offset: Int, size: Int, callback: WGPUBufferMapCallback, userdata: UnsafeMutableRawPointer?) -> Void {
        return wgpuBufferMapAsync(c, mode, offset, size, callback, userdata)
    }

    public func setLabel(label: UnsafeMutablePointer<CChar>?) -> Void {
        return wgpuBufferSetLabel(c, label)
    }

    public func unmap() -> Void {
        return wgpuBufferUnmap(c)
    }

    public func drop() -> Void {
        return wgpuBufferDrop(c)
    }
}