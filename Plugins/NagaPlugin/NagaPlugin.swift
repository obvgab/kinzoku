import Foundation
import PackagePlugin

@main
struct NagaPlugin: BuildToolPlugin {
  private func createBuildCommands(
    inputFiles: [Path],
    workingDirectory: Path,
    tool: PluginContext.Tool
  ) -> [Command] {
    if inputFiles.isEmpty { return [] }
    let outputShaders = workingDirectory.appending("Shaders")
    try? FileManager.default.createDirectory(atPath: outputShaders.string,
                withIntermediateDirectories: true)
    
    let metalFiles = inputFiles.map { wgsl in
      [wgsl.string, workingDirectory.appending("Shaders").appending(wgsl.stem + ".metal").string]
    }
    let spvFiles = inputFiles.map { wgsl in
      [wgsl.string, workingDirectory.appending("Shaders").appending(wgsl.stem + ".spv").string]
    }
    
    return (metalFiles + spvFiles).map { files in
        .prebuildCommand(displayName: "Naga [\(files[0]) -> \(files[1])]",
                         executable: tool.path,
                         arguments: files,
                         outputFilesDirectory: outputShaders
        )
    }
  }
  
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    guard let sourceTarget = target.sourceModule else { return [] }
    return createBuildCommands(
      inputFiles: sourceTarget.sourceFiles(withSuffix: "wgsl").map(\.path),
      workingDirectory: context.pluginWorkDirectory,
      tool: try context.tool(named: "naga")
    )
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
extension NagaPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    return createBuildCommands(
      inputFiles: target.inputFiles.filter { $0.path.extension == "wgsl" }.map(\.path),
      workingDirectory: context.pluginWorkDirectory,
      tool: try context.tool(named: "naga")
    )
  }
}
#endif
