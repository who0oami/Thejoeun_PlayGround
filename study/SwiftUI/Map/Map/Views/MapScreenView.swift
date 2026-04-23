//
//  MapScreenView.swift
//  Map
//
//  Created by electrozone on 3/31/26.
//

import MapKit
import SwiftUI

struct MapScreenView: View {
    private let isPreview: Bool

    @State private var selectedPlace: Place = .historyHall
    @State private var position: MapCameraPosition = .region(Place.historyHall.region)

    @StateObject private var locationManager = LocationPermissionManager()

    init(isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1") {
        self.isPreview = isPreview
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapView
                    .ignoresSafeArea(edges: .bottom)

                PlaceSegmentedControl(selectedPlace: $selectedPlace)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard !isPreview else { return }
            locationManager.activate()
        }
        .onChange(of: selectedPlace) { _, place in
            moveCamera(to: place)
        }
        .onChange(of: locationManager.currentLocation) { _, location in
            guard location != nil, selectedPlace == .currentLocation else { return }
            moveCamera(to: .currentLocation)
        }
    }

    private var mapView: some View {
        Map(position: $position) {
            placeMarkers

            if !isPreview {
                UserAnnotation(anchor: .center) {
                    UserLocationAnnotationView()
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    @MapContentBuilder
    private var placeMarkers: some MapContent {
        ForEach(Place.allCases.filter { $0 != .currentLocation }) { place in
            Marker(place.title, coordinate: place.coordinate)
                .tint(place.tint)
        }
    }

    private func moveCamera(to place: Place) {
        if place == .currentLocation {
            if isPreview {
                position = .region(Place.currentLocation.region)
                return
            }

            position = .userLocation(
                followsHeading: false,
                fallback: .region(Place.currentLocation.region)
            )
            return
        }

        position = .region(place.region)
    }
}

#Preview {
    MapScreenView(isPreview: true)
}
