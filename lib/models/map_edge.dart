class MapEdge {
  final String from;
  final String to;
  final double distance;
  final String direction; // e.g., 'forward', 'turn_left'

  MapEdge({
    required this.from,
    required this.to,
    required this.distance,
    required this.direction,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'distance': distance,
      'direction': direction,
    };
  }

  factory MapEdge.fromJson(Map<String, dynamic> json) {
    return MapEdge(
      from: json['from'] as String,
      to: json['to'] as String,
      distance: (json['distance'] as num).toDouble(),
      direction: json['direction'] as String,
    );
  }
}
