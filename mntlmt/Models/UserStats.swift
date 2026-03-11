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
    // Persist active settings, default is required for migration
    var activeCategories: [ProblemCategory] = [ProblemCategory.basicArithmetic]
    
    init(dailyStreak: Int = 0, totalProblemsSolved: Int = 0, lastPlayedDate: Date = Date(), activeCategories: [ProblemCategory] = [.basicArithmetic]) {
        self.dailyStreak = dailyStreak
        self.totalProblemsSolved = totalProblemsSolved
        self.lastPlayedDate = lastPlayedDate
        self.activeCategories = activeCategories
    }
}
