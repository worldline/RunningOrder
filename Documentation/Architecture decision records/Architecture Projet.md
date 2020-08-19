# Architecture Projet
#ADR

## Introduction
Il existe beaucoup d’architectures logicielles différentes, et au début d’un projet, il est important de choisir une archi adaptée pour éviter des soucis lors du développement :
* Réutilisabilité
* Utilisation simple du Framework principal
* Testing
Le projet utilisant SwiftUI qui est encore très jeune, nous voulions trouver une architecture basée sur ce framework qui utilise principalement des vues contenant des bindings, le tout lié à des objets observés, si besoin de gestion plus complexe.
## Description détaillée
Le code sera découpé en Vues, Modèles et Manager.
### Vues
Notre interface est découpée en vues réutilisables.
Elles peuvent utiliser des `@State`, mais uniquement en `private`
### Modèles
Les structures de données seront des `struct` étendue par des extensions si besoin de conformité à `Identifiable`ou `Codable` ou autre protocol.
⚠️ Une réflexion à lieu pour mettre en place des business rules au sein d’extension des modèles. Cela sera plus détaillé au terme de la réflexion.
### Manager
Il s’agit de classes permettant de gérer les données métier et de les fournir aux vues qui ont besoin de ses données.
Plutôt que d’avoir un `ViewModel` par vue, nous avons un manager par type de donnée, ce qui nous permet de les gérer de manière plus globale.
Le passage de ses manager dans les vues se fait via des `environmentObject`afin de descendre la hiérarchie de manière plus simple et d’être utilisable si besoin.
Ces managers peuvent dépendre directement des services ou autre source de données (persistence locale) pour gérer au mieux les informations disponibles. Ils pourront ainsi gérer du cache mais aussi la sauvegarde, les appels réseaux, …

Cette architecture répond aux besoins suivants :
- Les vues sont réutilisables entre elles, les managers peuvent aussi être utilisés sur toutes les vues les requérant
- Cette architecture est basée sur SwiftUI pour la hiérarchie des vues et sur l’utilisation d’`environmentObject` pour les manager
- Les traitements de données étant isolés, on peut tout à fait mettre en place des tests unitaires simples et efficaces. Les tests UI et le Snapshot testing pourront également être mis à contribution.
## Arguments
- Facile à mettre en place
- Proche du framework cible
- Répond aux besoins présentés
## Alternatives considérées
* Faire du MVVM classique :
Concrètement, on aurait donc un `ViewModel` par vue qui serait alors des `ObservedObject` et on perdrait l’intérêt des `@Binding` et `@State` voir meme des `let` dans les vues. De plus, on aurait un VM même si on en a pas besoin, ce qui alourdirait l’app sans raison.
