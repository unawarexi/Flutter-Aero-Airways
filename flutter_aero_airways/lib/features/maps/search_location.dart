import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_aero_airways/core/config/environment.dart';

class LocationPickerService {
  static final _places = GoogleMapsPlaces(
    apiKey: Environment.googleMapsApiKey,
  );
  static final _geocoding = GoogleMapsGeocoding(
    apiKey: Environment.googleMapsApiKey,
  );

  static Future<String?> pickLocation(BuildContext context, {String? initialValue}) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _LocationSearchBottomSheet(
            initialValue: initialValue,
            externalScrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _LocationSearchBottomSheet extends StatefulWidget {
  final String? initialValue;
  final ScrollController? externalScrollController;
  const _LocationSearchBottomSheet({this.initialValue, this.externalScrollController});

  @override
  State<_LocationSearchBottomSheet> createState() => _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState extends State<_LocationSearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PlacesSearchResult> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  ScrollController? get _scrollController => widget.externalScrollController;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _controller.addListener(_onTextChanged);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _performSearch);
  }

  Future<void> _performSearch() async {
    final query = _controller.text;
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await LocationPickerService._places.searchByText(query);
      if (response.status == 'OK') {
        setState(() {
          _searchResults = response.results;
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fillWithCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
          msg: "Location permission denied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final response = await LocationPickerService._geocoding.searchByLocation(
        Location(lat: position.latitude, lng: position.longitude),
      );
      if (response.status == 'OK' && response.results.isNotEmpty) {
        final address = response.results.first.formattedAddress ?? '';
        setState(() {
          _controller.text = address;
        });
      } else {
        Fluttertoast.showToast(
          msg: "Unable to fetch address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching location: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Search location',
              prefixIcon: GestureDetector(
                onTap: _fillWithCurrentLocation,
                child: Icon(Icons.my_location, color: Colors.green, size: 20),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, idx) {
                      final result = _searchResults[idx];
                      return Card(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.8)
                            : Colors.grey.shade200,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                            width: 0.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            result.name,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            result.formattedAddress ?? '',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            String placeName = result.name;
                            if (result.formattedAddress != null &&
                                result.formattedAddress!.isNotEmpty) {
                              placeName = "${result.name}, ${result.formattedAddress}";
                            }
                            Navigator.pop(context, placeName);
                          },
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
