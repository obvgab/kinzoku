public class KZSurface {
    public var c: WGPUSurface

    public init(
        _ surface: WGPUSurface
    ) {
        self.c = surface
    }

    public func getPreferredFormat(
        adapter: KZAdapter
    ) -> KZTextureFormat {
        return KZTextureFormat(rawValue: wgpuSurfaceGetPreferredFormat(c, adapter.c).rawValue) ?? .undefined
    }
}
