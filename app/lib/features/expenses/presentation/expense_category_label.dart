import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';

String expenseCategoryLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'rent':
      return l10n.catRent;
    case 'internet':
      return l10n.catInternet;
    case 'energy':
      return l10n.catEnergy;
    case 'phone':
      return l10n.catPhone;
    case 'groceries':
      return l10n.catGroceries;
    case 'transport':
      return l10n.catTransport;
    case 'restaurants':
      return l10n.catRestaurants;
    case 'shopping':
      return l10n.catShopping;
    case 'family':
      return l10n.catFamily;
    case 'insurance':
      return l10n.catInsurance;
    case 'electricity':
      return l10n.catEnergy;
    case 'water':
      return l10n.catWater;
    case 'other':
      return l10n.categoryOther;
    default:
      return l10n.categoryOther;
  }
}

IconData expenseCategoryIcon(String id) {
  switch (id) {
    case 'rent':
      return Icons.home_rounded;
    case 'internet':
      return Icons.wifi_rounded;
    case 'energy':
    case 'electricity':
      return Icons.lightbulb_rounded;
    case 'phone':
      return Icons.smartphone_rounded;
    case 'groceries':
      return Icons.shopping_cart_rounded;
    case 'transport':
      return Icons.directions_bus_rounded;
    case 'restaurants':
      return Icons.restaurant_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'family':
      return Icons.volunteer_activism_rounded;
    case 'insurance':
      return Icons.health_and_safety_rounded;
    case 'water':
      return Icons.water_drop_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}
