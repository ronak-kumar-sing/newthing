import Foundation

struct StreakWidgetData: Codable {
    let habitName: String
    let currentStreak: Int
    let targetDays: Int
    let daysLeft: Int
    let percentage: Double
    let last7Days: [Bool]
    let accentColorHex: String
}

struct TaskWidgetData: Codable, Identifiable {
    let id: String
    let title: String
    let isCompleted: Bool
    let category: String?
}
