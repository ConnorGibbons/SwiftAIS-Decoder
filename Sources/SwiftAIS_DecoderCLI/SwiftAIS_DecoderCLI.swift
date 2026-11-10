// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftAIS_Decoder
import Networking

enum SwiftAIS_DecoderCLIErrors: Error {
    case noInputProvided
    case failedToCreateAnyInputs
}

class ProgramState: @unchecked Sendable {
    var decodedMessages: [AISMessage] = []
    var outputConnections: [TCPConnection] = []
    var inputConnections: [TCPConnection] = []
    let args: Arguments
    
    init(args: Arguments) throws {
        self.args = args
        guard !args.inputs.isEmpty else { throw SwiftAIS_DecoderCLIErrors.noInputProvided }
        if(!args.outputs.isEmpty) {
            createOutputConnections()
        }
        try createInputConnections()
    }
    
    private func createOutputConnections() {
        for output in args.outputs {
            do {
                let connection = try TCPConnection(onRead: {_ in }, host: output.ip, port: Int(output.port))
                self.outputConnections.append(connection)
            }
            catch {
                print("Failed to create output connection for: \(output.ip):\(output.port), error: \(error)")
            }
        }
    }
    
    private func createInputConnections() throws {
        for input in args.inputs {
            do {
                let newDecoder = AISDecoder()
                let newLineReader = StreamingAISNMEALineReader()
                let newConnection = try TCPConnection(onRead: {
                    self.acceptInput(decoder: newDecoder, lineReader: newLineReader, inputData: $0)
                }, host: input.ip, port: Int(input.port))
                self.inputConnections.append(newConnection)
            }
            catch {
                print("Failed to create input connection for IP: \(input.ip), Port: \(input.port)")
            }
        }
        if(self.inputConnections.isEmpty) {
            throw SwiftAIS_DecoderCLIErrors.failedToCreateAnyInputs
        }
    }
    
    private func acceptInput(decoder: AISDecoder, lineReader: StreamingAISNMEALineReader, inputData: Data) {
        let sentences = lineReader.insert(chars: [UInt8](inputData))
        for sentence in sentences {
            do {
                let parsedSentence = try AISNMEA0183Sentence(raw: String(decoding: sentence, as: UTF8.self))
                if let newAISMessage = try decoder.inputSentence(sentence: parsedSentence) {
                    emitAISMessage(message: newAISMessage)
                }
            }
            catch {
                print("Invalid AIS NMEA Sentence, won't be handled: \(sentence), error: \(error)")
            }
        }
    }
    
    private func emitAISMessage(message: AISMessage) {
        let desc = message.description()
        
        if(args.logDecodedMessages) {
            print(desc + "\n")
        }
        
        for connection in outputConnections {
            do {
               try connection.sendLine(desc)
            }
            catch {
                print("Failed to send AIS data to connection: \(connection.connectionName)")
            }
        }
    }
    
}

struct Arguments {
    var filePath: String? //
    var logDecodedMessages: Bool
    var outputs: [Endpoint]
    var inputs: [Endpoint]
}

@main
struct SwiftAIS_DecoderCLI: ParsableCommand {
    
    @Option(name: .customLong("od"), help: "If this option has a value, the decoder will perform offline decoding on the provided file and exit.")
    var filePath: String?
    
    @Option(name: .short, help: "Format: IP:Port, provides a server to output parsed JSON data to.")
    var outputs: [String] = []
    
    @Option(name: .short, help: "Format: IP:Port, provides a server to connect to for NMEA input.")
    var inputs: [String] = []
    
    @Flag(name: .customShort("n"), help: "Print decoded messages to stdout")
    var logDecodedMessages: Bool = false
    
    
    
    mutating func run() throws {
        
        let outputEndpoints: [Endpoint] = outputs.reduce([], { acc, endpointString in
            var accCpy = acc
            do {
                let endpoint = try Endpoint(fromString: endpointString)
                accCpy.append(endpoint)
            }
            catch {
               print("Invalid endpoint: \(endpointString), \(error)")
            }
            return accCpy
        })
        let inputEndpoints: [Endpoint] = inputs.reduce([], { acc, endpointString in
            var accCpy = acc
            do {
                let endpoint = try Endpoint(fromString: endpointString)
                accCpy.append(endpoint)
            }
            catch {
               print("Invalid endpoint: \(endpointString), \(error)")
            }
            return accCpy
        })
        
        let args = Arguments(filePath: filePath, logDecodedMessages: logDecodedMessages, outputs: outputEndpoints, inputs: inputEndpoints )
        if let path = filePath { // Offline decode path
            let fileURL = URL(string: path)
            try offlineDecode(fileURL: fileURL!, args: args)
            return
        }
        let state = try ProgramState(args: args)
        let sem = DispatchSemaphore(value: 0)
        sem.wait()
    }
    
    
    
    
    
    
   
    
}
