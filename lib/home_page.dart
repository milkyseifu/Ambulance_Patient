import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ambulance_patients/utilities/constants.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ambulance_patients/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class Item {
  const Item(this.name,this.icon);
  final String name;
  final Icon icon;
}


class _HomePageState extends State<HomePage> {

  bool _rememberme = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController type = TextEditingController();
  TextEditingController address = TextEditingController();
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(9.1450, 40.4897),
      zoom: 6
  );

  late GoogleMapController _googleMapController;
  late Marker _origin;
  late Marker _destination;
  late Position _currentPosition, _lastPosition;
  late String _currentAddress, _startAddress, _destinationAddress;
  Set<Marker> markers = {};
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late double current_lat, current_long;
  String? _placeDistance;

  Future signUp() async{
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      // print(pos);
      _currentPosition = position;

      current_lat = _currentPosition.latitude;
      current_long = _currentPosition.longitude;
      var url = Uri.parse("http://192.168.43.225:8080/incidentregister.php");

      var response = await http.post(url, body: {
        "fname":fname.text,
        "lname":lname.text,
        "pnum":type.text,
        "latitude": current_lat.toString(),
        "longitude": current_long.toString(),
        "address": address.text,
      });
      var data = json.decode(response.body);
      // Fluttertoast.showToast(msg: latitude.toString());
      if(data == "Success"){
        Fluttertoast.showToast(
            msg: "Requested Successfully!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.green,
            fontSize:25
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }else{
        Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize:25
        );
      }
    });
  }

  _builfirstNameofPatient(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'First Name',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                hintText: 'First Name of the Patient',
                hintStyle: kHintTextStyle
            ),
            controller: fname,
            validator: (value){
              if(value == null || value.isEmpty){
                return 'Please enter some text';
              }
              return null;
            },
          ),
        )
      ],
    );
  }

  _buillastNameofPatient(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Last Name',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                hintText: 'Last Name of the Patient',
                hintStyle: kHintTextStyle
            ),
            controller: lname,
            validator: (value){
              if(value == null || value.isEmpty){
                return 'Please enter some text';
              }
              return null;
            },
          ),
        )
      ],
    );
  }

  _buildincidenttype(){
      List<String> incidentTypes = [
          'Bleeding', 'Breathing Difficulties', 'Someone Collapses', 'epileptic Seizure', 'Severe Pain', 'Heart Attack', 'A Stroke', 'Pregnant Woman', 'Accident'
      ];
      String selectedtype = "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Incident Type',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        DropDownField(
          controller: type,
          required: true,
          hintText: "Select type of Incident",
          enabled: true,
          items: incidentTypes,
          onValueChanged: (value){
            setState(() {
              selectedtype = value;
            });
          },
        ),
        SizedBox(height: 3.0),
        Text(
          selectedtype,
          style: TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  _builIncidentAddress(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                hintText: 'Address of the Incident',
                hintStyle: kHintTextStyle
            ),
            controller: address,
            validator: (value){
              if(value == null || value.isEmpty){
                return 'Please enter some text';
              }
              return null;
            },
          ),
        )
      ],
    );
  }

  _buildRegBut(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: 300.0,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          signUp();
        },
        padding: EdgeInsets.all(5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.red,
        child: Text(
          'Request',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // late String countr_id;
  // List<String> country = [
  //   'A', 'B', 'C', 'D'
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Incident Types'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF39BAE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 40.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Emergency Form',
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 30.0),
                        _builfirstNameofPatient(),
                        SizedBox(height: 30.0),
                        _buillastNameofPatient(),
                        SizedBox(height: 30.0),
                        _buildincidenttype(),
                        // SizedBox(height: 30.0),
                        _builIncidentAddress(),
                        // _buildMapPage(),
                        SizedBox(height: 30.0,),
                        // _buildRegBut(),
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 25.0),
                            width: 300.0,
                            child: RaisedButton(
                              elevation: 5.0,
                              onPressed: () {
                                if(_formKey.currentState !.validate()){
                                  signUp();
                                  Scaffold.of(context).
                                  showSnackBar(SnackBar(content: Text('Processing Data'),
                                  )
                                  );
                                }
                              },
                              padding: EdgeInsets.all(5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: Colors.red,
                              child: Text(
                                'Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                      )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}