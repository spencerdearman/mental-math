import Foundation
import Observation

enum Operation: String, CaseIterable {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
    case percentage = "% of"
    case square = "²"
    case root = "√"
    case fractionToDecimal = "to dec" // Used internally for formatting 
}

struct Problem {
    let text: String
    let displayLines: [String]? // Optional array for vertical stacked formatting
    let expectedAnswer: String
}

@Observable
final class GameEngine {
    var currentProblem: Problem?
    var currentInput: String = ""
    var isEvaluating: Bool = false
    
    // Difficulty logic variables
    var currentDifficultyLevel: Int = 1
    var currentStreak: Int = 0 
    
    var problemsSolvedInSession: Int = 0
    let totalProblemsPerSession: Int = 20
    
    // UI Trackers
    var totalCorrectSession: Int = 0
    var totalIncorrectSession: Int = 0
    
    var activeCategories: [ProblemCategory] = [.basicArithmetic] {
        didSet {
            // Generate problem on initial load or if they previously had no categories selected.
            // Do not force a reroll mid-game when closing the settings menu.
            if currentProblem == nil || currentProblem?.text == "Select Category" {
                generateNewProblem()
            } else if activeCategories.isEmpty {
                currentProblem = Problem(text: "Select Category", displayLines: nil, expectedAnswer: "---")
            }
        }
    }
    
    var onProblemSolved: (() -> Void)?
    
    init() {
        // Will generate when View loads and sets activeCategories
    }
    
    func generateNewProblem() {
        guard !activeCategories.isEmpty else {
            currentProblem = Problem(text: "Select Category", displayLines: nil, expectedAnswer: "---")
            return
        }
        
        // Filter active categories based on the current streak tier to enforce progression
        // Levels 1-3 = Basic only
        // Levels 4-6 = Basic, Percentages, Squares, Decimals
        // Levels 7+  = All active categories
        
        var validCategories: [ProblemCategory] = []
        if activeCategories.contains(.basicArithmetic) { validCategories.append(.basicArithmetic) }
        
        if currentDifficultyLevel >= 4 {
            if activeCategories.contains(.percentages) { validCategories.append(.percentages) }
            if activeCategories.contains(.squares) { validCategories.append(.squares) }
            if activeCategories.contains(.decimals) { validCategories.append(.decimals) }
        }
        
        if currentDifficultyLevel >= 7 {
            if activeCategories.contains(.complexMultiplication) { validCategories.append(.complexMultiplication) }
            if activeCategories.contains(.squareRoots) { validCategories.append(.squareRoots) }
            if activeCategories.contains(.fractions) { validCategories.append(.fractions) }
        }
        
        // Failsafe if everything was filtered out
        if validCategories.isEmpty {
            validCategories = activeCategories
        }
        
        let selectedCategory = validCategories.randomElement()!
        
        self.currentProblem = buildProblemFor(category: selectedCategory, level: currentDifficultyLevel)
        self.currentInput = ""
    }
    
    private func buildProblemFor(category: ProblemCategory, level: Int) -> Problem {
        switch category {
        case .basicArithmetic:
            return generateBasicArithmetic(level: level)
        case .percentages:
            return generatePercentage()
        case .squares:
            return generateSquare()
        case .decimals:
            return generateDecimal()
        case .complexMultiplication:
            return generateComplexMultiplication()
        case .squareRoots:
            return generateSquareRoot()
        case .fractions:
            return generateFraction()
        }
    }
    
    // MARK: - Generators

    private func generateBasicArithmetic(level: Int) -> Problem {
        let op = [Operation.add, .subtract, .multiply, .divide].randomElement()!
        
        var n1 = 0
        var n2 = 0
        var ans = ""
        
        switch op {
        case .add:
            if level <= 2 {
                n1 = Int.random(in: 1...15)
                n2 = Int.random(in: 1...15)
            } else if level <= 4 {
                n1 = Int.random(in: 10...99)
                n2 = Int.random(in: 1...9)
            } else if level <= 6 {
                n1 = Int.random(in: 10...99)
                n2 = Int.random(in: 10...99)
            } else {
                n1 = Int.random(in: 10...40) * 10
                n2 = Int.random(in: 10...40) * 10
            }
            ans = "\(n1 + n2)"
            let display = level > 2 ? ["\(n1)", "+ \(n2)"] : nil
            return Problem(text: "\(n1) + \(n2)", displayLines: display, expectedAnswer: ans)
            
        case .subtract:
            if level <= 2 {
                n1 = Int.random(in: 5...20)
                n2 = Int.random(in: 1...n1)
            } else if level <= 4 {
                n1 = Int.random(in: 20...99)
                n2 = Int.random(in: 1...19)
            } else {
                n1 = Int.random(in: 20...99)
                n2 = Int.random(in: 10...n1)
            }
            ans = "\(n1 - n2)"
            let display = level > 2 ? ["\(n1)", "- \(n2)"] : nil
            return Problem(text: "\(n1) - \(n2)", displayLines: display, expectedAnswer: ans)
            
        case .multiply:
            if level <= 3 {
                n1 = Int.random(in: 2...9)
                n2 = Int.random(in: 2...9)
            } else { // times table + multiples of 10
                if Bool.random() {
                    n1 = Int.random(in: 2...12)
                    n2 = Int.random(in: 2...12)
                } else {
                    n1 = Int.random(in: 2...9) * 10
                    n2 = Int.random(in: 2...9)
                }
            }
            ans = "\(n1 * n2)"
            let display = level > 3 ? ["\(n1)", "× \(n2)"] : nil
            return Problem(text: "\(n1) × \(n2)", displayLines: display, expectedAnswer: ans)
            
        case .divide:
            n2 = Int.random(in: 2...12)
            let quotient = Int.random(in: 2...12)
            n1 = n2 * quotient
            ans = "\(quotient)"
            return Problem(text: "\(n1) ÷ \(n2)", displayLines: nil, expectedAnswer: ans)
            
        default: return Problem(text: "Error", displayLines: nil, expectedAnswer: "0")
        }
    }
    
    private func generatePercentage() -> Problem {
        let percentages = [10, 15, 20, 50]
        let p = percentages.randomElement()!
        let base = Int.random(in: 2...20) * 10 // 20, 30...200
        
        let ans = Double(p) / 100.0 * Double(base)
        
        // Remove .0 if it's whole integer
        let ansStr = ans.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(ans))" : "\(ans)"
        return Problem(text: "\(p)% of \(base)", displayLines: nil, expectedAnswer: ansStr)
    }
    
    private func generateSquare() -> Problem {
        let n = Int.random(in: 2...20)
        return Problem(text: "\(n)²", displayLines: nil, expectedAnswer: "\(n * n)")
    }
    
    private func generateDecimal() -> Problem {
        // Simple currency-style addition
        let d1 = Double(Int.random(in: 1...10)) + [0.25, 0.50, 0.75].randomElement()!
        let d2 = Double(Int.random(in: 1...5)) + [0.25, 0.50, 0.75].randomElement()!
        
        let op = Bool.random() ? Operation.add : Operation.subtract
        var first = d1
        var second = d2
        if op == .subtract && second > first {
            swap(&first, &second)
        }
        
        let ans = op == .add ? first + second : first - second
        
        let ansStr = ans.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(ans))" : "\(ans)"
        let text = "\(first) \(op.rawValue) \(second)"
        
        return Problem(text: text, displayLines: nil, expectedAnswer: ansStr)
    }
    
    private func generateComplexMultiplication() -> Problem {
        let n1 = Int.random(in: 11...29)
        let n2 = Int.random(in: 11...29)
        return Problem(text: "\(n1) × \(n2)", displayLines: ["\(n1)", "× \(n2)"], expectedAnswer: "\(n1 * n2)")
    }
    
    private func generateSquareRoot() -> Problem {
        let roots = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
        let root = roots.randomElement()!
        return Problem(text: "√\(root * root)", displayLines: nil, expectedAnswer: "\(root)")
    }
    
    private func generateFraction() -> Problem {
        let fractions = [
            ("1/2", "0.5"),
            ("1/4", "0.25"),
            ("3/4", "0.75"),
            ("1/5", "0.2"),
            ("2/5", "0.4"),
            ("3/5", "0.6"),
            ("4/5", "0.8")
        ]
        
        let pair = fractions.randomElement()!
        return Problem(text: "\(pair.0) = ?", displayLines: nil, expectedAnswer: pair.1)
    }
    
    // MARK: - Handlers
    
    func skipProblem() {
        // Count as an attempted problem but unanswered
        problemsSolvedInSession += 1
        totalIncorrectSession += 1
        
        // Notify tracking to increment total questions seen
        onProblemSolved?()
        
        currentInput = ""
        generateNewProblem()
    }
    
    func submitDigit(_ digit: String) {
        if isEvaluating { return }
        if digit == "delete" {
            if !currentInput.isEmpty {
                currentInput.removeLast()
            }
            return
        }
        
        if digit == "C" {
            currentInput = ""
            return
        }
        
        // Handle decimal rules
        if digit == "." {
            if currentInput.contains(".") || currentInput.isEmpty {
                return // Can't start with decimal or have multiple
            }
        }
        
        if currentInput.count < 6 {
            currentInput.append(digit)
            checkAnswer()
        }
    }
    
    private func checkAnswer() {
        guard let problem = currentProblem else { return }
        
        if currentInput == problem.expectedAnswer {
            // Correct
            isEvaluating = true
            Haptics.shared.playCorrect()
            currentStreak += 1
            problemsSolvedInSession += 1
            totalCorrectSession += 1
            
            // Adjust difficulty: level up every 4 streaks
            if currentStreak > 0 && currentStreak % 4 == 0 {
                currentDifficultyLevel += 1
            }
            
            onProblemSolved?()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.generateNewProblem()
                self.isEvaluating = false
            }
        }
    }
    
    func forceSubmit() {
        if isEvaluating { return }
        guard let problem = currentProblem, !currentInput.isEmpty else { return }
        
        if currentInput == problem.expectedAnswer {
            checkAnswer()
        } else {
            // Incorrect
            Haptics.shared.playIncorrect()
            currentStreak = 0
            totalIncorrectSession += 1
            if currentDifficultyLevel > 1 {
                currentDifficultyLevel -= 1
            }
            // Clear input so they try again
            currentInput = ""
        }
    }
}
