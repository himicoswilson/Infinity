import SwiftUI
import UIKit

struct PhotoPreviewControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    @Environment(\.colorScheme) var colorScheme
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(context.coordinator, action: #selector(Coordinator.updateCurrentPage(sender:)), for: .valueChanged)
        updateControlAppearance(control)
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
        updateControlAppearance(uiView)
    }
    
    private func updateControlAppearance(_ control: UIPageControl) {
        // 根据暗色模式调整颜色
        if colorScheme == .dark {
            control.pageIndicatorTintColor = .gray
            control.currentPageIndicatorTintColor = .white
        } else {
            control.pageIndicatorTintColor = .lightGray
            control.currentPageIndicatorTintColor = .black
        }
    }
    
    class Coordinator: NSObject {
        var control: PhotoPreviewControl
        
        init(_ control: PhotoPreviewControl) {
            self.control = control
        }
        
        @objc
        func updateCurrentPage(sender: UIPageControl){
            control.currentPage = sender.currentPage
        }
    }
}
