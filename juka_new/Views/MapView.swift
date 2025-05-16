@EnvironmentObject var locationManager: LocationManager
@State private var position: MapCameraPosition = .region(MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 25.0427731, longitude: 121.5140326),
    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
)) 