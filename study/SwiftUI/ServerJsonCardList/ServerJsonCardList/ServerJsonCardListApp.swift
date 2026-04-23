//
//  ServerJsonCardListApp.swift
//  ServerJsonCardList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

@main
struct ServerJsonCardListApp: App {
    @StateObject private var viewModel = NewsCardListViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("News", systemImage: "newspaper")
                    }

                QueryView()
                    .tabItem {
                        Label("Query", systemImage: "magnifyingglass")
                    }
            }
            .tint(.white)
            .environmentObject(viewModel)
        }
    }
}
