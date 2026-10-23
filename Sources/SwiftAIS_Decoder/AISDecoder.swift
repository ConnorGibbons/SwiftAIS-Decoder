//
//  AISDecoder.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/12/26.
//
//  AISDecoder is the class that implements the state & logic for handling NMEA AIS input.
import SignalTools

// Maps first character of armored NMEA AIS payload to a message type.
// Works because the first 6 bits of the payload are the message type,
// and the armoring itself is a 6-bit mapping to ASCII characters.
let aisMessageTypeByPayloadChar: [Character: AISMessageType] = [
    "1": .positionReportClassA,
    "2": .positionReportClassAAssignedSchedule,
    "3": .positionReportClassAResponseToInterrogation,
    "4": .baseStationReport,
    "5": .staticAndVoyageRelatedData,
    "6": .binaryAddressedMessage,
    "7": .binaryAcknowledge,
    "8": .binaryBroadcastMessage,
    "9": .standardSARAircraftPositionReport,
    ":": .utcAndDateInquiry,
    ";": .utcAndDateResponse,
    "<": .addressedSafetyRelatedMessage,
    "=": .safetyRelatedAcknowledgement,
    ">": .safetyRelatedBroadcastMessage,
    "?": .interrogation,
    "@": .assignmentModeCommand,
    "A": .dgnssBinaryBroadcastMessage,
    "B": .standardClassBCSPositionReport,
    "C": .extendedClassBEquipmentPositionReport,
    "D": .dataLinkManagement,
    "E": .aidToNavigationReport,
    "F": .channelManagement,
    "G": .groupAssignmentCommand,
    "H": .staticDataReport,
    "I": .singleSlotBinaryMessage,
    "J": .multipleSlotBinaryMessageWithCommunicationsState,
    "K": .positionReportForLongRangeApplications,
    "L": .singleSlotAidToNavigationReport
]

let messageTypeToParser: [AISMessageType: @Sendable (BitBuffer) throws -> AISMessage] = [
    .positionReportClassA: ClassAPositionReport.init,
    .positionReportClassAAssignedSchedule: ClassAPositionReport.init,
    .positionReportClassAResponseToInterrogation: ClassAPositionReport.init,
    .baseStationReport: BaseStationReport.init,
    .staticAndVoyageRelatedData: StaticAndVoyageData.init,
    .binaryAddressedMessage: BinaryAddressedMessage.init,
    .binaryAcknowledge: BinaryAcknowledge.init,
    .binaryBroadcastMessage: BinaryBroadcastMessage.init,
    .standardSARAircraftPositionReport: AircraftPositionReport.init,
    .utcAndDateInquiry: UTCDateInquiry.init,
    .utcAndDateResponse: UTCDateInquiryResponse.init,
    .addressedSafetyRelatedMessage: AddresedSafetyMessage.init,
    .safetyRelatedAcknowledgement: SafetyRelatedAcknowledge.init,
    .safetyRelatedBroadcastMessage: SafetyBroadcastMessage.init,
    .interrogation: InterrogationMessage.init,
    .assignmentModeCommand: AssignmentModeCommand.init,
    .dgnssBinaryBroadcastMessage: DGNSSBroadcastBinaryMessage.init,
    .standardClassBCSPositionReport: ClassBPositionReport.init,
    .extendedClassBEquipmentPositionReport: ClassBExtendedPositionReport.init,
    .dataLinkManagement: DataLinkManagement.init,
    .aidToNavigationReport: AidToNavigationReport.init,
    .channelManagement: ChannelManagement.init,
    .groupAssignmentCommand: GroupAssignmentCommand.init,
    .staticDataReport: StaticDataReport.init,
    .singleSlotBinaryMessage: SingleSlotBinaryMessage.init,
    .multipleSlotBinaryMessageWithCommunicationsState: MultiSlotBinaryMessage.init,
    .positionReportForLongRangeApplications: AISSatelliteMessage.init,
    .singleSlotAidToNavigationReport: SingleSlotAidToNavigationReport.init
]

public class AISDecoder {
    private var state: AISDecoderState
    
    public init() {
        self.state = AISDecoderState()
    }
    
    public func inputSentence(sentence: AISNMEA0183Sentence) throws -> AISMessage? {
        guard let allSentences = self.state.insert(sentence: sentence) else { return nil }
        guard let firstSentence = allSentences.first else { return nil }
        guard let messageTypeChar = firstSentence.payload.first else { return nil }
        guard let messageType = aisMessageTypeByPayloadChar[messageTypeChar] else { return nil }
        guard let parser = messageTypeToParser[messageType] else { return nil }
        var combinedPayloads = BitBuffer()
        for sentence in allSentences {
            combinedPayloads.append(contentsOf: sentence.payloadBits)
        }
        let parsedMessage = try parser(combinedPayloads)
        return parsedMessage
    }
    
}

private struct AISMessageMetadata: Hashable {
    let channel: AISChannel
    let fragmentCount: UInt8
    let sequenceNumber: UInt8
}


class AISDecoderState {
    // Messages are determined to be related if their channel, fragment count, and sequence numbers match.
    // Those properties are referred to as 'metadata' here.
    // Here, a message that has only been partially received is considered to be an 'open' message.
    // Here are the rules:
    // 1.   If a sentence is input matches the metadata of an open message, and has a fragment count greater than one
    //      and does not have the expected next fragment number given the stored state, the new sentence should be ignored.
    //
    // 2.   If a sentence is input with a fragment number of one,
    //      and the state already has an open message for the messages
    //      the state for that sequence should be reset and begin with the newly input sentence.
    //
    // 3.   If a sentence is input with a fragment number greater than 1, and it does not match the metadata
    //      of an open message, it should be ignored.
    private var openMessages: [AISMessageMetadata: [AISNMEA0183Sentence]]
    
    init() {
        self.openMessages = [:]
    }
    
    func insert(sentence: AISNMEA0183Sentence) -> [AISNMEA0183Sentence]? {
        if(sentence.sequentialID == nil || sentence.fragmentCount == 1) { // If either of these are true, it's a single-fragment sentence, so it's ready to be parsed.
            return [sentence]
        }
        
        let metadata = AISMessageMetadata(channel: sentence.channel, fragmentCount: sentence.fragmentCount, sequenceNumber: sentence.sequentialID!)
        if var openMessage = openMessages[metadata] { // Multi fragment + matches an existing message
            let last = openMessage.last!
            if(sentence.fragmentNumber == 1) {
                // Rule 2
                openMessages.updateValue([sentence], forKey: metadata)
                return nil
            }
            if(sentence.fragmentNumber != last.fragmentNumber + 1) {
                // Rule 1
                return nil
            }
            openMessage.append(sentence)
            if(sentence.fragmentNumber == sentence.fragmentCount) {
                openMessages.removeValue(forKey: metadata)
                return openMessage
            }
            openMessages.updateValue(openMessage, forKey: metadata)
            return nil
        }
        else { // Multi-fragment + not related to an existing message
            if(sentence.fragmentNumber != 1) {
                // Rule 3
                return nil
            }
            openMessages.updateValue([sentence], forKey: metadata)
            return nil
        }
    }
}
