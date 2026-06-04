#import "@preview/subpar:0.2.2"
#import "@preview/zebraw:0.6.3": zebraw
#import "@preview/meander:0.4.2"

= VulnScout <chapter:vulnscout>
#meander.reflow({
  import meander: *

  /*placed(top + right, boundary: contour.margin(15pt), figure(
    image("../assets/vulnscout.jpg", width: 5cm),
    caption: [Logo de VulnScout],
  ))*/

  container()

  content[
    #h(1em) VulnScout @vulnscout un outil de scan et d'évaluation de vulnérabilités basé sur les @SBOM:pl, conçu pour être convivial pour les développeurs et simple à intégrer avec Yocto, Buildroot (un autre outil de génération d'images Linux embarquées) et avec la plupart des systèmes générant des SBOMs var il prend en charge tous les formats standards (SPDX, CycloneDX, OpenVEX). Il a été conçu pour être très facile à mettre en place avec le minimum de configuration nécessaire. Il comble ainsi le fossé entre les outils de cybersécurité, souvent complexes et difficiles à mettre en place, et le développement logiciel au quotidien, notamment dans les projets comportant des dizaines voire des centaines de dépendances open source.
  ]
})

Concrètement, VulnScout est une application Web hébergée localement : son backend est écrit en Python avec le framework Flask @flask-manual, tandis que le frontend est en TypeScript avec le framework React @react-repo. Le développement de VulnScout a commencé en mai 2024 dans le cadre du stage de fin d'études de Louis Maillard, un étudiant de l'INSA Centre Val de Loire. Il a ensuite été annoncé officiellement à Embedded World 2025 @vulnscout-ew. Il est depuis disponible en open source mais toujours en développement actif. Une équipe dédiée de Savoir-faire Linux Montréal travaille dessus.

Savoir-faire Linux développe également un projet connexe, _meta-vulnscout_ @meta-vulnscout. Comme expliqué dans le @chapter:yocto:sota:nosbom, il s'agit d'un _layer_ Yocto contenant des classes améliorant les résultats de la classe `cve-check` de Yocto. Il contient également une classe permettant de directement lancer VulnScout depuis l'environnement de Yocto avec les @SBOM:pl et vulnérabilités déjà importées, sans avoir besoin de manuellement déployer VulnScout à côté et de gérer l'import des données.

== Analyse des vulnérabilités de SEAPATH
Il avait été décidé d'utiliser VulnScout pour étudier les vulnérabilités trouvées dans SEAPATH avant même le début du stage, afin de promouvoir l'outil auprès de la communauté Yocto mais aussi car c'est l'outil le plus adapté pour un projet basé sur Yocto. C'est donc pourquoi on a utilisé VulnScout lorsqu'il a fallu comparer les résultats des outils de détection au @chapter:yocto:comparison:cve-amount, ou bien lorsqu'on a étudié les vulnérabilités détectées dans SEAPATH au @chapter:yocto:cve-analysis.

Nous avons principalement utilisé la page "Vulnérabilités" de l'interface graphique (voir @fig:vulnscout:seapath:vulnerabilities) : en filtrant uniquement sur les vulnérabilités en attente et en les triant par ordre de sévérité, on a pu aisément voir les détails des vulnérabilités critiques pour ensuite chercher si elles étaient applicables ou non (voir @fig:vulnscout:seapath:vuln-modal). Cela nous a beaucoup aidé : chercher directement dans les fichiers SPDX et OpenVEX était très complexe dû à leur grande verbosité.

#subpar.grid(
  figure(
    image("../assets/vs_vulnerabilities.png"),
    caption: [Page listant les vulnérabilités],
  ),
  <fig:vulnscout:seapath:vulnerabilities>,
  figure(
    image("../assets/vs_vuln_modal.png", width: 80%),
    caption: [Page montrant les détails d'une vulnérabilité ainsi que ses évaluations],
  ),
  <fig:vulnscout:seapath:vuln-modal>,
  gap: 1em,
  caption: [Extraits de l'interface graphique de VulnScout],
  supplement: "Figure",
  placement: auto,
)

VulnScout étant encore en bêta, il était normal d'y trouver quelques bugs ou fonctionnalités manquantes au fil de notre utilisation. On a donc remonté ceux-ci sur le dépôt de VulnScout. Quand ceux-ci étaient bloquants, on les a directement réglés et proposé les contributions via des @PR:pl.

En effet, notre utilisation de VulnScout est légèrement différente de celle faite par les autres équipes de Savoir-faire Linux : là où eux l'utilisent directement via _meta-vulnscout_, nous paramétrons et lançons l'outil en utilisant la ligne de commande. Ainsi, nous avons pu corriger des soucis en rapport avec cette différence : par exemple, l'import des fichiers SPDX générés par SEAPATH rencontrait des problèmes de permissions.

#pagebreak()
Un autre soucis rencontré qui n'avait pas été remarqué par l'équipe de VulnScout est la fuite de données entre projets : lorsqu'une instance VulnScout contient à la fois des projets basés sur Yocto et d'autres non, les informations provenant des @SBOM:pl Yocto (par exemple pour indiquer qu'une vulnérabilité n'est pas présente car un fichier n'est pas compilé) sont visibles sur les pages de vulnérabilités des autres projets, alors que l'information ne les concerne pas. La correction de ce bug a nécessité de modifier le schéma de la base de données interne de VulnScout afin de stocker l'information fournie par Yocto dans une table contenant exactement les bonnes relations (la table `sbom_observation` au centre de la @fig:vulnscout:analysis:erd). Grâce à ce changement, les informations provenant des @SBOM:pl Yocto apparaissent sur la page des vulnérabilités seulement lorsqu'elles concernent le projet sélectionné (voir @fig:vulnscout:analysis:yocto-description).

#figure(
  image("../assets/erd 2.png", width: 80%),
  caption: [Modèle entité-association de la base de données de VulnScout],
  placement: auto,
) <fig:vulnscout:analysis:erd>

#figure(
  image("../assets/vs_vuln_yocto_desc.png", width: 80%),
  caption: [Page montrant une information remontée par Yocto pour le projet actuel],
  placement: auto,
) <fig:vulnscout:analysis:yocto-description>

#pagebreak()
== Intégration Continue dans SEAPATH
Comme évoqué au @chapter:yocto:ci:cve-check, on utilise VulnScout dans la @CI pour générer des rapports et pour émettre une erreur lorsque des vulnérabilités dépassent les seuils de sévérité. En effet, en plus de son interface graphique facile à utiliser, VulnScout propose un outil en ligne de commande pour interagir avec, que nous utilisons dans le pipeline de détection de vulnérabilités. Une version simplifiée des commandes que nous utilisons est montrée en @fig:vulnscout:ci:script.

#figure(
  zebraw(
    ```bash
    for variant in "host_standalone_efi" "guest_efi" ...; do
      vulnscout \
        --name "seapath" \
        --variant "$variant" \
        --add-spdx "./$variant/sbom-cve-checked.spdx.json"
    done

    vulnscout \
      --report "summary.adoc" \
      --report "vulnerabilities.csv"

    vulnscout \
      --match-condition \
        "not ignored and not fixed and (cvss >= 9.0 or (cvss >= 7.0 and epss >= 50%))" \
      --report "failed-vulnerabilities.txt"
    ```,
    hanging-indent: false,
    comment-flag: "#",
    highlight-lines: (
      (
        5,
        [On utilise les fichiers précédemment exportés par _sbom-cve-check_ après ingestion des @SBOM:pl de SEAPATH.],
        color.white.transparentize(100%),
      ),
    ),
  ),
  caption: [Script simplifié de l'exécution de VulnScout dans la @CI],
  placement: none,
) <fig:vulnscout:ci:script>

Comme le seuil à partir duquel une vulnérabilité est considéré comme critique utilise la valeur de l'@EPSS, VulnScout doit récupérer ces valeurs depuis la base de données en ligne, et ce pour toutes les vulnérabilités. Cette opération peut prendre plusieurs minutes selon la quantité de vulnérabilités détectées, il est donc préférable de ne pas la faire à chaque exécution de la @CI. Pour éviter cela, on a fait en sorte de garder la base de données de VulnScout en cache pour la réutiliser entre les exécutions.

Cependant, cette base de données contient les informations sur les @SBOM:pl chargés et les vulnérabilités déjà détectées aux exécutions précédentes. Conserver ces informations alors que les @SBOM:pl peuvent changer peut mener à des résultats incohérents : il a donc fallu trouver un moyen de conserver uniquement les données statiques (@EPSS et autres données sur les vulnérabilités), mais pas le reste (paquets, liste des vulnérabilités détectées, etc.)

Vu qu'il n'existait pas une telle fonctionnalité dans VulnScout, on a programmé de nouvelles commandes qui permettent de supprimer les @SBOM:pl précédemment importés dans VulnScout, ainsi que les données qui y sont associées (aussi appelés des _scans_) : ainsi, la commande `vulnscout --delete-scan <scan_id>` permet de supprimer un scan à partir de son identifiant. Puisque celui-ci n'est pas nécessairement connu, il a également fallu créer la commande `vulnscout list-scans [--json]`, qui permet de lister les scans précédents et ainsi de récupérer leurs identifiants.

En @CI, on va chaîner la commande `list-scans` à la commande `delete-scan`. Pour faire cela efficacement, on a pris soin de donner 2 modes d'affichage à la commande `list-scans`, le premier destiné à être lisible pour les humains (@fig:vulnscout:ci:list-scans:nojson) et le deuxième fait pour être facilement interprété par les machines : lorsqu'on ajoute l'option `--json`, VulnScout affiche les scans au format JSON qu'il est aisé de manipuler programmatiquement (@fig:vulnscout:ci:list-scans:json).

#{
  show raw: set text(size: 8pt)
  pad(x: -7%, subpar.grid(
    figure(
      box(stroke: luma(50%), inset: 4pt, radius: 8pt, ```bash
      $ vulnscout list-scans
      67bd6ccb-fd95-4aab-83cf-f929d1d7f207 (empty description) at 2026-06-02 12:54:52.257306, project seapath, variant guest_efi, 1 SBOMs, 18083 observations
      a76b3f2b-488e-49cc-9808-e453fe22f630 (empty description) at 2026-06-02 12:57:14.048960, project seapath, variant host_standalone_efi, 1 SBOMs, 19499 observations
      ```),
      caption: [Sans `--json`],
    ),
    <fig:vulnscout:ci:list-scans:nojson>,

    figure(
      box(stroke: luma(50%), inset: 4pt, radius: 8pt, ```json
      $ vulnscout list-scans --json
      [
        {
          "id": "67bd6ccb-fd95-4aab-83cf-f929d1d7f207",
          "description": "empty description",
          "timestamp": "2026-06-02T12:54:52.257306+00:00",
          "variant": {
            "id": "ab47745c-6a39-4eeb-b3a7-22d325fc6162",
            "name": "guest_efi",
            "project": {
              "id": "03b499ea-dd2c-40da-af36-634abae90f0d",
              "name": "seapath"
            }
          }
        },
        ...
      ]
      ```),
      caption: [Avec `--json`],
    ),
    <fig:vulnscout:ci:list-scans:json>,

    columns: 2,
    gap: 1em,
    supplement: "Figure",
    caption: [La commande `vulnscout list-scans [--json]`],
  ))
}

Au final, grâce à ces ajouts, notre @CI peut réutiliser la base de données de VulnScout tant qu'elle exécute ces commandes au début, à la manière décrite dans le script de la @fig:vulnscout:ci:drop-scans-script.

#figure(
  zebraw(
    ```bash
    old_scans=$(vulnscout --list-scans --json | jq ".[] | .id" -r)

    for old_scan_id in $old_scans; do
      vulnscout --delete-scan "$old_scan_id"
    done
    ```,
    hanging-indent: false,
    comment-flag: "#",
    highlight-lines: (
      (
        1,
        [_jq_ est un processeur de texte JSON. On s'en sert ici pour récupérer la liste des champs `id` pour chaque scan.],
        color.white.transparentize(100%),
      ),
    ),
  ),
  caption: [Script permettant de supprimer tous les scans de la base de données de VulnScout],
) <fig:vulnscout:ci:drop-scans-script>

== Amélioration de la qualité du code
Comme introduit au début du @chapter:vulnscout, VulnScout est à la base un projet développé durant un stage, puis repris par différents collaborateurs de Savoir-faire Linux. Malgré sa relative jeunesse, une certaine quantité de dette technique s'est accumulée, surtout dûe à l'utilisation de conventions de code datées et de frameworks obsolètes. De plus, l'équipe actuelle de Savoir-faire Linux Montréal travaillant sur VulnScout doit avancer à une certaine allure pour rajouter des fonctionnalités et dispose de peu de temps pour retoucher l'ancien code.

Le principal souci identifié concerne l'absence quasi complète de typage dans le backend. En effet, Python n'est pas un langage typé explicitement : on n'a pas besoin de spécifier le type de ses variables, le type des paramètres des fonctions ou bien le type de retour d'une méthode. Cela en fait un langage facile à prendre en main et rapide à écrire, mais cela a l'inconvénient de rendre l'analyse statique de code très complexe : là où le compilateur d'un langage typé statiquement comme le Java peut facilement détecter l'accès à une variable inconnue ou le passage d'un nombre dans une fonction s'attendant à une chaîne de caractère, les outils dédiés pour Python ont beaucoup de mal à faire ces mêmes analyses. Pour pallier ces problèmes, depuis la version 3.0 de Python (2008), les développeurs peuvent ajouter des annotations de type. Ce n'est pourtant toujours pas fait partout, et c'est le cas dans VulnScout.

Tout le code créé pour VulnScout dans le cadre de ce stage a donc été écrit de la manière la plus propre possible, avec un typage explicite et en utilisant les fonctionnalités récentes des langages et frameworks utilisés. De plus, on a pris soin de revoir les @PR:pl des autres contributeurs afin de s'assurer que code nouvellement introduit soit également de bonne qualité. La politique du projet VulnScout étant d'avoir obligatoirement 2 revues par des personnes différentes pour chaque @PR, on a eu l'occassion de revoir la plupart d'entre elles (la taille de l'équipe étant assez réduite, oscillant entre 3 et 4 personnes en nous comptant).

Afin de mesurer l'impact que nous avons eu sur la qualité du code, nous avons utilisé les outils _mypy_ et _Pyright_ pour calculer des estimateurs sur le typage du code : pourcentage d'imprécision dans les fichiers, nombre de fichiers avec des erreurs de typage explicite, nombre de symboles (variables, fonctions, etc.) avec des types connus, etc. On a effectué ces mesures sur deux versions de VulnScout : la version 0.10 qui était la dernière lorsque le stage a commencé, puis la version 0.15 qui est la version courante lors de l'écriture de ce rapport.

#figure(
  {
    set par(justify: false)
    table(
      columns: (auto, auto, ..(1fr,) * 4),
      align: center + horizon,
      fill: (x, y) => if y == 2 { red.lighten(85%) } else if y == 3 { blue.lighten(85%) } else { none },
      table.header(
        table.cell(rowspan: 2, inset: 1em)[*Version*],
        table.cell(rowspan: 2)[Lignes\ de code],
        table.cell(colspan: 2)[*mypy*],
        table.cell(colspan: 2)[*Pyright*],
        [Imprécision],
        [Fichiers erronés],
        [Exhaustivité du typage],
        [Symboles avec types connus],
      ),
      [0.10], [6214], [37,51 %],
      [8 / 43], [32,9  %], [156 / #(156 + 274)],
      [0.15], [18630], [34,97%],
      [7 / 99], [34,5 %], [316 / #(316 + 545)],
    )
  },
  caption: [Évolution des indicateurs de qualité du typage du backend au cours du stage],
) <fig:vulnscout:quality:typing-table>

Une première chose à remarquer dans le @fig:vulnscout:quality:typing-table est que la base de code du backend a triplé, en passant d'environ 6 000 à 18 000 lignes, tandis que le nombre de fichier a plus que doublé (de 43 à 99). Malgré cela, il y a moins de fichiers avec des erreurs de typage, et la précision et l'exhaustivité du typage ont augmenté de quelques points de pourcentages.

Ces évolutions ne semblent pas très grandes, mais mises en relation avec le triplement du nombre de lignes de codes, cela montre l'effort mis dans la revue des @PR:pl pour que le code nouvellement intégré soit le plus correctement typé. Deplus, il y a eu très peu de temps destiné à l'amélioration pure du code existant, le nouveau code dépend donc parfois sur de l'ancien code non typé et est donc imprécis par effet boule de neige.

Au final, grâce à ces améliorations, il est plus aisé et sûr d'écrire du nouveau code dans VulnScout car on peut savoir le type des variables et fonctions qu'on appelle et donc éviter des erreurs simples.

/*Pyright 0.15:
```
Symbols exported by "src": 917
  With known type: 316
  With ambiguous type: 56
  With unknown type: 545

Other symbols referenced but not exported by "src": 8069
  With known type: 5568
  With ambiguous type: 562
  With unknown type: 1939

Symbols without documentation:
  Functions without docstring: 1313
  Functions without default param: 16
  Classes without docstring: 255

Type completeness score: 34.5%
```
Pyright 0.10:
```
Symbols exported by "src": 474
  With known type: 156
  With ambiguous type: 44
  With unknown type: 274

Other symbols referenced but not exported by "src": 3800
  With known type: 2868
  With ambiguous type: 292
  With unknown type: 640

Symbols without documentation:
  Functions without docstring: 617
  Functions without default param: 11
  Classes without docstring: 103

Type completeness score: 32.9%
```*/

#let DT = "Dependency-Track"
== Comparaison avec #DT
#DT @dependencytrack est une plate-forme d'analyse de composants logiciels permettant d'identifier les risques dans une chaîne d'approvisionnement logicielle. En pratique, elle se base sur les @SBOM:pl pour détecter les vulnérabilités présentes dans un système. C'est donc un clair concurrent de VulnScout.

À plusieurs reprises, sur des salons où ils présentaient VulnScout, des membres de Savoir-faire Linux ont été questionnés sur la différence avec #DT et l'intérêt de VulnScout en comparaison. Une partie du stage a donc été consacrée à l'étude et à la comparaison en profondeur des deux outils, du déploiement initial à l'expérience d'évaluation de vulnérabilités, en passant par l'intégration avec les projets basés sur Yocto.

On a ensuite écrit un rapport détaillé sur cette comparaison. On a pris soin de consigner les points faibles et forts des deux outils, afin de pouvoir en tirer une liste d'améliorations possibles pour VulnScout. De plus, on a souligné les profondes différences de philosophies, qui font que ces outils ne sont pas en réelle concurrence car ils n'ont pas les mêmes utilisateurs cibles. Le rapport a été partagé à l'équipe du projet VulnScout de Montréal. Il est prévu d'ensuite le publier en article de blogue sur le site Web de Savoir-faire Linux. Le rapport est consultable dans l'@annex:vulnscout-dependency-track.
