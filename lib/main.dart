import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with URL and anon key
  await Supabase.initialize(
    url: 'https://bnwskkovjysujfnhlwkf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJud3Nra292anlzdWpmbmhsd2tmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3MTczMDUsImV4cCI6MjA0ODI5MzMwNX0.XIkKDTZFlcmBk7eSXoKd1FRRNU_oJK-nUw3n7TTaB44',
  );

  runApp(SkillUpApp());
}

class SkillUpApp extends StatelessWidget {
  const SkillUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flutter_dash, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false; // Switch to toggle between login and signup

  void _login() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Using Supabase to authenticate
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Check if the user is returned successfully
    if (response.user == null) {
      // Show error if login fails
      Fluttertoast.showToast(
        msg: "Login failed. Please check your credentials.",
        backgroundColor: Colors.red,
      );
    } else {
      // Navigate to landing page if login is successful
      Fluttertoast.showToast(
        msg: "Login successful!",
        backgroundColor: Colors.green,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    }
  }

  void _signUp() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Using Supabase to create a new user
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      Fluttertoast.showToast(
        msg: "Sign-up failed. Please try again.",
        backgroundColor: Colors.red,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Sign-up successful! Please log in.",
        backgroundColor: Colors.green,
      );
      setState(() {
        _isSignUp = false; // Switch to login screen after sign-up
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSignUp ? _signUp : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(_isSignUp ? 'Sign Up' : 'Login'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp; // Toggle between login and sign-up
                });
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Login'
                    : 'Don’t have an account? Sign Up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Guest'; // If no user, show 'Guest'

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'SKILLUP AI',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.notifications, color: Colors.grey),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _showProfileModal(context);
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/user.png'),
                radius: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Hi $email,\n',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'You have ',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: '4 Activities',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: ' pending',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '300 Points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Cross 500 within the week to move to next tier.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizCategoryPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(80, 36),
                      ),
                      child: Text('Take Quiz', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                '4 Pending Activities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildActivityCard('OOP', 'Notes'),
                  _buildActivityCard('SEC', 'Video'),
                  _buildActivityCard('DSA', 'Text'),
                  _buildActivityCard('ICT', 'Notes'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Popular Subjects',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSubjectChip('Mathematics', Colors.blue),
                  _buildSubjectChip('Chemistry', Colors.orange),
                  _buildSubjectChip('Physics', Colors.purple),
                  _buildSubjectChip('Computer', Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FAQPage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Search'),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            type,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(String title, Color color) {
    return Chip(
      label: Text(title),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  void _showProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/user.png'),
                radius: 50,
              ),
              SizedBox(height: 20),
              // Options for Sign Out and Exit
              ElevatedButton(
                onPressed: () async {
                  // Sign out the user
                  await Supabase.instance.client.auth.signOut();
                  Navigator.pop(context); // Close the modal
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AuthPage()), // Navigate to the login screen
                  );
                  Fluttertoast.showToast(
                    msg: "Successfully signed out!",
                    backgroundColor: Colors.green,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Sign Out'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop(); // Exit / close the modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Exit'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuizCategoryPage extends StatelessWidget {
  const QuizCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'id': 9, 'name': 'General Knowledge'},
      {'id': 18, 'name': 'Computer Science'},
      {'id': 23, 'name': 'History'},
      {'id': 19, 'name': 'Maths'},
      {'id': 22, 'name': 'Geography'},
      {'id': 21, 'name': 'Sports'},
      {'id': 24, 'name': 'Politics'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]['name']),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizPage(categoryId: categories[index]['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final int categoryId;

  const QuizPage({super.key, required this.categoryId});
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=5&category=${widget.categoryId}&difficulty=medium&type=multiple');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] == 0) {
          setState(() {
            _questions = (data['results'] as List).map((question) {
              List<String> options =
                  List<String>.from(question['incorrect_answers']);
              options.add(question['correct_answer']);
              options.shuffle();

              return {
                'question': question['question'],
                'options': options,
                'answer': question['correct_answer'],
              };
            }).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load questions: $e",
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextQuestion(String selectedOption) {
    if (_questions[_currentQuestionIndex]['answer'] == selectedOption) {
      _score++;
      Fluttertoast.showToast(
        msg: "Correct!",
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Wrong Answer!",
        backgroundColor: Colors.red,
      );
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Quiz Completed"),
        content: Text("Your score is $_score out of ${_questions.length}."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to the previous screen
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(child: Text("No questions available."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _questions[_currentQuestionIndex]['question'],
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ..._questions[_currentQuestionIndex]['options']
                          .map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _nextQuestion(option),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(option),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchController = TextEditingController();
  String _answer = '';
  bool _isLoading = false;

  // Function to fetch an answer from the API
  Future<void> _fetchAnswer(String question) async {
    if (question.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your question!',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _answer = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://api-inference.huggingface.co/models/google/flan-t5-base'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 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',
        },
        body: jsonEncode({
          'inputs': "Answer the question: $question",
          'parameters': {'max_length': 500, 'temperature': 0.7}
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _answer = data[0]['generated_text'];
        });
      } else {
        print('Error response: ${response.body}'); // For debugging
        setState(() {
          _answer =
              'Error: Failed to get response from AI (Status: ${response.statusCode})\nDetails: ${response.body}';
        });
      }
    } catch (e) {
      print('Exception: $e'); // For debugging
      setState(() {
        _answer = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Engine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Find answers to your questions.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Type your question here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      _fetchAnswer(_searchController.text.trim());
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_answer.isNotEmpty)
              Expanded(
                child: Card(
                  color: Colors.blue[50],
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answer:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _answer,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'No results yet, Type a question to find an answer!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
