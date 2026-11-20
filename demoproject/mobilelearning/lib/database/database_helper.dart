import 'dart:io';
import 'package:mobile_onboarding/model/base64_image.dart';
import 'package:mobile_onboarding/model/form_value.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/model/picker_state.dart';
import 'package:mobile_onboarding/model/switch_state.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../model/picker_id.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  // Encryption Key (this should be a secret key you define)
  // final String _encryptionKey = SecureDotEnv.get('DB_ENCRYPTION_KEY') ?? '';
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // Open the database with encryption
  Future<Database> _initDatabase() async {
    final String? _encryptionKey = await UserSecretStore.getDeviceKeyBase64();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dynamic_form.db');

    // Open the database with encryption
    return await openDatabase(path,
        version: 1, onCreate: _createDb, password: _encryptionKey);
  }

  // Creating the tables
  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE formValues(id INTEGER PRIMARY KEY AUTOINCREMENT, fieldClassID TEXT NOT NULL, fieldValue TEXT, requestId INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE pickerStates(id INTEGER PRIMARY KEY AUTOINCREMENT, fieldClassID TEXT NOT NULL, pickerIndex TEXT, requestId INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE pickerIds(id INTEGER PRIMARY KEY AUTOINCREMENT, fieldClassID TEXT NOT NULL, pickerId TEXT, requestId INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE switchStates(id INTEGER PRIMARY KEY AUTOINCREMENT, fieldClassID TEXT NOT NULL, state TEXT, requestId INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE base64Images(id INTEGER PRIMARY KEY AUTOINCREMENT, fieldClassID TEXT NOT NULL, base64String TEXT, requestId INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE loanRequestInformation(requestId INTEGER PRIMARY KEY AUTOINCREMENT, stepsCompleted INTEGER NOT NULL, status TEXT NOT NULL)',
    );
  }

  Future<int> insertFormValue(FormValue value) async {
    Database db = await database;
    return await db.insert('formValues', value.toMap());
  }

  Future<int> insertPickerIndex(PickerState value) async {
    Database db = await database;
    return await db.insert('pickerStates', value.toMap());
  }

  Future<int> insertPickerId(PickerID value) async {
    Database db = await database;
    return await db.insert('pickerIds', value.toMap());
  }

  Future<int> insertSwitchSate(SwitchState value) async {
    Database db = await database;
    return await db.insert('switchStates', value.toMap());
  }

  Future<int> insertBase64Image(Base64Image value) async {
    Database db = await database;
    return await db.insert('base64Images', value.toMap());
  }

  Future<int> insertLoanRequestInformation(LoanRequestInformation value) async {
    Database db = await database;
    return await db.insert('loanRequestInformation', value.toMap());
  }

  Future<int> updateFormValue(
      FormValue value, String key, int requestId) async {
    Database db = await database;
    return await db.update('formValues', value.toMap(),
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
  }

  Future<int> updatePickerIndex(
      PickerState value, String key, int requestId) async {
    Database db = await database;
    return await db.update('pickerStates', value.toMap(),
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
  }

  Future<int> updatePickerId(PickerID value, String key, int requestId) async {
    Database db = await database;
    return await db.update('pickerIds', value.toMap(),
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
  }

  Future<int> updateSwitchState(
      SwitchState value, String key, int requestId) async {
    Database db = await database;
    return await db.update('switchStates', value.toMap(),
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
  }

  Future<int> updateBase64Image(
      Base64Image value, String key, int requestId) async {
    Database db = await database;
    return await db.update('base64Images', value.toMap(),
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
  }

  Future<int> updateLoanRequestInformation(
      LoanRequestInformation value, int requestId) async {
    Database db = await database;
    return await db.update('loanRequestInformation', value.toMap(),
        where: 'requestId = ?', whereArgs: [requestId]);
  }

  Future<List<FormValue>> getFormValue(String key, int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('formValues',
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
    return List.generate(maps.length, (i) {
      return FormValue(
          maps[i]['fieldClassID'], maps[i]['fieldValue'], maps[i]['requestId']);
    });
  }

  Future<List<PickerState>> getPickerIndex(String key, int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('pickerStates',
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
    return List.generate(maps.length, (i) {
      return PickerState(maps[i]['fieldClassID'], maps[i]['pickerIndex'],
          maps[i]['requestId']);
    });
  }

  Future<List<PickerID>> getPickerId(String key, int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('pickerIds',
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
    return List.generate(maps.length, (i) {
      return PickerID(
          maps[i]['fieldClassID'], maps[i]['pickerId'], maps[i]['requestId']);
    });
  }

  // Add this method in DatabaseHelper
  Future<String?> getProductType(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('formValues',
        where: 'requestId = ? AND fieldClassID = ?',
        whereArgs: [requestId, 'product_type']);

    if (maps.isNotEmpty) {
      return maps.first['fieldValue']; // Return the product_type
    }

    return null; // Return null if no result
  }

  Future<List<SwitchState>> getSwitchState(String key, int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('switchStates',
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
    return List.generate(maps.length, (i) {
      return SwitchState(
          maps[i]['fieldClassID'], maps[i]['state'], maps[i]['requestId']);
    });
  }

  Future<List<Base64Image>> getBase64Image(String key, int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('base64Images',
        where: 'fieldClassID = ? AND requestId = ?',
        whereArgs: [key, requestId]);
    return List.generate(maps.length, (i) {
      return Base64Image(maps[i]['fieldClassID'], maps[i]['base64String'],
          maps[i]['requestId']);
    });
  }

  Future<List<LoanRequestInformation>> getLoanRequestInformation(
      int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('loanRequestInformation',
        where: 'requestId = ?', whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return LoanRequestInformation(
          maps[i]['requestId'], maps[i]['stepsCompleted'], maps[i]['status']);
    });
  }

  Future<List<FormValue>> getFormValues(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('formValues', where: "requestId = ?", whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return FormValue(
          maps[i]['fieldClassID'], maps[i]['fieldValue'], maps[i]['requestId']);
    });
  }

  Future<List<PickerState>> getPickerIndexes(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('pickerStates', where: "requestId = ?", whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return PickerState(maps[i]['fieldClassID'], maps[i]['pickerIndex'],
          maps[i]['requestId']);
    });
  }

  Future<List<PickerID>> getPickerIds(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('pickerIds', where: "requestId = ?", whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return PickerID(
          maps[i]['fieldClassID'], maps[i]['pickerId'], maps[i]['requestId']);
    });
  }

  Future<List<SwitchState>> getSwitchStates(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('switchStates', where: "requestId = ?", whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return SwitchState(
          maps[i]['fieldClassID'], maps[i]['state'], maps[i]['requestId']);
    });
  }

  Future<List<Base64Image>> getBase64Images(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('base64Images', where: "requestId = ?", whereArgs: [requestId]);
    return List.generate(maps.length, (i) {
      return Base64Image(maps[i]['fieldClassID'], maps[i]['base64String'],
          maps[i]['requestId']);
    });
  }

  // Add this method in DatabaseHelper
// Add this method in DatabaseHelper
  Future<String?> getFullName(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('formValues',
        where: 'requestId = ? AND fieldClassID = ?',
        whereArgs: [requestId, 'full_name']);

    if (maps.isNotEmpty) {
      return maps.first['fieldValue']; // Return the full_name
    }

    return null; // Return null if no result found
  }

  Future<String?> getCNIC(int requestId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('formValues',
        where: 'requestId = ? AND fieldClassID = ?',
        whereArgs: [requestId, 'id_number']);

    if (maps.isNotEmpty) {
      return maps.first['fieldValue']; // Return the full_name
    }

    return null; // Return null if no result found
  }

  Future<List<LoanRequestInformation>> getAllLoanRequestInformation() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('loanRequestInformation');
    return List.generate(maps.length, (i) {
      return LoanRequestInformation(
          maps[i]['requestId'], maps[i]['stepsCompleted'], maps[i]['status']);
    });
  }

  Future<int> delBase64Image(String key, int requestId) async {
    Database db = await database;
    return await db.delete("base64Images",
        where: "fieldClassID = ? AND requestId = ?",
        whereArgs: [key, requestId]);
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
  }

  Future<void> deleteAllLoanRequests() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('formValues');
      await txn.delete('pickerStates');
      await txn.delete('pickerIds');
      await txn.delete('switchStates');
      await txn.delete('base64Images');
      await txn.delete('loanRequestInformation');
    });
  }
}
