// import SwiftUI
// import MapKit

// struct PostLocation: Identifiable {
//     let id: String
//     let coordinate: CLLocationCoordinate2D
//     let post: PostDTO
//     let locationName: String
// }

// struct AllLocationsMapView: View {
//     @Environment(\.dismiss) private var dismiss
//     @StateObject private var viewModel = AllLocationsViewModel()
//     @State private var selectedPost: PostDTO?
//     @State private var region = MKCoordinateRegion(
//         center: CLLocationCoordinate2D(latitude: 35.0, longitude: 105.0), // 中国中心位置
//         span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
//     )
    
//     var body: some View {
//         NavigationView {
//             ZStack {
//                 Map(coordinateRegion: $region,
//                     annotationItems: viewModel.postLocations) { location in
//                     MapAnnotation(coordinate: location.coordinate) {
//                         Button(action: {
//                             selectedPost = location.post
//                         }) {
//                             VStack {
//                                 SwiftUI.Image(systemName: "mappin.circle.fill")
//                                     .font(.title)
//                                     .foregroundColor(.red)
//                                 Text(location.locationName)
//                                     .font(.caption)
//                                     .foregroundColor(.black)
//                                     .padding(4)
//                                     .background(Color.white)
//                                     .cornerRadius(4)
//                             }
//                         }
//                     }
//                 }
                
//                 if viewModel.isLoading {
//                     ProgressView()
//                 }
//             }
//             .navigationTitle("位置地图")
//             .navigationBarTitleDisplayMode(.inline)
//             .toolbar {
//                 ToolbarItem(placement: .navigationBarLeading) {
//                     Button("关闭") {
//                         dismiss()
//                     }
//                 }
//             }
//         }
//         .sheet(item: $selectedPost) { post in
//             PostDetailView(postdto: post)
//         }
//         .onAppear {
//             viewModel.fetchPostsWithLocation()
//         }
//     }
// }

// class AllLocationsViewModel: ObservableObject {
//     @Published var postLocations: [PostLocation] = []
//     @Published var isLoading = false
    
//     func fetchPostsWithLocation() {
//         Task {
//             isLoading = true
//             do {
//                 let posts: [PostDTO] = try await APIService.shared.request(
//                     Constants.APIEndpoints.postsWithLocation,
//                     method: .get
//                 )
                
//                 await MainActor.run {
//                     self.postLocations = posts.compactMap { post in
//                         guard let location = post.location.first else { return nil }
//                         return PostLocation(
//                             id: post.id,
//                             coordinate: CLLocationCoordinate2D(
//                                 latitude: location.latitude,
//                                 longitude: location.longitude
//                             ),
//                             post: post,
//                             locationName: location.locationName
//                         )
//                     }
//                     self.isLoading = false
//                 }
//             } catch {
//                 print("Error fetching posts with locations: \(error)")
//                 await MainActor.run {
//                     self.isLoading = false
//                 }
//             }
//         }
//     }
// } 
