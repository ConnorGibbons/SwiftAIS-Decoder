//
//  StreamingAISNMEALineReader.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 11/4/26.
//


import Foundation

public final class StreamingAISNMEALineReader: @unchecked Sendable {
    // NMEA sentence reader with a buffer & an insert function that emits once the buffer contains a full sentence.
    private var buffer: [UInt8] = []
    private let maxBufferLength: UInt16 // NMEA 0183 max sentence length is 82 chars. If the buffer exceeds the provided limit, it will be automatically flushed without emitting a sentence.
    
    init(maxBufferLength: UInt16 = 165) { // Default max of 165 chars. I did this so that if there is preceding junk, a valid sentence won't be dropped. If this is set too short and a sentence is dropped, it'll cause subsequent sentence alignment issues.
        self.maxBufferLength = maxBufferLength
    }
    
    // Returns an array of [UInt8] elements. Each [UInt8] is an AIS NMEA sentence.
    public func insert(chars: [UInt8]) -> [[UInt8]] {
        var sentences: [[UInt8]] = []
        buffer.append(contentsOf: chars)
        while let (start, end, trimmed) = findSentence() {
            sentences.append(Array(buffer[start...end]))
            buffer = Array(buffer[(end+trimmed+1)...])
        }
        if(buffer.count > maxBufferLength) {
            buffer.removeAll()
        }
        return sentences
    }
    
    // Finds an AIS sentence in the buffer and returns a tuple containing the index of "!", "\n", and the number of characters trimmed from the end..
    private func findSentence() -> (Int,Int,Int)? {
        if let beginIndex = buffer.firstIndex(where: {$0 == UInt8(ascii: "!")}) {
            let temp = buffer.dropFirst(beginIndex) // To prevent a circumstance where endIndex < beginIndex
            if let endIndex = temp.firstIndex(where: {$0 == UInt8(ascii: "\n")}) {
                var offsetEndIndex = endIndex - 1 // Trimming \n from end
                var trimmed = 1
                if(buffer[offsetEndIndex] == UInt8(ascii: "\r")) { offsetEndIndex -= 1; trimmed += 1 } // Trimming \r if present
                return (beginIndex, offsetEndIndex, trimmed)
            }
        }
        return nil
    }
    
}
