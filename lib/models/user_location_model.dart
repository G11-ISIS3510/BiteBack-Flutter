class UserLocation {

  final double latitude;
  final double longitude;

  UserLocation({required this.latitude, required this.longitude});

  @override
  String toString() {
    return "$latitude, $longitude";
  }
}
