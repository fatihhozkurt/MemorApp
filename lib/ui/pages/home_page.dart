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

  //Appbar
  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      //Appbar Lead
      leading: GestureDetector(
        onTap: () {
          //Tema bildirimi
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Tema Değiştirildi",
            //Getx
            body: Get.isDarkMode
                ? "Aydınlık temaya geçildi."
                : "Karanlık temaya geçildi",
          );

          notifyHelper.scheduledNotification();
          notifyHelper.periodicalyNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny : Icons.shield_moon,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
          size: 32,
        ),
      ),
      //Appbar Mid
      title: Center(
        child: Image.asset(
          "lib/assets/appicon.png",
          width: 54, // İstediğiniz genişliği belirleyin
          height: 54, // İstediğiniz yüksekliği belirleyin
        ),
      ),
      //Appbar Tail
      actions: [
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage("lib/assets/sergeant.png"),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  //Hatırlatma Kartları
  _showTasks() {
    return Expanded(
      child: Obx(() {
        //Görev yok
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else
          return ListView.builder(
              scrollDirection: Axis.vertical,
              //Kart sayısı
              itemCount: _taskController.taskList.length,
              itemBuilder: (context, index) {
                Task task = _taskController.taskList[index];
                //Günlük tekrar
                if (task.repeat == 'Daily') {
                  var hour = task.startTime.toString().split(":")[0];
                  var minutes = task.startTime.toString().split(":")[1];
                  debugPrint("My time is " + hour);
                  debugPrint("My minute is " + minutes);

                  //Saat formatı
                  DateTime date = DateFormat.jm().parseLoose(task.startTime!);
                  var myTime = DateFormat("HH:mm").format(date);

                  //Zamanlanmış bildirim (ama)
                  notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(":")[0]),
                      int.parse(myTime.toString().split(":")[1]),
                      task);

                  //Animasyonlar için kullandığımız paketin ayarlanması
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1375),
                    child: SlideAnimation(
                      horizontalOffset: 300.0,
                      child: FadeInAnimation(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  showBottomSheet(context, task);
                                },
                                child: TaskTile(task)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                //Eğer görevin tarihi seçili tarihle aynıysa zamanlı bildirim ve kart animasyonlarını ayarla
                if (task.date == DateFormat.yMd().format(_selectedDate)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1375),
                    child: SlideAnimation(
                      horizontalOffset: 300.0,
                      child: FadeInAnimation(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Kartlara basıldığında çağrılacak fonksiyon
                            GestureDetector(
                                onTap: () {
                                  showBottomSheet(context, task);
                                },
                                child: TaskTile(task)),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              });
      }),
    );
  }

  //Hatırlatma kartlarına basıldığında çağrılan fonksiyon
  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 4, left: 6, right: 6, bottom: 4),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Wrap(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            //Buton fonksiyonu
            _buildBottomSheetButton(
              label: "Tamamlandı",
              onTap: () {
                _taskController.markTaskCompleted(task.id);
                Get.back();
              },
              clr: primaryClr,
            ),
            //Buton fonksiyonu
            _buildBottomSheetButton(
              label: "Hatırlatmayı Sil",
              onTap: () {
                _taskController.deleteTask(task);
                Get.back();
              },
              clr: Colors.red[300],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true, // Take up the entire screen height
    );
  }

  //BottomSheet in buton componenti için fonksiyonu
  _buildBottomSheetButton(
      {required String label,
      Function? onTap,
      Color? clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr!,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(
          label,
          style: isClose
              ? titleTextStle
              : titleTextStle.copyWith(color: Colors.white),
        )),
      ),
    );
  }

  _noTaskMsg() {
    double paddingTop = 50.0; // İstediğiniz padding miktarı

    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 2000),
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "lib/assets/alarm.svg",
                    color: primaryClr.withOpacity(0.8),
                    height: 90,
                    semanticsLabel: 'Task',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      "Henüz hatırlatma eklemedin! \n Ya da eklemeyi mi unuttun?",
                      textAlign: TextAlign.center,
                      style: subTitleTextStle,
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
