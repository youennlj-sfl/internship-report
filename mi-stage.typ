#import "@local/silky-slides-insa:0.2.0": *

#set text(lang: "fr")

#show: insa-slides.with(
  title: "Visite de mi-stage",
  subtitle: [
    Maintien en condition de sécurité de #box[LF Energy SEAPATH]
  ],
  insa: "rennes",
  text-size: 20pt,
  config-page(
    margin: 2em,
  ),
  config-common(
    //show-bibliography-as-footnote: bibliography("bibliography.yml"),
    // footnotes are too big
  ),
)

= SEAPATH
== Présentation
#slide(composer: (1fr, auto))[
  SEAPATH @seapath :
  - hyperviseur (VMs)
  - temps réel
  - haute disponibilité
  - basé sur le noyau Linux

  Usage :
  - postes électriques

  2 versions :
  - Debian @debian
  - Yocto @yoctoproject
][
  #let cropped-img = box(image("assets/seapath_in_substation-V5.svg"), clip: true, inset: (
    left: -100pt,
    right: -50pt,
    top: -50pt,
  ))
  #align(center, utils.fit-to-height(grow: false, shrink: false, cropped-img))
]

== Problématique du stage
#set list(marker: (sym.circle.filled.tiny, sym.plus, sym.diamond.filled.medium))
Pas de visibilité sur les CVEs (vulnérabilités) présentes dans SEAPATH.

- mise en place d'outils pour *détecter les vulnérabilités*
  - utilisation de *SBOMs* (Software Bill Of Materials)
  - à faire dans les deux versions de SEAPATH

- *analyse des CVEs remontées*
  - vérifier si applicables
  - corriger si possible

- mettre en place du *monitoring* pour que cela soit fait en continu
  - via les CI/CD existantes

- utiliser l'outil *VulnScout* @vulnscout développé par Savoir-faire Linux

#slide[
  #set outline.entry(fill: line(stroke: (1pt + luma(50%)), length: 100%))
  #set list(spacing: 2em)
  #show heading: it => {
    it
    v(1fr)
  }
  #show outline.entry: it => list.item(link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  ))
  #context outline(
    target: heading.where(level: 1),
  )
  #v(1fr)
]

= CVEs sur SEAPATH Yocto
== Détection des CVEs : possibilités
- SEAPATH Yocto = distribution *déclarée en code* (Bitbake)\ #sym.arrow facile de générer un SBOM

- différentes techniques pour détecter les CVEs :
  - *générer un SBOM* puis utiliser un *outil de matching* sur le SBOM
  - utiliser l'*outil "cve-check" intégré* à Yocto pour détecter les CVEs
    - possiblement avec des *scripts de filtrage* supplémentaires\ (filtre les CVEs non compilées du noyaux Linux)

- différents technologies :
  - formats de SBOM : SPDX2, SPDX3, CycloneDX, OpenVEX @sbom-study
  - outils de matching : Grype @grype-in-production, sbom-cve-check @sbom-cve-check

== Détection des CVEs : travail préliminaire
- Mise en place des outils pour prise en main.

- Pour établir une comparaison, sélection de plusieurs scénarios :
  - "cve-check" de Yocto avec plus ou moins de scripts de filtrage
  - Génération de SBOMs (SPDX2 et OpenVEX) puis ingestion dans #box["sbom-cve-check"] pour détection des CVEs

- *Évaluation quantitative* des résultats de ces 3 scénarios :
  - comparaison du *nombre total de CVEs* remontées
  - évaluation du *nombre de faux positifs et faux négatifs*

- Sélection de la meilleure solution pour notre cas d'usage

- Écriture d'un rapport à publier ensuite en billet de blog

== Détection des CVEs : rapport sur la détection dans Yocto
#utils.fit-to-height(stack(
  dir: ltr,
  ..range(1, 4).map(i => image("assets/Yocto CVE check report.pdf", page: i)),
))

== Analyse des CVEs
- Quantité de CVEs potentiellement applicable assez importante (\~ 130)

- *Choix de la portée* de l'analyse faite dans SEAPATH :
  - CVEs critiques ($"CVSS" >= 9.0$)
  - CVEs importantes et facilement exploitables ($"CVSS" >= 9.0 and "EPSS" >= 50%$)

- Avec ces critères, reste \~ 15 CVEs à analyser

- La plupart sont des faux positifs :
  - Dépendent de *configuration spécifiques non présentes* dans SEAPATH
    - Ajout d'exceptions dans le code de SEAPATH
  - *Pas de version cible* dans les bases de données publiques de CVEs
    - Correction et contribution au Yocto Project via les _mailing lists_

== Intégration en CI
Intérêts :
- rendre publique la liste de CVEs détectées
- faire échouer les PR (Pull Requests) lorsqu'elles rajoutent des vulnérabilités

Travail effectué :
- réécriture de la CI (Jenkins @jenkins #sym.arrow GitHub Actions @github-actions)
  - gros travail de synchronisation entre les différents dépôts

- détection des CVEs dans la CI avec la méthode sélectionnée précédemment

- mise en place de lancements quotidiens pour chercher nouvelles CVEs

- feedback sur les PR en fonction des résultats de la CI

---
#utils.fit-to-height(image("assets/ci-workflows.png"))
---
#slide(composer: (1fr, 1.2fr))[
  #utils.fit-to-height(image("assets/pr-comment-cve-detected.png"))
][
  #utils.fit-to-height(box(clip: true, inset: (left: -200pt, top: -10pt), image("assets/ci-workflow-cve-detected.png")))
]


= Travail sur VulnScout
== Présentation
#place(bottom + right, dy: -20%, image("assets/vulnscout.jpg", width: 30%))
- Outil d'*évaluation de vulnérabilités*

- Développé par Savoir-faire Linux (équipe à Montréal), open-source

- Récent : annoncé en mars 2025, toujours en version bêta

- Versatile : supporte de nombreux formats de SBOMs

- Très intégré dans Yocto

#text(font: insa-heading-fonts, size: 1.1em)[*Relation avec SEAPATH :*]

- Utilisé pour évaluer les CVEs

- Utilisé dans la CI:
  - *génération de rapports* sur les CVEs
  - vérification des *CVEs critiques* (condition établie précédemment)

== Contributions
- Bloquants au fil de l'utilisation pour SEAPATH :
  - ajout de *fonctionnalités manquantes*
  - correction de *bugs*

- Amélioration de la base de code
  - typage
  - linting

- *Revues de code* pour les autres personnes de l'équipe

- Participation aux *réunions hebdomadaires* et aux planifications des cycles de développement

== Comparaison avec Dependency-Track
- Autre logiciel open-source de vérifications de vulnérabilités

- Existe depuis plus de 10 ans

- Qu'est-ce que VulnScout peut apporter ?
  - Déploiement d'une instance
  - Expérimentations dessus
  - Comparaison avec VulnScout
  - Écriture d'un rapport


= CVEs sur SEAPATH Debian
== Détection des CVEs : possibilités

- Distribution construite sur base Debian
  - liste de paquets à installer
  - scripts et fichiers de configuration
  - images de conteneurs à intégrer
  - #sym.arrow.double impossible de générer un SBOM à partir des sources comme avec Yocto

- Autre approche : *générer SBOM à partir du système de fichiers*
  - utilisation de Syft @syft

- Deux possibilités :
  + construire image #sym.arrow déployer sur une machine #sym.arrow lancer Syft
  + intégrer Syft *dans la construction de l'image*
    - plus complexe mais plus pratique
    - solution retenue

== Détection des CVEs : travail

- Création d'un _hook_ pour faire le scan des fichiers durant la construction

- Modifications dans le script de construction de l'image
  - Refactoring
  - Intégration des images conteneurs
  - Récupération des fichiers de scans créés

Reste à faire :

- Corriger les anciens scripts pour qu'ils restent fonctionnels

- Analyser le SBOM et regarder les CVEs détectées

- Intégration dans la CI

// mentionner les contribs sur le script pour rendre tout possible
// mentionner image docker

---
// #magic.bibliography()
#show bibliography: set heading(outlined: false)
#set text(size: 16pt)
#bibliography("bibliography.yml")

Notes :
- souligner que la condition a été choisie arbitrairement mais qu'on s'est posés des questions
  - discussions avec personnes concernées, etc.
- montrer qu'on est ingénieur BAC+5
  - prises de décisions
  - questionnements
- se préparer aux questions orientées recherche (résultats...)
- être précis rigoureux *scientifique* (Gildas Avoine !)
- améliorer => quelle métrique ?
  - e.g. pour typage, linting => indicateurs ?
- présenter l'entreprise dans la soutenance
  - assez en détails vu que c'est pas une entreprise connue
  - dire avec qui on travaille : développeurs, taille de l'équipe, Canada...
- mentionner les contributions dans le rapport
- clairement mentionner les problèmes rencontrés puis les solutions pour montrer qu'on réfléchit tout ça
  - même si c'est pas résolu, on a pris une autre route
  - aussi dans la soutenance (moins exhaustif)
- être technique dans le rapport
- l'auditeur ne lit pas le rapport
  - ne pas considérer que les détails sont dans le rapport (= être trop général)
- slides + illustrées, - de mots
  - montrer des graphiques genre pour les comparaisons
- rapport :
  - regarder consignes moodle sur les pages importantes
  - date de rendu
- travail supplémentaire hors scope du stage :
  - soit faire une section si suffisamment de travail
  - soit mentionner dans la conclusion

- présenter CVE, CVSS, tout ça
- présenter contenu SBOM : paquets, versions, licenses, relations (compilateur), ...
- dire que les rapports que je fais vont servir à la boîte
  - e.g. pour faire des offres

- pour la présentation de l'entreprise, réutiliser truc de Tanguy et Benjamin
