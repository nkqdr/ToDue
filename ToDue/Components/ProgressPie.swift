//
//  ProgressPie.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import SwiftUI

struct ProgressPie: Shape {
    var progress: Double
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = true
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.radians, endAngle.radians) }
        set {
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    init(progress: Double) {
        self.progress = progress
        self.startAngle = Angle(degrees: -90)
        self.endAngle = Angle(degrees: progress * 360 - 90)
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startPoint = CGPoint(
            x: center.x + radius * CGFloat(cos(startAngle.radians)),
            y: center.y + radius * CGFloat(sin(startAngle.radians))
        )
        var p = Path()
        p.move(to: center)
        p.addLine(to: startPoint)
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: !clockwise)
        p.addLine(to: center)
        return p
    }
}
