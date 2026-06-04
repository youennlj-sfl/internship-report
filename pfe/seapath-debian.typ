#import "@preview/fletcher:0.5.8"
#import "@preview/zebraw:0.6.3": zebraw

= Vulnérabilités sur SEAPATH Debian <chapter:debian>
Comme indiqué dans le @chapter:context:seapath:generation, SEAPATH est décliné en plusieurs versions et leurs images sont complètement différentes. Ainsi, il ne suffit pas d'analyser les vulnérabilités sur la version Yocto : il faut aussi faire les autres. Dans le cadre de ce stage, nous avons également mis en place la détection des vulnérabilités sur la version Debian. Cette version étant très différente de Yocto, il a fallu utiliser d'autres approches.

== Approches de détection
La version Debian de SEAPATH utilise l'ouil _FAI_ (Fully Automatic Installation) @fai-project-homepage pour construire les images. Cet outil permet de générer des supports d'installations Linux à partir de distributions existantes, contenant des paquets préinstallés et des scripts pour préconfigurer le système. En pratique, SEAPATH s'en sert pour générer des images préinstallées contenant tous les paquets nécessaires (e.g. _ceph_, _corosync_ et autres pour les images cluster, voir @chapter:context:seapath:architecture), avec le partitionnement du disque pré-établi, les fichiers de configuration des paquets déjà copiés et plusieurs scripts à lancer lors de l'installation de l'image sur une machine physique (par exemple pour automatiquement paramétrer les utilisateurs ou bien pour configurer le réseau).

Cette méthode de génération d'image est très pratique car bien plus rapide à écrire qu'une image Yocto : il suffit de décrire la liste des paquets, mettre les fichiers de configuration et écrire quelques scripts bashs, là où avec Yocto il faut complètement décrire comment compiler chaque paquet, comment copier les fichiers, etc. C'est également beaucoup plus rapide à générer car les paquets sont déjà compilés, il faut juste les télécharger depuis les archives des paquets Debian : une image peut être générée en 5 minutes, là où avec Yocto cela peut mettre jusqu'à 4 heures.

Cependant, avec cette manière de faire on ne peut pas générer de @SBOM à partir des sources comme on a fait avec Yocto. On a donc utilisé une approche différente, qui scanne l'image déjà construite. Pour cela, le logiciel @opensource _Syft_ @syft est particulièrement adapté. C'est un outil de génération de @SBOM à partir de plusieurs types de sources : images de @conteneur:pl, fichiers binaires, archives, ou même répertoires complets. C'est ce dernier type de source qui nous intéresse : quand on lance Syft sur la racine d'un système de fichier (usuellement nommé `/`), Syft va analyser tout le système et créer un @SBOM très complet. Ainsi, en utilisant Syft sur la racine d'une image SEAPATH Debian, Syft peut générer un @SBOM contenant tous les composants du système et on pourra détecter les vulnérabilités à l'aide de ce fichier.

== Intégration du générateur de SBOM <chapter:debian:syft>
Il a fallu décider d'où mettre en place Syft dans le processus de construction de l'image. La première solution est tout simplement de déployer une image construite dans une @VM, d'exécuter Syft à l'intérieur puis de récupérer le @SBOM ainsi généré. La mise en place est très simple techniquement, mais elle demande du temps et des ressources pour le déploiement de la @VM. Une seconde solution est de s'insérer dans le processus de génération de l'image, au moment où le système de fichier est finalisé mais avant qu'il ne soit compacté en une image disque, pour lancer Syft dessus. C'est une approche plus complexe car elle demande de comprendre comment fonctionne _FAI_ pour pouvoir rajouter du code au bon moment dans le processus. Cependant elle aura un temps d'exécution bien moindre que la première solution. On a donc décidé de prendre cette voie.

Le processus de génération de l'image est décrit dans la @fig:debian:syft:flowchart : on utilise un script qui s'occupe de préparer l'environnement, de lancer FAI puis de récupérer les images. De son côté, FAI gère ses tâches avec un ordonnencement pré-défini : d'abord la configuration des partitions, puis l'installation des paquets, puis les scripts de configuration. Le moment idéal pour scanner le système de fichiers et générer un @SBOM est à la fin de toutes les tâches mais juste avant la finalisation de l'image. Pour ce faire, on a pris avantage d'une fonctionnalité avancée de FAI : les _hooks_, qui sont des scripts bash que l'on peut insérer avant n'importe quelles tâches (les blocs bleus de la @fig:debian:syft:flowchart). Nous avons donc créé un _hook_ qui s'exécute juste avant la tâche de finalisation pour lancer Syft. Son code simplifié est disponible en @fig:debian:syft:hook.

#figure(
  image("../assets/debian_generate_flowchart.svg", width: 50%),
  caption: [Diagramme de l'exécution de la génération d'image avec FAI],
  placement: auto,
) <fig:debian:syft:flowchart>

#figure(
  zebraw(
    ```bash
    #!/bin/bash
    sbom_dir="/ext/output/sbom"

    mkdir -p "$sbom_dir"

    function scan_rootfs {
        echo "Scanning rootfs at $FAI_ROOT..."
        syft scan "$FAI_ROOT" \
            --source-name "SEAPATH Debian" \
            --source-supplier "SEAPATH using FAI v$FAI_VERSION" \
            --source-version "$SEAPATH_VERSION" \
            -o json=/ext/output/sbom/rootfs.syft.json
    }

    scan_rootfs
    ```,
    hanging-indent: false,
    comment-flag: "#",
    highlight-color: white.transparentize(100%),
    highlight-lines: (
      (8, [`FAI_ROOT` est une variable contenant le chemin vers le système de fichier construit.]),
    ),
  ),
  caption: [Hook de génération de @SBOM avant la tâche de finalisation],
) <fig:debian:syft:hook>

Il a aussi fallu installer le binaire de Syft dans l'environnement de construction de l'image afin que le hook puisse l'utiliser. Enfin, on a modifié le script de génération pour récupérer le @SBOM construit et le stocker à un endroit adéquat.

== Détection des vulnérabilités


== Intégration en CI

== Images de conteneurs
