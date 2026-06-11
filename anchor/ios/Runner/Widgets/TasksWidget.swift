import WidgetKit
import SwiftUI

struct TasksEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskWidgetData]
}

struct TasksProvider: TimelineProvider {
    func placeholder(in context: Context) -> TasksEntry {
        TasksEntry(date: Date(), tasks: [
            TaskWidgetData(id: "1", title: "Complete Flutter Assignment", isCompleted: false, category: "Academic"),
            TaskWidgetData(id: "2", title: "Apply to Placement Drive", isCompleted: false, category: "Placement"),
            TaskWidgetData(id: "3", title: "Go to Gym", isCompleted: true, category: "Personal")
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TasksEntry) -> ()) {
        let entry = TasksEntry(date: Date(), tasks: loadTasksData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = TasksEntry(date: Date(), tasks: loadTasksData())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadTasksData() -> [TaskWidgetData] {
        let defaults = UserDefaults(suiteName: "group.com.example.anchor")
        guard let jsonString = defaults?.string(forKey: "tasks_data"),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([TaskWidgetData].self, from: data)) ?? []
    }
}

struct TaskRow: View {
    let task: TaskWidgetData

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? Color(hex: "#C6F52C") : .gray)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 1) {
                Text(task.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(task.isCompleted ? .gray : .white)
                    .lineLimit(1)
                    .strikethrough(task.isCompleted, color: .gray)
                
                if let category = task.category {
                    Text(category.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TasksWidgetEntryView : View {
    var entry: TasksProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("TODAY'S TASKS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(1)
                Spacer()
                Text("ANCHOR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#C6F52C"))
            }

            Divider()
                .background(Color.white.opacity(0.1))

            if entry.tasks.isEmpty {
                Spacer()
                Text("All tasks completed for today.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(entry.tasks.prefix(4)) { task in
                        TaskRow(task: task)
                    }
                }
                if entry.tasks.count > 4 {
                    Text("+ \(entry.tasks.count - 4) more tasks")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#C6F52C"))
                        .padding(.top, 2)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(red: 19/255, green: 19/255, blue: 19/255))
    }
}

struct TasksWidget: Widget {
    let kind: String = "TasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksProvider()) { entry in
            TasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks Widget")
        .description("View and manage your tasks directly from the home screen.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
