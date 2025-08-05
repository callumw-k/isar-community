import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:isar_community_generator/isar_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('Error case', () {
    for (final file in Directory('test/errors').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;

      test(file.path, () async {
        final content = await file.readAsLines();

        final errorMessage = content.first.split('//').last.trim();

        var error = '';
        try {
          final assets = {
            'a|${file.path}': content.join('\n'),
          };

          const isarPath = '../isar_community/lib';
          assets.addAll({
            'isar_community|lib/isar.dart':
                await File('$isarPath/isar.dart').readAsString(),
            'isar_community|lib/src/annotations/collection.dart':
                await File(
                  '$isarPath/src/annotations/collection.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/embedded.dart':
                await File(
                  '$isarPath/src/annotations/embedded.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/index.dart':
                await File(
                  '$isarPath/src/annotations/index.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/name.dart':
                await File(
                  '$isarPath/src/annotations/name.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/backlink.dart':
                await File(
                  '$isarPath/src/annotations/backlink.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/ignore.dart':
                await File(
                  '$isarPath/src/annotations/ignore.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/enumerated.dart':
                await File(
                  '$isarPath/src/annotations/enumerated.dart',
                ).readAsString(),
            'isar_community|lib/src/annotations/type.dart':
                await File(
                  '$isarPath/src/annotations/type.dart',
                ).readAsString(),
            // Add core type definitions
            'isar_community|lib/src/isar.dart':
                await File('$isarPath/src/isar.dart').readAsString(),
            'isar_community|lib/src/isar_link.dart':
                await File('$isarPath/src/isar_link.dart').readAsString(),
            'isar_community|lib/src/schema/collection_schema.dart':
                await File(
                  '$isarPath/src/schema/collection_schema.dart',
                ).readAsString(),
            'isar_community|lib/src/schema/property_schema.dart':
                await File(
                  '$isarPath/src/schema/property_schema.dart',
                ).readAsString(),
            'isar_community|lib/src/schema/index_schema.dart':
                await File(
                  '$isarPath/src/schema/index_schema.dart',
                ).readAsString(),
            'isar_community|lib/src/schema/link_schema.dart':
                await File(
                  '$isarPath/src/schema/link_schema.dart',
                ).readAsString(),
            'isar_community|lib/src/schema/schema.dart':
                await File('$isarPath/src/schema/schema.dart').readAsString(),
          });

          await testBuilder(
            getIsarGenerator(BuilderOptions.empty),
            assets,
            onLog: (record) {
              if (record.level >= Level.SEVERE) {
                error = record.message;
              }
            },
          );
        } on Exception catch (e) {
          error = e.toString();
        }

        expect(error.toLowerCase(), contains(errorMessage.toLowerCase()));
      });
    }
  });
}
