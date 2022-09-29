import '../Models/fosc.dart';

int sortFoscs(Fosc a, Fosc b, int sortIndex, bool asc) {
  late int result;
  switch (sortIndex) {
    case 1:
      result = a.id.compareTo(b.id);
      break;
    case 2:
      result = a.companyName.compareTo(b.companyName);
      break;
    case 3:
      result = a.firstName.compareTo(b.firstName);
      break;
    case 4:
      result = a.lastName.compareTo(b.lastName);
      break;
    case 5:
      result = a.phone.compareTo(b.phone);
      break;
    default:
      result = a.id.compareTo(b.id);
      break;
  }
  if (!asc) result *= -1;
  return result;
}
