# Marronniers (Swift)

Bibliothèque Swift publiée par [Les Créavores](https://lescreavores.fr/), sans
dépendance : le calendrier éditorial français (les « marronniers », ces dates qui
reviennent chaque année dans la presse et chez les marques) de septembre 2026 à
décembre 2027. Elle sert à planifier publications sur les réseaux sociaux,
newsletters ou articles de blog autour des dates qui comptent pour un public
français.

- 139 dates, du 14/09/2026 au 31/12/2027 (une période se termine le 03/01/2028)
- Types : `ferie` (jour férié), `fete` (fête), `commercial` (temps fort
  commercial), `journee` (journée mondiale ou nationale), `vacances` (vacances
  scolaires), `saison` (soldes et saisons)
- 7 secteurs : `commerce`, `restauration`, `beaute`, `artisanat`, `b2b`,
  `sante`, `immobilier` ; une entrée marquée `tous` vaut pour chaque secteur
- Chaque entrée donne sa source et une idée de publication (`angle`)

La même API existe en Java, Clojure et Haxe :
[tresor4k/marronniers](https://github.com/tresor4k/marronniers).

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/tresor4k/marronniers-swift.git", from: "0.1.0")
],
targets: [
    .target(name: "MonApp", dependencies: [
        .product(name: "Marronniers", package: "marronniers-swift")
    ])
]
```

## Utilisation

```swift
import Marronniers

// Les 5 prochaines dates non terminées à une date donnée (périodes en cours comprises)
for m in Marronniers.upcoming(from: "2026-11-20", limit: 5) {
    print(m.date, m.libelle) // 2026-11-01 Mois sans tabac et Movember ...
}

// À partir d'aujourd'hui (jour lu dans le fuseau de Paris)
Marronniers.upcoming(limit: 5)

// Toutes les dates de mai 2027, triées par date de début
Marronniers.byMonth(year: 2027, month: 5) // ... 2027-05-30 Fête des mères

// Les dates d'un restaurant (entrées « tous » comprises)
Marronniers.forSector("restauration")

// Les jours fériés seulement
Marronniers.byType("ferie")

// Toute entrée qui chevauche une période (bornes incluses, AAAA-MM-JJ)
Marronniers.between("2026-10-01", "2026-12-31")

// Identifiants et libellés des secteurs
Marronniers.sectors // [Secteur(id: "commerce", label: "Commerce et e-commerce"), ...]
```

## Méthode

Chaque date est soit fixe (fête légale, journée mondiale à date fixe, tradition
datée), soit calculée par une règle publique (Pâques 2027 = 28 mars ; fête des
mères = dernier dimanche de mai sauf Pentecôte ; Black Friday = lendemain du
4e jeudi de novembre ; soldes = code de commerce), soit lue dans un texte
officiel (arrêtés fixant les calendriers scolaires 2026-2027 et 2027-2028,
calendrier des soldes du ministère de l'Économie). Les journées mondiales sans
date fixe ni règle publique sont volontairement absentes.

`Sources/Marronniers/Data.swift` est généré depuis le fichier de données de
l'outil en ligne (`tools/gen_data.mjs`), et un contrôle croisé compare chaque
champ de chaque entrée avec ce fichier (`tools/crosscheck.mjs`, zéro écart
exigé) : [générateur de calendrier éditorial en ligne](https://lescreavores.fr/outils/generateur-calendrier-editorial/).

## Licence

MIT, voir LICENSE.
