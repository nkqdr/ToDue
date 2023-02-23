//
//  ViewExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder
    public func currentDeviceNavigationViewStyle() -> some View {
        if UIDevice.isIPhone {
            self.navigationViewStyle(StackNavigationViewStyle())
        } else {
            self.navigationViewStyle(DefaultNavigationViewStyle())
        }
    }
    
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    func themedListRowBackground() -> some View {
        self.listRowBackground(Color("Accent2").opacity(0.3))
    }
    
    func hideScrollContentBackgroundIfNecessary() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
    
    func versionAwareSearchable(text searchValue: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            return self.searchable(text: searchValue)
        } else {
            return self
        }
    }
    
    func versionAwareBorderedButtonStyle() -> some View {
        if #available(iOS 15.0, *) {
            return self.buttonStyle(.bordered)
        } else {
            return self.buttonStyle(.automatic)
        }
    }
    
    func versionAwarePresentationDetents() -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents([.medium, .large])
        } else {
            return self
        }
    }
    
    func versionAwarePickerStyle(displayTitle: String) -> some View {
        if #available(iOS 16.0, *) {
            return self
        } else {
            return HStack {
                Text(displayTitle)
                Spacer()
                self.pickerStyle(.menu)
            }
        }
    }
    
    func versionAwareConfirmationDialog(_ isPresented: Binding<Bool>, title: LocalizedStringKey, message: String, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.confirmationDialog(
                Text(title),
                isPresented: isPresented,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    withAnimation(.easeInOut) {
                        onDelete()
                    }
                }
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(message)
                    .font(.headline).fontWeight(.bold)
            }
        } else {
            return self.alert(isPresented: isPresented) {
                Alert(
                    title: Text(title),
                    message: Text(message).font(.headline).fontWeight(.bold),
                    primaryButton: .destructive(Text("Delete")) {
                        withAnimation(.easeInOut) {
                            onDelete()
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        onCancel()
                    }
                )
            }
        }
    }
    
    func versionAwareRegularMaterialBackground() -> some View {
        if #available(iOS 15.0, *) {
            return self.background(.regularMaterial, in: Capsule())
        } else {
            return ZStack(alignment: .center) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                self
            }
            .frame(maxWidth: 100)
        }
    }
    
    func groupListStyleIfNecessary() -> some View {
        if #available(iOS 15.0, *) {
            return self
        } else {
            return self.listStyle(InsetGroupedListStyle())
        }
    }
    
    @ViewBuilder
    func versionAwareDeleteSwipeAction(showContextMenuInstead: Bool = true, onDelete: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.swipeActions(edge: .trailing) {
                Button(action: onDelete, label: {
                    Label("Delete", systemImage: "trash")
                })
                .tint(.red)
            }
        } else {
            if showContextMenuInstead {
                self.contextMenu {
                    Button {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            } else {
                self
            }
        }
    }
    
    @ViewBuilder
    func versionAwareEditSwipeAction(showContextMenuInstead: Bool = true, onEdit: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.swipeActions(edge: .leading) {
                Button(action: onEdit, label: {
                    Label("Edit", systemImage: "pencil")
                })
                .tint(.indigo)
            }
        } else {
            if showContextMenuInstead {
                self.contextMenu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            } else {
                self
            }
        }
    }
    
    func versionAwareNavigationTitleDisplayMode() -> some View {
        if #available(iOS 15.0, *) {
            return self.navigationBarTitleDisplayMode(.large)
        } else {
            return self.navigationBarTitleDisplayMode(.large)
        }
    }
    
    func versionAwareSwipeAction(labelText: LocalizedStringKey, labelImage: String, tint: Color?, leading: Bool = false, perform: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.swipeActions(edge: leading ? .leading : .trailing) {
                Button {
                    perform()
                } label: {
                    Label(labelText, systemImage: labelImage)
                }
                .tint(tint ?? .accentColor)
            }
        } else {
            return self
        }
    }
    
    func versionAwareSubtaskCompleteSwipeAction(_ subTask: SubTask, onComplete: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.versionAwareSwipeAction(
                labelText: subTask.isCompleted ? "Mark as incomplete" : "Mark as complete",
                labelImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill",
                tint: .mint,
                leading: true,
                perform: onComplete
            )
        } else {
            return self
        }
    }
    
    func versionAwareTaskCompleteSwipeAction(_ task: Task, onComplete: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.versionAwareSwipeAction(
                labelText: task.isCompleted ? "Mark as incomplete" : "Mark as complete",
                labelImage: task.isCompleted ? "gobackward.minus" : "checkmark.circle.fill",
                tint: .mint,
                leading: true,
                perform: onComplete
            )
        } else {
            return self
        }
    }
    
    func versionAwareAddToDailySwipeAction(isInDaily: Bool, leading: Bool = true, onAdd: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.versionAwareSwipeAction(
                labelText: isInDaily ? "Remove from today" : "Add to today",
                labelImage: isInDaily ? "minus.circle" : "link.badge.plus",
                tint: .green,
                leading: leading,
                perform: onAdd
            )
        } else {
            return self
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
