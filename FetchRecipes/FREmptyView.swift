//
//  FREmptyView.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import SwiftUI

struct FREmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "questionmark.app.dashed")
                .scaleEffect(x: 4, y: 4, anchor: .center)
                .foregroundColor(.gray)
            Spacer()
                .frame(height:40)
            Text("There are no recipes to display.")
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
    FREmptyView()
}
