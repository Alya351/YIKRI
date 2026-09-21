import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';
import '../../core/config/api_config.dart';
import '../orientation/orientation_screen.dart';
import 'defi_screen.dart';

class SageScreen extends StatefulWidget {
  final String prenom;
  final String classe;

  const SageScreen({
    super.key,
    this.prenom = 'Aminata',
    this.classe = 'Terminale D',
  });

  @override
  State<SageScreen> createState() => _SageScreenState();
}

class _SageScreenState extends State<SageScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  int _credits = 20;
  bool _geminiDisponible = true;

  // Clé API Gemini — remplace par ta vraie clé
  static String get _geminiApiKey => ApiConfig.geminiApiKey;
  static String get _geminiUrl => ApiConfig.geminiUrl;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // Suggestions rapides
  final List<Map<String, String>> _suggestions = [
    {'label': 'Explique-moi le discriminant', 'icon': '📐'},
    {'label': 'Crée-moi un plan de révision', 'icon': '📅'},
    {'label': 'Donne-moi un défi Maths', 'icon': '🎯'},
    {'label': 'Comment améliorer ma moyenne ?', 'icon': '📈'},
    {'label': 'Explique la photosynthèse', 'icon': '🌱'},
    {'label': 'Méthode pour disserter', 'icon': '✍️'},
    {'label': 'Aide-moi à choisir mon orientation', 'icon': '🧭'},
  ];

  // Base de réponses simulées du Sage
  final Map<String, String> _reponses = {
    'discriminant': '''Le discriminant, c\'est la clé qui révèle le nombre de solutions d\'une équation du second degré.

On le calcule ainsi :

Δ = b² - 4ac

Trois cas :
• Δ > 0 → deux solutions distinctes
• Δ = 0 → une solution double
• Δ < 0 → aucune solution réelle

Exemple : pour x² - 5x + 6 = 0
a=1, b=-5, c=6 → Δ = 25 - 24 = 1

Δ > 0 donc deux solutions :
x₁ = (5+1)/2 = 3 et x₂ = (5-1)/2 = 2''',

    'plan': '''Voici ton plan de révision pour cette semaine, {PRENOM} :

LUNDI — Mathématiques (45 min)
Révise les équations du second degré. Fais 5 exercices.

MARDI — SVT (30 min)
La cellule et ses fonctions. Lis le cours, fais un schéma.

MERCREDI — Physique (45 min)
Lois de Newton. Exercices corrigés.

JEUDI — Français (30 min)
Techniques de dissertation. Entraîne-toi sur un sujet.

VENDREDI — Maths + SVT (1h)
Révision croisée avant le weekend.

SAMEDI — Révision libre (45 min)
Choisis la matière où tu te sens le moins à l'aise.

DIMANCHE — Repos mérité 🙏

Commence par le plus difficile en début de semaine — c\'est là que ton cerveau est le plus frais.''',

    'défi': '__DEFI__',

    'moyenne': '''Pour améliorer ta moyenne, {PRENOM}, voici ma méthode en 4 points :

1. IDENTIFIE tes matières faibles
Regarde tes notes — quelles matières tirent ta moyenne vers le bas ?

2. PRIORISE ces matières
Consacre 60% de ton temps de révision aux matières faibles, 40% aux points forts.

3. RÉGULARITÉ avant intensité
30 minutes par jour valent mieux que 4 heures le dimanche. Ton cerveau retient mieux en petites sessions régulières.

4. TESTE-TOI
Ne relis pas passivement — fais des exercices, des QCM, des défis. C\'est en faisant des erreurs qu\'on apprend vraiment.

Ta moyenne actuelle est 68%. Avec cette méthode, tu peux viser 75% d\'ici un mois.''',

    'photosynthèse': '''La photosynthèse, c\'est le processus par lequel les plantes fabriquent leur propre nourriture grâce à la lumière.

L\'équation simplifiée :

6CO₂ + 6H₂O + lumière → C₆H₁₂O₆ + 6O₂

En clair : la plante absorbe du dioxyde de carbone et de l\'eau, capte la lumière solaire, et produit du glucose (sa nourriture) et de l\'oxygène (qu\'on respire).

Où ça se passe ? Dans les chloroplastes, grâce à la chlorophylle — le pigment vert des feuilles.

Deux grandes étapes :
• Phase lumineuse → capture de l\'énergie solaire
• Cycle de Calvin → fabrication du glucose

Retiens : sans photosynthèse, pas d\'oxygène, pas de nourriture, pas de vie sur Terre.''',

    'dissertation': '''La dissertation en 5 étapes, {PRENOM} :

1. ANALYSE DU SUJET (10 min)
Souligne les mots-clés. Reformule la question. Délimite le sujet.

2. PROBLÉMATIQUE (5 min)
Formule une question centrale à laquelle ton devoir va répondre.

3. PLAN en 3 parties (15 min)
Thèse → Antithèse → Synthèse
Chaque partie = 2-3 arguments + exemples

4. RÉDACTION
• Introduction : accroche → présentation → problématique → annonce du plan
• Développement : transitions entre les parties
• Conclusion : bilan + ouverture

5. RELECTURE (10 min)
Orthographe, cohérence, longueur équilibrée.

Astuce : commence toujours par le brouillon du plan avant de rédiger. Ne commence jamais à écrire sans savoir où tu vas.''',

    'default': '',
  };

  @override
  void initState() {
    super.initState();
    final profile = AppService().profile;
    if (profile != null) _credits = profile.credits;
    AppService().addListener(_onCreditsUpdate);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Message d'accueil initial
    Future.delayed(const Duration(milliseconds: 400), () {
      _ajouterMessageSage(
        'Salam ' + widget.prenom + ' ! Je suis Le Sage, ton mentor sur yikri.\n\nPose-moi une question sur tes cours, demande un plan de revision, ou releve un defi. Je suis la pour t aide a progresser.',
      );
    });
  }


  Future<String> _appelGemini(String question) async {
    if (_geminiApiKey.isEmpty) return '';
    try {
      final uri = Uri.parse('$_geminiUrl?key=$_geminiApiKey');
      final systemPrompt = '''Tu es Le Sage, un mentor educatif bienveillant pour les eleves burkinabes de la ''' + widget.classe + '''.
Tu reponds en francais, de maniere claire, concise et pedagogique.
Tu es specialise dans le programme scolaire burkinabe.
Reponds en maximum 150 mots. Sois encourageant et positif.
Si la question est hors sujet scolaire, ramene doucement vers les etudes.''';

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': systemPrompt + '\n\nQuestion de l eleve : ' + question}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 300,
        }
      });

      final request = await _createHttpClient().postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(body);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      return text ?? '';
    } catch (e) {
      return '';
    }
  }

  HttpClient _createHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }

  void _onCreditsUpdate() {
    if (!mounted) return;
    final profile = AppService().profile;
    if (profile != null) setState(() => _credits = profile.credits);
  }

  @override
  void dispose() {
    AppService().removeListener(_onCreditsUpdate);
    _inputController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _ajouterMessageSage(String texte, {bool avecDefi = false, bool avecOrientation = false}) {
    setState(() {
      _messages.add({
        'role': 'sage',
        'texte': texte,
        'avecDefi': avecDefi,
        'avecOrientation': avecOrientation,
        'time': _heureActuelle(),
      });
    });
    _scrollToBottom();
  }

  void _ajouterMessageUser(String texte) {
    setState(() {
      _messages.add({
        'role': 'user',
        'texte': texte,
        'time': _heureActuelle(),
      });
      _isTyping = true;
    });
    _scrollToBottom();
  }

  String _heureActuelle() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _genererReponse(String message) {
    final msg = message.toLowerCase();
    String _r(String key) => (_reponses[key] ?? '').replaceAll('{PRENOM}', widget.prenom);

    if (msg.contains('discriminant') || msg.contains('second degré') || msg.contains('équation')) {
      return _r('discriminant');
    }
    if (msg.contains('plan') || msg.contains('révision') || msg.contains('semaine')) {
      return _r('plan');
    }
    if (msg.contains('moyenne') || msg.contains('améliorer') || msg.contains('progresser')) {
      return _r('moyenne');
    }
    if (msg.contains('photosynthèse') || msg.contains('svt') || msg.contains('cellule') || msg.contains('plante')) {
      return _r('photosynthèse');
    }
    if (msg.contains('dissert') || msg.contains('français') || msg.contains('rédac')) {
      return _r('dissertation');
    }
    if (msg.contains('orientation') || msg.contains('série') || msg.contains('filière') || msg.contains('université') || msg.contains('choisir')) {
      return '__ORIENTATION__';
    }
    if (msg.contains('défi') || msg.contains('exercice') || msg.contains('entraîn')) {
      return '__DEFI__';
    }
    if (msg.contains('bonjour') || msg.contains('salam') || msg.contains('salut') || msg.contains('bonsoir')) {
      return 'Salam ' + widget.prenom + " ! Comment puis-je t'aider ? Pose une question de cours, demande un plan de revision, ou releve un defi.";
    }
    if (msg.contains('merci')) {
      return 'Avec plaisir, ' + widget.prenom + ' ! Continue comme ca, chaque question posee est un pas vers la reussite.';
    }
    if (msg.contains('newton') || msg.contains('physique') || msg.contains('force')) {
      return 'Les lois de Newton en resume, ' + widget.prenom + ' :\n\n1ere loi - Inertie\nUn objet reste au repos ou en mouvement rectiligne uniforme sans force exterieure.\n\n2eme loi - F = m x a\nLa somme des forces = masse x acceleration.\n\n3eme loi - Action-reaction\nSi A exerce une force sur B, B exerce une force egale et opposee sur A.';
    }

    if (msg.contains('integrale') || msg.contains('integral') || msg.contains('primitive')) {
      return 'L integrale est l operation inverse de la derivee.\n\nSi F\'(x) = f(x), alors F est une primitive de f.\n\nExemple :\nf(x) = 2x → F(x) = x² + C\nf(x) = 3x² → F(x) = x³ + C\n\nIntegrale definie entre a et b :\n∫[a,b] f(x)dx = F(b) - F(a)';
    }
    if (msg.contains('probabilite') || msg.contains('proba') || msg.contains('evenement')) {
      return 'Les probabilites mesurent la chance qu un evenement se produise.\n\nFormule de base :\nP(A) = nombre de cas favorables / nombre de cas possibles\n\nProprietes :\n• 0 ≤ P(A) ≤ 1\n• P(certain) = 1\n• P(impossible) = 0\n• P(A) + P(non A) = 1\n\nExemple : lancer un de, P(6) = 1/6';
    }
    if (msg.contains('vecteur') || msg.contains('coordonn')) {
      return 'Un vecteur est defini par sa direction, son sens et sa norme.\n\nCoordonnees :\nSi A(x₁,y₁) et B(x₂,y₂)\nAB = (x₂-x₁ ; y₂-y₁)\n\nNorme : ||AB|| = √((x₂-x₁)² + (y₂-y₁)²)\n\nAddition : u + v = (u₁+v₁ ; u₂+v₂)';
    }
    if (msg.contains('adn') || msg.contains('gene') || msg.contains('chromosom') || msg.contains('heredit')) {
      return 'L ADN (Acide DeoxyriboNucleique) est le support de l information genetique.\n\nStructure : double helice composee de 4 bases :\n• Adenine (A) - Thymine (T)\n• Guanine (G) - Cytosine (C)\n\nGene : sequence d ADN codant une proteine\nChromosome : structure contenant l ADN\nL humain a 46 chromosomes (23 paires)\n\nHeredite : transmission des genes des parents aux enfants';
    }
    if (msg.contains('respiration') || msg.contains('respiratoire')) {
      return 'La respiration cellulaire est la degradation du glucose pour produire de l energie.\n\nEquation bilan :\nC₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O + energie (ATP)\n\nLieu : mitochondries\n\nEtapes :\n1. Glycolyse (cytoplasme)\n2. Cycle de Krebs (mitochondrie)\n3. Chaine respiratoire (mitochondrie)';
    }
    if (msg.contains('economie') || msg.contains('marche') || msg.contains('offre') || msg.contains('demande')) {
      return 'En economie, le marche est le lieu de rencontre entre l offre et la demande.\n\nOffre : quantite proposee par les producteurs\nDemande : quantite souhaitee par les consommateurs\n\nPrix d equilibre : point ou offre = demande\n\nSi prix trop haut → offre > demande → surplus\nSi prix trop bas → demande > offre → penurie';
    }
    if (msg.contains('sankara') || msg.contains('burkina') || msg.contains('revolution')) {
      return 'Thomas Sankara (1949-1987) est l une des figures les plus marquantes de l histoire africaine.\n\nPresident du Burkina Faso de 1983 a 1987.\nA renomme la Haute-Volta en Burkina Faso (Pays des hommes integres).\n\nActions majeures :\n• Lutte contre la corruption\n• Emancipation des femmes\n• Autosuffisance alimentaire\n• Reboisement massif\n• Refus de la dette exterieure';
    }
    if (msg.contains('philosophie') || msg.contains('liberte') || msg.contains('conscience')) {
      return 'La philosophie interroge les grandes questions de l existence.\n\nQuelques concepts cles :\n\nLiberte : capacite d agir selon sa propre volonte\nSartre : " L existence precede l essence "\n\nConscience : connaissance de soi et du monde\nDescartes : " Je pense donc je suis "\n\nDevoir : obligation morale\nKant : " Agis de facon que ta maxime soit une loi universelle "';
    }

    // Sujets sciences supplémentaires
    if (msg.contains('vent') || msg.contains('atmosphere') || msg.contains('meteo') || msg.contains('climat')) {
      return 'Le vent est le deplacement de masses d air cree par des differences de pression atmospherique. L air se deplace des zones de haute pression vers les zones de basse pression. Plus la difference de pression est grande, plus le vent est fort. C est un phenomene fondamental en meteorologie et en geographie physique.';
    }
    if (msg.contains('chimie') || msg.contains('reaction') || msg.contains('molecule') || msg.contains('atome')) {
      return 'En chimie, une reaction chimique transforme des reactifs en produits. Les atomes se reorganisent pour former de nouvelles molecules. La masse totale est conservee (loi de Lavoisier). Par exemple : 2H2 + O2 → 2H2O (formation de l eau).';
    }
    if (msg.contains('histoire') || msg.contains('colonisation') || msg.contains('independance') || msg.contains('afrique')) {
      return 'Le Burkina Faso, anciennement Haute-Volta, a obtenu son independance de la France le 5 aout 1960. Le pays a connu plusieurs periodes importantes : la revolution de Thomas Sankara (1983-1987), figure emblematique du panafricanisme, reste une reference majeure pour comprendre l histoire contemporaine du Burkina.';
    }
    if (msg.contains('geographie') || msg.contains('capitale') || msg.contains('fleuve') || msg.contains('pays')) {
      return 'La geographie du Burkina Faso : pays enclave d Afrique de l Ouest, capitale Ouagadougou. Principaux fleuves : Volta Noire, Volta Rouge, Volta Blanche. Pays voisins : Mali, Niger, Benin, Togo, Ghana, Cote d Ivoire. Superficie : 274 000 km2, population d environ 22 millions d habitants.';
    }

    // Réponse générique intelligente
    final reponses = [
      'Bonne question, ' + widget.prenom + ' ! Cette notion est au programme de ' + widget.classe + '. Commence par revoir les bases, puis fais des exercices progressifs. Tu veux que je t explique etape par etape ?',
      'Je comprends ta question. En ' + widget.classe + ", c'est un sujet important. Commence par bien lire le cours, fais un schema de synthese, puis teste-toi avec des exercices. Tu veux un defi sur ce theme ?",
      'Excellente initiative de me poser cette question ! La clé pour progresser, c\'est de ne jamais rester bloqué. Reformule ta question avec plus de détails si tu peux, et je t\'aiderai avec précision.',
    ];
    return reponses[Random().nextInt(reponses.length)];
  }

  void _envoyerMessage(String texte) async {
    if (texte.trim().isEmpty) return;
    _inputController.clear();
    _ajouterMessageUser(texte);

    // Vérifier commandes spéciales d'abord
    final reponseLocale = _genererReponse(texte);

    if (reponseLocale == '__ORIENTATION__') {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isTyping = false);
      _ajouterMessageSage(
        'Je vais t aide a trouver la meilleure orientation pour toi, ' + widget.prenom + ' ! Entre tes notes et j analyse les series, filieres et universites du Burkina.',
        avecOrientation: true,
      );
      return;
    }

    if (reponseLocale == '__DEFI__') {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isTyping = false);
      _ajouterMessageSage(
        'Parfait ! Tu veux te tester ? J ai prepare un defi specialement pour toi. Releve-le et gagne des credits !',
        avecDefi: true,
      );
      return;
    }

    // Essayer Gemini API si clé disponible
    if (_geminiDisponible && ApiConfig.geminiApiKey.isNotEmpty) {
      final geminiReponse = await _appelGemini(texte);
      if (!mounted) return;
      setState(() => _isTyping = false);
      if (geminiReponse.isNotEmpty) {
        _ajouterMessageSage(geminiReponse);
        return;
      }
      // Si Gemini échoue, désactiver temporairement
      setState(() => _geminiDisponible = false);
      Future.delayed(const Duration(minutes: 2), () {
        if (mounted) setState(() => _geminiDisponible = true);
      });
    }

    // Fallback : réponse locale
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(600)));
    if (!mounted) return;
    setState(() => _isTyping = false);
    _ajouterMessageSage(reponseLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final msg = _messages[index];
                        return msg['role'] == 'sage'
                            ? _buildSageMessage(msg)
                            : _buildUserMessage(msg);
                      },
                    ),
            ),
            if (_messages.length <= 1) _buildSuggestions(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text('🧙', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Le Sage',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greenMid,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Ton mentor · Toujours disponible',
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.goldMid.withOpacity(0.15),
              border: Border.all(color: AppColors.goldMid.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_credits crédits',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.goldMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('🧙', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Le Sage',
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ton mentor personnel yikri',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 13,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSageMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🧙', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LE SAGE',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldMid,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      msg['time'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 9,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    msg['texte'],
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.65,
                    ),
                  ),
                ),
                if (msg['avecOrientation'] == true) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a, b) => OrientationScreen(
                            prenom: widget.prenom,
                            classe: widget.classe,
                          ),
                          transitionsBuilder: (c, a, b, child) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.goldMid,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧭', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            'Découvrir mon orientation',
                            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (msg['avecDefi'] == true) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a, b) => const DefiScreen(),
                          transitionsBuilder: (c, a, b, child) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.greenMid,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            'Relever le défi · +5 crédits',
                            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg['time'],
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 9,
                  color: AppColors.text3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.greenMid,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Text(
                  msg['texte'],
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                widget.prenom[0].toUpperCase(),
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🧙', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return _TypingDot(delay: Duration(milliseconds: i * 200));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUGGESTIONS',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _suggestions.map((s) {
              return GestureDetector(
                onTap: () => _envoyerMessage(s['label']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s['icon']!,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        s['label']!,
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: 10,
        left: 12,
        right: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 13,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  hintText: 'Pose une question au Sage...',
                  hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 13,
                    color: AppColors.text3,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: _envoyerMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _envoyerMessage(_inputController.text),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.greenMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget point clignotant pour l'indicateur de frappe
class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.goldMid,
        ),
      ),
    );
  }
}