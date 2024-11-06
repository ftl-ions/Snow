//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import PathKit

public struct ConfigFile: Codable {
    public var reformat: Bool?
    public var openAfterXc: Bool?
    public var watchPaths: [WatchPathConfig]?
    public var externalTools: [ExternalToolCommand]?
}

public struct WatchPathConfig: Codable {
    public var path: String
    public var extensions: [String]
}

public struct ExternalToolCommand: Codable {
    public var exec: String
    public var args: [String]
}

public struct Config {

    public enum Keys: String, CaseIterable {
        case reformat
        case openAfterXc
        case watchPaths
        case externalTools

        public var shortDescription: String {
            switch self {
            case .reformat:
                return
                    "whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false"
            case .openAfterXc:
                return
                    "whether Ice should open Xcode the generated project after running `ice xc`; defaults to true"
            case .watchPaths:
                return "whether Ice should watch for changes in the given paths; defaults to empty"
            case .externalTools:
                return "whether Ice should run the given tools before each build; defaults to empty"
            }
        }
    }

    public let reformat: Bool
    public let openAfterXc: Bool
    public var watchPaths: [WatchPathConfig]?
    public var externalTools: [ExternalToolCommand]?

    public init(
        reformat: Bool? = nil, openAfterXc: Bool? = nil, watchPaths: [WatchPathConfig]? = nil,
        externalTools: [ExternalToolCommand]? = nil
    ) {
        self.reformat = reformat ?? false
        self.openAfterXc = openAfterXc ?? true
        self.watchPaths = watchPaths ?? nil
        self.externalTools = externalTools ?? nil
    }

    public init(file: ConfigFile) {
        self.init(
            reformat: file.reformat, openAfterXc: file.openAfterXc, watchPaths: file.watchPaths,
            externalTools: file.externalTools)
    }

    public init(prioritized files: [ConfigFile]) {
        self.init(
            reformat: files.first(where: { $0.reformat != nil })?.reformat,
            openAfterXc: files.first(where: { $0.openAfterXc != nil })?.openAfterXc,
            watchPaths: files.first(where: { $0.watchPaths != nil })?.watchPaths,
            externalTools: files.first(where: { $0.externalTools != nil })?.externalTools
        )
    }

}

public class ConfigManager {

    public let globalPath: Path
    public let localPath: Path

    public private(set) var global: ConfigFile
    public private(set) var local: ConfigFile

    public var resolved: Config {
        return Config(prioritized: [local, global])
    }

    public init(global: Path, local: Path) {
        self.globalPath = global + "config.json"
        self.localPath = local + "snow.json"

        self.global = ConfigFile.load(from: globalPath) ?? .init()
        self.local = ConfigFile.load(from: localPath) ?? .init()
    }

    public enum UpdateScope {
        case local
        case global
    }

    public func update(scope: UpdateScope, _ go: (inout ConfigFile) -> Void) throws {
        switch scope {
        case .local:
            go(&local)
            try localPath.write(JSON.encoder.encode(local))
        case .global:
            go(&global)
            try globalPath.write(JSON.encoder.encode(global))
        }
    }

}
