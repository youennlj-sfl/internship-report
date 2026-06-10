
/*# Title: Plan de la soutenance (30 minutes)

Durée totale: 30 minutes

Public: jury à deux membres — un qui a lu le rapport, un chercheur qui ne l'a pas lu. Présenter de manière autonome : expliquer les termes clés et la logique des choix.

Répartition temporelle (suggestion)

1. Titre — 0:30
2. Contexte et enjeux — 3:00
3. Objectifs du stage — 2:00
4. Environnement technique (Yocto vs Debian) — 3:00
5. Méthodologie générale — 2:00
6. Détection basée sur SBOM — 3:00
7. Comparaison des approches testées — 3:00
8. Implémentation SEAPATH Yocto — 2:30
9. Implémentation SEAPATH Debian — 2:00
10. VulnScout, comparaison et contributions — 1:30
11. Résultats et métriques — 2:00
12. Limitations et travaux futurs — 1:30
13. Conclusion et recommandations — 1:00
14. Questions / Demo courte (si prévu) — 3:00

Conseils de présentation

- Utiliser un langage compréhensible pour le chercheur qui n'a pas lu le rapport : définir acronymes (SBOM, CVE, CVSS, EPSS) lors de la première apparition.
- Pour le membre qui a lu le rapport, aller droit au but sur les résultats et apports concrets.
- Prévoir 1 slide « backup » en annexe (exemples de rapports CI, extraits de SBOM, logs) si des questions techniques précises surviennent.

Liste des slides (contenu brut et figures suggérées)

Slide 1 — Titre (0:30)
- Contenu: Titre du projet, nom, entreprise (Savoir-faire Linux), encadrants, date de soutenance
- Figure: logos (Savoir-faire Linux, INSA), éventuellement photo miniature du dispositif SEAPATH.

Slide 2 — Contexte et enjeux (3:00)
- Contenu: Pourquoi la sécurité de SEAPATH est critique (usage en infrastructures critiques), problématiques (vulnérabilités transitant via dépendances, complexité des builds embarqués)
- Figures: schéma simple d'un smart-grid avec emplacement d'un IED/SEAPATH et flux (éditer pour montrer impact), icônes indiquant risque/criticité.

Slide 3 — Objectifs du stage (2:00)
- Contenu: Objectif principal: mise en place d'un suivi automatisé des vulnérabilités pour variantes Yocto et Debian. Objectifs secondaires: rendre les rapports exploitables, réduire faux positifs, intégrer en CI, contributions open source.
- Figures: liste à puces, icônes objectifs (automatisation, CI, qualité des données).

Slide 4 — Environnement technique (Yocto vs Debian) (3:00)
- Contenu: Présenter brièvement Yocto (build système embarqué, couches, recettes) vs Debian (paquets .deb, gestion de paquets), contraintes (reproductibilité, cross-compilation), impact sur détection des vulnérabilités.
- Figures: tableau comparatif Yocto vs Debian (2–3 lignes), diagramme simplifié montrant où et comment chaque variante est construite.

Slide 5 — Méthodologie générale (2:00)
- Contenu: Étapes suivies: collecte des artefacts (SBOMs / packages), normalisation des données, enrichissement (CPE/PURL), matching CVE, filtrage / heuristiques pour réduire faux positifs, intégration CI.
- Figures: workflow linéaire (collecte → normalisation → matching → reporting → CI).

Slide 6 — Détection basée sur SBOM (3:00)
- Contenu: Expliquer ce qu'est un SBOM, ses avantages et limites pour SEAPATH, comment il est généré (outils utilisés), contraintes pour Yocto (noms de paquets, métadonnées manquantes).
- Figures: extrait de SBOM (exemple PURL/CPE), schéma montrant génération de SBOM dans pipeline.

Slide 7 — Comparaison des approches testées (3:00)
- Contenu: Approches évaluées (parsing des images, SBOM, analyse des métadonnées, outils existants : Vulnerability scanners, Dependency-Track, VulnScout). Critères: précision, taux de faux positifs, intégrabilité CI, maintenance.
- Figures: tableau synthétique comparant approches par critères, extrait du rapport annexé (capture d'une page de comparaison) ou graphique radar.

Slide 8 — Implémentation SEAPATH Yocto (2:30)
- Contenu: Ce qui a été concretement modifié pour Yocto : génération SBOM, adaptation des recipes, pipeline CI (où lancer l'analyse), exemples de problèmes rencontrés (naming, versions mis-reportées).
- Figures: diagramme CI (jobs Yocto → génération SBOM → VulnScout/outil → rapport), capture d'écran d'un job CI pertinent.

Slide 9 — Implémentation SEAPATH Debian (2:00)
- Contenu: Processus pour Debian : génération SBOM à partir des paquets, intégration dans CI de packaging, différences majeures avec Yocto.
- Figures: pipeline Debian simplifié, exemple de SBOM généré pour Debian.

Slide 10 — VulnScout : comparaison & contributions (1:30)
- Contenu: Présentation rapide de VulnScout (rôle dans le projet), comparaison synthétique avec Dependency-Track (points forts/faibles), contributions (PRs, reviews) réalisées durant le stage.
- Figures: logos, mini-tableau comparatif, liste courte des PRs importantes (numéros ou titres si souhaité).

Slide 11 — Résultats et métriques (2:00)
- Contenu: Résultats clés : détection (ex : nombre de vulnérabilités identifiées), évolution (ex : réduction faux positifs après filtrage), rapport d'exemple envoyé aux mainteneurs, intégration régulière en CI.
- Figures: graphique (barres/ligne) montrant nombre de CVE détectées avant/après filtrage ou par méthode, capture d'un rapport CI (extrait PDF image dans les annexes).

Slide 12 — Limitations et travaux futurs (1:30)
- Contenu: Limites connues : qualité des métadonnées, faux positifs résiduels, résilience des pipelines, couverture des CVE pour composants non-packagés. Voies futures : enrichissement SBOM, heuristiques ML, meilleure corrélation binaire/source, monitoring continu.
- Figures: bullet points, flèche montrant roadmap 6–12 mois.

Slide 13 — Conclusion et recommandations (1:00)
- Contenu: Rappel des apports concrets (automatisation, rapports exploitables, contributions open source), recommandations opérationnelles pour les mainteneurs (intégrer checks en CI, prioriser triage, maintenir SBOMs à jour).
- Figures: 3–4 takeaways visuels (icônes + phrase courte).

Slide 14 — Questions et démonstration courte (3:00)
- Contenu: Laisser le reste du temps pour questions. Si une démo courte est prévue, montrer un pipeline CI en action ou un rapport généré (préparer un replay local ou captures vidéo/screenshot pour ne pas dépendre du réseau).
- Figures: capture vidéo ou GIF ou lien vers demo; slide « backup » avec références aux annexes du rapport.

Annexes / Slides de secours (non comptées dans le temps principal)
- Extraits de rapports PDF (annexes existantes dans rapport) : Yocto CVE check report, VulnScout vs Dependency-Track, rapport CI de vulnérabilités.
- Exemples de règles de filtrage, extraits de SBOM, logs de CI détaillés.

Checklist pour la soutenance

- Préparer 1 slide par minute maximum, mais privilégier 12–14 slides pour 30 minutes.
- Avoir 1 slide de backup technique (logs, extraits SBOM, PRs) pour répondre aux questions du chercheur technique.
- Savoir expliquer en 30s ce qu'est un SBOM et pourquoi il est utile.
- Préparer une phrase d'ouverture simple qui situe le problème en une minute pour le juré qui n'a pas lu le rapport.

Fin du plan
*/

#let is-preview = "x-preview" in sys.inputs

#import "@local/silky-slides-insa:0.2.0": *

#set text(lang: "fr")
#show figure.caption: set text(size: 17pt)

#show: insa-slides.with(
  title: "Soutenance de PFE",
  title-visual: pad(top: 155pt, left: -20pt, block(
    fill: insa-colors.tertiary.transparentize(60%),
    inset: 1em,
    stack(
      spacing: 1em,
      image("../assets/savoirfairelinux_logo.png", width: 60%),
      image("../assets/lfenergy-seapath-logo-color.svg", width: 60%),
    ),
  )),
  subtitle: text(size: 24pt)[
    Maintien en condition de sécurité de #box[LF Energy SEAPATH]
  ],
  insa: "rennes",
  text-size: 20pt,
  config-page(
    margin: 1.25cm,
  ),
  config-common(
    //show-bibliography-as-footnote: bibliography("bibliography.yml"),
    // footnotes are too big
    show-notes-on-second-screen: if is-preview { none } else { right },
  ),
)

#import "@preview/fletcher:0.5.8"

= Contexte et enjeux
//== Les postes électriques et leur transition
== Le réseau électrique en transformation
- Consommation d'énergies renouvelables +65% en 11 ans @sdes-2025
  - Besoin de *repenser gestion du réseau électrique* : _smart grids_
#figure(
  image("../assets/Electrical_substation_model_(side-view).png", height: 30%),
  caption: [Vue en coupe d'un *poste électrique*],
)
- Nombreux équipements : disjoncteurs, transformateurs, etc.
- Contrôlés par des _Intelligent Electronic Devices_ (IEDs)
  - Défis des _smart grids_ : besoin de *virtualiser* les IEDs

== Place de SEAPATH @seapath
#slide(composer: (1fr, 1.5fr))[
  Hyperviseur :
  - héberge des *IEDs virtuels*

  Contraintes :
  - *temps réel*
  - *haute disponibilité*

  Ouvert :
  - *open source*\ co-mainteneurs :
    - Savoir-faire Linux
    - RTE International
  - basé sur le noyau Linux
][
  #let cropped-img = box(
    figure(image("../assets/seapath_in_substation-V5.svg")),
    clip: true,
    inset: (
      left: -17%,
      right: -9%,
      top: -10%,
    ),
  )
  #align(center, cropped-img) // pas de figure ici, aucune idée de la caption
]

== Architecture de SEAPATH et enjeux
#slide(
  composer: (1.6fr, 1fr),
  figure(image("../assets/seapath_technology_stack.png"), caption: [Architecture générale de SEAPATH]),
  align(horizon)[
    #sym.approx Distribution Linux : Assemblage de nombreux composants logiciels.

    #text(size: 1.2em, weight: "extrabold")[Quelles vulnérabilités ?]

    SEAPATH destiné à des infrastructures _critiques_ !

    Législations : CRA (UE) /\ #h(1em) Exec. Order 14028 (USA)
  ],
)

= Présentation du stage
== Missions
- *Recherche/comparaison* des *solutions de détection de vulnérabilités*
//  - Sélection de la meilleure solution avec des données précises

- *Mise en place* des solutions retenues
//  - Dans les 2 variantes principales de SEAPATH
//  - Les inclure dans les pipelines d'intégration continue

- *Analyser* les vulnérabilités remontées
  - En utilisant le projet *VulnScout* @vulnscout de Savoir-faire Linux
//  - Les corriger si possible
//  - Réduire le nombre de faux positifs
#speaker-note[
  Présenter rapidement VulnScout
]

#cols(columns: (1fr, auto))[
  But recherché pour SEAPATH :

  - Vue facile sur les vulnérabilités présentes dans SEAPATH
    - Transparent pour les utilisateurs

    - Mainteneurs peuvent potentiellement corriger en cas de vulnérabilité majeure
][
  #figure(image("../assets/vulnscout.jpg", width: 6cm))

]

== Savoir-faire Linux
#slide(composer: (1fr, 8cm))[
  *Entreprise de Services Numériques* d'origine québécoise fondée en 1999.

  Spécialité : technologies *libres*, systèmes et applications sous *Linux*.

  Deux bureaux :
  - *Montréal*, +50 collaborateurs, logiciels open source
  - *Rennes*, \~15 collaborateurs (majorité d'ingénieurs en informatique), spécialisé Linux embarqué

  Engagé activement dans l'open source : salons, contributions à de grands projets, e.g. Yocto @yoctoproject.
][
  #figure(image("../assets/savoirfairelinux_logo.png", width: 100%), caption: [Logo de l'entreprise])
  #v(2em)
  #figure(image("../assets/jami.webp", width: 3cm), caption: [Jami @jami, un logiciel développé par SFL])
]

//== Environnement technique

== Méthodologie générale de détection des vulnérabilités
SEAPATH #sym.approx distribution Linux : *centaines de composants*

#sym.arrow.double *impossible* de détecter les failles dans le code (surface trop grande)

#pause
#v(1em)
Notre approche : utiliser les *bases de données de vulnérabilités*

- besoin de liste des composants présents = *SBOM*
- à faire générer avec SEAPATH

#figure(
  text(size: 17pt, fletcher.diagram(
    node-stroke: 1pt,
    node-inset: 0.5em,
    node-fill: insa-colors.tertiary.lighten(50%),
    spacing: 1.5em,
    {
      import fletcher: *

      node((0, 0), width: 4cm, height: 3cm)[Collecte des paquets]
      edge("-|>")
      node((1, 0), width: 4cm, height: 3cm)[Génération des SBOMs]
      edge("-|>")
      node((2, 0), width: 5cm, height: 3cm)[Enrichissement des données]
      edge("-|>")
      node(
        (3, 0),
        width: 5cm,
        height: 3cm,
        stroke: 2pt,
        fill: insa-colors.secondary.lighten(80%),
      )[Mise en correspondance avec BDD#footnote[BDD : Base de données]]
      edge("-|>")
      node((4, 0), width: 5cm, height: 3cm)[Filtrage des vulnérabilités (heuristiques)]
    },
  )),
  caption: [Processus de détection des vulnérabilités],
)

#speaker-note[
  Schéma haut niveau, on va voir chaque étape

  BDD = base de données, évoquer exemples (NVD, CVE...)
]

== Les SBOMs
#v(-1.5em)
#text(size: 0.92em, quote(
  block: true,
  attribution: [UE 2024/2847],
)[_Source Bills of Materials_ / Nomenclatures Logicielles : Document contenant les *détails* et les *relations* avec la chaîne d’approvisionnement des différents *composants* utilisés dans la fabrication d’un produit comportant des éléments numériques.])

#cols(columns: (1fr, auto))[
  - Requis par les futures législations (CRA @cra-article)

  - Contenu :
    - *composants* : nom, versions, licences, etc.
    - *fichiers*
    - *relations* : contient / dépend de / décrit par / ...

  - Interopérable, outils de *génération automatique*

  - Formats standards : SPDX, CycloneDX
][
  #grid(
    columns: 9cm,
    rows: 2,
    gutter: 1em,
    figure(
      image("../assets/spdx-logo.png"),
      caption: [Standard ISO\ (Linux Foundation)],
    ),
    figure(image("../assets/cyclonedx-logo.png"), caption: [Standard ecma\ (OWASP)]),
  )
]

#speaker-note[
  Dire que le contenu est très utile pour détecter vulnérabilités (identifiants composants)
]

= Détection de vulnérabilités sur SEAPATH Yocto
#import "@preview/meander:0.4.3"
== Environnement technique : Yocto
#meander.reflow({
  import meander: *

  placed(top + right, figure(image("../assets/Yocto_Project_logo.svg", width: 7cm)))

  container()

  content[
    - Projet open source, Fondation Linux
    - Ensemble d'outils pour créer des *distributions Linux embarquées*
    #v(1em)
    Construction du système avec BitBake :
    - Image construite _from scratch_ : *compiler les sources*, empaqueter, etc.
    - Décrit entièrement *via du code*
      - tout est connu : programmes, librairies, fichiers compilés...
      - *facile de générer un SBOM*
  ]
})
#pause
#figure(
  text(size: 17pt, fletcher.diagram(
    node-stroke: 1pt,
    node-inset: 0.5em,
    node-fill: insa-colors.tertiary.lighten(50%),
    spacing: 2em,
    {
      import fletcher: *

      node((0, 0), width: 4.5cm, height: 2.5cm)[Récupération des sources]
      edge("-|>")
      node((1, 0), width: 4.5cm, height: 2.5cm)[Compilation des paquets]
      edge("-|>")
      node((2, 0), width: 4.5cm, height: 2.5cm)[Génération du système de fichiers]
      edge("-|>")
      node((3, 0), width: 4.5cm, height: 2.5cm)[Création de l'image]
    },
  )),
  caption: [Processus de construction d'une image avec Yocto],
)

#speaker-note[
  Parler de l'embarqué

  Décrire "image"

  On connaît les versions des programmes puisque c'est dans le code : nickel pour SBOM

  Aucun binaire opaque inclus
]

== Étude des approches de détection de vulnérabilités

#cols(
  columns: (1fr, 4cm),
)[
  - Approches utilisant les SBOMs :
    - *Grype* @grype-in-production : scanneur orienté distributions et conteneurs
    - *sbom-cve-check* @sbom-cve-check : détecteur orienté Yocto

  #pause
  #figure(
    text(size: 17pt, fletcher.diagram(
      node-stroke: 1pt,
      node-inset: 0.5em,
      node-fill: insa-colors.tertiary.lighten(50%),
      spacing: 1.5em,
      {
        import fletcher: *

        node((0, 0), width: 4.5cm, height: 2.5cm)[Chargement du SBOM]
        edge("-|>")
        node((1, 0), width: 5cm, height: 2.5cm)[Téléchargement des BDD]
        edge("-|>")
        node((2, 0), width: 5cm, height: 2.5cm)[Mise en correspondance]
        edge("-|>")
        node((3, 0), width: 4.5cm, height: 2.5cm)[Export des résultats]
      },
    )),
  )
][
  #meanwhile
  #figure(image("../assets/grype-logo-name.png", width: 100%))
]
#pause
#pause

- Approche sans SBOMs : *_cve-check_*, classe pré-faite de Yocto
  - cherche les vulnérabilités lors de la construction de l'image

#pause
#figure(
  text(size: 17pt, fletcher.diagram(
    node-stroke: 1pt,
    node-inset: 0.5em,
    node-fill: insa-colors.tertiary.lighten(50%),
    spacing: 2em,
    {
      import fletcher: *

      node((0, 0), width: 4.5cm, height: 2.5cm)[Récupération des sources]
      edge("-|>")
      node((1, 0), width: 4.5cm, height: 2.5cm)[Compilation des paquets]
      edge("-|>")
      node(
        (2, 0),
        width: 5cm,
        height: 2.5cm,
        stroke: 2pt,
        fill: insa-colors.secondary.lighten(80%),
      )[Mise en correspondance avec BDD]
      edge("-|>")
      node((3, 0), width: 4.5cm, height: 2.5cm)[Génération du système de fichiers]
      edge("-|>")
      node((4, 0), width: 4.5cm, height: 2.5cm)[Création de l'image]
    },
  )),
)

== Évaluation des approches
#meander.reflow({
  import meander: *

  placed(top + right, figure(text(size: 18pt, table(
    columns: 3,
    inset: 0.5em,
    [], [Vuln.\ trouvée], [Vuln.\ applicable],
    [Faux positif], [#sym.checkmark], [#sym.crossmark],
    [Faux négatif], [#sym.crossmark], [#sym.checkmark],
  ))))

  container()

  content[
    Critères :
    - *nombre total* de vulnérabilités trouvées

    - taux de *faux positifs / faux négatifs*

    - facilité d'utilisation / d'automatisation

    Évaluation et comparaisons sur SEAPATH.
  ]
})



/*

Slide 7 — Comparaison des approches testées (3:00)
- Contenu: Approches évaluées (parsing des images, SBOM, analyse des métadonnées, outils existants : Vulnerability scanners, Dependency-Track, VulnScout). Critères: précision, taux de faux positifs, intégrabilité CI, maintenance.
- Figures: tableau synthétique comparant approches par critères, extrait du rapport annexé (capture d'une page de comparaison) ou graphique radar.

Slide 8 — Implémentation SEAPATH Yocto (2:30)
- Contenu: Ce qui a été concretement modifié pour Yocto : génération SBOM, adaptation des recipes, pipeline CI (où lancer l'analyse), exemples de problèmes rencontrés (naming, versions mis-reportées).
- Figures: diagramme CI (jobs Yocto → génération SBOM → VulnScout/outil → rapport), capture d'écran d'un job CI pertinent.

Slide 9 — Implémentation SEAPATH Debian (2:00)
- Contenu: Processus pour Debian : génération SBOM à partir des paquets, intégration dans CI de packaging, différences majeures avec Yocto.
- Figures: pipeline Debian simplifié, exemple de SBOM généré pour Debian.

Slide 10 — VulnScout : comparaison & contributions (1:30)
- Contenu: Présentation rapide de VulnScout (rôle dans le projet), comparaison synthétique avec Dependency-Track (points forts/faibles), contributions (PRs, reviews) réalisées durant le stage.
- Figures: logos, mini-tableau comparatif, liste courte des PRs importantes (numéros ou titres si souhaité).

Slide 11 — Résultats et métriques (2:00)
- Contenu: Résultats clés : détection (ex : nombre de vulnérabilités identifiées), évolution (ex : réduction faux positifs après filtrage), rapport d'exemple envoyé aux mainteneurs, intégration régulière en CI.
- Figures: graphique (barres/ligne) montrant nombre de CVE détectées avant/après filtrage ou par méthode, capture d'un rapport CI (extrait PDF image dans les annexes).

Slide 12 — Limitations et travaux futurs (1:30)
- Contenu: Limites connues : qualité des métadonnées, faux positifs résiduels, résilience des pipelines, couverture des CVE pour composants non-packagés. Voies futures : enrichissement SBOM, heuristiques ML, meilleure corrélation binaire/source, monitoring continu.
- Figures: bullet points, flèche montrant roadmap 6–12 mois.

Slide 13 — Conclusion et recommandations (1:00)
- Contenu: Rappel des apports concrets (automatisation, rapports exploitables, contributions open source), recommandations opérationnelles pour les mainteneurs (intégrer checks en CI, prioriser triage, maintenir SBOMs à jour).
- Figures: 3–4 takeaways visuels (icônes + phrase courte).

Slide 14 — Questions et démonstration courte (3:00)
- Contenu: Laisser le reste du temps pour questions. Si une démo courte est prévue, montrer un pipeline CI en action ou un rapport généré (préparer un replay local ou captures vidéo/screenshot pour ne pas dépendre du réseau).
- Figures: capture vidéo ou GIF ou lien vers demo; slide « backup » avec références aux annexes du rapport.

Annexes / Slides de secours (non comptées dans le temps principal)
- Extraits de rapports PDF (annexes existantes dans rapport) : Yocto CVE check report, VulnScout vs Dependency-Track, rapport CI de vulnérabilités.
- Exemples de règles de filtrage, extraits de SBOM, logs de CI détaillés.
*/


---
// #magic.bibliography()
#show bibliography: set heading(outlined: false)
#set text(size: 16pt)
#bibliography("../bibliography.yml")
