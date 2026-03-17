enum HealthStatus { ok, degraded }

class HealthReport {
  const HealthReport({
    required this.status,
    required this.timestamp,
    required this.version,
    this.dependencies,
  });

  final HealthStatus status;
  final DateTime timestamp;
  final String version;
  final Map<String, String>? dependencies;

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'version': version,
        if (dependencies != null) 'dependencies': dependencies,
      };
}
