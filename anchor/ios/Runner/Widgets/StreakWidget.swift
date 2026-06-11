import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakData: StreakWidgetData?
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakData: StreakWidgetData(
            habitName: "Focus Goal",
            currentStreak: 5,
            targetDays: 365,
            daysLeft: 360,
            percentage: 1.3,
            last7Days: [true, true, true, false, true, true, true],
            accentColorHex: "#C6F52C"
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let entry = StreakEntry(date: Date(), streakData: loadStreakData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = StreakEntry(date: Date(), streakData: loadStreakData())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadStreakData() -> StreakWidgetData? {
        let defaults = UserDefaults(suiteName: "group.com.example.anchor")
        guard let jsonString = defaults?.string(forKey: "streak_data"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(StreakWidgetData.self, from: data)
    }
}

struct StreakWidgetEntryView : View {
    var entry: StreakProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.streakData?.habitName.uppercased() ?? "FOCUS GOAL")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: entry.streakData?.accentColorHex ?? "#C6F52C"))
                .tracking(1)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(entry.streakData?.currentStreak ?? 0)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("DAYS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: entry.streakData?.accentColorHex ?? "#C6F52C"))
            }

            HStack {
                Text("\(entry.streakData?.daysLeft ?? 365)d left")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: entry.streakData?.accentColorHex ?? "#C6F52C"))
                Text("·")
                    .foregroundColor(.gray)
                Text("\(Int(entry.streakData?.percentage ?? 0.0))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(0..<7) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill((entry.streakData?.last7Days[safe: index] ?? false)
                              ? Color(hex: entry.streakData?.accentColorHex ?? "#C6F52C")
                              : Color.white.opacity(0.1))
                        .frame(height: 12)
                }
            }
        }
        .padding()
        .background(Color(red: 19/255, green: 19/255, blue: 19/255))
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Streak Widget")
        .description("Track your active streak and contribution dot matrix.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension Color {
    init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xff) / 255.0
        let g = Double((rgb >> 8) & 0xff) / 255.0
        let b = Double(rgb & 0xff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
