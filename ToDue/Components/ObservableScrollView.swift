//
//  ObservableScrollView.swift
//  ToDue
//
//  Created by Niklas Kuder on 26.08.22.
//

import SwiftUI

// Simple preference that observes a CGFloat.
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}

// A ScrollView wrapper that tracks scroll offset changes.
struct ObservableScrollView<Content>: View where Content : View {
    @Namespace var scrollSpace
    
    @Binding var scrollOffset: CGFloat
    let content: (ScrollViewProxy) -> Content
    var showsIndicators: Bool = true

    init(scrollOffset: Binding<CGFloat>, showsIndicators: Bool,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
        _scrollOffset = scrollOffset
        self.showsIndicators = showsIndicators
        self.content = content
    }

  var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            ScrollViewReader { proxy in
                content(proxy)
                  .background(GeometryReader { geo in
                      let offset = -geo.frame(in: .named(scrollSpace)).minY
                      Color.clear
                        .preference(key: ScrollViewOffsetPreferenceKey.self,
                                    value: offset)
                  })
            }
        }
        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
          scrollOffset = value
        }
  }
}
