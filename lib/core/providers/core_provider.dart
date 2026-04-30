import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final connectivityProvider = Provider((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio; // This uses the class we wrote with the Interceptors
});
