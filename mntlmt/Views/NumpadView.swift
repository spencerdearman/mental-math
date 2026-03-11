import SwiftUI

struct NumpadView: View {
    let engine: GameEngine
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let buttons = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        ".", "0", "C"
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(buttons, id: \.self) { btn in
                if btn == "C" {
                    Button(action: {
                        engine.submitDigit(btn)
                    }) {
                        Text(btn)
                            .font(.title)
                            .foregroundColor(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, minHeight: 65)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                    }
                } else if btn.isEmpty || btn == "." {
                    // Empty or decimal
                    Button(action: {
                        engine.submitDigit(btn)
                    }) {
                        Text(btn.isEmpty ? "" : btn)
                            .font(.title)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 65)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                    }
                } else {
                    Button(action: {
                        engine.submitDigit(btn)
                    }) {
                        Text(btn)
                            .font(.title)
                            .frame(maxWidth: .infinity, minHeight: 65)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}
