import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_project/requests/googleMapsRequests.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "hello",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController _googleMapController;
  static LatLng _initialPosition;
  LatLng _finalPosition = _initialPosition;
  final List<Marker> _markersList = [];
  TextEditingController _locationController=TextEditingController();
  TextEditingController _destinationController=TextEditingController();
  GoogleMapsServices _googleMapsServices=GoogleMapsServices();
  final Set<Polyline> _polylines={};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return _initialPosition==null? Container():
    Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: _initialPosition, zoom: 5),
          onMapCreated: _onCreated,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          markers: Set.from(_markersList),
          onCameraMove: _onCameraMove,
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0,top: 10.0),
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 8.0, bottom: 8.0),
                    child: TextField(
                      controller: _locationController,
                      cursorColor: Colors.blue.shade900,
                      decoration: InputDecoration(
                          hintText: "Pick up",
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.red.shade900,
                          )),
                    ),
                  ),
                  color: Colors.grey[100],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 8.0, bottom: 8.0),
                    child: TextField(
                      controller: _destinationController,
                      cursorColor: Colors.blue.shade900,
                      decoration: InputDecoration(
                          hintText: "Destination",
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.local_taxi,
                            color: Colors.blue.shade900,
                          )),
                    ),
                  ),
                  color: Colors.grey[100],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _onCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    print("hello");
    _finalPosition = position.target;
    print(position.target);
  }

  void _onAddMarker() {
    var uuid = new Uuid();
    //uuid.v1();
    setState(() {
      _markersList.add(Marker(
          markerId: MarkerId(uuid.v1()),
          position: _finalPosition,
          infoWindow: InfoWindow(
            title: "remmember here",
            snippet: "good place",
          ),
          icon: BitmapDescriptor.defaultMarker));
    });
  }
  List decodePoly(String poly){
    var list=poly.codeUnits;
    var lList=new List();
    int index=0;
    int len= poly.length;
    int c=0;
// repeating until all attributes are decoded
    do
    {
      var shift=0;
      int result=0;

      // for decoding value of one attribute
      do
      {
        c=list[index]-63;
        result|=(c & 0x1F)<<(shift*5);
        index++;
        shift++;
      }while(c>=32);
      /* if value is negetive then bitwise not the value */
      if(result & 1==1)
      {
        result=~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    }while(index<len);

/*adding to previous value as done in encoding */
    for(var i=2;i<lList.length;i++)
      lList[i]+=lList[i-2];

    print(lList.toString());

    return lList;
  }

  void _getUserLocation() async  {
     Position position=await Geolocator().getCurrentPosition(desiredAccuracy:LocationAccuracy.best);
     List<Placemark> placemark=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
     setState(() {
       _initialPosition=LatLng(position.latitude, position.longitude);
       _locationController.text=placemark[0].name;
     });
  }
}
