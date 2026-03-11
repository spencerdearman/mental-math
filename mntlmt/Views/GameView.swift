import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allStats: [UserStats]
    
    @State private var engine = GameEngine()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    // Equation display
                    if let problem = engine.currentProblem {
                        VStack(spacing: 20) {
                            if let lines = problem.displayLines, lines.count > 1 {
                                // Vertical Stack
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text(lines[0])
                                        .font(.largeTitle).fontWeight(.medium)
                                    
                                    Text(lines[1])
                                        .font(.largeTitle).fontWeight(.medium)
                                        .padding(.bottom, 8)
                                        .background(
                                            Rectangle()
                                                .frame(height: 2)
                                                .padding(.top, 56)
                                            , alignment: .bottom
                                        )
                                }
                                .foregroundStyle(.primary)
                            } else {
                                // Horizontal Math
                                Text(problem.text)
                                    .font(.largeTitle).fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            
                            // User input text field mock
                            Text(engine.currentInput)
                                .font(.largeTitle).fontWeight(.regular)
                                .foregroundColor(engine.currentInput.isEmpty ? .clear : .primary)
                                .frame(minWidth: 60, minHeight: 65)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .glassEffect(.regular, in: .rect(cornerRadius: 16))
                                .tint((engine.currentProblem != nil && engine.currentInput.count == engine.currentProblem!.expectedAnswer.count) ? Color.yellow : Color.clear)
                        }
                        .id(problem.text)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    Spacer()
                                        
                    NumpadView(engine: engine)
                        .padding(.bottom, 40)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: engine.currentProblem?.text)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            engine.forceSubmit()
                        }
                    }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "circle.grid.2x2")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(engine.totalCorrectSession)")
                                .foregroundColor(.green)
                        }
                        .font(.system(size: 14, weight: .medium))
                        
                        Text("\(engine.problemsSolvedInSession + 1) / \(engine.totalProblemsPerSession)")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("\(engine.totalIncorrectSession)")
                                .foregroundColor(.red)
                        }
                        .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .glassEffect(.regular.interactive(), in: .capsule)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        engine.skipProblem()
                    } label: {
                        Label("Skip", systemImage: "arrow.forward")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                if let stats = allStats.first {
                    SettingsView(userStats: stats) { newCategories in
                        engine.activeCategories = newCategories
                    }
                }
            }
            .onAppear {
                setupEngineContext()
            }
        }
    } // Closes body
    
    // MARK: - Private Methods
    
    private func setupEngineContext() {
        setupEngineSaveCallback()
        
        // Load initial categories
        if let stats = allStats.first {
            engine.activeCategories = stats.activeCategories
        } else {
            let initialStats = UserStats()
            modelContext.insert(initialStats)
            engine.activeCategories = initialStats.activeCategories
        }
    }
    
    private func setupEngineSaveCallback() {
        engine.onProblemSolved = {
            let currentStats: UserStats
            if let existing = allStats.first {
                currentStats = existing
            } else {
                currentStats = UserStats(dailyStreak: 0, totalProblemsSolved: 0, lastPlayedDate: Date())
                modelContext.insert(currentStats)
            }
            
            currentStats.totalProblemsSolved += 1
            
            // Basic daily streak tracking
            let calendar = Calendar.current
            if !calendar.isDateInToday(currentStats.lastPlayedDate) {
                if calendar.isDateInYesterday(currentStats.lastPlayedDate) {
                    currentStats.dailyStreak += 1
                } else {
                    currentStats.dailyStreak = 1
                }
                currentStats.lastPlayedDate = Date()
            }
        }
    }
}
