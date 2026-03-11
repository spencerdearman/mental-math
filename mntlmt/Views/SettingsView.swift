import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Pass the user stats reference directly
    let userStats: UserStats
    
    // We bind to a local copy to allow immediate UI toggling,
    // then write back on dismiss or immediately
    @State private var localActiveCategories: Set<ProblemCategory> = []
    
    // Callback to tell GameEngine to reload config
    let onCategoriesUpdated: ([ProblemCategory]) -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 30) {
                
                HStack {
                    Text("Categories")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        saveAndDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(ProblemCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.rawValue)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(localActiveCategories.contains(category) ? .black : Color(white: 0.7))
                                
                                Spacer()
                                
                                if localActiveCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleCategory(category)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 40)
        }
        .onAppear {
            localActiveCategories = Set(userStats.activeCategories)
        }
    }
    
    private func toggleCategory(_ category: ProblemCategory) {
        if localActiveCategories.contains(category) {
            // Prevent removing the last category
            if localActiveCategories.count > 1 {
                localActiveCategories.remove(category)
            }
        } else {
            localActiveCategories.insert(category)
        }
    }
    
    private func saveAndDismiss() {
        let newCategories = Array(localActiveCategories)
        userStats.activeCategories = newCategories
        onCategoriesUpdated(newCategories)
        dismiss()
    }
}
