//
//  ParkingStatusView.swift
//  hangangpark
//

import SwiftUI

struct ParkingStatusView: View {
    let session: UserSession
    let onLogout: () -> Void

    @StateObject private var viewModel = ParkingStatusViewModel()
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        currentSummary(proxy: proxy)
                        currentParkingSection
                            .id("currentParkingSection")
                        actionButtons

                        if !viewModel.message.isEmpty {
                            Text(viewModel.message)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("로그아웃", action: onLogout)
                    .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.loadParkingLots() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            await viewModel.loadParkingLots()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("뚝섬 한강공원")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)

                    Text("현재 주차가능대수")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.88))
                }

                Spacer()

                Image(systemName: "car.2.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(Color.white.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text("로그인 계정: \(session.email)")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.11, green: 0.34, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func currentSummary(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 12) {
            NavigationLink {
                NoticeView()
            } label: {
                SummaryCard(
                    title: "공지사항",
                    value: "공지",
                    systemImage: "megaphone.fill",
                    iconColor: .white,
                    iconBackgroundColor: Color(red: 0.88, green: 0.18, blue: 0.18)
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                Button {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo("currentParkingSection", anchor: .top)
                    }
                } label: {
                    SummaryCard(title: "현재 잔여", value: "\(viewModel.totalAvailable)대", systemImage: "parkingsign.circle.fill")
                }
                .buttonStyle(.plain)

                SummaryCard(title: "조회 구역", value: "4곳", systemImage: "mappin.and.ellipse")
            }
        }
    }

    private var currentParkingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("현재 잔여 대수")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                    Text("한강공원 주차 페이지의 주차가능대수를 가져옵니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(viewModel.isLoading ? "업데이트 중" : "실시간")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.06, green: 0.52, blue: 0.48))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.89, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            ForEach(viewModel.displayParkingLots) { lot in
                ParkingLotRow(lot: lot)
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink {
                ParkingPredictionView(viewModel: viewModel)
            } label: {
                PredictionActionButtonLabel()
            }
            .buttonStyle(.plain)

            NavigationLink {
                ConvenienceMapView()
            } label: {
                MainActionButtonLabel(
                    title: "주변 편의점 찾아보기",
                    subtitle: "지도 화면에서 가까운 편의점을 확인하세요.",
                    systemImage: "map.fill",
                    color: Color(red: 0.06, green: 0.52, blue: 0.48)
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                FacilityRecommendationView()
            } label: {
                MainActionButtonLabel(
                    title: "연관 추천 정보",
                    subtitle: "뚝섬 한강공원 연관 추천 정보를 확인하세요.",
                    systemImage: "calendar.badge.plus",
                    color: Color(red: 0.35, green: 0.42, blue: 0.56)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let systemImage: String
    var iconColor = Color(red: 0.16, green: 0.38, blue: 0.83)
    var iconBackgroundColor = Color(red: 0.92, green: 0.95, blue: 1.0)

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(iconColor)
                .frame(width: 38, height: 38)
                .background(iconBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

private struct PredictionActionButtonLabel: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text("잔여 대수 예측하기")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text("1~8시간 뒤 주차장별 여유 공간을 미리 확인하세요.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white.opacity(0.86))
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.16, green: 0.38, blue: 0.83))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color(red: 0.16, green: 0.38, blue: 0.83).opacity(0.24), radius: 16, x: 0, y: 8)
    }
}

private struct MainActionButtonLabel: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        ParkingStatusView(
            session: UserSession(userid: 1, useremail: "user@example.com", userage: 24, usersex: 1),
            onLogout: {}
        )
    }
}
