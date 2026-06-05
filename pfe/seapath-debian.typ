#import "@preview/fletcher:0.5.8"
#import "@preview/zebraw:0.6.3": zebraw
#import "@preview/silky-report-insa:0.5.2": insa-colors

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

Il a aussi fallu installer le binaire de Syft dans l'environnement de construction de l'image afin que le hook puisse l'utiliser. Enfin, on a modifié le script de lancement pour récupérer le @SBOM construit à la fin et le stocker à un endroit adéquat.

== Détection des vulnérabilités <chapter:debian:grype>
Maintenant que l'on peut générer des @SBOM:pl, on a pu passer à l'étape de détection des vulnérabilités. Pour ce faire, nous avons identifié 2 possibilités : réutiliser _sbom-cve-check_ @sbom-cve-check, comme nous l'avions fait dans la version Yocto au @chapter:yocto, ou bien utiliser _Grype_ @grype-in-production, un outil @opensource complémentaire à Syft qui est développé par la même compagnie, Anchore.

Afin de ne pas avoir à refaire le travail de compréhension et de mise en place d'un nouvel outil, nous avons commencé par essayer d'utiliser sbom-cve-check sur le @SBOM généré par Syft. Cependant, sbom-cve-check ne prend en entrée que des @SBOM:pl au format SPDX3 ou bien au format SPDX2 spécifiquement généré par Yocto. Syft peut exporter dans plusieurs formats, mais ne supporte pas le SPDX 3. Ainsi, il n'est pas possible de directement importer les résultats de Syft dans sbom-cve-check. Nous avons essayé d'utiliser des convertisseurs de @SBOM:pl (par exemple, SPDX2 vers SPDX3), mais ces outils induisent une perte d'information qui réduisent la qualité de la détection de vulnérabilités en plus d'introduire plus de complexité dans le processus.

Afin de rester simple, nous avons donc essayé l'outil Grype. Celui-ci peut directement utiliser le format de sortie natif de Syft et donc dispose des informations les plus complètes possibles. Le résultat était très probant, Grype nous génère une liste des vulnérabilités présentes très complète (voir @fig:debian:grype:table) : elle contient à la fois beaucoup de vulnérabilités mais aussi beaucoup d'informations (versions des paquets corrigées, type de paquet, etc.).

On a pu expliquer ces bons résultat par les informations supplémentaires contenues dans le @SBOM généré par Syft : celui-ci contient le type de distribution, ce qui permet à Grype d'utiliser des données contenues dans les bases spécifiques (dans notre cas, le Debian Security Tracker @debian-security-tracker) : grâce à cela, Grype peut afficher par exemple quand une vulnérabilité ne sera jamais corrigée ("won't fix" dans le résumé de la @fig:debian:grype:table).

#let code-block(code) = block(
  stroke: insa-colors.primary.darken(50%),
  inset: 6pt,
  radius: 4pt,
  fill: insa-colors.tertiary.lighten(80%),
  code,
)

#figure(
  pad(x: -5%, code-block({
    show raw.line.where(number: 1): set text(weight: "bold")
    set text(size: 9.65pt)
    ```
    NAME                 INSTALLED                 FIXED IN          TYPE          VULNERABILITY   SEVERITY    EPSS
    linux-kernel         6.12.90+deb13.1-rt-amd64  *6.18.29, 7.0.6   linux-kernel  CVE-2026-43500  High        43.5%
    openssh-client       1:10.0p1-7+deb13u4                          deb           CVE-2020-15778  Negligible  64.3%
    openssh-server       1:10.0p1-7+deb13u4                          deb           CVE-2020-15778  Negligible  64.3%
    openssh-sftp-server  1:10.0p1-7+deb13u4                          deb           CVE-2020-15778  Negligible  64.3%
    libsubid5            1:4.17.4-2                (won't fix)       deb           CVE-2024-56433  Low         6.0%
    login.defs           1:4.17.4-2                (won't fix)       deb           CVE-2024-56433  Low         6.0%
    linux-kernel         6.12.90+deb13.1-rt-amd64                    linux-kernel  CVE-2022-3646   Medium      0.1%
    stdlib               go1.24.4                  1.23.12, *1.24.6  go-module     CVE-2025-47907  High        < 0.1%
    ...
    ```
  })),
  kind: image,
  caption: [Extrait du résumé de l'exécution de Grype],
) <fig:debian:grype:table>

Afin d'estimer si les vulnérabilités remontées étaient cohérentes, nous avons utilisé VulnScout qui est capable d'interpréter les fichiers de résultat de Grype via son outil de scan intégré. Nous avons pris avantage de cette capacité en faisant un léger changement dans le code (voir @chapter:vulnscout:seapath-analysis), ce qui nous a permi de voir toutes les vulnérabilités dans VulnScout. Nous avons survolé les plus importantes, et il ne semble pas y avoir de faux positifs : comme indiqué plus haut, Grype se sert directement du traqueur de sécurité de Debian, donc les données sont très précises.

Tout comme pour SEAPATH Yocto, il n'est pas dans le cadre du stage de corriger les vulnérabilités détectées, pour les mêmes raisons évoquées à la fin du @chapter:yocto:cve-analysis. Nous en sommes donc restés là pour l'analyse des vulnérabilités.

== Intégration en CI
De la même manière que pour SEAPATH Yocto (@chapter:yocto:ci), il a fallu intégrer notre processus de détection des vulnérabilités dans l'@CI:long. Il existait déjà un pipeline de construction des images qui appelle le script évoqué dans le @chapter:debian:syft : comme nous avons déjà modifié ce script pour récupérer les @SBOM:pl générés, il ne reste plus qu'à lancer Grype pour détecter les vulnérabilités et VulnScout pour générer les rapports.

Le lancement de Grype se fait en quelques lignes de commandes tandis que celui de VulnScout est presque identique à ce qu'on a fait sur Yocto (@chapter:yocto:ci:cve-check). La subtilité est dans la gestion du cache de Grype : en effet, l'outil télécharge toutes ses données avant de faire la détection. Cela peut prendre plusieurs minutes lorsqu'on part de rien. Afin de ne pas prendre ce temps à chaque lancement de la @CI, mais aussi pour éviter de surcharger inutilement les serveurs de Grype, nous avons fait en sorte de conserver la base de données entre les exécutions de la @CI. Cependant, pour ce pipeline, nous n'utilisons pas de machine dédiée mais les _runners_ publiques de GitHub Actions. Conserver des données entre les exécutions de la @CI n'est plus aussi simple que de les stocker dans un répertoire spécifique, il faut utiliser le système de cache spécifique à GitHub Actions, en prenant garde à ne sauvegarder le cache que si c'est nécessaire, donc uniquement si il y a eu des mises à jour dans la base de données de Grype. Une version simplifiée des étapes du pipeline responsable du cache est présentée en fig @fig:debian:ci:cache-workflow.

De plus, tout comme sur SEAPATH Yocto, nous avons aussi ajouté un pipeline qui s'exécute automatiquement tous les jours pour détecter les nouvelles vulnérabilités, avec le même principe qu'expliqué dans le @chapter:yocto:ci:cve-check : on ne reconstruit pas l'image à chaque fois, on va juste réutiliser le @SBOM du dernier pipeline de construction.

La @PR:long #footnote[@PR ajoutant le pipeline de détection de vulnérabilités : #link("https://github.com/seapath/build_debian_iso/pull/164")] n'a pas encore été intégrée à la base de code car il reste des questions ouvertes sur la gestion des vulnérabilités détectées, notamment quoi faire des vulnérabilités que les mainteneurs de Debian ont marqué comme "won't fix". On aurait pu simplement les ignorer dans Grype, mais cela nous a semblé être une solution un peu rapide et potentiellement problématique en terme de transparence. Ces questions seront discutées lors d'une réunion du @TSC:long.

#figure(
  zebraw(
    ```yml
    - name: Restore Grype cache
      id: grype-cache
      uses: actions/cache/restore@v5
      with:
        key: grype
        path: "/cache/grype"

    - name: Update Grype database
      id: grype-db-update
      run: |
        mkdir -p "/cache/grype"
        # We use Podman here since with Docker the generated cache files
        # are root owned, causing permission issues when saving to cache.
        update_res=$(podman run --rm -v "/cache/grype:/.cache/grype/db:Z" \
          anchore/grype:v0.111.1 db update )
        echo $update_res
        if [ "$update_res" == "No vulnerability database update available" ]; then
          echo "db-updated=false" >> "$GITHUB_OUTPUT"
        else
          echo "db-updated=true" >> "$GITHUB_OUTPUT"
        fi

    - name: Run Grype on SBOMs
      ...

    - name: Save Grype cache
      if: "${{ always() && steps.grype-db-update.outputs.db-updated == 'true' }}"
      uses: actions/cache/save@v5
      with:
        key: ${{ steps.grype-cache.outputs.cache-primary-key }}
        path: "/cache/grype"
    ```,
    hanging-indent: false,
    comment-flag: "#",
    highlight-color: white.transparentize(100%),
    highlight-lines: (
      (6, [Nous téléchargeons le cache si une précédente exécution de la @CI l'a sauvegardé.]),
      (
        15,
        [Nous demandons explicitement à Grype de mettre à jour sa base de données. Ainsi, nous pouvons savoir si elle était à jour et ré-exporter le cache si nécessaire.],
      ),
      (
        31,
        [Si la base de données a été mise à jour durant cette exécution (ligne 15), nous ré-exportons le cache.],
      ),
    ),
  ),
  caption: [Code du pipeline responsable du cache de Grype],
  placement: auto,
) <fig:debian:ci:cache-workflow>

== Images de conteneurs
Une des évolutions prévues pour une future version de SEAPATH est l'ajout du support des @conteneur:pl, entre autre pour pouvoir utiliser _cephadm_, un outil permettant d'administrer des clusters Ceph @ceph qui repose sur l'utilisation de conteneurs. En pratique, lorsqu'on veut lancer un conteneur avec, par exemple, Podman @podman, il suffit d'une simple commande `podman run` : celle-ci va s'occuper de télécharger l'image voulue depuis Internet si elle n'est pas déjà présente dans le registre local, puis elle va créer et lancer le conteneur. Cependant, un cluster SEAPATH est en général isolé d'Internet par question de sécurité. Ainsi, il n'est pas possible de télécharger l'image d'un conteneur (voir l'erreur dans la @fig:debian:containers:pull-error).

#figure(
  code-block(```bash
  $ podman run --rm quay.io/ceph/ceph:v20.2.0
  Trying to pull quay.io/ceph/ceph:v20.2.0...
  Error: unable to copy from source docker://quay.io/ceph/ceph:v20.2.0: initializing source docker://quay.io/ceph/ceph:v20.2.0: pinging container registry quay.io: Get "https://quay.io/v2/": dial tcp: lookup quay.io: Temporary failure in name resolution
  ```),
  caption: [Erreur lors du lancement d'un conteneur sans connexion Internet],
  kind: image,
) <fig:debian:containers:pull-error>

La solution retenue par les mainteneurs de SEAPATH pour la version Debian est de télécharger les images de conteneurs dans des archives avant la construction de l'image de SEAPATH, puis ensuite de les charger dans le registre local. Florent Carli, le mainteneur de SEAPATH chez RTE International, avait préalablement implémenté cette logique dans un seul des 2 scripts de lancement : `build_iso.sh`. Celui dont on a parlé dans le @chapter:debian:syft s'appelle `generate_seapath_image.sh` et ne dispose pas du code pour gérer les images de conteneurs. Il a donc fallu retravailler ce script pour permettre la gestion des images de conteneurs.

Enfin, une fois que les conteneurs sont intégrés dans l'image SEAPATH, il faut aussi les utiliser dans notre détection de vulnérabilités car ils font partie de notre pile logicielle. Nous avons donc modifié le _hook_ FAI de la @fig:debian:syft:hook pour également scanner les images de conteneurs et générer des @SBOM:pl, qu'on exporte en même temps que celui du système de fichier. On a également modifié le pipeline pour donner tous ces @SBOM:pl à Grype et à VulnScout afin d'avoir une vue des vulnérabilités la plus complète possible.
