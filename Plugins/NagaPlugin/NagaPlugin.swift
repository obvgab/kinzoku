import PackagePlugin
import Foundation

@main
struct NagaPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceShaders = FileManager.default
            .enumerator(atPath: context.pluginWorkDirectory.appending(subpath: "Shaders").string)? // Allow to be overriden?
            .allObjects
            .compactMap({ $0 as? String })
        else {
            return []
        }
        
        return try sourceShaders.map {
            Command.buildCommand( // Either make both .metal and .spv, or figure out our platform target
                displayName: "Converting WGSL to Metal", // Make dynamic
                executable: try context.tool(named: "naga").path,
                arguments: [
                    $0,
                    $0.replacingOccurrences(of: ".wgsl", with: ".metal") // Make dynamic
                ]
            )
        }
    }
}
