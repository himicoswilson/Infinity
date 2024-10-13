// import SwiftUI

// struct BirthdayCardView: View {
//     @State private var isCalendarFlipped = false
//     @State private var calendarDegree = 0.0
//     @State private var flips = 0
    
//     var body: some View {
//         ZStack {
//             // 深蓝色背景
//             Color(red: 0.1, green: 0.1, blue: 0.3)
//                 .ignoresSafeArea()
            
//             // 星星背景
//             ForEach(0..<50) { _ in
//                 Circle()
//                     .fill(Color.white)
//                     .frame(width: CGFloat.random(in: 1...3))
//                     .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
//                               y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
//                     .opacity(Double.random(in: 0.3...0.7))
//             }
            
//             VStack {
//                 Spacer()
                
//                 // 放大的日历，居中显示
//                 CalendarView(isFlipped: $isCalendarFlipped)
//                     .frame(width: 280, height: 320)
//                     .rotation3DEffect(
//                         .degrees(calendarDegree),
//                         axis: (x: 0, y: 1, z: 0)
//                     )
//                     .onTapGesture {
//                         flipCalendar()
//                     }
                
//                 Spacer()
                
//                 Text("点击日历查看年龄")
//                     .font(.custom("Avenir", size: 18))
//                     .foregroundColor(.white)
//                     .padding(.bottom, 20)
//             }
//         }
//     }
    
//     func flipCalendar() {
//         flips = 5
//         animateFlip()
//     }
    
//     func animateFlip() {
//         if flips > 0 {
//             withAnimation(.linear(duration: 0.2)) {
//                 calendarDegree += 180
//             }
//             flips -= 1
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                 animateFlip()
//             }
//         } else {
//             withAnimation(.linear(duration: 0.2)) {
//                 isCalendarFlipped.toggle()
//             }
//         }
//     }
// }

// struct CalendarView: View {
//     @Binding var isFlipped: Bool
    
//     var body: some View {
//         ZStack {
//             // 日历正面
//             frontView
//                 .opacity(isFlipped ? 0 : 1)
            
//             // 日历背面
//             backView
//                 .opacity(isFlipped ? 1 : 0)
//                 .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//         }
//     }
    
//     var frontView: some View {
//         ZStack {
//             RoundedRectangle(cornerRadius: 25)
//                 .fill(Color.white)
//                 .shadow(radius: 10)
            
//             VStack(spacing: 10) {
//                 Text("十月")
//                     .font(.system(size: 48, weight: .bold))
//                     .foregroundColor(.red)
                
//                 Text("23")
//                     .font(.system(size: 160, weight: .bold))
//                     .foregroundColor(.black)
//             }
//         }
//     }
    
//     var backView: some View {
//         ZStack {
//             RoundedRectangle(cornerRadius: 25)
//                 .fill(Color.white)
//                 .shadow(radius: 10)
            
//             VStack(spacing: 20) {
//                 Text("Age")
//                     .font(.system(size: 48, weight: .bold))
//                     .foregroundColor(.red)
                
//                 Text("20")
//                     .font(.system(size: 160, weight: .bold))
//                     .foregroundColor(.black)
//             }
//         }
//     }
// }



import SwiftUI

struct BirthdayCardView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = -5
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // 气泡动画背景
            BubblesView()
            
            VStack(spacing: 30) {
                // 生日快乐文字
                Text("生日快乐")
                    .font(.custom("Avenir-Heavy", size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // 装饰线
                HStack {
                    Line()
                    SwiftUI.Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                    Line()
                }
                .frame(width: 200)
                
                // 年龄
                Text("20")
                    .font(.custom("Avenir-Black", size: 120))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: rotationAngle)
                
                // 祝福语
                Text("Like is the choice love is only you.")
                    .font(.custom("Avenir", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                rotationAngle = 5
            }
        }
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(height: 1)
    }
}

struct BubblesView: View {
    let bubbleCount = 20
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<bubbleCount, id: \.self) { _ in
                BubbleView(size: geometry.size)
            }
        }
    }
}

struct BubbleView: View {
    let size: CGSize
    @State private var position: CGPoint
    @State private var scale: CGFloat
    @State private var opacity: Double
    
    init(size: CGSize) {
        self.size = size
        _position = State(initialValue: CGPoint(x: CGFloat.random(in: 0...size.width),
                                                y: CGFloat.random(in: 0...size.height)))
        _scale = State(initialValue: CGFloat.random(in: 0.1...0.3))
        _opacity = State(initialValue: Double.random(in: 0.1...0.5))
    }
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: 20, height: 20)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 5...20)).repeatForever()) {
                    position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                       y: CGFloat.random(in: 0...size.height))
                    scale = CGFloat.random(in: 0.1...0.3)
                    opacity = Double.random(in: 0.1...0.5)
                }
            }
    }
}
