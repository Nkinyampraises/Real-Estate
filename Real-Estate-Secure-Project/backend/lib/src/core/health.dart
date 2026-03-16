abstract class JsonSerializable {
  Map<String, Object?> toJson();
}

class HealthStatus implements JsonSerializable {
  final String status;
  final String environment;
  final String version;
  final DateTime timestamp;
  final List<String> tags;
  final String tagLine;

  const HealthStatus({
    required this.status,
    required this.environment,
    required this.version,
    required this.timestamp,
    this.tags = const [],
    this.tagLine = '',
  });

  HealthStatus copyWith({
    String? status,
    String? environment,
    String? version,
    DateTime? timestamp,
    List<String>? tags,
    String? tagLine,
  }) {
    return HealthStatus(
      status: status ?? this.status,
      environment: environment ?? this.environment,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      tagLine: tagLine ?? this.tagLine,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'status': status,
      'environment': environment,
      'version': version,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'tags': tags,
      'tag_line': tagLine,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is HealthStatus &&
        other.status == status &&
        other.environment == environment &&
        other.version == version &&
        other.timestamp == timestamp &&
        _listEquals(other.tags, tags) &&
        other.tagLine == tagLine;
  }

  @override
  int get hashCode => Object.hash(
        status,
        environment,
        version,
        timestamp,
        Object.hashAll(tags),
        tagLine,
      );
}

abstract class HealthCheck {
  Future<HealthStatus> check();
}

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var i = 0; i < left.length; i += 1) {
    if (left[i] != right[i]) {
      return false;
    }
  }

  return true;
}
