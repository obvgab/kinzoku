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

// General note: Create getters and setters for all KZ classes that make interfacing with them akin to C--just provide middleman
