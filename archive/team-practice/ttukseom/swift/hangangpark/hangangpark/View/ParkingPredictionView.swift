//
//  ParkingPredictionView.swift
//  hangangpark
//

import SwiftUI

struct ParkingPredictionView: View {
    @ObservedObject var viewModel: ParkingStatusViewModel

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    hourSelector
                    predictionList
                }
                .padding(22)
            }
        }
        .navigationTitle("잔여 대수 예측")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1~8시간 뒤 예측")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)

            Text("ML 모델 연결 전까지는 현재 주차가능대수 기준 임시 예측을 표시합니다.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.86))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.11, green: 0.34, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var hourSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예측 시간")
                .font(.headline)
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

            Picker("예측 시간", selection: $viewModel.selectedPredictionHour) {
                ForEach(viewModel.predictionHours, id: \.self) { hour in
                    Text("\(hour)시간").tag(hour)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    private var predictionList: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("예측 잔여 대수")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

                Spacer()

                Text("총 \(viewModel.predictedTotalAvailable)대")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.06, green: 0.52, blue: 0.48))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.89, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            ForEach(viewModel.displayParkingLots) { lot in
                PredictionLotRow(
                    lot: lot,
                    hour: viewModel.selectedPredictionHour,
                    predictedAvailable: viewModel.predictedAvailable(for: lot)
                )
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

private struct PredictionLotRow: View {
    let lot: ParkingLotStatus
    let hour: Int
    let predictedAvailable: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(lot.parkinglotname)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                Text("현재 \(lot.available)대 -> \(hour)시간 뒤")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(predictedAvailable)대")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))
        }
        .padding(14)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        ParkingPredictionView(viewModel: ParkingStatusViewModel())
    }
}
