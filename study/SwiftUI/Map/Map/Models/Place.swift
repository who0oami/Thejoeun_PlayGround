//
//  Place.swift
//  Map
//
//  Created by electrozone on 3/31/26.
//

import CoreLocation
import MapKit
import SwiftUI

enum Place: String, CaseIterable, Identifiable {
    case historyHall
    case duliMuseum
    case currentLocation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .historyHall:
            "서대문 형무소 역사관"
        case .duliMuseum:
            "둘리뮤지엄"
        case .currentLocation:
            "현재 위치"
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .historyHall:
            CLLocationCoordinate2D(latitude: 37.5744, longitude: 126.9570)
        case .duliMuseum:
            CLLocationCoordinate2D(latitude: 37.6524, longitude: 127.0277)
        case .currentLocation:
            CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
        }
    }

    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }

    var tint: Color {
        switch self {
        case .historyHall:
            .indigo
        case .duliMuseum:
            .red
        case .currentLocation:
            .blue
        }
    }
}
