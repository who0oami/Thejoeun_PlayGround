//
//  Quiz15App.swift
//  Quiz15
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

@main
struct Quiz15_reApp: App {
    @StateObject private var lampSettings = LampSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lampSettings)
        }
    }
}
