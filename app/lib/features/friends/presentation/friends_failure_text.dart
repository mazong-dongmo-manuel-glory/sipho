import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/friends/domain/friends.dart';

/// The user-facing explanation of a failed friends action.
String friendsFailureText(AppLocalizations l10n, FriendsFailure failure) {
  switch (failure) {
    case FriendsFailure.codeNotFound:
      return l10n.friendsErrCodeNotFound;
    case FriendsFailure.ownCode:
      return l10n.friendsErrOwnCode;
    case FriendsFailure.alreadyDone:
      return l10n.friendsErrAlreadyDone;
    case FriendsFailure.limitReached:
      return l10n.friendsErrLimit;
    case FriendsFailure.network:
      return l10n.friendsErrNetwork;
    case FriendsFailure.notAllowed:
      return l10n.friendsErrNotAllowed;
    case FriendsFailure.unknown:
      return l10n.friendsErrGeneric;
  }
}
