import 'package:my_sauda/features/parties/model/party.dart';

// Opens the sauda form for a brand new sauda with a party already fixed on one
// side; the form then hands the created sauda back to the caller.
class NewSaudaPreset {
  final Party? buyer;
  final Party? seller;

  const NewSaudaPreset({this.buyer, this.seller});
}
