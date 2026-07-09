# Moduluebersicht und Berechnungen

Dieses Dokument beschreibt kurz, was jedes Modul im Ordner [code](../code) macht und welche Berechnungen darin stattfinden.

| Modul | Kurzbeschreibung | Zentrale Berechnungen |
| --- | --- | --- |
| BatterieEinfach | Einfaches Hausbatterie-Modell mit Lade-/Entladegrenzen, SOC-Schutz und Wirkungsgraden. | Leistungsbegrenzung: `P_begrenzt = min(max(P_soll, -P_entladen_max), P_laden_max)`; SOC-Schutz (bei `SOC_max` nicht laden, bei `SOC_min` nicht entladen); Wirkungsgradabbildung `P_wirk = eta_laden*P_batt` (Laden) bzw. `P_wirk = P_batt/eta_entladen` (Entladen); Energiedynamik `der(E)=P_wirk`; SOC-Bildung `SOC = min(max(E/Emax_J, SOC_min), SOC_max)`. |
| BatterieEinfachV2G | EV-nahe Batterie mit Praesenzsignal, optionalem V2G und SOC-Reset bei Ankunft. | Nur bei Praesenz aktiv; Lade-/Entladebegrenzung wie oben; Entladung nur wenn `v2gAktiv` und `SOC_intern > SOC_min`; Energiedynamik `der(E)=P_wirk`; SOC aus `E/Emax_J`; Ruecksetzlogik per `when setSOC then reinit(E, SOC_set_val*Emax_J)`. |
| EMS | Energie-Management-System fuer Aufteilung von PV-Leistung auf Hausbatterie, EV und Netz. | Ueberschuss/Defizit: `P_uberschuss = P_PV - P_Last`; Batterieregelung mit Schwellwerten und SOC-Grenzen; EV-V2G nur bei Defizit, EV-Praesenz und SOC-Bedingungen; EV-Laden bei Ueberschuss bzw. erzwungenem Mindest-SOC; Netzrestausgleich mit Import-/Exportlimits; momentane Autarkie: `100*(1-max(P_Grid_soll,0)/P_Last)`. |
| EV_Batterie | Alternative EV-Batteriekomponente mit EV-Aktivierung, Praesenz und V2G-Freigabe. | Begrenzung `P_soll` auf Lade-/Entladeleistung; Entladung nur bei `v2gAktiv`; SOC-Schutz; Wirkungsgradabbildung Laden/Entladen; Energiedynamik `der(E)=P_wirk`; SOC-Bildung aus `E/Emax_J` mit Klemmen auf `[SOC_min, SOC_max]`. |
| E_Auto | EV-Subsystem als Kopplung aus Anwesenheitsprofil (`InputFunktionEV`) und Batterie (`BatterieEinfachV2G`). | Keine eigene numerische Energieberechnung; verbindet Signale: `present`, `setSOC`, `SOC_set_val`, `P_soll`, `SOC`; bildet daraus die EV-Ausgaenge `P_EV`, `SOC_EV`, `EV_present_out`. |
| HausSystem_V3 | Top-Level-Systemmodell (PV-Input, Hausbatterie, EV, EMS, Monitoring, Simulationsende). | Automatisches Simulationsende via `simEnde_s` und `terminate()`; Energieintegration: `der(energie_verbrauch_Wh)=P_Last/3600`, `der(energie_netz_bezug_Wh)=max(P_Grid_soll,0)/3600`; kumulierte Autarkie: `100*(1-energie_netz_bezug_Wh/energie_verbrauch_Wh)` (mit Schutz bei kleinem Nenner). |
| InputFunktionEV | Erzeugt EV-Praesenz und SOC-Setzimpulse aus 15-Minuten-Profilen fuer Woche/Wochenende. | Zeitabbildung `zeitImTag=mod(time,86400)`; 15-Minuten-Index aus `floor(zeitImTag/900)+1`; Wochentagslogik (5+2 oder alternierend); Praesenzwahl aus Rasterfeldern; bei Abfahrt Merken von `socBeimVerlassen`; bei Rueckkehr Absenkung `soc_hold = clamp(socBeimVerlassen - socAbsenkungRueckkehr)`; Impuls `setSOC = edge(presentIntern)`. |
| InputFunktion_V2 | Liefert PV- und Lastprofile aus internen 15-Minuten-Tabellen (Sommer/Winter, Woche/Wochenende). | Zeitdiskretisierung auf 15-Minuten-Bins; Tages- und Wochenlogik wie bei EV-Input; Indexbegrenzung auf `[1..97]`; Auswahl der Profilwerte per Index: `P_PV` aus Sommer/Winter-Tabelle, `P_Last` aus Woche/Wochenende-Tabelle. |

## Hinweis zur Modellstruktur

- Kontinuierliche Dynamik steckt vor allem in den Batteriekomponenten ueber `der(E)`.
- Diskrete Ereignisse entstehen ueber `when`/`edge` (z. B. EV-Ankunft).
- Das EMS ist primär regelbasiert mit Grenzwerten (`min`/`max`) und Schwellwertlogik.
