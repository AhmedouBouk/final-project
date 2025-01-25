# ESP Schedule Manager

Une application web Django pour la gestion des emplois du temps de l'ESP.

## Fonctionnalités

- Interface conviviale pour la visualisation des emplois du temps
- Gestion du plan des emplois du temps avec drag-and-drop
- Base de données complète des cours, professeurs et salles
- Version mobile pour la consultation des emplois du temps
- Interface responsive et moderne

## Installation

1. Créez un environnement virtuel et activez-le :
```bash
python -m venv venv
venv\Scripts\activate
```

2. Installez les dépendances :
```bash
pip install -r requirements.txt
```

3. Effectuez les migrations :
```bash
python manage.py makemigrations
python manage.py migrate
```

4. Créez un superutilisateur :
```bash
python manage.py createsuperuser
```

5. Lancez le serveur :
```bash
python manage.py runserver
```

## Structure du projet

- `schedule/` : Application principale
  - `models.py` : Modèles de données (Course, Professor, Room, etc.)
  - `views.py` : Vues et API endpoints
  - `templates/` : Templates HTML
    - `schedule.html` : Page de visualisation des emplois du temps
    - `plan.html` : Page de gestion du plan
    - `database.html` : Page de gestion de la base de données

## Utilisation

1. Accédez à l'interface d'administration (`/admin`) pour ajouter des cours, professeurs et salles
2. Utilisez la page "Plan" pour créer les emplois du temps
3. Visualisez les emplois du temps dans la page principale
4. Gérez la base de données dans la page dédiée

## Technologies utilisées

- Django 5.1.4
- Bootstrap 5
- jQuery
- HTML5 Drag and Drop API
