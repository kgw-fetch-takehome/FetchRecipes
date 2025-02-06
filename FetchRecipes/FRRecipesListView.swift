//
//  FRRecipesListView.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/5/25.
//

import SwiftUI

class FRRecipesListViewModel: ObservableObject {
    enum LoadingState {
        case loading
        case loaded
        case empty
        case error
        
        func isLoading() -> Bool {
            self == .loading
        }
        
        func isEmpty() -> Bool {
            self == .empty
        }
        
        func isError() -> Bool {
            self == .error
        }
    }
    
    fileprivate enum SortOrder {
        case name
        case cuisine
    }

    @Published var recipes: [FRRecipe] = []
    @Published var loadingState: LoadingState = .loading

    private var sortOrder = SortOrder.name
    
    @MainActor
    func refreshRecipeList() async {
        loadingState = .loading
        do {
            let newRecipes = try await FRRecipesService.fetchRecipes()
            recipes = sortRecipes(newRecipes)
            loadingState = newRecipes.isEmpty ? .empty : .loaded
        }
        catch {
            recipes = []
            loadingState = .error
        }
    }
    
    private func sortRecipes(_ recipes:[FRRecipe]) -> [FRRecipe] {
        recipes.sorted { (recipe1, recipe2) -> Bool in
            switch sortOrder {
            case .name:
                recipe1.name < recipe2.name
            case .cuisine:
                recipe1.cuisine < recipe2.cuisine
            }
        }
    }
    
    fileprivate func setSortOrder(_ sortBy:SortOrder) {
        sortOrder = sortBy
        recipes = sortRecipes(recipes)
    }
    
    static func mock() -> FRRecipesListViewModel {
        let vm = FRRecipesListViewModel()
        vm.recipes = (0..<10).map { _ in .mock() }
        return vm
    }
}

struct FRRecipesListView: View {
    
    @ObservedObject private var viewModel: FRRecipesListViewModel
    @State private var showingDetail = false
    @State private var expandedRecipe = ""
    
    init(viewModel: FRRecipesListViewModel = FRRecipesListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.recipes) { recipe in
                            FRRecipeCard(viewModel: FRRecipeCardViewModel(recipe: recipe))
                                .onTapGesture {
                                    expandedRecipe = recipe.uuid
                                    withAnimation {
                                        showingDetail = true
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Fetch Recipes")
            .navigationBarItems(
                trailing:
                    HStack {
                        Menu {
                            Button("Sort by Name") { viewModel.setSortOrder(.name) }
                            Button("Sort by Cuisine") { viewModel.setSortOrder(.cuisine) }
                        } label: {
                            Label("", systemImage: "arrow.up.arrow.down")
                        }
                        Button("", systemImage: "arrow.clockwise", action: {
                            Task {
                                await viewModel.refreshRecipeList()
                            }
                        })
                    }
            )
            .overlay {
                if viewModel.loadingState.isLoading() {
                    ZStack {
                        Color.background(opacity:0.8)
                        ProgressView()
                    }
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                }
            }
            .overlay {
                let detailRecipe = viewModel.recipes.first { $0.uuid == expandedRecipe }
                FRRecipeDetail(viewModel: FRRecipeDetailViewModel(recipe: detailRecipe, showing: $showingDetail))
                    .opacity(showingDetail ? 1 : 0)
            }
            .overlay {
                VStack(alignment: .center) {
                    FREmptyView()
                    Spacer()
                        .frame(height:80)
                }
                .opacity(viewModel.loadingState.isEmpty() ? 1 : 0)
            }
            .overlay {
                VStack(alignment: .center) {
                    FRErrorView()
                    Spacer()
                        .frame(height:80)
                }
                .opacity(viewModel.loadingState.isError() ? 1 : 0)
            }
        }
        .onAppear() {
            Task {
                await viewModel.refreshRecipeList()
            }
        }
    }
}

#Preview {
    FRRecipesListView(viewModel: .mock())
}
