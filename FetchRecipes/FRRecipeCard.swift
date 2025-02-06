//
//  FRRecipeCard.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import SwiftUI

private let placeholder = UIImage(named: "placeholder")!

class FRRecipeCardViewModel: ObservableObject {
    @Published var recipe: FRRecipe
    @Published var smallImage: UIImage?
    
    init(recipe: FRRecipe) {
        self.recipe = recipe
        Task {
            await loadSmallImage()
        }
    }
    
    static func mock(expanded: Bool = false) -> FRRecipeCardViewModel {
        let vm = FRRecipeCardViewModel(recipe: .mock())
        return vm
    }
    
    @MainActor
    private func loadSmallImage() {
        guard let url = recipe.smallPhotoURL else { return }
        Task {
            do {
                let image = try await FRImageLoader.shared.loadImage(from: url)
                smallImage = image
            }
            catch {
                // Unable to load image - use placeholder
                smallImage = placeholder
            }
        }
    }
}

struct FRRecipeCard: View {
    @ObservedObject var viewModel: FRRecipeCardViewModel
    
    init(viewModel: FRRecipeCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Image(uiImage: viewModel.smallImage ?? placeholder)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
            VStack(alignment: .leading) {
                Text(viewModel.recipe.name)
                    .font(.title)
                Text(viewModel.recipe.cuisine)
                    .font(.subheadline)
                Spacer()
            }
            .padding(4)
        }
    }
}

#Preview("Normal", traits: .sizeThatFitsLayout, .fixedLayout(width: 320, height: 100)) {
    FRRecipeCard(viewModel: .mock())
}

#Preview("Expanded", traits: .sizeThatFitsLayout, .fixedLayout(width: 320, height: 320)) {
    FRRecipeCard(viewModel: .mock(expanded: true))
}

#Preview("Dark", traits: .sizeThatFitsLayout, .fixedLayout(width: 320, height: 100)) {
    FRRecipeCard(viewModel: .mock())
        .preferredColorScheme(.dark)
}

#Preview("Large Text", traits: .sizeThatFitsLayout, .fixedLayout(width: 320, height: 100)) {
    FRRecipeCard(viewModel: .mock())
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
