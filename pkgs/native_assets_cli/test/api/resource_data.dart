import 'package:native_assets_cli/src/model/resource_identifiers.dart';

const resourceFile = '''{
  "_comment": "Resources referenced by annotated resource identifiers",
  "AppTag": "TBD",
  "environment": {
    "dart.tool.dart2js": false
  },
  "identifiers": []
}''';

final resourceIdentifiers = ResourceIdentifiers(identifiers: [
  Identifier(
    name: 'methodName1',
    id: 'someMetadata',
    uri: Uri.file('path/to/file').toFilePath(),
    nonConstant: true,
    files: [
      ResourceFile(part: 1, references: [
        ResourceReference(
          uri: Uri.file('path/to/reference').toFilePath(),
          line: 2,
          column: 4,
          arguments: {
            '1': 'Some positional argument',
          },
        ),
      ]),
    ],
  ),
  Identifier(
    name: 'methodName2',
    id: 'someOtherMetadata',
    uri: Uri.file('path/to/other/file').toFilePath(),
    nonConstant: false,
    files: [
      ResourceFile(part: 1, references: [
        ResourceReference(
          uri: Uri.file('path/to/reference').toFilePath(),
          line: 15,
          column: 3,
          arguments: {
            'namedIntParam': 1,
          },
        ),
      ]),
      ResourceFile(part: 2, references: [
        ResourceReference(
          uri: Uri.file('path/to/reference').toFilePath(),
          line: 15,
          column: 3,
          arguments: {
            'namedIntParam': 2,
          },
        ),
      ]),
    ],
  ),
]);

const resourceIdentifiersJson = '''
{
  "identifiers": [
    {
      "name": "methodName1",
      "id": "someMetadata",
      "uri": "path/to/file",
      "nonConstant": true,
      "files": [
        {
          "part": 1,
          "references": [
            {
              "@": {
                "uri": "path/to/reference",
                "line": 2,
                "column": 4
              },
              "1": "Some positional argument"
            }
          ]
        }
      ]
    },
    {
      "name": "methodName2",
      "id": "someOtherMetadata",
      "uri": "path/to/other/file",
      "nonConstant": false,
      "files": [
        {
          "part": 1,
          "references": [
            {
              "@": {
                "uri": "path/to/reference",
                "line": 15,
                "column": 3
              },
              "namedIntParam": 1
            }
          ]
        },
        {
          "part": 2,
          "references": [
            {
              "@": {
                "uri": "path/to/reference",
                "line": 15,
                "column": 3
              },
              "namedIntParam": 2
            }
          ]
        }
      ]
    }
  ]
}''';
