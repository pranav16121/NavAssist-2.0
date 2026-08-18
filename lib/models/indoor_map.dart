import 'map_node.dart';
import 'map_edge.dart';

class IndoorMap {
  final String name;
  final int version;
  final List<MapNode> nodes;
  final List<MapEdge> edges;
  final DateTime createdAt;

  IndoorMap({
    required this.name,
    required this.version,
    required this.nodes,
    required this.edges,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalDistance => nodes.fold(0.0, (sum, item) => sum + item.distanceFromPrevious);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IndoorMap.fromJson(Map<String, dynamic> json) {
    return IndoorMap(
      name: json['name'] as String,
      version: json['version'] as int,
      nodes: (json['nodes'] as List).map((n) => MapNode.fromJson(n)).toList(),
      edges: (json['edges'] as List).map((e) => MapEdge.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
