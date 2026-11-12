class UpdateException implements Exception {
  const UpdateException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Stable releases use exactly X.Y.Z; builds increase independently on Android.
int compareVersions(String left, String right) {
  List<int> parts(String value) {
    final normalized = value.replaceFirst(RegExp(r'^v'), '');
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(normalized)) {
      throw const UpdateException('La versión publicada no es válida.');
    }
    return normalized.split('.').map(int.parse).toList();
  }

  final a = parts(left);
  final b = parts(right);
  for (var i = 0; i < 3; i++) {
    final difference = a[i].compareTo(b[i]);
    if (difference != 0) return difference;
  }
  return 0;
}

class UpdateRelease {
  const UpdateRelease({
    required this.version,
    required this.buildNumber,
    required this.notes,
    required this.url,
    required this.size,
    required this.sha256,
  });
  final String version;
  final int buildNumber;
  final String notes;
  final Uri url;
  final int size;
  final String sha256;

  factory UpdateRelease.fromManifest(
    Map<String, dynamic> json, {
    required String tag,
    required String notes,
    required Uri url,
    required String assetName,
    required int assetSize,
  }) {
    final version = json['version'];
    final build = json['buildNumber'];
    final size = json['size'];
    final hash = json['sha256'];
    if (version is! String ||
        'v$version' != tag ||
        build is! int ||
        build <= 0 ||
        size is! int ||
        size <= 0 ||
        size != assetSize ||
        json['file'] != assetName ||
        hash is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) {
      throw const UpdateException(
        'Los datos de la actualización no son válidos.',
      );
    }
    compareVersions(version, version);
    return UpdateRelease(
      version: version,
      buildNumber: build,
      notes: notes,
      url: url,
      size: size,
      sha256: hash,
    );
  }
}
