import 'package:flutter/material.dart';
import 'package:student/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:student/components/app_colour.dart';
import 'package:student/components/bottom_navigation.dart';
import 'package:student/components/background_style_two.dart';
import 'package:student/Student/appoinment/appoinment_screen.dart';
import 'package:student/Student/crisis_support.dart';
import 'package:student/Student/self_help_tools.dart';
import 'package:student/Student/unimasresources.dart';
import 'dart:math';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 2;
  String nearestDate = "";
  String nearestTime = "";
  String nearestLocation = "";
  String nearestCounselor = "";
  String selectedMood = "";
  String username = ""; // Default empty string
  String? profilePicUrl = "";
  final AuthService _auth = AuthService(); // Initialize AuthService

  // List of motivational quotes
  final List<String> positiveQuotes = [
    // Academic Success
    "Every study session brings you closer to your dreams. Keep going! 📚✨",
    "You don't have to be perfect to be amazing. Progress over perfection! 💫",
    "Small steps every day lead to big achievements. You've got this! 🎓",
    "Today's effort is tomorrow's success. Make it count! 💪",
    "Your potential is limitless. Embrace the challenge! 🌟",

    // Mental Wellness & Balance
    "Take breaks, stay focused, achieve more. You're doing great! 🌈",
    "It's okay to go at your own pace. You're exactly where you need to be! 😊",
    "Balance is key - make time for study, friends, and self-care. 🎯",
    "Stress is temporary, but your determination is permanent. Keep going! ⭐",
    "Your mental health matters. Take care of yourself today! 🌸",

    // Motivation & Persistence
    "Each assignment completed is a step toward your goals. Keep climbing! 📝",
    "You've overcome challenges before, and you'll do it again! 💫",
    "Your future self will thank you for not giving up today. 🌅",
    "Every expert was once a beginner. Keep learning, keep growing! 🌱",
    "Your dedication today shapes your success tomorrow! ⚡",

    // Self-Confidence
    "You are more capable than you know. Trust yourself! 💫",
    "Your unique perspective matters. Share your voice! 🗣️",
    "Confidence grows with every challenge you face. You're getting stronger! 💪",
    "You belong here. Your dreams are valid! ✨",
    "Your journey is your own. Be proud of your progress! 🌟",

    // Resilience
    "Mistakes are proof that you're trying. Keep going! 🚀",
    "Every setback is a setup for a comeback. Rise up! 🌅",
    "Your resilience is your superpower. Use it! ⚡",
    "Tough times don't last, but tough students do! 💪",
    "You've made it through 100% of your worst days. You're unstoppable! 🌈",

    // Growth & Learning
    "Each class is an opportunity to become better than yesterday! 📚",
    "Your effort today is an investment in your future. Keep investing! 💎",
    "Learning is a journey, not a race. Enjoy the process! 🌱",
    "Your potential grows with every challenge you accept! 🎯",
    "Today's curiosity leads to tomorrow's expertise! ✨",

    // Community & Support
    "You're not alone in this journey. Reach out when you need support! 🤝",
    "Your university community believes in you! 🎓",
    "Together we rise. Connect, collaborate, succeed! 🌟",
    "Every great achievement starts with the decision to try! 💫",
    "You're part of something bigger. Make your mark! ⭐"
  ];

  // Method to get a random quote
  String getRandomQuote() {
    final random = Random();
    return positiveQuotes[random.nextInt(positiveQuotes.length)];
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // Fetch all data together
  }

  Future<void> _initializeData() async {
    // Temporary variables to hold state data
    String tempUsername = "User";
    String tempNearestDate = "No appointment scheduled";
    String tempNearestTime = "-";
    String tempNearestLocation = "-";
    String tempNearestCounselor = "-";

    try {
      // Fetch user data
      final userData = await _auth.getCurrentUserData();
      if (userData != null) {
        tempUsername = userData['username'] ?? "User";
      }

      // Fetch the nearest appointment
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DateTime now = DateTime.now();

        final querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .orderBy('appointmentDate')
            .orderBy('time')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            final data = doc.data();
            final dateStr = data['appointmentDate'] as String?;
            final timeStr = data['time'] as String?;

            if (dateStr != null && timeStr != null) {
              final appointmentDateTime =
                  DateFormat("yyyy-MM-dd hh:mm a").parse("$dateStr $timeStr");
              print("Parsing: $dateStr $timeStr");

              if (appointmentDateTime.isAfter(now)) {
                tempNearestDate =
                    data['appointmentDate'] ?? 'Date not specified';
                tempNearestTime = data['time'] ?? 'Time not specified';
                tempNearestLocation =
                    data['location'] ?? 'Location not specified';
                tempNearestCounselor =
                    data['counsellor'] ?? 'Counsellor not specified';
                break;
              }
            }
          }
        } else {
          tempNearestDate = "No upcoming appointments";
        }
      } else {
        tempNearestDate = "Please login to view appointments";
      }
    } catch (e) {
      print("Error initializing data: $e");
      tempNearestDate = "Error fetching data";
    }

    // Update the state once with all accumulated data
    setState(() {
      username = tempUsername;
      nearestDate = tempNearestDate;
      nearestTime = tempNearestTime;
      nearestLocation = tempNearestLocation;
      nearestCounselor = tempNearestCounselor;
    });
  }

  Future<void> checkMoodStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Retrieve the last logged date and mood status
      String? lastLoggedDate = prefs.getString('lastLoggedDate_$userId');
      DateTime today = DateTime.now();
      String todayString = "${today.year}-${today.month}-${today.day}";

      // Check if the last logged date matches today's date
      bool hasLoggedMood = (lastLoggedDate == todayString);
      print("User ID: $userId");
      print("Last Logged Date: $lastLoggedDate");
      print("Has logged mood today: $hasLoggedMood");

      if (hasLoggedMood) {
        // Navigate to the mood done page (only once)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/mooddonecheckin');
        });
      } else {
        // Navigate to the mood tracker page if not logged
        Navigator.pushReplacementNamed(context, '/moodtracker');
      }
    }
  }

  void navigateTo(String page) {
    print("Navigating to $page");
    // Handle other navigation cases
    if (page == 'Resource') {
      Navigator.pushNamed(context, '/resource');
    } else if (page == 'Dashboard') {
      Navigator.pushNamed(context, '/studentdashboard');
    } else if (page == 'Chat') {
      Navigator.pushNamed(context, '/chat');
    } else if (page == 'Profile') {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('d MMM yyyy, EEEE').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              navigateTo('Resource');
              break;
            case 1:
              checkMoodStatus();
              break;
            case 2:
              navigateTo('Dashboard');
              break;
            case 3:
              navigateTo('Chat');
              break;
            case 4:
              navigateTo('Profile');
              break;
          }
        },
      ),
      body: Stack(
        children: [
          const BackgroundStyleTwo(),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 40, bottom: 50),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile and Greeting Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor:
                                const Color(0XFFD9D9D9).withOpacity(.7),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: profilePicUrl != null &&
                                      profilePicUrl!.isNotEmpty
                                  ? NetworkImage(profilePicUrl!)
                                      as ImageProvider
                                  : const AssetImage(
                                          'assets/images/profilepic.png')
                                      as ImageProvider, // Default image if no profile pic
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back, $username",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Appointment Section
                  Center(
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0XFFD9D9D9).withOpacity(.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // This makes the column take minimum required space
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "Upcoming Appointment",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Date Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.pri_purple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Date: ",
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: nearestDate,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Time Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Time: ",
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: nearestTime,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Location Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Location: ",
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: nearestLocation,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Counselor Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Counsellor: ",
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: nearestCounselor,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.85, // Responsive width
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            const Color(0xFFF5F3FF), // Light purple background
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF613EEA).withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            size: 32,
                            color: Color(0xFF613EEA),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getRandomQuote(),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF2D3748),
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF613EEA).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Four card buttons displayed in a 2x2 grid
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final cardColors = [
                        AppColors.sec_purple,
                        AppColors.pri_greenYellow,
                        AppColors.sec_cyan,
                        AppColors.pri_cyan,
                      ];
                      return CardButton(
                        title: _getCardTitle(index),
                        color: cardColors[index % cardColors.length],
                        onTap: () => _navigateToSection(index),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: const Text("You have no new notifications."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Method to navigate to respective sections (self-help, crisis support, etc.)
  void _navigateToSection(int index) {
    // Map index to respective screen
    final screens = [
      const SelfHelpTools(), // Screen for Self-Help Tools
      const CrisisSupportPage(), // Screen for Crisis Support
      const CounsellorInfoScreen(), // Screen for UNIMAS Support
      const AppointmentScreen(), // Screen for Counselling Appointment
    ];

    // Navigate to the respective screen based on the index
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screens[index]),
    );
  }

  // Get card titles based on the index
  String _getCardTitle(int index) {
    switch (index) {
      case 0:
        return "Self-Help Tools";
      case 1:
        return "Crisis Support";
      case 2:
        return "UNIMAS Support";
      case 3:
        return "Counselling Appointment";
      default:
        return "Unknown Section";
    }
  }
}

// Card button widget
class CardButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;

  const CardButton(
      {super.key,
      required this.title,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/* Version 2.0.0 - Major UI Update*/
