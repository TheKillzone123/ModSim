model EV_Batterie
  // ===========================
  // Parameter
  // ===========================
  parameter Boolean EV_aktiv = true "EV aktivieren (Ein/Aus)";
  parameter Boolean v2gAktiv = false "Bidirektionales Laden (V2G) erlauben";
  parameter Real kapazitaet_Wh(min=0) = 40000 "EV-Kapazität [Wh]";
  parameter Real SOC0(min=0, max=1) = 0.4 "Start-SOC [0..1]";
  parameter Real SOC_min(min=0, max=1) = 0.10 "untere SOC-Grenze";
  parameter Real SOC_max(min=0, max=1) = 0.95 "obere SOC-Grenze";
  parameter Real P_laden_max(min=0)    = 11000 "Max. Ladeleistung [W]";
  parameter Real P_entladen_max(min=0) = 3300  "Max. Entladeleistung [W]";
  parameter Real eta_laden(min=0, max=1)    = 0.95 "Wirkungsgrad Laden";
  parameter Real eta_entladen(min=0, max=1) = 0.95 "Wirkungsgrad Entladen";

  // ===========================
  // Anschlüsse
  // ===========================
  Modelica.Blocks.Interfaces.RealInput P_soll
    "Soll-Leistung vom EMS [W], +laden, -entladen"
    annotation(Placement(transformation(extent={{-120,-10},{-100,10}}),
                        iconTransformation(extent={{-120,-10},{-100,10}})));

  Modelica.Blocks.Interfaces.BooleanInput present
    "EV anwesend/angesteckt"
    annotation(Placement(transformation(extent={{-120,40},{-100,60}}),
                        iconTransformation(extent={{-120,40},{-100,60}})));

  Modelica.Blocks.Interfaces.BooleanInput setSOC
    "Impuls: SOC bei Ankunft setzen"
    annotation(Placement(transformation(extent={{-120,70},{-100,90}}),
                        iconTransformation(extent={{-120,70},{-100,90}})));

  Modelica.Blocks.Interfaces.RealInput SOC_set_val
    "SOC-Wert bei Ankunft [0..1]"
    annotation(Placement(transformation(extent={{-120,20},{-100,40}}),
                        iconTransformation(extent={{-120,20},{-100,40}})));

  Modelica.Blocks.Interfaces.RealOutput P_batt
    "Umgesetzte EV-Leistung [W]"
    annotation(Placement(transformation(extent={{100,10},{120,30}}),
                        iconTransformation(extent={{100,10},{120,30}})));

  Modelica.Blocks.Interfaces.RealOutput SOC
    "EV-SOC [0..1]"
    annotation(Placement(transformation(extent={{100,-30},{120,-10}}),
                        iconTransformation(extent={{100,-30},{120,-10}})));

protected 
  // Interner Energiezustand (in Joule)
  parameter Real Emax_J = kapazitaet_Wh*3600 "Maximale Energie [J]";
  Real E(stateSelect=StateSelect.prefer) "Gespeicherte Energie [J]";
  Real SOC_intern "Interner SOC (ungeklemmt)";
  Real P_begrenzt "Leistung nach max. Grenzen";
  Real P_wirk "Wirksame Leistung (mit Wirkungsgraden)";

equation 
  // ===========================
  // V2G Logik
  // ===========================

  // 1) EV aktiv? Wenn nicht, P_soll = 0
  P_begrenzt = if (EV_aktiv and present) then 
                 min(max(P_soll, -P_entladen_max), P_laden_max)
               else 
                 0;

  // 2) SOC-SCHUTZ mit V2G-Unterscheidung
  // WICHTIG: Diese Logik erlaubt Entladung NUR wenn v2gAktiv=true!
  P_batt = if (P_begrenzt > 0) and (SOC_intern >= SOC_max) then 
             0
           else if (P_begrenzt < 0) and (SOC_intern <= SOC_min) then 
             0
           else if (P_begrenzt < 0) and not v2gAktiv then 
             0
           else 
             P_begrenzt;
                // Bei voll nicht laden
                // Bei leer nicht entladen
                // Entladung NUR wenn v2gAktiv=true!
                          // Sonst erlaubt

  // 3) Wirkungsgrad anwenden
  P_wirk = if P_batt >= 0 then 
             eta_laden * P_batt
           else 
             P_batt / eta_entladen;  // Laden: Wirkungsgrad < 1
                                     // Entladen: Energie sinkt mehr

  // 4) Energie integrieren
  der(E) = P_wirk;

  // 5) SOC berechnen
  SOC_intern = E / Emax_J;
  SOC = min(max(SOC_intern, SOC_min), SOC_max);

initial equation 
  // Anfangsenergie
  E = min(max(SOC0*Emax_J, SOC_min*Emax_J), SOC_max*Emax_J);

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics = {
        Rectangle(extent={{-100,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid),
        Text(extent={{-90,24},{90,50}}, textString="EV-Batterie",
             fontSize=12, fontStyle=FontStyle.Bold),
        Text(extent={{-96,-6},{-10,10}}, textString="P_soll"),
        Text(extent={{12,12},{96,28}}, textString="P_batt"),
        Text(extent={{12,-28},{98,-12}}, textString="SOC")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

end EV_Batterie;
