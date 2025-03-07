import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vitbhopal/features/user_auth/presentation/pages/PostAdvertisementPageState.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/search.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/ai.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/profile.dart';
import 'fullview.dart';
import "PostAdvertisementPageState.dart";

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
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: _pages[_selectedIndex],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.android), label: "AI"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    ),
  );
}}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _blogs = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredBlogs = [];

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

  void _filterBlogs(String query) {
    setState(() {
      _filteredBlogs = _blogs.where((blog) {
        return blog['specialist'].toLowerCase().contains(query.toLowerCase());
      }).toList();
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
        title: Text("Home", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate(blogs: _blogs, onSearch: _filterBlogs));
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _filteredBlogs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullView(
                              title: _filteredBlogs[index]['title'],
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
                        title: _filteredBlogs[index]['title'],
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

class CustomSearchDelegate extends SearchDelegate {
  final List<dynamic> blogs;
  final Function(String) onSearch;

  CustomSearchDelegate({required this.blogs, required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query); // Clear search results when the query is cleared
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredBlogs = blogs.where((blog) {
      return blog['specialist'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredBlogs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredBlogs[index]['title']),
          subtitle: Text(filteredBlogs[index]['specialist']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullView(
                  title: filteredBlogs[index]['title'],
                  name: filteredBlogs[index]['name'],
                  specialist: filteredBlogs[index]['specialist'],
                  description: filteredBlogs[index]['description'],
                  image1: filteredBlogs[index]['image1'] ?? '',
                  image2: filteredBlogs[index]['image2'] ?? '',
                  image3: filteredBlogs[index]['image3'] ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = blogs.where((blog) {
      return blog['specialist'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['title']),
          subtitle: Text(suggestions[index]['specialist']),
          onTap: () {
            query = suggestions[index]['title'];
            onSearch(query); // Update the search results
            showResults(context);
          },
        );
      },
    );
  }
}

class BlogPost extends StatelessWidget {
  final String name;
  final String title;
  final String specialist;
  final String description;
  final String image1;
  final String image2;
  final String image3;

  BlogPost({
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
    return Card(
      color: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullView(
                      title: title,
                      name: name,
                      specialist: specialist,
                      description: description,
                      image1: image1,
                      image2: image2,
                      image3: image3,
                    ),
                  ),
                );
              },
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
              ),
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
