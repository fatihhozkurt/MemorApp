import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

//Temayı yönetmek için kullanacağımız sınıf
class ThemeService {
  // Get Storage paketini kullanarak yerel depolama alanına erişmek için bir nesne oluşturur.
  final _box = GetStorage();
  //Temanın açık mı koyu mu olduğunu kaydetmek için kullanılacak bir değişken tanımlar.
  final _key = 'isDarkMode';

  //Kayıtlı tema modunu okuyarak isDarkMode'u okur ve değerine göre tema döndürür.
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

//isDarkMode değişkeninin değerini yerel depolamaya kaydeder.
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

//Bu fonksiyon temayı değiştirmeyi sağlar
  void switchTheme() {
    //GetX paketinin changeThemeMode() metodunu kullanarak uygulamanın temasını değiştirir.
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    //Yeni temayı kaydeder
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
