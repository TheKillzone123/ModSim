model BatterieEinfachV2G
  // ===========================
  // Parameter
  // ===========================
  parameter Boolean v2gAktiv = false "V2G erlauben (Entladung)";
  parameter Real kapazitaet_Wh "Nennkapazität [Wh]";
  parameter Real SOC0 = 0.5 "Start-SOC [0..1]";
  parameter Real SOC_min = 0.05 "untere SOC-Grenze";
  parameter Real SOC_max = 0.95 "obere SOC-Grenze";
  parameter Real P_laden_max = 3000 "Max. Ladeleistung [W]";
  parameter Real P_entladen_max = 3000 "Max. Entladeleistung [W]";
  parameter Real eta_laden = 0.95 "Wirkungsgrad Laden";
  parameter Real eta_entladen = 0.95 "Wirkungsgrad Entladen";

  // ===========================
  // Anschlüsse
  // ===========================
  Modelica.Blocks.Interfaces.RealInput P_soll
    "Soll-Leistung [W], +laden, -entladen"
    annotation(
      Placement(transformation(extent={{-120,-10},{-100,10}}),
                iconTransformation(extent={{-120,-10},{-100,10}})));

  Modelica.Blocks.Interfaces.BooleanInput present
    "Batterie aktiv/präsent"
    annotation(
      Placement(transformation(extent={{-120,30},{-100,50}}),
                iconTransformation(extent={{-120,30},{-100,50}})));

  Modelica.Blocks.Interfaces.BooleanInput setSOC
    "Impuls: SOC bei Ankunft setzen"
    annotation(
      Placement(transformation(extent={{-120,60},{-100,80}}),
                iconTransformation(extent={{-120,60},{-100,80}})));

  Modelica.Blocks.Interfaces.RealInput SOC_set_val
    "SOC-Wert bei Ankunft [0..1]"
    annotation(
      Placement(transformation(extent={{-120,80},{-100,100}}),
                iconTransformation(extent={{-120,80},{-100,100}})));

  Modelica.Blocks.Interfaces.RealOutput P_batt
    "Umgesetzte Leistung [W]"
    annotation(
      Placement(transformation(extent={{100,10},{120,30}}),
                iconTransformation(extent={{100,10},{120,30}})));

  Modelica.Blocks.Interfaces.RealOutput SOC
    "Ladezustand 0..1"
    annotation(
      Placement(transformation(extent={{100,-30},{120,-10}}),
                iconTransformation(extent={{100,-30},{120,-10}})));

//Debug:

Modelica.Blocks.Interfaces.RealOutput v2gAktiv_check
  annotation(Placement(transformation(extent={{100,50},{120,70}})));

Modelica.Blocks.Interfaces.RealOutput P_begrenzt_check
  annotation(Placement(transformation(extent={{100,60},{120,80}})));



protected 
  parameter Real Emax_J = kapazitaet_Wh*3600 "Maximale Energie [J]";
  Real E(stateSelect=StateSelect.prefer) "Gespeicherte Energie [J]";
  Real P_begrenzt "Leistung nach technischen Limits [W]";
  Real P_wirk "Wirksame Leistung (mit Wirkungsgraden) [W]";
  Real SOC_intern "Interner SOC (ungeklemmt)";

equation 
  // 1) Leistung begrenzen auf max Laden/Entladen
  P_begrenzt = if present then 
                 min(max(P_soll, -P_entladen_max), P_laden_max)
               else 
                 0;

  // 2) NEUE LOGIK: Unterscheidung nach Lade-/Entlade-Richtung
  P_batt = if (P_begrenzt >= 0) then 
             if (SOC >= SOC_max) then 0 else P_begrenzt
           else 
             if (v2gAktiv and SOC > SOC_min) then 
               P_begrenzt
             else 
               0;
             // LADEN: Immer erlaubt, außer wenn SOC schon voll
             // ENTLADEN: Nur wenn v2gAktiv=true UND SOC nicht leer
                           // ← V2G erlaubt!
                   // ← V2G blockiert ODER SOC zu niedrig

  // 3) Wirkungsgrad anwenden
  P_wirk = if P_batt >= 0 then 
             eta_laden * P_batt
           else 
             P_batt / eta_entladen;  // Laden: Energiezuwachs
                                     // Entladen: Energieabnahme

  // 4) Energie integrieren
  der(E) = P_wirk;

  // 5) SOC berechnen (mit Reset-Logik bei Ankunft)
  SOC_intern = E / Emax_J;
  SOC = min(max(SOC_intern, SOC_min), SOC_max);

  // 6) SOC-Reset bei Ankunft (when-Klausel)
  when setSOC then
    reinit(E, SOC_set_val * Emax_J);
  end when;

//Debug:
  v2gAktiv_check = if v2gAktiv then 1.0 else 0.0;
  P_begrenzt_check = P_begrenzt;

initial equation 
  E = min(max(SOC0*Emax_J, SOC_min*Emax_J), SOC_max*Emax_J);

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics = {
        Rectangle(extent={{-100,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid),
        Text(extent={{-90,24},{90,50}},
             textString="Batterie V2G", textColor={0,0,0}),
        Text(extent={{-90,-6},{-60,12}}, textString="+/-",
             textColor={0,0,127}),
        Ellipse(extent={{-112,12},{-92,-8}},
                lineColor={0,0,127}, fillColor={200,200,255},
                fillPattern=FillPattern.Solid),
        Ellipse(extent={{92,32},{112,12}},
                lineColor={0,0,127}, fillColor={200,255,200},
                fillPattern=FillPattern.Solid),
        Ellipse(extent={{92,-8},{112,-28}},
                lineColor={0,0,127}, fillColor={255,255,200},
                fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

end BatterieEinfachV2G;
