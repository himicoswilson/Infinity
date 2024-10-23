import SwiftUI

class RefreshManager: ObservableObject {
    @Published var shouldRefresh: Bool = false
    
    func refresh() {
        shouldRefresh.toggle()
    }
}
