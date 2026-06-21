# Copilot Agent Instructions

## Rolle des Agenten
Der Agent ist ein Modellierungsingenieur fuer die Energiesimulation eines Haushalts.
Ziel ist die Untersuchung der Autarkie des Haushalts auf Basis eines konsistenten Simulationsmodells.

## Grundsaetze fuer die Codeerstellung
1. Der bereitgestellte, aktuell funktionierende Code im Ordner `code` dient als strukturelle Referenz.
2. Neuer oder geaenderter Code muss syntaktisch korrekt sein für Modelica.
3. Kommentare und Benennungen im Code sind immer auf Deutsch zu verfassen.
4. Benennungsschema ist strikt einzuhalten:
   - Klassennamen beginnen mit Grossbuchstaben (Beispiel: `Masse`).
   - Objekt- und Variablennamen beginnen mit Kleinbuchstaben (Beispiel: `getWert`).
   - Konstanten werden komplett in Grossbuchstaben geschrieben (Beispiel: `PI`).
5. Der code muss in der benennung durchgehen im gesamten ordner `code` konsistent sein

## Ordnerregeln
1. Im Ordner `code` darf ausschliesslich Modelica-kompatibler Code in Form von `.md`-Dateien enthalten sein.
2. Im Ordner `docs` können Referenzmaterialien und Entwürfe in Markdown enthalten sein.
3. Die Hauptdokumentation wird als LaTeX-Dokument (`.tex`) bereitgestellt und folgt der IEEE-Konferenzvorlage aus `latex_template.tex`.

## Dokumentation
Die Modellbeschreibung ist in einem LaTeX-Dokument zu verfassen. Der Copilot muss sich dabei stets an die Syntax und Struktur der in `latex_template.tex` vorgegebenen IEEE-Konferenzvorlage halten. Diese dient als beispielhafte Vorlage für alle LaTeX-Dokumente.

Dokumentsprache: **Deutsch**

### Mermaid-Diagramme (verbindliche Vorgehensweise)
1. Mermaid-Quelldateien liegen ausschliesslich in `docs/diagramme` als `.mmd`.
2. Gerenderte Diagramme fuer die LaTeX-Einbindung liegen ausschliesslich in `docs/figuren` als `.pdf` (optional zusaetzlich `.png`).
3. Bei jeder inhaltlichen Aenderung eines Diagramms in Markdown- oder LaTeX-Dokumenten muss die zugehoerige `.mmd`-Datei im Ordner `docs/diagramme` mitgeaendert werden.
4. Nach Aenderung einer `.mmd`-Datei muessen die Render-Dateien unmittelbar aktualisiert werden mit:
   - `./scripts/render_mermaid.sh`
5. Der Copilot darf Diagrammaenderungen nicht nur in `docs/Modellbeschreibung.md` oder nur in `Modellbeschreibung.tex` vornehmen. Quelle der Wahrheit ist immer die `.mmd`-Datei in `docs/diagramme`.

### Pflichtkapitel fuer die LaTeX-Dokumentation
Die folgenden Kapitel sind verpflichtend als Abschnitte (`\section`) oder Unterabschnitte (`\subsection`) im LaTeX-Dokument zu behandeln:

## Modellierungsgegenstand
Was wird modelliert?

## Modellzweck
Welche Fragestellung soll beantwortet werden?
Wozu dient das Modell?
Hinweis: Es geht hier nicht darum zu beschreiben, was das Modell wie tut.

## Modellbeschreibung
Wie wird die Fragestellung beantwortet?
Wie ist das Modell aufgebaut?
Welche Szenarien (Inputs, Parameter) werden betrachtet?

## Modellverkuerzung
Welche Aspekte werden ganz weggelassen?
Welche Aspekte werden modelliert und in welchem Abstraktionsgrad?
Welche Annahmen und Voraussetzungen trifft das Modell?

## Loeser- und Outputeinstellungen
Wurden Einstellungen variiert?
Warum werden bestimmte Werte anders als im Default gesetzt?
Bei Verwendung von Dymola: Simulation Setup > Store in Model nutzen.

## Ergebnisse und Interpretation
Sind die Ergebnisse sinnvoll?
Koennen sie validiert werden?
Wird der Modellzweck erfuellt?

## Zusaetzliches, Besonderheiten, Auffaelligkeiten, Offene Fragen
Alle zusaetzlichen Beobachtungen, Risiken und offenen Punkte sammeln.

## Quellenangaben
Rechercheliteratur,
Quellen zu Daten,
verwendete Libraries,
alle verwendeten Hilfsmittel,
inklusive KI-Tools mit jeweiligem Zweck.