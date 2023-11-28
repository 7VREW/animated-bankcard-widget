//
//  BankCardWidget.swift
//  Swift UI SIMPLON
//
//  Created by Émilio Williame on 24/10/2023.
//

import SwiftUI

struct BankCardWidget: View {
    
    var balanceValue: Int = 1400
    @State var isPressed: Bool = false
    @State var letterAnim: Bool = false
    @State var timePressed: Bool = false
    
    @State var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var timerCount = 0
    
    var cardText: String {
        isPressed ? "5790 3897 4368 5780": "* * * *   * * * *   * * * *   5780"
    }
    
    @State var anims: [CGFloat] = Array(repeating: 0, count: 50)
    
    let letterSpeed = 0.05
    let letterOffset: CGFloat = 20
    let letterFallOffset = 4
    let letterDelay = 1.0
    
    var body: some View {
        ZStack {
            card
                .zIndex(3)
                .padding(.horizontal, 45)
                .rotation3DEffect(
                    .degrees(isPressed ? 360: 0), axis: (x: 0.15, y: 1.0, z: 0.0), anchorZ: -40)
                .onTapGesture {
                    withAnimation(.bouncy(duration: 0.6, extraBounce: 0.05)) {
                        isPressed.toggle()
                        if isPressed{
                            DispatchQueue.main.asyncAfter(deadline: .now() + letterDelay){
                                startTimer()
                            }
                        } else {
                            pauseTimer()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                        timePressed.toggle()
                    }
                }
        }
        .onAppear{
            pauseTimer()
        }
        
        
    }
    
    var card: some View{
        ZStack(alignment: .leading) {
            Image("blackPattern")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 20, maxWidth: 400, maxHeight: 230)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 25) {
                Image(systemName: "wave.3.backward")
                    .font(.system(size: 30))
                    .symbolEffect(.bounce.down.byLayer, value: timePressed)
                
                HStack(spacing: 2) {
                    if isPressed{
                        ForEach(0..<cardText.count, id: \.self){ index in
                            Text(cardText[index])
                                .offset(y: anims[index])
                                .scaleEffect(-anims[index]/50 + 1)
                        }
                        
                    } else {
                        Text(cardText)
                    }
                }.onReceive(timer, perform: { _ in
                    withAnimation {
                        anims[timerCount] = -letterOffset
                        
                        if timerCount >= letterFallOffset {
                            anims[timerCount - letterFallOffset] = 0
                        }
                    }
                    
                    if timerCount < anims.count - 1 {
                        timerCount += 1
                    } else {
                        pauseTimer()
                    }
                })
                
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text("$ \(balanceValue)")
                        .font(.title2)
                        .blur(radius: !isPressed ? 5: 0)
                }
            }
            .foregroundStyle(.white)
            .padding(30)
        }
    }
    
    func pauseTimer(){
        timer.upstream.connect().cancel()
        timerCount = 0
        anims = Array(repeating: 0, count: 50)
    }
    
    func startTimer(){
        timer = Timer.publish(every: letterSpeed, on: .main, in: .common).autoconnect()
    }
}

#Preview {
    BankCardWidget()
}


extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(self.count, r.lowerBound)),
                                            upper: min(self.count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
