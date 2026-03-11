import UIKit

struct Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    func playCorrect() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playIncorrect() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
        
        // Slight delay for the double tap error effect
        // 0.1s is enough to feel like two distinct "thuds"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let secondGenerator = UIImpactFeedbackGenerator(style: .rigid)
            secondGenerator.prepare()
            secondGenerator.impactOccurred()
        }
    }
}
