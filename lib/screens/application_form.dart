import 'package:blowjobboard/data/mog_data.dart';
import 'package:blowjobboard/data/mock_repository.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_scroll/text_scroll.dart';

const cvType = XTypeGroup(
  label: "PDF",
  extensions: ["pdf"]
);

class ApplicationForm extends StatefulWidget {
  const ApplicationForm({
    super.key,
    
    required this.job
    });

    final JobPost job;

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {

    final formKey = GlobalKey<FormState>();
    XFile? selectedCv;
    String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextScroll(
                widget.job.title,
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
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.job.title} @ ${widget.job.company}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 8,),
                      Text("Приложите ваш CV"),
                      SizedBox(height: 8,),
                      OutlinedButton(
                        onPressed: () async {
                          final file = await openFile(acceptedTypeGroups: [cvType]);
                          if (file == null) return;
                          
                          setState(() {
                            selectedCv = file;
                          });

                          print("*****************${file.name}");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_file),
                            Flexible(
                              child: 
                              Text(
                              selectedCv?.name ?? "Выбрать файл",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text("...и добавьте короткое сообщение работодателю"),
                      SizedBox(height: 16,),
                      TextFormField(
                        onChanged: (value) {
                          message = value;
                        },
                        validator: (value) {
                          if (value == null || value.trim().length < 10){
                            return 'Минимум 10 символов';
                          }
                          return null;
                        },
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
                        maxLength: 300,
                        ),
                      SizedBox(height: 16,),
                      FilledButton(
                        onPressed: (){
                          final cv = selectedCv;
                          if (cv == null){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CV не выбран")));
                            return;
                          }
                      
                          if (!formKey.currentState!.validate()){
                            return;
                          }

                          mockRepository.addApplication(
                            jobPostId: widget.job.id,
                            cvName: cv.name,
                            message: message.trim(),
                          );

                          final messenger = ScaffoldMessenger.of(context);
                          context.pop();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Отклик отправлен')),
                          );
                        },
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
