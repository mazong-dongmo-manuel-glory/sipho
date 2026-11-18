import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Result of an on-demand location lookup (README §4.1).
///
/// We only keep human labels (country, region) — never raw GPS coordinates.
class LocationLabels {
  const LocationLabels({
    required this.countryCode,
    required this.region,
    required this.currency,
  });

  final String countryCode;
  final String region;
  final String currency;
}

/// Reduced-accuracy, foreground-only geolocation for onboarding.
class LocationService {
  /// Returns country/region labels, or null when permission is denied / lookup fails.
  Future<LocationLabels?> resolveApproximateLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isEmpty) return null;
      final place = places.first;
      final iso = (place.isoCountryCode ?? '').toUpperCase();
      if (iso.length != 2) return null;

      final region = (place.administrativeArea?.trim().isNotEmpty ?? false)
          ? place.administrativeArea!.trim()
          : (place.locality?.trim().isNotEmpty ?? false)
              ? place.locality!.trim()
              : iso;

      return LocationLabels(
        countryCode: iso,
        region: region,
        currency: _currencyFor(iso),
      );
    } catch (error) {
      debugPrint('[Location] lookup failed: $error');
      return null;
    }
  }

  static String _currencyFor(String countryCode) {
    switch (countryCode) {
      case 'CA':
        return 'CAD';
      case 'US':
        return 'USD';
      case 'GB':
        return 'GBP';
      case 'CM':
        return 'XAF';
      case 'CI':
      case 'SN':
      case 'BF':
      case 'ML':
      case 'TG':
      case 'BJ':
        return 'XOF';
      case 'FR':
      case 'BE':
      case 'CH':
      case 'DE':
      case 'ES':
      case 'IT':
      case 'PT':
      case 'NL':
        return 'EUR';
      default:
        return 'USD';
    }
  }
}
