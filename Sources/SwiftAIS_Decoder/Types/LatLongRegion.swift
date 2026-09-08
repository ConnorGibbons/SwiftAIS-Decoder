//
//  LatLongRegion.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Types 22 and 23 send 2 lat/ 2 longs that form a rectangular area.
//  Inputs are expected to be in 0.1 minutes and is therefore divided by 600 to get degrees.

struct LatLongRegion {
    let longitudeNE: Longitude
    let latitudeNE: Latitude
    let longitudeSW: Longitude
    let latitudeSW: Latitude
    
    init(longitudeNEMins: UInt32, latitudeNEMins: UInt32, longitudeSWMins: UInt32, latitudeSWMins: UInt32) {
        self.longitudeNE = Longitude(rawValue: longitudeNEMins, isTenths: true)
        self.latitudeNE = Latitude(rawValue: latitudeNEMins, isTenths: true)
        self.longitudeSW = Longitude(rawValue: longitudeSWMins, isTenths: true)
        self.latitudeSW = Latitude(rawValue: latitudeSWMins, isTenths: true)
    }
    
    var description: String {
        "\(longitudeNE.description), \(latitudeNE.description), \(longitudeSW.description), \(latitudeSW.description)"
    }
}


