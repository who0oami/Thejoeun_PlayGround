//
//  ConvenienceMapView.swift
//  hangangpark
//

import MapKit
import SwiftUI

struct ConvenienceMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5298, longitude: 127.0718),
        span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
    )
    @State private var places: [ConveniencePlace] = ConveniencePlace.parkingLots
    @State private var selectedPlace: ConveniencePlace?
    @State private var selectedDistance = ConvenienceDistance.fiveHundred
    @State private var message = "편의점 위치를 불러오는 중입니다."
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    header
                    mapView
                    placeList
                }
                .padding(18)
            }
        }
        .navigationTitle("편의점 지도")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadConvenienceStores()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("주변 편의점 찾아보기")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text("뚝섬 주차장과 가까운 편의점 위치를 함께 확인하세요.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.86))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.11, green: 0.34, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: mapPlaces) { place in
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    select(place)
                } label: {
                    mapPin(for: place)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            if isLoading {
                ProgressView("검색 중...")
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func mapPin(for place: ConveniencePlace) -> some View {
        let highlighted = isHighlightedOnMap(place)
        let selected = selectedPlace?.id == place.id

        return VStack(spacing: highlighted ? 6 : 4) {
            Image(systemName: place.kind.systemImage)
                .font(.system(size: highlighted ? 24 : 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: highlighted ? 46 : 34, height: highlighted ? 46 : 34)
                .background(place.kind.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(selected ? 0.26 : 0.18), radius: selected ? 10 : 6, x: 0, y: 3)

            Text(place.shortName)
                .font((highlighted ? Font.caption : Font.caption2).weight(.bold))
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                .lineLimit(1)
                .padding(.horizontal, highlighted ? 8 : 6)
                .padding(.vertical, highlighted ? 4 : 3)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private var placeList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(listTitle)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

                Spacer()

                Text(listBadgeText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.06, green: 0.52, blue: 0.48))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.89, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if selectedPlace != nil {
                distancePicker
            }

            if let selectedPlace, selectedPlace.kind == .store {
                selectedStoreInfo(place: selectedPlace)
            }

            if displayPlaces.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayPlaces) { place in
                    Button {
                        select(place)
                    } label: {
                        PlaceResultRow(place: place, isSelected: selectedPlace?.id == place.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    private var distancePicker: some View {
        HStack(spacing: 8) {
            ForEach(ConvenienceDistance.allCases) { distance in
                Button {
                    selectedDistance = distance
                } label: {
                    Text(distance.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(selectedDistance == distance ? .white : Color(red: 0.16, green: 0.38, blue: 0.83))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(selectedDistance == distance ? Color(red: 0.16, green: 0.38, blue: 0.83) : Color(red: 0.92, green: 0.95, blue: 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func selectedStoreInfo(place: ConveniencePlace) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: place.kind.systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(place.kind.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(place.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                    .fixedSize(horizontal: false, vertical: true)

                Text(place.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var listTitle: String {
        if selectedPlace?.kind == .parkingLot {
            return "\(selectedDistance.title) 내 편의점"
        }
        if selectedPlace?.kind == .store {
            return "주변 주차장"
        }
        return "주변 편의점"
    }

    private var listBadgeText: String {
        if selectedPlace?.kind == .store {
            return "\(selectedDistance.title) \(displayPlaces.count)곳"
        }
        if selectedPlace?.kind == .parkingLot {
            return "\(selectedDistance.title) \(displayPlaces.count)곳"
        }
        return "편의점 \(displayPlaces.count)곳"
    }

    private var displayPlaces: [ConveniencePlace] {
        if let selectedPlace, selectedPlace.kind == .store {
            return parkingLots
                .filter { $0.coordinate.distance(from: selectedPlace.coordinate) <= selectedDistance.meters }
                .sortedByDistance(from: selectedPlace.coordinate)
        }

        if let selectedPlace, selectedPlace.kind == .parkingLot {
            return convenienceStores
                .filter { $0.coordinate.distance(from: selectedPlace.coordinate) <= selectedDistance.meters }
                .sortedByDistance(from: selectedPlace.coordinate)
        }

        return convenienceStores
    }

    private var mapPlaces: [ConveniencePlace] {
        if let selectedPlace, selectedPlace.kind == .parkingLot {
            return parkingLots + convenienceStores.filter { $0.coordinate.distance(from: selectedPlace.coordinate) <= selectedDistance.meters }
        }

        if let selectedPlace, selectedPlace.kind == .store {
            return convenienceStores + parkingLots.filter { $0.coordinate.distance(from: selectedPlace.coordinate) <= selectedDistance.meters }
        }

        return places
    }

    private var convenienceStores: [ConveniencePlace] {
        places.filter { $0.kind == .store }
    }

    private var parkingLots: [ConveniencePlace] {
        places.filter { $0.kind == .parkingLot }
    }

    private func select(_ place: ConveniencePlace) {
        if selectedPlace?.id == place.id {
            selectedPlace = nil
            withAnimation(.easeInOut) {
                region.center = ConveniencePlace.parkingCenter
                region.span = MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
            }
            return
        }

        selectedPlace = place
        withAnimation(.easeInOut) {
            region.center = place.coordinate
            region.span = place.kind == .parkingLot
                ? MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
                : MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        }
    }

    private func isHighlightedOnMap(_ place: ConveniencePlace) -> Bool {
        guard let selectedPlace else {
            return place.kind == .parkingLot
        }

        if selectedPlace.id == place.id {
            return true
        }

        if selectedPlace.kind == .store {
            return place.kind == .parkingLot
        }

        if selectedPlace.kind == .parkingLot {
            return place.kind == .store
        }

        return false
    }

    private func loadConvenienceStores() async {
        guard !isLoading else { return }

        isLoading = true
        message = "편의점 위치를 불러오는 중입니다."

        do {
            let stores = try await searchConvenienceStores()
            places = ConveniencePlace.parkingLots + stores
            message = stores.isEmpty ? "주변 편의점을 찾지 못했습니다." : ""
        } catch {
            places = ConveniencePlace.parkingLots + ConveniencePlace.fallbackStores
            message = "검색 연결 실패로 기본 편의점 위치를 표시합니다."
        }

        isLoading = false
    }

    private func searchConvenienceStores() async throws -> [ConveniencePlace] {
        let queries = ["편의점", "매점", "CU", "GS25", "세븐일레븐", "이마트24"]
        var combinedStores: [ConveniencePlace] = []
        var lastError: Error?

        for query in queries {
            do {
                let stores = try await searchPlaces(query: query)
                combinedStores.append(contentsOf: stores)
            } catch {
                lastError = error
            }
        }

        let uniqueStores = combinedStores.uniquedByLocationAndName()
            .sortedByDistance(from: ConveniencePlace.parkingCenter)
            .prefix(10)
            .map { $0 }

        if uniqueStores.isEmpty, let lastError {
            throw lastError
        }

        return uniqueStores
    }

    private func searchPlaces(query: String) async throws -> [ConveniencePlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: ConveniencePlace.parkingCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
        )
        request.resultTypes = .pointOfInterest

        return try await withCheckedThrowingContinuation { continuation in
            MKLocalSearch(request: request).start { response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let stores = response?.mapItems.compactMap { item -> ConveniencePlace? in
                    let coordinate = item.placemark.coordinate
                    let nearestParkingDistance = ConveniencePlace.parkingLots
                        .map { $0.coordinate.distance(from: coordinate) }
                        .min() ?? .greatestFiniteMagnitude

                    guard nearestParkingDistance <= 900 else {
                        return nil
                    }

                    let name = item.name ?? query
                    guard name.isConvenienceStoreName else {
                        return nil
                    }

                    return ConveniencePlace(
                        name: name,
                        address: item.placemark.title ?? "주소 정보 없음",
                        coordinate: coordinate,
                        kind: .store
                    )
                } ?? []

                continuation.resume(returning: stores)
            }
        }
    }
}

private struct PlaceResultRow: View {
    let place: ConveniencePlace
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: place.kind.systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: isSelected ? 40 : 34, height: isSelected ? 40 : 34)
                .background(place.kind.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font((isSelected ? Font.headline : Font.subheadline).weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                Text(place.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .background(isSelected ? Color(red: 0.92, green: 0.95, blue: 1.0) : Color(red: 0.97, green: 0.98, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private enum ConvenienceDistance: Int, CaseIterable, Identifiable {
    case fiveHundred = 500
    case threeHundred = 300
    case oneHundred = 100

    var id: Int { rawValue }
    var meters: Double { Double(rawValue) }
    var title: String { "\(rawValue)m" }
}

private struct ConveniencePlace: Identifiable, Equatable {
    enum Kind: Equatable {
        case parkingLot
        case store

        var color: Color {
            switch self {
            case .parkingLot:
                return Color(red: 0.16, green: 0.38, blue: 0.83)
            case .store:
                return Color(red: 0.06, green: 0.52, blue: 0.48)
            }
        }

        var systemImage: String {
            switch self {
            case .parkingLot:
                return "parkingsign.circle.fill"
            case .store:
                return "cart.fill"
            }
        }
    }

    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let kind: Kind

    static func == (lhs: ConveniencePlace, rhs: ConveniencePlace) -> Bool {
        lhs.id == rhs.id
    }

    var shortName: String {
        if name.contains("뚝섬") {
            return name.replacingOccurrences(of: "주차장", with: "")
        }
        return "편의점"
    }

    static let parkingCenter = CLLocationCoordinate2D(latitude: 37.5297, longitude: 127.0715)

    static let parkingLots: [ConveniencePlace] = [
        ConveniencePlace(
            name: "뚝섬1주차장",
            address: "서울 광진구 자양동 409",
            coordinate: CLLocationCoordinate2D(latitude: 37.5276908, longitude: 127.0781632),
            kind: .parkingLot
        ),
        ConveniencePlace(
            name: "뚝섬2주차장",
            address: "서울 광진구 자양동 427-1",
            coordinate: CLLocationCoordinate2D(latitude: 37.5290757, longitude: 127.0735242),
            kind: .parkingLot
        ),
        ConveniencePlace(
            name: "뚝섬3주차장",
            address: "서울 광진구 자양동 97-5",
            coordinate: CLLocationCoordinate2D(latitude: 37.5306712, longitude: 127.0673524),
            kind: .parkingLot
        ),
        ConveniencePlace(
            name: "뚝섬4주차장",
            address: "서울 광진구 자양동 97-5",
            coordinate: CLLocationCoordinate2D(latitude: 37.5314716, longitude: 127.0644017),
            kind: .parkingLot
        )
    ]

    static let fallbackStores: [ConveniencePlace] = [
        ConveniencePlace(
            name: "뚝섬유원지역 주변 편의점",
            address: "뚝섬유원지역 인근",
            coordinate: CLLocationCoordinate2D(latitude: 37.5314, longitude: 127.0665),
            kind: .store
        ),
        ConveniencePlace(
            name: "자양동 주변 편의점",
            address: "자양동 주차장 인근",
            coordinate: CLLocationCoordinate2D(latitude: 37.5293, longitude: 127.0742),
            kind: .store
        ),
        ConveniencePlace(
            name: "한강공원 입구 주변 편의점",
            address: "뚝섬 한강공원 입구 인근",
            coordinate: CLLocationCoordinate2D(latitude: 37.5279, longitude: 127.0775),
            kind: .store
        )
    ]
}

private extension Array where Element == ConveniencePlace {
    func sortedByDistance(from coordinate: CLLocationCoordinate2D) -> [ConveniencePlace] {
        sorted { lhs, rhs in
            lhs.coordinate.distance(from: coordinate) < rhs.coordinate.distance(from: coordinate)
        }
    }

    func uniquedByLocationAndName() -> [ConveniencePlace] {
        var seenKeys = Set<String>()
        var uniquePlaces: [ConveniencePlace] = []

        for place in self {
            let latitudeKey = Int((place.coordinate.latitude * 100_000).rounded())
            let longitudeKey = Int((place.coordinate.longitude * 100_000).rounded())
            let nameKey = place.name.replacingOccurrences(of: " ", with: "").lowercased()
            let key = "\(nameKey)-\(latitudeKey)-\(longitudeKey)"

            if seenKeys.insert(key).inserted {
                uniquePlaces.append(place)
            }
        }

        return uniquePlaces
    }
}

private extension String {
    var isConvenienceStoreName: Bool {
        let normalized = replacingOccurrences(of: " ", with: "").lowercased()
        let blockedKeywords = [
            "화장실", "toilet", "restroom", "wc", "공중화장실",
            "주차장", "parking", "자전거", "대여", "정류장", "역", "출구",
            "공원", "광장", "운동장", "놀이터", "수영장", "안내", "센터"
        ]

        if blockedKeywords.contains(where: { normalized.contains($0) }) {
            return false
        }

        let allowedKeywords = [
            "편의점", "매점", "cu", "씨유", "gs25", "gs", "지에스",
            "세븐일레븐", "7-eleven", "7eleven", "이마트24", "emart24", "미니스톱"
        ]

        return allowedKeywords.contains { normalized.contains($0) }
    }
}

private extension CLLocationCoordinate2D {
    func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        let current = CLLocation(latitude: latitude, longitude: longitude)
        let target = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return current.distance(from: target)
    }
}

#Preview {
    NavigationStack {
        ConvenienceMapView()
    }
}
