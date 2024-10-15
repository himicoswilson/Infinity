import SwiftUI
import Kingfisher

struct ZoomableImageView: View {
    let imageURL: String
    let onDismiss: () -> Void // 添加此行
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: imageURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle())
                // 仅在放大状态下添加拖动手势
                .gesture(
                    scale > 1 ? (
                        DragGesture()
                            .onChanged { value in
                                withAnimation {
                                    let newOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    offset = newOffset
                                }
                            }
                            .onEnded { _ in
                                let finalOffset = limitOffset(offset, in: geometry, allowOverscroll: false)
                                withAnimation(.spring()) {
                                    offset = finalOffset
                                    lastOffset = finalOffset  // 确保在动画块中同时更新
                                }
                            }
                    ) : nil
                )
                .simultaneousGesture(
                    dragToDismissGesture
                )
                .simultaneousGesture(
                    tapGesture
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            withAnimation(.spring()) {
                                scale = min(max(scale, 1.0), 4.0)
                                offset = limitOffset(offset, in: geometry, allowOverscroll: false)
                                lastOffset = offset
                            }
                        }
                )
        }
    }

    // 单击退出，双击放大
    var tapGesture: some Gesture {
        let doubleTapGesture = TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring()) {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                    } else {
                        scale = 2
                    }
                }
            }

        let singleTapGesture = TapGesture(count: 1)
            .onEnded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDismiss()
                }
            }

        return ExclusiveGesture(doubleTapGesture, singleTapGesture)
    }

    // 下滑退出手势
    var dragToDismissGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale == 1 {
                    if abs(value.translation.height) > abs(value.translation.width) {
                        withAnimation(.linear(duration: 0.2)) {  // 平滑的动画过渡
                            offset = CGSize(width: 0, height: value.translation.height)
                        }
                    }
                }
            }
            .onEnded { value in
                if scale == 1 {
                    if abs(value.translation.height) > abs(value.translation.width) {
                        if value.translation.height > 100 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                onDismiss()
                            }
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                                offset = .zero
                            }
                        }
                    }
                }
            }
    }

    // limitOffset 函数，用于限制偏移量
    private func limitOffset(_ offset: CGSize, in geometry: GeometryProxy, allowOverscroll: Bool) -> CGSize {
        let scaledWidth = geometry.size.width * scale
        let scaledHeight = geometry.size.height * scale

        let maxOffsetX = max((scaledWidth - geometry.size.width) / 2, 0)
        let maxOffsetY = max((scaledHeight - geometry.size.height) / 2, 0)

        var minX = -maxOffsetX
        var maxX = maxOffsetX
        var minY = -maxOffsetY
        var maxY = maxOffsetY

        if allowOverscroll {
            // 设置允许超出的最大距离
            let overscrollLimit: CGFloat = 100
            minX -= overscrollLimit
            maxX += overscrollLimit
            minY -= overscrollLimit
            maxY += overscrollLimit
        }

        return CGSize(
            width: offset.width.clamped(to: minX...maxX),
            height: offset.height.clamped(to: minY...maxY)
        )
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
