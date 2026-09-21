import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';

class PublierCoursScreen extends StatefulWidget {
  const PublierCoursScreen({super.key});

  @override
  State<PublierCoursScreen> createState() => _PublierCoursScreenState();
}

class _PublierCoursScreenState extends State<PublierCoursScreen>
    with SingleTickerProviderStateMixin {
  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  String _matiereSelectee = 'Mathématiques';
  String _niveauSelecte = 'Terminale D';
  String _formatSelecte = 'PDF';
  PlatformFile? _fichierSelectionne;
  bool _isPublishing = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _matieres = [
    'Mathématiques', 'SVT', 'Physique-Chimie',
    'Français', 'Histoire-Géo', 'Philosophie',
  ];
  final List<String> _niveaux = [
    'Terminale D', 'Terminale A', 'Terminale C',
    '3ème', '2nde', '1ère',
  ];
  final List<Map<String, dynamic>> _formats = [
    {'label': 'PDF', 'icon': '📄'},
    {'label': 'Vidéo', 'icon': '🎥'},
    {'label': 'Audio', 'icon': '🎧'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _publier() async {
    if (_titreController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Remplis le titre et la description',
              style: TextStyle(fontFamily: 'PlusJakartaSans')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_fichierSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ajoute un fichier $_formatSelecte avant de publier',
              style: TextStyle(fontFamily: 'PlusJakartaSans')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.pop(context, {
        'titre': _titreController.text.trim(),
        'matiere': _matiereCode(_matiereSelectee),
        'eleves': 0,
        'note': 0.0,
        'revenus': 0,
        'format': _formatSelecte,
        'fichier': _fichierSelectionne!.name,
      });
    }
  }

  String _matiereCode(String matiere) {
    if (matiere == 'Mathématiques') return 'MATHS';
    if (matiere == 'Physique-Chimie') return 'PHYS';
    if (matiere == 'Histoire-Géo') return 'HIST';
    return matiere.toUpperCase();
  }

  Future<void> _choisirFichier() async {
    final List<String> extensions;
    if (_formatSelecte == 'PDF') {
      extensions = ['pdf'];
    } else if (_formatSelecte == 'Vidéo') {
      extensions = ['mp4', 'mov', 'avi', 'mkv'];
    } else {
      extensions = ['mp3', 'm4a', 'wav', 'aac'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: false,
      withData: false,
    );

    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _fichierSelectionne = result.files.single);
  }

  String _formatFileSize(int size) {
    if (size >= 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    if (size >= 1024) return '${(size / 1024).toStringAsFixed(1)} Ko';
    return '$size o';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrixInfo(),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'TITRE DU COURS',
                      hint: 'Ex: Équations du second degré — Méthodes complètes',
                      controller: _titreController,
                    ),
                    _buildField(
                      label: 'DESCRIPTION',
                      hint: 'Décris le contenu de ton cours...',
                      controller: _descController,
                      maxLines: 4,
                    ),
                    _buildDropdown(
                      label: 'MATIÈRE',
                      value: _matiereSelectee,
                      items: _matieres,
                      onChanged: (v) => setState(() => _matiereSelectee = v!),
                    ),
                    _buildDropdown(
                      label: 'NIVEAU',
                      value: _niveauSelecte,
                      items: _niveaux,
                      onChanged: (v) => setState(() => _niveauSelecte = v!),
                    ),
                    _buildFormatSelector(),
                    const SizedBox(height: 8),
                    _buildFichierUpload(),
                    const SizedBox(height: 20),
                    _buildSageHint(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPublishing ? null : _publier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                        child: _isPublishing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Publier le cours — 200 FCFA',
                                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
        bottom: 18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white54, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Publier un cours',
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrixInfo() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('💰', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix fixe : 200 FCFA par cours',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  'Prix défini par la plateforme — simplifie la décision d\'achat et garantit la cohérence.',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11,
                    color: AppColors.gold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 13, color: AppColors.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 13, color: AppColors.text3),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: AppColors.greenMid, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13, vertical: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 13, color: AppColors.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: AppColors.greenMid, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13, vertical: 11),
            ),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FORMAT DU COURS',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 8),
          Row(
            children: _formats.map((f) {
              final isSelected = _formatSelecte == f['label'];
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() {
                        _formatSelecte = f['label'];
                        _fichierSelectionne = null;
                      }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: f == _formats.last ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.greenLight
                          : AppColors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.greenMid
                            : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      children: [
                        Text(f['icon'],
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(f['label'],
                            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.text2,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFichierUpload() {
    return GestureDetector(
      onTap: _choisirFichier,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
              color: AppColors.greenMid.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: _fichierSelectionne == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const Icon(Icons.upload_file_outlined,
                color: AppColors.greenMid, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: _fichierSelectionne == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    _fichierSelectionne?.name ?? 'Importer le fichier $_formatSelecte',
                    style: TextStyle(fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenMid,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_fichierSelectionne != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${_formatSelecte} sélectionné · ${_formatFileSize(_fichierSelectionne!.size)}',
                      style: TextStyle(fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_fichierSelectionne != null)
              GestureDetector(
                onTap: () => setState(() => _fichierSelectionne = null),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.close, color: AppColors.text3, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSageHint() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Le Sage analysera ton cours dès la publication et suggèrera des exercices adaptés à tes élèves.',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
