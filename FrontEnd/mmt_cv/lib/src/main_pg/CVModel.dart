import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mmt_cv_sochi/src/main_pg/Left_Menu.dart';
import 'package:mmt_cv_sochi/src/main_pg/MEGAMEN.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:restart_app/restart_app.dart';
import 'package:archive/archive.dart';
// import 'package:path_provider/path_provider.dart';

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

  List<String> frstImgs = [
    "./assets/images/small_round.png",

  ];
  List<String> bboxImgs = [

    "./assets/images/small_round.png",
  ];
  List<String> cropImgs = [

    "./assets/images/small_round.png",
  ];

  bool flag = false;

  List<Widget> nameSlots = [];

  // ---------------------------------------------------------------------------------------------- //
  // unzip ответа от сервера 
  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        // print("test file");
        print(filename);
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png')) {
          File('./responce/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
          if (filename.contains('cropped_image')) {
            cropImgs.add('./responce/$filename');
          }
          else if (filename.contains('boxed_image')) {
            bboxImgs.add('./responce/$filename');
          }
          else {
            frstImgs.add('./responce/$filename');
          }
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
  
// ---------------------------------------------------------------------------------------------- //
  //загрузка изображений 
  Future<void> uploadImage() async {
    // Stopwatch stopwatch = Stopwatch()..start();
    final picker = ImagePicker();

    List<XFile>? imageFileList = [];
    List<String>? Path_files = [];

    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
        imageFileList.addAll(selectedImages);
    }
    
    for (var i = 0; i < imageFileList.length; i++) {
      // print(imageFileList[i].path.split("\\").last);
      Path_files.add(imageFileList[i].path.split("\\").last);
    }
    // print(Path_files);
    List<String>? base64list = [];
    for (var i = 0; i < imageFileList.length; i++) {
      final imageBytes1 = await imageFileList[i].readAsBytes();
      final base64Image1 = base64.encode(imageBytes1);
      base64list.add(base64Image1);
    }

    final json = {'files_names': Path_files,
                'files': base64list};

    // print('doSomething() executed in ${stopwatch.elapsed}');
    final response = await http.post(
        // Uri.parse('http://95.163.250.213/get_result_64'), // 5.188.143.201 185.130.112.217 95.163.250.196
        Uri.parse('http://127.0.0.1:8000/get_result_64'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(json),
    );

    // print(jsonEncode(json));

    // print('doSomething() executed in ${stopwatch.elapsed}');

    if (response.statusCode == 200) {
      // print('Image(s) uploaded successfully!');

      unzipFileFromResponse(response.bodyBytes);

      const path = "./responce/data.txt";

      File dataFile = File(path);

      String dataString = dataFile.readAsStringSync();

      final responceMap = jsonDecode(dataString);

      // print(responceMap);
      
      List<dynamic> dataMap = jsonDecode(jsonEncode(responceMap["data"]));

      print(dataMap);
      // List<List> dataList = dataMap.map((element) => [element['text'], element['probabilities']]).toList();
      // print(dataList);

      setState(() {
        flag = true;
        newDataList = dataMap; 
        if (frstImgs.contains("./assets/images/small_round.png")) {
          frstImgs.remove("./assets/images/small_round.png");
        }
        if (bboxImgs.contains("./assets/images/small_round.png")) {
          bboxImgs.remove("./assets/images/small_round.png");
        }
        if (cropImgs.contains("./assets/images/small_round.png")) {
          cropImgs.remove("./assets/images/small_round.png");
        }
      });
      // print('doSomething() executed in ${stopwatch.elapsed}');
    } else {
      // print('Failed to upload image.');
    }
  }
  // ---------------------------------------------------------------------------------------------- //
  // функция очистки папки
  Future<void> deleteFilesInFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
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
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child:  IconButton(
              icon: const Icon(
                Icons.autorenew_outlined,
                color: Color(0xFFEDB828),
                size: 24,
              ),
              onPressed: () {
                frstImgs = [
                  "./assets/images/small_round.png"
                ];
                setState(() {
                  flag = true;
                  newDataList = [];
                  frstImgs = [
                      "./assets/images/small_round.png",
                    ];
                    bboxImgs = [
                      "./assets/images/small_round.png",
                    ];
                    cropImgs = [
                      "./assets/images/small_round.png",
                    ];
                  deleteFilesInFolder("./responce");
                  Restart.restartApp();
                });
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          borderRadius: BorderRadius.circular(5.0),
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MaterialButton(
                                onPressed: () {
                                  uploadImage();
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
// ---------------------------------------------------------------------------------------------- //
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DataTable(
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 100,
                          border: TableBorder.all(
                            width: 2.0,
                            borderRadius: BorderRadius.circular(10.0),
                            color: const Color(0xFFEDB828),
                            ),
                            columns: const [
                              DataColumn(label: Text('Название файла',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),
                                    )
                              ),
                              DataColumn(label: Text('Номер вагона',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),
                                    )
                              ),
                              DataColumn(label: Text('Уверенность модели',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),
                                    )
                              ),
                              DataColumn(label: Text('Контрольная сумма',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),
                                    )
                              ),
                            ],
                            rows: newDataList.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item['name'], 
                                    style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),)
                                ),
                                DataCell(Text(item['number'].toString(), 
                                    style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),)
                                ),
                                DataCell(Text(item['confidence'], 
                                    style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),)
                                ),
                                DataCell(Text(item['is_correct'].toString(), 
                                    style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17,
                                              color: Color(0xFFF3F2F3),
                                            ),)
                                ),
                              ]);
                            }).toList(),
                          )
                      ],
                    ),
                  ),
// ---------------------------------------------------------------------------------------------- //
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 20, 30, 10),
                    child: Text(
                      "Недавние изображения, распознанные моделью",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Color(0xFFF3F2F3),
                      ),
                    ),
                  ),
// ---------------------------------------------------------------------------------------------- //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 270,
                          width: 350,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController ,
                                scrollDirection: Axis.horizontal,
                                itemCount: frstImgs.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child:
                                            Image.file(File(frstImgs[index]),
                                                      height: 200,
                                                      width: MediaQuery.of(context).size.width,
                                                      fit: BoxFit.contain,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Align(
                              //   alignment: Alignment.bottomCenter,
                              //   child: Padding(
                              //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              //     child: SmoothPageIndicator(
                              //       controller: _pageController ,
                              //       count: frstImgs.length,
                              //       axisDirection: Axis.horizontal,
                              //       effect: const ExpandingDotsEffect(
                              //         dotColor: Color(0xFFBC6626),
                              //         activeDotColor: Color(0xFFEDB828),
                              //         dotHeight: 10,
                              //         dotWidth: 10,
                              //         radius: 16,
                              //         spacing: 7,
                              //         expansionFactor: 5,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 270,
                          width: 350,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController ,
                                scrollDirection: Axis.horizontal,
                                itemCount: bboxImgs.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child:
                                            Image.file(File(bboxImgs[index]),
                                                      height: 200,
                                                      width: MediaQuery.of(context).size.width,
                                                      fit: BoxFit.contain,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Align(
                              //   alignment: Alignment.bottomCenter,
                              //   child: Padding(
                              //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              //     child: SmoothPageIndicator(
                              //       controller: _pageController ,
                              //       count: bboxImgs.length,
                              //       axisDirection: Axis.horizontal,
                              //       effect: const ExpandingDotsEffect(
                              //         dotColor: Color(0xFFBC6626),
                              //         activeDotColor: Color(0xFFEDB828),
                              //         dotHeight: 10,
                              //         dotWidth: 10,
                              //         radius: 16,
                              //         spacing: 7,
                              //         expansionFactor: 5,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 270,
                          width: 350,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController ,
                                scrollDirection: Axis.horizontal,
                                itemCount: cropImgs.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child:
                                            Image.file(File(cropImgs[index]),
                                                      height: 200,
                                                      width: MediaQuery.of(context).size.width,
                                                      fit: BoxFit.contain,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Align(
                              //   alignment: Alignment.bottomCenter,
                              //   child: Padding(
                              //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              //     child: SmoothPageIndicator(
                              //       controller: _pageController ,
                              //       count: cropImgs.length,
                              //       axisDirection: Axis.horizontal,
                              //       effect: const ExpandingDotsEffect(
                              //         dotColor: Color(0xFFBC6626),
                              //         activeDotColor: Color(0xFFEDB828),
                              //         dotHeight: 10,
                              //         dotWidth: 10,
                              //         radius: 16,
                              //         spacing: 7,
                              //         expansionFactor: 5,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Align(
                  //       alignment: Alignment.bottomCenter,
                  //       child: Padding(
                  //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                  //         child: SmoothPageIndicator(
                  //           controller: _pageController ,
                  //           count: cropImgs.length,
                  //           axisDirection: Axis.horizontal,
                  //           effect: const ExpandingDotsEffect(
                  //             dotColor: Color(0xFFBC6626),
                  //             activeDotColor: Color(0xFFEDB828),
                  //             dotHeight: 10,
                  //             dotWidth: 10,
                  //             radius: 16,
                  //             spacing: 7,
                  //             expansionFactor: 5,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
// ---------------------------------------------------------------------------------------------- //
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                    child: Divider(
                      color: Color(0xFFEDB828),
                      height: 16,
                      thickness: 3,
                      indent: 0,
                      endIndent: 0,
                    ),
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
    throw UnimplementedError();
  }
}
