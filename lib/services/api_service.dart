import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destination_model.dart';

class ApiService {
  static const String baseUrl =
      "http://192.168.100.103:8080/api";

  // ===========================
  // GET ALL
  // ===========================

  static Future<List<dynamic>> getDestinations() async {
  print("REQUEST => $baseUrl/destinations");

  final response =
      await http.get(Uri.parse("$baseUrl/destinations"));

  print("STATUS => ${response.statusCode}");
  print("BODY => ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("HTTP ${response.statusCode}");
  }

  final json = jsonDecode(response.body);

  print("JSON TYPE = ${json.runtimeType}");
  print("DATA TYPE = ${json["data"].runtimeType}");

  return json["data"] as List<dynamic>;
}

  // ===========================
  // INSERT
  // ===========================

  static Future<void> addDestination(
      Destination destination) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/destinations"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(destination.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  // ===========================
  // UPDATE
  // ===========================

  static Future<void> updateDestination(
      Destination destination) async {
    final response = await http.put(
      Uri.parse(
          "$baseUrl/admin/destinations/${destination.id}"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(destination.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // ===========================
  // DELETE
  // ===========================

  static Future<void> deleteDestination(
      String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/destinations/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}