# Configuration d'exemple pour Cyra
# Copiez ce fichier vers config.py et modifiez avec vos vraies valeurs

# ============================================================================
# CONFIGURATION BASE DE DONNÉES
# ============================================================================

DATABASE_CONFIG = {
    'dbname': "Asterix",        # Nom de votre base de données
    'user': "votre_user",       # Remplacez par votre utilisateur PostgreSQL
    'password': "votre_password", # Remplacez par votre mot de passe
    'host': "localhost",        # Adresse du serveur PostgreSQL
    'port': "5432"             # Port PostgreSQL (généralement 5432)
}

# ============================================================================
# PARAMÈTRES DE RECONNAISSANCE
# ============================================================================

RECOGNITION_CONFIG = {
    # Seuil de reconnaissance (0.0 à 1.0)
    # Plus bas = plus strict, Plus haut = plus permissif
    'threshold': 0.55,
    
    # Modèle à utiliser ('VGG-Face', 'Facenet', 'DeepFace', 'OpenFace', 'ArcFace')
    'model_name': "VGG-Face",
    
    # Traiter 1 frame sur X pour améliorer les performances
    'skip_frames': 1,
    
    # Activer/désactiver les logs de reconnaissance en base
    'enable_logging': False
}

# ============================================================================
# PARAMÈTRES WEBCAM ET AFFICHAGE
# ============================================================================

CAMERA_CONFIG = {
    # Source vidéo (0 = webcam par défaut, 1 = webcam externe, ou chemin vers fichier)
    'video_source': 0,
    
    # Résolution de capture
    'width': 640,
    'height': 480,
    'fps': 30,
    
    # Paramètres de détection de visages
    'min_face_size': (60, 60),
    'max_face_size': (300, 300),
    'scale_factor': 1.1,
    'min_neighbors': 4
}

DISPLAY_CONFIG = {
    # Couleurs des rectangles (BGR)
    'known_face_color': (0, 255, 0),    # Vert pour visages connus
    'unknown_face_color': (0, 0, 255),  # Rouge pour visages inconnus
    
    # Police et taille du texte
    'font_scale': 0.9,
    'font_thickness': 2,
    
    # Afficher la distance dans le nom
    'show_distance': True,
    
    # Afficher les FPS
    'show_fps': False
}

# ============================================================================
# CHEMINS ET DOSSIERS
# ============================================================================

PATHS_CONFIG = {
    # Dossier pour stocker les images de référence
    'reference_images_dir': "./data/references/",
    
    # Dossier pour logs et captures
    'logs_dir': "./logs/",
    'captures_dir': "./captures/",
    
    # Fichier de log
    'log_file': "./logs/cyra.log"
}

# ============================================================================
# PARAMÈTRES AVANCÉS
# ============================================================================

ADVANCED_CONFIG = {
    # Niveau de log ('DEBUG', 'INFO', 'WARNING', 'ERROR')
    'log_level': 'INFO',
    
    # Utiliser le cache pour éviter les recalculs
    'use_cache': True,
    'cache_duration': 1.0,  # secondes
    
    # Sauvegarder les captures automatiquement
    'auto_save_captures': False,
    
    # Nombre maximum de visages à traiter par frame
    'max_faces_per_frame': 5
}

# ============================================================================
# INSTRUCTIONS D'UTILISATION
# ============================================================================

"""
COMMENT UTILISER CE FICHIER :

1. Copiez ce fichier :
   cp config.example.py config.py

2. Modifiez les valeurs dans config.py selon votre configuration

3. Dans main.py, importez la config :
   from config import DATABASE_CONFIG, RECOGNITION_CONFIG, etc.

4. Utilisez les paramètres dans votre code :
   conn = psycopg2.connect(**DATABASE_CONFIG)
   threshold = RECOGNITION_CONFIG['threshold']

SÉCURITÉ :
- Ne commitez JAMAIS config.py avec vos vrais mots de passe
- config.py est dans .gitignore pour votre protection
- Seul config.example.py sera versionné
"""
