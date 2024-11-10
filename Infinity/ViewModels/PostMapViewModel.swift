import MapKit
import SwiftUI

class PostMapViewModel: ObservableObject {
    @Published private(set) var region: MKCoordinateRegion
    @Published private(set) var visiblePosts: [PostDTO]
    @Published private(set) var selectedPost: PostDTO
    @Published private(set) var selectedPosts: [PostDTO] = []
    @Published private(set) var isLoading = false
    
    private let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    private let focusedSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    init(post: PostDTO) {
        self.selectedPost = post
        self.visiblePosts = [post]
        
        if let location = post.location.first {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                ),
                span: focusedSpan
            )
        } else {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
                span: defaultSpan
            )
        }
    }
    
    func handlePostSelection(_ post: PostDTO, selectAllAtLocation: Bool) {
        Task { @MainActor in
            let locationId = post.location.first?.locationID
            let postsAtSameLocation = visiblePosts.filter {
                $0.location.first?.locationID == locationId
            }
            selectedPosts = selectAllAtLocation ? postsAtSameLocation : [post]
            selectedPost = post
            updateRegion(for: post)
        }
    }
    
    private func updateRegion(for post: PostDTO) {
        guard let location = post.location.first else { return }
        let newRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: focusedSpan
        )
        region = newRegion
    }
    
    @MainActor
    func loadNearbyPosts() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let radius = Int(calculateRadius(for: region.span))
            let endpoint = "\(Constants.APIEndpoints.postsNearby)/\(selectedPost.postID)?radius=\(radius)&page=1&size=10"
            
            let posts: [PostDTO] = try await APIService.shared.request(
                endpoint,
                method: .get
            )
            
            let filteredPosts = posts.filter { $0.id != selectedPost.id }
            visiblePosts = [selectedPost] + filteredPosts
        } catch {
            print("Error loading nearby posts: \(error)")
        }
        
        isLoading = false
    }
    
    private func calculateRadius(for span: MKCoordinateSpan) -> Double {
        let latDelta = span.latitudeDelta
        return latDelta * 111000 / 2
    }
}
