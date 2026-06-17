import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../services/firebase_service.dart';
import 'chat_screen.dart';

class StorySetupScreen extends StatefulWidget {
  const StorySetupScreen({super.key});

  @override
  State<StorySetupScreen> createState() => _StorySetupScreenState();
}

class _StorySetupScreenState extends State<StorySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _loreController = TextEditingController();
  final _styleController = TextEditingController();
  final _plotController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  void _startStory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newStory = StoryModel(
        id: '',
        title: _titleController.text.trim(),
        genre: _genreController.text.trim(),
        loreContext: _loreController.text.trim(),
        style: _styleController.text.trim(),
        currentPlotState: _plotController.text.trim(),
        history: [],
        lastUpdated: DateTime.now(),
      );

      await _firebaseService.saveStory(newStory);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(story: newStory)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: 'Story Title Input field',
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Story Title', hintText: 'e.g. The Lost City'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Genre Input field',
                child: TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(labelText: 'Genre', hintText: 'e.g. Sci-Fi, Fantasy'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Lore Context Input field',
                child: TextFormField(
                  controller: _loreController,
                  decoration: const InputDecoration(labelText: 'Lore Context (Characters/World Rules)'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Writing Style Input field',
                child: TextFormField(
                  controller: _styleController,
                  decoration: const InputDecoration(labelText: 'Style (e.g. 3rd Person, Dark Tone)'),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Initial Plot State Input field',
                child: TextFormField(
                  controller: _plotController,
                  decoration: const InputDecoration(labelText: 'Initial Plot State (Where are we starting?)'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 32),
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Semantics(
                    button: true,
                    label: 'Start Writing Story Button',
                    child: ElevatedButton(
                      onPressed: _startStory,
                      child: const Text('Start Writing'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
