import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/handle_request.dart';
import 'package:flutter_application_1/student/student_announcement.dart';
import 'package:flutter_application_1/student/student_notification.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final dynamic users;
  const DashboardScreen(this.users, {super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedCategory = 0;

  final List<String> categories = ["Dropping", "Clearance", "Graduation"];
  dynamic requirements = {
    "Dropping": [],
    "Clearance": [],
    "Graduation": [],
  };
  dynamic uploadStatuses = {
    "Dropping": [],
    "Clearance": [],
    "Graduation": [],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = {};
      response = await requestHandler.handleRequest(
        context,
        'users/user-requirements',
        body: {'category': "Dropping", "userId": widget.users['id']},
      );
      if (response['success'] == true) {
        setState(() {
          requirements = response['requirements'];
          uploadStatuses = response['uploadStatuses'];
        });
        print(requirements);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Loading employee error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  File? selectedFile;
  Future<void> _pickFile(requirement) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
      var uploaded = await uploadFile();
      uploadAFile(uploaded, requirement);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }

  Future<String> uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload.')),
      );
      return "";
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://ccc-clearance.netlify.app/.netlify/functions/api/file/upload-file'));
      request.files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded: ${responseData['uploadedDocument']}')),
          );
          return responseData['uploadedDocument'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${responseData['message']}')),
          );
        }
      } else {
        throw Exception('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
    return "";
  }

  Future<void> uploadAFile(uploaded, requirement) async {
    RequestHandler requestHandler = RequestHandler();
    try {
      Map<String, dynamic> response = {};
      response = await requestHandler.handleRequest(
        context,
        'users/upload-requirements',
        body: {
          'id': requirement['id'],
          'attachedFile': uploaded,
          'userId': widget.users['id'],
          'category': categories[_selectedCategory]
        },
      );
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Uploaded Successfuly"),
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => DashboardScreen(widget.users)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Loading employee error'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String category = categories[_selectedCategory];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text("Dashboard"),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(widget.users),
                  ),
                );
              }),
          IconButton(
              icon: const Icon(Icons.announcement),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnnouncementScreen(),
                  ),
                );
              }),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(widget.users),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categories[_selectedCategory],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: requirements[category].length,
                itemBuilder: (context, index) {
                  var requirement = requirements[category][index];
                  var uploadStatus = uploadStatuses[category][index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.file_present, color: Colors.blue),
                          title: Text(requirement['title']),
                          subtitle: Text(requirement['description'] ?? 'No description available'),
                          trailing: uploadStatus['date'] == null
                              ? ElevatedButton(
                                  onPressed: () => {_pickFile(requirements[category][index])},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    "Upload",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : null,
                        ),
                        if (uploadStatus['date'] != null)
                          ExpansionTile(
                            title: const Text("Upload Info"),
                            children: [
                              ListTile(
                                title: const Text("Status:"),
                                subtitle: Text(uploadStatus['status']),
                              ),
                              ListTile(
                                title: const Text("Uploaded On:"),
                                subtitle: Text(uploadStatus['date']!),
                              ),
                              ListTile(
                                title: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      uploadStatuses[category][index] = {"status": "pending", "date": null};
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    "Remove",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // View Requirement Button
                        ListTile(
                          title: ElevatedButton(
                            onPressed: () {
                              _showRequirementDialog(context, requirement);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              "View Requirement",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedCategory,
        onTap: (index) {
          setState(() {
            _selectedCategory = index;
          });
        },
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        items: categories
            .map(
              (category) => BottomNavigationBarItem(
                icon: const Icon(Icons.folder),
                label: category,
              ),
            )
            .toList(),
      ),
    );
  }

  void _showRequirementDialog(BuildContext context, Map<String, dynamic> requirement) {
    print(requirement['attachedFile']);
    String? attachedFile = requirement['attachedFile'];
    String? fileExtension = attachedFile != null ? attachedFile.split('.').last.toLowerCase() : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${requirement['title']}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Here is the preview of the requirement file:"),
                const SizedBox(height: 10),
                Text(
                  "${requirement['title']}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (attachedFile != null && attachedFile.isNotEmpty)
                  if (fileExtension == 'pdf')
                    Container(
                      width: double.infinity,
                      height: 400,
                      child: SfPdfViewer.network(attachedFile),
                    )
                  else if (['png', 'jpg', 'jpeg'].contains(fileExtension))
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        attachedFile,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Text("Preview not supported for .$fileExtension files."),
                if (attachedFile == null || attachedFile.isEmpty) const Text("No file available."),
              ],
            ),
          ),
          actions: <Widget>[
            // Close button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            if (attachedFile != null && attachedFile.isNotEmpty)
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(attachedFile))) {
                    await launchUrl(Uri.parse(attachedFile));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not launch the file URL.")),
                    );
                  }
                },
                child: const Text("Download"),
              ),
          ],
        );
      },
    );
  }
}
