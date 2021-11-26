//
//  Spirograph.swift
//  SwiftUIWork
//
//  Created by Stan Hu on 2021/11/26.
//

import SwiftUI

struct SpirographView: View {
    @State private var innerRadius = 125.0
    @State private var outerRaduis =  75.0
    @State private var distance =  25.0
    @State private var amount : CGFloat =  1.0
    @State private var hue =  0.6

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Spirograph(innerRadius: Int(innerRadius), outerRaduis: Int(outerRaduis), distance: Int(distance), amount: amount).stroke(Color(hue: hue, saturation: 1, brightness: 1),lineWidth: 1).frame(width: 300, height: 300)
            Spacer()
            Group{
                Text("Inner radius: \(Int(innerRadius))")
                Slider(value: $innerRadius, in: 10...150,step: 1).padding([.horizontal,.bottom])
                Text("Outer radius: \(Int(outerRaduis))")
                Slider(value: $outerRaduis, in: 10...150,step: 1).padding([.horizontal,.bottom])
                Text("Distance radius: \(Int(distance))")
                Slider(value: $distance, in: 1...150,step: 1).padding([.horizontal,.bottom])
                Text("Amount: \(amount, specifier: "%.2f")")
                Slider(value: $amount).padding([.horizontal,.bottom])
                Text("Color")
                Slider(value: $hue).padding(.horizontal)
            }
        }
    }
}

struct SpirographView_Previews: PreviewProvider {
    static var previews: some View {
        SpirographView()
    }
}

struct Spirograph : Shape {
    func path(in rect: CGRect) -> Path {
        let divisor = gcd(a: innerRadius, b: outerRaduis)
        let outerRadius = CGFloat(self.outerRaduis)
        let innerRadius = CGFloat(self.innerRadius)
        let distance = CGFloat(self.distance)
        let diffence = innerRadius - outerRadius
        let endPoint = ceil(2 * CGFloat.pi  * outerRadius / CGFloat(divisor)) * amount
        
        var path = Path()
        
        for theta in stride(from: 0, through: endPoint, by: 0.01){
            var x = diffence * cos(theta) + distance * cos(diffence / outerRadius * theta)
            var y = diffence * sin(theta) - distance * sin(diffence / outerRadius * theta)
            x += rect.width / 2
            y += rect.height / 2
            if theta == 0{
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
    
    func gcd(a:Int,b:Int)->Int{
        var a = a
        var b = b
        while b != 0{
            let tmp = b
            b = a % b
            a = tmp
        }
        return a
    }
    let innerRadius:Int
    let outerRaduis:Int
    let distance:Int
    let amount:CGFloat
}
