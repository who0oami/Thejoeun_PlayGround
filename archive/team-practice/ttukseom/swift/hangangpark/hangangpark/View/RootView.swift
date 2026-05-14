//
//  RootView.swift
//  hangangpark
//

import SwiftUI

struct RootView: View {
    @State private var session: UserSession?

    var body: some View {
        Group {
            if let session {
                NavigationStack {
                    ParkingStatusView(session: session) {
                        withAnimation(.easeInOut) {
                            self.session = nil
                        }
                    }
                }
                .transition(.opacity)
            } else {
                NavigationStack {
                    AuthView { session in
                        withAnimation(.easeInOut) {
                            self.session = session
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: session?.userid)
    }
}

#Preview {
    RootView()
}
