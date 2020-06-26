import 'package:flutter/cupertino.dart';

class ModelProduct {
  String sName;
  String sDate;
  String sTime;
  String sBarcode;
  String sGroup;
  String sImg64;
  Image sImage;
  String sUsername;

  ModelProduct(this.sBarcode,
      {this.sDate,
      this.sTime,
      this.sName,
      this.sGroup,
      this.sImg64,
      this.sUsername});

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["barcode"] = sBarcode;
    map["date"] = sDate;
    map["time"] = sTime;
    map["name"] = sName;
    map["prodgroup"] = sGroup;
    map["image"] = sImg64;
    map["username"] = sUsername;

    return map;
  }

  String get getBarcode => sBarcode;

  String get getDate => sDate;

  String get getTime => sTime;

  String get getName => sName;

  String get getGroup => sGroup;

  String get getsImg64 => sImg64;

  Image get getsImage => sImage;

  String get getsUsername => sUsername;

  set setBarcode(String sBarcode) {
    this.sBarcode = sBarcode;
  }

  set setDate(String sDate) {
    this.sDate = sDate;
  }

  set setTime(String sTime) {
    this.sTime = sTime;
  }

  set setName(String sName) {
    this.sName = sName;
  }

  set setGroup(String sGroup) {
    this.sGroup = sGroup;
  }

  set setImg64(String sImg64) {
    this.sImg64 = sImg64;
  }

  set setImage(Image sImage) {
    this.sImage = sImage;
  }

  set setUsername(String sUsername) {
    this.sUsername = sUsername;
  }
}
