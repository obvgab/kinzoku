import Wgpu

// Short utility functions
func manualPointer<T>(_ data: T) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    dataPointer.initialize(to: data)
    
    return dataPointer
}

func manualPointer<T>(_ data: [T]) -> UnsafeMutablePointer<T> {
    let dataPointer = UnsafeMutablePointer<T>.allocate(capacity: data.count)
    dataPointer.initialize(from: data, count: data.count)
    
    return dataPointer
}

/*
 General Notes:
 - Create getters and setters for all KZ classes that make interfacing with them akin to C--just provide middleman
 - All the 'self.pointers' tuples can probably be compressed to just an [UnsafeMutablePointer<Any>], but readibility is key right now
 - '#if os(macOS)' is scattered through the code because the precompiled binaries don't seem to contain them. Maybe manually compile them?
   - Seems to not be implemented on arm64, I don't know about x86
   - Manually compiling does seem to solve other issues, though
 - WGPUChainedStructs should be removed eventually.
   - Appears basically everwhere with "nextInChain" and what not
   - Maybe implement a .intoChainedStruct() for all classes, or allow all classes in the init()?
*/
