import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_3d/screens/current_location_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Map<String, String> regions = {};
  Map<String, String> provinces = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  Future<void> callAPI() async {
    //https://psgc.gitlab.io/api/island-groups/
    var url = Uri.https('psgc.gitlab.io', 'api/island-groups');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    List decodedResponse = jsonDecode(response.body);
    decodedResponse.forEach((element) {
      Map item = element;
      print(item['code']);
    });
  }

  Future<void> loadRegions() async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      //process
      List decodedResponse = jsonDecode(response.body);
      decodedResponse.forEach((element) {
        Map item = element;
        // print(item['code'] + item['regionName']);
        //map key:value -> code: regionName
        regions.addAll({item['code']: item['regionName']});
      });
    }
    print(regions);
    setState(() {
      isRegionsLoaded = true;
    });
  }

  Future<void> loadProvinces(String regionCode) async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/$regionCode/provinces/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      //process
      List decodedResponse = jsonDecode(response.body);
      provinces.clear();
      decodedResponse.forEach((element) {
        Map item = element;
        //map key:value -> code: name
        provinces.addAll({item['code']: item['name']});
      });
    }
    print(provinces);
    setState(() {
      isProvincesLoaded = true;
    });
  }

  Future<void> register() async {
    var url = Uri.parse('http://132.168.13.238/flutter_3d_php/register.php');
    await http.post(url, body: {
      'username': _usernameController.text,
      'province': _provinceController.text
    }).then((response) {
      Map decodedResponse = jsonDecode(response.body);
      print(decodedResponse['message']);
      if (decodedResponse['status'] == 'ok') {
        //navigate to another screen
        Navigator.push(context,
            CupertinoPageRoute(builder: (_) => const CurrentLocationScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decodedResponse['message'])),
        );
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 12,
          ),
          if (isRegionsLoaded)
            DropdownMenu(
              label: const Text('Region'),
              width: MediaQuery.of(context).size.width,
              enableSearch: true,
              // enableFilter: true,
              dropdownMenuEntries: regions.entries.map((item) {
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              onSelected: (value) {
                print(value);
                setState(() {
                  isProvincesLoaded = false;
                });

                loadProvinces(value!);
              },
            )
          else
            Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 8,
          ),
          if (isProvincesLoaded)
            DropdownMenu(
              controller: _provinceController,
              label: const Text('Provinces'),
              width: MediaQuery.of(context).size.width,
              enableSearch: true,
              // enableFilter: true,
              dropdownMenuEntries: provinces.entries.map((item) {
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              onSelected: (value) {
                print(value);
              },
            )
          else
            DropdownMenu(
              label: const Text('Provinces'),
              width: MediaQuery.of(context).size.width,
              dropdownMenuEntries: [],
            ),
          TextField(
            controller: _usernameController,
          ),
          ElevatedButton(
            onPressed: register,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
