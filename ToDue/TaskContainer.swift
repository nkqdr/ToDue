//
//  TaskContainer.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct TaskContainer: View {
    var task: Task
    var geometry: GeometryProxy
    var showBackground: Bool
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return VStack(alignment: .leading) {
            Text(dateFormatter.string(from: task.date ?? Date.now))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("Text"))
                .padding(.horizontal)
                .padding(.top)
            Spacer()
            Text(task.taskDescription ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("Text"))
                .padding(.horizontal)
                .padding(.bottom)
        }
        .frame(maxWidth: geometry.size.width * 3 / 4, minHeight: 120, alignment: .leading)
        .background(
            showBackground ? RoundedRectangle(cornerRadius: 15)
                .fill(Color("Accent1")) : RoundedRectangle(cornerRadius: 15)
                .fill(Color("Background"))
            
        )
    }
}

//struct TaskContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskContainer(task:Task(), geometry: GeometryProxy())
//    }
//}
