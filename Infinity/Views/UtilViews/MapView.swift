import SwiftUI
import MapKit
import CoreLocation
import Combine

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationService = LocationService()
    @Binding var selectedLocation: Location?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var searchText: String = ""
    @State private var searchSubject = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var shouldUpdateCenter = true
    
    @State private var searchResults: [Location] = []  // 存储搜索结果
    @State private var selectedPin: Location?  // 添加选中的标注
    
    var body: some View {
        NavigationView {
            MapContentView(
                locationService: locationService,
                region: $region,
                searchText: $searchText,
                searchResults: $searchResults,
                selectedPin: $selectedPin
            )
                .ignoresSafeArea(.all, edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(selectedLocation != nil ? "清空" : "取消") {
                            selectedLocation = nil  // 清空选择
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.primary)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("选择地点")
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("确定") {
                            if let selected = selectedPin {
                                selectedLocation = selected
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .disabled(selectedPin == nil)
                        .foregroundColor(selectedPin != nil ? .primary : .gray)
                    }
                }
        }
        .onAppear {
            setupSearchDebounce()
            locationService.requestLocationPermission()
            
            // 如果有初始选中的位置，更新地图和标记
            if let location = selectedLocation {
                selectedPin = location
                searchResults = [location]
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                shouldUpdateCenter = false
            } else {
                locationService.startUpdatingLocation()
                // 使用 Task 包装异步代码
                Task {
                    do {
                        // 获取当前位置名称
                        let locationName = try await LocationUtils.shared.reverseGeocode(
                            latitude: locationService.currentLocation?.coordinate.latitude ?? 0,
                            longitude: locationService.currentLocation?.coordinate.longitude ?? 0
                        )
                        // 在主线程更新 UI
                        await MainActor.run {
                            selectedPin = Location(
                                latitude: locationService.currentLocation?.coordinate.latitude ?? 0,
                                longitude: locationService.currentLocation?.coordinate.longitude ?? 0,
                                locationName: locationName
                            )
                        }
                    } catch {
                        print("获取位置名称失败：\(error)")
                    }
                }
            }
        }
        .onChange(of: searchText) { newValue in
            searchSubject.send(newValue)
        }
        .onChange(of: locationService.currentLocation) { newLocation in
            guard shouldUpdateCenter else { return }
            
            if let location = newLocation?.coordinate {
                withAnimation {
                    region.center = location
                }
                shouldUpdateCenter = false
            }
        }
    }
    
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { searchText in
                guard !searchText.isEmpty else {
                    searchResults = []
                    return
                }
                searchLocations()
            }
            .store(in: &cancellables)
    }
    
    private func searchLocations() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("搜索错误: \(error.localizedDescription)")
                    return
                }
                
                self.searchResults = response?.mapItems.map { item in
                    // 构建位置名称，处理可选值
                    var components: [String] = []
                    
                    if let name = item.name {
                        components.append(name)
                    }
                    if let thoroughfare = item.placemark.thoroughfare {
                        components.append(thoroughfare)
                    }
                    if let locality = item.placemark.locality {
                        components.append(locality)
                    }
                    
                    let locationName = components.isEmpty ? "未知位置" : components.joined(separator: ", ")
                    
                    return Location(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude,
                        locationName: locationName
                    )
                } ?? []
                
                if let firstResult = self.searchResults.first {
                    withAnimation {
                        self.region.center = firstResult.coordinate
                    }
                }
            }
        }
    }
}

// 创建新的子视图来处理地图内容
private struct MapContentView: View {
    @ObservedObject private var locationService: LocationService
    @Binding private var region: MKCoordinateRegion
    @Binding private var searchText: String
    @Binding private var searchResults: [Location]
    @Binding private var selectedPin: Location?
    
    init(locationService: LocationService,
         region: Binding<MKCoordinateRegion>,
         searchText: Binding<String>,
         searchResults: Binding<[Location]>,
         selectedPin: Binding<Location?>) {
        self._locationService = ObservedObject(wrappedValue: locationService)
        self._region = region
        self._searchText = searchText
        self._searchResults = searchResults
        self._selectedPin = selectedPin
    }
    
    var body: some View {
        ZStack {
            VStack {
                SearchBarView(searchText: $searchText)
                ZStack {
                    MapContainerView(
                        region: $region,
                        searchResults: $searchResults,
                        selectedPin: $selectedPin
                    )
                    
                    // // 添加定位按钮
                    // VStack {
                    //     Spacer()
                    //     HStack {
                    //         Spacer()
                    //         LocationButtonView(action: centerOnUserLocation)
                    //             .padding()
                    //     }
                    // }
                }
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationService.currentLocation?.coordinate {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location,
                    span: region.span  // 保持当前缩放级别
                )
            }
        }
    }
}

// 搜索栏视图
private struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        TextField("搜索地点", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
}

// 地图容器视图
private struct MapContainerView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var searchResults: [Location]
    @Binding var selectedPin: Location?
    
    // 创建 Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 创建 UIView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.region = region
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    // 更新 UIView
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 如果当前地图区域和目标区域相等，就不需要更新
        if coordinateRegionsAreEqual(mapView.region, region) {
            return
        }
        
        mapView.setRegion(region, animated: true)
        
        // 更新标注
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        let annotations = searchResults.map { location -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = location.locationName
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    // 添加坐标区域比较方法
    private func coordinateRegionsAreEqual(_ region1: MKCoordinateRegion, _ region2: MKCoordinateRegion) -> Bool {
        let center1 = region1.center
        let center2 = region2.center
        let span1 = region1.span
        let span2 = region2.span
        
        return abs(center1.latitude - center2.latitude) < 0.000001 &&
               abs(center1.longitude - center2.longitude) < 0.000001 &&
               abs(span1.latitudeDelta - span2.latitudeDelta) < 0.000001 &&
               abs(span1.longitudeDelta - span2.longitudeDelta) < 0.000001
    }
    
    // Coordinator 类
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapContainerView
        private let geocoder = CLGeocoder()
        
        init(_ parent: MapContainerView) {
            self.parent = parent
            super.init()
        }
        
        // 处理标注点击事件
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if annotation is MKUserLocation {
                return
            }
            
            // 只更新选中的位置，不改变地图缩放
            if let title = annotation.title ?? nil,
               let location = parent.searchResults.first(where: { $0.locationName == title }) {
                parent.selectedPin = location
            }
        }
        
        // 处理地图点击事件
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // 直接创建一个基本位置，以防地理编码失败
            let basicLocation = Location(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                locationName: String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
            )
            
            Task {
                do {
                    let locationName = try await LocationUtils.shared.reverseGeocode(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                    
                    let newLocation = Location(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        locationName: locationName
                    )
                    
                    DispatchQueue.main.async {
                        self.parent.searchResults = [newLocation]
                        self.parent.selectedPin = newLocation
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.parent.searchResults = [basicLocation]
                        self.parent.selectedPin = basicLocation
                    }
                }
            }
        }
        
        
        // 处理标注按钮点击
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation,
               let title = annotation.title ?? nil,
               let location = parent.searchResults.first(where: { $0.locationName == title }) {
                parent.selectedPin = location
            }
        }
    }
}

// 定位按钮视图
private struct LocationButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SwiftUI.Image(systemName: "location.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
                .padding()
        }
    }
}
