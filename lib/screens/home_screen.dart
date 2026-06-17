import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/story_model.dart';
import 'story_setup_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _confirmDelete(BuildContext context, StoryModel story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Semantics(header: true, child: const Text('Delete Story?')),
        content: Text('Are you sure you want to delete "${story.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebaseService.deleteStory(story.id);
      if (mounted) {
        setState(() {}); // Force stream refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('My Stories Library'),
        ),
      ),
      body: StreamBuilder<List<StoryModel>>(
        stream: _firebaseService.getUserStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading stories.'));
          }

          final stories = snapshot.data ?? [];

          if (stories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your library is empty. Tap the New Story button to start writing!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return Semantics(
                button: true,
                label: 'Open story titled \${story.title}',
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(story.title.isEmpty ? 'Untitled Story' : story.title, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text('Genre: ${story.genre}', style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Semantics(
                      button: true,
                      label: 'Delete ${story.title}',
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, story),
                        tooltip: 'Delete Story',
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(story: story)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Create new story',
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StorySetupScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Story'),
        ),
      ),
    );
  }
}
