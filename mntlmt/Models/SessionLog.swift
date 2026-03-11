import Foundation
import SwiftData

@Model
final class SessionLog {
    var id: UUID
    var date: Date
    var score: Int
    var totalQuestions: Int
    var totalDuration: TimeInterval
    var averageTimePerQuestion: TimeInterval
    var gameMode: String
    
    init(id: UUID = UUID(), date: Date = Date(), score: Int = 0, totalQuestions: Int = 0, totalDuration: TimeInterval = 0.0, averageTimePerQuestion: TimeInterval = 0.0, gameMode: String = "Standard") {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.totalDuration = totalDuration
        self.averageTimePerQuestion = averageTimePerQuestion
        self.gameMode = gameMode
    }
}
