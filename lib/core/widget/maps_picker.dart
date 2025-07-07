import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../presentation/laporan/bloc/laporan_bloc.dart';

class MapsPicker extends StatefulWidget {
  @override
  _MapsPickerState createState() => _MapsPickerState();
}

class _MapsPickerState extends State<MapsPicker> {
  GoogleMapController? _mapController;
  TextEditingController _searchController = TextEditingController();
  LatLng _currentCenter = LatLng(-7.797068, 110.370529);
  LatLng? _selectedPosition;

  void _searchLocation(BuildContext context) async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        LatLng searchedLatLng = LatLng(location.latitude, location.longitude);

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(searchedLatLng),
        );

        setState(() {
          _selectedPosition = searchedLatLng;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat tidak ditemukan')),
      );
    }
  }

  void _pickLocationManually(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _currentCenter = position;
    });
  }

  void _cancelPin() {
    setState(() {
      _selectedPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard jika klik di luar
      child: BlocBuilder<LaporanBloc, LaporanState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cari Lokasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _searchLocation(context),
                    child: Text('Cari'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: state.selectedLocation ?? _currentCenter,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (position) {
                    setState(() {
                      _currentCenter = position.target;
                    });
                  },
                  onTap: _pickLocationManually, // Pilih dengan tap
                  markers: _selectedPosition != null
                      ? {
                          Marker(
                            markerId: MarkerId('selected'),
                            position: _selectedPosition!,
                          )
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final LatLng location = _selectedPosition ?? _currentCenter;
                      context.read<LaporanBloc>().add(
                        SelectLocation(latitude: location.latitude, longitude: location.longitude),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lokasi berhasil dipilih')),
                      );
                    },
                    child: Text('Pilih Lokasi Ini'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _cancelPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Cancel Pin'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _selectedPosition == null
                    ? 'Belum ada lokasi yang dipilih.'
                    : 'Lokasi: ${_selectedPosition!.latitude}, ${_selectedPosition!.longitude}',
              ),
            ],
          );
        },
      ),
    );
  }
}
