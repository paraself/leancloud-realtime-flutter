import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancloud_realtime_flutter/LeancloudRealtime.dart';

void main() {
  const MethodChannel channel = MethodChannel('leancloud_realtime_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LeancloudRealtime.platformVersion, '42');
  });
}
