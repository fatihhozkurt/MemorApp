import 'dart:async';
import 'dart:ffi';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_management/controllers/task_controller.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/services/notification_services.dart';
import 'package:task_management/ui/pages/add_task_page.dart';
import 'package:task_management/ui/size_config.dart';
import 'package:task_management/ui/theme.dart';
import 'package:task_management/ui/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:task_management/ui/widgets/task_tile.dart';
import '../../services/theme_services.dart';
//Gerekli kütüphanelerin import edilmesi

//Daha sonra kullanmak üzere statefull class
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

//Ana classımız
class _HomePageState extends State<HomePage> {
  //Hatırlatma kartında kullanacağımız değişkenler
  DateTime _selectedDate = DateTime.parse(DateTime.now().toString());
  final _taskController = Get.put(TaskController());
  late var notifyHelper;
  bool animate = false;
  double left = 630;
  double top = 900;
  Timer? _timer;

//Bildirim için gerekli ayarlamaları yapıyoruz
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    _timer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        animate = true;
        left = 30;
        top = top / 3;
      });
    });
  }

  //Sayfanın temel yapısına ekleyeceğimiz fonksiyonlar
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _dateBar(),
          SizedBox(
            height: 12,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  //Tarih seçimi
  _dateBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: DatePicker(
          //Tarih başlangıcı
          DateTime.now(),
          height: 100.0,
          width: 80,
          initialSelectedDate: DateTime.now(),
          selectionColor: primaryClr,
          dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          //Gün
          dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          //Ay
          monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
            ),
          ),
          //Seçilen tarih değişkeni
          onDateChange: (date) {
            setState(
              () {
                _selectedDate = date;
              },
            );
          },
        ),
      ),
    );
  }

  //Hatırlatma ekleme buton fonksiyonu
  _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      //Div
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            //Harılatmalarım
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Hatırlatmalarım",
                style: headingTextStyle,
              ),
            ],
          ),
          //Buton
          MyButton(
            label: "+ Ekle",
            onTap: () async {
              await Get.to(AddTaskPage());
              _taskController.getTasks();
            },
          ),
        ],
      ),
    );
  }