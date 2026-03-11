import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // We expect the array of SessionLog objects.
    let sessionLogs: [SessionLog]
    
    // Derived filtered logs
    private var chartData: [SessionLog] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return sessionLogs
            .filter { $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if chartData.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Data Yet")
                            .font(.title3.bold())
                        Text("Complete a few sessions to see your progress track over time.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Section: Chart
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Average Time per Question")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Last 30 Days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Chart(chartData) { log in
                                    LineMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Time (s)", log.averageTimePerQuestion)
                                    )
                                    .interpolationMethod(.monotone)
                                    .foregroundStyle(.primary)
                                    .symbol(Circle().strokeBorder(lineWidth: 1.5))
                                    .symbolSize(40)
                                    
                                    AreaMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Time (s)", log.averageTimePerQuestion)
                                    )
                                    .interpolationMethod(.monotone)
                                    .foregroundStyle(
                                        .linearGradient(
                                            colors: [.primary.opacity(0.2), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: max(1, chartData.count / 4))) { value in
                                        if let date = value.as(Date.self) {
                                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                        }
                                    }
                                }
                                .frame(height: 250)
                                .padding(.top, 16)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                            
                            // Section: Recent Sessions
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(chartData.reversed().prefix(5)) { log in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(log.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text(log.gameMode)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.primary.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Score: \(log.score)/\(log.totalQuestions)")
                                                .font(.subheadline.bold())
                                            Text(String(format: "Avg: %.2fs", log.averageTimePerQuestion))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
