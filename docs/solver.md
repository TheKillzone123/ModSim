# Analyse der Löser-Einstellungen

## Bewertung der gewaehlten Einstellungen

| Einstellung | Aktueller Wert | Warum diese Wahl hier sinnvoll ist | Moegliche Alternativen | Wann die Alternative sinnvoll waere |
| --- | --- | --- | --- | --- |
| Startzeit | `0 s` | Typischer und eindeutiger Simulationsstart fuer ein zeitdiskretes Wochenprofil. Alle Tages- und Wochenfunktionen beziehen sich damit auf einen klaren Nullpunkt. | Keine fachlich notwendige Alternative, ausser verschobener Simulationsstart. | Wenn ein bestimmter Wochentag oder ein anderer Ausschnitt direkt als Startpunkt modelliert werden soll. |
| Stopzeit | `604800 s` | Entspricht exakt 7 Tagen. Das passt zur 5+2-Wochenlogik und erlaubt eine komplette Betrachtung von Werktagen und Wochenende innerhalb eines Laufs. | `86400 s`, `1209600 s` oder andere Mehrtagesfenster. | `86400 s` fuer reine Tagesanalysen; laengere Zeitfenster fuer robustere Aussagen zur Autarkie ueber mehrere Wochen. |
| Toleranz | `1e-4` | Guter Kompromiss aus Rechenzeit und Genauigkeit. Fuer Energiebilanzen und Ladezustandsverlaeufe ist diese Toleranz meist fein genug, ohne den Solver unnoetig zu verlangsamen. | `1e-5`, `1e-6`, `1e-3` | Kleinere Toleranz fuer genauere Transienten- oder Vergleichsanalysen; groessere Toleranz fuer schnellere Langzeitsimulationen mit weniger Fokus auf kleine Abweichungen. |
| Ausgabeintervall | `60 s` | Das Modell arbeitet mit vergleichsweise langsamen Energiefluessen. Ein 60-Sekunden-Raster ist fein genug, um Lastwechsel, EMS-Schaltungen und SOC-Verlaeufe sauber zu sehen, ohne unnoetig viele Datenpunkte zu erzeugen. | `10 s`, `300 s`, `900 s` | `10 s` fuer detailreiche Kurzzeitanalysen; `300 s` oder `900 s` fuer kompaktere Ausgaben, wenn vor allem Tages- oder Wochenenergien interessieren. |
| Anzahl Intervalle | `10080` | Bei 7 Tagen ergibt das exakt 60-Sekunden-Ausgabeschritte. Das ist konsistent zum Ausgabeintervall von `60 s`. | Entsprechend zum gewuenschten Ausgabeintervall anpassbar. | Falls feinere oder grobere Ausgaberasters benoetigt werden. |
| Solver / Algorithmus | `dassl` | DASSL ist fuer Modelica-Modelle mit Differential-Algebraischen Gleichungen sehr passend. Dieses Modell kombiniert Speicherzustaende, begrenzte Leistungen, Schaltlogik, harte Bedingungen und ereignisartige Umschaltungen. Dafuer ist ein robuster impliziter DAE-Loeser die naheliegende Wahl. | `ida`, `cvode`, `radau`, explizit `euler` | Wenn das verwendete Tool einen anderen DAE-Loeser stabiler oder schneller ausfuehrt, oder wenn bewusst sehr einfache bzw. sehr spezielle Transienten untersucht werden. |

## Warum DASSL hier plausibel ist

| Beobachtung im Modell | Relevanz fuer die Solver-Wahl | Auswirkung |
| --- | --- | --- |
| Batterien und EV werden ueber kontinuierliche Zustaende wie SOC beschrieben. | Das erzeugt Differentialgleichungen. | Ein Solver muss kontinuierliche Zustaende stabil integrieren. |
| EMS, Ladefreigaben und Netzgrenzen fuehren zu logischen Umschaltungen. | Das erzeugt Ereignisse und diskrete Zustandswechsel. | Der Solver muss Event-Wechsel robust behandeln. |
| Leistungsfluesse sind gekoppelt und teils durch Bedingungen begrenzt. | Das ist typisch fuer algebraische Anteile bzw. DAE-artiges Verhalten. | Ein impliziter DAE-Loeser ist meist robuster als ein einfacher expliziter Solver. |
| Die Eingangsprofile sind stueckweise konstant im 15-Minuten-Raster. | Es entstehen Sprungstellen in den Eingangsgroessen. | Ein robuster Event-/DAE-Solver reduziert das Risiko numerischer Artefakte an den Sprungstellen. |

## Andere hier grundsaetzlich moegliche Solver

| Solver | Typ | Eignung fuer dieses Modell | Vorteil | Nachteil |
| --- | --- | --- | --- | --- |
| DASSL | Impliziter DAE-Solver | Sehr gut geeignet | Robust bei DAE, Schaltlogik und potenziell steifem Verhalten | Hoeherer Rechenaufwand als einfache explizite Verfahren |
| IDA | Moderner impliziter DAE-Solver | Ebenfalls gut geeignet | Oft aehnliche Staerken wie DASSL, teils bessere Robustheit je nach Toolchain | Nicht in jedem Tool gleich gut verfuegbar oder gleich vorbelegt |
| CVode | ODE-Solver aus SUNDIALS | Bedingt geeignet | Kann bei glatteren Modellen effizient sein | Weniger natuerlich fuer stark DAE-gepraegte oder schaltintensive Modelle |
| Radau / andere implizite Runge-Kutta-Verfahren | Implizit, steifheitsgeeignet | Fachlich moeglich | Gute Stabilitaet bei steifen Systemen | In der Praxis fuer Standard-Modelica-Workflows oft weniger ueblich als DASSL/IDA |
| Euler | Expliziter Einfachsolver | Nur eingeschraenkt geeignet | Sehr einfach, nachvollziehbar, fuer Tests nützlich | Fuer grobere Schritte ungenau und bei steifen oder schaltenden Systemen numerisch fragil |
| Explizite Runge-Kutta-Verfahren | Explizite ODE-Solver | Eher eingeschraenkt geeignet | Gut fuer glatte, nicht steife Modelle | Weniger robust bei DAE-Anteilen, Ereignissen und harten Umschaltungen |

## Fazit

| Frage | Bewertung |
| --- | --- |
| Warum wurde DASSL gewaehlt? | Weil das Modell typische Eigenschaften eines schaltenden DAE-Energiesystems hat: kontinuierliche Speicherzustaende, algebraische Kopplungen, Begrenzungen und Ereignisse. DASSL ist fuer genau diese Kombination ein gaengiger und robuster Standard. |
| Welche Alternativen waeren realistisch? | Vor allem `IDA` als naheliegende Alternative unter den impliziten DAE-Loesern. Fuer Spezialfaelle sind auch `CVode`, `Radau` oder zu Testzwecken `Euler` moeglich. |

## Entscheidungsmatrix fuer die Loeserwahl

Bewertungsskala: `1 = schwach`, `5 = sehr gut`

| Kriterium | Gewicht [%] | DASSL | IDA | CVode | Radau | Euler |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Robustheit bei DAE/algebraischen Kopplungen | 35 | 5 | 5 | 2 | 4 | 1 |
| Robustheit bei Ereignissen/Schaltlogik | 25 | 5 | 4 | 3 | 4 | 2 |
| Genauigkeit fuer Energiebilanzen/SOC | 20 | 4 | 4 | 3 | 4 | 2 |
| Rechenzeit/Effizienz | 10 | 3 | 3 | 4 | 2 | 5 |
| Praktische Toolchain-Verfuegbarkeit | 10 | 5 | 4 | 3 | 2 | 5 |
| Gesamtscore (gewichtete Punkte) | 100 | 4.50 | 4.30 | 2.70 | 3.70 | 1.95 |

### Rechenregel

$$
	ext{Gesamtscore} = \sum_i \left(\frac{\text{Gewicht}_i}{100} \cdot \text{Punkte}_i\right)
$$

### Entscheidung

| Rang | Loeser | Score | Entscheidungshinweis |
| ---: | --- | ---: | --- |
| 1 | DASSL | 4.50 | Empfohlener Standardloeser fuer dieses Modell (DAE + Schaltlogik). |
| 2 | IDA | 4.30 | Sehr gute Alternative, falls im verwendeten Tool stabiler oder schneller. |
| 3 | Radau | 3.70 | Fachlich moeglich, aber meist weniger praktisch in Standard-Workflows. |
| 4 | CVode | 2.70 | Eher fuer glattere ODE-Modelle geeignet. |
| 5 | Euler | 1.95 | Nur fuer sehr einfache Tests mit sehr kleinem Zeitschritt. |