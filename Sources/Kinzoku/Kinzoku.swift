@_exported import WgpuHeaders
#if os(Linux)
@_exported import Glibc
#endif
@_exported import Foundation

// MARK: - Utility Functions

// Needs manual deallocation
func getCopiedPointer<T>(_ data: T) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    dataPointer.initialize(to: data)

    return dataPointer
}

// Needs manual deallocation
func getCopiedPointer<T>(_ data: [T]) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: data.count)
    dataPointer.initialize(from: data, count: data.count)

    return dataPointer
}

// Relies on stack deallocation to invalidate pointer
func getDanglingPointer<T>(_ data: inout [T]) -> UnsafeMutablePointer<T> {
    return data.withUnsafeBytes { bytes in
        return UnsafeMutablePointer(mutating: bytes.baseAddress!.assumingMemoryBound(to: T.self))
    }
}

// Relies on stack deallocation to invalidate pointer
func getDanglingPointer<T>(_ data: inout T) -> UnsafeMutablePointer<T> {
    return UnsafeMutablePointer(&data)
}

// MARK: - Library Loading
// Sourced from SourceKitten's dlopen and dlsym method

class Loader {
    let handle: UnsafeMutableRawPointer

    init() {
        #if os(macOS)
            #if arch(arm64) // Darwin Aarch64
                let path = Bundle.module.path(forResource: "aarch64", ofType: ".dylib")
            #else // Darwin x86_64
                let path = Bundle.module.path(forResource: "x86_64", ofType: ".dylib")
            #endif
        #else
            #if arch(arm64) // Linux Aarch64
                let path = Bundle.module.path(forResource: "aarch64", ofType: ".so")
            #else // Linux x86_64
                let path = Bundle.module.path(forResource: "x86_64", ofType: ".so")
            #endif
        #endif

        if let handle = dlopen(path, RTLD_LAZY) {
            self.handle = handle
            return
        }

        fatalError("Loading \(path ?? "MISSING") did not resolve library")
    }

    func load<T>(_ symbol: String) -> T {
        if let selector = dlsym(handle, symbol) {
            return unsafeBitCast(selector, to: T.self)
        }

        fatalError("Symbol for \(symbol) failed: \(String(validatingUTF8: dlerror()) ?? "UNKNOWN")")
    }
}

// MARK: - Selectors for WGPU methods

private let loader = Loader()
