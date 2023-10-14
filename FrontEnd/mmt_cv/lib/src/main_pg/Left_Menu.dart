import 'package:flutter/material.dart';
import 'package:mmt_cv_sochi/src/main_pg/CVModel.dart';
import 'package:url_launcher/url_launcher.dart';


final Uri githubDOCS = Uri.parse('https://github.com/mireaMegaman/sochi_hack/blob/main/README.md');
final Uri repository = Uri.parse('https://github.com/mireaMegaman/sochi_hack');
final Uri serversDocs = Uri.parse('https://mega-men.ru/docs');


// ignore: camel_case_types
class Left_Menu extends StatelessWidget {
  const Left_Menu({super.key});

  Future<void> _github() async {
    if (!await launchUrl(githubDOCS)) {
      throw Exception('Could not launch $githubDOCS');
    }
  }

  Future<void> _repo() async {
    if (!await launchUrl(repository)) {
      throw Exception('Could not launch $repository');
    }
  }

  Future<void> _servdoc() async {
    if (!await launchUrl(serversDocs)) {
      throw Exception('Could not launch $serversDocs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0x00121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFFEDB828),
            size: 20,
          ),
          onPressed: () {
            Navigator.push(
              context,
              // MaterialPageRoute(builder: (context) => CVModel(newDataList: [],)),
              MaterialPageRoute(builder: (context) => CVModel()),
            );
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 50),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Приветствуем вас в MMT-CV!",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xFFF3F2F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(10),
                          width: 310,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xff292929),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: const Color(0x4d292929), width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Здесь вы можете:",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ListView(
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: false,
                                  physics: const ScrollPhysics(),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "1. Ознакомиться с техническим заданием наших партнеров",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "2. Посмотреть инструкцию по использованию приложения",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "3. Обратитесь к документации",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "4. Перейдите на внешние ссылки нашей команды (например, GitHub или Telegram)",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
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
                  const Divider(
                    color: Color(0xFFEDB828),
                    height: 16,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Divider(
                          color: Color(0xFFEDB828),
                          height: 16,
                          thickness: 0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Container(
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(10),
                          // width: MediaQuery.of(context).size.width * 0.85,
                          width: 310,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xff292929),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: const Color(0xff292929), width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Техническое задание наших партнеров:",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Color(0xFFF3F2F3),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ListView(
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: false,
                                  physics: const ScrollPhysics(),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "1. Создать решение для распознавания различных номеров вагонов",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "2. Предсказания модели передавать на внешний API",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "3. ",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                      child: Text(
                                        "4.  ",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xffffffff),
                                        ),
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
                  const Divider(
                    color: Color(0xFFEDB828),
                    height: 16,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                _github();
                              },
                              color: const Color(0xFFEDB828),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(16),
                              textColor: const Color(0xff000000),
                              height: 40,
                              minWidth: 140,
                              child: const Text(
                                "Документация",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 25),
                              child: MaterialButton(
                                onPressed: () {
                                  _repo();
                                },
                                color: const Color(0xFFEDB828),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.all(16),
                                textColor: const Color(0xff000000),
                                height: 40,
                                minWidth: 140,
                                child: const Text(
                                  "Репозиторий",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                _servdoc();
                              },
                              color: const Color(0xFFEDB828),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(16),
                              textColor: const Color(0xff000000),
                              height: 40,
                              minWidth: 140,
                              child: const Text(
                                "FastAPI Docs",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Color(0xFFEDB828),
                    height: 16,
                    thickness: 3,
                    indent: 0,
                    endIndent: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
