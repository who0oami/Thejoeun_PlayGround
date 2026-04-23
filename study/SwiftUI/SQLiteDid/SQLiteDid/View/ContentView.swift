//
//  ContentView.swift
//  SQLiteDid
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var todoDB: TodoDB
    @Environment(\.editMode) private var editMode
    @State private var isPresentingAddView = false
    @State private var selectedTodo: Todo?

    var body: some View {
        NavigationStack {
            List {
                ForEach(todoDB.todoList) { todo in
                    if isEditing {
                        TodoRowView(todo: todo)
                    } else {
                        Button {
                            selectedTodo = todo
                        } label: {
                            TodoRowView(todo: todo)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete(perform: deleteTodo)
                .onMove(perform: moveTodo)
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddView) {
                AddTodoView()
            }
            .sheet(item: $selectedTodo) { todo in
                NavigationStack {
                    TodoDetailView(todo: todo)
                }
            }
        }
    }

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    private func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            _ = todoDB.deleteDB(id: todoDB.todoList[index].id)
        }
    }

    private func moveTodo(from source: IndexSet, to destination: Int) {
        todoDB.moveTodo(from: source, to: destination)
    }
}

private struct TodoRowView: View {
    let todo: Todo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: todo.isCompleted ? "eraser.fill" : "eraser")
                .foregroundStyle(todo.isCompleted ? .red : .secondary)
                .font(.title3)

            Text(todo.content)
                .foregroundStyle(todo.isCompleted ? .red : .primary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var todoDB: TodoDB
    @State private var content = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 14) {
                    Text("Todo List")
                        .font(.title2.bold())

                    Text("추가할 내용을 입력하세요")
                        .foregroundStyle(.secondary)

                    TextField("할일을 입력하세요", text: $content)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 24) {
                        Button("취소") {
                            dismiss()
                        }
                        .foregroundStyle(.secondary)

                        Button("추가") {
                            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            if todoDB.insertDB(content: trimmed) {
                                dismiss()
                            }
                        }
                        .fontWeight(.semibold)
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .frame(maxWidth: 280)

                Spacer()
            }
            .padding()
        }
    }
}

private struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var todoDB: TodoDB
    let todo: Todo
    @State private var content: String

    init(todo: Todo) {
        self.todo = todo
        _content = State(initialValue: todo.content)
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                Text("Todo List")
                    .font(.title2.bold())

                Text("TodoList를 수정하거나 작업 완료를 선택 하세요")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("할일을 입력하세요", text: $content)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 24) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)

                    Button("수정") {
                        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        if todoDB.updateDB(id: todo.id, content: trimmed) {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)

                    Button("완료") {
                        _ = todoDB.updateCompletion(id: todo.id, isCompleted: true)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: 280)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoDB())
}
