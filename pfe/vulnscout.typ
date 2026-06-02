#import "@preview/subpar:0.2.2"

= VulnScout <chapter:vulnscout>
VulnScout @vulnscout un outil de scan et d'évaluation de vulnérabilités basé sur les @SBOM:pl, conçu pour être convivial pour les développeurs et simple à intégrer avec Yocto, Buildroot (un autre outil de génération d'images Linux embarquées) et avec la plupart des systèmes générant des SBOMs var il prend en charge tous les formats standards (SPDX, CycloneDX, OpenVEX). Il a été conçu pour être très facile à mettre en place avec le minimum de configuration nécessaire. Il comble ainsi le fossé entre les outils de cybersécurité, souvent complexes et difficiles à mettre en place, et le développement logiciel au quotidien, notamment dans les projets comportant des dizaines voire des centaines de dépendances open source.

Le développement de VulnScout a commencé en mai 2024 dans le cadre du stage de fin d'études de Louis Maillard, un étudiant de l'INSA Centre Val de Loire. Il a ensuite été annoncé officiellement à Embedded World 2025 @vulnscout-ew. Il est depuis disponible en open source mais est toujours en bêta. Une équipe dédiée de Savoir-faire Linux Montréal travaille dessus.

Savoir-faire Linux développe également un projet connexe, _meta-vulnscout_ @meta-vulnscout. Comme expliqué dans le @chapter:yocto:sota:nosbom, il s'agit d'un _layer_ Yocto contenant des classes améliorant les résultats de la classe `cve-check` de Yocto. Il contient également une classe permettant de directement lancer VulnScout depuis l'environnement de Yocto avec les @SBOM:pl et vulnérabilités déjà importées, sans avoir besoin de manuellement déployer VulnScout à côté et de gérer l'import des données.

== Utilisation pour SEAPATH
=== Analyse des vulnérabilités
Avant même le début du stage, il était décidé d'utiliser VulnScout pour étudier les vulnérabilités trouvées dans SEAPATH afin de promouvoir l'outil auprès de la communauté Yocto. C'est donc pourquoi on a utilisé VulnScout lorsqu'il a fallu comparer les résultats des outils de détection au @chapter:yocto:comparison:cve-amount, ou bien lorsqu'on a étudié les vulnérabilités détectées dans SEAPATH au @chapter:yocto:cve-analysis.

Nous avons principalement utilisé la page "Vulnérabilités" de l'interface utilisateur (voir @fig:vulnscout:seapath:vulnerabilities) : en filtrant uniquement sur les vulnérabilités en attente et en les triant par ordre de sévérité, on a pu aisément voir les détails des vulnérabilités critiques pour ensuite chercher si elles étaient applicables ou non (voir @fig:vulnscout:seapath:vuln-modal). Cela nous a beaucoup aidé : chercher directement dans les fichiers SPDX et OpenVEX était très complexe dû à leur grande verbosité.

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
  caption: [Extraits de l'interface utilisateur de VulnScout],
  supplement: "Figure",
  placement: auto,
)

VulnScout étant encore en bêta, il était normal d'y trouver quelques bugs ou fonctionnalités manquantes au fil de notre utilisation. On a donc remonté ceux-ci sur le dépôt de VulnScout. Quand ceux-ci étaient bloquants, on les a directement réglés et proposé les contributions via des @PR:pl.

En effet, notre utilisation de VulnScout est légèrement différente de celle faite par les autres équipes de Savoir-faire Linux : là où eux l'utilisent directement via _meta-vulnscout_, nous paramétrons et lançons l'outil en utilisant la ligne de commande. Ainsi, nous avons pu corriger des soucis en rapport avec cette différence : par exemple, l'import des fichiers SPDX générés par SEAPATH rencontrait des problèmes de permissions.

=== Intégration Continue
@chapter:yocto:ci:cve-check

== Contributions au code
=== Amélioration de la qualité du code
#table(
  columns: 3,
  table.header([Version], [Imprécision], [Problematic files]),
  [v0.10.0], [37,51%], [8/43],
  [v0.15.0-alpha], [33,95%], [6/96],
)

Pyright 0.15-a:
```
Symbols exported by "src": 919
  With known type: 314
  With ambiguous type: 56
  With unknown type: 549

Other symbols referenced but not exported by "src": 8071
  With known type: 5568
  With ambiguous type: 562
  With unknown type: 1941

Symbols without documentation:
  Functions without docstring: 1312
  Functions without default param: 16
  Classes without docstring: 255

Type completeness score: 34.2%
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
```

Assez peu de temps dédié à l'amélioration de la base de code pré-existante. Base de code pratiquement doublée, grâce aux revues de code le nouveau code est "propre".

== Comparaison avec DependencyTrack
