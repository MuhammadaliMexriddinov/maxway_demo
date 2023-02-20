import 'package:dio/dio.dart';

import '../branch_model.dart';
import '../data.dart';

class MapApi {
  Future<MaxWayBranch> getItems() async {
    final response = await Dio().get(
        "https://maxway.uz/_next/data/ch7KmKvJ5azfPmlISTmjb/uz/branches.json");
    return MaxWayBranch.fromJson(response.data);
  }
}
