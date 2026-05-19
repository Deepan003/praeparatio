import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/question_model.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

class AiService {
  static AiService? _instance;
  static AiService get instance => _instance ??= AiService._();
  AiService._();

  static const String _prefKey      = 'gemini_api_key';
  static const String _modelPrefKey = 'gemini_model_name';

  String? _apiKey;
  String  _modelName = AppConstants.geminiModel; // default, overridden by admin

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  String? get currentKey   => _apiKey;
  String  get currentModel => _modelName;

  void setModelName(String model) {
    if (model.trim().isNotEmpty) _modelName = model.trim();
  }

  /// Call once at login to restore key + model from SharedPreferences.
  Future<void> loadSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey   = prefs.getString(_prefKey);
    final savedModel = prefs.getString(_modelPrefKey);
    if (savedKey   != null && savedKey.isNotEmpty)   _apiKey    = savedKey;
    if (savedModel != null && savedModel.isNotEmpty) _modelName = savedModel;
  }

  /// Load the exam AI key from Supabase DB (called from admin settings screen).
  Future<void> loadKeyFromDb() async {
    try {
      final raw = await SupabaseService.instance.getSetting('exam_ai_api_key');
      if (raw == null) return;
      final key = raw.toString().trim();
      if (key.isNotEmpty) {
        _apiKey = key;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, key);
      }
    } catch (_) {}
  }

  /// Set key in memory only (not persisted).
  void setApiKey(String key) => _apiKey = key.trim();

  /// Persist key + model to SharedPreferences (DB saving handled by admin settings screen).
  Future<void> saveApiKey(String key, {String? model}) async {
    _apiKey = key.trim();
    if (model != null && model.trim().isNotEmpty) _modelName = model.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _apiKey!);
    await prefs.setString(_modelPrefKey, _modelName);
  }

  /// Remove the stored key from both memory and device storage.
  Future<void> clearSavedKey() async {
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Returns the first 8 characters of the saved key for display (masked).
  String get maskedKey {
    if (!hasApiKey) return '';
    final k = _apiKey!;
    if (k.length <= 8) return k;
    return '${k.substring(0, 8)}${'•' * (k.length - 8)}';
  }

  // Single-call strategy: one request per generation to prevent question repetition.
  // Token budget: ~300 tokens/question × 100 questions = ~30 000 tokens.
  // Gemini 2.5 Flash output cap = 65 536 tokens — fits 100 questions comfortably.
  static const int _maxQuestionsPerCall = 100;

  /// Generates [count] questions in a single API call.
  /// If the model returns fewer (truncation), makes ONE supplementary call
  /// for the missing questions only — preventing cross-call repetition.
  Future<List<QuestionModel>> generateExamQuestions({
    required List<String> chapters,
    required String difficulty,
    required int count,
    String? prompt,
    int? selectedClass,
  }) async {
    if (!hasApiKey) {
      throw Exception(
          'Gemini API key not configured.\nGo to Admin → AI Config to set your Gemini key.');
    }

    // ── Primary call — try to get all questions at once ──────────────────
    final primary = await _generateBatch(
      chapters: chapters,
      difficulty: difficulty,
      count: count,
      prompt: prompt,
      selectedClass: selectedClass,
    );

    if (primary.length >= count) {
      return primary.take(count).toList(); // got everything
    }

    // ── Supplementary call — only for the missing questions ──────────────
    // (at most one extra call; keeps repetition risk minimal)
    if (primary.isNotEmpty && primary.length < count) {
      final needed = count - primary.length;
      try {
        final extra = await _generateBatch(
          chapters: chapters,
          difficulty: difficulty,
          count: needed,
          prompt: prompt,
          selectedClass: selectedClass,
          batchNum: 2,
          totalBatches: 2,
        );
        return [...primary, ...extra].take(count).toList();
      } catch (_) {
        // Supplement failed — return what the primary call gave us
        return primary;
      }
    }

    throw Exception(
        'AI returned no questions. Check your API key and model in AI Config, then retry.');
  }

  Future<List<QuestionModel>> _generateBatch({
    required List<String> chapters,
    required String difficulty,
    required int count,
    String? prompt,
    int? selectedClass,
    int batchNum = 1,
    int totalBatches = 1,
  }) async {
    final chapterList = chapters.join(', ');
    final classInfo =
        selectedClass != null ? 'Class $selectedClass' : 'Class 11 and 12';
    final promptExtra =
        (prompt != null && prompt.isNotEmpty) ? '\nAdditional instructions: $prompt' : '';
    final batchNote = totalBatches > 1
        ? '\nThis is batch $batchNum of $totalBatches — make sure questions are unique and different from other batches.'
        : '';

    final userPrompt = '''You are an expert NEET Biology question creator.
Create exactly $count multiple-choice questions from NCERT Biology ($classInfo)
for the following chapters: $chapterList.
Difficulty: $difficulty$promptExtra$batchNote

Return ONLY a valid JSON array (no markdown, no explanation, no trailing text) with this exact structure:
[
  {
    "text": "Question text here?",
    "optionA": "Option A text",
    "optionB": "Option B text",
    "optionC": "Option C text",
    "optionD": "Option D text",
    "correctOption": "A",
    "explanation": "Brief NCERT-based explanation",
    "chapter": "Chapter name from the list provided"
  }
]

Rules:
- Strictly NCERT-based content only
- NEET Level: use statement-based, assertion-reason, and matching-type questions
- All four options must be plausible — avoid obviously wrong distractors
- No duplicate questions
- correctOption must be exactly "A", "B", "C", or "D"
- Return raw JSON array only — no code blocks, no prose, nothing before [ or after ]''';

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [{'text': userPrompt}]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          // 65 536 is Gemini 2.5 Flash's maximum output tokens.
          // 100 questions × ~300 tokens = ~30 000 — fits with plenty of headroom.
          // responseMimeType omitted: strict JSON mode causes silent failures
          // on retries; our parser already handles markdown fences correctly.
          'maxOutputTokens': 65536,
        },
      }),
    ).timeout(const Duration(seconds: 300));

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      final msg = err['error']?['message'] ?? 'HTTP ${response.statusCode}';
      throw Exception('Gemini API error: $msg');
    }

    final data = jsonDecode(response.body);

    // MAX_TOKENS = response was cut off mid-JSON. Try to salvage completed objects.
    final finishReason = data['candidates']?[0]?['finishReason'] as String?;
    final rawText =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? '';

    if (rawText.isEmpty) {
      throw Exception('Gemini returned an empty response. Retry or check your API key.');
    }

    // If truncated, _parseQuestions salvages all complete objects from the partial JSON
    return _parseQuestions(rawText, chapters, difficulty, truncated: finishReason == 'MAX_TOKENS');
  }

  List<QuestionModel> _parseQuestions(
      String rawText, List<String> chapters, String difficulty,
      {bool truncated = false}) {
    // Strip markdown code fences if present
    var cleaned = rawText
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    // Try to find a complete JSON array first
    String jsonStr;
    final fullMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
    if (fullMatch != null) {
      jsonStr = fullMatch.group(0)!;
    } else if (cleaned.startsWith('[')) {
      // Truncated — find the last fully completed JSON object "}," or "}"
      // and close the array to salvage completed questions
      final lastComplete = cleaned.lastIndexOf('},');
      if (lastComplete > 0) {
        jsonStr = '${cleaned.substring(0, lastComplete + 1)}]';
      } else {
        // Try closing on last `}` (last object, possibly complete)
        final lastBrace = cleaned.lastIndexOf('}');
        if (lastBrace > 0) {
          jsonStr = '${cleaned.substring(0, lastBrace + 1)}]';
        } else {
          throw Exception(
              'Gemini did not return recognisable JSON. Please retry.');
        }
      }
    } else {
      throw Exception(
          'Gemini response was not in JSON format. Please retry.');
    }

    late List<dynamic> questionsJson;
    try {
      questionsJson = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      // JSON still malformed — try stripping trailing incomplete object
      try {
        final fallback = cleaned.substring(0, (cleaned.lastIndexOf('},') + 1).clamp(0, cleaned.length));
        questionsJson = jsonDecode('$fallback]') as List<dynamic>;
      } catch (e2) {
        throw Exception('Gemini returned malformed JSON. Please retry. Detail: $e2');
      }
    }

    if (questionsJson.isEmpty) {
      throw Exception('Gemini returned an empty question list. Please retry.');
    }

    const uuid = Uuid();
    // Filter out any incomplete/malformed question objects silently
    final results = <QuestionModel>[];
    for (final q in questionsJson) {
      try {
        final map = q as Map<String, dynamic>;
        final text = (map['text'] ?? '').toString().trim();
        final correct = (map['correctOption'] ?? 'A').toString().toUpperCase().trim();
        if (text.isEmpty || !['A', 'B', 'C', 'D'].contains(correct)) continue;
        results.add(QuestionModel(
          id: uuid.v4(),
          text: text,
          optionA: (map['optionA'] ?? '').toString(),
          optionB: (map['optionB'] ?? '').toString(),
          optionC: (map['optionC'] ?? '').toString(),
          optionD: (map['optionD'] ?? '').toString(),
          correctOption: correct,
          explanation: map['explanation']?.toString(),
          chapter: (map['chapter'] ?? chapters.first).toString(),
          difficulty: difficulty,
        ));
      } catch (_) {
        continue; // skip malformed individual objects
      }
    }
    return results;
  }

  // Mental health chatbot - fully local, no API needed
  String getMentalHealthResponse(String message) {
    final lower = message.toLowerCase();

    if (_containsAny(lower, ['stressed', 'stress', 'pressure', 'overwhelmed'])) {
      return _randomFrom([
        "It's completely normal to feel stressed during exam preparation. Take a 5-minute break — close your eyes, breathe slowly, and let your mind rest. You're working hard and that already shows your dedication. 💙",
        "Stress is your body's way of saying you care about this. Try the 4-7-8 breathing technique: inhale for 4 counts, hold for 7, exhale for 8. It genuinely helps calm your nervous system. You've got this!",
      ]);
    }
    if (_containsAny(lower, ['anxious', 'anxiety', 'nervous', 'scared', 'fear', 'worried'])) {
      return _randomFrom([
        "Exam anxiety is incredibly common, even among top students. Remember: you've prepared for this. Focus on what you *do* know, not what you don't. One question at a time, one chapter at a time. 🌟",
        "When anxiety hits, anchor yourself in the present. Name 5 things you can see right now. It brings your mind back from the 'what ifs'. You are more prepared than you feel. Trust your preparation.",
      ]);
    }
    if (_containsAny(lower, ['tired', 'exhausted', 'sleep', 'fatigue', 'burnout'])) {
      return _randomFrom([
        "Your brain consolidates memory during sleep — rest is not laziness, it's study strategy. A well-rested mind retains 40% more than an exhausted one. Please give yourself permission to sleep. 😴",
        "Burnout is real and it's telling you something important: you need restoration. Even 20 minutes of walking outside can reset your mental state significantly. Please be kind to yourself today.",
      ]);
    }
    if (_containsAny(lower, ['fail', 'failed', 'bad result', 'poor marks', 'disappointed'])) {
      return _randomFrom([
        "One bad result does not define you or your future. Every NEET topper has had disappointing test days. What matters is what you do next — analyse where you went wrong, adjust, and move forward. 💪",
        "Disappointment means you have high standards, and that's a strength. Give yourself today to feel it, then tomorrow, open your books again. Progress is rarely linear. You're still on the path. 🌈",
      ]);
    }
    if (_containsAny(lower, ['motivat', 'give up', 'quit', "can't do it", 'hopeless'])) {
      return _randomFrom([
        "The fact that you're here, still studying, still trying — that's not a small thing. Most people never even try. NEET is hard, yes. But you are harder. Don't quit on a bad day. 🔥",
        "Remember *why* you started. The version of you who chose this path knew something. On the hard days, trust that earlier version of yourself. Your dream is worth the fight.",
      ]);
    }
    if (_containsAny(lower, ['focus', 'concentrate', 'distract'])) {
      return _randomFrom([
        "Try the Pomodoro method: 25 minutes of deep focus, 5 minutes of complete rest. Your brain is not built for marathon sessions — it thrives on intentional sprints. Give it a try today! ⏱️",
        "Distractions are normal. Create a physical study environment that signals 'study mode' — same spot, same time. Your brain will start associating that place with focus over time.",
      ]);
    }
    if (_containsAny(lower, ['lonely', 'alone', 'friend', 'miss', 'social'])) {
      return "Preparing for NEET can feel isolating, and that's a real challenge. Remember your batchmates are on the same journey — even a short conversation can help. You're not alone in this. 💙";
    }
    if (_containsAny(lower, ['happy', 'good', 'great', 'excited', 'amazing', 'wonderful'])) {
      return "That's wonderful to hear! 🌟 Positive energy is fuel for learning. Ride this wave — tackle your hardest topic while you're feeling this way. Keep shining!";
    }

    // Default
    return _randomFrom([
      "I'm here to listen. Preparing for NEET is a journey, not just a destination. Whatever you're going through, it's valid. What's on your mind? 💙",
      "Thank you for sharing with me. Remember that every student faces challenges on this path — your feelings are valid and you're not alone. How can I support you today?",
      "This journey takes incredible courage and persistence. I believe in your ability to get through whatever you're facing right now. Tell me more about how you're feeling.",
    ]);
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _randomFrom(List<String> options) {
    final index = DateTime.now().millisecondsSinceEpoch % options.length;
    return options[index];
  }

  // ── Universal Biology Doubt Solver (OpenAI-compatible — works with Groq, OpenAI, etc.) ──

  static const String _chatbotSystemPrompt = '''
You are a friendly and knowledgeable NEET Biology study assistant for Indian students preparing for NEET, studying Class 11 and 12 NCERT Biology.

Your role:
- Answer biology doubts clearly and accurately based on NCERT Class 11 and 12 syllabus
- Use simple, easy-to-understand language with relatable examples
- Highlight NEET exam-important points and commonly tested concepts
- Structure answers with bullet points for processes, numbered steps for sequences
- Keep answers thorough but focused — no unnecessary padding

IMPORTANT RULES:
- Each question is completely independent. You have NO memory of previous conversations.
- If asked about topics outside NEET Biology (Class 11 and 12), politely redirect back to biology.
- Always be encouraging and supportive in tone.

MENTAL HEALTH HANDLING — very important:
If a student expresses stress, anxiety, feeling overwhelmed, burnout, sadness, or any mental health concern:
1. Respond with genuine warmth and empathy FIRST — acknowledge their feelings completely
2. Tell them their feelings are valid and NEET preparation is genuinely hard
3. Suggest taking short breaks, sleeping well, and talking to someone they trust (parent, friend, teacher)
4. Do NOT give medical advice or diagnose anything
5. After the supportive message, gently offer to help with their biology studies when they are ready
''';

  /// Ask a biology doubt question using a universal OpenAI-compatible API.
  /// Reads api key, model, and endpoint from Supabase app_settings.
  Future<String> askChatbotQuestion(String question) async {
    String? apiKey, model, endpoint;
    try {
      apiKey   = (await SupabaseService.instance.getSetting('chatbot_api_key'))   as String?;
      model    = (await SupabaseService.instance.getSetting('chatbot_model'))     as String?;
      endpoint = (await SupabaseService.instance.getSetting('chatbot_endpoint'))  as String?;
    } catch (_) {}

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Chatbot is not configured yet. Please ask your admin to set up the API key.');
    }

    final url = (endpoint != null && endpoint.isNotEmpty)
        ? endpoint
        : 'https://api.groq.com/openai/v1/chat/completions';
    final mdl = (model != null && model.isNotEmpty) ? model : 'llama-3.3-70b-versatile';

    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': mdl,
        'messages': [
          {'role': 'system', 'content': _chatbotSystemPrompt},
          {'role': 'user',   'content': question},
        ],
        'max_tokens': 900,
        'temperature': 0.6,
      }),
    ).timeout(const Duration(seconds: 35));

    if (resp.statusCode != 200) {
      final body = resp.body;
      String msg = 'Service unavailable (${resp.statusCode}). Try again shortly.';
      try {
        final err = jsonDecode(body);
        msg = err['error']?['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }

    final data = jsonDecode(resp.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
