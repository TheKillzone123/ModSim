# Parameterliste und Herkunftsstatus

Diese Datei dient als Uebersicht ueber die im Code verwendeten Parameter und deren Herkunftsstatus.

Legende:
- Belegt oder hergeleitet: Wert ist in der Modellbeschreibung oder in einer externen Quelle beschrieben.
- Modellannahme: Wert ist bewusst gesetzt, aber nicht extern belegt.
- Abgeleitet: Wert ergibt sich rechnerisch aus anderen Parametern.
- Legacy-Default: Wert stammt aus einer Standalone-Version und wird im Gesamtmodell teilweise nur noch als Voreinstellung genutzt.

## Werte ohne direkte externe Referenz

Die folgenden Werte tauchen im Code als feste Schwellen oder Defaults auf, ohne dass sie in den Quellen direkt als Mess- oder Herstellerwert belegt sind:

### Nicht direkt in der Modellbeschreibung genannt

| Wert | Internetquelle(n) | Projektquelle | Plausible wissenschaftliche Begründung |
| --- | --- | --- | --- |
| `P_ev_schwelle_laden = 500 W` | [Shareef 2020](https://doi.org/10.3390/app10134533), [Althaher 2015](https://doi.org/10.1109/tsg.2014.2388357), [Blonsky 2022](https://doi.org/10.1016/j.apenergy.2022.119770) | Code: [code/EMS.md](../code/EMS.md) | Regelbasierte Home-Energy-Management-Systeme arbeiten in der Literatur mit Schwellwerten, Hysterese und Entscheidungslogik, um Schaltflattern zu vermeiden. 500 W ist hier kein Paper-Exaktwert, sondern ein konservativer Deadband-Filter fuer Restueberschuss. |
| `P_v2g_min_defizit = 100 W` | [Ortega-Vazquez 2014](https://doi.org/10.1049/iet-gtd.2013.0624), [Khalid 2021](https://doi.org/10.1109/access.2021.3112189) | Code: [code/EMS.md](../code/EMS.md) | V2G-Entladung wird in der Literatur typischerweise nur bei echter Lastsituation und unter Nebenbedingungen aktiviert. 100 W ist ein sehr kleiner Ausloese-Offset, der numerisches Hin- und Herschalten reduziert. |
| `P_netz_max_import = 6000 W` im Standalone-EMS | [Khalid 2021](https://doi.org/10.1109/access.2021.3112189), [Engelhardt 2022](https://doi.org/10.1016/j.etran.2022.100198) | Code: [code/EMS.md](../code/EMS.md) | Kein exakter Paperwert, sondern konservative Modellwahl im kW-Bereich. Die Literatur ordnet Lade- und Netzleistungen fuer Wohn- und EV-Anwendungen klar im Bereich weniger Kilowatt ein. Hier jedoch nicht relewant da von HausSystem_V3 überschrieben und nur noch ein relikt. Hier jedoch nicht relewant da von HausSystem_V3 überschrieben und nur noch ein relikt.|
| `socAbsenkungRueckkehr = 0.10` im Standalone-Modul | [Chowdhury 2024](https://doi.org/10.1016/j.est.2023.110001), [Ortega-Vazquez 2014](https://doi.org/10.1049/iet-gtd.2013.0624) | Code: [code/InputFunktionEV.md](../code/InputFunktionEV.md) | Die Literatur zeigt, dass Ladefenster und SOC-Fenster den Alterungs- und Betriebszustand des Fahrzeugs beeinflussen. 0.10 ist hier eine bewusst einfache, konservative Annahme fuer einen typischen Fahrtag. Hier jedoch nicht relewant da von HausSystem_V3 überschrieben und nur noch ein relikt aus Tests. |
| `P_laden_max = 3000 W` und `P_entladen_max = 3000 W` in BatterieEinfach/BatterieEinfachV2G | [Khalid 2021](https://doi.org/10.1109/access.2021.3112189), [Engelhardt 2022](https://doi.org/10.1016/j.etran.2022.100198) | Code: [code/BatterieEinfach.md](../code/BatterieEinfach.md), [code/BatterieEinfachV2G.md](../code/BatterieEinfachV2G.md) | In der Literatur werden Heimspeicher und EV-nahe Ladeleistungen in der Groessenordnung weniger Kilowatt beschrieben. 3 kW ist damit ein plausibler Standalone-Default mit etwas Headroom gegenueber dem im Gesamtsystem verwendeten 2.5 kW-Wert. Hier jedoch nicht relewant da von HausSystem_V3 überschrieben und nur noch ein relikt. |
| `kapazitaet_Wh = 40000 Wh`, `SOC0 = 0.4`, `SOC_min = 0.10`, `P_entladen_max = 3300 W` in E_Auto/EV_Batterie | [Khalid 2021](https://doi.org/10.1109/access.2021.3112189), [Ortega-Vazquez 2014](https://doi.org/10.1049/iet-gtd.2013.0624) | Code: [code/E_Auto.md](../code/E_Auto.md), [code/EV_Batterie.md](../code/EV_Batterie.md) | Das sind Legacy-Defaults fuer einen generischen EV-Baustein. Die Literatur stuetzt den Bereich: EV-Batterien, SOC-Fenster und V2G-Limits werden typischerweise konservativ im mittleren Ladebereich und mit wenigen Kilowatt Entladeleistung modelliert. Hier jedoch nicht relewant da von HausSystem_V3 überschrieben und nur noch ein relikt. |

### Internetquellen fuer die wissenschaftliche Plausibilisierung

| Kurzverweis | Typ | Kernaussage fuer dieses Projekt |
| --- | --- | --- |
| [Chowdhury 2024](https://doi.org/10.1016/j.est.2023.110001) | Paper | Einfluss des SOC-Fensters auf die Degradation von Tesla-Lithium-Ionen-Zellen; geeignet zur Begruendung enger SOC-Limits und schonender Betriebsfenster. |
| [Ortega-Vazquez 2014](https://doi.org/10.1049/iet-gtd.2013.0624) | Paper | Haushaltsnahe EV-Lade- und V2G-Optimierung unter Batteriedegradation und Preisunsicherheit; stuetzt SOC- und Betriebsgrenzen. |
| [Shareef 2020](https://doi.org/10.3390/app10134533) | Paper | Regelbasiertes Home Energy Management; geeignet zur Begruendung von Schwellwert- und Hysterese-Logik. |
| [Althaher 2015](https://doi.org/10.1109/tsg.2014.2388357) | Paper | Demand-Response im HEMS unter Leistungs- und Komfortgrenzen; stuetzt heuristische Regelketten. |
| [Blonsky 2022](https://doi.org/10.1016/j.apenergy.2022.119770) | Paper | Vergleich heuristischer, deterministischer und stochastischer HEMS-Methoden unter Unsicherheit; geeignet zur Einordnung einfacher Schwellenlogik. |
| [Khalid 2021](https://doi.org/10.1109/access.2021.3112189) | Review | Uebersicht zu Ladeleistungen, Topologien und Standards von EV-Ladestationen; stuetzt die Einordnung von kW-Groessenordnungen. |
| [Engelhardt 2022](https://doi.org/10.1016/j.etran.2022.100198) | Paper | Energiemanagement fuer mehrbatteriegestuetztes EV-Laden; hilfreich fuer kW-basierte Leistungsgrenzen und Speicherkoordination. |

### Bereits in der Modellbeschreibung genannt oder hergeleitet

Die folgenden Werte sind im Projekt bereits fachlich hergeleitet und werden hier nur zur Vollstaendigkeit aufgefuehrt:

- `SOC0 = 0.5` fuer die Hausbatterie: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) als Start-SOC 50% dokumentiert.
- `P_netz_max_export = 10000 W`: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) und [docs/Modellbeschreibung.tex](../Modellbeschreibung.tex#L211) als Netzausgleichsgrenze beschrieben.
- `P_batt_laden_max = 2500 W` und `P_batt_entladen_max = 2500 W`: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) und [docs/Modellbeschreibung.tex](../Modellbeschreibung.tex#L95) als 2.5 kW Lade-/Entladegrenze dokumentiert.
- `SOC_min = 0.05`, `SOC_max = 0.95`: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L160-L164) als harte SOC-Limits genannt.
- `SOC_max = 0.95`, `P_laden_max = 11000 W` im EV-Kontext: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L95) und [docs/Modellbeschreibung.md](Modellbeschreibung.md#L228-L229) als EV-Grenzen beschrieben.
- `P_netz_max_import = 10000 W`, `P_netz_max_export = 10000 W` im Gesamtmodell: in [docs/Modellbeschreibung.md](Modellbeschreibung.md#L398-L404) als Ausgangsgrenzen des Netzausgleichs gefuehrt.

### Bereits in der Modellbeschreibung genannt oder hergeleitet

| Wert | Projektquelle | Beleg in der Doku |
| --- | --- | --- |
| `SOC0 = 0.5` fuer die Hausbatterie | Code: [code/HausSystem_V.md](../code/HausSystem_V.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) als Start-SOC 50% dokumentiert. |
| `P_netz_max_export = 10000 W` | Code: [code/HausSystem_V.md](../code/HausSystem_V.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) und [docs/Modellbeschreibung.tex](../Modellbeschreibung.tex#L211-L212) als Netzausgleichsgrenze beschrieben. |
| `P_batt_laden_max = 2500 W` und `P_batt_entladen_max = 2500 W` | Code: [code/HausSystem_V.md](../code/HausSystem_V.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L302-L305) und [docs/Modellbeschreibung.tex](../Modellbeschreibung.tex#L95) als 2.5 kW Lade-/Entladegrenze dokumentiert. |
| `SOC_min = 0.05`, `SOC_max = 0.95` | Code: [code/BatterieEinfach.md](../code/BatterieEinfach.md), [code/EV_Batterie.md](../code/EV_Batterie.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L160-L164) als harte SOC-Limits genannt. |
| `SOC_max = 0.95`, `P_laden_max = 11000 W` im EV-Kontext | Code: [code/HausSystem_V.md](../code/HausSystem_V.md), [code/E_Auto.md](../code/E_Auto.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L95-L95) und [docs/Modellbeschreibung.md](Modellbeschreibung.md#L228-L229) als EV-Grenzen beschrieben. |
| `P_netz_max_import = 10000 W`, `P_netz_max_export = 10000 W` im Gesamtmodell | Code: [code/HausSystem_V.md](../code/HausSystem_V.md) | In [docs/Modellbeschreibung.md](Modellbeschreibung.md#L398-L404) als Ausgangsgrenzen des Netzausgleichs gefuehrt. |

## Vollstaendige Inventarliste nach Datei

### BatterieEinfach

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `kapazitaet_Wh` | ohne Default | Belegt im aufrufenden Modell | Kapazitaet wird von `HausSystem_V3` gesetzt |
| `SOC0` | 0.5 | Legacy-Default | Standalone-Voreinstellung |
| `SOC_min` | 0.05 | Belegt / Modellannahme | In der Doku als harter SOC-Grenzwert beschrieben |
| `SOC_max` | 0.95 | Belegt / Modellannahme | In der Doku als harter SOC-Grenzwert beschrieben |
| `P_laden_max` | 3000 W | Modellannahme | Standalone-Voreinstellung |
| `P_entladen_max` | 3000 W | Modellannahme | Standalone-Voreinstellung |
| `eta_laden` | 0.95 | Belegt | In der Doku als konstanter Wirkungsgrad genannt |
| `eta_entladen` | 0.95 | Belegt | In der Doku als konstanter Wirkungsgrad genannt |
| `Emax_J` | `kapazitaet_Wh * 3600` | Abgeleitet | Reiner Umrechnungswert |

### BatterieEinfachV2G

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `v2gAktiv` | false | Modellannahme | Schaltet bidirektionale Entladung frei oder sperrt sie |
| `kapazitaet_Wh` | ohne Default | Belegt im aufrufenden Modell | Kapazitaet wird von `HausSystem_V3` oder `E_Auto` gesetzt |
| `SOC0` | 0.5 | Legacy-Default | Standalone-Voreinstellung |
| `SOC_min` | 0.05 | Belegt / Modellannahme | Harte Untergrenze |
| `SOC_max` | 0.95 | Belegt / Modellannahme | Harte Obergrenze |
| `P_laden_max` | 3000 W | Modellannahme | Standalone-Voreinstellung |
| `P_entladen_max` | 3000 W | Modellannahme | Standalone-Voreinstellung |
| `eta_laden` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `eta_entladen` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `Emax_J` | `kapazitaet_Wh * 3600` | Abgeleitet | Reiner Umrechnungswert |

### EMS

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `SOC_batt_min_entladen` | 0.05 | Belegt / Modellannahme | Hausbatterie soll nicht unter diesen SOC entladen |
| `SOC_batt_min_laden` | 0.30 | Modellannahme | Heuristische Ladeschwelle |
| `SOC_batt_max_laden` | 0.80 | Modellannahme | Heuristischer Ladestopp |
| `P_batt_laden_max` | 2500 W | Modellannahme | Interne Hausbatterie-Grenze |
| `P_batt_entladen_max` | 2500 W | Modellannahme | Interne Hausbatterie-Grenze |
| `v2gAktiv` | false | Modellannahme | V2G-Freigabe |
| `SOC_EV_min_v2g` | 0.60 | Modellannahme | V2G-Entladung erst oberhalb dieser Schwelle |
| `P_v2g_min_defizit` | 100 W | Modellannahme | Startschwelle fuer V2G-Einsatz |
| `P_ev_entladen_max` | 3300 W | Modellannahme | Maximal moegliche EV-Entladeleistung |
| `SOC_EV_min_laden` | 0.30 | Modellannahme | Mindest-SOC fuer das EV bei Anwesenheit |
| `P_ev_schwelle_laden` | 500 W | Modellannahme | Rest-Ueberschuss fuer EV-Ladung |
| `P_ev_laden_max` | 11000 W | Belegt / modellintern | Effektive EV-Ladeleistung im aktuellen Aufbau |
| `netzAktiv` | true | Modellannahme | Netzanbindung an oder aus |
| `P_netz_max_import` | 6000 W | Modellannahme | Standalone-Default des EMS |
| `P_netz_max_export` | 10000 W | Modellannahme | Exportgrenze des EMS |

### EV_Batterie

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `EV_aktiv` | true | Modellannahme | EV-Modul aktiviert |
| `v2gAktiv` | false | Modellannahme | Bidirektionales Laden aus oder an |
| `kapazitaet_Wh` | 40000 Wh | Legacy-Default | Standalone-Voreinstellung, nicht der Wert des Gesamtmodells |
| `SOC0` | 0.4 | Legacy-Default | Standalone-Voreinstellung |
| `SOC_min` | 0.10 | Legacy-Default | Standalone-Untergrenze |
| `SOC_max` | 0.95 | Legacy-Default | Standalone-Obergrenze |
| `P_laden_max` | 11000 W | Modellannahme | Fahrzeugseitiges Lade-Limit |
| `P_entladen_max` | 3300 W | Modellannahme | Fahrzeugseitiges V2G-Limit |
| `eta_laden` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `eta_entladen` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `Emax_J` | `kapazitaet_Wh * 3600` | Abgeleitet | Reiner Umrechnungswert |

### E_Auto

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `EV_aktiv` | true | Modellannahme | Schaltet das EV-Modul ein |
| `istWoche` | true | Modellannahme | Rueckfalllogik fuer Wochentage |
| `nutze5plus2` | true | Modellannahme | Aktiviert die 5+2-Logik |
| `startWochentag` | 1 | Modellannahme | 1 = Montag |
| `socAbsenkungRueckkehr` | 0.10 | Modellannahme | Rueckkehrabzug im Standalone-Modul |
| `v2gAktiv` | false | Modellannahme | V2G-Freigabe |
| `kapazitaet_Wh` | 40000 Wh | Legacy-Default | Standalone-Voreinstellung |
| `SOC0` | 0.4 | Legacy-Default | Standalone-Voreinstellung |
| `SOC_min` | 0.10 | Legacy-Default | Standalone-Untergrenze |
| `SOC_max` | 0.95 | Legacy-Default | Standalone-Obergrenze |
| `P_laden_max` | 11000 W | Modellannahme | Fahrzeugseitiges Lade-Limit |
| `P_entladen_max` | 3300 W | Modellannahme | Fahrzeugseitiges V2G-Limit |
| `eta_laden` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `eta_entladen` | 0.95 | Belegt | Konstanter Wirkungsgrad |

### HausSystem_V3

| Parameter | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `nutzeSommer` | true | Modellannahme | Sommer- oder Winterprofil |
| `nutze5plus2` | true | Modellannahme | Automatische 5+2-Woche |
| `startWochentag` | 1 | Modellannahme | Starttag der Simulation |
| `istWoche` | true | Modellannahme | Rueckfalllogik fuer Profile |
| `netzAktiv` | true | Modellannahme | Netzanbindung aktiv |
| `P_netz_max_import` | 10000 W | Modellannahme | Gesamtmodell-Grenze |
| `P_netz_max_export` | 10000 W | Modellannahme | Gesamtmodell-Grenze |
| `automatischeSimDauer` | true | Modellannahme | Automatische Laufzeitwahl |
| `kapazitaet_Batt_Wh` | 5100 Wh | Belegt | Hausbatterie-Kapazitaet aus dem Gesamtmodell |
| `SOC0_Batt` | 0.5 | Modellannahme | Start-SOC der Hausbatterie |
| `SOC_batt_min_entladen` | 0.05 | Belegt / Modellannahme | Untere Grenze der Hausbatterie |
| `SOC_batt_max` | 0.95 | Belegt / Modellannahme | Obere Grenze der Hausbatterie |
| `P_batt_laden_max` | 2500 W | Modellannahme | Hausbatterie-Limit |
| `P_batt_entladen_max` | 2500 W | Modellannahme | Hausbatterie-Limit |
| `eta_batt_laden` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `eta_batt_entladen` | 0.95 | Belegt | Konstanter Wirkungsgrad |
| `SOC_batt_min_laden` | 0.30 | Modellannahme | Heuristische Ladeschwelle |
| `SOC_batt_max_laden` | 0.80 | Modellannahme | Heuristischer Ladestopp |
| `EV_aktiv` | true | Modellannahme | EV im Gesamtmodell aktiv |
| `socAbsenkungRueckkehr` | `8300.0 / kapazitaet_EV_Wh` | Abgeleitet | Rueckkehrabzug aus 50 km und 16,6 kWh/100 km |
| `v2gAktiv` | false | Modellannahme | V2G-Freigabe |
| `SOC_EV_min_v2g` | 0.60 | Modellannahme | V2G-Entladungsschwelle |
| `P_v2g_min_defizit` | 100 W | Modellannahme | V2G-Startschwelle |
| `P_ev_entladen_max` | 3300 W | Modellannahme | EV-V2G-Limit |
| `kapazitaet_EV_Wh` | 66500 Wh | Belegt | EV-Kapazitaet des Gesamtmodells |
| `SOC0_EV` | 0.8 | Belegt / Modellannahme | Start-SOC des EV im Wochenbeginn-Szenario |
| `P_wallbox_laden_max` | 22000 W | Belegt | Hardwaregrenze des verwendeten Ladegeraets |
| `P_ev_laden_max` | 11000 W | Modellannahme | Fahrzeugseitiges Lade-Limit |
| `P_ev_laden_effektiv_max` | `min(P_wallbox_laden_max, P_ev_laden_max)` | Abgeleitet | Effektives Lade-Limit |
| `SOC_EV_min_laden` | 0.30 | Modellannahme | Mindest-SOC fuer das EV bei Anwesenheit |
| `P_ev_schwelle_laden` | 1500 W | Modellannahme | Ueberschuss-Schwelle fuer EV-Ladung |
| `simDauerTag_s` | 86400 s | Abgeleitet | Sekunden pro Tag |
| `simDauerWoche_s` | 604800 s | Abgeleitet | Sekunden pro Woche |
| `simEnde_s` | dynamisch | Abgeleitet | Aus Dauerlogik bestimmt |
| `energie_verbrauch_Wh` | dynamisch | Abgeleitet | Kumulierte Verbrauchsenergie |
| `energie_netz_bezug_Wh` | dynamisch | Abgeleitet | Kumulierte Netzbezugsenergie |

### InputFunktionEV

| Parameter / Datenreihe | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `EV_aktiv` | true | Modellannahme | EV-Praesenzlogik an oder aus |
| `istWoche` | true | Modellannahme | Rueckfalllogik fuer Wochentage |
| `nutze5plus2` | true | Modellannahme | 5+2-Wochenlogik |
| `startWochentag` | 1 | Modellannahme | 1 = Montag |
| `socAbsenkungRueckkehr` | 0.10 | Modellannahme | Standardwert im Standalone-Modul |
| `anzahlPunkte` | 97 | Abgeleitet | 96 Viertelstunden plus Endpunkt |
| `evPraesenzWoche` | 15-Minuten-Raster | Modellannahme | Interne Zeitreihe fuer Werktage |
| `evPraesenzWochenende` | 15-Minuten-Raster | Modellannahme | Interne Zeitreihe fuer Wochenende |
| `socBeimVerlassen` | Startwert 0.8 | Modellannahme | Anfangszustand fuer Rueckkehrlogik |
| `soc_hold` | Startwert 0.7 | Modellannahme | Anfangszustand fuer Rueckkehr-SOC |

### InputFunktion_V2

| Parameter / Datenreihe | Wert / Default | Status | Bemerkung |
| --- | --- | --- | --- |
| `dateiPfad` | leer | Modellannahme | Datei wird laut Code ignoriert |
| `nutzeSommer` | true | Modellannahme | Sommer- oder Winterprofil |
| `istWoche` | true | Modellannahme | Rueckfalllogik fuer Wochentage |
| `nutze5plus2` | true | Modellannahme | 5+2-Wochenlogik |
| `startWochentag` | 1 | Modellannahme | 1 = Montag |
| `anzahlPunkte` | 97 | Abgeleitet | 96 Viertelstunden plus Endpunkt |
| `pvSommerW` | 15-Minuten-Raster | Belegt / hergeleitet | Sommerprofil, in der Doku auf Juni-Ertrag normiert |
| `pvWinterW` | 15-Minuten-Raster | Belegt / hergeleitet | Winterprofil, in der Doku auf Januar-Ertrag normiert |
| `lastWocheW` | 15-Minuten-Raster | Belegt | Wochentags-Lastprofil aus dem realen Haushalt |
| `lastWochenendeW` | 15-Minuten-Raster | Belegt | Wochenend-Lastprofil aus dem realen Haushalt |

## Kurzfazit

Die meisten technisch relevanten Kernwerte sind im Dokumentationsstand bereits hergeleitet oder als Modellannahmen kenntlich gemacht. Die groessten offenen Herkunftspunkte sind die heuristischen EMS-Schwellen, die Legacy-Defaults der Standalone-Modelle und einige Netzgrenzen. Wenn gewuenscht, kann diese Liste als naechster Schritt noch in eine strengere Dreierklassifikation umgebaut werden:

1. direkt extern belegt
2. aus Doku hergeleitet
3. reine Modellannahme ohne Quelle