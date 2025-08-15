-- ============================================================================
-- CYRA - RECONNAISSANCE FACIALE
-- Structure de la base de données PostgreSQL
-- ============================================================================

-- Créer la base de données (à exécuter en tant qu'admin PostgreSQL)
-- CREATE DATABASE Asterix;
-- \c Asterix;

-- ============================================================================
-- TABLE PRINCIPALE : PERSONNES
-- ============================================================================

CREATE TABLE IF NOT EXISTS persons (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    images_path VARCHAR(255) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT TRUE,
    description TEXT
);

-- Index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_persons_nom ON persons(nom);
CREATE INDEX IF NOT EXISTS idx_persons_actif ON persons(actif);

-- ============================================================================
-- TABLE DES LOGS DE RECONNAISSANCE
-- ============================================================================

CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES persons(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confidence_score DECIMAL(5,4),
    distance_calculated DECIMAL(8,6),
    camera_source VARCHAR(50) DEFAULT 'webcam',
    notes TEXT
);

-- Index pour optimiser les recherches par date et utilisateur
CREATE INDEX IF NOT EXISTS idx_logs_user_id ON logs(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_logs_user_timestamp ON logs(user_id, timestamp);

-- ============================================================================
-- TABLE DE CONFIGURATION SYSTÈME (optionnelle)
-- ============================================================================

CREATE TABLE IF NOT EXISTS system_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    description TEXT,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer quelques configurations par défaut
INSERT INTO system_config (config_key, config_value, description) VALUES
('recognition_threshold', '0.55', 'Seuil de reconnaissance par défaut'),
('model_name', 'VGG-Face', 'Modèle de reconnaissance utilisé'),
('enable_logging', 'true', 'Activer les logs de reconnaissance'),
('max_faces_per_frame', '5', 'Nombre maximum de visages à traiter par frame')
ON CONFLICT (config_key) DO NOTHING;

-- ============================================================================
-- VUES UTILES
-- ============================================================================

-- Vue pour les statistiques par utilisateur
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    p.id,
    p.nom,
    p.prenom,
    COUNT(l.id) as total_detections,
    MAX(l.timestamp) as derniere_detection,
    AVG(l.confidence_score) as score_moyen,
    AVG(l.distance_calculated) as distance_moyenne
FROM persons p
LEFT JOIN logs l ON p.id = l.user_id
WHERE p.actif = true
GROUP BY p.id, p.nom, p.prenom;

-- Vue pour les détections récentes (dernières 24h)
CREATE OR REPLACE VIEW detections_recentes AS
SELECT 
    p.nom,
    p.prenom,
    l.timestamp,
    l.confidence_score,
    l.distance_calculated
FROM persons p
JOIN logs l ON p.id = l.user_id
WHERE l.timestamp > NOW() - INTERVAL '24 hours'
ORDER BY l.timestamp DESC;

-- ============================================================================
-- FONCTIONS UTILES
-- ============================================================================

-- Fonction pour nettoyer les anciens logs (garder seulement les 30 derniers jours)
CREATE OR REPLACE FUNCTION cleanup_old_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM logs 
    WHERE timestamp < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les statistiques système
CREATE OR REPLACE FUNCTION get_system_stats()
RETURNS TABLE (
    total_persons INTEGER,
    active_persons INTEGER,
    total_detections BIGINT,
    detections_today BIGINT,
    avg_daily_detections NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM persons) as total_persons,
        (SELECT COUNT(*)::INTEGER FROM persons WHERE actif = true) as active_persons,
        (SELECT COUNT(*) FROM logs) as total_detections,
        (SELECT COUNT(*) FROM logs WHERE DATE(timestamp) = CURRENT_DATE) as detections_today,
        (SELECT COALESCE(AVG(daily_count), 0) 
         FROM (
             SELECT DATE(timestamp) as detection_date, COUNT(*) as daily_count
             FROM logs 
             WHERE timestamp > NOW() - INTERVAL '30 days'
             GROUP BY DATE(timestamp)
         ) daily_stats) as avg_daily_detections;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS POUR MISE À JOUR AUTOMATIQUE
-- ============================================================================

-- Trigger pour mettre à jour date_modification automatiquement
CREATE OR REPLACE FUNCTION update_modification_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_persons_modification
    BEFORE UPDATE ON persons
    FOR EACH ROW
    EXECUTE FUNCTION update_modification_date();

CREATE TRIGGER trigger_update_config_modification
    BEFORE UPDATE ON system_config
    FOR EACH ROW
    EXECUTE FUNCTION update_modification_date();

-- ============================================================================
-- DONNÉES D'EXEMPLE (à supprimer en production)
-- ============================================================================

-- Insérer quelques personnes d'exemple
-- INSERT INTO persons (nom, prenom, images_path, description) VALUES
-- ('Doe', 'John', '/path/to/john_doe.jpg', 'Utilisateur de test'),
-- ('Smith', 'Jane', '/path/to/jane_smith.jpg', 'Utilisatrice de test'),
-- ('Admin', 'System', '/path/to/admin.jpg', 'Administrateur système');

-- ============================================================================
-- REQUÊTES UTILES POUR L'ADMINISTRATION
-- ============================================================================

/*
-- Voir toutes les personnes actives :
SELECT * FROM persons WHERE actif = true ORDER BY nom;

-- Voir les détections du jour :
SELECT p.nom, COUNT(*) as detections 
FROM persons p 
JOIN logs l ON p.id = l.user_id 
WHERE DATE(l.timestamp) = CURRENT_DATE 
GROUP BY p.nom 
ORDER BY detections DESC;

-- Voir les statistiques par utilisateur :
SELECT * FROM user_stats ORDER BY total_detections DESC;

-- Nettoyer les anciens logs :
SELECT cleanup_old_logs();

-- Voir les statistiques système :
SELECT * FROM get_system_stats();

-- Désactiver un utilisateur :
UPDATE persons SET actif = false WHERE nom = 'Nom_Utilisateur';

-- Voir les détections récentes :
SELECT * FROM detections_recentes LIMIT 10;
*/

-- ============================================================================
-- PERMISSIONS (à adapter selon vos besoins)
-- ============================================================================

-- Créer un utilisateur pour l'application
-- CREATE USER cyra_app WITH PASSWORD 'mot_de_passe_securise';

-- Donner les permissions nécessaires
-- GRANT SELECT, INSERT, UPDATE ON persons TO cyra_app;
-- GRANT SELECT, INSERT ON logs TO cyra_app;
-- GRANT SELECT ON system_config TO cyra_app;
-- GRANT USAGE ON SEQUENCE persons_id_seq TO cyra_app;
-- GRANT USAGE ON SEQUENCE logs_id_seq TO cyra_app;
