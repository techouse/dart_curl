import 'dart:convert' show utf8;
import 'dart:io' as io show Platform;

import 'package:crypto/crypto.dart' as crypto show md5;
import 'package:curl/curl.dart';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http show Request;
import 'package:test/test.dart';

extension on String {
  String get md5hex => crypto.md5.convert(utf8.encode(this)).toString();
}

void main() {
  final Faker faker = new Faker();

  late Uri endpoint;
  late Uri endpointWithQuery;

  setUp(() {
    endpoint = Uri.parse(faker.internet.httpsUrl());
    endpointWithQuery = Uri.https(
      faker.internet.domainName(),
      faker.internet.domainWord(),
      <String, String>{
        faker.lorem.word(): faker.lorem.word(),
        faker.lorem.word(): faker.lorem.word(),
        faker.lorem.word(): faker.lorem.word(),
        faker.lorem.word(): faker.lorem.word(),
      },
    );
  });

  test('GET request', () {
    final http.Request req = http.Request('GET', endpoint);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpoint" --compressed --insecure'''
          : '''curl '$endpoint' --compressed --insecure''',
    );
  });

  test('GET request with query parameters', () {
    final http.Request req = http.Request('GET', endpointWithQuery);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpointWithQuery" --compressed --insecure'''
          : '''curl '$endpointWithQuery' --compressed --insecure''',
    );
  });

  test('GET request with headers', () {
    final http.Request req = http.Request('GET', endpoint);
    final String cookie =
        'sessionid=${faker.randomGenerator.string(32).md5hex}; csrftoken=${faker.randomGenerator.string(32).md5hex};';
    final String ua = 'Thor';
    req.headers['Cookie'] = cookie;
    req.headers['User-Agent'] = ua;
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpoint" -H "Cookie: $cookie" -H "User-Agent: $ua" --compressed --insecure'''
          : '''curl '$endpoint' -H 'Cookie: $cookie' -H 'User-Agent: $ua' --compressed --insecure''',
    );
  });

  test('POST request', () {
    final http.Request req = http.Request('POST', endpoint);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpoint" -X POST --compressed --insecure'''
          : '''curl '$endpoint' -X POST --compressed --insecure''',
    );
  });

  test('POST request with query parameters ', () {
    final http.Request req = http.Request('POST', endpointWithQuery);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpointWithQuery" -X POST --compressed --insecure'''
          : '''curl '$endpointWithQuery' -X POST --compressed --insecure''',
    );
  });

  test(
    'POST request with parts',
    () {
      final http.Request req = http.Request('POST', endpoint);
      final String part1 = 'This is the part one of content';
      final String part2 = 'This is the part two of content😅';
      final String expectQuery =
          '''part1=This%20is%20the%20part%20one%20of%20content&part2=This%20is%20the%20part%20two%20of%20content%F0%9F%98%85''';
      req.bodyFields = {
        'part1': part1,
        'part2': part2,
      };
      expect(
        toCurl(req),
        io.Platform.isWindows
            ? '''curl "$endpoint" -H "content-type: application/x-www-form-urlencoded; charset=utf-8" --data "$expectQuery" --compressed --insecure'''
            : '''curl '$endpoint' -H 'content-type: application/x-www-form-urlencoded; charset=utf-8' --data '$expectQuery' --compressed --insecure''',
      );
    },
    onPlatform: {
      'windows': Skip('TODO: investigate %20 encoding issues on Windows.'),
    },
  );

  test(
    'PUT request with body',
    () {
      final http.Request req = http.Request('PUT', endpoint);
      req.body = 'This is the text of body😅, \\, \\\\, \\\\\\';
      expect(
        toCurl(req),
        io.Platform.isWindows
            ? '''curl "$endpoint" -X PUT -H "content-type: text/plain; charset=utf-8" --data-binary \$"This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\" --compressed --insecure'''
            : '''curl '$endpoint' -X PUT -H 'content-type: text/plain; charset=utf-8' --data-binary \$'This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\' --compressed --insecure''',
      );
    },
    onPlatform: {
      'windows': Skip('TODO: investigate \$ encoding issues on Windows.'),
    },
  );

  test(
    'PUT request with body and query parameters',
    () {
      final http.Request req = http.Request('PUT', endpointWithQuery);
      req.body = 'This is the text of body😅, \\, \\\\, \\\\\\';
      expect(
        toCurl(req),
        io.Platform.isWindows
            ? '''curl "$endpointWithQuery" -X PUT -H "content-type: text/plain; charset=utf-8" --data-binary \$"This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\" --compressed --insecure'''
            : '''curl '$endpointWithQuery' -X PUT -H 'content-type: text/plain; charset=utf-8' --data-binary \$'This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\' --compressed --insecure''',
      );
    },
    onPlatform: {
      'windows': Skip('TODO: investigate \$ encoding issues on Windows.'),
    },
  );

  test(
    'PATCH request with body',
    () {
      final http.Request req = http.Request('PATCH', endpoint);
      req.body = 'This is the text of body😅, \\, \\\\, \\\\\\';
      expect(
        toCurl(req),
        io.Platform.isWindows
            ? '''curl "$endpoint" -X PATCH -H "content-type: text/plain; charset=utf-8" --data-binary \$"This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\" --compressed --insecure'''
            : '''curl '$endpoint' -X PATCH -H 'content-type: text/plain; charset=utf-8' --data-binary \$'This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\' --compressed --insecure''',
      );
    },
    onPlatform: {
      'windows': Skip('TODO: investigate \$ encoding issues on Windows.'),
    },
  );

  test(
    'PATCH request with body and query parameters',
    () {
      final http.Request req = http.Request('PATCH', endpointWithQuery);
      req.body = 'This is the text of body😅, \\, \\\\, \\\\\\';
      expect(
        toCurl(req),
        io.Platform.isWindows
            ? '''curl "$endpointWithQuery" -X PATCH -H "content-type: text/plain; charset=utf-8" --data-binary \$"This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\" --compressed --insecure'''
            : '''curl '$endpointWithQuery' -X PATCH -H 'content-type: text/plain; charset=utf-8' --data-binary \$'This is the text of body\\ud83d\\ude05, \\\\, \\\\\\\\, \\\\\\\\\\\\' --compressed --insecure''',
      );
    },
    onPlatform: {
      'windows': Skip('TODO: investigate \$ encoding issues on Windows.'),
    },
  );

  test('DELETE request', () {
    final http.Request req = http.Request('DELETE', endpoint);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpoint" -X DELETE --compressed --insecure'''
          : '''curl '$endpoint' -X DELETE --compressed --insecure''',
    );
  });

  test('DELETE request with query parameters ', () {
    final http.Request req = http.Request('DELETE', endpointWithQuery);
    expect(
      toCurl(req),
      io.Platform.isWindows
          ? '''curl "$endpointWithQuery" -X DELETE --compressed --insecure'''
          : '''curl '$endpointWithQuery' -X DELETE --compressed --insecure''',
    );
  });
}
