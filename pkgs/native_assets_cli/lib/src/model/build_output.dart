// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_output.dart';

final class BuildOutputImpl implements BuildOutput {
  @override
  final DateTime timestamp;

  final List<AssetImpl> _assets;

  final Map<String, List<AssetImpl>> _assetsForLinking;

  @override
  Iterable<AssetImpl> get assets => _assets;

  @override
  Map<String, List<AssetImpl>> get assetsForLinking => _assetsForLinking;

  final Dependencies _dependencies;

  Dependencies get dependenciesModel => _dependencies;

  @override
  Iterable<Uri> get dependencies => _dependencies.dependencies;

  final Metadata metadata;

  BuildOutputImpl({
    DateTime? timestamp,
    List<AssetImpl>? assets,
    Map<String, List<AssetImpl>>? assetsForLinking,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        _assets = assets ?? [],
        _assetsForLinking = assetsForLinking ?? {},
        // ignore: prefer_const_constructors
        _dependencies = dependencies ?? Dependencies([]),
        // ignore: prefer_const_constructors
        metadata = metadata ?? Metadata({});

  @override
  void addDependency(Uri dependency) =>
      _dependencies.dependencies.add(dependency);

  @override
  void addDependencies(Iterable<Uri> dependencies) =>
      _dependencies.dependencies.addAll(dependencies);

  static const _assetsKey = 'assets';
  static const _dependenciesKey = 'dependencies';
  static const _metadataKey = 'metadata';
  static const _timestampKey = 'timestamp';
  static const _versionKey = 'version';

  factory BuildOutputImpl.fromJsonString(String jsonString) {
    final Object? json;
    if (jsonString.startsWith('{')) {
      json = jsonDecode(jsonString);
    } else {
      // TODO(https://github.com/dart-lang/native/issues/1000): At some point
      // remove the YAML fallback.
      json = loadYaml(jsonString);
    }
    return BuildOutputImpl.fromJson(as<Map<Object?, Object?>>(json));
  }

  factory BuildOutputImpl.fromJson(Map<Object?, Object?> jsonMap) {
    final outputVersion = Version.parse(as<String>(jsonMap['version']));
    if (outputVersion.major > latestVersion.major) {
      throw FormatException(
        'The output version $outputVersion is newer than the '
        'package:native_assets_cli config version $latestVersion in Dart or '
        'Flutter, please update the Dart or Flutter SDK.',
      );
    }
    if (outputVersion.major < latestVersion.major) {
      throw FormatException(
        'The output version $outputVersion is newer than this '
        'package:native_assets_cli config version $latestVersion in Dart or '
        'Flutter, please update native_assets_cli.',
      );
    }

    final assets =
        AssetImpl.listFromJsonList(as<List<Object?>>(jsonMap[_assetsKey]));

    return BuildOutputImpl(
      timestamp: DateTime.parse(as<String>(jsonMap[_timestampKey])),
      assets: assets,
      dependencies:
          Dependencies.fromJson(as<List<Object?>?>(jsonMap[_dependenciesKey])),
      metadata:
          Metadata.fromJson(as<Map<Object?, Object?>?>(jsonMap[_metadataKey])),
    );
  }

  Map<String, Object> toJson(Version version) => {
        _timestampKey: timestamp.toString(),
        _assetsKey: [
          for (final asset in _assets) asset.toJson(version),
        ],
        if (_dependencies.dependencies.isNotEmpty)
          _dependenciesKey: _dependencies.toJson(),
        _metadataKey: metadata.toJson(),
        _versionKey: version.toString(),
      }..sortOnKey();

  String toJsonString(Version version) =>
      const JsonEncoder.withIndent('  ').convert(toJson(version));

  /// The version of [BuildOutputImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs and
  /// packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  ///
  /// [BuildOutput.latestVersion] is tied to [BuildConfig.latestVersion]. This
  /// enables making the JSON serialization in `build.dart` dependent on the
  /// version of the Dart or Flutter SDK. When there is a need to split the
  /// versions of BuildConfig and BuildOutput, the BuildConfig should start
  /// passing the highest supported version of BuildOutput.
  static Version latestVersion = BuildConfigImpl.latestVersion;

  /// Writes the JSON file from [file].
  static Future<BuildOutputImpl?> readFromFile({required Uri file}) async {
    final buildOutputFile = File.fromUri(file);
    if (await buildOutputFile.exists()) {
      return BuildOutputImpl.fromJsonString(
          await buildOutputFile.readAsString());
    }

    return null;
  }

  /// Writes the [toJsonString] to the output file specified in the [config].
  Future<void> writeToFile({required PipelineConfig config}) async {
    final configVersion = (config as PipelineConfigImpl).version;
    final jsonString = toJsonString(configVersion);
    await File.fromUri(config.outputFile)
        .writeAsStringCreateDirectory(jsonString);
  }

  @override
  String toString() => toJsonString(BuildConfigImpl.latestVersion);

  @override
  bool operator ==(Object other) {
    if (other is! BuildOutputImpl) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<AssetImpl>().equals(other._assets, _assets) &&
        other._dependencies == _dependencies &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<AssetImpl>().hash(_assets),
        _dependencies,
        metadata,
      );

  @override
  void addMetadatum(String key, Object value) {
    metadata.metadata[key] = value;
  }

  @override
  void addMetadata(Map<String, Object> metadata) {
    this.metadata.metadata.addAll(metadata);
  }

  Metadata get metadataModel => metadata;

  @override
  void addAsset(Asset asset, {String? linkInPackage}) {
    _getAssetList(linkInPackage).add(asset as AssetImpl);
  }

  @override
  void addAssets(Iterable<Asset> assets, {String? linkInPackage}) {
    _getAssetList(linkInPackage).addAll(assets.cast());
  }

  List<AssetImpl> _getAssetList(String? linkInPackage) => linkInPackage == null
      ? _assets
      : (_assetsForLinking[linkInPackage] ??= []);
}
