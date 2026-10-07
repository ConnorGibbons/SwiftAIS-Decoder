//
//  AtoNDimensions.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//
//  I tried to be as faithful to the spec as possible here without over complicating things.
//  Some of these types call for tracking state across multiple type 28 messages & combining them to form a meaningful output.
//  Since this message type is rarely used, I don't think that's worth the effort right now. If it proves necessary in the future I'll consider adding it.

/// Dimensions A and B of an AtoN, interpreted according to its dimension type.
/// This is strictly for message type 28
struct AtoNDimensions {
    let type: AtoNDimensionType
    let additionalDataFlag: Bool
    let a: UInt16
    let b: UInt16

    init?(type: AtoNDimensionType, additionalDataFlag: Bool, a: UInt16, b: UInt16) {
        guard a <= 0b111111111 else { return nil } // Max val is 511, field is 9 bits
        guard b <= 0b11111111111 else { return nil } // Max val is 2047, field is 11 bits
        self.type = type
        self.additionalDataFlag = additionalDataFlag
        self.a = a
        self.b = b
    }

    var description: String {
        guard additionalDataFlag, let combination = combinationDescription else { return dimensionsDescription }
        return "\(dimensionsDescription) (\(combination))"
    }

    /// How this dimension type combines with an accompanying one when the additional data flag is set.
    /// Only covers the combinations the spec actually defines in the dimension type descriptions.
    private var combinationDescription: String? {
        switch type {
        case .areaSector:
            "Connects clockwise with the accompanying Boundary Line 1 at the same position to form a sector"
        case .areaQuadrilateral:
            "Connects clockwise with the accompanying Boundary Line 2 or Large Boundary Line 2 to form a quadrilateral"
        case .largeAreaSector:
            "Connects clockwise with the accompanying Large Boundary Line 1 at the same position to form a sector"
        case .largeAreaQuadrilateral:
            "Connects clockwise with the accompanying Large Boundary Line 2 to form a quadrilateral"
        default:
            nil
        }
    }

    private var dimensionsDescription: String {
        switch type {
        case .standard:
            return "A: \(a) m, B: \(b) m"
        case .heightAndStructuralArea:
            let radius = a == 511 ? "511 m or greater" : "\(a) m"
            let height = b == 2047 ? "204.7 m or greater" : "\(Double(b) / 10) m"
            return "Radius: \(radius), Height above sea level: \(height)"
        case .swingCircle:
            // B values above 100 are reserved, so the radius can't be computed
            guard b <= 100 else { return "Radius: Reserved (A: \(a), B: \(b))" }
            return "Radius: \(Int(a) * 100 + Int(b)) m"
        case .mobileVector:
            return "COG: \(mobileCourseDescription), SOG: \(mobileSpeedDescription)"
        case .areaPolygon:
            return "Vertex: \(vertexDescription), Total lines: \(b <= 8 ? "\(b)" : "Reserved (\(b))")"
        case .areaCircle:
            // A values above 99 are reserved, so the radius can't be computed
            guard a <= 99 else { return "Radius: Reserved (A: \(a), B: \(b))" }
            return "Radius: \(Int(a) + (Int(b) * 100)) m" // A is in 1-meter steps, B is 100m steps
        case .boundaryLine1, .areaSector, .boundaryLine2:
            return "Orientation: \(orientationDescription), Length: \(Int(b) * 10) m"
        case .areaQuadrilateral:
            return "Orientation: \(orientationDescription), Diagonal length: \(Int(b) * 10) m"
        case .largeBoundaryLine1, .largeAreaSector, .largeBoundaryLine2:
            return "Orientation: \(orientationDescription), Length: \(Int(b) * 200) m"
        case .largeAreaQuadrilateral:
            return "Orientation: \(orientationDescription), Diagonal length: \(Int(b) * 200) m"
        case .reserved, .reserved2:
            return "Reserved (A: \(a), B: \(b))"
        }
    }

    private var orientationDescription: String {
        switch a {
        case 0...359:
            return "\(a) degrees"
        case 361 where type == .areaQuadrilateral || type == .largeAreaQuadrilateral:
            return "Not available"
        default:
            return "Reserved (\(a))"
        }
    }

    private var mobileCourseDescription: String {
        switch a {
        case 0...359: return "\(a) degrees"
        case 360: return "Not reported"
        case 361: return "Not reported (dynamically positioned on station)"
        case 362: return "Not reported (purposely adrift)"
        case 363: return "Not reported (tethered)"
        case 364: return "Unknown"
        default: return "Reserved (\(a))"
        }
    }
    
    private var mobileSpeedDescription: String {
        switch b {
        case 0...59: return "\(b) knots"
        case 60: return "Not reported"
        default: return "Reserved (\(b))"
        }
    }

    private var vertexDescription: String {
        switch a {
        case 0: return "Closing vertex (connects to vertex 1)"
        case 1...8: return "\(a)"
        default: return "Reserved (\(a))"
        }
    }
}
