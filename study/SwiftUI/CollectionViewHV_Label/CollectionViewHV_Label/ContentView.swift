//
//  ContentView.swift
//  CollectionViewHV_Label
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var verticalCharacters: [String] = CharacterSeed.people
    @State private var horizontalCharacters: [String] = CharacterSeed.people

    private let verticalColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let horizontalRows = [
        GridItem(.fixed(60))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("위쪽 인물 목록")
                            .font(.title3.weight(.bold))

                        LazyVGrid(columns: verticalColumns, spacing: 12) {
                            ForEach(verticalCharacters, id: \.self) { character in
                                NavigationLink {
                                    CharacterDetailView(
                                        name: character,
                                        sectionTitle: "위쪽 VGrid"
                                    )
                                } label: {
                                    CharacterCell(name: character, color: .blue.opacity(0.16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("아래쪽 인물 목록")
                            .font(.title3.weight(.bold))

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: horizontalRows, spacing: 12) {
                                ForEach(horizontalCharacters, id: \.self) { character in
                                    NavigationLink {
                                        CharacterDetailView(
                                            name: character,
                                            sectionTitle: "아래쪽 HGrid"
                                        )
                                    } label: {
                                        CharacterCell(name: character, color: .orange.opacity(0.18))
                                            .frame(width: 120)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .frame(height: 60)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("삼국지 인물")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddCharacterView(
                            verticalCharacters: $verticalCharacters,
                            horizontalCharacters: $horizontalCharacters
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

private struct AddCharacterView: View {
    @Binding var verticalCharacters: [String]
    @Binding var horizontalCharacters: [String]

    @Environment(\.dismiss) private var dismiss
    @State private var newCharacter = ""
    @State private var selectedSection: GridSection = .vertical
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        Form {
            Section("인물 추가") {
                TextField("인물 이름", text: $newCharacter)

                Picker("추가 위치", selection: $selectedSection) {
                    ForEach(GridSection.allCases) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("저장") {
                    saveCharacter()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("인물 추가")
        .navigationBarTitleDisplayMode(.inline)
        .alert("추가할 수 없음", isPresented: $showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveCharacter() {
        let trimmedName = newCharacter.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "인물 이름을 입력하세요."
            showError = true
            return
        }

        if verticalCharacters.contains(trimmedName) || horizontalCharacters.contains(trimmedName) {
            errorMessage = "이미 존재하는 인물입니다."
            showError = true
            return
        }

        switch selectedSection {
        case .vertical:
            verticalCharacters.append(trimmedName)
        case .horizontal:
            horizontalCharacters.append(trimmedName)
        }

        dismiss()
    }
}

private struct CharacterDetailView: View {
    let name: String
    let sectionTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(name)
                .font(.largeTitle.weight(.bold))

            Text(sectionTitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(CharacterSeed.description(for: name))
                .font(.body)
                .lineSpacing(6)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle("인물 디테일")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum GridSection: String, CaseIterable, Identifiable {
    case vertical
    case horizontal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vertical:
            return "위쪽"
        case .horizontal:
            return "아래쪽"
        }
    }
}

private enum CharacterSeed {
    static let people = ["유비", "관우", "장비", "조조", "여포", "동탁", "초선", "손견"]

    static func description(for name: String) -> String {
        switch name {
        case "유비":
            return "촉한의 초대 황제로 인의와 명분을 중시한 인물입니다."
        case "관우":
            return "유비를 따르던 장수로 충의의 상징처럼 알려진 인물입니다."
        case "장비":
            return "호방한 성격과 강한 무력으로 이름을 남긴 촉의 장수입니다."
        case "조조":
            return "위나라의 기반을 세운 정치가이자 뛰어난 전략가입니다."
        case "여포":
            return "압도적인 무력으로 유명했지만 여러 세력을 옮겨 다닌 인물입니다."
        case "동탁":
            return "후한 말 권력을 장악하며 혼란을 키운 군벌입니다."
        case "초선":
            return "삼국지 이야기에서 미인계와 함께 자주 언급되는 인물입니다."
        case "손견":
            return "오나라 세력의 기틀을 닦은 용맹한 장수입니다."
        default:
            return "\(name)은(는) 사용자가 추가한 삼국지 인물입니다."
        }
    }
}

private struct CharacterCell: View {
    let name: String
    let color: Color

    var body: some View {
        Text(name)
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
    }
}

#Preview {
    ContentView()
}
