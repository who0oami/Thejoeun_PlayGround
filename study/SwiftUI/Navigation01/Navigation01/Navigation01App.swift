//
//  NavigationApp.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

@main
struct Navigation02App: App {
    @StateObject private var lampDAta = LampData() //******
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lampData)
        }
    }
}
