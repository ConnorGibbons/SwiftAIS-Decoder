// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftAIS_Decoder

@main
struct SwiftAIS_DecoderCLI: ParsableCommand {
    
    @Argument(help: "File path")
    var filePath: String
    
    mutating func run() throws {
        let fileURL = URL(string: filePath)
        try offlineDecode(fileURL: fileURL!)
    }
    
}
