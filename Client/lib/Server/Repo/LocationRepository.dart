// lib/Server/Repo/LocationRepository.dart

import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _provinces => _db.collection('provinces');

  CollectionReference _cities(String provinceId) =>
      _provinces.doc(provinceId).collection('cities');

  // ─── Provinces ──────────────────────────────────────────────────────────────

  /// All active provinces sorted by order. Use in dropdowns.
  Future<List<ProvinceModel>> getProvinces() async {
    final snap = await _provinces
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => ProvinceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// All provinces including inactive. For admin screen.
  Future<List<ProvinceModel>> getAllProvinces() async {
    final snap = await _provinces.orderBy('order').get();
    return snap.docs
        .map((d) => ProvinceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<ProvinceModel>> streamProvinces() {
    return _provinces
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProvinceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<ProvinceModel> addProvince(ProvinceModel province) async {
    final ref = await _provinces.add(province.toMap());
    return province.copyWith(docId: ref.id);
  }

  Future<void> updateProvince(ProvinceModel province) async {
    await _provinces.doc(province.docId!).update(province.toMap());
  }

  Future<void> deleteProvince(String provinceId) async {
    // Delete all cities first
    final cities = await _cities(provinceId).get();
    final batch = _db.batch();
    for (final doc in cities.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_provinces.doc(provinceId));
    await batch.commit();
  }

  Future<void> activateProvince(String docId) =>
      _provinces.doc(docId).update({'isActive': true});

  Future<void> deactivateProvince(String docId) =>
      _provinces.doc(docId).update({'isActive': false});

  // ─── Cities ─────────────────────────────────────────────────────────────────

  /// Active cities for a province. Use in dropdowns.
  Future<List<CityModel>> getCities(String provinceId) async {
    final snap = await _cities(provinceId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => CityModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// All cities including inactive. For admin screen.
  Future<List<CityModel>> getAllCities(String provinceId) async {
    final snap = await _cities(provinceId).orderBy('order').get();
    return snap.docs
        .map((d) => CityModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<CityModel>> streamCities(String provinceId) {
    return _cities(provinceId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CityModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<CityModel> addCity(CityModel city) async {
    final ref = await _cities(city.provinceId).add(city.toMap());
    return city.copyWith(docId: ref.id);
  }

  Future<void> updateCity(CityModel city) async {
    await _cities(city.provinceId).doc(city.docId!).update(city.toMap());
  }

  Future<void> deleteCity(String provinceId, String cityId) async {
    await _cities(provinceId).doc(cityId).delete();
  }

  Future<void> activateCity(String provinceId, String cityId) =>
      _cities(provinceId).doc(cityId).update({'isActive': true});

  Future<void> deactivateCity(String provinceId, String cityId) =>
      _cities(provinceId).doc(cityId).update({'isActive': false});
}