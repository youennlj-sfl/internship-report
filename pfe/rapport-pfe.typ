#import "@preview/silky-report-insa:0.5.2": *
#import "@preview/glossarium:0.5.10": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/zebraw:0.6.3": *

#show: make-glossary

#let entry-list = (
  (
    key: "ied",
    short: "IED",
    long: "Intelligent Electronic Device",
    description: [
      Dispositif électronique utilisé dans les systèmes de gestion et de contrôle du réseau électrique. Ils sont capables de collecter des données en temps réel, de prendre des décisions autonomes et d'exécuter des actions telles que l'ouverture ou la fermeture de disjoncteurs en réponse à des conditions anormales du réseau.
    ],
  ),
  (
    key: "SBOM",
    short: "SBOM",
    long: "Software Bill of Materials",
    longplural: "Software Bills of Materials",
    description: [
      Liste des composants utilisés pour créer un artéfact logiciel. Parfois appelée _nomenclature logicielle_.
    ],
  ),
  (
    key: "CI",
    short: "CI",
    long: "Intégration Continue",
    description: [
      Ensemble de pratiques utilisées en génie logiciel consistant à vérifier à chaque modification de code source que le résultat des modifications ne produit pas de régression dans l'application développée.
    ],
  ),
  (
    key: "opensource",
    short: "open source",
    description: [
      Caractéristique d'un projet logiciel dont la licence respecte des critères précisément établis par l'Open Source Initiative, c'est-à-dire les possibilités de libre redistribution, d'accès au code source et de création de travaux dérivés.
    ],
  ),
  (
    key: "distribution",
    short: "distribution",
    description: [
      Ensemble de logiciels qui, associés à un noyau Linux, fournissent un système d'exploitation opérationnel. Ils ne sont pas nécessaires pour que le système démarre, mais offrent les services requis pour le cas d'usage souhaité.
    ],
  ),
  (
    key: "PR",
    short: "PR",
    long: "Pull Request",
    longplural: "Pull Requests",
    description: [
      Demande d'intégration de commits dans une autre base de code. Le développeur pousse sa branche et demande à ce qu'elle soit fusionnée dans une autre, souvent la branche principale du dépôt.
    ],
  ),
  (
    key: "conteneur",
    short: "conteneur",
    description: [
      Enveloppe virtuelle qui contient une application et tous les éléments dont elle a besoin pour fonctionner : bibliothèques, outils, fichiers... Peut être grossièrement considéré comme une @VM:long légère.
    ],
  ),
  (
    key: "smart-grid",
    short: "smart grid",
    description: [
      Réseau électrique modernisé qui utilise la technologie numérique, la communication bidirectionnelle et des commandes avancées pour optimiser la génération, la transmission et la distribution d'électricité. Il intègre notamment des sources d'énergie renouvelable pour améliorer l'efficacité et la fiabilité de la distribution.
    ],
  ),
  (
    key: "hyperviseur",
    short: "hyperviseur",
    description: [
      Logiciel ou matériel permettant de créer et d'exécuter des VMs. Il agit comme un gestionnaire de ressources et de supervision entre les systèmes d'exploitation invités et le matériel physique de l'hôte.
    ],
  ),
  (
    key: "VM",
    short: "VM",
    long: "Machine Virtuelle",
    longplural: "Machines Virtuelles",
    description: [
      Émulation logicielle d'un ordinateur physique qui exécute un système d'exploitation et des applications comme un ordinateur physique, lancée sur un @hyperviseur.
    ],
  ),
  (
    key: "noyau",
    short: "noyau",
    description: [
      Cœur d'un système d'exploitation. Contient les programmes et pilotes essentiels à son fonctionnement, comme la gestion de la mémoire, des processus ou des I/O basiques. Souvent appelé par le terme anglais _kernel_.
    ],
  ),
  (
    key: "RT",
    short: "RT",
    long: "Temps Réel",
    description: [
      Caractéristique d'un système pour lequel le respect des contraintes temporelles dans l'exécution des traitements est aussi important que le résultat de ces traitements.
    ],
  ),
  (
    key: "CPE",
    short: "CPE",
    long: "Common Platform Enumeration",
    longplural: "Common Platform Enumeration",
    description: [
      Schéma de nommage structuré permettant d'identifier des systèmes informatiques, des logiciels, des paquets ou encore du matériel informatique. Peut contenir beaucoup de détails tels que le distributeur, la langue, etc. (à l'inverse du @PURL)
    ],
  ),
  (
    key: "PURL",
    short: "PURL",
    long: "Package-URL",
    description: [
      Schéma de nommage basé sur la syntaxe URL permettant d'identifier de manière unique un paquet logiciel, indépendamment de son écosystème ou médium de distribution (contrairement au @CPE).
    ],
  ),
  (
    key: "CVSS",
    short: "CVSS",
    long: "Common Vulnerability Scoring System",
    description: [
      Un score indiquant à quel point une vulnérabilité est grave. Va de 0 à 10, 10 indiquant une vulnérabilité absolument critique.
    ],
  ),
  (
    key: "EPSS",
    short: "EPSS",
    long: "Exploit Prediction Scoring System",
    description: [
      Un score indiquant la probabilité qu'une vulnérabilité soit exploitée. Va de 0 à 1 (ou de 0% à 100%).
    ],
  ),
  (
    key: "TSC",
    short: "TSC",
    long: "Comité de Pilotage Technique",
    description: [
      Comité gérant les aspects techniques d'un projet. Il se réunit régulièrement et ses réunions peuvent être ouvertes au public. Sigle issu de l'anglais _Technical Steering Committee_.
    ],
  ),
  (
    key: "API",
    short: "API",
    long: "Application Programming Interface",
    description: [
      Interface logicielle qui permet de "connecter" un logiciel ou un service à un autre logiciel ou service afin d'échanger des données et des fonctionnalités.
    ],
  ),
)
#register-glossary(entry-list)

#show: doc => insa-pfe(
  "Youenn LE JEUNE",
  "INFO",
  "2025-2026",
  "Maintien en condition de sécurité de LF Energy SEAPATH",
  "Savoir-faire Linux",
  image("../assets/savoirfairelinux_logo.png", width: 80%),
  "Erwann ROUSSY",
  "Barbara FILA",
  [
    Le projet porte sur la sécurisation de SEAPATH en mettant en place un suivi automatisé des vulnérabilités pour ses variantes Yocto et Debian. Le but est de fournir aux mainteneurs des rapports exploitables afin d'améliorer la sécurité d'un produit utilisé dans des infrastructures critiques.

    Plusieurs approches ont été étudiées et implémentées pour détecter les vulnérabilités, notamment à l'aide de SBOMs. Des analyses ont été menées pour améliorer la qualité des informations extraites et réduire les faux positifs. Le travail a donné lieu à des contributions dans de grands projets open source.

    L'ensemble a été intégré dans des pipelines d'intégration continue, avec des contrôles périodiques et des rapports automatisés pour faciliter le suivi et la remontée d'alertes tout en étant transparent et reproductible.
  ],
  [
    The project focuses on securing SEAPATH by implementing automated vulnerability tracking for its Yocto and Debian variants. The goal is to provide maintainers with actionable reports to improve the security of a product used in critical infrastructure.

    Several approaches were studied and implemented to detect vulnerabilities, notably using SBOMs. Analyses were carried out to improve the quality of extracted information and reduce false positives. The work resulted in contributions to major open-source projects.

    All of this was integrated into continuous integration pipelines, with periodic checks and automated reports to facilitate monitoring and the escalation of alerts while remaining transparent and reproducible.
  ],
  defense-date: "2026-06-17",
  insa-tutor-suffix: "e",
  insa: "rennes",
  lang: "fr",
  omit-outline: true,
  doc,
)
#show link: it => {
  if type(it.dest) == str {
    it = underline(it)
  }
  return text(fill: blue.darken(50%), it)
}

#let zebra-theme = (
  background-color: (luma(240), luma(247)),
  highlight-color: insa-colors.tertiary.lighten(60%),
  comment-color: blue.lighten(93%),
)
#show: zebraw-init.with(
  numbering-separator: true,
  hanging-indent: true,
  comment-color: blue.lighten(85%),
  ..zebra-theme,
)

#show raw.where(block: false): box.with(fill: black.transparentize(95%), outset: (x: 2pt, y: 3pt), radius: 4pt)
#set raw(syntaxes: ("../BitBake.sublime-syntax",))

#insa-hide-page-counter()
#heading(numbering: none, outlined: false)[Remerciements]
Tout d'abord, merci beaucoup à mon tuteur de stage, Erwann, de m'avoir fait confiance pour ce stage. Merci pour ton aide, merci aussi de ne pas trop m'avoir aidé et de m'avoir laissé galérer, c'était très formateur. Merci aussi pour les discussions sans trop tête ni queue pour laisser notre cerveau s'arrêter un peu parfois. D'ailleurs, il manque les ravioli dans ta classification.

Merci à la direction de faire le maximum pour que les stagiaires soient intégrés dans la vie professionnelle de l'entreprise, en nous faisant participer aux réunions quotidiennes et en nous poussant à contribuer aux projets internes.

Merci aux collègues de Montréal de l'équipe VulnScout qui m'ont intégré à leurs cycles de développement, ont corrigé mes bugs et revu mes PRs sans rechigner. Merci beaucoup à Valentin d'avoir tout fait pour que je sois bien intégré dans l'équipe, même à 5 000 km d'ici !

Enfin, merci à tous les collègues de Rennes pour leur bon accueil et notre intégration aisée à Florent et à moi, c'était sans prise de tête et ce fut un plaisir. À l'heure où j'écris ces lignes je n'en suis pas encore certain, mais je suis presque sûr qu'on va gagner le tournoi de Mölkky. Allez Kevin, allez Youssef on va y arriver !

#pagebreak()
#outline()

#heading(numbering: none, outlined: false)[Glossaire]
#print-glossary(
  entry-list,
  entry-sortkey: x => lower(x.key),
  deduplicate-back-references: true,
)

#pagebreak()
#insa-show-page-counter(current-page: 1)
#include "intro.typ"

#pagebreak()

#include "seapath-yocto.typ"

#pagebreak()

#include "seapath-debian.typ"

#pagebreak()

#include "vulnscout.typ"

//#pagebreak()
= Conclusion

#include "conclusion.typ"

#pagebreak()
#set heading(numbering: none)
#insa-hide-page-counter()
#text(size: 10pt, bibliography("../bibliography.yml"))

#pagebreak()
#set heading(numbering: none)

= Annexes
#set heading(numbering: (..nums) => nums.at(1), supplement: [Annexe], outlined: false)
#show heading: it => block(sticky: true)[
  Annexe #counter(heading).display() - #it.body
]

== Planning
#import "@preview/timeliney:0.4.0"

#timeliney.timeline(
  show-grid: false,
  {
    import timeliney: *

    headerline(
      group(([*Février*], 6)),
      group(([*Mars*], 9)),
      group(([*Avril*], 9)),
      group(([*Mai*], 8)),
      group(([*Juin*], 9)),
      group(([], 1)),
    )

    taskgroup(
      title: [*Connexe*],
      {
        task("Formations", (0, 3))
        task([Rapport de PFE], (28, 34))
        task([Préparation de la\ soutenance], (33, 36))
      },
    )

    taskgroup(
      title: [*SEAPATH Yocto*],
      {
        task([Comparaison des méthodes\ de détection], (2, 9))
        task("Analyse des vulnérabilités", (4, 5), (8, 11))
        task([Migration de la CI], (9, 17))
        task([CI de détection\ des vulnérabilités], (15, 19), (28, 30))
      },
    )

    taskgroup(
      title: [*SEAPATH Debian*],
      {
        task([Étude des approches\ de détection], (17, 19))
        task([Génération de SBOM], (19, 23))
        task([CI de détection\ des vulnérabilités], (23, 25))
      },
    )

    taskgroup(
      title: [*VulnScout*],
      {
        task([Contributions et revues], (5, 7), (25, 36))
        task([Comparaison avec\ Dependency-Track], (20, 23))
      },
    )

    milestone("Visite du stage", at: 22, style: (stroke: (dash: "dashed")))
    milestone(box(fill: white, outset: 1pt)[Rendu du rapport], at: 34, style: (stroke: (dash: "dashed")))
    milestone("Soutenance", at: 36, style: (stroke: (dash: "dashed")))
  },
)

#pagebreak()
== Rapport de comparaison des solutions de détection de vulnérabilité <annex:cve-comparison-report>
#for i in range(1, 5) {
  block(stroke: 1pt, image("../assets/Yocto CVE check report.pdf", page: i), height: 1fr)
  pagebreak()
}

== Raport de comparaison entre VulnScout et Dependency-Track <annex:vulnscout-dependency-track>
#for i in range(1, 11 + 1) {
  block(stroke: 1pt, image("../assets/VulnScout DependencyTrack comparison.pdf", page: i), height: 1fr)
  pagebreak()
}

== Rapport de vulnérabilités généré en CI <annex:vulnscout-report-summary>
#block(stroke: 1pt, image("../assets/vulnscout-report-summary.pdf"), height: 1fr)
