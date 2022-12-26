import Wgpu

public class KZSurface {
    public var c: WGPUSurface?
    
    public init(
        _ surface: WGPUSurface?
    ) {
        self.c = surface
    }
    
    public func getPreferredFormat(
        adapter: KZAdapter
    ) -> KZTextureFormat {
        return KZTextureFormat(rawValue: wgpuSurfaceGetPreferredFormat(c, adapter.c).rawValue) ?? .undefined
    }
}

public enum KZTextureFormat: UInt32 { // (u)nsigned & (s)igned
    case undefined = 0x00000000
    case r8Unorm = 0x00000001
    case r8Snorm = 0x00000002
    case r8Uint = 0x00000003
    case r8Sint = 0x00000004
    case r16Uint = 0x00000005
    case r16Sint = 0x00000006
    case r16Float = 0x00000007
    case rg8Unorm = 0x00000008
    case rg8Snorm = 0x00000009
    case rg8Uint = 0x0000000A
    case rg8Sint = 0x0000000B
    case r32Float = 0x0000000C
    case r32Uint = 0x0000000D
    case r32Sint = 0x0000000E
    case rg16Uint = 0x0000000F
    case rg16Sint = 0x00000010
    case rg16Float = 0x00000011
    case rgbA8Unorm = 0x00000012
    case rgbA8UnormSrgb = 0x00000013
    case rgbA8Snorm = 0x00000014
    case rgbA8Uint = 0x00000015
    case rgbA8Sint = 0x00000016
    case bgra8Unorm = 0x00000017
    case bgra8UnormSrgb = 0x00000018
    case rgb10A2Unorm = 0x00000019
    case rg11B10Ufloat = 0x0000001A
    case rgb9E5Ufloat = 0x0000001B
    case rg32Float = 0x0000001C
    case rg32Uint = 0x0000001D
    case rg32Sint = 0x0000001E
    case rgbA16Uint = 0x0000001F
    case rgbA16Sint = 0x00000020
    case rgbA16Float = 0x00000021
    case rgbA32Float = 0x00000022
    case rgbA32Uint = 0x00000023
    case rgbA32Sint = 0x00000024
    case stencil8 = 0x00000025
    case depth16Unorm = 0x00000026
    case depth24Plus = 0x00000027
    case depth24PlusStencil8 = 0x00000028
    case depth24UnormStencil8 = 0x00000029
    case depth32Float = 0x0000002A
    case depth32FloatStencil8 = 0x0000002B
    case bc1rgbAUnorm = 0x0000002C
    case bc1rgbAUnormSrgb = 0x0000002D
    case bc2rgbAUnorm = 0x0000002E
    case bc2rgbAUnormSrgb = 0x0000002F
    case bc3rgbAUnorm = 0x00000030
    case bc3rgbAUnormSrgb = 0x00000031
    case bc4RUnorm = 0x00000032
    case bc4RSnorm = 0x00000033
    case bc5rgUnorm = 0x00000034
    case bc5rgSnorm = 0x00000035
    case bc6HrgbUfloat = 0x00000036
    case bc6HrgbFloat = 0x00000037
    case bc7rgbAUnorm = 0x00000038
    case bc7rgbAUnormSrgb = 0x00000039
    case etc2rgb8Unorm = 0x0000003A
    case etc2rgb8UnormSrgb = 0x0000003B
    case etc2rgb8A1Unorm = 0x0000003C
    case etc2rgb8A1UnormSrgb = 0x0000003D
    case etc2rgbA8Unorm = 0x0000003E
    case etc2rgbA8UnormSrgb = 0x0000003F
    case eacr11Unorm = 0x00000040
    case eacr11Snorm = 0x00000041
    case eacrg11Unorm = 0x00000042
    case eacrg11Snorm = 0x00000043
    case astc4x4Unorm = 0x00000044
    case astc4x4UnormSrgb = 0x00000045
    case astc5x4Unorm = 0x00000046
    case astc5x4UnormSrgb = 0x00000047
    case astc5x5Unorm = 0x00000048
    case astc5x5UnormSrgb = 0x00000049
    case astc6x5Unorm = 0x0000004A
    case astc6x5UnormSrgb = 0x0000004B
    case astc6x6Unorm = 0x0000004C
    case astc6x6UnormSrgb = 0x0000004D
    case astc8x5Unorm = 0x0000004E
    case astc8x5UnormSrgb = 0x0000004F
    case astc8x6Unorm = 0x00000050
    case astc8x6UnormSrgb = 0x00000051
    case astc8x8Unorm = 0x00000052
    case astc8x8UnormSrgb = 0x00000053
    case astc10x5Unorm = 0x00000054
    case astc10x5UnormSrgb = 0x00000055
    case astc10x6Unorm = 0x00000056
    case astc10x6UnormSrgb = 0x00000057
    case astc10x8Unorm = 0x00000058
    case astc10x8UnormSrgb = 0x00000059
    case astc10x10Unorm = 0x0000005A
    case astc10x10UnormSrgb = 0x0000005B
    case astc12x10Unorm = 0x0000005C
    case astc12x10UnormSrgb = 0x0000005D
    case astc12x12Unorm = 0x0000005E
    case astc12x12UnormSrgb = 0x0000005F
    case force32 = 0x7FFFFFFF
}
