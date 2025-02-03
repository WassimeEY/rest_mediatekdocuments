<h1>Présentation de l'API</h1>
Cette API, écrite en PHP, est basée sur la structure de l'API présentée dans le dépôt suivant :<br>
https://github.com/CNED-SLAM/rest_chocolatein<br>
Le readme de ce dépôt présente la structure de la base de l'API (rôle de chaque fichier) et comment l'exploiter.<br>
Les ajouts faits dans cette API ne concernent que les fichiers '.env' (qui contient les données sensibles d'authentification et d'accès à la BDD) et 'MyAccessBDD.php' (dans lequel de nouvelles fonctions ont été ajoutées pour répondre aux demandes de l'application).<br>
Cette API permet d'exécuter des requêtes SQL sur la BDD Mediatek86 créée avec le SGBDR MySQL.<br>
Elle est accessible via une authentification "basique" (avec login="admin", pwd="adminpwd").<br>
Sa vocation actuelle est de répondre aux demandes de l'application MediaTekDocuments, mise en ligne sur le dépôt :<br>
https://github.com/CNED-SLAM/MediaTekDocuments

<h1>Installation de l'API en local</h1>
Pour tester l'API REST en local, voici le mode opératoire (similaire à celui donné dans le dépôt d'API de base) :
<ul>
   <li>Installer les outils nécessaires (WampServer ou équivalent, NetBeans ou équivalent pour gérer l'API dans un IDE, Postman pour les tests).</li>
   <li>Télécharger le zip du code de l'API et le dézipper dans le dossier www de wampserver (renommer le dossier en "rest_mediatekdocuments", donc en enlevant "_master").</li>
   <li>Si 'Composer' n'est pas installé, le télécharger avec ce lien et l'insstaller : https://getcomposer.org/Composer-Setup.exe </li>
   <li>Dans une fenêtre de commandes ouverte en mode admin, aller dans le dossier de l'API et taper 'composer install' puis valider pour recréer le vendor.</li>
   <li>Récupérer le script metiak86.sql en racine du projet puis, avec phpMyAdmin, créer la BDD mediatek86 et, dans cette BDD, exécuter le script pour remplir la BDD.</li>
   <li>Ouvrir l'API dans NetBeans pour pouvoir analyser le code et le faire évoluer suivant les besoins.</li>
   <li>Pour tester l'API avec Postman, ne pas oublier de configurer l'authentification (onglet "Authorization", Type "Basic Auth", Username "admin", Password "adminpwd".</li>
</ul>
<h1>Exploitation de l'API</h1>
Adresse de l'API (en local) : http://localhost/rest_mediatekdocuments/ <br>
Voici les différentes possibilités de sollicitation de l'API, afin d'agir sur la BDD, en ajoutant des informations directement dans l'URL (visible) et éventuellement dans le body (invisible) suivant les besoins : 
<h2>Récupérer un contenu (select)</h2>
Méthode HTTP : <strong>GET</strong><br>
http://localhost/rest_mediatekdocuments/table/champs (champs optionnel)
<ul>
   <li>'table' doit être remplacé par un nom de table (caractères acceptés : alphanumériques et '_')</li>
   <li>'champs' (optionnel) doit être remplacé par la liste des champs (nom/valeur) qui serviront à la recherche (au format json)</li>
</ul>

<h2>Insérer (insert)</h2>
Méthode HTTP : <strong>POST</strong><br>
http://localhost/rest_mediatekdocuments/table <br>
'table' doit être remplacé par un nom de table (caractères acceptés : alphanumériques et '_')<br>
Dans le body (Dans Postman, onglet 'Body', cocher 'x-www-form-urlencoded'), ajouter :<br>
<ul>
   <li>Key : 'champs'</li>
   <li>Value : liste des champs (nom/valeur) qui serviront à l'insertion (au format json)</li>
</ul>

<h2>Modifier (update)</h2>
Méthode HTTP : <strong>PUT</strong><br>
http://localhost/rest_mediatekdocuments/table/id (id optionnel)<br>
<ul>
   <li>'table' doit être remplacé par un nom de table (caractères acceptés : alphanumériques et '_')</li>
   <li>'id' (optionnel) doit être remplacé par l'identifiant de la ligne à modifier (caractères acceptés : alphanumériques)</li>
</ul>
Dans le body (Dans Postman, onglet 'Body', cocher 'x-www-form-urlencoded'), ajouter :<br>
<ul>
   <li>Key : 'champs'</li>
   <li>Value : liste des champs (nom/valeur) qui serviront à la modification (au format json)</li>
</ul>

<h2>Supprimer (delete)</h2>
Méthode HTTP : <strong>DELETE</strong><br>
http://localhost/rest_mediatekdocuments/table/champs (champs optionnel)<br>
<ul>
   <li>'table' doit être remplacé par un nom de table (caractères acceptés : alphanumériques et '_')</li>
   <li> 'champs' (optionnel) doit être remplacé par la liste des champs (nom/valeur) qui serviront déterminer les lignes à supprimer (au format json</li>
</ul>

<h1>Les fonctionnalités ajoutées</h1>
Dans MyAccessBDD, plusieurs fonctions ont été ajoutées pour répondre aux demandes actuelles de l'application C# MediaTekDocuments :<br>
<ul>
   <li><strong>selectTableSimple : </strong>récupère les lignes des tables simples (genre, public, rayon, etat) contenant juste 'id' et 'libelle', dans l'ordre alphabétique sur 'libelle'. Cette fonction est appelée pour  remplir les combos correspondants.</li>
   <li><strong>selectAllLivres : </strong>récupère la liste des livres avec les informations correspondantes (d'où nécessité de jointures).</li>
   <li><strong>selectAllDvd : </strong>même chose pour les dvd.</li>
   <li><strong>selectAllRevues : </strong>même chose pour les revues.</li>
   <li><strong>selectExemplairesRevue : </strong>récupère les exemplaires d'une revue dont l'id sera donné.</li>
</ul>
