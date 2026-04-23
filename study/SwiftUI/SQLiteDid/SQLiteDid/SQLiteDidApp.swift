//
//  SQLiteDidApp.swift
//  SQLiteDid
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

@main
struct SQLiteDidApp: App {
    @StateObject private var todoDB = TodoDB()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoDB)
        }
    }
}
