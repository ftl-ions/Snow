//
//  GenerateTestListTests.swift
//  IceTests
//
//  Created by Jake Heiser on 11/25/18.
//

import TestingUtilities
import XCTest

class GenerateTestListTests: XCTestCase {

    func testGenerate() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("generate-test-list")
        
        Differentiate.byPlatform(mac: {
            Differentiate.byVersion(swift5AndAbove: {
                IceAssertEqual(result.exitStatus, 0)
                IceAssertEqual(result.stderr, "")
                
                Differentiate.byVersion(swift5_1AndAbove: {
                    IceAssertEqual(result.stdout, """
                    
                    Compile Lib/Lib.swift
                    Merge Lib
                    
                    Compile LibTests/LibTests.swift
                    Merge LibTests
                    Link LibPackageTests
                    
                    """)
                }, swift4_0AndAbove: {
                    IceAssertEqual(result.stdout, """
                    Compile Lib (1 sources)
                    Compile LibTests (1 sources)
                    Link ./.build/x86_64-apple-macosx/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                    
                    """)
                })
                
                IceAssertEqual(icebox.fileContents("Tests/LinuxMain.swift"), """
                import XCTest
                
                import LibTests
                
                var tests = [XCTestCaseEntry]()
                tests += LibTests.__allTests()
                
                XCTMain(tests)

                """)
                
                IceAssertEqual(icebox.fileContents("Tests/LibTests/XCTestManifests.swift"), """
                #if !canImport(ObjectiveC)
                import XCTest
                
                extension LibTests {
                    // DO NOT MODIFY: This is autogenerated, use:
                    //   `swift test --generate-linuxmain`
                    // to regenerate.
                    static let __allTests__LibTests = [
                        ("testExample", testExample),
                    ]
                }

                public func __allTests() -> [XCTestCaseEntry] {
                    return [
                        testCase(LibTests.__allTests__LibTests),
                    ]
                }
                #endif
                
                """)
            }, swift4_1AndAbove: {
                IceAssertEqual(result.exitStatus, 0)
                IceAssertEqual(result.stderr, "")
                IceAssertEqual(result.stdout, """
                Compile Lib (1 sources)
                Compile LibTests (1 sources)
                Link ./.build/x86_64-apple-macosx10.10/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                
                """)
                
                IceAssertEqual(icebox.fileContents("Tests/LinuxMain.swift"), """
                import XCTest
                
                import LibTests
                
                var tests = [XCTestCaseEntry]()
                tests += LibTests.__allTests()
                
                XCTMain(tests)

                """)
                
                IceAssertEqual(icebox.fileContents("Tests/LibTests/XCTestManifests.swift"), """
                import XCTest

                extension LibTests {
                    static let __allTests = [
                        ("testExample", testExample),
                    ]
                }

                #if !os(macOS)
                public func __allTests() -> [XCTestCaseEntry] {
                    return [
                        testCase(LibTests.__allTests),
                    ]
                }
                #endif
                
                """)
            }, swift4_0AndAbove: {
                IceAssertEqual(result.exitStatus, 1)
                IceAssertEqual(result.stdout, "")
                IceAssertEqual(result.stderr, """
                
                Error: test list generation only supported for Swift 4.1 and above
                
                
                """)
            })
        }, linux: {
            IceAssertEqual(result.exitStatus, 1)
            IceAssertEqual(result.stdout, "")
            IceAssertEqual(result.stderr, """

            Error: test list generation is not supported on Linux


            """)
        })
    }

}
