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
2. Der Ordner `docs` ist ausschliesslich fuer die Projektdokumentation in Markdown vorgesehen.

## Pflichtkapitel fuer die Dokumentation in `docs`
Die folgenden Kapitel sind verpflichtend zu behandeln:

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