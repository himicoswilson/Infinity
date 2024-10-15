import SwiftUI

struct PhotoPreviewView: View {
    var images: [ImageDTO]
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PhotoPreviewController(pages: images.map { image in
                ZoomableImageView(imageURL: image.imageURL) { direction in
                    switch direction {
                    case .left:
                        print("left")
                        currentPage = (currentPage + 1) % images.count
                    case .right:
                        print("right")
                        currentPage = (currentPage - 1 + images.count) % images.count
                    }
                }
            }, currentPage: $currentPage)
            
            if images.count > 1 {
                PhotoPreviewControl(numberOfPages: images.count, currentPage: $currentPage)
                    .frame(width: CGFloat(images.count * 18))
                    .scaleEffect(0.75)
                    .padding(.bottom, 20)
            }
        }
    }
}
