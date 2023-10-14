import 'package:flutter/material.dart';
import 'package:mmt_cv_sochi/src/main_pg/CVModel.dart';

class LoadingWait extends StatelessWidget {
  const LoadingWait({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff5e6f76),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 620),
          child: Align(
            alignment: const Alignment(0.0, -0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Text(
                        "Все должно работать!",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 20,
                          color: Color(0xffd5f6e4),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Text(
                        "Но если вы долго находитесь на этом экране, для вашего спасения есть кнопка ниже",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xffd7d7d7),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            // MaterialPageRoute(builder: (context) => CVModel(newDataList: [],)),
                            MaterialPageRoute(builder: (context) => CVModel()),
                          );
                        },
                        color: const Color(0xffdbfeeb),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xff000000),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "Домой",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
