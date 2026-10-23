//
//  OfflineParse.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/12/26.
//
//  For reading a file of AIS NMEA sentences & processing them.
import Foundation
import SwiftAIS_Decoder


final class AISNMEALineReader {
    // NMEA Line reader specifically for extracting AIS sentences from a file of newline separated sentences.
    private let handle: FileHandle
    private let chunkSize: Int
    private var buffer: [UInt8] = []
    private var lineStartPosition = 0
    private var eofReached = false

    init(url: URL, chunkSize: Int = 256 * 1024) throws {
        self.handle = try FileHandle(forReadingFrom: url)
        self.chunkSize = chunkSize
    }

    deinit { try? handle.close() }

    func next() throws -> [UInt8]? {
        while true {
            if let newlinePosition = buffer[lineStartPosition...].firstIndex(of: UInt8(ascii: "\n")) {
                let line = line(in: lineStartPosition..<newlinePosition)
                lineStartPosition = newlinePosition + 1
                if let line { return Array(line) }
                continue // blank or non-AIS line: skip it
            }
            if eofReached {
                guard lineStartPosition < buffer.count else { return nil }
                let line = line(in: lineStartPosition..<buffer.count)
                lineStartPosition = buffer.count
                return line.map(Array.init) // nil here really is end of file
            }
            buffer.removeFirst(lineStartPosition)
            lineStartPosition = 0
            if let chunk = try handle.read(upToCount: chunkSize), !chunk.isEmpty {
                buffer.append(contentsOf: chunk)
            } else {
                eofReached = true
            }
        }
    }

    private func line(in range: Range<Int>) -> ArraySlice<UInt8>? {
        var end = range.upperBound
        if end > range.lowerBound, buffer[end - 1] == UInt8(ascii: "\r") { end -= 1 }
        let line = buffer[range.lowerBound..<end]
        if let sentenceStart = line.firstIndex(where: {$0 == UInt8(ascii: "!")}) {
            return line[sentenceStart...]
        } else {
            return nil // If it's some other sentence type that isn't "!"-prefixed, it will land here
        }
    }
    
}

func offlineDecode(fileURL: URL) throws {
    var errors: [(Error, String?)] = [] // Error & a debug string tuple
    var messages: [AISMessage] = []
    
    func logError(err: Error, debug: String?) {
        errors.append((err,debug))
    }
    
    let reader = try AISNMEALineReader(url: fileURL)
    let decoder = AISDecoder()
    while let sentence = try reader.next() {
        let sentenceAsString = String(decoding: sentence, as: UTF8.self) // input is ASCII but this works
        do {
            let aisSentence = try AISNMEA0183Sentence(raw: sentenceAsString)
            if let aisMessage = try decoder.inputSentence(sentence: aisSentence) { messages.append(aisMessage) }
        }
        catch {
            logError(err: error, debug: "Offending sentence: \(sentenceAsString)")
            continue
        }
    }
    
    printStats(errors: errors, messages: messages)
}

private func printStats(errors: [(Error, String?)], messages: [AISMessage]) {
    var messageTypeCounts: [AISMessageType: Int] = [:]
    for message in messages {
        messageTypeCounts[message.messageType, default: 0] += 1
    }

    let divider = String(repeating: "─", count: 60)
    print(divider)
    print("AIS Decode Summary")
    print(divider)

    // Messages
    print("Messages decoded: \(messages.count)")
    let sortedTypes = messageTypeCounts.sorted { "\($0.key)" < "\($1.key)" }
    let labelWidth = sortedTypes.map { "\($0.key)".count }.max() ?? 0
    let countWidth = String(sortedTypes.map(\.value).max() ?? 0).count

    for (type, count) in sortedTypes {
        let label = "\(type)".padding(toLength: labelWidth, withPad: " ", startingAt: 0)
        let countStr = String(repeating: " ", count: countWidth - String(count).count) + String(count)
        let percent = Double(count) / Double(messages.count) * 100
        print("  \(label)  \(countStr)  (\(String(format: "%5.1f", percent))%)")
    }
    
    // Errors
    print()
    print("Errors: \(errors.count)")
    let indexWidth = String(errors.count).count
    for (i, (error, debug)) in errors.enumerated() {
        let index = String(repeating: " ", count: indexWidth - String(i + 1).count) + String(i + 1)
        print("  [\(index)] \(error)")
        if let debug {
            print("  " + String(repeating: " ", count: indexWidth + 3) + "↳ \(debug)")
        }
    }
    print(divider)
}
