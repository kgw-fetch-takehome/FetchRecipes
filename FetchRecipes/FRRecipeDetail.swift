//
//  FRRecipeDetail.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import SwiftUI

private let placeholder = UIImage(named: "placeholder")!

class FRRecipeDetailViewModel: ObservableObject {
    @Published var recipe: FRRecipe?
    @Published var image: UIImage?
    @Binding var showingDetail: Bool
    
    init(recipe: FRRecipe?, showing: Binding<Bool>) {
        self.recipe = recipe
        self._showingDetail = showing
        Task {
            await loadImage()
        }
    }
    
    static func mock() -> FRRecipeDetailViewModel {
        let vm = FRRecipeDetailViewModel(recipe: .mock(), showing: .constant(true))
        return vm
    }
    
    @MainActor
    private func loadImage() {
        guard let url = recipe?.largePhotoURL else { return }
        Task {
            do {
                image = try await FRImageLoader.shared.loadImage(from: url)
            }
            catch {
                // Unable to load image - use placeholder
                image = placeholder
            }
        }
    }
}

struct FRRecipeDetail: View {
    
    @ObservedObject var viewModel: FRRecipeDetailViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.background(opacity:0.95))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onTapGesture {
                        // dismiss detail
                        withAnimation {
                            viewModel.showingDetail = false
                        }
                    }
                VStack {
                    Spacer()
                    Text(viewModel.recipe?.name ?? "")
                        .font(.title)
                        .fontWeight(.black)
                    Image(uiImage: viewModel.image ?? placeholder)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: geometry.size.height / 3)
                        .clipped()
                        .padding()
                    HStack(spacing: 20) {
                        if let url = viewModel.recipe?.sourceURL {
                            Button("Recipe Page") {
                                UIApplication.shared.open(url)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        if let video = viewModel.recipe?.videoURL {
                            Button("Video") {
                                UIApplication.shared.open(video)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    FRRecipeDetail(viewModel: FRRecipeDetailViewModel.mock())
}
