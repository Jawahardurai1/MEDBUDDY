import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fullview.dart';
import "PostAdvertisementPageState.dart";

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _blogs = [];
  List<dynamic> _filteredBlogs = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
    _searchController.addListener(_filterBlogs);
  }

  Future<void> _fetchBlogs() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/data/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _blogs = json.decode(response.body);
          _filteredBlogs = _blogs;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load blogs");
      }
    } catch (e) {
      print("Error fetching blogs: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBlogs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBlogs = _blogs
          .where((blog) => blog['specialist'].toLowerCase().contains(query))
          .toList();
    });
  }
void _uploadData() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostAdvertisementPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by specialist...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _filteredBlogs.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullView(
                              name: _filteredBlogs[index]['name'],
                              specialist: _filteredBlogs[index]['specialist'],
                              description: _filteredBlogs[index]['description'],
                              image1: _filteredBlogs[index]['image1'] ?? '',
                              image2: _filteredBlogs[index]['image2'] ?? '',
                              image3: _filteredBlogs[index]['image3'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: BlogPost(
                        name: _filteredBlogs[index]['name'],
                        specialist: _filteredBlogs[index]['specialist'],
                        description: _filteredBlogs[index]['description'],
                        image1: _filteredBlogs[index]['image1'] ?? '',
                        image2: _filteredBlogs[index]['image2'] ?? '',
                        image3: _filteredBlogs[index]['image3'] ?? '',
                      ),
                    ),
                    Divider(color: Colors.grey),
                  ],
                );
              },
            ),
             floatingActionButton: FloatingActionButton(
        onPressed: _uploadData,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.upload, color: Colors.white),
      ),
   
    );
  }
}

class BlogPost extends StatelessWidget {
  final String name;
  final String specialist;
  final String description;
  final String image1;
  final String image2;
  final String image3;

  BlogPost({
    required this.name,
    required this.specialist,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              specialist,
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              description.split('\n').take(2).join('\n'),
              style: TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
