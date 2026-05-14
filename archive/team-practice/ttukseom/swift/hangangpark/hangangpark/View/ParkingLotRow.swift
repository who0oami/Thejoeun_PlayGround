//
//  ParkingLotRow.swift
//  hangangpark
//

import SwiftUI

struct ParkingLotRow: View {
    let lot: ParkingLotStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lot.parkinglotname)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

                    Text(lot.address.isEmpty ? "뚝섬 한강공원" : lot.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(lot.statusLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(lot.available)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))

                Text("대 남음")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("전체 \(lot.capacity)대")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: lot.occupancyRate)
                .tint(statusColor)
        }
        .padding(16)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var statusColor: Color {
        if lot.occupancyRate >= 0.8 {
            return .red
        }
        if lot.occupancyRate >= 0.5 {
            return .orange
        }
        return Color(red: 0.06, green: 0.52, blue: 0.48)
    }
}

#Preview {
    ParkingLotRow(
        lot: ParkingLotStatus(
            parkinglotname: "뚝섬 1주차장",
            address: "서울특별시 광진구",
            available: 42,
            capacity: 100,
            occupied: 58,
            occupancyRate: 0.58,
            statusLabel: "보통",
            latitude: 37.53,
            longitude: 127.07
        )
    )
    .padding()
    .background(Color(red: 0.95, green: 0.97, blue: 0.99))
}
