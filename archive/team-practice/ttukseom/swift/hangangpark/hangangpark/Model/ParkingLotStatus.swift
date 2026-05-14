//
//  ParkingLotStatus.swift
//  hangangpark
//

import Foundation

struct ParkingLotStatus: Decodable, Identifiable, Equatable {
    let parkinglotname: String
    let address: String
    let available: Int
    let capacity: Int
    let occupied: Int
    let occupancyRate: Double
    let statusLabel: String
    let latitude: Double
    let longitude: Double

    var id: String { "\(parkinglotname)-\(latitude)-\(longitude)" }

    private enum CodingKeys: String, CodingKey {
        case parkinglotname
        case address
        case available
        case capacity
        case occupied
        case occupancyRate = "occupancy_rate"
        case statusLabel = "status_label"
        case latitude
        case longitude
    }
}
