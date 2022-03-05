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
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(task: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let allTasks = CoreDataManager.shared.getAllTasks().filter { task in
            !task.isCompleted
        }
        let entry: TaskEntry
        if (allTasks.isEmpty) {
            entry = TaskEntry(task: nil)
        } else {
            entry = TaskEntry(task: allTasks[0])
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let newTasks = CoreDataManager.shared.getAllTasks().filter { task in
            !task.isCompleted
        }
        let entry = TaskEntry(task: newTasks.isEmpty ? nil : newTasks[0])
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SmallWidget : View {
    var entry: Provider.Entry
    @Binding var remainingTime: String
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Next Due Date in")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            Text(remainingTime)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct MediumWidget : View {
    var entry: Provider.Entry
    @Binding var remainingTime: String
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return HStack {
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
            .padding(.vertical)
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            VStack (alignment: .leading) {
                Text(dateFormatter.string(from: entry.task != nil ? entry.task!.date! : Date.now))
                    .foregroundColor(Color("Text"))
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.vertical)
                Text(entry.task != nil ? entry.task!.taskDescription! : "Task Description")
                    .foregroundColor(Color("Text"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent1")))
            .padding(.vertical)
            .padding(.trailing)
        }
    }
}

struct LargeWidget : View {
    var entry: Provider.Entry
    @Binding var remainingTime: String
    
    var body: some View {
        HStack {
            VStack {
                Text("Next Due Date in")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text(remainingTime)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Text(entry.task != nil ? entry.task!.taskDescription! : "asd")
        }
    }
}



struct ToDoWidgetEntryView : View {
    var entry: Provider.Entry
    @State private var remainingTime = "No Tasks!"
    @Environment(\.widgetFamily) var family

    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidget(entry: entry, remainingTime: $remainingTime)
            case .systemMedium:
                MediumWidget(entry: entry, remainingTime: $remainingTime)
            default:
                LargeWidget(entry: entry, remainingTime: $remainingTime)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .onAppear(perform: {
            getRemainingDays(task: entry.task)
        })
    }
    
    func getRemainingDays(task: Task?) {
        if (task == nil) {
            remainingTime = "No Tasks!"
            return
        }
        let diff = Calendar.current.dateComponents([.year, .month, .day], from: Date.now, to: task!.date!)
        var outputStr = ""
        if (diff.year != nil && diff.year != 0) {
            outputStr += "\(diff.year!) "
            outputStr += diff.year == 1 ? "Year " : "Years "
        }
        if (diff.month != nil && diff.month != 0) {
            outputStr += "\(diff.month!) "
            outputStr += diff.month == 1 ? "Month " : "Months "
        }
        outputStr += "\(diff.day != nil ? diff.day! + 1 : 0) "
        outputStr += diff.day != nil && diff.day! + 1 == 1 ? "Day" : "Days"
        remainingTime = outputStr
    }
}

@main
struct ToDoWidget: Widget {
    private let kind: String = "ToDoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ToDoWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Next Task Widget")
        .description("Always have your next task on your home screen.")
    }
}

struct ToDoWidget_Preview: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        Group {
//            ToDoWidgetEntryView(entry: TaskEntry(task: nil))
//                .preferredColorScheme(.dark)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
            ToDoWidgetEntryView(entry: TaskEntry(task: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .preferredColorScheme(.dark)
//            ToDoWidgetEntryView(entry: TaskEntry(task: nil))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

