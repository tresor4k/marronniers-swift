import Foundation

/// Une date du calendrier éditorial (« marronnier »).
///
/// Les dates sont des chaînes ISO `AAAA-MM-JJ` ; `dateFin` est égale à `date`
/// pour un jour unique. `secteurs` liste les identifiants de secteur séparés
/// par des virgules, « tous » signifiant tous les secteurs.
public struct Marronnier: Equatable, Hashable {
    /// Premier jour, `AAAA-MM-JJ`.
    public let date: String
    /// Dernier jour, `AAAA-MM-JJ`.
    public let dateFin: String
    public let libelle: String
    /// `ferie`, `fete`, `commercial`, `journee`, `vacances` ou `saison`.
    public let type: String
    public let secteurs: String
    /// Origine de la date (texte officiel, organisation, règle ou usage).
    public let source: String
    /// Idée de publication en une phrase.
    public let angle: String
}

/// Un secteur d'activité : identifiant et libellé en français.
public struct Secteur: Equatable, Hashable {
    public let id: String
    public let label: String
}

/// Calendrier éditorial français de septembre 2026 à décembre 2027, publié par
/// Les Créavores (https://lescreavores.fr/outils/generateur-calendrier-editorial/).
///
/// Chaque fonction renvoie les entrées triées par date de début ; les entrées
/// qui commencent le même jour gardent l'ordre de la source.
public enum Marronniers {
    /// Entrées dont la période chevauche `[debut, fin]` (bornes incluses, `AAAA-MM-JJ`).
    public static func between(_ debut: String, _ fin: String) -> [Marronnier] {
        all.filter { $0.date <= fin && $0.dateFin >= debut }
    }

    /// Entrées qui chevauchent un mois (`month` de 1 à 12).
    public static func byMonth(year: Int, month: Int) -> [Marronnier] {
        let prefixe = String(format: "%04d-%02d", year, month)
        return between(prefixe + "-01", prefixe + "-31")
    }

    /// Entrées d'un secteur (voir `sectors`) ; les entrées « tous » sont toujours incluses.
    public static func forSector(_ id: String) -> [Marronnier] {
        all.filter { m in
            let tags = m.secteurs.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return tags.contains("tous") || tags.contains(id)
        }
    }

    /// Entrées d'un type : `ferie`, `fete`, `commercial`, `journee`, `vacances` ou `saison`.
    public static func byType(_ type: String) -> [Marronnier] {
        all.filter { $0.type == type }
    }

    /// Les `limit` prochaines entrées non terminées au jour `from` (`AAAA-MM-JJ`),
    /// périodes en cours comprises.
    public static func upcoming(from: String, limit: Int = 10) -> [Marronnier] {
        Array(all.filter { $0.dateFin >= from }.prefix(max(0, limit)))
    }

    /// Même chose à partir d'une `Date`, lue dans le fuseau horaire donné (par défaut celui de Paris).
    public static func upcoming(from date: Date = Date(), limit: Int = 10,
                                timeZone: TimeZone = TimeZone(identifier: "Europe/Paris")!) -> [Marronnier] {
        var calendrier = Calendar(identifier: .gregorian)
        calendrier.timeZone = timeZone
        let c = calendrier.dateComponents([.year, .month, .day], from: date)
        return upcoming(from: String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!), limit: limit)
    }
}
