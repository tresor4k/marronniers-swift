// Génère Sources/Marronniers/Data.swift depuis le fichier de données du site (source unique).
// Ne jamais modifier Data.swift à la main.
//
// Usage : node tools/gen_data.mjs [chemin/vers/marronniers-2026-2027.ts]
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const DEFAULT_TS = resolve(
  ROOT,
  "../../Lescreavores/site2/nouveau-site/src/data/tool-content/marronniers-2026-2027.ts",
);
export const DEST = resolve(ROOT, "Sources/Marronniers/Data.swift");
export const FIELDS = ["date", "dateFin", "libelle", "type", "secteurs", "source", "angle"];

function literal(src, marker) {
  const start = src.indexOf(marker);
  if (start < 0) throw new Error(`marker not found: ${marker}`);
  const open = src.indexOf("[", start + marker.length - 1);
  const close = src.indexOf("\n];", open);
  if (open < 0 || close < 0) throw new Error(`array not found after ${marker}`);
  return new Function(`return ${src.slice(open, close + 2)};`)();
}

export function parse(tsPath = DEFAULT_TS) {
  const src = readFileSync(tsPath, "utf-8");
  const entries = literal(src, "export const MARRONNIERS_2026_2027: Marronnier[] =");
  const sectors = literal(src, "export const MARRONNIER_SECTEURS: { id: string; label: string }[] =");
  const rows = (src.match(/^\s*\{ date: "/gm) || []).length;
  if (entries.length !== rows) throw new Error(`parsed ${entries.length} entries, ${rows} rows in file`);
  for (const e of entries) {
    if (Object.keys(e).join() !== FIELDS.join()) throw new Error(`unexpected fields: ${Object.keys(e).join()}`);
    for (const k of FIELDS) {
      if (typeof e[k] !== "string") throw new Error(`non string ${k}`);
      if (/[\u0000-\u001f]/.test(e[k])) throw new Error(`control character in ${k}`);
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(e.date) || !/^\d{4}-\d{2}-\d{2}$/.test(e.dateFin) || e.dateFin < e.date)
      throw new Error(`bad dates: ${e.date} ${e.dateFin}`);
  }
  return { entries, sectors };
}

// Ordre attendu : date de début, ex aequo dans l'ordre de la source (sort est stable).
export const sortByDate = (entries) =>
  entries.map((e, i) => ({ e, i })).sort((a, b) => (a.e.date < b.e.date ? -1 : a.e.date > b.e.date ? 1 : a.i - b.i)).map((x) => x.e);

// Littéral Swift : seuls \ et " sont à échapper (pas de caractère de contrôle, vérifié par parse).
const sw = (s) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;

function generate(tsPath) {
  const { entries, sectors } = parse(tsPath);
  const out = [
    "// GÉNÉRÉ par tools/gen_data.mjs depuis marronniers-2026-2027.ts (Les Créavores). Ne pas modifier.",
    "",
    "extension Marronniers {",
    "    /// Les 7 secteurs et leur libellé, dans l'ordre de l'outil en ligne.",
    "    public static let sectors: [Secteur] = [",
    ...sectors.map((s) => `        Secteur(id: ${sw(s.id)}, label: ${sw(s.label)}),`),
    "    ]",
    "",
    "    /// Toutes les entrées, triées par date de début (ex aequo dans l'ordre de la source).",
    "    public static let all: [Marronnier] = [",
    ...sortByDate(entries).map((e) => `        Marronnier(${FIELDS.map((k) => `${k}: ${sw(e[k])}`).join(", ")}),`),
    "    ]",
    "}",
    "",
  ];
  writeFileSync(DEST, out.join("\n"), { encoding: "utf-8" });
  console.log(`${entries.length} entries, ${sectors.length} sectors -> ${DEST}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) generate(process.argv[2] || DEFAULT_TS);
