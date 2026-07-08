//
//  AISMessageType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

enum AISMessageType: Int {
    case positionReportClassA = 1
    case positionReportClassAAssignedSchedule = 2
    case positionReportClassAResponseToInterrogation = 3
    case baseStationReport = 4
    case staticAndVoyageRelatedData = 5
    case binaryAddressedMessage = 6
    case binaryAcknowledge = 7
    case binaryBroadcastMessage = 8
    case standardSARAircraftPositionReport = 9
    case utcAndDateInquiry = 10
    case utcAndDateResponse = 11
    case addressedSafetyRelatedMessage = 12
    case safetyRelatedAcknowledgement = 13
    case safetyRelatedBroadcastMessage = 14
    case interrogation = 15
    case assignmentModeCommand = 16
    case dgnssBinaryBroadcastMessage = 17
    case standardClassBCSPositionReport = 18
    case extendedClassBEquipmentPositionReport = 19
    case dataLinkManagement = 20
    case aidToNavigationReport = 21
    case channelManagement = 22
    case groupAssignmentCommand = 23
    case staticDataReport = 24
    case singleSlotBinaryMessage = 25
    case multipleSlotBinaryMessageWithCommunicationsState = 26
    case positionReportForLongRangeApplications = 27

    var description: String {
        switch self {
        case .positionReportClassA:
            return "Position Report Class A"
        case .positionReportClassAAssignedSchedule:
            return "Position Report Class A (Assigned schedule)"
        case .positionReportClassAResponseToInterrogation:
            return "Position Report Class A (Response to interrogation)"
        case .baseStationReport:
            return "Base Station Report"
        case .staticAndVoyageRelatedData:
            return "Static and Voyage Related Data"
        case .binaryAddressedMessage:
            return "Binary Addressed Message"
        case .binaryAcknowledge:
            return "Binary Acknowledge"
        case .binaryBroadcastMessage:
            return "Binary Broadcast Message"
        case .standardSARAircraftPositionReport:
            return "Standard SAR Aircraft Position Report"
        case .utcAndDateInquiry:
            return "UTC and Date Inquiry"
        case .utcAndDateResponse:
            return "UTC and Date Response"
        case .addressedSafetyRelatedMessage:
            return "Addressed Safety Related Message"
        case .safetyRelatedAcknowledgement:
            return "Safety Related Acknowledgement"
        case .safetyRelatedBroadcastMessage:
            return "Safety Related Broadcast Message"
        case .interrogation:
            return "Interrogation"
        case .assignmentModeCommand:
            return "Assignment Mode Command"
        case .dgnssBinaryBroadcastMessage:
            return "DGNSS Binary Broadcast Message"
        case .standardClassBCSPositionReport:
            return "Standard Class B CS Position Report"
        case .extendedClassBEquipmentPositionReport:
            return "Extended Class B Equipment Position Report"
        case .dataLinkManagement:
            return "Data Link Management"
        case .aidToNavigationReport:
            return "Aid-to-Navigation Report"
        case .channelManagement:
            return "Channel Management"
        case .groupAssignmentCommand:
            return "Group Assignment Command"
        case .staticDataReport:
            return "Static Data Report"
        case .singleSlotBinaryMessage:
            return "Single Slot Binary Message"
        case .multipleSlotBinaryMessageWithCommunicationsState:
            return "Multiple Slot Binary Message With Communications State"
        case .positionReportForLongRangeApplications:
            return "Position Report For Long-Range Applications"
        }
    }
}
