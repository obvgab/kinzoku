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
        pointers.file = manualPointer(fileContents)
        
        let wgslDescriptor = WGPUShaderModuleWGSLDescriptor(
            chain: WGPUChainedStruct(next: nil, sType: WGPUSType_ShaderModuleWGSLDescriptor),
            code: pointers.file
        )
        pointers.wgsl = manualPointer(wgslDescriptor)
        let castedPointer = UnsafeRawPointer(pointers.wgsl!).bindMemory(to: WGPUChainedStruct.self, capacity: 1)
        
        let labelArray = fromWGSL.relativeString.cString(using: String.Encoding.utf8)!
        pointers.label = manualPointer(labelArray)

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
