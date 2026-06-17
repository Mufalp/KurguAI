import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/story_model.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/firebase_service.dart';
import '../services/export_service.dart';

class ChatScreen extends StatefulWidget {
  final StoryModel story;

  const ChatScreen({super.key, required this.story});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GeminiService _geminiService;
  final FirebaseService _firebaseService = FirebaseService();
  final ExportService _exportService = ExportService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    "Add a sudden plot twist",
    "Describe the environment in detail",
    "Focus on character dialogue",
    "Introduce a new conflict",
    "Advance time to the next day"
  ];

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _geminiService = GeminiService(apiKey);
    
    // Initial generation if empty
    if (widget.story.history.isEmpty) {
      _generateResponse("Begin the first chapter based on the lore and plot state.");
    } else {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generateResponse(String instruction) async {
    if (instruction.isEmpty) return;

    setState(() {
      _isLoading = true;
      if (instruction != "Begin the first chapter based on the lore and plot state.") {
        widget.story.history.add(ChatMessage(role: MessageRole.user, text: instruction));
      }
    });
    _promptController.clear();
    _scrollToBottom();
    
    try {
      final responseMsg = await _geminiService.generateNextEpisode(widget.story, instruction);
      setState(() {
        widget.story.history.add(responseMsg);
        _isLoading = false;
      });
      await _firebaseService.saveStory(widget.story);
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _rerollLast() {
    if (widget.story.history.length >= 2) {
      setState(() {
        widget.story.history.removeLast(); // Remove AI response
        final lastInstruction = widget.story.history.removeLast(); // Remove user prompt
        _generateResponse(lastInstruction.text); // Try again
      });
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Export Story', style: Theme.of(context).textTheme.titleLarge),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Export as TXT'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _exportService.exportToTxt(widget.story);
                  if (path != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to: $path')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _exportService.exportToPdf(widget.story);
                  if (path != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to: $path')));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickPrompts() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Semantics(
              button: true,
              label: 'Quick action: $prompt',
              child: ActionChip(
                label: Text(prompt),
                onPressed: () {
                  _promptController.text = prompt;
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Story',
            onPressed: _showExportOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reroll Last Response',
            onPressed: _rerollLast,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.story.history.length,
              itemBuilder: (context, index) {
                final msg = widget.story.history[index];
                final isUser = msg.role == MessageRole.user;

                return Semantics(
                  label: isUser ? 'You instructed: ${msg.text}' : 'Story text: ${msg.text}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                    ),
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      msg.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildQuickPrompts(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Type your next instruction here',
                    child: TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        hintText: 'What happens next?',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: _generateResponse,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Semantics(
                  button: true,
                  label: 'Send instruction',
                  child: ElevatedButton(
                    onPressed: () => _generateResponse(_promptController.text),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(), 
                      padding: const EdgeInsets.all(16.0),
                      minimumSize: const Size(56, 56) // Ensure it is very tappable
                    ),
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
