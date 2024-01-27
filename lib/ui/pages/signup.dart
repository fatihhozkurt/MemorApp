import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../db/sqlite.dart';
import '../../models/user.dart';
import 'login.dart';
//Gerekli kütüphaneleri ekliyoruz

//SignUp adında bir durum sınıfı oluşturuyoruz
class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //Kullanıcı adı, şifre, şifre doğrulama ve şifre görünürlüğü değişkenlerinin atanması
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool isVisible = false;
  //Değişkenlerin durumlarını kontrol etmek için form oluşturulması
  final formKey = GlobalKey<FormState>();

  //Sayfanın en dışında duracak widgetımızı oluşturuyoruz.
  @override
  Widget build(BuildContext context) {
    //Scaffold ile temel ekran yapısını oluşuruyoruz
    return Scaffold(
      //Widget ağacı kullanarak ortalama, kenar boşlukları gibi özellikleri ekliyoruz
      body: Center(
        //Bottom overflow hatası oluşmaması için SingleChildScrollView kullanılması
        child: SingleChildScrollView(
          //Tüm metinleri tek bir form içerisine koyarak boş olup olmadıklarını kontrol ediyoruz
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Kayıt ol sayfasında görünecek robot ikonu
                  Image.asset(
                    "lib/assets/robot.png",
                    width: 210,
                  ),

                  //Kullanıcı adı alanı
                  Container(
                    //Kullanıcı adı alanı görünümünün özelleştirmeleri
                    margin: EdgeInsets.all(8),
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
                  Container(
                    //Şifre alanının görünüm özelleştirmeleri
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.lightBlueAccent.withOpacity(.4)),
                    child: TextFormField(
                      //Şifre alanının boşluk kontrolü ve uyarı yazısı
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

                  //Şifre alanı
                  Container(
                    //Şifre alanının görünüm özelleştirmeleri
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.lightBlueAccent.withOpacity(.4)),
                    child: TextFormField(
                      //Şifre alanındaki boşluk kontrolü
                      controller: confirmPassword,
                      validator: (value) {
                        //Eğer alan boşsa "Şifre gerekli!" yazısı gösterir
                        if (value!.isEmpty) {
                          return "Şifre gerekli!";

                          //Eğer bir önceki şifre alanındaki şifre ile eşleşmiyorsa "Şifreler eşleşmiyor!" yazısı gösterir
                        } else if (password.text != confirmPassword.text) {
                          return "Şifreler eşleşmiyor!";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Şifreyi tekrarla",
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
                  //Kayıt ol butonu
                  Container(
                    //Kayıt ol butonunun görünüm özelleştirmeleri
                    height: 55,
                    width: MediaQuery.of(context).size.width * .5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black),
                    child: TextButton(
                        //Butona tıklandığında gerçekleşecek fonksiyon
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Eğer form doğrulanmışsa DatabaseHelper sınıfından db adında bir nesne oluşturur
                            final db = DatabaseHelper();
                            //Kullanıcı bilgilerini veri tabanına kayıt eder
                            db
                                .signup(Users(
                                    usrName: username.text,
                                    usrPassword: password.text))
                                .whenComplete(() {
                              //Kayıt ettikten sonra kullanıcıyı Giriş Yap sayfasına yönlendirir
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            });
                          }
                        },
                        child: const Text(
                          "Kayıt Ol",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),

                  //Zaten bir hesabın var mı linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Kullanıcının hesabı varsa onu Giriş Yap sayfasına yönlendiriyoruz
                      const Text("Zaten hesabın var mı?"),
                      TextButton(
                          //"Zaten hesabın var mı? Giriş Yap" tıklandığında Giriş Yap sayfasına yönlendiriyoruz
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: const Text("Giriş Yap"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
