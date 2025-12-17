import 'package:flutter/material.dart';

void main() {
  runApp(const ColorYourMindApp());
}

class ColorYourMindApp extends StatelessWidget {
  const ColorYourMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Your Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntroPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.pink.shade100,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? size.width * 0.15 : 24.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.deepPurple,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Color Your Mind',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isWeb ? 100 : 60),
                  
                  // Hero Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Main illustration
                          Container(
                            width: isWeb ? 400 : size.width * 0.7,
                            height: isWeb ? 400 : size.width * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.brush,
                                  size: isWeb ? 120 : 80,
                                  color: Colors.purple.shade300,
                                ),
                                Positioned(
                                  top: isWeb ? 80 : 50,
                                  right: isWeb ? 60 : 40,
                                  child: Icon(
                                    Icons.color_lens,
                                    size: isWeb ? 60 : 40,
                                    color: Colors.pink.shade300,
                                  ),
                                ),
                                Positioned(
                                  bottom: isWeb ? 80 : 50,
                                  left: isWeb ? 60 : 40,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: isWeb ? 50 : 35,
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Title
                          Text(
                            'Unleash Your Creativity',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isWeb ? 56 : 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade900,
                              height: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Subtitle
                          Text(
                            'Explore endless coloring possibilities with our\nbeautiful collection of digital coloring pages',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isWeb ? 20 : 16,
                              color: Colors.deepPurple.shade700,
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // CTA Button
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to main app
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 48 : 32,
                                vertical: isWeb ? 24 : 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.deepPurple.withOpacity(0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start Coloring',
                                  style: TextStyle(
                                    fontSize: isWeb ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isWeb ? 100 : 60),
                  
                  // Features Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Why Choose Color Your Mind?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWeb ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeatureCard(
                              icon: Icons.devices,
                              title: 'Cross-Platform',
                              description: 'Works on mobile, tablet, and web',
                              color: Colors.purple,
                            ),
                            _buildFeatureCard(
                              icon: Icons.collections,
                              title: 'Rich Library',
                              description: 'Hundreds of coloring pages',
                              color: Colors.pink,
                            ),
                            _buildFeatureCard(
                              icon: Icons.download,
                              title: 'Save & Share',
                              description: 'Download and share your artwork',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Available on Android, iOS, and Web',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.deepPurple.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
