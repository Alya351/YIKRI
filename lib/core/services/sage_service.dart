import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// ─── Modèle de message ────────────────────────────────────────────────────────

class SageMessage {
  final String role; // 'user' | 'model' (Gemini utilise 'model' au lieu de 'assistant')
  final String content;

  const SageMessage({required this.role, required this.content});

  // Format attendu par l'API Gemini
  Map<String, dynamic> toGeminiJson() => {
    'role': role,
    'parts': [{'text': content}],
  };
}

// ─── Résultat d'un appel ──────────────────────────────────────────────────────

class SageResponse {
  final String text;
  final bool isError;
  final bool isOffline;

  const SageResponse({
    required this.text,
    this.isError = false,
    this.isOffline = false,
  });
}

// ─── Service principal ────────────────────────────────────────────────────────

class SageService {
  static final SageService _instance = SageService._internal();
  factory SageService() => _instance;
  SageService._internal();

  // Gemini Flash — rapide, gratuit jusqu'à 1500 req/jour
static String get _endpoint =>
    '${ApiConfig.geminiUrl}?key=${ApiConfig.geminiApiKey}';

  final List<SageMessage> _history = [];

  // Prompt système : personnalité du Sage, cadré sur le contexte burkinabè
  String _buildSystemPrompt({
    required String prenom,
    required String classe,
    required List<String> coursAchetes,
  }) {
    final coursStr = coursAchetes.isEmpty
        ? 'aucun cours acheté pour le moment'
        : coursAchetes.join(', ');

    return '''Tu es Le Sage, le mentor IA de l'application éducative yikri, conçue pour les élèves du Burkina Faso.

PROFIL DE L'ÉLÈVE :
- Prénom : $prenom
- Classe : $classe
- Cours achetés : $coursStr

TON RÔLE :
- Tu es un mentor bienveillant, encourageant et pédagogue
- Tu réponds uniquement en français
- Tu adaptes tes explications au niveau $classe du système scolaire burkinabè (programmes MENA)
- Tu connais les matières du programme burkinabè : Maths, SVT, Physique-Chimie, Français, Anglais, Histoire-Géographie, Philosophie
- Tu utilises des exemples concrets liés à la vie au Burkina Faso quand c'est pertinent

RÈGLES IMPORTANTES :
- Pour les DÉFIS : ne donne jamais la réponse directement — guide l'élève progressivement par des indices jusqu'à ce qu'il trouve seul
- Pour les QCM : explique pourquoi la mauvaise réponse est fausse, puis donne immédiatement la bonne réponse
- Si une question est hors de ta portée (hors programme scolaire), dis-le clairement et poliment
- Garde tes réponses concises : 3 à 6 lignes maximum sauf si une explication détaillée est nécessaire
- Utilise des sauts de ligne pour aérer tes réponses
- Sois chaleureux et utilise le prénom $prenom de temps en temps

Tu es ici pour aider $prenom à réussir. Chaque question posée est un pas vers la réussite.''';
  }

  /// Envoie un message et retourne la réponse du Sage
  Future<SageResponse> envoyer({
    required String message,
    required String prenom,
    required String classe,
    List<String> coursAchetes = const [],
  }) async {
    _history.add(SageMessage(role: 'user', content: message));

    // Limite à 20 messages pour économiser le quota
    final histoireTronquee = _history.length > 20
        ? _history.sublist(_history.length - 20)
        : List<SageMessage>.from(_history);

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [{'text': _buildSystemPrompt(
              prenom: prenom,
              classe: classe,
              coursAchetes: coursAchetes,
            )}]
          },
          'contents': histoireTronquee.map((m) => m.toGeminiJson()).toList(),
          'generationConfig': {
            'maxOutputTokens': 512,
            'temperature': 0.7,
          },
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final texte = data['candidates'][0]['content']['parts'][0]['text'] as String;

        _history.add(SageMessage(role: 'model', content: texte));
        return SageResponse(text: texte.trim());

      } else if (response.statusCode == 429) {
        _history.removeLast();
        return const SageResponse(
          text: 'Je suis très sollicité en ce moment. Réessaie dans quelques secondes.',
          isError: true,
        );
      } else {
        _history.removeLast();
        return const SageResponse(
          text: 'Une erreur s\'est produite. Vérifie ta connexion et réessaie.',
          isError: true,
        );
      }
    } on Exception catch (e) {
      _history.removeLast();
      final isConnError = e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('HandshakeException');
      if (isConnError) {
        return const SageResponse(
          text: 'Pas de connexion internet. Le Sage est disponible uniquement en ligne.',
          isError: true,
          isOffline: true,
        );
      }
      return const SageResponse(
        text: 'Une erreur inattendue s\'est produite. Réessaie.',
        isError: true,
      );
    }
  }

  /// Vide l'historique (nouvelle conversation)
  void effacerHistorique() => _history.clear();

  int get nombreMessages => _history.length;
}