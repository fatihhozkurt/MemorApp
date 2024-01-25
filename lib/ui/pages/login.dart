import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_management/ui/pages/home_page.dart';
import 'package:task_management/ui/pages/signup.dart';
import '../../db/sqlite.dart';
import '../../models/user.dart';
//Gerekli kütüphaneleri ekliyoruz.

//StatefulWidget kullanarak LoginScreen sınıfını oluşturuyoruz.
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Kullanıcı adı, şifre, şifre görünürlüğü ve giriş durumu değişkenlerinin tanımlanması.
  final username = TextEditingController();
  final password = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;

  //Daha sonra veri tabanı işlemlerinde kullanılmak üzere DataBaseHelper sınıfının db örneği oluşturuluyor.
  final db = DatabaseHelper();

  //Giriş doğrulama işlemlerini kontrol edecek fonksiyon.
  login() async {
    var response = await db
        .login(Users(usrName: username.text, usrPassword: password.text));
    if (response == true) {
      //Eğer giriş başarılıysa navigatör ile Hatırlatmalarım sayfasına yönlendirir
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      //Eğer değilse kontrol için isLoginTrue değişkenini ayarlar.
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  //formKey adında bir global anahtar oluşturuyoruz.
  final formKey = GlobalKey<FormState>();

  //Sayfanın en dışında duracak widgetımızı oluşturuyoruz.
  @override
  Widget build(BuildContext context) {
    //Scaffold ile temel ekran yapısını oluşuruyoruz
    return Scaffold(
      //Widget ağacı kullanarak ortalama, kenar boşlukları gibi özellikleri ekliyoruz
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            //Tüm metinleri tek bir form içerisine koyarak boş olup olmadıklarını kontrol ediyoruz
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  //Giriş sayfasında görünecek uygulama ikonu
                  Image.asset(
                    "lib/assets/appicon.png",
                    width: 210,
                  ),
                  const SizedBox(height: 5),

                  //Kullanıcı adı alanı
                  Container(
                    //Kullanıcı adı alanı görünümünün özelleştirmeleri
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.lightBlueAccent.withOpacity(.4)),
                    child: TextFormField(
                      //Kullanıcı adı alanının boşluk kontrolü ve uyarı yazısı
                      controller: username,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Kullanıcı adı gerekli!";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Kullanıcı Adı",
                      ),
                    ),
                  ),

                  //Şifre alanı
                  const SizedBox(height: 5),
                  Container(
                    //Şifre alanının görünüm özelleştirmeleri
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.lightBlueAccent.withOpacity(.4)),
                    child: TextFormField(
                      //Şifre alanı boşluk kontrolü ve uyarı yazısı
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Şifre gerekli!";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Şifre",
                          suffixIcon: IconButton(
                              //Şifre alanındaki icona tıklandığında şifrenin görününürlüğünün ayarlanması
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),

                  const SizedBox(height: 15),
                  //Giriş Yap butonu
                  Container(
                    //Giriş Yap butonunun görünüm özelleştirmeleri
                    height: 55,
                    width: MediaQuery.of(context).size.width * .5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black),
                    child: TextButton(
                        //Butona tıklandığında gerçekleşecek fonksiyon
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Eğer form doğrulanmışsa giriş yapmak için login fonksiyonunu çağır
                            login();
                          }
                        },
                        child: const Text(
                          "Giriş Yap",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),

                  //Mevcut hesabı yoksa kayıt olmak için kayıt ol linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //"Hesabın yok mu?"" yazısı
                      const Text("Hesabın yok mu?"),
                      const SizedBox(height: 20),
                      TextButton(
                          onPressed: () {
                            //Kayıt ol yazısına tıklandığında Kayıt ol sayfasına yönlendirme
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp()));
                          },
                          //"Kayıt Ol" yazısı
                          child: const Text("Kayıt Ol"))
                    ],
                  ),

                  //isLoginTrue kontrolü ile kullanıcı adının veya şifrenin hatalı olması durumunda görünecek mesaj
                  isLoginTrue
                      ? const Text(
                          "Kullanıcı adı veya şifre hatalı!",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
