# 🎓 Yikri (Yi-Kri) — Plateforme Mobile Éducative & Tuteur IA pour le Burkina Faso

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Gemini AI](https://img.shields.io/badge/Google%20Gemini-AI%20Tutor-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-blueviolet?style=for-the-badge)](https://riverpod.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge)](https://flutter.dev)

**Yikri** (*« Lève-toi / Éveille-toi »* en langue Mooré) est une application mobile **EdTech** multiplateforme innovante conçue pour rendre l'éducation accessible, interactive et captivante pour les élèves du Burkina Faso et d'Afrique de l'Ouest, même dans les zones à faible connectivité.

---

## 🌟 Fonctionnalités Clés

### 🧠 1. Le Tuteur Intelligent « Le Sage » (Google Gemini AI)
* **Assistance Pédagogique 24/7 :** Dialogue interactif avec une IA pédagogique adaptée aux programmes scolaires nationaux (CEP, BEPC, BAC).
* **Mode Défi Quotidien :** Quiz génératifs instantanés pour tester la compréhension des notions abordées.
* **Explications pas à pas :** Décomposition simplifiée des problèmes mathématiques, scientifiques et littéraires.

### 📚 2. Hub d'Apprentissage & Révisions
* **Cours & Fiches Synthétiques :** Fiches de cours structurées par niveau et par matière.
* **Devoirs & Exercices Corrigés :** Bibliothèque d'épreuves d'entraînement avec corrigés détaillés.
* **Mode Examen Blanc :** Simulation en conditions réelles avec chronomètre et notation instantanée.

### 🎮 3. Gamification & Engagement
* **Système de Points & Classements :** Tableaux des meilleurs scores par classe, établissement et région.
* **Mini-jeux Éducatifs :** Consolidation des acquis par le jeu (calcul rapide, culture générale, vocabulaire).
* **Badges d'Impact :** Récompenses visuelles valorisant la régularité et la persévérance de l'élève.

### 👨‍👩‍👧‍👦 4. Espaces Enseignants & Parents
* **Espace Enseignant / Classe Connectée :** Publication directe de cours, devoirs et suivi collectif des élèves.
* **Espace Parent :** Tableau de bord de suivi des progrès, temps d'étude et points faibles de l'enfant.

### 📡 5. Mode Hors-Ligne & Résilience Réseau
* **Détection Intelligente de Connectivité :** Bascule automatique en mode dégradé avec cache local lorsque la connexion Internet est coupée (`connectivity_plus`).
* **Intégration Paiements Mobiles :** Support des micro-abonnements via Mobile Money (Orange Money, Moov Money).

---

## 🛠️ Stack Technique

* **Framework :** [Flutter](https://flutter.dev) (SDK Dart 3.x)
* **Architecture :** Feature-First Clean Architecture
* **State Management :** [Flutter Riverpod](https://riverpod.dev) (v2.4+)
* **Routage & Navigation :** [GoRouter](https://pub.dev/packages/go_router) (v13+)
* **Intelligence Artificielle :** Google Gemini Flash API (`generativelanguage.googleapis.com`)
* **Stockage Local :** `shared_preferences`
* **Design System :** Google Fonts (Inter, Outfit), Material 3, animations fluides et transitions modernes.

---

## 📁 Structure du Projet

```
lib/
├── core/
│   ├── config/             # Configuration API (Gemini, Endpoints)
│   ├── services/           # Services (Gemini AI, Auth, Notification, Offline, Paiement)
│   └── theme/              # Palette de couleurs, typographies, styles globaux
├── features/
│   ├── auth/               # Connexion, inscription, sélection d'avatar
│   ├── onboarding/         # Écrans d'accueil et tutoriel initial
│   ├── home/               # Tableau de bord principal de l'apprenant
│   ├── cours/              # Catalogue et consultation des leçons
│   ├── fiches/             # Résumés de cours et fiches mémo
│   ├── devoirs/            # Exercices d'entraînement
│   ├── examen/             # Simulateur d'épreuves et examens blancs
│   ├── sage/               # Chat avec le tuteur IA « Le Sage » & Défis
│   ├── jeu/                # Jeux sérieux et quiz de renforcement
│   ├── classement/         # Leaderboards et classements compétitifs
│   ├── stats/              # Graphiques de performance et progression
│   ├── parent/             # Portail de suivi parental
│   ├── enseignant/         # Outils de publication pour les professeurs
│   └── profil/             # Gestion du compte et préférences
└── main.dart               # Point d'entrée de l'application
```

---

## 🚀 Installation & Lancement

### Prérequis
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.19 ou supérieure)
* [Android Studio](https://developer.android.com/studio) ou VS Code avec l'extension Flutter/Dart
* Clé API Google Gemini (gratuite sur [Google AI Studio](https://aistudio.google.com/))

### 1. Cloner le projet
```bash
git clone https://github.com/Alya351/yikri-2-.git
cd yikri-2-
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configurer la clé Gemini AI
Copiez le fichier de configuration d'exemple :
```bash
cp lib/core/config/api_config.example.dart lib/core/config/api_config.dart
```
Puis ajoutez votre clé API Gemini dans `lib/core/config/api_config.dart` ou lancez l'application avec la variable d'environnement :
```bash
flutter run --dart-define=GEMINI_API_KEY=votre_cle_api_gemini
```

---

## 👩‍💻 Auteur

**Kiemde Banyala Latifa Alya**  
*Élève Ingénieure en Systèmes Numériques & Développeuse Mobile / Fullstack*  
*ISGE-BF (Institut Supérieur de Génie Électrique du Burkina Faso)*
