import 'dart:convert';

import 'package:kinfolk/kinfolk.dart';
import 'package:kinfolk/model/cuba_entity_filter.dart';
import 'package:kinfolk/model/url_types.dart';
import 'package:kinfolk/service/auth.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class RestHelper {
  getSingleModelRest({
    required String serviceOrEntityName,
    required String methodName,
    required Types type,
    String? body,
    required Function(Map<String, dynamic> json) fromMap,
  }) async {
    String urlStr = Kinfolk.createRestUrl(serviceOrEntityName, methodName, type);
    oauth2.Client? client = await Authorization().client;
    Uri url = Uri.parse(urlStr);

    var response;

    if (body != null) {
      response = await getPostResponse(url: url, body: body, client: client!);
    } else {
      response = await getGetResponse(url: url, client: client!);
    }

    var respBody = response.body;
    if (respBody.runtimeType == String && respBody.isEmpty) return null;

    var source = jsonDecode(respBody);
    assert(source is Map, 'Response is ${source.toString()}');

    return fromMap(source);
  }

  getSingleValueRest({
    required String serviceOrEntityName,
    required String methodName,
    required Types type,
    String? body,
  }) async {
    String urlStr = Kinfolk.createRestUrl(serviceOrEntityName, methodName, type);
    oauth2.Client? client = await Authorization().client;
    Uri url = Uri.parse(urlStr);

    var response;

    if (body != null) {
      response = await getPostResponse(url: url, body: body, client: client!);
    } else {
      response = await getGetResponse(url: url, client: client!);
    }

    var respBody = response.body;
    if (respBody.runtimeType == String && respBody.isEmpty) return null;

    var source = jsonDecode(respBody);

    return source;
  }

  getListModelRest({
    required String serviceOrEntityName,
    required String methodName,
    required Types type,
    String? body,
    required Function(Map<String, dynamic> json) fromMap,
    CubaEntityFilter? filter,
  }) async {
    Uri url = Uri.parse(Kinfolk.createRestUrl(serviceOrEntityName, methodName, type));
    oauth2.Client? client = await Authorization().client;

    var response;

    if (filter != null) {
      assert(type == Types.entities, "Filter can be used only with Types.entities");
      response = await getPostResponse(
        url: url,
        body: filter.toJson(),
        client: client!,
      );
    } else {
      if (body != null) {
        response = await getPostResponse(url: url, body: body, client: client!);
      } else {
        response = await getGetResponse(url: url, client: client!);
      }
    }
    var respBody = response.body;
    if (respBody.runtimeType == String && respBody.isEmpty) return null;

    var source = jsonDecode(respBody);
    assert(source is List, "Response is" + "\n$respBody");

    return source.map((item) => fromMap(item)).toList();
  }

  getPostResponse({required url, required body, required oauth2.Client client}) async =>
      await client.post(url, body: body, headers: Kinfolk.appJsonHeader);

  getGetResponse({required url, required oauth2.Client client}) async =>
      await client.get(url, headers: Kinfolk.appJsonHeader);
}
