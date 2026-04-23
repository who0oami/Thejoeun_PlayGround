//
//  TodoDB.swift
//  SQLiteDid
//
//  Created by electrozone on 3/31/26.
//

import SQLite3
import Combine
import SwiftUI

class TodoDB: ObservableObject {
    var db: OpaquePointer?
    @Published var todoList: [Todo] = []

    init() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("todo.db")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        createTableIfNeeded()
        loadTodo()
    }

    deinit {
        sqlite3_close(db)
    }

    func loadTodo() {
        todoList = queryDB()
    }

    private func createTableIfNeeded() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS todo (
            sid INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            priority INTEGER NOT NULL DEFAULT 0
        )
        """

        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table : \(errMsg)")
        }

        addColumnIfNeeded(name: "is_completed", definition: "INTEGER NOT NULL DEFAULT 0")
        addColumnIfNeeded(name: "priority", definition: "INTEGER NOT NULL DEFAULT 0")
        normalizePrioritiesIfNeeded()
    }

    private func addColumnIfNeeded(name: String, definition: String) {
        let queryString = "PRAGMA table_info(todo)"
        var stmt: OpaquePointer?
        var hasColumn = false

        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let columnName = sqlite3_column_text(stmt, 1),
                   String(cString: columnName) == name {
                    hasColumn = true
                    break
                }
            }
        }

        sqlite3_finalize(stmt)

        guard !hasColumn else { return }

        let alterQuery = "ALTER TABLE todo ADD COLUMN \(name) \(definition)"
        if sqlite3_exec(db, alterQuery, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error altering table : \(errMsg)")
        }
    }

    private func normalizePrioritiesIfNeeded() {
        let countQuery = "SELECT COUNT(*) FROM todo WHERE priority = 0"
        var stmt: OpaquePointer?
        var zeroPriorityCount = 0

        if sqlite3_prepare_v2(db, countQuery, -1, &stmt, nil) == SQLITE_OK,
           sqlite3_step(stmt) == SQLITE_ROW {
            zeroPriorityCount = Int(sqlite3_column_int(stmt, 0))
        }
        sqlite3_finalize(stmt)

        guard zeroPriorityCount > 0 else { return }

        let idsQuery = "SELECT sid FROM todo ORDER BY sid"
        var idsStmt: OpaquePointer?
        var ids: [Int] = []

        if sqlite3_prepare_v2(db, idsQuery, -1, &idsStmt, nil) == SQLITE_OK {
            while sqlite3_step(idsStmt) == SQLITE_ROW {
                ids.append(Int(sqlite3_column_int(idsStmt, 0)))
            }
        }
        sqlite3_finalize(idsStmt)

        for (index, id) in ids.enumerated() {
            _ = updatePriority(id: id, priority: index, shouldReload: false)
        }
    }

    func insertDB(content: String) -> Bool {
        var stmt: OpaquePointer?
        let queryString = "INSERT INTO todo (content, is_completed, priority) VALUES (?, 0, ?)"
        let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let nextPriority = todoList.count

        sqlite3_prepare_v2(db, queryString, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, content, -1, sqliteTransient)
        sqlite3_bind_int(stmt, 2, Int32(nextPriority))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)

        if result {
            loadTodo()
        }

        return result
    }

    func queryDB() -> [Todo] {
        var stmt: OpaquePointer?
        let queryString = "SELECT sid, content, is_completed, priority FROM todo ORDER BY priority, sid"
        var fetchedList: [Todo] = []

        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select : \(errMsg)")
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let content = String(cString: sqlite3_column_text(stmt, 1))
            let isCompleted = sqlite3_column_int(stmt, 2) == 1
            let priority = Int(sqlite3_column_int(stmt, 3))

            fetchedList.append(Todo(id: id, content: content, isCompleted: isCompleted, priority: priority))
        }

        sqlite3_finalize(stmt)
        return fetchedList
    }

    func deleteDB(id: Int) -> Bool {
        var stmt: OpaquePointer?
        let queryString = "DELETE FROM todo WHERE sid = ?"

        sqlite3_prepare_v2(db, queryString, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, Int32(id))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)

        if result {
            resequencePriorities()
            loadTodo()
        }

        return result
    }

    func updateDB(id: Int, content: String) -> Bool {
        var stmt: OpaquePointer?
        let queryString = "UPDATE todo SET content = ? WHERE sid = ?"
        let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        sqlite3_prepare_v2(db, queryString, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, content, -1, sqliteTransient)
        sqlite3_bind_int(stmt, 2, Int32(id))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)

        if result {
            loadTodo()
        }

        return result
    }

    func updateCompletion(id: Int, isCompleted: Bool) -> Bool {
        var stmt: OpaquePointer?
        let queryString = "UPDATE todo SET is_completed = ? WHERE sid = ?"

        sqlite3_prepare_v2(db, queryString, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, isCompleted ? 1 : 0)
        sqlite3_bind_int(stmt, 2, Int32(id))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)

        if result {
            loadTodo()
        }

        return result
    }

    func moveTodo(from source: IndexSet, to destination: Int) {
        var reordered = todoList
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, todo) in reordered.enumerated() {
            _ = updatePriority(id: todo.id, priority: index, shouldReload: false)
        }

        loadTodo()
    }

    private func resequencePriorities() {
        let todos = queryDB()
        for (index, todo) in todos.enumerated() {
            _ = updatePriority(id: todo.id, priority: index, shouldReload: false)
        }
    }

    private func updatePriority(id: Int, priority: Int, shouldReload: Bool) -> Bool {
        var stmt: OpaquePointer?
        let queryString = "UPDATE todo SET priority = ? WHERE sid = ?"

        sqlite3_prepare_v2(db, queryString, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, Int32(priority))
        sqlite3_bind_int(stmt, 2, Int32(id))

        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)

        if result && shouldReload {
            loadTodo()
        }

        return result
    }
}
