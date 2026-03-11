import Foundation
import SwiftData

enum ProblemCategory: String, Codable, CaseIterable {
    case basicArithmetic = "Basic Arithmetic"
    case percentages = "Percentages"
    case squares = "Squares"
    case decimals = "Decimals"
    case complexMultiplication = "Advanced Multiplication"
    case squareRoots = "Square Roots"
    case fractions = "Fractions"
}

@Model
final class UserStats {
    var dailyStreak: Int
    var totalProblemsSolved: Int
    var lastPlayedDate: Date
    // Phase 4 Analytics & Settings
    @Relationship(deleteRule: .cascade) var sessionLogs: [SessionLog] = []
    
    var activeCategories: [ProblemCategory] = [ProblemCategory.basicArithmetic]
    
    var sessionLength: Int = 20 // 0 = Endless
    var hapticsEnabled: Bool = true
    var themePreference: String = "System" // "System", "Light", "Dark"
    var timeAttackDuration: Int = 60
    var gameMode: String = "Standard" // "Standard", "Timed"
    
    // Simple dictionary for basic weakness targeting (e.g. tracking average times per category name)
    var categoryMetrics: [String: Double] = [:]
    
    init(
        dailyStreak: Int = 0,
        totalProblemsSolved: Int = 0,
        lastPlayedDate: Date = Date(),
        activeCategories: [ProblemCategory] = [.basicArithmetic],
        sessionLength: Int = 20,
        hapticsEnabled: Bool = true,
        themePreference: String = "System",
        timeAttackDuration: Int = 60,
        categoryMetrics: [String: Double] = [:]
    ) {
        self.dailyStreak = dailyStreak
        self.totalProblemsSolved = totalProblemsSolved
        self.lastPlayedDate = lastPlayedDate
        self.activeCategories = activeCategories
        
        self.sessionLength = sessionLength
        self.hapticsEnabled = hapticsEnabled
        self.themePreference = themePreference
        self.timeAttackDuration = timeAttackDuration
        self.gameMode = "Standard"
        self.categoryMetrics = categoryMetrics
    }
}
