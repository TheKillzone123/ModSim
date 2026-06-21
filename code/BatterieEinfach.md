model BatterieEinfach
  // ===========================
  // Parameter
  // ===========================
  parameter Real kapazitaet_Wh "Nennkapazität [Wh]";
  parameter Real SOC0 = 0.5     "Start-SOC [0..1]";
  parameter Real SOC_min = 0.05 "untere SOC-Grenze";
  parameter Real SOC_max = 0.95 "obere SOC-Grenze";

  parameter Real P_laden_max    = 3000 "Maximale Ladeleistung [W]";
  parameter Real P_entladen_max = 3000 "Maximale Entladeleistung [W]";

  parameter Real eta_laden    = 0.95 "Wirkungsgrad Laden";
  parameter Real eta_entladen = 0.95 "Wirkungsgrad Entladen";

  // ===========================
  // Anschlüsse (grafisch platziert)
  // ===========================
  Modelica.Blocks.Interfaces.RealInput P_soll
    "Soll-Leistung [W], +laden, -entladen"
    annotation(
      Placement(transformation(extent={{-120,-10},{-100,10}}),
                iconTransformation(extent={{-120,-10},{-100,10}})));

  Modelica.Blocks.Interfaces.RealOutput P_batt
    "Umgesetzte Leistung [W] (+in Batterie)"
    annotation(
      Placement(transformation(extent={{100,10},{120,30}}),
                iconTransformation(extent={{100,10},{120,30}})));

  Modelica.Blocks.Interfaces.RealOutput SOC
    "Ladezustand 0..1"
    annotation(
      Placement(transformation(extent={{100,-30},{120,-10}}),
                iconTransformation(extent={{100,-30},{120,-10}})));

protected 
  // Interner Energiezustand (in Joule)
  parameter Real Emax_J = kapazitaet_Wh*3600 "Maximale Energie [J]";
  Real E(stateSelect=StateSelect.prefer) "Gespeicherte Energie [J]";

  // Hilfsgrößen
  Real P_begrenzt "Leistung nach technischen Limits";
  Real P_wirk     "Wirksame Leistung (mit Wirkungsgraden)";

equation 
  // 1) Leistung auf max. Laden/Entladen begrenzen
  P_begrenzt = min(max(P_soll, -P_entladen_max), P_laden_max);

  // 2) SOC-Schutz: bei voll nicht laden, bei leer nicht entladen
  P_batt = if (SOC >= SOC_max and P_begrenzt > 0) then 0
           else if (SOC <= SOC_min and P_begrenzt < 0) then 0
           else P_begrenzt;

  // 3) Wirkungsgrad anwenden
  //    Laden: Energiezuwachs = eta_laden * P_batt
  //    Entladen: Energieabnahme = |P_batt| / eta_entladen
  P_wirk = if P_batt >= 0 then 
    eta_laden*P_batt
    else 
    P_batt/eta_entladen;

  // 4) Dynamik: Energie integrieren
  der(E) = P_wirk;

  // 5) SOC-Berechnung mit Sättigung auf [SOC_min, SOC_max] (Anzeige)
  SOC = min(max(E/Emax_J, SOC_min), SOC_max);

initial equation 
  // Anfangsenergie gemäß SOC0, auf gültigen Bereich geklemmt
  E = min(max(SOC0*Emax_J, SOC_min*Emax_J), SOC_max*Emax_J);

  // ===========================
  // Grafik / Icon
  // ===========================
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics = {
        Rectangle(extent={{-100,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid),
        Text(extent={{-90,24},{90,50}},
             textString="Batterie", lineColor={0,0,0}),
        Text(extent={{-90,-6},{-60,12}}, textString="+/-",
             lineColor={0,0,127}),
        Ellipse(extent={{-112,12},{-92,-8}},
                lineColor={0,0,127}, fillColor={200,200,255},
                fillPattern=FillPattern.Solid),
        Ellipse(extent={{92,32},{112,12}},
                lineColor={0,0,127}, fillColor={200,255,200},
                fillPattern=FillPattern.Solid),
        Ellipse(extent={{92,-8},{112,-28}},
                lineColor={0,0,127}, fillColor={255,255,200},
                fillPattern=FillPattern.Solid)}
        // Gehäuse
        // Titel
        // kleines Plus-/Minus-Symbol zur Orientierung
        // Pin-Markierungen (optional, nur visuell)
                                                // P_soll links
                                                // P_batt rechts oben
                                                // SOC rechts unten
),  Diagram(coordinateSystem(preserveAspectRatio=false)));
end BatterieEinfach;

