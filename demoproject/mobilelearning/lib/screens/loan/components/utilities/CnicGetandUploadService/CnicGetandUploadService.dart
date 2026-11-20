// 1) Declare a global to hold the Dobcnic documentId
import 'package:mobile_onboarding/widgets/newDocumentsUpload/apiService.dart';

int? dobcnicDocumentId;
List<int>? dobcnicUploadId;
// 2) Function to fetch & set that global
Future<void> fetchAndSetDobcnicId({
  required int productCodeId,
  required String? employmentTypeId,
}) async {
  try {
    // reuse your existing fetchDocuments(...)
    final docs = await fetchDocuments(
      productCodeId: productCodeId,
      employmentTypeId: employmentTypeId,
    );

    // find the one named "Dobcnic"
    final dobcnic = docs.firstWhere(
      (d) => d.documentName.toLowerCase() == 'dobcnic',
      orElse: () => throw StateError('Dobcnic document not found'),
    );

    // store its ID
    dobcnicDocumentId = dobcnic.documentId;
    print('Dobcnic documentId = $dobcnicDocumentId');
  } on StateError catch (e) {
    // no matching element
    print(e);
  } catch (e) {
    // network / parsing / other error
    print('Error fetching Dobcnic id: $e');
  }
}
