import 'package:ptmstock/ViewItem_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:ptmstock/Utils/images.dart';
import 'package:ptmstock/database/db_product.dart';
import 'package:ptmstock/model/model_product.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImageResize;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_rounded_date_picker/rounded_date_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

class AddProductScreen extends StatefulWidget {
  String sUsername;

  AddProductScreen({Key key, this.sUsername}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _counter = 0;
  List<ModelProduct> mdProduct = new List();
  String sBarcode = '';
  String sBase64Img = '';
  final picker = ImagePicker();
  DateFormat datetimeFormat = DateFormat('dd-MM-yyyy HH:mm');
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');
  DateTime currentDt = DateTime.now();
  String sFullDate = '';
  String sUsername = '';
  String sListData = '';
  TextEditingController dateStart_controller;
  TextEditingController dateEnd_controller;
  DateFormat savetimeFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
  DateFormat savedateFormat = DateFormat('yyyy-MM-dd');
  DateTime dtStartDate = DateTime.now();
  DateTime dtEndDate = DateTime.now();
  DateTime currentDateTime = DateTime.now();
  DateTime currentDT = DateTime.now();
  TextEditingController searchBar_controller = TextEditingController();
  FocusNode focusSearch = FocusNode();
  bool isDownloading = false;
  bool bNoMoreData = false;
  TextStyle _textStyleButton = TextStyle(color: Colors.blue, fontSize: 12);

  String getMonthName(final int month) {
    switch (month) {
      case 1:
        return "มกราคม";
      case 2:
        return "กุมภาพันธ์";
      case 3:
        return "มีนาคม";
      case 4:
        return "เมษายน";
      case 5:
        return "พฤษภาคม";
      case 6:
        return "มิถุนายน";
      case 7:
        return "กรกฎาคม";
      case 8:
        return "สิงหาคม";
      case 9:
        return "กันยายน";
      case 10:
        return "ตุลาคม";
      case 11:
        return "พฤศจิกายน";
      case 12:
        return "ธันวาคม";
      default:
        return "Unknown";
    }
  }

  bool isProcess = false;

  waitProcess(int index) async {
    if (!isProcess) {
      isProcess = true;
      await setDataListViewScrolling(index);
      isProcess = false;
//      if(isLoading){
//        isLoading = false;
//        setState(() {});
//      }
    }
  }

  @override
  void dispose() {
    focusSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (this.widget.sUsername != null) sUsername = this.widget.sUsername;
    String sThaiMonth = dtStartDate.day.toString() +
        ' ' +
        getMonthName(dtStartDate.month) +
        ' ' +
        dtStartDate.year.toString();
    dateStart_controller = TextEditingController(text: sThaiMonth);
    setDataListViewFirstTime(0);
    super.initState();
  }

  deleteFromDB(String sBarcode) async {
    DatabaseHelper db = DatabaseHelper();
    int iRet = await db.deleteProductByBarcode(sBarcode);
    if (iRet > 0) {
      Navigator.pop(context);
      setDataListViewFirstTime(0);
    }
  }

  deleteAllByDate() async {
    DatabaseHelper db = DatabaseHelper();
    int iRet = await db
        .deleteProductAllByDate(dtStartDate.toString().substring(0, 10));
    if (iRet > 0) {
      Navigator.pop(context);
      setDataListViewFirstTime(0);
    }
  }

  setDataListViewFirstTime(int index) async {
    isDownloading = true;
    sFullDate = currentDt.day.toString() +
        " " +
        getMonthName(currentDt.month) +
        " " +
        (currentDt.year).toString();
    // สำหรับดึงข้อมูล firebase
    mdProduct.clear();

    DatabaseHelper db = new DatabaseHelper();
    List<Map> lm =
        await db.getAllProduct(dtStartDate.toString().substring(0, 10), index);
    int iRet = lm.length;
    for (int i = 0; i < lm.length; i++) {
      Map map = lm[i];
      String sBarcode = map['barcode'];
      String sDate = map['date'];
      String sTime = map['time'];
      String sName = map['name'];
      String sGroup = map['group'];
      String sImg64 = map['image'];
      String sUsername = map['username'];

      DateTime dtDocDate = DateTime.parse(sDate);
      String sThaiMonth =
//            dtDocDate.day.toString() +
//            ' ' +
//            getMonthName(dtDocDate.month) +
//            ' ' +
//            dtDocDate.year.toString() +
//            ' ' +
          sTime;
      String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
          dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
      Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
      if (sBarcode == null) sBarcode = '';
      if (sThaiMonth == null) sThaiMonth = '';
      if (sTime == null) sTime = '';
      if (sName == null) sName = '';
      if (sGroup == null) sGroup = '';
      if (sImg64 == null) sImg64 = '';
      if (sUsername == null) sUsername = '';
      mdProduct.add(ModelProduct(
        sBarcode,
        sDate: sThaiMonth,
        sTime: sTime,
        sName: sName,
        sGroup: sGroup,
        sImg64: sImg64,
        sUsername: sUsername,
      ));
      mdProduct[i].sImage = itemImage;
    }
    if (iRet == 0) {

      sListData = "ไม่มีรายการ";
      bNoMoreData = true;
      setState(() {});
    }
    isDownloading = false;
    if (iRet > 0) {
//        Navigator.pop(context);
      setState(() {});
    }

  }

  setDataListViewScrolling(int index) async {
    isDownloading = false;
    sFullDate = currentDt.day.toString() +
        " " +
        getMonthName(currentDt.month) +
        " " +
        (currentDt.year).toString();


    DatabaseHelper db = new DatabaseHelper();
    List<Map> lm = await db.getAllProductLimitTen(
        dtStartDate.toString().substring(0, 10), index);
    int iRet = lm.length;
    if (iRet > 0) {
      for (int i = 0; i < lm.length; i++) {
        Map map = lm[i];
        String sBarcode = map['barcode'];
        String sDate = map['date'];
        String sTime = map['time'];
        String sName = map['name'];
        String sGroup = map['group'];
        String sImg64 = map['image'];
        String sUsername = map['username'];

        DateTime dtDocDate = DateTime.parse(sDate);
        String sThaiMonth =
//            dtDocDate.day.toString() +
//            ' ' +
//            getMonthName(dtDocDate.month) +
//            ' ' +
//            dtDocDate.year.toString() +
//            ' ' +
        sTime;
        String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
            dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
        Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
        if (sBarcode == null) sBarcode = '';
        if (sThaiMonth == null) sThaiMonth = '';
        if (sTime == null) sTime = '';
        if (sName == null) sName = '';
        if (sGroup == null) sGroup = '';
        if (sImg64 == null) sImg64 = '';
        if (sUsername == null) sUsername = '';
        mdProduct.add(ModelProduct(
          sBarcode,
          sDate: sThaiMonth,
          sTime: sTime,
          sName: sName,
          sGroup: sGroup,
          sImg64: sImg64,
          sUsername: sUsername,
        ));
        mdProduct[i].sImage = itemImage;
      }
    }

    if (iRet > 0) {
      isDownloading = true;
//        Navigator.pop(context);
      setState(() {});
    } else {
      isDownloading = true;
      sListData = "ไม่มีรายการ";
      bNoMoreData = true;
    }
  }

  getDataBySearch(String sSearchName) async {
    isDownloading = true;
    mdProduct.clear();

    DatabaseHelper db = new DatabaseHelper();
    List<Map> lm = await db.getProductByBarcode(
        dtStartDate.toString().substring(0, 10), sSearchName);
    int iRet = lm.length;
    for (int i = 0; i < lm.length; i++) {
      Map map = lm[i];
      String sBarcode = map['barcode'];
      String sDate = map['date'];
      String sTime = map['time'];
      String sName = map['name'];
      String sGroup = map['group'];
      String sImg64 = map['image'];
      String sUsername = map['username'];
      DateTime dtDocDate = DateTime.parse(sDate);
      String sThaiMonth = sTime;

      String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
          dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
      Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
      if (sBarcode == null) sBarcode = '';
      if (sThaiMonth == null) sThaiMonth = '';
      if (sTime == null) sTime = '';
      if (sName == null) sName = '';
      if (sGroup == null) sGroup = '';
      if (sImg64 == null) sImg64 = '';
      if (sUsername == null) sUsername = '';
      mdProduct.add(ModelProduct(
        sBarcode,
        sDate: sThaiMonth,
        sTime: sTime,
        sName: sName,
        sGroup: sGroup,
        sImg64: sImg64,
        sUsername: sUsername,
      ));
      mdProduct[i].sImage = itemImage;
    }

    if (iRet == 0) {
      mdProduct.clear();
      sListData = "ไม่มีรายการ";
      bNoMoreData = true;
      setState(() {

      });
    }

    if (iRet > 0) {
      isDownloading = false;
//        Navigator.pop(context);
      setState(() {});
    }
//        Navigator.pop(context);
  }

  processCreateProduct() async {
    sBase64Img = '';
    sBarcode = '';

    String sBase64 = await _imageTakePicture();
    if (sBase64Img != null && sBase64Img != '') {
      await scan();

      if (sBarcode != null && sBarcode != '') {
        int iRet = 0;
        DatabaseHelper db = DatabaseHelper();
        List<Map> lm = await db.checkProductByBarcode(sBarcode);
//
        iRet = lm.length;
//
//        if (iRet > 0) {
//          showDialog(
//              context: context,
//              builder: (_) {
//                return AlertDialog(
//                  title: Text("รหัสบาร์โค้ดซ้ำ..มีข้อมูลในระบบแล้ว"),
//                  actions: <Widget>[
//                    FlatButton.icon(
//                        onPressed: () => Navigator.pop(context),
//                        icon: Icon(
//                          Icons.close,
//                          color: Colors.grey,
//                        ),
//                        label: Text(
//                          "ปิด",
//                          style: TextStyle(color: Colors.grey),
//                        ))
//                  ],
//                );
//              });
//        } else {
          String sDate = savedateFormat.format(DateTime.now());
          String sTime = timeFormat.format(DateTime.now());
//      mdProduct.add(ModelProduct(sBarcode,sDate: sDate,sCode: sBarcode,sName: 'ไม่ระบุ',sGroup: 'ไม่ระบุ',sImg64: sBase64Img));
          iRet = await db.saveProduct(ModelProduct(sBarcode,
              sDate: sDate,
              sTime: sTime,
              sName: 'ไม่ระบุ',
              sGroup: 'ไม่ระบุ',
              sImg64: sBase64Img,
              sUsername: sUsername));

        if (iRet > 0) setDataListViewFirstTime(0);
//        }
      }
    }
  }

  _imageTakePicture() async {
    var picture = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 600
    );
    ImageResize.Image imageFile =
        ImageResize.decodeJpg(File(picture.path).readAsBytesSync());
    ImageResize.Image thumbnail = ImageResize.copyResize(imageFile, width: 520);
    sBase64Img = base64Encode(ImageResize.encodePng(thumbnail));
//    imageProduct = ImagesConverter.imageFromBase64String(sBase64Img);
    setState(() {});
    return sBase64Img;
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();

      setState(() {
        if (barcode != null) {
          sBarcode = barcode;
        }
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
//          Text("");
      } else {
        // Unknown error.
      }
    } on FormatException {
      // User returned using the "back"-button before scanning anything.
    } catch (e) {
      // Unknown error.
    }
  }

  _onClickPushPage(String sBarCode) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ViewItemPage(
          sBarcode: sBarCode,
        );
      },
    ));
  }

  searchData(String search) async {
    await Future.delayed(Duration(milliseconds: 700));

    String sSearchName = searchBar_controller.text;
    if (search.length == 0) {
      sSearchName = "";
      await setDataListViewFirstTime(0);
    } else {
      if (search == sSearchName) {
        await getDataBySearch(sSearchName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
//      WillPopScope(
//      onWillPop: () async => false,
//      child:
        Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        child:
            //          child: Column(
            //            mainAxisAlignment: MainAxisAlignment.start,
            //            children: <Widget>[
            //              Row(
            //                mainAxisAlignment: MainAxisAlignment.start,
            //                children: <Widget>[
            //                  Expanded(
            //                    child: Container(
            //                      decoration: BoxDecoration(color: Colors.grey.shade200),
            //                      padding: EdgeInsets.all(5),
            //                      child: Column(
            //                        crossAxisAlignment: CrossAxisAlignment.start,
            //                        children: <Widget>[
            //                          Text('วันที่: ' + sFullDate),
            //                          Text('ชื่อผู้ใช้งาน: ' + sUsername),
            //                        ],
            //                      ),
            //                    ),
            //                  )
            //                ],
            //              ),
            _buildSuggestions(),
        //            ],
        //          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => processCreateProduct(),
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
//      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
//        automaticallyImplyLeading: false,
      centerTitle: true,
      title: GestureDetector(
        child: Text("รายการสินค้า"),
        onTap: () {
          print(mdProduct.length);
        },
      ),
//      actions: <Widget>[
//        FlatButton.icon(
//            onPressed: () => Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => AddProductScreenTest())),
//            icon: Icon(
//              Icons.image,
//              color: Colors.white,
//            ),
//            label: Text(
//              "test",
//              style: TextStyle(
//                color: Colors.white,
//              ),
//            ))
//      ],
    );
  }

  Widget _buildSuggestions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            color: Colors.grey.shade300,
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'ชื่อผู้ใช้งาน : ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: sUsername,
                                  style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        )
                      ],
                    ),
                    buildPickDate(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade100,
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (term) {
                                searchData(searchBar_controller.text);
                              },
                              autofocus: false,
                              onChanged: searchData,
                              controller: searchBar_controller,
                              decoration: InputDecoration(
                                hintText: 'ค้นหาด้วยบาร์โค้ด',
                                prefixIcon: GestureDetector(
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade700,
                                  ),
                                  onTap: () {
                                    searchData(searchBar_controller.text);
                                  },
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 13),
                                border: InputBorder.none,
                                suffixIcon: searchBar_controller.text.length > 0
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 15,
                                          color: Colors.grey.shade500,
                                        ),
                                        onPressed: () {
                                          searchBar_controller.clear();
                                          setDataListViewFirstTime(0);
                                          setState(() {});
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        mdProduct.length > 0
            ? Expanded(
          child: new

          GridView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: mdProduct.length + 1,
            shrinkWrap: true,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, i) {
              final index = i;
              if (index >= mdProduct.length) {
                waitProcess(index);
              }
              if (mdProduct.length > 0 && index < mdProduct.length) {
                return _buildRow(mdProduct[index], index);
              }
            },
          ),
                )
            : isDownloading
                ? Container(
                    margin: EdgeInsets.all(10),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Text(
                        sListData,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
      ],
    );
  }

  Widget buildPickDate() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      color: Colors.grey.shade200,
        child: Row(children: <Widget>[
          Expanded(
            flex: 9,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      child: Text(
                        'เลือกวันที่',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade700),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: DateTimeField(
                        readOnly: true,
                        resetIcon: null,
                        textAlign: TextAlign.center,
                        controller: dateStart_controller,
                        format: dateFormat,
                        focusNode: focusSearch,
                        style: TextStyle(color: Colors.blue, height: 1.4),
                        onShowPicker: (context, currentValue) async {
                          dtStartDate = DateTime(
                              dtStartDate.year,
                              dtStartDate.month,
                              dtStartDate.day,
                              dtStartDate.hour,
                              dtStartDate.minute,
                              dtStartDate.second);
                          final date = await RoundedDatePicker.show(
                            context,
                            theme: ThemeData(primarySwatch: Colors.red),
                            initialDate: DateTime(
                                dtStartDate.year, dtStartDate.month,
                                dtStartDate.day),
                            locale: Locale("th", "TH"),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            dtStartDate = date;
                            String sThaiMonth = dtStartDate.day.toString() +
                                ' ' +
                                getMonthName(dtStartDate.month) +
                                ' ' +
                                dtStartDate.year.toString();
                            dateStart_controller =
                                TextEditingController(text: sThaiMonth);
                            setDataListViewFirstTime(0);
                            setState(() {});

                            return DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                          } else {
                            String sThaiMonth = dtStartDate.day.toString() +
                                ' ' +
                                getMonthName(dtStartDate.month) +
                                ' ' +
                                dtStartDate.year.toString();
                            dateStart_controller =
                                TextEditingController(text: sThaiMonth);
//                              return DateTime(
//                                  dtStartDate.year,
//                                  dtStartDate.month,
//                                  dtStartDate.day,
//                                  dtStartDate.hour,
//                                  dtStartDate.minute);
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 15,
                          ),
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.blue,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Column(children: <Widget>[
                Container(
                  child: IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red,),
                    onPressed: () =>
                        showDialog(
                            context: context,
                            builder: (_) {
                              String sDate = dtStartDate.toString().substring(0,
                                  10);
                              return AlertDialog(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: Text(
                                    "ต้องการล้างรายการทั้งหมดของ $sDate หรือไม่?"),
                                actions: <Widget>[
                                  FlatButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon:
                                      Icon(Icons.close, color: Colors.grey),
                                      label: Text(
                                        "ยกเลิก",
                                        style: TextStyle(color: Colors.grey),
                                      )),
                                  FlatButton.icon(
                                      onPressed: () async {
                                        deleteAllByDate();
                                      },
                                      icon: Icon(Icons.delete_forever,
                                          color: Colors.red),
                                      label: Text(
                                        "ล้างข้อมูล",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                ],
                              );
                            }),
                  ),
                ),
                Container(
                  child: Text("ล้างข้อมูลวันที่เลือก",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,),
                )
              ],)
          )
        ],)
    );
  }

  Widget _buildRow(ModelProduct pair, int index) {
    return Card(
      elevation: 5.0,
      color: Colors.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: new Hero(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5)),
                                border: Border.all(color: Colors.grey)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                                child: pair.sImage
                            ),
                          ),
                          tag: pair.sImg64,
                        ),
                        onTap: () {
                          Navigator.of(context).push(new PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) {
                                return new Material(
                                    color: Colors.black38,
                                    child: new Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5)),
//                                    padding: const EdgeInsets.all(30.0),
                                      child: new InkWell(
                                        child: new Hero(
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5)),
                                              child: ImagesConverter
                                                  .imageFromBase64String(
                                                      pair.sImg64,
                                                      bTapView: true)),
                                          tag: pair.sImg64,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ));
                              }));
                        },
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 1,
                  right: 1,
                  child: IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: Text("ต้องการลบรายการนี้หรือไม่?"),
                                actions: <Widget>[
                                  FlatButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon:
                                          Icon(Icons.close, color: Colors.grey),
                                      label: Text(
                                        "ยกเลิก",
                                        style: TextStyle(color: Colors.grey),
                                      )),
                                  FlatButton.icon(
                                      onPressed: () async {
                                        deleteFromDB(pair.sBarcode);
                                      },
                                      icon: Icon(Icons.delete_forever,
                                          color: Colors.red),
                                      label: Text(
                                        "ลบ",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                ],
                              );
                            });
                      }),
                )
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5),
            child: new Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    pair.sBarcode,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5),
            child: new Row(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  pair.sDate + ' น.',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          new Container(
              padding: EdgeInsets.only(left: 5, bottom: 5),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        pair.sUsername,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.1),
                      ),
                    ],
                  ),
                  Container(
//                    decoration: BoxDecoration(
//                        color: Colors.red,
//                        borderRadius: BorderRadius.circular(5),
//                        border: Border.all(color: Colors.grey)),
//                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(
                      right: 5,
                    ),
                    child: GestureDetector(
                      child: Text(
                        '..ดูเพิ่มเติม',
                        style: _textStyleButton,
                      ),
                      onTap: () {
                        _onClickPushPage(pair.sBarcode);
                      },
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
