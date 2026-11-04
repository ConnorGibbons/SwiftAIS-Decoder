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
    case failedToCreateInputServer
}

class ProgramState: @unchecked Sendable {
    var decodedMessages: [AISMessage] = []
    var decoders: [String: (StreamingAISNMEALineReader,AISDecoder)] = [:] // Maps TCPConnection.connectionName to a decoder and a line reader.
    var outputConnections: [TCPConnection] = []
    var inputServer: TCPServer? = nil
    let args: Arguments
    
    init(args: Arguments) throws {
        self.args = args
        if(!args.outputs.isEmpty) {
            createOutputConnections()
        }
        guard let inputPort = args.inputPort else { throw SwiftAIS_DecoderCLIErrors.noInputProvided }
        try createInputServer()
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
    
    private func createInputServer() throws {
        guard let port = args.inputPort else { throw SwiftAIS_DecoderCLIErrors.failedToCreateInputServer }
        let inputServer = try TCPServer(port: port, maxConnections: 10, actionOnNewConnection: acceptNewInputConnection, actionOnReceive: acceptInput)
    }
    
    private func acceptNewInputConnection(newInputConnection: TCPConnection) {
        let newDecoder = AISDecoder()
        let newLineReader = StreamingAISNMEALineReader()
        decoders.updateValue((newLineReader,newDecoder), forKey: newInputConnection.connectionName)
    }
    
    private func acceptInput(connectionName: String, inputData: Data) {
        guard let (lineReader, decoder) = decoders[connectionName] else {
            print("Received input from unknown connection: \(connectionName)")
            return
        }
        
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
        
        if(args.logNMEASentences) {
            print(desc)
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
    var logNMEASentences: Bool
    var outputs: [Endpoint]
    var inputPort: UInt16?
}

@main
struct SwiftAIS_DecoderCLI: ParsableCommand {
    
    @Option(name: .customLong("od"), help: "If this option has a value, the decoder will perform offline decoding on the provided file and exit.")
    var filePath: String?
    
    @Option(name: .short, help: "Format: IP:Port, provides a server to output parsed JSON data to.")
    var outputs: [String]
    
    @Option(name: .short, help: "Value to use as a port for the NMEA input server.")
    var inputPort: UInt16?
    
    @Flag(name: .short, help: "Print valid NMEA Sentence to stdout")
    var nmeaSentencesToConsole: Bool = false
    
    
    
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
        
        let args = Arguments(filePath: filePath, logNMEASentences: nmeaSentencesToConsole, outputs: outputEndpoints, inputPort: inputPort)
        if let path = filePath { // Offline decode path
            let fileURL = URL(string: path)
            try offlineDecode(fileURL: fileURL!, args: args)
            return
        }
        let state = try ProgramState(args: args)
        
        
    }
    
    
    
    
    
    
   
    
}
