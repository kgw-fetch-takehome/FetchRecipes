//
//  FRErrorView.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import SwiftUI

struct FRErrorView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .scaleEffect(x: 4, y: 4, anchor: .center)
                .foregroundColor(.gray)
            Spacer()
                .frame(height:40)
            Text("There was an error loading recipes.")
                .font(.headline)
                .fontWeight(.medium)
            Text("Please try refreshing the list.")
                .font(.subheadline)
            Spacer()
        }
        .padding(.bottom)
    }
}

#Preview {
    FRErrorView()
}
