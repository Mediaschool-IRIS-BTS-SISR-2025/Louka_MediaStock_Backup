Documentation du Script de Backup pour MediaStock

Version 1.0 – Décembre 2025

1. Introduction

Ce script permet de réaliser un backup complet de l'application MediaStock, incluant :

La base de données MySQL.

Les fichiers du projet.

Les volumes Docker (données persistantes).

Les logs des conteneurs Docker.

Il est conçu pour fonctionner sous Windows avec Git Bash et Docker Desktop.

2. Prérequis
2.1 Environnement requis

Système d'exploitation : Windows 10/11.

Terminal : Git Bash (ou WSL2).

Docker : Docker Desktop installé et démarré.

Droits d'accès : Droits d'écriture dans le répertoire de backup.

2.2 Dépendances

Docker et Docker Compose installés.

Un projet MediaStock fonctionnel avec :

Une base de données MySQL dans un conteneur Docker.

Un volume Docker nommé mediastock_mysql-data.

3. Installation et Configuration
3.1 Téléchargement du script

Place le script backup.sh et restore.sh dans le projet :

C:\Users\<utilisateur>\OneDrive - MEDIASCHOOL\Cybersécurité\Mediastock BackUp\MediaStock-main

3.2 Configuration du script

Ouvre backup.sh et modifie les variables si nécessaire :

# Nom du conteneur MySQL
DB_CONTAINER="mediastock-db"

# Utilisateur et mot de passe MySQL
DB_USER="mediastock"
DB_PASS="motdepasse"

# Chemin du projet et backup
PROJECT_ROOT="C:\Users\<utilisateur>\OneDrive - MEDIASCHOOL\Cybersécurité\Mediastock BackUp\MediaStock-main"
BACKUP_ROOT="./backups"


Pour restore.sh, assurez-vous que la variable d'environnement MYSQL_PASSWORD est définie :

export MYSQL_PASSWORD="motdepasse"

3.3 Création du répertoire de backup

Avant de lancer le script :

mkdir -p "./backups"

4. Fonctionnement du Script
4.1 Étapes du backup

Vérification des prérequis :

Docker est démarré.

Le conteneur MySQL est accessible.

Backup MySQL :

Export via mysqldump compressé en .sql.gz.

Backup du code source :

Copie de tous les fichiers du projet sauf .git et les backups existants.

Backup des volumes Docker :

Le volume mediastock_mysql-data est archivé via un conteneur Alpine.

Backup des fichiers de configuration :

.env, docker-compose.yml, docker-compose.production.yml.

Création de l’archive finale :

Compression de tous les backups dans un fichier .tar.gz.

Génération d’un checksum SHA256.

Nettoyage des anciens backups :

Suppression des backups de plus de 7 jours.

5. Utilisation
5.1 Lancer le backup manuellement

Ouvre Git Bash et exécute :

cd "C:\Users\<utilisateur>\OneDrive - MEDIASCHOOL\Cybersécurité\Mediastock BackUp\MediaStock-main"
bash backup.sh

5.2 Restore

Arrêter les conteneurs pour éviter les conflits MySQL :

docker compose down


Définir le mot de passe MySQL :

export MYSQL_PASSWORD="motdepasse"


Lancer le restore :

bash restore.sh ./backups/mediastock_backup_YYYYMMDD_HHMMSS.tar.gz


Si aucun fichier n’est précisé, le script prend automatiquement le dernier backup.

Après restauration, redémarrer les conteneurs :

docker compose up -d

6. Structure des Backups

Chaque backup est organisé comme suit :

mediastock_backup_YYYYMMDD_HHMMSS/
├── db/
│   └── mysql_all.sql.gz        # Backup MySQL
├── app/                        # Code source de l'application
├── volumes/
│   └── mysql-data.tar.gz       # Backup du volume Docker
├── config/
│   ├── .env
│   ├── docker-compose.yml
│   └── docker-compose.production.yml
└── mediastock_backup_YYYYMMDD_HHMMSS.tar.gz # Archive finale

7. Bonnes pratiques

Tester régulièrement les backups avec restore.sh.

Stocker les backups sur un disque externe ou cloud.

Vérifier les logs générés (backup_YYYYMMDD_HHMMSS.log).

Ne jamais supprimer manuellement les volumes Docker sans backup.
