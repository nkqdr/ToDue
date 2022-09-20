//
//  ToDoWidget.swift
//  ToDoWidget
//
//  Created by Niklas Kuder on 05.03.22.
//

import WidgetKit
import SwiftUI

struct TaskEntry: TimelineEntry {
    let date: Date = Date.now
    let task: Task?
    let secondTask: Task?
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(task: nil, secondTask: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let allTasks = PersistenceController.shared.getIncompleteTasks()
        let entry: TaskEntry
        if (allTasks.isEmpty) {
            entry = TaskEntry(task: nil, secondTask: nil)
        } else {
            entry = TaskEntry(task: allTasks[0], secondTask: allTasks.count < 2 ? nil : allTasks[1])
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let newTasks = PersistenceController.shared.getIncompleteTasks()
        let entry = TaskEntry(task: newTasks.isEmpty ? nil : newTasks[0], secondTask: newTasks.count < 2 ? nil : newTasks[1])
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SmallWidget : View {
    var entry: Provider.Entry
    var remainingTime: LocalizedStringKey
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Next Due Date in")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            Text(remainingTime)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

struct MediumWidget : View {
    var entry: Provider.Entry
    var remainingTime: LocalizedStringKey

    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return HStack {
            VStack (alignment: .leading) {
                Text("Next Due Date in")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text(remainingTime)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.trailing, 25)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            VStack {
                if let task = entry.task {
                    TaskContainer(task: task, descriptionLineLimit: 4, innerTaskContainerPadding: 6)
                }
                if let task = entry.secondTask {
                    TaskContainer(task: task, backgroundColor: Color("Accent2").opacity(0.3), innerTaskContainerPadding: 6)
                }
            }
        }
        .padding()
    }
}

//struct LargeWidget : View {
//    var entry: Provider.Entry
//    var remainingTime: LocalizedStringKey
//
//    var body: some View {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .none
//        return VStack (alignment: .leading) {
//            Text("Next Due Date in")
//                .font(.title3)
//                .fontWeight(.bold)
//                .foregroundColor(.gray)
//            Text(remainingTime)
//                .font(.title2)
//                .fontWeight(.bold)
//            Spacer()
//            if let task = entry.task {
//                TaskContainer(task: task, includeDescription: true)
//            }
//            if let task = entry.secondTask {
//                TaskContainer(task: task, backgroundColor: Color("Accent2").opacity(0.3), includeDescription: true)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//        .padding()
//    }
//}

struct TaskContainer: View {
    var task: Task
    var backgroundColor: Color = Color("Accent1")
    var cornerRadius: CGFloat = 10
    var descriptionLineLimit: Int = 2
    var innerTaskContainerPadding: CGFloat?
    var includeDescription: Bool = false
    
    private var horizontalPadding: CGFloat? {
        if let p = innerTaskContainerPadding {
            return p + 2
        }
        return nil
    }
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return VStack (alignment: .leading) {
            Text(dateFormatter.string(from: task.date!))
                .foregroundColor(.secondary)
                .font(.caption)
                .fontWeight(.bold)
            Group {
                Text(task.taskTitle!)
                    .foregroundColor(Color("Text"))
                    .font(.footnote)
                    .fontWeight(.bold)
                if descriptionLineLimit > 0, includeDescription {
                    Text(task.taskDescription ?? "")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .fontWeight(.bold)
                        .lineLimit(descriptionLineLimit)
                }
            }
            .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, innerTaskContainerPadding ?? 15)
        .padding(.horizontal, horizontalPadding ?? 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
    }
}



struct ToDoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    
    var body: some View {
        let label = Utils.remainingTimeLabel(task: entry.task)
        Group {
            switch family {
            case .systemSmall:
                SmallWidget(entry: entry, remainingTime: label)
            default:
                MediumWidget(entry: entry, remainingTime: label)
//            default:
//                LargeWidget(entry: entry, remainingTime: label)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
    }
}

@main
struct ToDoWidget: Widget {
    private let kind: String = "ToDoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ToDoWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Next Task Widget")
        .description("Always have your next task on your home screen.")
    }
}

struct ToDoWidget_Preview: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        Group {
            ToDoWidgetEntryView(entry: TaskEntry(task: nil, secondTask: nil))
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            ToDoWidgetEntryView(entry: TaskEntry(task: nil, secondTask: nil))
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
//            ToDoWidgetEntryView(entry: TaskEntry(task: nil, secondTask: nil))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

