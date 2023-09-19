import Foundation
import PackagePlugin

@main
struct NagaPlugin: BuildToolPlugin {
  private func createBuildCommands(inputFiles: [Path], tool: PluginContext.Tool) -> [Command] {
    if inputFiles.isEmpty { return [] }
    let commandInfo: [(output: Path, files: [String])] = inputFiles.map { wgsl in
      (wgsl.removingLastComponent(),
       [wgsl.string, wgsl.string.replacingOccurrences(of: ".wgsl", with: ".metal")])
    }
    
    return commandInfo.map { info in
        .prebuildCommand(displayName: "Naga [\(info.files[0]) -> \(info.files[1])]",
                         executable: tool.path,
                         arguments: info.files,
                         outputFilesDirectory: info.output
        )
    }
  }
  
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    guard let sourceTarget = target.sourceModule else { return [] }
    return createBuildCommands(
      inputFiles: sourceTarget.sourceFiles(withSuffix: "wgsl").map(\.path),
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
      tool: try context.tool(named: "naga")
    )
  }
}
#endif
