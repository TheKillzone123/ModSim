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
  parameter Real socAbsenkungRueckkehr = 8300.0/kapazitaet_EV_Wh
    "SOC-Absenkung bei EV-Rückkehr aus 50 km Pendelweg (8.3 kWh) [0..1]"
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
  parameter Real SOC0_EV = 0.8 "Start-SOC EV zu Wochenbeginn [0..1]"
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
    annotation (Placement(transformation(extent={{-140,104},{-100,134}})));

  BatterieEinfach batterie(
    kapazitaet_Wh = kapazitaet_Batt_Wh,
    SOC0 = SOC0_Batt,
    SOC_min = SOC_batt_min_entladen,
    SOC_max = SOC_batt_max,
    P_laden_max = P_batt_laden_max,
    P_entladen_max = P_batt_entladen_max,
    eta_laden = eta_batt_laden,
    eta_entladen = eta_batt_entladen)
    annotation (Placement(transformation(extent={{46,126},{86,156}})));

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
    annotation (Placement(transformation(extent={{-110,-14},{-70,16}})));

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
    annotation (Placement(transformation(extent={{-36,30},{34,100}})));

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
    annotation(Placement(transformation(extent={{100,81},{120,91}})));

  Modelica.Blocks.Interfaces.RealOutput P_EV_soll_out
    "EV Sollleistung [W]"
    annotation(Placement(transformation(extent={{100,67},{120,77}})));

  Modelica.Blocks.Interfaces.RealOutput P_Grid_soll_out
    "Netzausgleich Sollleistung [W]"
    annotation(Placement(transformation(extent={{100,53},{120,63}})));

  Modelica.Blocks.Interfaces.RealOutput Autarkie_out
  "Autarkiegrad momentan [%]"
  annotation(Placement(transformation(extent={{100,39},{120,49}})));

  Modelica.Blocks.Interfaces.RealOutput Autarkie_kumuliert_out
  "Autarkiegrad über Gesamtzeitraum [%]"
  annotation(Placement(transformation(extent={{100,23},{120,33}})));

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
    annotation (Line(points={{-98,129.5},{-58,129.5},{-58,94},{-42,94},{-42,93},
          {-39.5,93}},
                     color={0,0,0}));

  connect(inputPV.P_Last, ems.P_Last)
    annotation (Line(points={{-98,116},{-68,116},{-68,79},{-39.5,79}},
                     color={0,0,0}));

  connect(batterie.SOC, ems.SOC_Batt)
    annotation (Line(points={{88,138},{88,110},{-54,110},{-54,65},{-39.5,65}},
                     color={0,0,0}));

  connect(e_auto.SOC_EV, ems.SOC_EV)
    annotation (Line(points={{-68,-2},{-52,-2},{-52,51},{-39.5,51}},
                     color={0,0,0}));

  // ===========================
  // AUSGÄNGE ← EMS
  // ===========================

  connect(ems.P_EV_soll, e_auto.P_soll)
    annotation (Line(points={{37.5,72},{48,72},{48,-16},{-120,-16},{-120,1},{-112,
          1}},       color={0,0,0}));

  // ===========================
  // MONITORING AUSGÄNGE
  // ===========================

  connect(inputPV.P_PV, P_PV_out)
    annotation (Line(points={{-98,129.5},{95,129.5},{95,130},{110,130}},
                     color={0,0,0}));

  connect(inputPV.P_Last, P_Last_out)
    annotation (Line(points={{-98,116},{95,116},{95,120},{110,120}},
                     color={0,0,0}));

  connect(batterie.SOC, SOC_Batt_out)
    annotation (Line(points={{88,138},{88,110},{110,110}},
                     color={0,0,0}));

  connect(e_auto.SOC_EV, SOC_EV_out)
    annotation (Line(points={{-68,-2},{68,-2},{68,100},{110,100}},
                     color={0,0,0}));

  connect(ems.P_Batt_soll, P_Batt_soll_out)
    annotation (Line(points={{37.5,86},{110,86}},
                     color={0,0,0}));

  connect(ems.P_EV_soll, P_EV_soll_out)
    annotation (Line(points={{37.5,72},{110,72}},
                     color={0,0,0}));

  connect(ems.P_Grid_soll, P_Grid_soll_out)
    annotation (Line(points={{37.5,58},{110,58}},
                     color={0,0,0}));

  connect(ems.Autarkie, Autarkie_out)
  annotation (Line(points={{37.5,44},{110,44}},
      color={0,0,0}));

  Autarkie_kumuliert_out = autarkie_kumuliert;
  connect(e_auto.EV_present_out, ems.EV_present) annotation (Line(points={{-68,-6.5},
          {-48,-6.5},{-48,37},{-39.5,37}}, color={255,0,255}));
  connect(batterie.P_soll, ems.P_Batt_soll) annotation (Line(points={{44,141},{38,
          141},{38,100},{48,100},{48,86},{37.5,86}}, color={0,0,127}));
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
