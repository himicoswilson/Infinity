import SwiftUI

struct PhotoPreviewView: View {
    var images: [ImageDTO]
    @State private var currentPage: Int
    @Environment(\.presentationMode) var presentationMode

    init(images: [ImageDTO], initialPage: Int = 0) {
        self.images = images
        self._currentPage = State(initialValue: initialPage)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PhotoPreviewController(
                pages: images.map { image in
                    ZoomableImageView(imageURL: image.imageURL, onDismiss: {
                        presentationMode.wrappedValue.dismiss()
                    })
                },
                currentPage: $currentPage
            )

            if images.count > 1 {
                PhotoPreviewControl(numberOfPages: images.count, currentPage: $currentPage)
                    .frame(width: CGFloat(images.count * 18))
                    .scaleEffect(0.75)
                    .padding(.bottom, 20)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
