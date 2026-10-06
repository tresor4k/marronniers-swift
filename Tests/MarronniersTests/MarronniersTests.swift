import Foundation
import XCTest
@testable import Marronniers

final class MarronniersTests: XCTestCase {
    func testJeuComplet() {
        XCTAssertEqual(Marronniers.all.count, 139)
        XCTAssertEqual(Marronniers.sectors.count, 7)
        XCTAssertEqual(Marronniers.all.first?.date, "2026-09-14")
        XCTAssertEqual(Marronniers.all.last?.date, "2027-12-31")
        for (a, b) in zip(Marronniers.all, Marronniers.all.dropFirst()) {
            XCTAssertLessThanOrEqual(a.date, b.date)
        }
        for m in Marronniers.all {
            XCTAssertLessThanOrEqual(m.date, m.dateFin)
            XCTAssertTrue(["ferie", "fete", "commercial", "journee", "vacances", "saison"].contains(m.type))
        }
    }

    func testUpcoming() {
        let suivants = Marronniers.upcoming(from: "2026-11-20", limit: 3)
        XCTAssertEqual(suivants.map { $0.libelle },
                       ["Mois sans tabac et Movember",
                        "Journée internationale des droits de l'enfant",
                        "Black Friday"])
        XCTAssertEqual(suivants.last?.date, "2026-11-27")
        XCTAssertTrue(Marronniers.upcoming(from: "2028-01-04").isEmpty)
        XCTAssertTrue(Marronniers.upcoming(from: "2026-01-01", limit: 0).isEmpty)
        // 2026-11-20 à 12 h UTC = 13 h à Paris
        let date = Date(timeIntervalSince1970: 1_795_176_000)
        XCTAssertEqual(Marronniers.upcoming(from: date, limit: 3), suivants)
    }

    func testByMonth() {
        let mai = Marronniers.byMonth(year: 2027, month: 5)
        XCTAssertEqual(mai.count, 12)
        XCTAssertTrue(mai.contains { $0.date == "2027-05-30" && $0.libelle == "Fête des mères" })
        XCTAssertTrue(Marronniers.byMonth(year: 2025, month: 1).isEmpty)
        // Vacances de Pâques en Corse : du 25 mars au 12 avril 2027, donc aussi en avril
        XCTAssertTrue(Marronniers.byMonth(year: 2027, month: 4).contains {
            $0.libelle == "Vacances de Pâques en Corse (jusqu'au 12 avril)" && $0.dateFin == "2027-04-12"
        })
    }

    func testSecteurEtType() {
        XCTAssertEqual(Marronniers.byType("ferie").count, 14)
        XCTAssertEqual(Marronniers.forSector("restauration").count, 77)
        XCTAssertEqual(Marronniers.sectors.first, Secteur(id: "commerce", label: "Commerce et e-commerce"))
    }

    /// Contrôle croisé : avec MARRONNIERS_DUMP=chemin, écrit tout le jeu en JSON
    /// pour tools/crosscheck.mjs.
    func testDump() throws {
        guard let chemin = ProcessInfo.processInfo.environment["MARRONNIERS_DUMP"] else { return }
        let entries = Marronniers.all.map {
            ["date": $0.date, "dateFin": $0.dateFin, "libelle": $0.libelle, "type": $0.type,
             "secteurs": $0.secteurs, "source": $0.source, "angle": $0.angle]
        }
        let sectors = Marronniers.sectors.map { ["id": $0.id, "label": $0.label] }
        let json = try JSONSerialization.data(withJSONObject: ["entries": entries, "sectors": sectors])
        try json.write(to: URL(fileURLWithPath: chemin))
    }
}
