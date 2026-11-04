//
//  StreamingAISNMEALineReaderTests.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 11/4/26.
//

import Testing
@testable import SwiftAIS_DecoderCLI

struct StreamingAISNMEALineReaderTests {
    
    @Test func extractsFullValidInput() {
        let exampleSentence = "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A" + "\r\n"
        let newStreamingLineReader = StreamingAISNMEALineReader()
        let outputSentences = newStreamingLineReader.insert(chars: [UInt8](exampleSentence.utf8))
        print(outputSentences)
        assert(outputSentences.count == 1)
        assert(String(decoding: outputSentences.first ?? [0], as: UTF8.self) == "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A")
    }
    
    @Test func extractsFullValidInputWithoutCarriageReturn() {
        let exampleSentence = "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A" + "\n"
        let newStreamingLineReader = StreamingAISNMEALineReader()
        let outputSentences = newStreamingLineReader.insert(chars: [UInt8](exampleSentence.utf8))
        print(outputSentences)
        assert(outputSentences.count == 1)
        assert(String(decoding: outputSentences.first ?? [0], as: UTF8.self) == "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A")
    }
    
    @Test func extractsFromSplitValidInput() {
        let newStreamingLineReader = StreamingAISNMEALineReader()
        let split = ["!AIVDM,1,1,,","A,91b55vRAQw","OnDE<M05ICOp0208CM",",0*6A","\r\n"]
        var outputSentences: [[UInt8]] = []
        for chunk in split {
            let output = newStreamingLineReader.insert(chars: [UInt8](chunk.utf8))
            outputSentences.append(contentsOf: output)
        }
        assert(outputSentences.count == 1)
        assert(String(decoding: outputSentences.first ?? [0], as: UTF8.self) == "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A")
    }
    
}
