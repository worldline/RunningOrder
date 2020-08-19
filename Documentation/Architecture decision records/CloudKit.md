# CloudKit
#ADR

## Introduction
Nous avons besoin pour l’application Running Order de pouvoir synchroniser en temps réel entre les postes de toute l’équipe toutes les informations du Running Order.
Il faut pouvoir de manière simple ajouter des stories, les modifier et de les lire lors des tests ou de la démo.
## Arguments
- Pas besoin de serveur => gérer par la plateforme 
- Innovant => apprendre à utiliser cette techno
- Intégré à nos outils Xcode
- Gère la synchronisation avec des notifications push silencieuses
- Pas de compte utilisateur à gérer : compte icloud
- Scalable en fonction des utilisateurs
## Alternatives considérées
* Serveurs chez Worldline
	* Problème d’accès par internet : pas d’accès externe
* Continuer sur confluence
	* API Confluence à explorer
	* Etude de faisabilité nécessaire
	* Pas innovant
* CloudKit avec CoreData