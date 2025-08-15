# 🔍 Cyra - Système de Reconnaissance Faciale

Un système de reconnaissance faciale en temps réel utilisant DeepFace, OpenCV et PostgreSQL.

## 📋 Description

Cyra est un système intelligent de reconnaissance faciale qui :

- Détecte et identifie les visages en temps réel via webcam
- Compare avec une base de données PostgreSQL de visages connus
- Utilise le modèle VGG-Face pour une reconnaissance précise
- Affiche les résultats avec des rectangles colorés et les noms

## ✨ Fonctionnalités

- **Reconnaissance en temps réel** : Traitement vidéo fluide depuis la webcam
- **Base de données intégrée** : Stockage des références dans PostgreSQL
- **Modèle IA avancé** : Utilisation de VGG-Face via DeepFace
- **Interface visuelle** : Affichage des résultats avec rectangles colorés
- **Optimisations performance** : Pré-calcul des embeddings de référence
- **Logging détaillé** : Distances et debug en temps réel

## 🚀 Installation

### Prérequis

- Python 3.8+
- PostgreSQL
- Webcam fonctionnelle

### Étapes d'installation

1. **Cloner le projet**

```bash
 git clone <url-du-repo>
cd Cyra
```

2. **Créer l'environnement virtuel**

```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate     # Windows
```

3. **Installer les dépendances**

```bash
pip install -r requirements.txt
```

4. **Configuration de la base de données**

Créez la base de données PostgreSQL :

```sql
CREATE DATABASE Asterix;
```

Créez la table des personnes :

```sql
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    images_path VARCHAR(255) NOT NULL
);
```

Optionnel - Table des logs :

```sql
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES persons(id),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

5. **Configuration**

Modifiez les paramètres de connexion dans `main.py` :

```python
conn = psycopg2.connect(
    dbname="Asterix",
    user="votre_utilisateur",
    password="votre_mot_de_passe",
    host="localhost",
    port="5432"
)
```

## 📊 Structure de la Base de Données

### Table `persons`


| Colonne     | Type         | Description                        |
| ----------- | ------------ | ---------------------------------- |
| id          | SERIAL       | Identifiant unique                 |
| nom         | VARCHAR(100) | Nom de la personne                 |
| images_path | VARCHAR(255) | Chemin vers l'image de référence |

### Table `logs` (optionnelle)


| Colonne   | Type      | Description                  |
| --------- | --------- | ---------------------------- |
| id        | SERIAL    | Identifiant unique           |
| user_id   | INTEGER   | Référence vers persons.id  |
| timestamp | TIMESTAMP | Date/heure de reconnaissance |

## 🎯 Utilisation

1. **Ajouter des visages de référence**

```sql
INSERT INTO persons (nom, images_path) VALUES 
('John Doe', '/chemin/vers/john.jpg'),
('Jane Smith', '/chemin/vers/jane.jpg');
```

2. **Lancer la reconnaissance**

```bash
python main.py
```

3. **Contrôles**

- `q` : Quitter l'application
- La webcam s'ouvre automatiquement
- Les visages sont détectés avec des rectangles colorés :
  - 🔴 **Rouge** : Visage inconnu
  - 🟢 **Vert** : Visage reconnu

## ⚙️ Configuration

### Paramètres principaux dans `main.py` :

```python
# Seuil de reconnaissance (plus bas = plus strict)
threshold = 0.55

# Modèle utilisé
model_name = "VGG-Face"

# Paramètres OpenCV
minSize=(60, 60)  # Taille minimale des visages détectés
```

## 🔧 Optimisations

### Performance

- **Pré-calcul des embeddings** : Les visages de référence sont traités une seule fois
- **Modèle VGG-Face** : Équilibre précision/vitesse optimal
- **Détection OpenCV** : Haar Cascade pour détection rapide

### Qualité

- **Distance euclidienne** : Mesure de similarité entre embeddings
- **Seuil ajustable** : Contrôle de la sensibilité
- **Gestion d'erreurs** : Robustesse face aux images corrompues

## 📁 Structure du Projet

```
Cyra/
├── .venv/              # Environnement virtuel
├── main.py             # Script principal
├── requirements.txt    # Dépendances Python
├── README.md          # Documentation
├── .gitignore         # Fichiers à ignorer
└── data/              # Dossier pour images de test (optionnel)
```

## 🐛 Dépannage

### Erreurs courantes

**1. Erreur de connexion PostgreSQL**

- Vérifiez que PostgreSQL est démarré
- Contrôlez les paramètres de connexion
- Assurez-vous que l'utilisateur a les droits

**2. Webcam non détectée**

- Testez avec `cv2.VideoCapture(0)` dans Python
- Vérifiez les permissions de la webcam
- Essayez d'autres indices (1, 2, etc.)

**3. Images non trouvées**

- Vérifiez les chemins dans la base de données
- Utilisez des chemins absolus
- Contrôlez les permissions des fichiers

**4. Modèle DeepFace lent**

- Première utilisation : téléchargement automatique
- Réduisez la résolution de la webcam si nécessaire
- Considérez l'utilisation d'un GPU

## 📈 Performances

### Benchmarks typiques

- **FPS moyen** : 15-25 fps (selon matériel)
- **Temps de reconnaissance** : 50-200ms par visage
- **Précision** : ~95% avec seuil 0.55
- **Mémoire** : ~500MB-1GB selon nombre de références

### Optimisations possibles

- Réduction de la résolution webcam
- Skip frames (traiter 1 frame sur N)
- Cache des résultats récents
- Utilisation GPU avec CUDA

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- [DeepFace](https://github.com/serengil/deepface) - Librairie de reconnaissance faciale
- [OpenCV](https://opencv.org/) - Traitement d'images
- [PostgreSQL](https://www.postgresql.org/) - Base de données
- Communauté Python pour l'écosystème riche

## 📞 Support

Pour tout problème ou question :

- Ouvrez une issue sur GitHub
- Consultez la documentation DeepFace
- Vérifiez les logs d'erreur en mode debug

---

**Développé avec ❤️ pour la reconnaissance faciale intelligente**
