import Wgpu
import Foundation

public struct KZShaderModule { public var c: WGPUShaderModule }

public class KZShaderSource {
    public var c: WGPUShaderModuleDescriptor
    var pointers: (
        file: UnsafeMutablePointer<CChar>,
        wgsl: UnsafeMutablePointer<WGPUShaderModuleWGSLDescriptor>?,
        label: UnsafeMutablePointer<CChar>,
        spirv: UnsafeMutablePointer<WGPUShaderModuleSPIRVDescriptor>?
    )
    
    init(fromWGSL: URL) throws {
        let fileContents = try String(contentsOf: fromWGSL).cString(using: String.Encoding.utf8)!
        
        pointers.file = UnsafeMutablePointer<CChar>.allocate(capacity: fileContents.count)
        pointers.file.initialize(from: fileContents, count: fileContents.count)
        
        let wgslDescriptor = WGPUShaderModuleWGSLDescriptor(
            chain: WGPUChainedStruct(next: nil, sType: WGPUSType_ShaderModuleWGSLDescriptor),
            code: pointers.file
        )
        
        pointers.wgsl = UnsafeMutablePointer<WGPUShaderModuleWGSLDescriptor>.allocate(capacity: 1)
        pointers.wgsl!.initialize(to: wgslDescriptor)
        let castedPointer = UnsafeRawPointer(pointers.wgsl!).bindMemory(to: WGPUChainedStruct.self, capacity: 1)
        
        let labelArray = fromWGSL.relativeString.cString(using: String.Encoding.utf8)!
        pointers.label = UnsafeMutablePointer<CChar>.allocate(capacity: labelArray.count)
        pointers.label.initialize(from: labelArray, count: labelArray.count)
        
        c = WGPUShaderModuleDescriptor(
            nextInChain: castedPointer,
            label: pointers.label,
            hintCount: 0,
            hints: nil
        )
        
        pointers.spirv = nil
    }
    
    /*
    init(fromSPIRV: URL) {
        
    }
     */
    
    // Hopefully get rid of the pointers and data (no memory leaks?)
    deinit {
        pointers.file.deallocate()
        pointers.label.deallocate()
        pointers.wgsl?.deallocate()
        pointers.spirv?.deallocate()
    }
}
