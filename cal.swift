import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showResults = false
    let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    let hapticSelection = UISelectionFeedbackGenerator()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Sleep Cycle Calculator")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    NeomorphicCard {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("I plan to go to bed at:")
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .onChange(of: selectedDate) { _ in
                                    hapticSelection.selectionChanged()
                                    withAnimation {
                                        showResults = true
                                    }
                                }
                        }
                        .padding()
                    }
                    
                    if showResults {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recommended wake-up times:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(calculateWakeUpTimes(), id: \.time) { wakeTime in
                                NeomorphicCard {
                                    HStack {
                                        Text(wakeTime.time)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.blue)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("\(wakeTime.hours) hours")
                                                .foregroundColor(.secondary)
                                            Text("(\(wakeTime.cycles) cycles)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                }
                                .onTapGesture {
                                    hapticImpact.impactOccurred()
                                }
                            }
                        }
                        .onAppear {
                            hapticImpact.impactOccurred(intensity: 0.8)
                        }
                    }
                    
                    Text("Calculations include 14 minutes to fall asleep.\nEach sleep cycle is 90 minutes.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .onAppear {
            // Prepare haptic engines
            hapticImpact.prepare()
            hapticSelection.prepare()
        }
    }
    
    struct WakeTime {
        let time: String
        let cycles: Int
        let hours: String
    }
    
    func calculateWakeUpTimes() -> [WakeTime] {
        var times: [WakeTime] = []
        let calendar = Calendar.current
        
        // Add 14 minutes for falling asleep
        var baseTime = calendar.date(byAdding: .minute, value: 14, to: selectedDate) ?? selectedDate
        
        // Calculate 6 wake times (4.5 to 9 hours of sleep)
        for i in 1...6 {
            baseTime = calendar.date(byAdding: .minute, value: 90, to: baseTime) ?? baseTime
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            
            times.append(WakeTime(
                time: formatter.string(from: baseTime),
                cycles: i,
                hours: String(format: "%.1f", Double(i) * 1.5)
            ))
        }
        
        return times
    }
}

struct NeomorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray6))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            )
    }
}

#Preview {
    ContentView()
}

extension Color {
    static let neuBackground = Color(UIColor.systemGray6)
    static let neuShadow = Color.black.opacity(0.2)
    static let neuHighlight = Color.white.opacity(0.7)
}
