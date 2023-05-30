import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = true;
  List<NewsArticle> newsArticles = [];
  String searchKeyword = '';
  List<NewsArticle> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    const apiKey = '5d53fbf398fe4361a267e25848e6d422';
    final url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          newsArticles = (responseData['articles'] as List)
              .map((article) => NewsArticle(
                    article['title'],
                    article['description'],
                    article['urlToImage'],
                    article['url'], // Website URL
                  ))
              .toList();
          _isLoading = false;
          filterNews();
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }

  void filterNews() {
    if (searchKeyword.isEmpty) {
      filteredArticles = newsArticles;
    } else {
      filteredArticles = newsArticles
          .where((article) =>
              article.title.toLowerCase().contains(searchKeyword.toLowerCase()) ||
              article.subtitle.toLowerCase().contains(searchKeyword.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-blue-grad.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50,),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Stay Updated',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextField(
                      expands: false,
                      decoration: InputDecoration(
                        hintText: 'Search News',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Handle search button click
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchKeyword = value;
                          filterNews();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: filteredArticles.length,
                          itemBuilder: (BuildContext context, int index) {
                            final article = filteredArticles[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: NewsImage(article.imageUrl), // Use NewsImage widget here
                                ),
                                ListTile(
                                  title: Text(
                                    article.title,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    article.subtitle,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    launch(article.websiteUrl);
                                  },
                                ),
                                Row( // Added Row widget for site image and title
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: NewsSiteImage(article.websiteUrl), // Use NewsSiteImage widget here
                                    ),
                                    Text(
                                      getSiteTitle(article.websiteUrl), // Function to extract site title from URL
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Divider(
                                  thickness: 1.0,
                                  color: Colors.grey[300],
                                  indent: 16.0,
                                  endIndent: 16.0,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String websiteUrl;

  NewsArticle(this.title, this.subtitle, this.imageUrl, this.websiteUrl);
}

class NewsImage extends StatelessWidget {
  final String imageUrl;

  NewsImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(imageUrl)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while the image is being loaded
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Show an error widget if there was an error loading the image
          return Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data?.statusCode == 200) {
          // Display the image if it was loaded successfully
          return Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover);
        } else {
          // Show a placeholder widget if the image is not available
          return Placeholder(fallbackHeight: 200);
        }
      },
    );
  }
}

class NewsSiteImage extends StatelessWidget {
  final String websiteUrl;

  NewsSiteImage(this.websiteUrl);

  @override
  Widget build(BuildContext context) {
    // Extract the site's hostname from the URL
    final Uri uri = Uri.parse(websiteUrl);
    final String hostname = uri.host;

    // Replace www. prefix if present
    final String site = hostname.startsWith('www.') ? hostname.substring(4) : hostname;

    // Generate a placeholder image URL based on the site's name
    final String placeholderImageUrl = 'https://www.google.com/s2/favicons?sz=64&domain=$hostname';

    return Image.network(
      placeholderImageUrl,
      width: 24,
      height: 24,
    );
  }
}

String getSiteTitle(String websiteUrl) {
  // Extract the site's hostname from the URL
  final Uri uri = Uri.parse(websiteUrl);
  final String hostname = uri.host;
  final int dotIndex = hostname.lastIndexOf(".");

  // Replace www. prefix if present
  final String site = hostname.startsWith('www.') ? hostname.substring(4,dotIndex) : hostname.substring(0,hostname.indexOf("."));

  return site;
}
