= Introduction <chapter:introduction>

Aujourd’hui, les infrastructures énergétiques évoluent rapidement, largement influencées par l’adoption croissante des énergies renouvelables, qui représentent désormais 15,8% de la consommation d’énergie primaire en 2025, par rapport à seulement 9,6% onze ans auparavant @sdes-2025. Cette transition entraîne un changement majeur dans la gestion des réseaux électriques, passant d’un modèle
traditionnellement statique et unidirectionnel à un paradigme plus dynamique et imprévisible.

Au cœur de cette mutation se trouve la nécessité de repenser les systèmes de contrôle et d’automatisation, notamment en migrant des dispositifs physiques appelés @ied vers des versions virtuelles. Cette transition s’avère indispensable pour surmonter les défis associés aux coûts élevés d’exploitation et de déploiement des équipements physiques, ainsi qu’aux cycles de développement et de mise à jour complexes et chronophages.

Pour répondre à ces enjeux, une approche axée sur la virtualisation des fonctionnalités, indépendamment des contraintes matérielles, s’impose. Dans cette perspective, le projet SEAPATH @seapath, lancé par la Linux Foundation Energy, émerge comme une initiative majeure visant à concevoir une plateforme open-source et temps réel permettant d’exécuter la virtualisation des @ied:pl provenant de divers fournisseurs du secteur énergétique.

Les réseaux électriques faisant partie des infrastructures critiques d'un pays, il y a un très grand enjeu de sécurité : les acteurs du secteur de l'énergie doivent pouvoir suivre toutes les vulnérabilités qui affectent les logiciels utilisés pour gérer leur réseau.

Ce projet de fin d'études a principalement porté sur le monitoring des vulnérabilités logicielles de deux versions de SEAPATH, en se concentrant spécifiquement sur la génération de @SBOM:pl, l'analyse des vulnérabilités critiques et l'intégration en @CI. Il a mené à de nombreuses contributions dans plusieurs projets @opensource dont VulnScout @vulnscout, un outil spécifiquement créé pour évaluer les vulnérabilités.

Après avoir posé le contexte du stage au @chapter:context, nous aborderons l'étude des vulnérabilités sur la version Yocto de SEAPATH au @chapter:yocto, avec une vue d'ensemble détaillée des travaux d'intégration en @CI dans le @chapter:yocto:ci. Nous étudierons ensuite la mise en place de détection de vulnérabilités sur la version Debian @debian de SEAPATH au @chapter:debian. Enfin, le @chapter:vulnscout détaillera l'utilisation de VulnScout ainsi que les contributions apportées au projet.

/*Ce projet de fin d’études a principalement ciblé la certification de SEAPATH, en se concentrant spécifiquement sur la mesure de la latence et la manipulation des VMs. Pour ce faire, une série de
tests a été élaborée et exécutée au sein d’une chaîne d’intégration continue.

Apres avoir posé le contexte du stage en section 2, nous aborderons l’implémentation des tests de
latence avec la question de la synchronisation temporelle en section 3. Nous étudierons ensuite en
section 4 la création de l’outillage permettant le calcul de la latence réseau. La section 5 présentera
l’intégration des travaux dans la CI. Une ouverture sur la création d’un "openlab" est discuté en
section 6.3.*/

= Cadre et contexte du stage <chapter:context>

#let sfl = box("Savoir-faire Linux")

== #sfl
=== Présentation de #sfl

#sfl est une entreprise d’origine québécoise dont la principale activité est l’intégration de systèmes Linux @linux-introduction ou d’applications sous Linux. Fondée en 1999 à Montréal, où l’entreprise possède son siège social, elle s’est depuis étendue en France. Depuis 2018, c’est à Rennes que la branche française est installée. Proche du parc Oberthür, c’est dans ces bureaux que s’est déroulé ce stage.

Le bureau rennais est orienté Linux embarqué. Les projets portent sur l’intégration de @distribution:pl Linux ou d’applications sur des produits clients, de l’audit ou encore du développement.

L’entreprise participe aussi activement à la communauté open source, via des contributions à des projets et la participation à de nombreux salons. Enfin, plusieurs logiciels libres, comme Jami @jami, SEAPATH @seapath ou encore VulnScout @vulnscout, sont développés et maintenus par #sfl.

=== Outils et méthodes de travail <chapter:context:sfl:tooling>
Chaque projet chez #sfl s’appuie sur un ensemble d’outils communs pour maintenir une organisation et une qualité de travail optimales. L’objectif est de détecter rapidement les erreurs et d’automatiser les tâches répétitives.

Pour collaborer efficacement, chaque projet est versionné dans des dépôts _Git_ @git. Chez #sfl, l’application _Gerrit_ @gerrit héberge les dépôts, et met en place un système de revue de code. Chaque commit est vérifié par une (ou plusieurs, selon les projets) autres personnes de l'entreprise, ce qui permet de détecter les erreurs ou de proposer de meilleures approches. Lorsque la personne faisant la revue demande ou propose des modifications, le commit en question doit être modifié, afin de garder un historique parfaitement cohérent. Un commit n’est ajouté dans la branche principale d’un dépôt que lorsque la revue est validée. Certains projets @opensource comme SEAPATH ou VulnScout utilisent plutôt _GitHub_ @github, où le même principe de revue de code est appliqué.

L’intégration continue, ou @CI, ajoute un deuxième filet de sécurité. C’est un ensemble de services automatisés pour compiler et tester du code. L’entreprise utilise l’application Jenkins @jenkins pour les projets utilisant _Gerrit_, ou bien le système _GitHub Actions_ @github-actions pour les autres. À chaque nouveau commit ou @PR, un cycle de @CI commence et va effectuer diverses tâches : compiler le projet, lancer des tests, etc. Cela augmente les chances de détecter une régression, de rapidement régler les bugs, et d’éviter une longue investigation de problème plus tard. Sur des projets applicatifs, des tests d’analyse statique du code permettent aussi de maintenir une bonne qualité de code.

En parallèle, #sfl développe et maintient plusieurs outils facilitant le développement des projets. Ces outils sont utilisés en interne mais sont également disponibles en @opensource. Parmi les plus importants, on peut noter :
- _CQFD_ @cqfd, permet de facilement lancer des commandes dans un @conteneur ayant accès au dossier courant. Il est notamment utilisé pour configurer et utiliser le projet Yocto avec ses nombreuses dépendances, peu importe l’environnement d’exécution.
- _Cukinia_ @cukinia, un outil de test pour vérifier la configuration d’un système Linux au runtime : présence d’utilisateurs, de partitions de système de fichier, de programmes, de périphériques... Il permet d’appliquer une méthodologie de développement piloté par les tests pour l’intégration d’un système Linux complet.

Concernant l'organisation interne, les informations importantes sont diffusées par e-mails. Pour le quotidien, une instance _Mattermost_ est utilisée comme plateforme de communication instantanée. La majorité du travail est faite en présentiel, mais il arrive de faire des réunions par visioconférence, notamment avec l'équipe de Montréal, notamment lorsque les deux bureaux travaillent sur des projets communs.

== Le projet SEAPATH
=== Le réseau électrique
Le réseau électrique constitue l’ensemble des infrastructures permettant d’acheminer l’énergie électrique depuis les lieux de production vers les consommateurs. Il est constitué de divers points de connexion appelés *nœuds*, qui correspondent aux *postes électriques*. Ces postes se divisent généralement en deux catégories : les postes d’interconnexion, qui aiguillent les lignes de même tension, permettant par exemple d’isoler une ligne défaillante ou à des fins de réorganisation du réseau. On a aussi les *postes de transformation*, qui ajustent la tension en l’élevant (par exemple, à la sortie des centrales) ou en l’abaissant (pour la distribution vers les consommateurs).

Dans un poste de transformation on trouve de nombreux équipements (@fig:context:substation-model), certains destinés à la transformation de la tension tels que le *transformateur de puissance* (9) tandis que d'autres sont là pour protéger et isoler les composants, comme les *sectionneurs* (5) ou les *disjoncteurs* (6).

#figure(
  image("../assets/Electrical_substation_model_(side-view).png"),
  caption: [Vue en coupe d'une sous-station électrique @shigeru-electrical-substation],
  placement: auto,
) <fig:context:substation-model>

Le *bâtiment de contrôle* (10) abrite des équipement assurant la gestion de ces composants. Les systèmes de contrôle et d’automatisation des réseaux électriques jouent un rôle crucial dans cette gestion, en intégrant des technologies avancées pour superviser et optimiser la distribution de l’énergie. Parmi ces technologies, les @ied:pl occupent une place centrale.

Un @ied est un élément clé d’un poste électrique, remplaçant les relais traditionnels et autres appareils par des dispositifs dotés de microprocesseurs et de communications avancées. Il protège les lignes, génère des événements, gère les régulateurs de tension, et collecte des données critiques, permettant une prise de décision rapide pour la protection et la restauration du réseau. @mcdonald2007substation

=== Les limites du modèle actuel
Aujourd’hui, en raison principalement de l’essor des énergies renouvelables, intégrant ainsi des sources d’énergie aux moyennes et basses tensions, on passe d’un modèle statique et unidirectionnel du réseau vers un modèle beaucoup plus dynamique et imprévisible, qu’on appelle @smart-grid.

Le cycle de développement des systèmes de contrôle et d’automatisation des réseaux électriques est donc en pleine transformation. Il est nécessaire de porter le code développé pour les @ied:pl physiques vers des @ied:pl virtuels. Les dispositifs physiques ont des coûts opérationnels et de déploiement élevés, avec des cycles de développement, de test et de mise à jour complexes et longs. Pour relever ces défis, un tournant dans la conception des systèmes s’impose. La virtualisation des fonctionnalités, en se détachant des implémentations dépendantes du matériel, facilite la transition d’un réseau électrique traditionnel vers une smart grid orienté logiciel @en15249362.

C’est dans ce tournant que s’inscrit le projet SEAPATH (Software Enabled Automation Platform and Artifacts), une initiative de la Linux Foundation Energy qui vise à développer une plateforme *@opensource* et *@RT:long* qui permettra d’exécuter la *virtualisation d’@ied:pl* provenant de divers fournisseurs du secteur de l’énergie avec de fortes contraintes de *fiabilité et disponibilité*. Les co-mainteneurs du projet sont #sfl et RTE international.

=== La virtualisation <chapter:context:seapath:virt>
La *virtualisation* regroupe les techniques matérielles et/ou logicielles qui permettent à une seule machine d’exécuter plusieurs systèmes d’exploitation et/ou applications de manière isolée, comme s’ils tournaient sur des machines distinctes. Pour ce faire, on utilise un @hyperviseur. Celui-ci agit comme une couche intermédiaire entre le matériel de la machine hôte et les systèmes d’exploitation invités, souvent appelés @VM:pl.

La virtualisation offre de nombreux avantages :
- Efficacité des ressources : la virtualisation permet d’exécuter plusieurs applications sur une seule machine, optimisant l’utilisation du matériel.
- Déploiement rapide : la mise en place des @VM:pl est plus rapide que l’installation dematériel, surtout avec l’automatisation.

SEAPATH utilise le module noyau KVM @kivity2007kvm, permettant de convertir l’OS en un @hyperviseur dit "de type 1", ce qui signifie que les @VM:pl s'exécutent directement sur le matériel, sans traverser le système d'exploitation hôte. De plus, SEAPATH utilise QEMU @qemu en conjonction avec KVM. Dans cette configuration, KVM se charge des interactions avec le matériel tandis que QEMU émule les périphériques et gère l’environnement de la @VM. Enfin, libvirt @libvirt est utilisé pour gérer et orchestrer les @VM:pl.

=== Architecture de SEAPATH <chapter:context:seapath:architecture>
L'achitecture générale de SEAPATH est présentée en @fig:context:seapath-stack :
#figure(
  image("../assets/seapath_technology_stack.png", width: 80%),
  caption: [Architecture générale de SEAPATH],
  placement: none,
) <fig:context:seapath-stack>

L’@hyperviseur tourne sur un @noyau Linux @RT, rendant préemptive la majeure partie du code du @noyau et en particulier les sections critiques et les gestionnaires d’interruptions. Il modifie par ailleurs certains mécanismes pour réduire les temps de latence induits par le fonctionnement du système, qui sont critiques dans notre contexte.

En plus de la couche de virtualisation décrite au @chapter:context:seapath:virt, SEAPATH utilise plusieurs outils permettant la mise en place d'un cluster pour avoir de la haute disponibilité :
- _Open vSwitch_ @openvswitch, une implémentation logicielle d’un switch ethernet.
- _Pacemaker_ @pacemaker, chargé de démarrer, arrêter et superviser les ressources du cluster.
- _Corosync_ @corosync, un système de communication de groupe.
- _Ceph_ @ceph, un solution de stockage distribué.
Lorsque SEAPATH est installé sur plusieurs @hyperviseur:pl, ces outils orchestrent le déploiement des @VM:pl sur les machines adéquates et permettent de les déplacer en cas de besoin, mais surtout de les redémarrer sur une autre machine si la leur tombe en panne.

=== Génération et déploiement <chapter:context:seapath:generation>
Concrètement, SEAPATH se présente à la manière d'une @distribution Linux : les utilisateurs disposent d'images disques pour installer SEAPATH sur leurs machines. SEAPATH se décline en plusieurs versions, chacune générant ces images de manières différentes. Nous nous concentrerons sur 2 d'entre elles :
- la version "Yocto" @yoctoproject construit l'image disque _from scratch_ : toute la distribution est décrite dans du code. Tous les paquets et librairies nécessaires (e.g. Corosync, libvirt, etc.) possèdent leurs "recettes" (écrites dans le langage BitBake propre à Yocto) qui détaillent comment télécharger les codes sources, les construire, les empaqueter, etc.
- la version "Debian" @debian se base sur la distribution du même nom. On décrit simplement au système de build la liste des paquets à installer, quelques fichiers de configuration et on s'aide de scripts pour automatiser toute la génération.

Enfin, on utilise Ansible @hochstein2017ansible, un outil d’automatisation, pour configurer divers éléments de l’infrastructure déployée en utilisant des _playbooks_. Ces playbooks définissent l’état souhaité de l’infrastructure sous forme de code, décrivant les tâches à exécuter sur les différents nœuds du système, également appelés "hosts". Les nœuds sont décrits dans un _inventaire_ qui est fourni au playbook.

//== Objectifs du PFE
=== Aspects de cybersécurité

Actuellement, le projet SEAPATH ne propose pas de moyen simple à ses utilisateurs pour suivre les vulnérabilités logicielles présentes dans le système. Les mainteneurs eux-même n'ont pas connaissance de celles-ci, ce qui est un grave problème, SEAPATH étant destiné à terme à être utilisé dans des infrastructures critiques où une vulnérabilité grave peut priver d'électricité des millions de foyers et causer de graves dommages.

De plus, le monde de la cybersécurité s'accélère depuis quelques années. Les vulnérabilités découvertes sont de plus en plus nombreuses, et les organisations étatiques et même internationales commencent à légiférer pour obliger les fournisseurs de solutions numériques à se préoccuper de ces questions. Par exemple, l'Union Européenne a créé le Cyber Resilience Act (CRA) @cra-article qui prendra effet en 2027, d'où l'intérêt pour les mainteneurs de SEAPATH d'agir maintenant. Le stage effectué s'inscrit dans ce contexte, pour permettre à SEAPATH de se doter des outils nécessaires pour suivre les vulnérabilités potentiellement dangereuses.

// == Le projet VulnScout
