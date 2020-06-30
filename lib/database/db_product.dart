import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:ptmstock/model/model_product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tbProduct = "product";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "db_product.db");

    var ourDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tbProduct(id INTEGER PRIMARY KEY, barcode TEXT, date TEXT, time TEXT, name TEXT, prodgroup TEXT, image TEXT, username TEXT)");
  }

  //CRUD - CREATE, READ, UPDATE, DELETE

  //Insertion
  Future<int> saveProduct(ModelProduct product) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tbProduct", product.toMap());
    return res;
  }

  Future<List<Map>> getAllProduct(String sDate, int index) async {
    var dbClient = await db;
    String sWhere = 'date' + ' =?';
    List<String> sArgs = [sDate];
    var result = await dbClient.query(
      tbProduct,
      where: sWhere,
      whereArgs: sArgs,
      orderBy: 'date' + ' DESC' + ', ' + 'time' + ' DESC',
    );

    return result.toList();
  }

  Future<List<Map>> getAllProductLimitTen(String sDate, int index) async {
    var dbClient = await db;
    String sWhere = 'date' + ' =?';
    List<String> sArgs = [sDate];
    var result = await dbClient.query(tbProduct, where: sWhere,
        whereArgs: sArgs,
        orderBy: 'date' + ' DESC' + ', ' + 'time' + ' DESC',
        limit: 10,
        offset: index);

    return result.toList();
  }

  Future<List<Map>> getProductByBarcode(String sDate, String sBarcode) async {
    var dbClient = await db;
    String sWhere = 'barcode' + " LIKE '" +
        sBarcode +
        "%'";
    List<String> sArg = [sDate];
    var result =
    await dbClient.query(tbProduct, where: sWhere,
        orderBy: 'date' + ' DESC' + ', ' + 'time' + ' DESC');

    return result.toList();
  }

  Future<List<Map>> checkProductByBarcode(String sBarcode) async {
    var dbClient = await db;
    String sWhere = 'barcode' + ' =?';
    List<String> sArg = [sBarcode];
    var result =
        await dbClient.query(tbProduct, where: sWhere, whereArgs: sArg);

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tbProduct"));
  }

  Future<int> deleteProductByBarcode(String sBarcode) async {
    var dbClient = await db;
    String sWhere = 'barcode' + ' =?';
    List<String> sArgs = [sBarcode];
    int iRet = await dbClient
        .delete(tbProduct, where: sWhere, whereArgs: sArgs);
    return iRet;
  }

  Future<int> deleteProductAllByDate(String sDate) async {
    var dbClient = await db;
    String sWhere = 'date' + ' =?';
    List<String> sArgs = [sDate];
    int iRet = await dbClient
        .delete(tbProduct, where: sWhere, whereArgs: sArgs);
    return iRet;
  }

//  Future<int> updateUser(User user) async {
//    var dbClient = await db;
//    return await dbClient.update(tableUser, user.toMap(),
//        where: "$columnId = ?", whereArgs: [user.id]);
//  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
