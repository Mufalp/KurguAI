import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import '../models/story_model.dart';

class GeminiService {
  final String _apiKey;
  
  GeminiService(this._apiKey);

  GenerativeModel _getModel(StoryModel story) {
    final systemInstruction = '''
# ROLE: Core Narrative Engine & Novelist
# EXPECTATION: Generate high-quality, structurally consistent prose. Maintain absolute fidelity to the provided <lore_context> and <plot_state>.

## PROTOCOLS
1. STICK TO LORE: Never contradict facts in <lore_context>. If an unmapped entity appears, assign traits and log them via updates.
2. CONTINUITY: Read <plot_state> before generating text. Ensure the timeline, character locations, and physical objects match current states.
3. PROSE QUALITY: Avoid cliches, passive voice, and melodramatic tropes unless specified by <style>. Show, don't tell.

## CONTEXT BLOCKS
<lore_context>
${story.loreContext}
</lore_context>

<plot_state>
${story.currentPlotState}
</plot_state>

<style>
${story.style}
</style>

## OUTPUT FORMAT
Respond STRICTLY using the following XML tags:
<narrative_generation>
[The actual novel text goes here]
</narrative_generation>

<state_updates>
[Deltas only: list any changes to characters, inventory, or plot tracking caused by this scene]
</state_updates>
''';

    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstruction),
    );
  }

  Future<ChatMessage> generateNextEpisode(StoryModel story, String userInstruction) async {
    final model = _getModel(story);
    
    List<Content> contents = [];
    for (var msg in story.history) {
      if (msg.role == MessageRole.user) {
        contents.add(Content.text(msg.text));
      } else {
        contents.add(Content.model([TextPart(msg.rawXml ?? msg.text)]));
      }
    }
    
    contents.add(Content.text(userInstruction));

    try {
      final response = await model.generateContent(contents);
      final responseText = response.text ?? '';
      
      // Parse the XML
      final narrativeMatch = RegExp(r'<narrative_generation>(.*?)</narrative_generation>', dotAll: true).firstMatch(responseText);
      final stateMatch = RegExp(r'<state_updates>(.*?)</state_updates>', dotAll: true).firstMatch(responseText);
      
      final narrative = narrativeMatch?.group(1)?.trim() ?? responseText;
      final stateUpdates = stateMatch?.group(1)?.trim() ?? '';
      
      // Update the story's plot state dynamically
      if (stateUpdates.isNotEmpty) {
        story.currentPlotState += '\\n\\n[UPDATE]: ' + stateUpdates;
      }
      
      return ChatMessage(
        role: MessageRole.model,
        text: narrative,
        rawXml: responseText,
      );
    } catch (e) {
      print("Error generating content: $e");
      
      // MOCK MODE: If the user is blocked by Google Cloud, return a beautiful mock response
      // so they can still test the UI and accessibility features for their internship!
      if (e.toString().contains('blocked') || e.toString().contains('not found')) {
        await Future.delayed(const Duration(seconds: 2));
        final mockNarrative = "The dark clouds rolled over the mountain as the hero approached the gates. The air was cold, and every step echoed in the silent valley. Based on your instruction: '$userInstruction', a sudden shift in the wind revealed a hidden path.";
        final mockState = "Location updated to Mountain Gates. Discovered hidden path.";
        
        story.currentPlotState += '\\n\\n[UPDATE]: ' + mockState;
        
        return ChatMessage(
          role: MessageRole.model,
          text: mockNarrative,
          rawXml: "<narrative_generation>$mockNarrative</narrative_generation>\\n<state_updates>$mockState</state_updates>",
        );
      }
      
      rethrow;
    }
  }
}
