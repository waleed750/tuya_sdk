// lib/shared/widgets/location/location_picker_card.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:example/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'map_button_widget.dart';
import 'search_box_widget.dart';
import 'transparent_button.dart';

/// Simple POJO for search results (label + latlng).
class PlaceSuggestion {
  final String label;
  final LatLng point;
  PlaceSuggestion(this.label, this.point);
}

/// Reusable, stateful location picker (shadcn + flutter_map + search).
/// - Uses setState (no Bloc) so you can reuse anywhere.
/// - Emits `onChanged` whenever user picks/changes the location.
class SiteMapWidget extends StatefulWidget {
  const SiteMapWidget({
    super.key,
    this.title = 'Location (Map)',
    this.hint =
        'Click on the map or search to pick a location, or use “Use My Location”.',
    this.initialCenter = const LatLng(24.7136, 46.6753), // Riyadh
    this.initialZoom = 11.5,
    this.initialSelection,
    this.minZoom = 3,
    this.maxZoom = 18,
    this.onChanged,
    this.tileUrlTemplate =
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // OSM
    this.tileSubdomains = const ['a', 'b', 'c'],
    this.searchPlaceholder = 'Search for a place…',
    this.searchDebounceMs = 400,
    this.maxResults = 8,
    this.icon = Icons.location_pin,
    this.timezone,
    this.clearLoaction,

    /// Optional: supply your own search function to replace the built-in OSM/Nominatim.
    this.searchPlaces,
  });

  final String title;
  final String hint;
  final String? timezone;
  final LatLng initialCenter;
  final double initialZoom;
  final LatLng? initialSelection;
  final double minZoom;
  final double maxZoom;
  final IconData icon;

  /// Called when user picks a location (tap, search select, or use-my-location).
  /// Returns the LatLng and best-effort label (can be null).
  final void Function(LatLng latLng, String? label)? onChanged;

  /// Flutter Map tile config
  final String tileUrlTemplate;
  final List<String> tileSubdomains;
  final void Function()? clearLoaction;

  /// Search UI
  final String searchPlaceholder;
  final int searchDebounceMs;
  final int maxResults;

  /// Custom search; if null we fallback to OSM Nominatim.
  /// Must return suggestions ordered by relevance.
  final Future<List<PlaceSuggestion>> Function(String q)? searchPlaces;

  @override
  State<SiteMapWidget> createState() => _SiteMapWidgetState();
}

class _SiteMapWidgetState extends State<SiteMapWidget> {
  late final MapController _mapController;
  LatLng _center = const LatLng(24.7136, 46.6753);
  double _zoom = 11.5;

  LatLng? _selected;
  String? _selectedLabel;
  bool isMyLocationLoading = false;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debouncer;
  bool _searching = false;
  List<PlaceSuggestion> _results = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = widget.initialCenter;
    _zoom = widget.initialZoom;
    _selected = widget.initialSelection;
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---- Helpers --------------------------------------------------------------

  void _debouncedSearch(String q) {
    _debouncer?.cancel();
    _debouncer = Timer(Duration(milliseconds: widget.searchDebounceMs), () {
      _runSearch(q);
    });
    setState(() {}); // to refresh clear button visibility
  }

  Future<void> _runSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);

    try {
      final suggestions = widget.searchPlaces != null
          ? await widget.searchPlaces!(query)
          : await _nominatimSearch(query, widget.maxResults);

      if (!mounted) return;
      setState(() {
        _results = suggestions;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _searching = false;
      });
    }
  }

  Future<List<PlaceSuggestion>> _nominatimSearch(
    String query,
    int limit,
  ) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json'
      '&q=${Uri.encodeQueryComponent(query)}&limit=$limit&addressdetails=1',
    );
    final resp = await http.get(
      uri,
      headers: {'User-Agent': 'syncn-mobile-app/1.0 (contact@example.com)'},
    );
    if (resp.statusCode != 200) return [];

    final List data = json.decode(resp.body) as List;
    return data
        .map((e) {
          final lat = double.tryParse(e['lat']?.toString() ?? '');
          final lon = double.tryParse(e['lon']?.toString() ?? '');
          final label = e['display_name']?.toString();
          if (lat == null || lon == null) {
            return null;
          }
          return PlaceSuggestion(label ?? 'Unknown', LatLng(lat, lon));
        })
        .whereType<PlaceSuggestion>()
        .toList();
  }

  Future<void> _useMyLocation() async {
    setState(() => isMyLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selected = here;
        _selectedLabel = 'My Location';
        _center = here;
        _zoom = math.max(_zoom, 14);
      });
      _mapController.move(here, _zoom);

      widget.onChanged?.call(here, _selectedLabel);
      setState(() => isMyLocationLoading = false);
    } catch (_) {
      setState(() => isMyLocationLoading = false);

      // swallow for now; you can toast/snackbar if you like
    }
  }

  void _resetView() {
    setState(() {
      _center = widget.initialCenter;
      _zoom = widget.initialZoom;
    });
    _selected = null;
    _mapController.move(_center, _zoom);
  }

  void _applySelection(LatLng p, {String? label}) {
    setState(() {
      _selected = p;
      _selectedLabel = label;
      _center = p;
      _zoom = math.max(_zoom, 14);
      _results = [];
    });
    _mapController.move(p, _zoom);
    widget.onChanged?.call(p, label);
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
                Text(widget.title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.hint, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 10),

            // Map + Search Stack
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.12),
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Map
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: _zoom,
                        minZoom: widget.minZoom,
                        maxZoom: widget.maxZoom,
                        onTap: (tapPos, latLng) => _applySelection(latLng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: widget.tileUrlTemplate,
                          subdomains: widget.tileSubdomains,
                          userAgentPackageName: 'syncn_mobile_app',
                        ),
                        if (_selected != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selected!,
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const _Pin(),
                              ),
                            ],
                          ),
                        // Zoom controls (simple)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Column(
                            spacing: 5,
                            children: [
                              MapControlButton(
                                icon: Icons.add,
                                onTap: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom + 1.0,
                                  );
                                },
                              ),
                              MapControlButton(
                                icon: Icons.remove,
                                onTap: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom - 1.0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar overlay
                  PositionedDirectional(
                    top: 5,
                    end: 5,
                    child: SearchBox(
                      controller: _searchCtrl,
                      placeholder: widget.searchPlaceholder,
                      searching: _searching,
                      onChanged: _debouncedSearch,
                      onClear: () {
                        _debouncer?.cancel();
                        _searchCtrl.clear();
                        setState(() => _results = []);
                      },
                    ),
                  ),

                  // Results list
                  if (_results.isNotEmpty)
                    Positioned(
                      top: 56,
                      left: 10,
                      right: 10,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        color: theme.colorScheme.surface,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: theme.colorScheme.outline,
                            ),
                            itemBuilder: (ctx, i) {
                              final s = _results[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.search, size: 18),
                                title: Text(
                                  s.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    _applySelection(s.point, label: s.label),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Actions
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                TransparentButton(
                  isLoading: isMyLocationLoading,
                  text: 'Use My Location',
                  icon: LucideIcons.locateFixed,
                  onTap: isMyLocationLoading ? null : _useMyLocation,
                ),
                TransparentButton(
                  isLoading: false,
                  text: 'Reset View',
                  onTap: () async {
                    _resetView();
                  },
                  icon: LucideIcons.crosshair,
                ),
                if (widget.clearLoaction != null)
                  TransparentButton(
                    isLoading: false,
                    text: 'Clear Location',
                    bgColor: Color(0xFF942D2D),
                    onTap: () async {
                      widget.clearLoaction!();
                    },
                    icon: LucideIcons.eraser,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (widget.timezone != null)
              Text(
                widget.timezone!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple pin with shad colors
class _Pin extends StatelessWidget {
  const _Pin();
  @override
  Widget build(BuildContext context) {
    // final c = ShadTheme.of(context).colorScheme;
    return SizedBox(
      width: 24,
      height: 24,
      // decoration: BoxDecoration(
      //   color: AppColors.secondaryPrimaryColor,
      //   shape: BoxShape.circle,
      //   border: Border.all(color: c.card, width: 2),
      //   boxShadow: [
      //     BoxShadow(
      //       color: c.primary.withValues(alpha: 0.25),
      //       blurRadius: 8,
      //       spreadRadius: 0,
      //     ),
      //   ],
      // ),
      child: const Icon(LucideIcons.mapPin, size: 30, color: AppColors.primary),
    );
  }
}
