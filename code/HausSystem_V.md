model HausSystem_V3
  // ===========================
  // STARK VEREINFACHT: PV + Batterie + EMS + E_AUTO
  // ===========================

  // ===========================
  // UMGEBUNG
  // ===========================
  parameter Boolean nutzeSommer = true "true = Sommerprofil, false = Winterprofil"
    annotation (Dialog(group="Umgebung"));
  parameter Boolean nutze5plus2 = true "true = automatische 5+2-Woche"
    annotation (Dialog(group="Umgebung"));
  parameter Integer startWochentag(min=1, max=7) = 1
    "Wochentag bei Simulationsstart: 1=Mo ... 7=So"
    annotation (Dialog(group="Umgebung"));
  parameter Boolean istWoche = true "true = unter der Woche, false = Wochenende"
    annotation (Dialog(group="Umgebung"));
  parameter Boolean netzAktiv = true "Netzanbindung aktiv"
    annotation (Dialog(group="Umgebung"));
  parameter Real P_netz_max_import = 10000 "Max Netzbezug [W]"
    annotation (Dialog(group="Umgebung"));
  parameter Real P_netz_max_export = 10000 "Max Netzeinspeisung [W]"
    annotation (Dialog(group="Umgebung"));
  parameter Boolean automatischeSimDauer = true
    "Automatisch auf 1 Tag bei nutze5plus2=false, sonst 7 Tage"
    annotation (Dialog(group="Umgebung"));

  // ===========================
  // HAUS
  // ===========================
  parameter Real kapazitaet_Batt_Wh = 5100  "Batterie Kapazität [Wh]"
    annotation (Dialog(group="Haus"));
  parameter Real SOC0_Batt = 0.5 "Start-SOC Batterie [0..1]"
    annotation (Dialog(group="Haus"));

  // Hausbatterie (muss zu BatterieEinfach passen)
  parameter Real SOC_batt_min_entladen = 0.05 "Unteres SOC-Limit Hausbatterie (wie BatterieEinfach.SOC_min)"
    annotation (Dialog(group="Haus"));
  parameter Real SOC_batt_max = 0.95 "Oberes SOC-Limit Hausbatterie (wie BatterieEinfach.SOC_max)"
    annotation (Dialog(group="Haus"));
  parameter Real P_batt_laden_max = 2500 "Max Ladeleistung Batterie [W]"
    annotation (Dialog(group="Haus"));
  parameter Real P_batt_entladen_max = 2500 "Max Entladeleistung Batterie [W]"
    annotation (Dialog(group="Haus"));
  parameter Real eta_batt_laden = 0.95 "Wirkungsgrad Laden Batterie"
    annotation (Dialog(group="Haus"));
  parameter Real eta_batt_entladen = 0.95 "Wirkungsgrad Entladen Batterie"
    annotation (Dialog(group="Haus"));

  // EMS / Batterie-Strategie
  parameter Real SOC_batt_min_laden = 0.30 "Batterie lädt ab SOC < [0..1]"
    annotation (Dialog(group="Haus"));
  parameter Real SOC_batt_max_laden = 0.80 "Batterie lädt nur bis SOC < [0..1]"
    annotation (Dialog(group="Haus"));

  // ===========================
  // EV
  // ===========================
  parameter Boolean EV_aktiv = true "E_Auto aktivieren"
    annotation (Dialog(group="EV"));
  parameter Real socAbsenkungRueckkehr = 0.10
    "SOC-Absenkung bei EV-Rückkehr [0..1], z.B. 0.10 = 10%"
    annotation (Dialog(group="EV"));
  parameter Boolean v2gAktiv = false "V2G (Vehicle-to-Grid) aktivieren"
    annotation (Dialog(group="EV"));
  parameter Real SOC_EV_min_v2g = 0.60 "EV entlädt nur ab SOC > [0..1]"
    annotation (Dialog(group="EV"));
  parameter Real P_v2g_min_defizit = 100 "V2G springt ein ab Defizit > [W]"
    annotation (Dialog(group="EV"));
  parameter Real P_ev_entladen_max = 3300 "Max. EV Entladeleistung (V2G) [W]"
    annotation (Dialog(group="EV"));
  parameter Real kapazitaet_EV_Wh = 66500 "EV-Kapazität [Wh]"
    annotation (Dialog(group="EV"));
  parameter Real SOC0_EV = 0.4 "Start-SOC EV [0..1]"
    annotation (Dialog(group="EV"));
  parameter Real P_wallbox_laden_max = 22000 "Max. Ladeleistung Wallbox SMA EV CHARGER 22 [W]"
    annotation (Dialog(group="EV"));
  parameter Real P_ev_laden_max = 11000 "Max. EV Ladeleistung fahrzeugseitig [W]"
    annotation (Dialog(group="EV"));
  parameter Real P_ev_laden_effektiv_max = min(P_wallbox_laden_max, P_ev_laden_max)
    "Effektive EV-Ladeleistung aus Wallbox- und Fahrzeuglimit [W]"
    annotation (Dialog(group="EV"));
  parameter Real SOC_EV_min_laden = 0.30 "EV soll bei Anwesenheit auf mind. diesen SOC geladen werden [0..1]"
    annotation (Dialog(group="EV"));
  parameter Real P_ev_schwelle_laden = 1500 "EV lädt erst ab Überschuss > [W]"
    annotation (Dialog(group="EV"));

  // ===========================
  // Komponenten (MINIMAL!)
  // ===========================

  InputFunktion_V2 inputPV(
    nutzeSommer = nutzeSommer,
    nutze5plus2 = nutze5plus2,
    startWochentag = startWochentag,
    istWoche = istWoche)
    annotation (Placement(transformation(extent={{-140,100},{-100,130}})));

  BatterieEinfach batterie(
    kapazitaet_Wh = kapazitaet_Batt_Wh,
    SOC0 = SOC0_Batt,
    SOC_min = SOC_batt_min_entladen,
    SOC_max = SOC_batt_max,
    P_laden_max = P_batt_laden_max,
    P_entladen_max = P_batt_entladen_max,
    eta_laden = eta_batt_laden,
    eta_entladen = eta_batt_entladen)
    annotation (Placement(transformation(extent={{-70,100},{-30,130}})));

  E_Auto e_auto(
    EV_aktiv = EV_aktiv,
    istWoche = istWoche,
    nutze5plus2 = nutze5plus2,
    startWochentag = startWochentag,
    socAbsenkungRueckkehr = socAbsenkungRueckkehr,
    v2gAktiv = v2gAktiv,
    kapazitaet_Wh = kapazitaet_EV_Wh,
    SOC0 = SOC0_EV,
    P_laden_max = P_ev_laden_effektiv_max)
    annotation (Placement(transformation(extent={{-70,40},{-30,70}})));

  // EMS passend zur "nie gleichzeitig laden/entladen" Version
  EMS ems(
    SOC_batt_min_entladen = SOC_batt_min_entladen,
    SOC_batt_min_laden = SOC_batt_min_laden,
    SOC_batt_max_laden = SOC_batt_max_laden,
    P_batt_laden_max = P_batt_laden_max,
    P_batt_entladen_max = P_batt_entladen_max,

    v2gAktiv = v2gAktiv,
    SOC_EV_min_v2g = SOC_EV_min_v2g,
    P_v2g_min_defizit = P_v2g_min_defizit,
    P_ev_entladen_max = P_ev_entladen_max,
    SOC_EV_min_laden = SOC_EV_min_laden,
    P_ev_schwelle_laden = P_ev_schwelle_laden,
    P_ev_laden_max = P_ev_laden_effektiv_max,

    netzAktiv = netzAktiv,
    P_netz_max_import = P_netz_max_import,
    P_netz_max_export = P_netz_max_export)
    annotation (Placement(transformation(extent={{10,40},{80,110}})));

  // ===========================
  // Ausgänge (MONITORING!)
  // ===========================
  Modelica.Blocks.Interfaces.RealOutput P_PV_out
    "PV-Leistung [W]"
    annotation(Placement(transformation(extent={{100,125},{120,135}})));

  Modelica.Blocks.Interfaces.RealOutput P_Last_out
    "Haushaltslasten [W]"
    annotation(Placement(transformation(extent={{100,115},{120,125}})));

  Modelica.Blocks.Interfaces.RealOutput SOC_Batt_out
    "Batterie SOC [0..1]"
    annotation(Placement(transformation(extent={{100,105},{120,115}})));

  Modelica.Blocks.Interfaces.RealOutput SOC_EV_out
    "EV SOC [0..1]"
    annotation(Placement(transformation(extent={{100,95},{120,105}})));

  Modelica.Blocks.Interfaces.RealOutput P_Batt_soll_out
    "Batterie Sollleistung [W]"
    annotation(Placement(transformation(extent={{100,75},{120,85}})));

  Modelica.Blocks.Interfaces.RealOutput P_EV_soll_out
    "EV Sollleistung [W]"
    annotation(Placement(transformation(extent={{100,55},{120,65}})));

  Modelica.Blocks.Interfaces.RealOutput P_Grid_soll_out
    "Netzausgleich Sollleistung [W]"
    annotation(Placement(transformation(extent={{100,35},{120,45}})));

  Modelica.Blocks.Interfaces.RealOutput Autarkie_out
  "Autarkiegrad momentan [%]"
  annotation(Placement(transformation(extent={{100,15},{120,25}})));

  Modelica.Blocks.Interfaces.RealOutput Autarkie_kumuliert_out
  "Autarkiegrad über Gesamtzeitraum [%]"
  annotation(Placement(transformation(extent={{100,-5},{120,5}})));

protected
  parameter Real simDauerTag_s = 86400 "1 Tag in Sekunden";
  parameter Real simDauerWoche_s = 604800 "7 Tage in Sekunden";
  Real simEnde_s "Automatisches Simulationsende [s]";
  
  // Energieintegration für Autarkie-Berechnung
  Real energie_verbrauch_Wh(start=0, fixed=true) "Kumulierte Verbrauchsenergie [Wh]";
  Real energie_netz_bezug_Wh(start=0, fixed=true) "Kumulierte Netzbezugsenergie [Wh]";
  Real autarkie_kumuliert "Autarkie über Gesamtzeitraum [%]";

equation 
  // Automatische Simulationsdauer anhand des Wochenmodus
  simEnde_s = if automatischeSimDauer then (if nutze5plus2 then simDauerWoche_s else simDauerTag_s) else simDauerWoche_s;

  // Beendet die Simulation automatisch beim Erreichen der Zielzeit
  when time >= simEnde_s then
    terminate("Automatisches Simulationsende erreicht.");
  end when;

  // ===========================
  // ENERGIEINTEGRATION
  // ===========================
  // Verbrauchte Energie in Wh pro Sekunde
  der(energie_verbrauch_Wh) = inputPV.P_Last / 3600;
  
  // Netzbezugsenergie in Wh pro Sekunde (nur positiv, also Import)
  der(energie_netz_bezug_Wh) = max(ems.P_Grid_soll, 0) / 3600;
  
  // Autarkiegrad über Gesamtzeitraum [%]
  autarkie_kumuliert = 
    if energie_verbrauch_Wh > 1 then 
      100.0 * (1.0 - energie_netz_bezug_Wh / energie_verbrauch_Wh)
    else 
      0;

  // ===========================
  // EINGÄNGE → EMS
  // ===========================

  connect(inputPV.P_PV, ems.P_PV)
    annotation (Line(points={{-98,125.5},{0,125.5},{0,96},{6.5,96}},
                     color={255,165,0}, thickness=2));

  connect(inputPV.P_Last, ems.P_Last)
    annotation (Line(points={{-98,112},{0,112},{0,89},{6.5,89}},
                     color={200,0,0}, thickness=2));

  connect(batterie.SOC, ems.SOC_Batt)
    annotation (Line(points={{-28,112},{0,112},{0,82},{6.5,82}},
                     color={0,100,200}, thickness=2));

  connect(e_auto.SOC_EV, ems.SOC_EV)
    annotation (Line(points={{-28,52},{0,52},{0,75},{6.5,75}},
                     color={0,150,0}, thickness=2));

  connect(e_auto.EV_present_out, ems.EV_present)
    annotation (Line(points={{-28,47.5},{0,47.5},{0,68},{6.5,68}},
                     color={255,0,255}, thickness=2));

  // ===========================
  // AUSGÄNGE ← EMS
  // ===========================

  connect(ems.P_Batt_soll, batterie.P_soll)
    annotation (Line(points={{83.5,96},{90,96},{90,135},{-72,135},{-72,115}},
                     color={0,100,200}, thickness=2));

  connect(ems.P_EV_soll, e_auto.P_soll)
    annotation (Line(points={{83.5,89},{90,89},{90,20},{-72,20},{-72,55}},
                     color={0,150,0}, thickness=2));

  // ===========================
  // MONITORING AUSGÄNGE
  // ===========================

  connect(inputPV.P_PV, P_PV_out)
    annotation (Line(points={{-98,125.5},{95,125.5},{95,130},{100,130}},
                     color={255,165,0}, thickness=1));

  connect(inputPV.P_Last, P_Last_out)
    annotation (Line(points={{-98,112},{95,112},{95,120},{100,120}},
                     color={200,0,0}, thickness=1));

  connect(batterie.SOC, SOC_Batt_out)
    annotation (Line(points={{-28,112},{95,112},{95,110},{100,110}},
                     color={0,100,200}, thickness=1));

  connect(e_auto.SOC_EV, SOC_EV_out)
    annotation (Line(points={{-28,52},{95,52},{95,100},{100,100}},
                     color={0,150,0}, thickness=1));

  connect(ems.P_Batt_soll, P_Batt_soll_out)
    annotation (Line(points={{83.5,96},{95,96},{95,80},{100,80}},
                     color={0,100,200}, thickness=1));

  connect(ems.P_EV_soll, P_EV_soll_out)
    annotation (Line(points={{83.5,89},{95,89},{95,60},{100,60}},
                     color={0,150,0}, thickness=1));

  connect(ems.P_Grid_soll, P_Grid_soll_out)
    annotation (Line(points={{83.5,82},{95,82},{95,40},{100,40}},
                     color={255,100,0}, thickness=1));

  connect(ems.Autarkie, Autarkie_out)
  annotation (Line(points={{83.5,75},{95,75},{95,20},{100,20}},
      color={0,200,0}, thickness=1));

  Autarkie_kumuliert_out = autarkie_kumuliert;

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics={
        Rectangle(extent={{-100,-100},{100,100}},
                  lineColor={0,0,0}, fillColor={240,240,240},
                  fillPattern=FillPattern.Solid, lineThickness=2),
        Text(extent={{-90,80},{90,100}}, textString="HAUS-ENERGIESYSTEM V3",
             fontSize=14, textColor={0,0,0}),
        Text(extent={{-90,-95},{90,-75}},
             textString="PV + Batterie + E-Auto + Netz",
             fontSize=10, textColor={100,100,100})}),

    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-150,-30},{130,150}})),

    experiment(
      StartTime = 0,
      StopTime = 604800,
      Tolerance = 0.0001));

end HausSystem_V3;
