import SwiftUI
import Kingfisher

struct ZoomableImageView: View {
    let imageURL: String
    let onDismiss: () -> Void
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
                .gesture(
                    scale > 1 ? (
                        DragGesture()
                            .onChanged { value in
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                withAnimation(.interactiveSpring()) {
                                    offset = limitOffset(newOffset, in: geometry, allowOverscroll: true)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    offset = limitOffset(offset, in: geometry, allowOverscroll: false)
                                    lastOffset = offset
                                }
                            }
                    ) : nil
                )
                .simultaneousGesture(tapGesture)
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            let newScale = scale * delta
                            scale = min(max(newScale, 0.5), 6.0)
                            
                            // 实时调整偏移量以保持缩放中心
                            let updatedOffset = CGSize(
                                width: offset.width * delta,
                                height: offset.height * delta
                            )
                            offset = limitOffset(updatedOffset, in: geometry, allowOverscroll: true)
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
                withAnimation(.easeInOut(duration: 0.5)) {
                    onDismiss()
                }
            }

        return ExclusiveGesture(doubleTapGesture, singleTapGesture)
    }

    // limitOffset 函数，用于限制偏移量
    private func limitOffset(_ offset: CGSize, in geometry: GeometryProxy, allowOverscroll: Bool) -> CGSize {
        let scaledWidth = geometry.size.width * scale
        let scaledHeight = geometry.size.height * scale

        let maxOffsetX = max((scaledWidth - geometry.size.width) / 2, 0)
        let maxOffsetY = max((scaledHeight - geometry.size.height) / 2, 0)

        let minX = -maxOffsetX
        let maxX = maxOffsetX
        let minY = -maxOffsetY
        let maxY = maxOffsetY

        let overscrollLimit: CGFloat = 50
        let springForce: CGFloat = allowOverscroll ? 0.3 : 1.0

        let boundedOffsetX = offset.width.clamped(to: (minX - overscrollLimit)...(maxX + overscrollLimit))
        let boundedOffsetY = offset.height.clamped(to: (minY - overscrollLimit)...(maxY + overscrollLimit))

        let deltaX = boundedOffsetX < minX || boundedOffsetX > maxX ? (boundedOffsetX > maxX ? maxX : minX) - boundedOffsetX : 0
        let deltaY = boundedOffsetY < minY || boundedOffsetY > maxY ? (boundedOffsetY > maxY ? maxY : minY) - boundedOffsetY : 0

        return CGSize(
            width: boundedOffsetX + deltaX * springForce,
            height: boundedOffsetY + deltaY * springForce
        )
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
