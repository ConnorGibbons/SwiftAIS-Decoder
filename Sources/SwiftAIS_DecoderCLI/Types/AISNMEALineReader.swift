//
//  AISNMEALineReader.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 11/4/26.
//

import Foundation

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
