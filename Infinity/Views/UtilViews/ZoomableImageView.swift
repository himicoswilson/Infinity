import SwiftUI
import Kingfisher

struct ZoomableImageView: View {
    let imageURL: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isZooming = false
    var onSwipe: ((Direction) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: imageURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .gesture(
                    scale > 1 ?
                    // 放大状态下的拖动手势，用于平移图片
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { value in
                            lastOffset = offset
                            limitOffset(geometry: geometry)
                        }
                    :
                    // 未放大状态下的滑动手势，用于切换图片
                    DragGesture(minimumDistance: 20)
                        .onChanged {_ in }
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                if horizontalAmount < 0 {
                                    onSwipe?(.left)
                                } else if horizontalAmount > 0 {
                                    onSwipe?(.right)
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            limitOffset(geometry: geometry)
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation(.spring()) {
                                if scale > 1 {
                                    scale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = min(2, 4) // 双击放大到指定级别
                                }
                            }
                        }
                )
                .animation(.spring(), value: offset)
                .animation(.spring(), value: scale)
        }
    }
    
    private func limitOffset(geometry: GeometryProxy) {
        let maxOffsetX = max((geometry.size.width * scale - geometry.size.width) / 2, 0)
        let maxOffsetY = max((geometry.size.height * scale - geometry.size.height) / 2, 0)
        
        offset = CGSize(
            width: offset.width.clamped(to: -maxOffsetX...maxOffsetX),
            height: offset.height.clamped(to: -maxOffsetY...maxOffsetY)
        )
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
enum Direction {
    case left, right
}

