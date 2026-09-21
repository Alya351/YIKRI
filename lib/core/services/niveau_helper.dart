// Utilitaire pour déterminer le niveau et la série d'un élève

class NiveauHelper {
  static bool isCollege(String classe) {
    return ['6ème', '5ème', '4ème', '3ème'].contains(classe);
  }

  static bool isLycee(String classe) => !isCollege(classe);

  static bool isTerminale(String classe) => classe.startsWith('Terminale');

  static bool isPremiere(String classe) => classe.startsWith('1ère');

  static bool isSeconde(String classe) => classe == '2nde';

  static String getSerie(String classe) {
    if (classe.contains('A')) return 'A';
    if (classe.contains('C')) return 'C';
    if (classe.contains('D')) return 'D';
    if (isCollege(classe)) return 'college';
    return 'general';
  }

  static String getEmoji(String classe) {
    if (classe == '6ème') return '🌱';
    if (classe == '5ème') return '🌿';
    if (classe == '4ème') return '🌳';
    if (classe == '3ème') return '🎯';
    if (classe == '2nde') return '🚀';
    if (classe.startsWith('1ère')) return '⭐';
    if (classe.startsWith('Terminale')) return '🏆';
    return '📚';
  }
}