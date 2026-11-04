//
//  OfflineDecode.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/12/26.
//
//  For reading a file of AIS NMEA sentences & processing them.
import Foundation
import SwiftAIS_Decoder


func offlineDecode(fileURL: URL, args: Arguments) throws {
    var errors: [(Error, String?)] = [] // Error & a debug string tuple
    var messages: [AISMessage] = []
    
    func logError(err: Error, debug: String?) {
        errors.append((err,debug))
    }
    var decodeTime: Double = 0.0
    let reader = try AISNMEALineReader(url: fileURL)
    let decoder = AISDecoder()
    while let sentence = try reader.next() {
        let sentenceAsString = String(decoding: sentence, as: UTF8.self) // input is ASCII but this works
        do {
            let start = DispatchTime.now()
            let aisSentence = try AISNMEA0183Sentence(raw: sentenceAsString)
            if let aisMessage = try decoder.inputSentence(sentence: aisSentence) { messages.append(aisMessage) }
            decodeTime += (Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000)
        }
        catch {
            logError(err: error, debug: "Offending sentence: \(sentenceAsString)")
            continue
        }
    }
    
    printStats(errors: errors, messages: messages, decodeTime: decodeTime)
}

private func printStats(errors: [(Error, String?)], messages: [AISMessage], decodeTime: Double) {
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
    print("Time spent decoding: \(decodeTime) ms")
    print("Decoding time per message: \(decodeTime / Double(messages.count)) ms")
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
