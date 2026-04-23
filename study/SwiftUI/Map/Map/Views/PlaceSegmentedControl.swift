//
//  PlaceSegmentedControl.swift
//  Map
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct PlaceSegmentedControl: View {
    @Binding var selectedPlace: Place

    var body: some View {
        Picker("장소 선택", selection: $selectedPlace) {
            ForEach(Place.allCases) { place in
                Text(place.title).tag(place)
            }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    PlaceSegmentedControl(selectedPlace: .constant(.historyHall))
        .padding()
}
