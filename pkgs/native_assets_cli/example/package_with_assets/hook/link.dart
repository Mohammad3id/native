// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await link(args, (config, output) async {
    final packageName = config.packageName;
    final allAssets = [
      DataAsset(
        package: packageName,
        name: 'unused',
        file: config.packageRoot.resolve('assets').resolve('unused_asset.json'),
      ),
      DataAsset(
        package: packageName,
        name: 'used',
        file: config.packageRoot.resolve('assets').resolve('used_asset.json'),
      )
    ];
    output.addAssets(shake(allAssets, config.resources));
  });
}

Iterable<Asset> shake(
  List<DataAsset> allAssets,
  List<Resource> resources,
) =>
    allAssets.where(
      (asset) => resources.any((resource) => resource.metadata == asset.id),
    );
