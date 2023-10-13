import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mmt_cv_sochi/src/main_pg/Left_Menu.dart';
import 'package:mmt_cv_sochi/src/main_pg/MEGAMEN.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:archive/archive.dart';

// Парсинг json
class Data {
  final String file_name;
  final String pred_class;

  Data({
    required this.file_name, 
    required this.pred_class,
    });

}


class CVModel extends StatefulWidget {
  CVModel({super.key});
  
  @override
  State<CVModel> createState() => _CVModelState();
}


class  _CVModelState extends State<CVModel>{
  final _pageController = PageController();
  late var newDataList = [];
  List<String> images = [
    "./assets/images/small_round.png"
  ];
  bool flag = false;
  
  // unzip ответа от сервера 
  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        print("test file");
        print(filename);
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png')) {
          File('./responce/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
          images.add('./responce/$filename');
        }
        else {
          File('responce/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        }
      } else {
        print("test dir");
        await Directory('responce/$filename').create(recursive: true);
      }
    }
  }
  //загрузка изображений 
  Future<void> uploadImage() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final picker = ImagePicker();
    List<XFile>? imageFileList = [];
    final List<XFile> selectedImages = await picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
        imageFileList.addAll(selectedImages);
    }
    List<String>? base64list = [];
    for (var i = 0; i < imageFileList.length; i++) {
      final imageBytes1 = await imageFileList[i].readAsBytes();
      final base64Image1 = base64.encode(imageBytes1);
      base64list.add(base64Image1);
    }
    final json = {'files': base64list};
    print('doSomething() executed in ${stopwatch.elapsed}');
    final response = await http.post(
        // Uri.parse('http://95.163.250.213/get_result_64'), // 5.188.143.201 185.130.112.217 95.163.250.196
        Uri.parse('http://127.0.0.1:8000/get_result_64'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(json),
      );
      // print(jsonEncode(json));
      print('doSomething() executed in ${stopwatch.elapsed}');
      if (response.statusCode == 200) {
        print('Image(s) uploaded successfully!');
        unzipFileFromResponse(response.bodyBytes);
        const path = "./responce/data.txt";
        File dataFile = File(path);
        String dataString = dataFile.readAsStringSync();
        final responceMap = jsonDecode(dataString);
        List<dynamic> dataMap = jsonDecode(jsonEncode(responceMap["data"]));
        List<List> dataList = dataMap.map((element) => [element['file_name'], element['pred_class']]).toList();
        setState(() {
          flag = true;
          newDataList = dataList;          
          if (images.contains("./assets/images/small_round.png")) {
            images.remove("./assets/images/small_round.png");
          }
        });
        print('doSomething() executed in ${stopwatch.elapsed}');
      } else {
        print('Failed to upload image.');
      }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF181818),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFFEDB828),
            size: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Left_Menu()),
            );
          },
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
        //     child:  IconButton(
        //       icon: const Icon(
        //         Icons.person,
        //         color: Color(0xffd9fae9),
        //         size: 24,
        //       ),
        //       onPressed: () {
        //         // Navigator.push(
        //         //   context,
        //         //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
        //         // );
        //       },
        //     ),
        //   ),
        // ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 920),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0x00000000),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MEGAMEN()),
                          );
                        },
                        color: const Color(0xFFEDB828),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        textColor: const Color(0xFF181818),
                        height: 60,
                        minWidth: 180,
                        child: const Text(
                          "MEGAMEN TEAM",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            //   child: MaterialButton(
                            //     onPressed: () {
                            //       // Navigator.push(
                            //       //   context,
                            //       //   MaterialPageRoute(builder: (context) => const Uploaded_files()),
                            //       // );
                            //     },
                            //     color: const Color(0xFFEDB828),
                            //     elevation: 0,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(7.0),
                            //     ),
                            //     padding: const EdgeInsets.all(10),
                            //     textColor: const Color(0xFF181818),
                            //     height: 45,
                            //     minWidth: 130,
                            //     child: const Text(
                            //       "БД устройства",
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w600,
                            //         fontStyle: FontStyle.normal,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MaterialButton(
                                onPressed: () {
                                  uploadImage();
                                  // print(images);
                                },
                                color: const Color(0xFFEDB828),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                padding: const EdgeInsets.all(15),
                                textColor: const Color(0xFF181818),
                                height: 45,
                                minWidth: 130,
                                child: const Text(
                                  "Загрузить ваш файл",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Таблица предсказаний:",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                fontSize: 17,
                                color: Color(0xFFF3F2F3),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 18, 0),
                                child: Text(
                                  "Имя файла",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xFFF3F2F3),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                child: Text(
                                  "Предсказанный класс",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xFFF3F2F3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                      SizedBox(
                                        height: 120,
                                        width: 120,
                                        child: ListView.builder(
                                          itemCount: newDataList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final item = newDataList[index];
                                          return item != null ? ListTile(
                                            title: Text('${(index+1)}. ${item[0]}'),
                                            // subtitle: Text('Code: ${item[1]}'),
                                            ) : Container();
                                          },  
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                      SizedBox(
                                        height: 120,
                                        width: 120,
                                        child: ListView.builder(
                                          itemCount: newDataList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final item = newDataList[index];
                                          return item != null ? ListTile(
                                            title: Text('${(index+1)}. ${item[1]}'),
                                            ) : Container();
                                          },  
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 20, 30, 10),
                    child: Text(
                      "Недавние изображения, распознанные моделью",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Color(0xFFF3F2F3),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 270,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController ,
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child:
                                      Image.file(File(images[index]),
                                        height: 200,
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.contain,
                                      )),
                                    
                                  // child: Image.asset(
                                  //   "assets/images/Untitled-1.png",
                                  //   height: 200,
                                  //   width: MediaQuery.of(context).size.width,
                                  //   fit: BoxFit.contain,
                                  // ),
                                // ),
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: SmoothPageIndicator(
                              controller: _pageController ,
                              count: images.length,
                              axisDirection: Axis.horizontal,
                              effect: const ExpandingDotsEffect(
                                dotColor: Color(0xFFBC6626),
                                activeDotColor: Color(0xFFEDB828),
                                dotHeight: 10,
                                dotWidth: 10,
                                radius: 16,
                                spacing: 7,
                                expansionFactor: 5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 10),
                    child: Text(
                      "Загруженные изображения",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Color(0xFFF3F2F3),
                      ),
                    ),
                  ),
                  GridView(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    children: [
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF232323),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child:
                              Image(
                            image: AssetImage("assets/images/Untitled-1.png"),
                            height: 100,
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF232323),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child:
                              Image(
                            image: AssetImage("assets/images/Untitled-1.png"),
                            height: 100,
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Color(0xFFEDB828),
                    height: 16,
                    thickness: 3,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child:
                              Image(
                            image: AssetImage("assets/images/rgi_logo.png"),
                            height: 190,
                            width: 190,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          "ЮФО 2023",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 18,
                            color: Color(0xFFEDB828),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
