//
//  ProgressView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ProgressView: View {
//    @ObservedObject var viewModel: QuizViewModel
    private static let colorSet1: ColorSet = .init(primaryFill: .yellowGreenCrayola, secondaryFill: .white, shadowFill: .darkSeaGreen, primaryHighlight: .hunterGreen)
    private static let colorSet2: ColorSet = .init(primaryFill: .yellow, secondaryFill: .white, shadowFill: .darkSeaGreen, primaryHighlight: .hunterGreen)
    private var colorSet: ColorSet = ProgressView.colorSet1
    var body: some View {
        HStack(spacing: 90) {
            HStack {
                CompletionBadgeView()
                    .frame(width: 20, height: 20)
                Text("Page")
                    .font(.caption.bold())
            }
        }
    }
    
    struct ColorSet {
        var primaryFill: Color
        var secondaryFill: Color
        var shadowFill: Color
        var primaryHighlight: Color
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}

struct CompletionBadgeView: View {
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(.green)
                    .frame(width: proxy.size.width * 2/3,
                           height: proxy.size.height * 2/3)
                ProgressRing()
                    .fill(Color.morningDustBlue)
                ProgressRing(step: 1.5)
                    .fill(Color.green)
            }
        }
    }
}

struct ProgressRing: Shape {
    var step: Double
    var percentage: CGFloat
    let paddingRadians: CGFloat
    
    init(step: Double = 4, paddingPercentage: Double = 10) {
        self.step = step
        self.percentage = step * 0.25
        self.paddingRadians = Double.pi / paddingPercentage
    }
    
    var animatableData: Double {
        get { step }
        set { step = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = rect.midX
        
        if step == 0 {
            path = path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round))
            return path
        }
        for s in 0..<Int(step) {
            let startingAngle = angleAtStep(Double(s), paddingRadians: paddingRadians, clipToMin: false)
            let newPoint = pointOnCircle(rect, radius: radius, angle: startingAngle)
            path.move(to: newPoint)
            path.addArc(center: rect.centre,
                        radius: radius,
                        startAngle: startingAngle,
                        endAngle: angleAtStep(Double(s + 1), paddingRadians: paddingRadians, clipToMin: true),
                        clockwise: false)
        }
        let remainder = step.truncatingRemainder(dividingBy: 1)
        if remainder > 0 {
            let startingAngle = angleAtStep(Double(Int(step)), paddingRadians: paddingRadians, clipToMin: false)
            let endAngle = angleAtStep(step, paddingRadians: paddingRadians, clipToMin: true)
            if startingAngle < endAngle {
                let newPoint = pointOnCircle(rect, radius: radius, angle: startingAngle)
                path.move(to: newPoint)
                path.addArc(center: rect.centre,
                            radius: radius,
                            startAngle: startingAngle,
                            endAngle: endAngle,
                            clockwise: false)
            }
        }

        path = path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round))
        return path
    }
    
    private func pointOnCircle(_ rect: CGRect, radius: Double, angle: Angle) -> CGPoint {
        let x: CGFloat = radius * cos(angle.radians) + rect.midX
        let y: CGFloat = radius * sin(angle.radians) + rect.midY
        return CGPoint(x: x, y: y)
    }
    
    private func angleAtStep(_ step: Double, paddingRadians: CGFloat, clipToMin: Bool) -> Angle {
        let trueRadian = (((Double.pi / 2) * (step - 1)).truncatingRemainder(dividingBy: 2 * Double.pi)).positiveAbsoluteRadian
        if ((Double.zero) - paddingRadians).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: (Double.zero))
            || (trueRadian.positiveAbsoluteRadian == (Double.zero).positiveAbsoluteRadian && clipToMin) {
            return Angle(radians: ((Double.zero) - paddingRadians).positiveAbsoluteRadian)
        } else if (Double.zero).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: (Double.zero) + paddingRadians)
                    || (trueRadian.positiveAbsoluteRadian == (Double.zero).positiveAbsoluteRadian && !clipToMin) {
            return Angle(radians: ((Double.zero) + paddingRadians).positiveAbsoluteRadian)
        } else if ((Double.pi / 2) - paddingRadians).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: (Double.pi / 2))
                    || (trueRadian.positiveAbsoluteRadian == (Double.pi / 2).positiveAbsoluteRadian && clipToMin) {
            return Angle(radians: ((Double.pi / 2) - paddingRadians).positiveAbsoluteRadian)
        } else if (Double.pi / 2).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: (Double.pi / 2) + paddingRadians)
                    || (trueRadian.positiveAbsoluteRadian == (Double.pi / 2).positiveAbsoluteRadian && !clipToMin) {
            return Angle(radians: ((Double.pi / 2) + paddingRadians).positiveAbsoluteRadian)
        } else if (Double.pi - paddingRadians).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: Double.pi)
                    || (trueRadian.positiveAbsoluteRadian == Double.pi.positiveAbsoluteRadian && clipToMin) {
            return Angle(radians: (Double.pi - paddingRadians).positiveAbsoluteRadian)
        } else if (Double.pi).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: Double.pi + paddingRadians)
                    || (trueRadian.positiveAbsoluteRadian == Double.pi.positiveAbsoluteRadian && !clipToMin) {
            return Angle(radians: (Double.pi + paddingRadians).positiveAbsoluteRadian)
        } else if (Double.pi * 3/2 - paddingRadians).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: (Double.pi * 3/2))
                    || (trueRadian.positiveAbsoluteRadian == (Double.pi * 3/2).positiveAbsoluteRadian && clipToMin) {
            return Angle(radians: (Double.pi * 3/2 - paddingRadians).positiveAbsoluteRadian)
        } else if (Double.pi * 3/2).isRadianLessThan(radian: trueRadian) && trueRadian.isRadianLessThan(radian: Double.pi * 3/2 + paddingRadians)
                    || (trueRadian.positiveAbsoluteRadian == (Double.pi * 3/2).positiveAbsoluteRadian && !clipToMin) {
            return Angle(radians: (Double.pi * 3/2 + paddingRadians).positiveAbsoluteRadian)
        } else {
            return Angle(radians: trueRadian.positiveAbsoluteRadian)
        }
    }
}

fileprivate extension Double {
    func isRadianLessThan(radian: Double) -> Bool {
        guard self.positiveAbsoluteRadian != radian.positiveAbsoluteRadian else {
            return false
        }
        return (self.positiveAbsoluteRadian - radian.positiveAbsoluteRadian).positiveAbsoluteRadian > Double.pi
    }
    
    var positiveAbsoluteRadian: Double {
        var newValue = self.truncatingRemainder(dividingBy: Double.pi * 2)
        if self <= 0 || self == Double.pi * 2 {
            newValue += Double.pi * 2
        }
        return newValue
    }
}

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}

extension CGRect {
    var centre: CGPoint {
        .init(x: self.midX, y: self.midY)
    }
    var top: CGPoint {
        .init(x: self.midX, y: self.minY)
    }
    
    func arcSlope(startingPoint: CGPoint, radius: CGFloat, radiansRemoved: CGFloat) -> CGPoint {
        let m: CGFloat = radiansRemoved / 2
        let triangleBase: CGFloat = (sin(m) * radius) * 2
        
        let x = cos(m) * triangleBase
        let y = sin(m) * triangleBase
        
        return CGPoint(x: x, y: y)
    }
}
