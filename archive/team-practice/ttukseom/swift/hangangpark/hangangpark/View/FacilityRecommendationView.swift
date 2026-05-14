//
//  FacilityRecommendationView.swift
//  hangangpark
//

import SafariServices
import SwiftUI

struct FacilityRecommendationView: View {
    @StateObject private var viewModel = FacilityRecommendationViewModel()
    @State private var selectedURL: URL?

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header

                    if viewModel.isLoading && viewModel.displayRecommendations.isEmpty {
                        ProgressView("연관 추천 정보를 불러오는 중...")
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    ForEach(viewModel.displayRecommendations) { facility in
                        FacilityRecommendationCard(facility: facility) {
                            selectedURL = facility.url
                        }
                    }

                    if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(22)
            }
        }
        .navigationTitle("연관 추천 정보")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .task {
            await viewModel.loadRecommendations()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("연관 추천 정보")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)

            Text("뚝섬한강공원의 주변 추천 정보입니다.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.86))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.11, green: 0.34, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct FacilityRecommendationCard: View {
    let facility: FacilityRecommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: iconName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color(red: 0.16, green: 0.38, blue: 0.83))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 7) {
                        Text(facility.title)
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)

                        Text(facility.displayDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    Label("Visit Seoul", systemImage: "link")
                    Spacer()
                    Text("자세히 보기")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(red: 0.16, green: 0.38, blue: 0.83))
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        if facility.title.contains("눈썰매") {
            return "snowflake"
        }
        if facility.title.contains("아리랑") {
            return "house.fill"
        }
        if facility.title.contains("한강공원") || facility.title.contains("유원지") {
            return "tree.fill"
        }
        return "star.fill"
    }
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    NavigationStack {
        FacilityRecommendationView()
    }
}
