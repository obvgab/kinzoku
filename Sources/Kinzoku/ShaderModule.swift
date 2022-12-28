import Wgpu
import Foundation

public struct KZShaderModule { public var c: WGPUShaderModule }

public struct KZShaderSource {
    public var c: WGPUShaderModuleDescriptor
    
    // We want to keep these objects tracked by ARC (if I did this right)
    var wgslDescriptor: WGPUShaderModuleWGSLDescriptor
    // var spirvDescriptor: WGPUShaderModuleSPIRVDescriptor
    
    init(fromWGSL: URL) throws {
        var stringRaw = try String(contentsOf: fromWGSL)
            
        wgslDescriptor = WGPUShaderModuleWGSLDescriptor(
            chain: WGPUChainedStruct(next: nil, sType: WGPUSType_ShaderModuleWGSLDescriptor),
            code: stringRaw
        )
        
        let pointer = UnsafeRawPointer(&wgslDescriptor).bindMemory(to: WGPUChainedStruct.self, capacity: 1)
        
        c = WGPUShaderModuleDescriptor(
            nextInChain: pointer,
            label: "test", // How to get around the pointer must outlive?
            hintCount: 0,
            hints: nil
        )
    }
    
    /*
    init(fromSPIRV: URL) {
        
    }
     */
}
