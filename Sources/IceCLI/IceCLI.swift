//
// IceCLI.swift
// IceCLI
//

import Foundation
import IceKit
import PathKit
import Rainbow
import SwiftCLI

public class IceCLI {
    
    public static let name = "ice"
    public static let description = "ice package manager"
    public static let version = "0.6.2"
    
    private static let globalRootKey = "ICE_GLOBAL_ROOT"
    
    public init() {}
    
    public func run() -> Never {
        Rainbow.enabled = Term.isTTY
        
        let ice = createIce()
        
        let cli = CLI(
            name: IceCLI.name, version: IceCLI.version, description: IceCLI.description)
        cli.commands = [
            AddCommand(ice: ice),
            BuildCommand(),
            CleanCommand(),
            ConfigGroup(ice: ice),
            DescribeCommand(ice: ice),
            DumpCommand(),
            FormatCommand(ice: ice),
            GenerateCompletionsCommand(cli: cli),
            InitCommand(ice: ice),
            NewCommand(ice: ice),
            OutdatedCommand(ice: ice),
            ProductGroup(ice: ice),
            RemoveCommand(ice: ice),
            RegistryGroup(ice: ice),
            ResetCommand(),
            ResolveCommand(),
            RunCommand(),
            SearchCommand(ice: ice),
            TargetGroup(ice: ice),
            TestCommand(),
            ToolsVersionGroup(ice: ice),
            UpdateCommand(ice: ice),
            VersionCommand(ice: ice),
            XcCommand(ice: ice)
        ]
        cli.globalOptions = [GlobalOptions.verbose]
        cli.versionCommand = nil
        cli.goAndExit()
    }
    
    private func createIce() -> Ice {
        let root: Path
        if let rootStr = ProcessInfo.processInfo.environment[IceCLI.globalRootKey] {
            root = Path(rootStr)
        } else {
            root = Ice.defaultRoot
        }
        
        do {
            return try Ice(root: root)
        } catch {
            WriteStream.stderr <<< "Error: ".bold.red + "couldn't set up Ice at \(root)"
            exit(1)
        }
    }
    
}
