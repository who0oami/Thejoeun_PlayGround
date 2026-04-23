//
//  UserLocationAnnotationView.swift
//  Map
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct UserLocationAnnotationView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.blue, .white)

            Text("현재 위치")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
        }
    }
}

#Preview {
    UserLocationAnnotationView()
}
