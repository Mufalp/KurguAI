import 'chat_message.dart';

class StoryModel {
  String id;
  String title;
  String genre;
  String loreContext;
  String style;
  String currentPlotState;
  List<ChatMessage> history;
  DateTime lastUpdated;

  StoryModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.loreContext,
    required this.style,
    required this.currentPlotState,
    required this.history,
    required this.lastUpdated,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json, String documentId) {
    return StoryModel(
      id: documentId,
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      loreContext: json['loreContext'] ?? '',
      style: json['style'] ?? '',
      currentPlotState: json['currentPlotState'] ?? '',
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'loreContext': loreContext,
      'style': style,
      'currentPlotState': currentPlotState,
      'history': history.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
