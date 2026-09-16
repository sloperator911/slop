import 'package:blowjobboard/data/mog_data.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class ApplicationForm extends StatelessWidget {
  const ApplicationForm({
    super.key,
    
    required this.job
    });

    final JobPost job;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextScroll(
                job.title,
                mode: TextScrollMode.endless,
                pauseBetween: Duration(seconds: 1),
                ),
              ),
              const SizedBox(width: 8,),
              Text(": Отклик")
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: 
              Padding(padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${job.title} : ${job.company}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 8,),
                      Text("Приложите ваш CV"),
                      SizedBox(height: 8,),
                      OutlinedButton(
                        onPressed: () async {
                          final file = await openFile();
                          print("*****************${file?.name}");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_file),
                            Text("Выбарть файл")
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text("...и по желнию добавьте короткое сообщение работодателю"),
                      SizedBox(height: 16,),
                      TextFormField(
                        decoration: InputDecoration(
                          hint: Opacity(
                            opacity: 0.5,
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                Text("Максимум 300 символов",),
                                ],
                              ),
                            ),
                          border: OutlineInputBorder()
                          ),
                        minLines: 5,
                        maxLines: 5,
                        ),
                      SizedBox(height: 16,),
                      FilledButton(
                        onPressed: (){},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            Text("Отправить")
                          ],
                        ),
                      ),
                    
                    ],
                  ),
                ),
              ),
            
          )
        ],

      ),
    );
  }
}
