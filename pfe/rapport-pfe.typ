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
      Dispositif électronique utilisé dans les systèmes de gestion et de contrôle du réseau électrique. Ils sont capables de collecter des données en temps réel, de prendre des décisions autonomes et d’exécuter des actions telles que l’ouverture ou la fermeture de disjoncteurs en réponse à des conditions anormales du réseau.
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
      Ensemble de pratiques utilisées en génie logiciel consistant à vérifier à chaque modification de code source que le résultat des modifications ne produit pas de régression dans l’application développée.
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
      Ensemble de logiciels qui, associés à un noyau Linux, fournissent un système d’exploitation opérationnel. Ils ne sont pas nécessaires pour que le système démarre, mais offrent les services requis pour le cas d’usage souhaité.
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
      Réseau électrique modernisé qui utilise la technologie numérique, la communication bidirectionnelle et des commandes avancées pour optimiser la génération, la transmission et la distribution d’électricité. Il intègre notamment des sources d’énergie renouvelable pour améliorer l’efficacité et la fiabilité de la distribution.
    ],
  ),
  (
    key: "hyperviseur",
    short: "hyperviseur",
    description: [
      Logiciel ou un matériel permettant de créer et d’exécuter des VMs. Il agit comme un gestionnaire de ressources et de supervision entre les systèmes d’exploitation invités et le matériel physique de l’hôte.
    ],
  ),
  (
    key: "VM",
    short: "VM",
    long: "Machine Virtuelle",
    longplural: "Machines Virtuelles",
    description: [
      Émulation logicielle d’un ordinateur physique qui exécute un système d’exploitation et des applications comme un ordinateur physique, lancée sur un @hyperviseur.
    ],
  ),
  (
    key: "noyau",
    short: "noyau",
    description: [
      Coeur d’un système d’exploitation. Contient les programmes et pilotes essentiels à son fonctionnement, comme la gestion de la mémoire, des processus ou des I/O basiques. Souvent appelé par le terme anglais _kernel_.
    ],
  ),
  (
    key: "RT",
    short: "RT",
    long: "Temps Réel",
    description: [
      Caractéristique d'un système pour lequel le respect des contraintes temporelles dans l’exécution des traitements est aussi important que le résultat de ces traitements.
    ],
  ),
  (
    key: "CPE",
    short: "CPE",
    long: "Common Platform Enumeration",
    longplural: "Common Platform Enumeration",
    description: [
      Schéma de nommage structuré permettant d'identifier des systèmes informatiques, des logiciels, des paquets ou encore du matériel informatique. Peut contenir beaucoup de détails tel que le distributeur, la langue, etc. (à l'inverse du @PURL)
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
      Comité gérant les aspects techniques d'un projet. Il se réunit régulièrement et ses réunions peuvent être ouvertes au public. Sigle issue de l'anglais _Technical Steering Committee_.
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
    Résumé du stage en français.
  ],
  [
    Summary of the internship in english.
  ],
  defense-date: "2026-06-17",
  insa-tutor-suffix: "e",
  insa: "rennes",
  lang: "fr",
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

#include "intro.typ"

#pagebreak()

#include "seapath-yocto.typ"

#pagebreak()

#include "seapath-debian.typ"

#pagebreak()

#include "vulnscout.typ"

//#pagebreak()
= Conclusion
TODO

#pagebreak()
#set heading(numbering: none)
= Glossaire
#print-glossary(
  entry-list,
  entry-sortkey: x => lower(x.key),
  deduplicate-back-references: true,
)
#pagebreak()
#text(size: 10pt, bibliography("../bibliography.yml"))

#pagebreak()
#set heading(numbering: none)

= Annexes
#set heading(numbering: (..nums) => nums.at(1), supplement: [Annexe])
#show heading: it => block(sticky: true)[
  Annexe #counter(heading).display() - #it.body
]

== Planning
*TODO*

#pagebreak()
== Rapport de comparaison des solutions de détection de vulnérabilité <annex:cve-comparison-report>
Le rapport complet est attaché en pièce jointe à ce PDF.
#pdf.attach(
  "../assets/Yocto CVE check report.pdf",
  description: "Rapport sur les différentes solution de détection de vulnérabilités",
  mime-type: "application/pdf",
)

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
