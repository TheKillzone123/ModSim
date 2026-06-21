model EMS
  // ===========================
  // Parameter
  // ===========================
  // Hausbatterie
  parameter Real SOC_batt_min_entladen = 0.05 "Hausbatt: nicht unter diesen SOC entladen (Batterie SOC_min)";
  parameter Real SOC_batt_min_laden = 0.30 "Hausbatt: Schnell laden falls SOC < [0..1]";
  parameter Real SOC_batt_max_laden = 0.80 "Hausbatt: Lade-Stopp ab SOC >= [0..1]";
  parameter Real P_batt_laden_max = 3000 "Hausbatt: Max Ladeleistung [W]";
  parameter Real P_batt_entladen_max = 3000 "Hausbatt: Max Entladeleistung [W]";

  // EV / V2G
  parameter Boolean v2gAktiv = false "V2G erlauben";
  parameter Real SOC_EV_min_v2g = 0.60 "EV entlädt nur ab SOC > [0..1]";
  parameter Real P_v2g_min_defizit = 100 "V2G springt ein ab Defizit > [W]";
  parameter Real P_ev_entladen_max = 3300 "Max EV Entladeleistung (V2G) [W]";

  // EV Laden
  parameter Real SOC_EV_min_laden = 0.30 "EV wird bei Anwesenheit auf mind. diesen SOC nachgeladen [0..1]";
  parameter Real P_ev_schwelle_laden = 500 "EV lädt erst ab Rest-Überschuss >= [W]";
  parameter Real P_ev_laden_max = 11000 "Max EV Ladeleistung [W]";

  // Netz
  parameter Boolean netzAktiv = true "Netzanbindung aktiv";
  parameter Real P_netz_max_import = 6000 "Max Netzbezug [W]";
  parameter Real P_netz_max_export = 10000 "Max Netzeinspeisung [W]";

  // ===========================
  // Eingänge
  // ===========================
  Modelica.Blocks.Interfaces.RealInput P_PV
    annotation(Placement(transformation(extent={{-120,60},{-100,80}})));

  Modelica.Blocks.Interfaces.RealInput P_Last
    annotation(Placement(transformation(extent={{-120,40},{-100,60}})));

  Modelica.Blocks.Interfaces.RealInput SOC_Batt
    annotation(Placement(transformation(extent={{-120,20},{-100,40}})));

  Modelica.Blocks.Interfaces.RealInput SOC_EV
    annotation(Placement(transformation(extent={{-120,0},{-100,20}})));

  Modelica.Blocks.Interfaces.BooleanInput EV_present
    annotation(Placement(transformation(extent={{-120,-20},{-100,0}})));

  // ===========================
  // Ausgänge
  // ===========================
  Modelica.Blocks.Interfaces.RealOutput P_Batt_soll
    annotation(Placement(transformation(extent={{100,60},{120,80}})));

  Modelica.Blocks.Interfaces.RealOutput P_EV_soll
    annotation(Placement(transformation(extent={{100,40},{120,60}})));

  Modelica.Blocks.Interfaces.RealOutput P_Grid_soll
    annotation(Placement(transformation(extent={{100,20},{120,40}})));

  Modelica.Blocks.Interfaces.RealOutput Autarkie
    annotation(Placement(transformation(extent={{100,0},{120,20}})));

protected 
  Real P_uberschuss;
  Real P_nach_batt;
  Real P_nach_ev;

  Real P_batt_cmd;
  Real P_EV_v2g;
  Real P_EV_laden;

equation 
  // 1) Überschuss/Defizit
  P_uberschuss = P_PV - P_Last;

  // 2) Hausbatterie: laden/entladen bis Minimum
  P_batt_cmd =
    if (P_uberschuss > 100) and (SOC_Batt < SOC_batt_max_laden) then 
      if SOC_Batt < SOC_batt_min_laden then 
        min(P_uberschuss, P_batt_laden_max)
      else 
        min(P_uberschuss, 0.5*P_batt_laden_max)
    else if (P_uberschuss < -100) and (SOC_Batt > SOC_batt_min_entladen) then 
      max(P_uberschuss, -P_batt_entladen_max)
    else 
      0;
      // Laden (bis Leistungsgrenze)
      // Entladen (nur solange nicht "leer")

  P_Batt_soll = P_batt_cmd;
  P_nach_batt = P_uberschuss - P_Batt_soll;

  // 3) EV V2G: nur wenn Hausbatt leer, Defizit, EV da, SOC ok, v2gAktiv=true
  P_EV_v2g =
    if v2gAktiv and 
       (P_nach_batt < -P_v2g_min_defizit) and 
       EV_present and 
       (SOC_EV > SOC_EV_min_v2g) and 
       (SOC_Batt <= SOC_batt_min_entladen) then 
      max(P_nach_batt, -P_ev_entladen_max)
    else 
      0;                                     // negativ

  // 4) EV Laden: nur bei ausreichend Rest-Überschuss nach Hausbatt
  //    -> Bei SOC < SOC_EV_min_laden wird erzwungen geladen (auch mit Netzbezug, falls noetig).
  //    -> Sonst nur bei ausreichend Rest-Ueberschuss.
  P_EV_laden =
    if EV_present and (SOC_EV < SOC_EV_min_laden) then
      min(P_ev_laden_max, max(P_nach_batt + P_netz_max_import, 0))
    else if (P_nach_batt >= P_ev_schwelle_laden) and EV_present then 
      min(P_nach_batt, P_ev_laden_max)
    else 
      0;                                     // positiv

  // Nie gleichzeitig: P_nach_batt kann nicht gleichzeitig >= Schwelle und < -Schwelle sein
  P_EV_soll = P_EV_v2g + P_EV_laden;

  // 5) Rest nach EV
  P_nach_ev = P_nach_batt - P_EV_soll;

  // 6) Netz gleicht den Rest aus
  P_Grid_soll =
    if netzAktiv then 
      if (P_nach_ev < -200) then 
        min(-P_nach_ev, P_netz_max_import)
      else if (P_nach_ev > 200) then 
        -min(P_nach_ev, P_netz_max_export)
      else 
        0
    else 
      0;                                     // Import +
                                             // Export -

  // 7) Autarkiegrad [%]
  Autarkie =
    if P_Last > 0 then 
      100.0 * (1.0 - max(P_Grid_soll, 0)/P_Last)
    else 
      100.0;

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics={
        Rectangle(extent={{-100,-100},{100,100}},
                  lineColor={0,0,0}, fillColor={200,220,240},
                  fillPattern=FillPattern.Solid, lineThickness=2),
        Text(extent={{-90,70},{90,92}}, textString="EMS", fontSize=16, textColor={0,0,0})}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));
end EMS;
