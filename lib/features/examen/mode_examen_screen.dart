import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';

class ModeExamenScreen extends StatefulWidget {
  const ModeExamenScreen({super.key});

  @override
  State<ModeExamenScreen> createState() => _ModeExamenScreenState();
}

class _ModeExamenScreenState extends State<ModeExamenScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  bool _actif = false;
  DateTime? _dateFin;
  final List<String> _matieresSelectees = [];
  bool _enregistrement = false;

  final List<Map<String, String>> _matieres = [
    {'nom': 'Mathématiques', 'emoji': '📐'},
    {'nom': 'SVT', 'emoji': '🌿'},
    {'nom': 'Physique-Chimie', 'emoji': '⚗️'},
    {'nom': 'Français', 'emoji': '✍️'},
    {'nom': 'Histoire-Géo', 'emoji': '🗺️'},
    {'nom': 'Philosophie', 'emoji': '💭'},
    {'nom': 'Anglais', 'emoji': '🌍'},
  ];

  final List<Map<String, dynamic>> _periodesOfficielles = [
    {'label': 'Compositions 1er trimestre', 'emoji': '📝', 'duree': 7},
    {'label': 'Compositions 2ème trimestre', 'emoji': '📝', 'duree': 7},
    {'label': 'BEPC / BAC Blanc', 'emoji': '🎓', 'duree': 14},
    {'label': 'BAC Session principale', 'emoji': '🏆', 'duree': 10},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _actif = AppService().modeExamenActif;
    _dateFin = AppService().modeExamenFin;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _choisirDateFin() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Date de fin du Mode Examen',
      confirmText: 'Confirmer',
      cancelText: 'Annuler',
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.goldMid, surface: AppColors.dark2),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateFin = picked);
  }

  Future<void> _activer() async {
    if (_dateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tu dois choisir une date de fin', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _enregistrement = true);
    await AppService().activerModeExamen(fin: _dateFin!, matieres: _matieresSelectees);
    setState(() { _actif = true; _enregistrement = false; });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Mode Examen activé jusqu\'au ${_formatDate(_dateFin!)} 🎓', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
      backgroundColor: AppColors.goldMid,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _desactiver() async {
    setState(() => _enregistrement = true);
    await AppService().desactiverModeExamen();
    setState(() { _actif = false; _dateFin = null; _matieresSelectees.clear(); _enregistrement = false; });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  int _joursRestants() => _dateFin != null ? _dateFin!.difference(DateTime.now()).inDays : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(children: [
          _buildHeader(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _actif ? _buildEtatActif() : _buildEtatInactif(),
              const SizedBox(height: 20),
              if (!_actif) ...[
                _buildSectionPeriodes(),
                const SizedBox(height: 16),
                _buildSectionDateFin(),
                const SizedBox(height: 16),
                _buildSectionMatieres(),
                const SizedBox(height: 16),
              ],
              _buildSectionProtections(),
              const SizedBox(height: 24),
            ]),
          )),
          _buildBoutonAction(),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 14, left: 16, right: 16, bottom: 18),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.arrow_back, color: Colors.white54, size: 16)),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mode Examen', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          Text('Protection des crédits bonus', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withOpacity(0.4))),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _actif ? AppColors.goldMid.withOpacity(0.2) : Colors.white.withOpacity(0.08),
            border: Border.all(color: _actif ? AppColors.goldMid.withOpacity(0.4) : Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _actif ? AppColors.goldMid : Colors.white38)),
            const SizedBox(width: 5),
            Text(_actif ? 'Actif' : 'Inactif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _actif ? AppColors.goldMid : Colors.white38)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEtatActif() {
    final jours = _joursRestants();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2A2000), Color(0xFF1A1500)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: AppColors.goldMid.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldMid, AppColors.gold]), borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('🎓', style: TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MODE EXAMEN ACTIF', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldMid, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(jours > 0 ? '$jours jour${jours > 1 ? 's' : ''} restant${jours > 1 ? 's' : ''}' : 'Expire aujourd\'hui', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            if (_dateFin != null) Text('Jusqu\'au ${_formatDate(_dateFin!)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.5))),
          ])),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (jours / 30).clamp(0.0, 1.0), backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldMid), minHeight: 6)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _buildProtectionRow('🛡️', 'Crédits bonus protégés', 'Déduction max -2/semaine'),
            const SizedBox(height: 8),
            _buildProtectionRow('🔕', 'Notifications réduites', 'Moins d\'interruptions'),
            const SizedBox(height: 8),
            _buildProtectionRow('👪', 'Parents notifiés', 'Ils savent que tu révises'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEtatInactif() {
    final bonus = AppService().profile?.creditsInfo.bonus ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldMid, AppColors.gold]), borderRadius: BorderRadius.circular(9)), child: const Center(child: Text('🧙', style: TextStyle(fontSize: 14)))),
          const SizedBox(width: 8),
          Text('LE SAGE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.goldMid, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 10),
        Text(
          bonus > 0 ? 'Tu as $bonus crédits bonus à protéger. Active le Mode Examen avant tes épreuves pour éviter toute déduction d\'inactivité.' : 'Active le Mode Examen avant tes épreuves. Tes crédits bonus seront protégés et tes parents seront automatiquement notifiés.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white.withOpacity(0.82), height: 1.6),
        ),
      ]),
    );
  }

  Widget _buildSectionPeriodes() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PÉRIODES OFFICIELLES (MENA)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
      const SizedBox(height: 10),
      ..._periodesOfficielles.map((p) => GestureDetector(
        onTap: () => setState(() => _dateFin = DateTime.now().add(Duration(days: p['duree'] as int))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Text(p['emoji'] as String, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(p['label'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(7)), child: Text('${p['duree']} jours', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold))),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildSectionDateFin() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('DATE DE FIN (OBLIGATOIRE)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _choisirDateFin,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: _dateFin != null ? AppColors.goldMid : AppColors.border, width: _dateFin != null ? 2 : 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: _dateFin != null ? AppColors.goldMid.withOpacity(0.15) : AppColors.background, borderRadius: BorderRadius.circular(11)), child: Center(child: Icon(Icons.calendar_today_rounded, color: _dateFin != null ? AppColors.goldMid : AppColors.text3, size: 20))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_dateFin != null ? 'Fin le ${_formatDate(_dateFin!)}' : 'Choisir une date de fin', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: _dateFin != null ? AppColors.text : AppColors.text3)),
              if (_dateFin != null) Text('${_joursRestants()} jours de protection', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.goldMid)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.text3, size: 20),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildSectionMatieres() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('MATIÈRES CONCERNÉES (optionnel)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _matieres.map((m) {
        final isSelected = _matieresSelectees.contains(m['nom']);
        return GestureDetector(
          onTap: () => setState(() => isSelected ? _matieresSelectees.remove(m['nom']) : _matieresSelectees.add(m['nom']!)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.goldMid.withOpacity(0.15) : AppColors.white,
              border: Border.all(color: isSelected ? AppColors.goldMid : AppColors.border, width: isSelected ? 2 : 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(m['emoji']!, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(m['nom']!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppColors.goldMid : AppColors.text2)),
            ]),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _buildSectionProtections() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CE QUE LE MODE EXAMEN PROTÈGE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
        const SizedBox(height: 12),
        _buildProtectionRowLight('🛡️', 'Crédits bonus protégés', 'Déduction réduite à -2 max (au lieu de -10 par semaine)'),
        const SizedBox(height: 10),
        _buildProtectionRowLight('📅', 'Remise à zéro maintenue', 'Les crédits bonus se remettent quand même à zéro en fin de mois'),
        const SizedBox(height: 10),
        _buildProtectionRowLight('🔕', 'Notifications réduites', 'Le Sage envoie moins d\'alertes pour ne pas te perturber'),
        const SizedBox(height: 10),
        _buildProtectionRowLight('👪', 'Parents notifiés automatiquement', 'Tes parents reçoivent une alerte dès l\'activation'),
        const SizedBox(height: 10),
        _buildProtectionRowLight('🎮', 'Mini-jeu et achats maintenus', 'Tu peux toujours jouer et acheter des cours'),
        const SizedBox(height: 10),
        _buildProtectionRowLight('⏰', 'Désactivation automatique', 'Le mode se désactive tout seul à la date de fin'),
      ]),
    );
  }

  Widget _buildProtectionRow(String emoji, String titre, String soustitre) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titre, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(soustitre, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withOpacity(0.45))),
      ])),
    ]);
  }

  Widget _buildProtectionRowLight(String emoji, String titre, String soustitre) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titre, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
        Text(soustitre, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3, height: 1.4)),
      ])),
    ]);
  }

  Widget _buildBoutonAction() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 12),
      child: _actif
          ? SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: _enregistrement ? null : _desactiver,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: AppColors.red, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: _enregistrement
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Désactiver le Mode Examen', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.red)),
            ))
          : SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _enregistrement ? null : _activer,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldMid, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: _enregistrement
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('🎓', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(_dateFin != null ? 'Activer jusqu\'au ${_formatDate(_dateFin!)}' : 'Activer le Mode Examen', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ]),
            )),
    );
  }
}