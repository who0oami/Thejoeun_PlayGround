//
//  NoticeView.swift
//  hangangpark
//

import SwiftUI

struct NoticeView: View {
    @StateObject private var viewModel = NoticeViewModel()

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if viewModel.isLoading {
                        ProgressView("공지사항을 불러오는 중...")
                            .frame(maxWidth: .infinity)
                            .padding(28)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    ForEach(viewModel.notices) { notice in
                        NoticeCard(notice: notice)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("공지사항")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.loadNotices() }
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
            await viewModel.loadNotices()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공지사항")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))

            Text("뚝섬 한강공원 이용 안내를 최신순으로 알려드려요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct NoticeCard: View {
    let notice: Notice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        if notice.isImportant {
                            Text("중요")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.88, green: 0.18, blue: 0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Text(notice.createdAt.formatted(date: .numeric, time: .omitted))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Text(notice.title)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.22))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Text(notice.content)
                .font(.subheadline)
                .lineSpacing(4)
                .foregroundStyle(Color(red: 0.30, green: 0.34, blue: 0.42))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        NoticeView()
    }
}
