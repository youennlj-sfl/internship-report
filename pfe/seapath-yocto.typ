#import "@preview/glossarium:0.5.10": (
  gls, gls-long, gls-longplural, glspl, make-glossary, print-glossary, register-glossary,
)
#import "@preview/zebraw:0.6.3": zebraw
#import "@preview/subpar:0.2.2"
#import "@preview/fletcher:0.5.8"

= Vulnérabilités sur SEAPATH Yocto <chapter:yocto>

La première partie du stage a été consacrée à la recherche et à l'essai des différentes possibilités pour détecter des vulnérabilités dans la version Yocto de SEAPATH. Nous n'allons pas ici analyser le code lui-même pour y trouver des failles : SEAPATH étant une @distribution Linux entière, composée de centaines de composants différents, la surface à analyser est bien trop importante. Toutes les méthodes de détection étudiées prennent une autre approche : elles essaient de faire des liens entre SEAPATH et les bases de données de vulnérabilités connues. Nous allons voir comment. Une fois qu'une solution aura été sélectionnée, nous verrons sa mise en place réelle dans SEAPATH.

== État de l'art <chapter:yocto:sota>
=== Solutions avec @SBOM:short
Comme introduit dans le @chapter:context:seapath:generation, la construction de la @distribution se fait entièrement depuis les sources : aucun binaire opaque n'est inclus dans l'image disque. Cela donne un grand avantage pour la détection des vulnérabilités car on connaît absolument tout ce qui sera inclus dans le système une fois déployé : programmes, librairies, configurations, mais aussi quels fichiers sources ont été compilés, dans quelles versions, etc. Cela nous permet de facilement générer des #gls("SBOM", first: true) très complets. Yocto propose d'ailleurs plusieurs _classes_ pour exporter des @SBOM:pl dans différents formats : SPDX2, SPDX3, OpenVEX ou encore CycloneDX @sbom-study. Un extrait de @SBOM généré par Yocto pour SEAPATH est disponible en @fig:yocto:sota:sbom.

#figure(
  zebraw(
    ```json
    {
      "@context": "https://spdx.org/rdf/3.0.1/spdx-context.jsonld",
      "@graph": [
        {
          "type": "software_Package",
          "software_packageVersion": "20.2.1",
          "name": "ceph",
          "summary": "User space components of the Ceph file system"
          "description": "User space components of the Ceph file system.",
          "externalIdentifier": [{"identifier": "pkg:yocto/meta-seapath/ceph@20.2.1"}, {"identifier": "cpe:2.3:*:*:ceph_storage_osd:20.2.1:*:*:*:*:*:*:*"}, ...],
        },
        {
          "type": "software_File",
          "name": "usr/lib/ceph/erasure-code/libec_clay.so",
          "verifiedUsing": [{"algorithm": "sha256", "hashValue": "0a323c42c25bf33d08334ac7cd2dda1b10b734f5f07714f9185c6a48db8feee4"}]
        },
        {
          "type": "software_File",
          "software_primaryPurpose": "source",
          "name": "sources/linux-mainline-rt-6.12.89-rt18+git/drivers/net/ipa/data/ipa_data-v5.5.c",
          "verifiedUsing": ...
        },
      ]
    }
    ```,
    lang: false,
    hanging-indent: false,
    comment-flag: "//",
    highlight-lines: (
      6,
      7,
      (
        10,
        emph[
          Identifiants du paquet aux formats standard dans l'industrie : @CPE et @PURL.
        ],
      ),
      (
        16,
        color.white.transparentize(100%),
        emph[Un fichier présent dans l'image disque, ici une librairie compilée.],
      ),
      (
        22,
        color.white.transparentize(100%),
        emph[Un fichier source ayant servi à la compilation d'un paquet, ici un pilote inclus dans le @noyau Linux.],
      ),
    ),
  ),
  caption: [Extrait d'un @SBOM:short de SEAPATH au format SPDX3, simplifié et annoté],
  placement: auto,
) <fig:yocto:sota:sbom>

// test

Parmi les solutions trouvées lors de l'état de l'Art, plusieurs d'entre elles se basent uniquement sur ce SBOM pour trouver des vulnérabilités dans SEAPATH. C'est le cas par exemple de _Grype_ @grype-in-production ou de _sbom-cve-check_ @sbom-cve-check. Ces outils vont utiliser les champs d'identification des paquets (lignes surlignées en rouge dans la @fig:yocto:sota:sbom) pour chercher les vulnérabilités associées dans des bases de données en ligne. Il en existe plusieurs :
- la NVD (National Vulnerability Database) @nist-nvd, maintenue par le NIST, l'institut États-Unien des normes et de la technologie ;
- la liste du CVE#emoji.tm Program @cvelistv5, contenant des vulnérabilités de nombreuses autres bases de données ;
- la liste des vulnérabilités propres au @noyau Linux @linux-vulns, gérée par les mainteneurs du noyau ;
- les bases de données propres aux grandes distributions Linux : le traqueur de Debian @debian-security-tracker, celui de RedHat @redhat-security-updates, etc.

Certaines de ces bases de données associent des identifiants #gls("CPE", first: true, plural: true) à leurs vulnérabilités : _Grype_ va les faire correspondre aux @CPE:pl présentes dans les SBOM pour dire si une vulnérabilité est présente ou non dans l'image. L'outil _sbom-cve-check_ va plutôt se reposer sur les versions fournies dans le SBOM pour voir si une vulnérabilité est exploitable.

=== Solutions sans @SBOM:short <chapter:yocto:sota:nosbom>
Une autre approche pour trouver les vulnérabilités a également été étudiée : le projet Yocto propose une classe dédiée, nommée `cve-check` @yocto-cve-check, qui va effectuer la recherche de vulnérabilités pendant le processus de construction de l'image, en bénéficiant de tout le contexte nécessaire : nom et versions des paquets, liste des fichiers sources, etc. En activant cette classe, un fichier OpenVEX est créé à la fin du build, contenant les vulnérabilités détectées.

Enfin, d'autres membres de Savoir-faire Linux ont développés des classes (au sein d'un outil nommé `meta-vulnscout` @meta-vulnscout) permettant d'améliorer `cve-check` pour les vulnérabilités liées au @noyau Linux : de base, cet outil utilise uniquement sur la base de données du NIST @nist-nvd qui n'est pas complète pour le @noyau. Ainsi, les nouvelles classes de `meta-vulnscout` vont utiliser des bases de données supplémentaires pour récupérer plus de vulnérabilités, mais aussi filtrer celles non applicables en regardant la version du @noyau et les fichiers sources compilés ou non.

== Comparaison des solutions
Après avoir établi une liste de solutions potentielles dans le @chapter:yocto:sota, il a fallu sélectionner celle la plus adaptée pour SEAPATH. Pour cela, chacune de ces solutions a été testée pour en tirer des évaluations quantitatives : on a mesuré le *nombre total de vulnérabilités* remontées, et on a évalué le nombre de *faux positifs* (vulnérabilités annoncées comme applicables par les outils mais qui ne le sont pas) et de *faux négatifs* (vulnérabilités non reportées par les outils).

=== Méthodologie

On a créé 4 scénarios de test qu'on a lancé sur une même version de SEAPATH pour pouvoir comparer les résultats :
- scénario "basique" utilisant uniquement sur la classe `cve-check` de Yocto ;
- scénario "léger" utilisant `cve-check` avec 2 des 3 classes de `meta-vulnscout` ;
  - Dans ce scénario, on n'a pas inclus la classe filtrant les vulnérabilités selon les fichiers sources compilés du @noyau, à la demande de collègues qui voulaient estimer la performance de cette classe.
- scénario "complet" utilisant `cve-check` avec toutes les classes de `meta-vulnscout` ;
- scénario "externe" utilisant l'outil _sbom-cve-check_ avec les @SBOM:pl générés par Yocto.

On notera ici l'absence d'un scénario utilisant Grype : en effet, lors des tests préliminaires pour mettre en place ces outils, on a remarqué une quantité flagrante de faux positifs. Par conception, Grype est un outil fait pour fonctionner sur des distribution Linux "connues" : il va chercher dans les bases de données adaptées selon la distribution et se base sur les @CPE:pl, qui contiennent également des indications de distributions. SEAPATH Yocto étant une distribution "maison", Grype fonctionne moins bien. On l'a donc retiré de notre liste d'outils à tester.

#include "yocto-cve-results.typ"

== Mise en place de l'outil
Une fois la solution choisie, il a fallu l'intégrer de manière permanente dans SEAPATH. `sbom-cve-check` étant un outil externe, les seuls changements impliquées dans la base de code Yocto concernent la génération des @SBOM. En effet, pour avoir les meilleurs résultats, `sbom-cve-check` requiert :
- un fichier SPDX contenant les contenus "classiques" générés par Yocto : liste des paquets, recettes et autres, mais également la liste des fichiers sources compilés pour le noyau Linux ;
- un fichier OpenVEX contenant les annotations pour les vulnérabilités déjà connues.

Il existe des classes pré-faites pour cela dans Yocto, ainsi il n'y a pas eu de difficulté pour écrire la configuration pour générer ces fichiers, en se basant sur la documentation du projet Yocto @yoctoproject. La @fig:yocto:implem:bitbake montre le code qu'il a fallu rajouter.

#figure(
  zebraw(
    ```BitBake
    inherit create-spdx-2.2
    inherit vex

    SPDX_INCLUDE_COMPILED_SOURCES:pn-linux-mainline-rt = "1"
    ```,
    hanging-indent: false,
    highlight-color: color.white.transparentize(100%),
    highlight-lines: (
      (1, [Génère des fichiers SPDX pour tous les paquets inclus dans l'image générée]),
      (2, [Génère un fichier OpenVEX contenant les annotations de vulnérabilités déjà connues]),
      (
        4,
        [Indique à la classe _create-spdx-2.2_ d'inclure la liste des sources compilées dans le fichier SPDX, *uniquement* pour le package _linux-mainline-rt_],
      ),
    ),
    comment-flag: "#",
  ),
  caption: [Paramètres pour générer les fichiers nécessaires à la détection de vulnérabilités],
) <fig:yocto:implem:bitbake>

Pourtant, après essai de cette solution, la liste des sources du @noyau n'était pas exportée dans le fichier SPDX. La documentation de Yocto n'étant pas plus détaillée sur la question, une recherche approfondie dans le code source de Yocto a été menée pour comprendre comment cette liste est générée.

On a rapidement compris que le problème provenait de la recette utilisée pour générer le @noyau Linux. Yocto propose plusieurs recettes pré-faites pour cela afin de faciliter la création de projets avec Yocto, une recette de @noyau étant assez complexe à écrire. Cependant, SEAPATH a divergé sur une recette maison car il y a des besoins spécifiques : comme expliqué au @chapter:context:seapath:architecture, il faut un noyau @RT:long avec des configurations particulières. Les deux recettes ont divergé il y a tellement longtemps (le premier commit de celle de SEAPATH date d'octobre 2020#footnote[Commit à l'origine de la recette du noyau Linux de SEAPATH : #link("https://github.com/SEAPATH/meta-seapath/commit/737b85673d78e37371cff5d9589190995c03ebbf")]) que leurs codes sont très différents et donc particulièrement difficiles à comparer.

Finalement, après comparaison en profondeur des fichiers générés par la construction du noyau par les deux recettes, il est apparu que le processus de build de SEAPATH ne générait pas certains fichiers de débogage utilisés par Yocto pour trouver la liste des fichiers sources. On est ainsi arrivé à la racine du problème : il manquait deux options dans la configuration même du @noyau Linux. Après ajout de celles-ci (cf. @fig:yocto:implem:kernel-cfg), les fichiers sources sont bien listés dans le fichier SPDX généré.

#figure(
  zebraw(
    ```ini
    # This allows to get the debug symbols of the kernel and know which files have been compiled. It has been pulled from https://git.yoctoproject.org/yocto-kernel-cache/tree/features/debug/debug-kernel.cfg?h=yocto-6.12
    CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
    CONFIG_DEBUG_INFO=y
    ```,
    lang: false,
  ),
  caption: [Fichier de configuration rajouté à la recette du @noyau Linux],
) <fig:yocto:implem:kernel-cfg>


== Analyse des vulnérabilités détectées <chapter:yocto:cve-analysis>
Une fois les fichiers SBOM correctement générés, on a pu les faire ingérer à `sbom-cve-check` puis on a regardé les vulnérabilités détectées. Nous avons pour cela utilisé le logiciel VulnScout @vulnscout, qui est un outil d'évaluation de vulnérabilités développé par Savoir-faire Linux. Une partie significative du stage ayant porté sur l'amélioration de cet outil, nous la détaillerons dans un chapitre dédié (@chapter:vulnscout).

Déjà, on a pu remarquer un nombre total de vulnérabilités potentiellement applicables assez importante : environ 130. Toutes les analyser aurait potentiellement pu prendre plusieurs jours voire même semaines, il a donc été décidé de les filtrer selon leur importance. On a utilisé pour cela les deux métriques courantes pour estimer l'importance de vulnérabilités : le @CVSS qui indique la sévérité et l'@EPSS qui indique l'exploitabilité. Une vulnérabilité avec un score de sévérité faible et une exploitabilité nulle ne vaut pas le coup d'être étudiée. La portée de notre analyse a donc été définie uniquement pour les vulnérabilités vérifiants une de ces conditions :
- $"CVSS" >= 9.0$ (vulnérabilités critiques)
- $"CVSS" >= 7.0 and "EPSS" >= 50%$ (vulnérabilités importantes et facilement exploitables)

Ce choix a été fait avec le tuteur de stage car il semblait cohérent avec les vulnérabilités détectées. Nous avons consulté des collègues ayant de l'expérience dans le milieu de l'analyse de vulnérabilités, notamment dans l'équipe de Savoir-faire Linux à Montréal, pour nous assurer que les seuils étaient plausibles. Ils pourront de toute manière être réévalués, notamment lors de futures réunions du @TSC de SEAPATH. L'étude des vulnérabilités étant encore au stade de R&D, il n'y a pas de problème à prendre cette décision unilatéralement pour le moment.

Ainsi, après avoir filtré la centaine de vulnérabilités détectées avec les seuils énoncé précédemment, il n'est plus resté qu'une quinzaine de vulnérabilités à analyser, dont une majorité étaient des faux positifs :
- Certains étaient dûs à la configuration de SEAPATH. Par exemple #link("https://www.cve.org/CVERecord?id=CVE-2026-32746")[CVE-2026-32746], une vulnérabilité dans le binaire _telnetd_ contenu dans le paquet _inetutils_, est détectée alors que SEAPATH contient une partie seulement d'_inetutils_ (comme _ping_ par exemple) mais pas _telnetd_.
- La plupart sont des vulnérabilités marquées comme potentiellement applicables alors qu'elles ont été corrigées depuis longtemps. C'est souvent le cas lorsque les bases de données de vulnérabilités n'ont pas connaissance des versions auxquelles les vulnérabilités ont été corrigées. Par exemple, #link("https://nvd.nist.gov/vuln/detail/CVE-2018-6764")[CVE-2018-6764] est une vulnérabilité de _libvirt_ qui a été découverte et corrigée en 2018 dans la version 4.1.0. Pourtant, les bases de données n'incluent pas cette information. Il s'agit en général d'un oubli de la part des mainteneurs de ces bases, mais ça occasionne ce genre de problèmes.

Afin de corriger ces faux positifs, on peut utiliser un mécanisme de Yocto qui permet d'annoter une vulnérabilité dans une recette et qui inclut ensuite cette annotation dans le fichier OpenVEX (voir @fig:yocto:analysis:cve_status et @fig:yocto:analysis:openvex). Quand on utilise `sbom-cve-check`, on lui donne le fichier OpenVEX en plus du SBOM pour qu'il filtre automatiquement les vulnérabilités connues selon leur statut (ici, _ignored_).

#v(.5em) // pour le truc du langage
#figure(
  zebraw(```BitBake
  # Dans recipes-connectivity/inetutils/inetutils_%.bbappend
  CVE_STATUS[CVE-2026-32746] = "not-applicable-config: telnetd not included in SEAPATH"

  # Dans recipes-extended/libvirt/libvirt_%.bbappend
  CVE_STATUS[CVE-2018-6764] = "fixed-version: Fixed in 4.1.0, NVD tracks this as version-less vulnerability"
  ```),
  caption: [Annotations de vulnérabilités dans les recettes BitBake],
) <fig:yocto:analysis:cve_status>

#figure(
  zebraw(
    ```json
    {
      "name": "inetutils",
      "version": "2.5",
      "cpes": ["cpe:2.3:*:*:inetutils:2.5:*:*:*:*:*:*:*"],
      "issue": [{
        "id": "CVE-2026-32746",
        "status": "Ignored",
        "link": "https://nvd.nist.gov/vuln/detail/CVE-2026-32746",
        "detail": "not-applicable-config",
        "description": "telnetd not included in SEAPATH"
      }, ...]
    }
    ```,
    lang: false,
  ),
  caption: [Extrait de fichier OpenVEX contenant une annotation de vulnérabilité],
) <fig:yocto:analysis:openvex>

Pour les faux positifs causés par l'absence du numéro de la version corrigeant la vulnérabilité, il a fallu trouver ce numéro. C'était parfois trivial lorsque le correctif est annoncé dans les notes de versions, mais il souvent fallu fouiller les dépôts Git à la recherche des commits contenant les correctifs pour ensuite trouver les versions associées.

Afin que ce travaille bénéfie à d'autres utilisateurs de Yocto, ces annotations ont été rendues @opensource : après relecture par plusieurs collègues, le commit a été soumis aux mainteneurs du projet Yocto via leur liste de diffusion#footnote[Discussion sur la liste de diffusion : #link("https://lists.yoctoproject.org/g/meta-virtualization/topic/118343262")]. Il a ensuite été accepté quelques semaines plus tard, ces changements font donc officiellement partie de la base de code publique du projet Yocto.#footnote[Commit contenant les changements : #link("https://git.yoctoproject.org/meta-virtualization/commit/?id=88e29d1f7f")]

Concernant les vrais positifs (les vulnérabilités détectées qui sont réellement présentes et potentiellement exploitables), il n'est pas dans le cadre du stage de les corriger. SEAPATH étant un projet encore jeune, il n'est pas encore déployé dans de vraies infrastructures critiques. De plus, SEAPATH est open-source et les mainteneurs n'ont pas encore décidé de la politique qu'ils comptaient adopter concernant les vulnérabilités détectées en son sein.

Enfin, la documentation de SEAPATH Yocto a été mise à jour pour indiquer aux futurs contributeurs et utilisateurs comment effectuer cette analyse de vulnérabilités, en listant les fichiers à utiliser et les commandes à faire pour les traiter.

//#pagebreak()
== #gls-long("CI", update: true) <chapter:yocto:ci>

Pour le moment, la détection des vulnérabilités a été faite manuellement après chaque build de SEAPATH. La prochaine étape est d'intégrer cette détection dans le pipeline de @CI. Grâce à cela, à chaque changement dans le code de SEAPATH, le système va chercher les vulnérabilités et générer un rapport. C'est particulièrement pratique pour les #gls("PR", first: true) : cela permettra de détecter aisément si un contributeur externe essaie d'introduire une faille dans SEAPATH car les vulnérabilités ajoutée apparaîtraient automatiquement dans le résumé de la @PR.

Jusqu'à maintenant, la @CI de SEAPATH est interne à Savoir-faire Linux : elle tourne sur une instance Jenkins @jenkins et est lancée dès qu'un commit est prêt à être intégré dans la base de code Gerrit @gerrit interne à l'entreprise. Cependant, SEAPATH est un projet @opensource dont les dépôts publiques sont aussi hébergés sur GitHub @github. Les personnes externes à Savoir-faire Linux qui souhaitent contribuer à SEAPATH le font sur GitHub et ne déclenchent donc pas la @CI, ce qui nullifie en partie l'intérêt d'ajouter la détection de vulnérabilités dans la @CI. De plus, vu que Jenkins est uniquement accessible en interne chez Savoire-faire Linux, il n'y a pas de transparence sur les processus utilisés lors du développement. Pour ces raisons, il a été décidé en premier lieu de réécrire la @CI sur GitHub Actions @github-actions pour ensuite y rajouter la détection de vulnérabilités.

=== Transfert sur GitHub Actions <chapter:yocto:ci:transfer>

Le pipeline de @CI de SEAPATH sur Jenkins est assez basique : il récupère les sources, initialise l'environnement de développement (à l'aide de CQFD, voir @chapter:context:sfl:tooling) puis lance successivement la construction de 4 variantes d'images SEAPATH différentes (pour chaque type d'image utilisé dans un cluster). Si tout s'est passé correctement, la CI passe. Si un problème survient, la CI s'arrête instantanément.

Il est très aisé de reproduire une @CI aussi basique sur GitHub Actions : les actions exécutées n'ont rien de particulier, notre pipeline `build` ne contient presque qu'une suite de commandes shell à exécuter.

Une première amélioration menée a été de diviser le processus de build : au lieu de construire toutes les variantes dans une seule et même étape du pipeline (voir @fig:yocto:ci:build-jenkins), on a utilisé la fonctionnalité de _matrice_ de GitHub Actions permettant d'effectuer une même suite d'étapes plusieurs fois avec des paramètres différents : ici, on itère sur la variante d'image à construire (voir @fig:yocto:ci:build-gh). Cela a de nombreux avantages : on peut voir les journaux de chaque étape individuellement, en cas de problème lors de la construction d'une variante la CI continuera pour les autres, on peut même paralléliser la construction pour la rendre plus rapide.

#subpar.grid(
  figure(
    pad(
      scale(80%, fletcher.diagram(node-stroke: 1pt, node-outset: 0pt, node-inset: .7em, spacing: 2em, debug: false, {
        import fletcher: edge, node, shapes
        let termination = (shape: shapes.pill, fill: color.red.desaturate(50%))
        let process = (shape: shapes.rect, fill: color.aqua.desaturate(50%))

        node((0, 0), ..termination)[Début de la CI]
        edge("-|>")
        node((1, 0), ..process)[Récupérer les\ sources]
        edge("-|>")
        node((1, 1), ..process)[Initialiser\ l'environnement]
        edge("-|>")
        node((1, 2), ..process)[Construire les\ variantes 1, 2, 3, 4]
        edge("-|>")
        node((0, 2), ..termination)[Fin de la CI]
      })),
      y: 0.65em,
    ),
    caption: [Pipeline pré-existant],
  ),
  <fig:yocto:ci:build-jenkins>,

  figure(
    scale(80%, fletcher.diagram(node-stroke: 1pt, node-outset: 0pt, node-inset: .7em, spacing: 2em, debug: false, {
      import fletcher: edge, node, shapes
      let termination = (shape: shapes.pill, fill: color.red.desaturate(50%))
      let loop = (shape: shapes.hexagon, fill: color.orange.desaturate(50%))
      let process = (shape: shapes.rect, fill: color.aqua.desaturate(50%))

      node((0, 0), ..termination)[Début de la CI]
      edge("-|>")
      node((0, 1), name: <loop>, ..loop, pad(0pt)[Pour chaque\ `variante`])

      edge("-|>", <build-wf>)
      node(enclose: (<fetch>, <init>, <build>), stroke: (dash: "dashed"), snap: -1, name: <build-wf>)
      node((1, 0), name: <fetch>, ..process)[Récupérer les\ sources]
      edge("-|>")
      node((1, 1), name: <init>, ..process)[Initialiser\ l'environnement]
      edge("-|>")
      node((1, 2), name: <build>, ..process)[Construire\ `variant`]

      edge(<loop>, <end>, "-|>")
      node((0, 2), name: <end>, ..termination)[Fin de la CI]
    })),
    caption: [Nouveau pipeline `build`],
  ),
  <fig:yocto:ci:build-gh>,

  columns: 2,
  gap: 1em,
  align: horizon,
  supplement: "Figure",
  placement: auto,
  caption: [Évolution de l'architecture du pipeline de construction des images],
)

Une fois le pipeline écrit, on a rencontré un premier problème : un build de SEAPATH "à froid", ce qui veut dire sans jamais ne l'avoir fait auparavant et sans avoir mis en cache des données, peut durer plusieurs heures et demande des ressources non négligeables en mémoire et processeur. Il est irréaliste de faire tourner la @CI sur l'infrastructure publique de GitHub. Un _runner_ GitHub Actions a donc été déployé sur un serveur dédié de l'entreprise : on bénéficie ainsi d'une plus grande puissance de calcul et d'un cache stocké localement. Une fois passé la toute première construction, les exécutions de CI suivantes prenent une vingtaine de minutes seulement. // TODO if more text needed, explain Ansible use here

=== Détection de vulnérabilités <chapter:yocto:ci:cve-check>
Maintenant que les images se construisent correctement dans la @CI, la détection des vulnérabilités sur les images générées a pu être automatisée. Nous avons donc écrit un nouveau pipeline dédié qui s'exécute après celui de build.

Comme décidé dans le @chapter:yocto:comparison:conclusion, on va utiliser l'outil _sbom-cve-check_ qui utilise les @SBOM:pl générés par l'étape de construction de l'image. Le pipeline commence par installer cet outil. Il télécharge ensuite les @SBOM:pl de chaque variante, puis lance la détection de vulnérabilités sur ceux-ci. On a bien fait attention de faire la détection sur chaque fichier individuellement : cela permettra de savoir dans quelle(s) variante(s) les vulnérabilités sont présentes. _sbom-cve-check_ exporte un fichier SPDX3 par variante, contenant le @SBOM ainsi que les vulnérabilités détectées.

Ensuite, nous utilisons l'outil VulnScout pour générer des rapports sur les vulnérabilités présentes dans les fichiers SPDX3 ainsi que pour émettre une erreur lorsque des vulnérabilités dépassent les seuils définis au @chapter:yocto:cve-analysis. Les rapports sont ensuite sauvegardés et rendus publiques à la fin du pipeline pour pouvoir être lus par n'importe qui.

En pratique, nous exportons un fichier CSV (un tableur) contenant l'ensemble des vulnérabilités détectées avec leurs statuts, ainsi qu'un résumé permettant aux utilisateurs d'avoir une vue rapide des vulnérabilités présentes. Un exemple peut être consulté en @annex:vulnscout-report-summary.

Lorsque des vulnérabilités dépassent les seuils, on a pris soin de rendre l'erreur la plus claire possible pour que les mainteneurs puissent avoir l'information rapidement et facilement. Ainsi, une liste des vulnérabilités critiques et leurs scores @EPSS et @CVSS ainsi que les packages et variantes associés, sont affichées en annotation sur la page du pipeline (voir @fig:yocto:ci:cve-check:gh-annotations).

#figure(
  image("../assets/gh_workflow_cve_annotations.png", width: 100%),
  caption: [Page de résumé du pipeline de détection des vulnérabilités.],
  placement: auto,
) <fig:yocto:ci:cve-check:gh-annotations>

Comme indiqué dans le @fig:yocto:comparison:databases-table du @chapter:yocto:comparison:cve-amount, _sbom-cve-check_ a besoin de télécharger les bases de données du NVD et du projet CVE#emoji.tm. Celles-ci sont particulièrement conséquentes : elles représentent à elles deux 7,1 Go de données. Ce n'est raisonnable de télécharger ces bases de données à chaque fois que la CI tourne. Ainsi, nous faisons aussi tourner la CI sur le serveur dédié de Savoir-faire Linux, en configurant notre pipeline pour que les bases de données soient stockées dans un emplacement qui ne soit pas régulièrement supprimé.

Enfin, puisque des vulnérabilités sont découvertes tous les jours, on a mis en place un pipeline `periodic-cve-check` qui s'exécute automatiquement tous les matins et va détecter les vulnérabilités sur la dernière image de SEAPATH construite en utilisant le @SBOM sauvegardé du dernier pipeline. Ainsi, même si il n'y a pas eu d'activité sur le dépôt, la détection se fait tout de même régulièrement et permet de ne pas laisser une nouvelle vulnérabilité critique non détectée.

=== #gls-longplural("PR", update: true) <chapter:yocto:ci:pr>
Jusqu'ici, le pipeline de construction ne s'exécutait que lorsqu'un commit était poussé sur la branche principale du dépôt. Cependant, la politique de contribution à SEAPATH impose de pousser son code sur une branche à part dans un dépot personnel, puis d'ensuite faire une @PR:long sur le dépôt principal. Nous avons donc créé un pipeline qui se lance lorsque qu'une @PR est ouverte vers la branche principale : celle-ci va construire les images, puis faire la détection de vulnérabilités.

Afin de ne pas dupliquer de code, nous avons pris avantage du concept des pipelines réutilisables de GitHub Actions @gh-actions-reuse-workflows : cela permet d'"inclure" un pipeline dans un autre. Ainsi, nous avons créé 2 pipelines réutilisables, qui sont inclus dans les pipelines `push`, `pr` et `periodic-cve-check` :
#block(breakable: false)[
  - `_build`, décrit au @chapter:yocto:ci:transfer, qui construit les images et sauvegarde les @SBOM:pl ;
  - `_cve-check`, décrit au @chapter:yocto:ci:cve-check, qui effectue la détection des vulnérabilités sur les @SBOM:pl sauvegardés précédemment et exporte des rapports.
]

Un diagramme montrant les différents pipelines ainsi que leurs relations est disponible en @fig:yocto:ci:pr:diagram-main.

De plus, afin de rendre les potentiels problèmes rencontrés lors de la @CI les plus clairs possibles, nous avons créé un pipeline à part, `pr-summary`, qui compile les résultats et poste un commentaire sur la @PR qui a déclenché le pipeline : ce commentaire indique si la construction des images s'est bien passée et si des vulnérabilités ont dépassé les seuils. Un exemple est disponible en @fig:yocto:ci:pr:comment.

#figure(
  [
    #image("../assets/yocto-ci-main.svg", width: 72%)
    #block(stroke: .5pt, inset: .5em, align(left)[
      *Légende :*
      - flèches en pointillés : déclenchement de pipeline automatique
      - flèches épaisses : inclusion de pipeline
    ])
  ],
  caption: [Schéma de la CI],
  placement: auto,
) <fig:yocto:ci:pr:diagram-main>

#figure(
  image("../assets/gh_pr_comment.png", height: 32%),
  caption: [Commentaire créé automatiquement sur une @PR par la @CI.],
  placement: auto,
) <fig:yocto:ci:pr:comment>


=== Approche multi-dépôts <chapter:yocto:ci:multirepo>

Pour générer une image SEAPATH, il y a besoin de beaucoup de code : la description de l'environnement, les scripts, le code BitBake, ses dépendances, les fichiers de configurations, etc.
- L'environnement de travail, les scripts et autres fichiers de configuration sont stockés à la racine du répertoire de travail et sauvegardés dans le dépôt _yocto-bsp_ @SEAPATH-git-yocto-bsp.
- Le code BitBake décrivant la distribution à générer est stocké dans le répertoire `sources/meta-seapath` et sauvegardé dans le dépôt _meta-seapath_ @SEAPATH-git-meta-seapath.
- Les dépendances BitBake sont tirées depuis d'autres dépôts Git qui ne sont pas maintenus par SEAPATH et sont également stockés dans le répertoire `sources/`.

Afin d'éviter aux développeurs de SEAPATH une longue suite de commandes `git clone` à chaque fois qu'il faut préparer un environnement de travail, l'outil _repo_ @google-repo-git est utilisé : il permet de décrire dans un fichier _manifest_ la liste des dépôts à tirer et où les placer dans l'espace de travail. Les _manifests_ de SEAPATH sont stockés dans le dépôt _repo-manifest_ @SEAPATH-git-repo-manifest. L'arborescence créée par _repo_ sur le _manifest_ de SEAPATH est montrée dans la @fig:yocto:ci:multirepo:tree.

#figure(
  zebraw(
    ```
    .
    ├── .cqfd
    │   └── docker
    ├── .github
    │   └── workflows
    ├── tools
    │   ├── demo_setup
    │   └── deploy_vm
    ├── .repo
    │   ├── ...
    │   └── manifests
    └── sources
        ├── bitbake
        ├── meta-yocto
        ├── meta-intel
        ├── ...
        └── meta-seapath
    ```,
    hanging-indent: false,
    highlight-lines: (
      ..range(2, 8 + 1),
      (8, [Contenu du dépôt _yocto-bsp_ @SEAPATH-git-yocto-bsp]),
      (11, [Dépôt _repo-manifest_ @SEAPATH-git-repo-manifest]),
      ..range(13, 16 + 1).map(x => (x, color.purple.lighten(82%))),
      (16, [Dépendances de SEAPATH]),
      (17, [Dépôt _meta-seapath_ @SEAPATH-git-meta-seapath]),
    ),
  ),
  caption: [Arborescence des sources de SEAPATH Yocto],
  placement: auto,
) <fig:yocto:ci:multirepo:tree>

Cette approche est standard dans les projets basés sur Yocto, mais elle complique la mise en place de @CI. En effet, les CI basées sur GitHub Actions sont intimement liées à un dépôt : le code des pipelines est stocké dedans et tous les déclencheurs sont liés au dépôt. Cependant nous voulons qu'un commit ou une @PR sur n'importe lequel des dépôts de code de SEAPATH (_yocto-bsp_ ou _meta-seapath_) déclenche notre CI. Il a donc fallu trouver des solutions pour contourner le problème. Nous avons envisagé deux approche :
+ dupliquer les pipelines sur les deux dépôts ;
+ avoir les pipelines principaux sur un dépôt et leur rediriger les événements de l'autre dépôt en utilisant d'autres pipelines dédiés.

La première solution est la plus simple, mais elle a plusieurs inconvénients :
- Elle implique de dupliquer du code, ce qui induit un coût de maintenance supplémentaire et de potentiels bugs si les pipelines sont mis à jour dans un dépôt mais pas dans l'autre.
- Elle disperse les résultats des exécutions de la CI : si on veut avoir une vue globale de la CI de SEAPATH Yocto, il faut ouvrir les deux dépôts et y chercher les dernières exécutions.

La deuxième solution règle ces inconvénients : les pipelines de constructions sont présent uniquement dans le dépôt principal, tandis que l'autre dépôt contient simplement des pipelines de redirection qui ne changeront jamais. De plus, tous les résultats de CI seront centralisés dans le dépôt principal. Nous avons donc choisi cette solution.

=== Synchronisation entre dépôts <chapter:yocto:ci:sync>
Pour mettre en œuvre cette synchronisation, on va conserver les pipelines principaux (`build` et `cve-check`) dans le dépôt _yocto-bsp_. Les pipelines dans _meta-seapath_ serviront uniquement à déclencher ces derniers quand un commit ou une @PR arrive.

Une première difficulté a été de trouver le mécanisme à utiliser pour déclencher les pipelines du dépôt principal depuis un autre dépôt. Nous avons cherché dans la documentation s'il existait des _triggers_ (les types d'événements qui déclenchent un pipeline) qui correspondraient à notre usage, et il y en avait deux :
+ `workflow_dispatch`, qui permet à des utilisateurs de manuellement lancer un pipeline avec des paramètres ;
+ `repository_dispatch`, qui est fait pour qu'un événement externe au dépôt déclenche des actions via l'@API de GitHub, en y passant des paramètres.

À première vue, le deuxième _trigger_ paraît mieux indiqué. Cependant, il possède deux limitations bloquantes :
- Il est impossible de suivre l'avancement d'un pipeline déclenché ainsi #footnote[Discussion à propos du problème de suivi des pipelines avec `repository_dispatch` : https://github.com/peter-evans/repository-dispatch/issues/260] : à cause de cela, les pipelines dans _meta-seapath_ renverront toujours "succès", même si le pipeline déclenché dans _yocto-bsp_ échoue.
- On ne peut pas dire à GitHub dans quelle branche lancer le pipeline, ce qui est dommage car SEAPATH est maintenu dans différentes versions sur des branches dédiées.

Nous avons donc fait le choix du premier _trigger_ : on utilise l'@API de GitHub Actions pour manuellement déclencher le pipeline avec `workflow_dispatch` et on attend ensuite la fin de son exécution, ce qui n'était pas possible avec `repository_dispatch`. L'inconvénient de cette méthode est qu'elle fait apparaître un menu permettant de lancer la CI depuis l'interface utilisateur (voir @fig:yocto:ci:sync:ui-popup). Ce menu ne s'affichant qu'aux mainteneurs de SEAPATH, nous avons considéré qu'il s'agissait d'un problème mineur.

#figure(
  image("/assets/gh_workflow_dispatch.png", width: 35%),
  caption: [Élément d'interface utilisateur qui apparaît à cause du _trigger_ `workflow_dispatch`],
  placement: none,
) <fig:yocto:ci:sync:ui-popup>

La deuxième difficulté de cette CI synchronisée entre 2 dépôts a été la gestion des permissions et secrets. En effet, afin de pouvoir déclencher la CI dans le dépôt principal, le pipeline de "délégation" a besoin d'un accès *authentifié* à l'@API GitHub Actions. Il a donc été nécessaire de créer une "GitHub App" qui possède les permissions pour déclencher des pipelines et stocker sa clé privée dans le dictionnaire de valeurs secrètes du dépôt _meta-seapath_.

Tout ceci fonctionne très bien, sauf dans un cas très particulier : lorsqu'un contributeur externe à l'organisation SEAPATH propose une @PR, le pipeline exécuté dispose de permissions restreintes et n'a pas accès aux secrets du dépôt. Il s'agit d'une mesure préventive mise en place par GitHub pour éviter que des @PR malveillantes volent des données confidentielles. Dans notre cas, il n'y a pas de risques car le code de la @PR n'est pas téléchargé dans le pipeline de délégation. Cependant, à cause de ces restrictions, il n'est pas possible de faire la délégation dans ce pipeline, puisqu'il y a besoin du secret. Il y avait là encore 2 solutions possibles :
+ Utiliser le _trigger_ `pull_request_target` qui s'exécute sans les restrictions de sécurité ;
+ Utiliser le _trigger_ `workflow_run` qui permet d'automatiquement lancer un pipeline à la fin d'un autre, cette fois-ci sans les restrictions de sécurité.

Ces deux options étant similaires en apparence, on a sélectionné la première car elle était plus simple à mettre en place. Le problème de permissions s'est résolu, mais un autre est apparu : la @CI se lance automatiquement lorsqu'une @PR est ouverte, sans que les mainteneurs n'aient à l'approuver préalablement. C'est une grave faille de sécurité : n'importe quel attaquant peut introduire des changements ayants pour but d'exécuter du code malveillant dans l'environnement de @CI et potentiellement de corrompre la machine sur laquelle elle tourne, qui est hébergée au sein de Savoir-faire Linux (cf @chapter:yocto:ci:transfer). Malgré nos recherches, il n'existe pas de moyen simple de contourner ce problème.

Ainsi, nous avons bifurqué vers la seconde option, qui est plus complexe car elle demande un pipeline supplémentaire et quelques manipulations pour lui passer les données nécessaires. On retrouve bien le bouton pour approuver le lancement de la @CI (voir @fig:yocto:ci:sync:approve-button) qui ajoute une protection contre les attaques. La structure de la @CI est ainsi complète. Un schéma est disponible en @fig:yocto:ci:sync:schema.

#figure(
  box(stroke: (bottom: luma(50%)), image("../assets/gh_pr_approve_wf.png")),
  caption: [Encart demandant aux mainteneurs d'approuver le lancement de la @CI pour une @PR venant d'un contributeur externe.],
  placement: auto,
) <fig:yocto:ci:sync:approve-button>

#figure(
  [
    #image("../assets/yocto-ci-full.svg", width: auto)
    #block(stroke: .5pt, inset: .5em, align(left)[
      *Légende :*
      - flèches en pointillés : déclenchement de pipeline automatique
      - flèches épaisses : inclusion de pipeline
      - rectangles : fichiers de pipelines
      - rectangles en pointillés rouges : pipelines à permissions restreintes
    ])
  ],
  caption: [
    Schéma complet de la CI.
  ],
  placement: auto,
) <fig:yocto:ci:sync:schema>
