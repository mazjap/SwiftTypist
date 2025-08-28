#if DEBUG
import SwiftUI

struct TypingDebugViewState: Equatable, CustomStringConvertible {
    let precedingCount: Int
    let succeedingCount: Int
    
    var description: String {
        "Preceding Count: \(precedingCount) = Succeeding Count: \(succeedingCount)"
    }
}

struct TypingDebugView: View {
    @State private var precedingCount = 12
    @State private var succeedingCount = 12
    private let model: TypingViewModel
    
    init(model: TypingViewModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Preceding")
                Slider(value: $precedingCount.asDouble, in: 0...50, step: 1)
                
                Spacer()
                
                Text("Succeeding")
                Slider(value: $succeedingCount.asDouble, in: 0...50, step: 1)
            }
            
            TypingView(precedingCount: precedingCount, succeedingCount: succeedingCount, model: model)
        }
        .onChange(of: TypingDebugViewState(precedingCount: precedingCount, succeedingCount: succeedingCount)) { _, new in
            print("\n\n\n\n\n\n\n\(new)")
        }
    }
}

extension Int {
    var asDouble: Double {
        get {
            Double(self)
        } set {
            self = Int(newValue)
        }
    }
}

#Preview {
    @Previewable @State var model = TypingViewModel(asciiString: .linear("The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. [beep] A single lap should be completed each time you hear this sound. [ding] Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, start. "))
    
    TypingDebugView(model: model)
}
#endif
