model InputFunktionEV
  // ===========================
  // Parameter
  // ===========================
  parameter Boolean EV_aktiv = true "EV aktivieren (Ein/Aus)";
  parameter Boolean istWoche = true "true = unter der Woche, false = Wochenende";
  parameter Boolean nutze5plus2 = true
    "true = automatische 5+2-Woche (Mo-Fr Woche, Sa-So Wochenende)";
  parameter Integer startWochentag(min=1, max=7) = 1
    "Wochentag bei Simulationsstart: 1=Mo ... 7=So";
  parameter Real socAbsenkungRueckkehr(min=0, max=1) = 0.10
    "SOC-Absenkung bei Rückkehr [0..1], z.B. 0.10 = 10%";

  // ===========================
  // Eingänge
  // ===========================
  Modelica.Blocks.Interfaces.RealInput SOC_aktuell
    "Aktueller EV-SOC aus Batterie [0..1]"
    annotation(Placement(transformation(extent={{-120,-10},{-100,10}}),
                         iconTransformation(extent={{-120,-10},{-100,10}})));

  // ===========================
  // Ausgänge (an EV_Batterie anschließen)
  // ===========================
  Modelica.Blocks.Interfaces.BooleanOutput present
    "1 = EV anwesend/angesteckt"
    annotation(Placement(transformation(extent={{100,40},{120,60}}),
                         iconTransformation(extent={{100,40},{120,60}})));

  Modelica.Blocks.Interfaces.BooleanOutput setSOC
    "Impuls: SOC bei Ankunft setzen"
    annotation(Placement(transformation(extent={{100,0},{120,20}}),
                         iconTransformation(extent={{100,0},{120,20}})));

  Modelica.Blocks.Interfaces.RealOutput SOC_set_val
    "SOC-Wert bei Ankunft [0..1]"
    annotation(Placement(transformation(extent={{100,-40},{120,-20}}),
                         iconTransformation(extent={{100,-40},{120,-20}})));

protected 
  parameter Integer anzahlPunkte = 97 "96x15min + Endpunkt bei 24h";

  // EV-Praesenzprofil im 15-Minuten-Raster (1=anwesend, 0=abwesend)
  // Woche: 07:00-18:00 abwesend
  parameter Real evPraesenzWoche[anzahlPunkte] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1
  };

  // Wochenende: anwesend, aber 10:00-12:00 Uhr abwesend
  parameter Real evPraesenzWochenende[anzahlPunkte] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  };

  Real zeitImTag "Sekunden im aktuellen Tag [0..86400)";
  Integer index15minRoh "Unbegrenzter 15-Minuten-Index";
  Integer index15min "Index fuer 15-Minuten-Wert";
  Integer tagIndex "Tagindex ab Simulationsstart";
  Integer wochentagIndex "1=Mo ... 7=So";
  Boolean istWocheIntern "Interne Auswahl Woche/Wochenende";
  Boolean istWocheStart "Starttyp fuer alternierenden Fallback";
  Boolean presentIntern(start=false, fixed=true) "Interner Präsenzzustand";
  Real socBeimVerlassen(start=0.8, fixed=true) "Gemerkter SOC beim Verlassen";
  Real soc_hold(start=0.7, fixed=true) "SOC-Wert bei Ankunft [0..1]";

equation 
  // Tageszeit fuer zyklische Mehrtages-Simulation
  zeitImTag = mod(time, 86400);
  index15minRoh = integer(floor(zeitImTag/900)) + 1;
  tagIndex = integer(floor(time/86400));
  wochentagIndex = 1 + mod(startWochentag - 1 + tagIndex, 7);
  istWocheStart = istWoche;
  istWocheIntern = if nutze5plus2 then
                     (wochentagIndex <= 5)
                   else
                     (if istWocheStart then mod(tagIndex, 2) == 0 else mod(tagIndex, 2) == 1);

  // Begrenzung des 15-Minuten-Index auf gueltigen Bereich
  index15min = if index15minRoh < 1 then 1 else if index15minRoh > anzahlPunkte then anzahlPunkte else index15minRoh;

  // Praesenzprofil aus kompakten Rasterwerten
  presentIntern = if EV_aktiv then
                    (if istWocheIntern then evPraesenzWoche[index15min] > 0.5 else evPraesenzWochenende[index15min] > 0.5)
                  else
                    false;

  // SOC beim Verlassen merken
  when (not presentIntern) and pre(presentIntern) then
    socBeimVerlassen = SOC_aktuell;
  end when;

  // Bei Rückkehr SOC mit definierter Absenkung setzen
  when presentIntern and not pre(presentIntern) then
    soc_hold = min(max(socBeimVerlassen - socAbsenkungRueckkehr, 0.0), 1.0);
  end when;

  // Präsenz: EV anwesend gemäß Zeitplan
  present = presentIntern;

  // SOC-Setzimpuls und -wert ausgeben
  setSOC      = edge(presentIntern);
  SOC_set_val = soc_hold;

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics = {
        Rectangle(extent={{-100,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid),
        Text(extent={{-90,24},{90,50}}, textString="Input EV",
             fontSize=12, textColor={0,0,0}),
        Ellipse(extent={{92,62},{112,42}}, lineColor={0,0,127}, fillColor={255,220,220},
                fillPattern=FillPattern.Solid),
        Text(extent={{-50,50},{-10,60}}, textString="present"),
        Ellipse(extent={{92,22},{112,2}}, lineColor={0,0,127}, fillColor={255,255,200},
                fillPattern=FillPattern.Solid),
        Text(extent={{-50,10},{-10,20}}, textString="setSOC"),
        Text(extent={{-98,-10},{-60,0}}, textString="SOC_in"),
        Ellipse(extent={{92,-18},{112,-38}}, lineColor={0,0,127}, fillColor={220,255,220},
                fillPattern=FillPattern.Solid),
        Text(extent={{-60,-30},{-10,-20}}, textString="SOC_set_val")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

end InputFunktionEV;
