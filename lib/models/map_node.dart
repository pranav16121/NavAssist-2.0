class MapNode {
  final String id;
  final String name;
  final double x;
  final double y;
  final int sequence;
  final int stepsFromPrevious;
  final double distanceFromPrevious;
  final String turn; // 'straight', 'left', 'right', 'u_turn' etc.

  MapNode({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.sequence = 0,
    this.stepsFromPrevious = 0,
    this.distanceFromPrevious = 0.0,
    this.turn = 'straight',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'sequence': sequence,
      'stepsFromPrevious': stepsFromPrevious,
      'distanceFromPrevious': distanceFromPrevious,
      'turn': turn,
    };
  }

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
      id: json['id'] as String,
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      sequence: json['sequence'] as int? ?? 0,
      stepsFromPrevious: json['stepsFromPrevious'] as int? ?? 0,
      distanceFromPrevious: (json['distanceFromPrevious'] as num? ?? 0.0).toDouble(),
      turn: json['turn'] as String? ?? 'straight',
    );
  }
}
