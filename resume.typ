#let summary(
  name: "Prénom NOM",
  company-tutor: "Prénom NOM",
  company-address: "1 rue de quoicoubeh",
  pfe-title: "Le titre",
  summary: lorem(80),
  domains: "informatique lolilol",
  environments: "Fortran *_*",
) = page[
  #block(
    stroke: 1pt,
    inset: 2pt,
    table(
      columns: 1fr,
      inset: (x: 4pt, y: 8pt),
      [*Prénom #smallcaps[Nom] :* #name],
      [
        *Maître de stage dans l'établissement d'accueil :* #company-tutor

        *Addresse de l'établissement d'accueil :* #company-address
      ],
      [*Titre du stage :* #pfe-title],
    ),
  )
  #block(stroke: 1pt, inset: 4pt, width: 100%, height: 1fr, grid(
    rows: 3,
    gutter: 2em,
    [
      *Résumé de la mission du stage :* _(contexte et travail à réaliser)_

      #summary
    ], [
      *Domaines d'application :* _(traitement d’images, protocoles réseaux, télévision numérique, etc.)_

      #domains
    ], [
      *Environnements :* _(langages, systèmes, etc.)_

      #environments
    ]
  ))
]

#summary(
  name: "Youenn LE JEUNE",
  company-tutor: "Erwann ROUSSY, Savoir-faire Linux",
  company-address: "74A Rue de Paris, 35000 Rennes",
  pfe-title: "Maintien en condition de sécurité de LF Energy SEAPATH",
  summary: [
    SEAPATH est un hyperviseur temps-réel à haute disponibilité. De manière résumée, il s'agit d'une distribution Linux personnalisée avec des caractéristiques très particulières :
    - La distribution dispose de toutes les fonctionnalités pour faire tourner des Machines Virtuelles (VM).
    - Le noyau Linux intégré a les fonctionnalités Temps Réel (RT) activées.
    - Il est possible de créer un cluster de machines avec SEAPATH pour que les VM tournent en continu sans interruption de service (la "haute disponibilité").
    Ces fonctionnalités rendent SEAPATH très utile pour les distributeurs d'énergie tels que RTE ou Enedis : en faisant tourner des VMs avec des logiciels de monitoring du réseau électrique, des coupes-circuits, etc. sur un cluster SEAPATH, ils s'assurent que leurs systèmes répondront avec une latence très faible (temps réel) et qu'il n'y aura pas d'interruption (haute disponibilité).

    SEAPATH est un projet open-source de la Linux Foundation pour l'Énergie et Savoir-faire Linux (SFL) est un des principaux contributeurs. Un des projets actuels de SFL pour SEAPATH est de mettre en place un système automatisé de détection des CVEs (vulnérabilités) sur le système, d'analyser les CVEs remontées et de rendre ces analyses publiques.

    Durant ce premier mois de stage, j'ai suivi des formations sur SEAPATH et sur son système de build, Yocto. J'ai pris en main le logiciel VulnScout qui est un outil d'évaluation de vulnérabilités open-source maintenu par SFL. J'ai étudié et mis en places plusieurs méthodes de détections de CVEs dans Yocto : un outil intégré, des scripts pour améliorer les résultats et un outil d'analyse via SBOM (liste de tous les composants logiciels du système). J'ai fait un rapport détaillé sur ces différentes méthodes avec statistiques et analyse des différences, que je publierai ensuite en billet de blog.

    J'ai également dû analyser quelques CVEs qui étaient remontées par ces systèmes pour voir si elles étaient applicables ou non, en regardant les versions applicables dans différentes bases de données (NIST NVD, CVE#sym.trademark Program, Linux Kernel vulns), les sources utilisées lors de la compilation, etc.

    J'ai fait plusieurs contributions aux outils que j'ai utilisé durant ce premier mois : corrections de bugs dans VulnScout, rapporter des bugs à sbom-cve-check, remonter des exclusions de CVEs aux mailing lists du projet Yocto.

    Enfin, j'ai commencé à créer une pipeline de CI/CD pour automatiser la détection de CVEs en utilisant les outils étudiés précédemment.
  ],
  domains: "Distribution d'électricité",
  environments: "Yocto (Bitbake), Python, GitHub Actions, Ansible",
)
