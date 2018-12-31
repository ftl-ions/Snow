//
//  PackageLoader.swift
//  IceKit
//
//  Created by Jake Heiser on 7/28/18.
//

import Foundation
import PathKit
import SwiftCLI

public struct PackageLoader {
    
    private final class ToolsVersionLine: Matcher, Matchable {
        // Spec at: https://github.com/apple/swift-package-manager/blob/master/Sources/PackageLoading/ToolsVersionLoader.swift#L97
        static let regex = Regex("^// swift-tools-version:(.*?)(?:;.*|$)", options: [.caseInsensitive])
        
        var toolsVersion: String { return captures[0] }
    }
    
    public static func formPackagePath(in directory: Path, toolsVersion: String? = nil) -> Path {
        var file = "Package"
        if let toolsVersion = toolsVersion {
            file += "@swift-\(toolsVersion)"
        }
        file += ".swift"
        return directory + file
    }
    
    public let root: Path
    
    public init(directory: Path, crawlUp: Bool = true) throws {
        var current = directory
        while true {
            let path = PackageLoader.formPackagePath(in: current)
            if path.exists {
                self.root = current
                return
            }
            let parent = current.parent()
            if current == parent || crawlUp == false { // Root; can't go up any farther, no Package.swift
                throw IceError(message: "couldn't find Package.swift")
            }
            current = parent
        }
        fatalError()
    }
    
    public func packageFilePath(for toolsVersion: SwiftToolsVersion?) -> Path {
        if let version = toolsVersion?.version {
            let tags = [
                "\(version.major).\(version.minor).\(version.patch)",
                "\(version.major).\(version.minor)",
                "\(version.major)",
            ]
            for tag in tags {
                let path = PackageLoader.formPackagePath(in: root, toolsVersion: tag)
                if path.exists {
                    return path
                }
            }
        }
        let nonSpecific = PackageLoader.formPackagePath(in: root)
        return nonSpecific
    }
    
    public func loadPackage(config: Config?) throws -> Package {
        let spm = SPM(directory: root)
        let data = try spm.dumpPackage()
        
        let path = packageFilePath(for: spm.version)
        
        Logger.verbose <<< "Identified Package.swift location: " + path.string

        guard let file = ReadStream.for(path: path.string),
            let line = file.readLine(),
            let match = ToolsVersionLine.findMatch(in: line),
            let toolsVersion = SwiftToolsVersion(match.toolsVersion) else {
                throw IceError(message: "couldn't read Package.swift")
        }
        
        return try loadPackage(from: data, toolsVersion: toolsVersion, path: path, config: config)
    }
    
    public func loadPackage(from payload: Data, toolsVersion: SwiftToolsVersion, path: Path, config: Config?) throws -> Package {
        let data: ModernPackageData
        if let v5_0 = try? JSONDecoder().decode(PackageDataV5_0.self, from: payload) {
            Logger.verbose <<< "Parsing package output as from SPM v5.0"
            data = v5_0
        } else if let v4_2 = try? JSONDecoder().decode(PackageDataV4_2.self, from: payload) {
            Logger.verbose <<< "Parsing package output as from SPM v4.2"
            data = v4_2.convertToModern()
        } else if let v4_0 = try? JSONDecoder().decode(PackageDataV4_0.self, from: payload) {
            Logger.verbose <<< "Parsing package output as from SPM v4.0"
            data = v4_0.convertToModern()
        } else {
            throw IceError(message: "can't parse Package.swift")
        }
        return Package(data: data, toolsVersion: toolsVersion, path: path, config: config)
    }
    
}
