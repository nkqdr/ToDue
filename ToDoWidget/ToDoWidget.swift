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
        let allTasks = CoreDataManager.shared.getAllTasks().filter { task in
            !task.isCompleted
        }
        let entry: TaskEntry
        if (allTasks.isEmpty) {
            entry = TaskEntry(task: nil, secondTask: nil)
        } else {
            entry = TaskEntry(task: allTasks[0], secondTask: allTasks.count < 2 ? nil : allTasks[1])
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let newTasks = CoreDataManager.shared.getAllTasks().filter { task in
            !task.isCompleted
        }
        let entry = TaskEntry(task: newTasks.isEmpty ? nil : newTasks[0], secondTask: newTasks.count < 2 ? nil : newTasks[1])
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
        .padding()
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
            if (entry.task != nil) {
            VStack (alignment: .leading) {
                Text(dateFormatter.string(from: entry.task != nil ? entry.task!.date! : Date.now))
                    .foregroundColor(Color("Text"))
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.vertical)
                Text(entry.task != nil ? entry.task!.taskTitle! : "Task Title")
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
}

struct LargeWidget : View {
    var entry: Provider.Entry
    @Binding var remainingTime: String
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return VStack (alignment: .leading) {
            Text("Next Due Date in")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            Text(remainingTime)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            if (entry.task != nil) {
                VStack (alignment: .leading) {
                    Text(dateFormatter.string(from: entry.task != nil ? entry.task!.date! : Date.now))
                        .foregroundColor(Color("Text"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding([.horizontal, .top])
                    Text(entry.task != nil ? entry.task!.taskTitle! : "Task Title")
                        .foregroundColor(Color("Text"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding([.horizontal, .bottom])
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent1")))
                .padding(.vertical)
                .padding(.trailing)
            }
            if (entry.secondTask != nil) {
                VStack (alignment: .leading) {
                   Text(dateFormatter.string(from: entry.secondTask != nil ? entry.secondTask!.date! : Date.now))
                       .foregroundColor(Color("Text"))
                       .font(.headline)
                       .fontWeight(.bold)
                       .padding([.horizontal, .top])
                   Text(entry.secondTask != nil ? entry.secondTask!.taskTitle! : "Task Title")
                       .foregroundColor(Color("Text"))
                       .font(.subheadline)
                       .fontWeight(.bold)
                       .padding([.horizontal, .bottom])
                   Spacer()
               }
               .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
               .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent2").opacity(0.3)))
               .padding(.vertical)
               .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
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
        let diff = Calendar.current.dateComponents([.year, .month, .day], from: Date.now.removeTimeStamp!, to: task!.date!)
        var outputStr = ""
        if (diff.year != nil && diff.year != 0) {
            outputStr += "\(diff.year!) "
            outputStr += diff.year == 1 ? "Year " : "Years "
        }
        if (diff.month != nil && diff.month != 0) {
            outputStr += "\(diff.month!) "
            outputStr += diff.month == 1 ? "Month " : "Months "
        }
        outputStr += "\(diff.day != nil ? diff.day! : 0) "
        outputStr += diff.day != nil && diff.day! == 1 ? "Day" : "Days"
        if (diff.day != nil && diff.month != nil && diff.year != nil && diff.day! < 0 && diff.month! <= 0 && diff.year! <= 0) {
            remainingTime = "Task is past due!"
        } else {
            remainingTime = outputStr
        }
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
//            ToDoWidgetEntryView(entry: TaskEntry(task: nil))
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//                .preferredColorScheme(.dark)
            ToDoWidgetEntryView(entry: TaskEntry(task: nil, secondTask: nil))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

