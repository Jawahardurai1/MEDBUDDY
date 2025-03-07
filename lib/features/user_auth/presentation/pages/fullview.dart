import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'PostAdvertisementPageState.dart';
import 'search.dart';
import 'ai.dart';
import 'profile.dart';
import 'fullview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    AIAssistPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: "AI"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/data/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _blogs = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _blogs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_blogs[index]['title']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullView(
                          title: _blogs[index]['title'],
                          name: _blogs[index]['name'],
                          specialist: _blogs[index]['specialist'],
                          description: _blogs[index]['description'],
                          image1: _blogs[index]['image1'] ?? '',
                          image2: _blogs[index]['image2'] ?? '',
                          image3: _blogs[index]['image3'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostAdvertisementPage()),
          );
        },
        child: Icon(Icons.upload),
      ),
    );
  }
}

class FullView extends StatelessWidget {
  final String name;
  final String title;
  final String specialist;
  final String description;
  final String image1;
  final String image2;
  final String image3;

  FullView({
    required this.name,
    required this.title,
    required this.specialist,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specialist,
                style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.05),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: 20),
              if (image1.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  child: Image.network(image1, fit: BoxFit.cover),
                ),
              if (image2.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  child: Image.network(image2, fit: BoxFit.cover),
                ),
              if (image3.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.3,
                  child: Image.network(image3, fit: BoxFit.cover),
                ),
            ],
          ),
        ),
      ),
    );
  }
}