import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Mapbox access token (replace with your real token)
  final String mapboxToken = "pk.eyJ1IjoiY2hoYWlyaW5uIiwiYSI6ImNtbjNkMjI0bDAwMjYycnBzZjZkeWFvbXgifQ.nxV6sPzC2Apsu1FzEViBLw";

  // Available Mapbox styles
  final Map<String, String> mapStyles = {
    "Street": "mapbox/streets-v12",
    "Satellite": "mapbox/satellite-v9",
    "Dark": "mapbox/dark-v11",
  };

  String currentStyle = "Street";
  final MapController _mapController = MapController();

  // Markers for Phnom Penh
  final List<Map<String, dynamic>> markerData = [
    {
      "point": LatLng(11.5801, 104.9002),
      "color": Colors.red,
      "title": "Phnom Penh Marker 1",
      "description": "Some info about Marker 1"
    },
    {
      "point": LatLng(11.5610, 104.9166),
      "color": Colors.blue,
      "title": "Phnom Penh Marker 2",
      "description": "Some info about Marker 2"
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(11.5564, 104.9282), 13);
    });
  }

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showMarkerInfo(String title, String description) {
    if(!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Mapbox Phnom Penh App"),
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(),
            children: [
              // Mapbox Tile Layer
              TileLayer(
                urlTemplate:
                "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: {
                  "accessToken": mapboxToken,
                  "id": mapStyles[currentStyle]!,
                },
              ),
              // Marker Layer
              MarkerLayer(
                markers: markerData.map((m) {
                  return Marker(
                    point: m["point"] as LatLng,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () =>
                          _showMarkerInfo(m["title"], m["description"]),
                      child: Icon(
                        Icons.location_on,
                        color: m["color"] as Color,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'Mapbox',
                    onTap: () => _openUrl('https://www.mapbox.com/'),
                  ),
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () =>
                        _openUrl('https://www.openstreetmap.org/copyright'),
                  ),
                ],
              ),
            ],
          ),
          // Bottom style buttons
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: mapStyles.keys.map((styleName) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentStyle = styleName;
                      });
                    },
                    child: Text(styleName),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}