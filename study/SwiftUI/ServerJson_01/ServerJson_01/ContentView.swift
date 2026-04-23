//
//  ContentView.swift
//  ServerJson_01
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var tableTitle = "학생 테이블"
    @State private var students: [StudentRow] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    ContentUnavailableView(
                        "불러오기에 실패했습니다",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if students.isEmpty {
                    ProgressView("불러오는 중...")
                } else {
                    List(students) { student in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(student.name)
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(student.middleText)
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Text(student.studentID)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(tableTitle)
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadStudents()
        }
    }

    private func loadStudents() async {
        guard students.isEmpty else { return }

        do {
            let url = URL(string: "https://zeushahn.github.io/Test/ios/student.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let payload = try JSONSerialization.jsonObject(with: data)
            let parsed = StudentParser.parse(payload)
            
            await MainActor.run {
                tableTitle = parsed.title
                students = parsed.students

                if students.isEmpty {
                    errorMessage = "표시할 학생 데이터가 없습니다."
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct StudentRow: Identifiable {
    let id = UUID()
    let name: String
    let middleText: String
    let studentID: String
}

private enum StudentParser {
    nonisolated static func parse(_ payload: Any) -> (title: String, students: [StudentRow]) {
        if let dictionary = payload as? [String: Any] {
            let title = stringValue(
                in: dictionary,
                matching: ["title", "table", "tableName", "name", "테이블명", "제목"]
            ) ?? "학생 테이블"

            if let rows = dictionary["students"] as? [[String: Any]]
                ?? dictionary["data"] as? [[String: Any]]
                ?? dictionary["items"] as? [[String: Any]] {
                return (title, rows.compactMap(student(from:)))
            }

            if let row = dictionary["student"] as? [String: Any] {
                return (title, [student(from: row)].compactMap { $0 })
            }
        }

        if let rows = payload as? [[String: Any]] {
            return ("학생 테이블", rows.compactMap(student(from:)))
        }

        return ("학생 테이블", [])
    }

    nonisolated private static func student(from dictionary: [String: Any]) -> StudentRow? {
        let name = stringValue(in: dictionary, matching: ["name", "studentName", "이름"])
        let middleText = stringValue(
            in: dictionary,
            matching: ["middle", "middleText", "description", "text", "중간글자", "중간"]
        )
        let studentID = stringValue(
            in: dictionary,
            matching: ["id", "studentID", "studentId", "studentNo", "studentNum", "number", "num", "학번", "hakbun"]
        )

        guard let name else { return nil }

        return StudentRow(
            name: name,
            middleText: middleText ?? "",
            studentID: studentID ?? ""
        )
    }

    nonisolated private static func stringValue(in dictionary: [String: Any], matching keys: [String]) -> String? {
        for key in keys {
            if let value = textValue(from: dictionary[key]), !value.isEmpty {
                return value
            }
        }

        for (key, value) in dictionary {
            guard let string = textValue(from: value), !string.isEmpty else { continue }
            if keys.contains(where: { normalized(key).contains(normalized($0)) }) {
                return string
            }
        }

        return nil
    }

    nonisolated private static func textValue(from value: Any?) -> String? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    nonisolated private static func normalized(_ value: String) -> String {
        value.replacingOccurrences(of: "_", with: "").lowercased()
    }
}

#Preview {
    ContentView()
}
