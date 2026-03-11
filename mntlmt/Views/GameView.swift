import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allStats: [UserStats]
    
    @State private var engine = GameEngine()
    @State private var showingSettings = false
    @State private var showingStats = false
    @State private var showingMenu = false
    
    @State private var timeAttackTimer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    // Equation display OR Summary display
                    if engine.isSessionComplete {
                        summaryView
                            .transition(.opacity)
                    } else if let problem = engine.currentProblem {
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
                                .font(.largeTitle).fontWeight(.medium)
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
                    
                    if !engine.isSessionComplete {
                        NumpadView(engine: engine)
                            .padding(.bottom, 40)
                            .transition(.opacity)
                    } else {
                        Spacer().frame(height: 100)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: engine.currentProblem?.text)
                .animation(.easeInOut(duration: 0.5), value: engine.isSessionComplete)
            }
            .overlay(alignment: .top) {
                if !engine.isSessionComplete {
                    ZStack(alignment: .top) {
                        // Invisible background to dismiss the menu
                        if showingMenu {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showingMenu = false
                                    }
                                }
                        }
                        
                        // The Dynamic Island Morphing Container
                        VStack(spacing: 0) {
                            // Always visible Header (The Pill Content)
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    showingMenu.toggle()
                                }
                            } label: {
                                sessionStatsContent
                                    .padding(.horizontal, showingMenu ? 20 : 16)
                            }
                            .buttonStyle(.plain)
                            .frame(height: 48) // Fixed height prevents jitter
                            
                            // Expanding Menu Items (Height animated, clipped by parent)
                            VStack(spacing: 0) {
                                Divider().padding(.horizontal, 16)
                                
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showingMenu = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        engine.endSession()
                                    }
                                } label: {
                                    HStack {
                                        Text("End Game")
                                        Spacer()
                                        Image(systemName: "flag.checkered")
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .contentShape(Rectangle())
                                }
                                
                                Divider().padding(.horizontal, 16)
                                
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showingMenu = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        showingStats = true
                                    }
                                } label: {
                                    HStack {
                                        Text("Show Analytics")
                                        Spacer()
                                        Image(systemName: "chart.xyaxis.line")
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .contentShape(Rectangle())
                                }
                            }
                            .frame(height: showingMenu ? 100 : 0) // Controls the stretch
                            .opacity(showingMenu ? 1 : 0) // Smooth text fade
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: showingMenu ? 240 : 180)
                        .background(
                            Color.clear
                                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: showingMenu ? 32 : 24, style: .continuous))
                        )
                        // Clip shape guarantees inner text does not bleed outside the glassy background during animation
                        .clipShape(RoundedRectangle(cornerRadius: showingMenu ? 32 : 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: showingMenu ? 20 : 5, x: 0, y: showingMenu ? 10 : 2)
                        // Offset pulls the overlay directly into the system toolbar space
//                        .offset(y: -50)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showingMenu)
                    }
                    .zIndex(1)
                }
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
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                // .principal placement remains empty to allow overlay offset to fill the space
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !engine.isSessionComplete {
                        Button {
                            engine.skipProblem()
                        } label: {
                            Label("Skip", systemImage: "arrow.forward")
                        }
                    } else {
                        Button {
                            showingStats = true
                        } label: {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                if let stats = allStats.first {
                    SettingsView(userStats: stats) { newCategories, newMode in
                        engine.activeCategories = newCategories
                        engine.gameMode = newMode
                        engine.sessionLength = stats.sessionLength
                        engine.timeAttackDuration = stats.timeAttackDuration
                        engine.hapticsEnabled = stats.hapticsEnabled
                        startNewSession()
                    }
                    .presentationDetents([.large])
                }
            }
            .sheet(isPresented: $showingStats) {
                if let stats = allStats.first {
                    StatsView(sessionLogs: stats.sessionLogs)
                }
            }
            .onAppear {
                setupEngineContext()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupEngineContext() {
        setupEngineSaveCallback()
        
        if let stats = allStats.first {
            engine.activeCategories = stats.activeCategories
            engine.sessionLength = stats.sessionLength
            engine.timeAttackDuration = stats.timeAttackDuration
            engine.gameMode = stats.gameMode
            engine.categoryMetrics = stats.categoryMetrics
        } else {
            let initialStats = UserStats()
            modelContext.insert(initialStats)
            engine.activeCategories = initialStats.activeCategories
            engine.sessionLength = initialStats.sessionLength
            engine.timeAttackDuration = initialStats.timeAttackDuration
            engine.gameMode = initialStats.gameMode
        }
        
        startNewSession()
    }
    
    private func startNewSession() {
        engine.startSession()
        
        timeAttackTimer?.invalidate()
        if engine.gameMode == "Timed" {
            timeAttackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if engine.timeRemaining > 0 {
                    engine.timeRemaining -= 1
                } else if !engine.isSessionComplete {
                    engine.endSession()
                    timeAttackTimer?.invalidate()
                }
            }
        }
    }
    
    private func setupEngineSaveCallback() {
        engine.onProblemSolved = {
            guard engine.isSessionComplete else { return }
            timeAttackTimer?.invalidate()
            
            let currentStats: UserStats
            if let existing = allStats.first {
                currentStats = existing
            } else {
                currentStats = UserStats(dailyStreak: 0, totalProblemsSolved: 0, lastPlayedDate: Date())
                modelContext.insert(currentStats)
            }
            
            currentStats.totalProblemsSolved += 1
            
            let calendar = Calendar.current
            if !calendar.isDateInToday(currentStats.lastPlayedDate) {
                if calendar.isDateInYesterday(currentStats.lastPlayedDate) {
                    currentStats.dailyStreak += 1
                } else {
                    currentStats.dailyStreak = 1
                }
                currentStats.lastPlayedDate = Date()
            }
            
            let totalDuration = engine.problemDurations.reduce(0, +)
            let avgTime = engine.problemsSolvedInSession > 0 ? totalDuration / Double(engine.problemsSolvedInSession) : 0.0
            
            let log = SessionLog(
                date: Date(),
                score: engine.totalCorrectSession,
                totalQuestions: engine.problemsSolvedInSession,
                totalDuration: totalDuration,
                averageTimePerQuestion: avgTime,
                gameMode: engine.gameMode
            )
            
            currentStats.sessionLogs.append(log)
            
            if engine.gameMode == "Standard" && engine.problemsSolvedInSession > 0 && !engine.activeCategories.isEmpty {
                for cat in engine.activeCategories {
                    let existing = currentStats.categoryMetrics[cat.rawValue] ?? 0.0
                    if existing == 0.0 {
                        currentStats.categoryMetrics[cat.rawValue] = avgTime
                    } else {
                        currentStats.categoryMetrics[cat.rawValue] = (existing * 0.8) + (avgTime * 0.2)
                    }
                }
                engine.categoryMetrics = currentStats.categoryMetrics
            }
        }
    }
    
    // MARK: - Subviews
    
    private var sessionStatsContent: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("\(engine.totalCorrectSession)")
                    .foregroundColor(.green)
            }
            .font(.system(size: 14, weight: .medium))
            
            if engine.gameMode == "Timed" {
                Text("\(engine.timeRemaining)s")
                    .font(.system(size: 16, weight: .semibold))
                    .monospacedDigit()
            } else if engine.gameMode == "Zen" {
                Image(systemName: "infinity")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, 8)
            } else {
                Text("\(engine.problemsSolvedInSession + 1) / \(engine.sessionLength)")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text("\(engine.totalIncorrectSession)")
                    .foregroundColor(.red)
            }
            .font(.system(size: 14, weight: .medium))
        }
    }
    
    private var summaryView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text(engine.gameMode == "Timed" ? "Time's Up!" : "Session Complete")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(engine.totalCorrectSession) / \(engine.problemsSolvedInSession)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 4) {
                let totalDuration = engine.problemDurations.reduce(0, +)
                let avgTime = engine.problemsSolvedInSession > 0 ? totalDuration / Double(engine.problemsSolvedInSession) : 0.0
                
                Text("Elapsed Time: \(String(format: "%.1f", totalDuration))s")
                Text("Avg per question: \(String(format: "%.2f", avgTime))s")
            }
            .font(.callout)
            .foregroundColor(.secondary)
            
            Button {
                startNewSession()
            } label: {
                HStack {
                    Text("Next Session")
                        .font(.headline)
                    Image(systemName: "arrow.counterclockwise")
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(Color.primary)
                .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
    }
}
