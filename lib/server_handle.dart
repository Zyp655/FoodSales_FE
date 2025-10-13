import 'dart:convert';
import 'package:cnpm_ptpm/models/sellers.dart';
import 'package:http/http.dart' as http;

class ServerHandler{
  final String _baseUrl = 'http://10.0.2.2/CNPM_PTPW/api/';

  Future<List<Sellers>> getSellers() async{
    try{
      List<Sellers> sellers = [];

      http.Response response = await http.get(Uri.parse('$_baseUrl/gen/sellers'));

      List sellersList = (json.decode(response.body))['sellers'];
      for(Map m in sellersList){
        sellers.add(Sellers.fromMap(m));

      }
      return sellers;
    }catch(e){
      print('Server Handler : error : ' + e.toString());
      rethrow;
    }
  }
}