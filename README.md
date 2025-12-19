# 🚀 Documentation du Script de Backup et Restore pour MediaStock
**Version 1.0 – Décembre 2025**

---

## 1. Introduction
Ce script permet de réaliser un **backup complet** de l'application MediaStock, incluant :  

- La base de données MySQL  
- Les fichiers du projet  
- Les volumes Docker (données persistantes)  
- Les logs des conteneurs Docker  

Il est conçu pour fonctionner sous **Windows** avec **Git Bash** et **Docker Desktop**.

---

## 2. Prérequis

### 2.1 Environnement requis
- Windows 10/11  
- Git Bash (ou WSL2)  
- Docker Desktop installé et démarré  
- Droits d'écriture dans le répertoire de backup  

### 2.2 Dépendances
- Docker et Docker Compose installés  
- Projet MediaStock fonctionnel avec :  
  - Une base de données MySQL dans un conteneur Docker  
  - Un volume Docker nommé `mediastock_mysql-data`

---

## 3. Installation et Configuration

### 3.1 Téléchargement du script
Place `backup.sh` et `restore.sh` dans le projet MediaStock :  

C:\Users\<utilisateur>\OneDrive - MEDIASCHOOL\Cybersécurité\Mediastock BackUp\MediaStock-main

### 3.2 Configuration du script
Édite les variables dans backup.sh et restore.sh selon ton environnement :

````bash
# Nom du conteneur MySQL
DB_CONTAINER="mediastock-db"

# Identifiants MySQL
DB_USER="mediastock"
DB_PASS="ton_mot_de_passe_mysql"

# Chemin du projet et des backups
PROJECT_ROOT="."
BACKUP_PATH="./backups"

# Durée de rétention des backups en jours
RETENTION_DAYS=7
````

3.3 Création du répertoire de backup
Avant de lancer le script :

bash
Copier le code
mkdir -p ./backups
4. Fonctionnement du Script
4.1 Étapes du backup
Vérification des prérequis : Docker et conteneur MySQL actifs

Backup de la base de données MySQL :

bash
Copier le code
docker exec "$DB_CONTAINER" mysqldump -u"$DB_USER" -p"$DB_PASS" --all-databases | gzip > "$BACKUP_PATH/db/mysql_all.sql.gz"
Backup des volumes Docker :

bash
Copier le code
docker run --rm -v mediastock_mysql-data:/data -v "$BACKUP_PATH/volumes:/backup" alpine tar czf /backup/mysql-data.tar.gz -C /data .
Backup des fichiers du projet :

bash
Copier le code
rsync -av --exclude backups --exclude .git "$PROJECT_ROOT/" "$BACKUP_PATH/app/"
Backup des fichiers de configuration :

bash
Copier le code
cp .env docker-compose.yml docker-compose.production.yml "$BACKUP_PATH/config/"
Création de l’archive finale :

bash
Copier le code
cd "$BACKUP_ROOT"
tar czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"
sha256sum "$BACKUP_NAME.tar.gz" > "$BACKUP_NAME.sha256"
Nettoyage des anciens backups :

bash
Copier le code
find "$BACKUP_ROOT" -name "mediastock_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
5. Utilisation
5.1 Lancer le backup manuellement
Ouvre Git Bash et exécute :

bash
Copier le code
cd /c/Users/<utilisateur>/OneDrive\ -\ MEDIASCHOOL/Cybersécurité/Mediastock\ BackUp/MediaStock-main
./backup.sh
5.2 Planifier un backup automatique (Windows)
Ouvrir le Planificateur de tâches (taskschd.msc)

Créer une nouvelle tâche :

Déclencheur : ex. tous les jours à 2h

Action : Lancer un programme

Programme : C:\Program Files\Git\bin\bash.exe

Arguments : -c "cd /c/Users/<utilisateur>/OneDrive - MEDIASCHOOL/Cybersécurité/Mediastock BackUp/MediaStock-main && ./backup.sh"

6. Structure des Backups
Chaque backup est organisé comme suit :

bash
Copier le code
mediastock_backup_YYYYMMDD_HHMMSS/
├── db/
│   └── mysql_all.sql.gz         # Backup de la base MySQL
├── app/
│   └── ...                      # Fichiers du projet
├── volumes/
│   └── mysql-data.tar.gz        # Backup du volume Docker
├── config/
│   ├── .env
│   ├── docker-compose.yml
│   └── docker-compose.production.yml
└── mediastock_backup_YYYYMMDD_HHMMSS.tar.gz  # Archive finale
└── mediastock_backup_YYYYMMDD_HHMMSS.sha256  # Checksum
7. Restauration des Données
7.1 Restaurer la base de données
bash
Copier le code
tar -xzf "$BACKUP_FILE" -C /tmp/
docker exec -i "$DB_CONTAINER" mysql -u"$DB_USER" -p"$DB_PASS" < /tmp/$(basename "$BACKUP_FILE" .tar.gz)/db/mysql_all.sql
7.2 Restaurer les volumes Docker
bash
Copier le code
tar -xzf /tmp/$(basename "$BACKUP_FILE" .tar.gz)/volumes/mysql-data.tar.gz -C /tmp/mysql_data
docker run --rm -v mediastock_mysql-data:/volume_data -v /tmp/mysql_data:/backup alpine sh -c "rm -rf /volume_data/* && tar -xzf /backup/mysql-data.tar.gz -C /volume_data"
7.3 Restaurer les fichiers du projet
bash
Copier le code
rsync -a --delete /tmp/$(basename "$BACKUP_FILE" .tar.gz)/app/ "$PROJECT_ROOT/"
7.4 Restaurer les fichiers de configuration
bash
Copier le code
cp /tmp/$(basename "$BACKUP_FILE" .tar.gz)/config/* "$PROJECT_ROOT/config/"
8. Gestion des Erreurs
Erreur	Cause	Solution
Docker n’est pas en cours d’exécution	Docker Desktop arrêté	Démarrer Docker Desktop
Conteneur MySQL non lancé	Conteneur MySQL absent	Lancer docker compose up -d
Volume Docker manquant	Volume mediastock_mysql-data inexistant	Vérifier avec docker volume ls
Fichier manquant dans backup	Permissions ou chemin incorrect	Vérifier $BACKUP_PATH et les droits d’écriture

9. Vérification de l’intégrité
Pour vérifier qu’un backup est valide, compare le checksum SHA256 :

bash
Copier le code
sha256sum mediastock_backup_YYYYMMDD_HHMMSS.tar.gz
cat mediastock_backup_YYYYMMDD_HHMMSS.sha256
10. Bonnes pratiques
Tester régulièrement les backups avec la restauration

Stocker les backups sur un disque externe ou un cloud

Vérifier les logs générés par le script (backup_YYYYMMDD_HHMMSS.log)

Mettre à jour les mots de passe MySQL dans les scripts lors de changement

👨‍💻 Auteur : Louka Lavenir
📅 Date : 19/12/2025
🏫 Mediaschool Nice – BTS SIO SISR
