model E_Auto
  // ===========================
  // Parameter
  // ===========================
  parameter Boolean EV_aktiv = true "EV aktivieren (Ein/Aus)";
  parameter Boolean v2gAktiv = false "Bidirektionales Laden (V2G) erlauben";
  parameter Real kapazitaet_Wh = 40000 "EV-Kapazität [Wh]";
  parameter Real SOC0 = 0.4 "Start-SOC [0..1]";
  parameter Real SOC_min = 0.10 "untere SOC-Grenze";
  parameter Real SOC_max = 0.95 "obere SOC-Grenze";
  parameter Real P_laden_max = 11000 "Max. Ladeleistung [W]";
  parameter Real P_entladen_max = 3300 "Max. Entladeleistung [W]";
  parameter Real eta_laden = 0.95 "Wirkungsgrad Laden";
  parameter Real eta_entladen = 0.95 "Wirkungsgrad Entladen";

  // ===========================
  // Externe Anschlüsse
  // ===========================
  Modelica.Blocks.Interfaces.RealInput P_soll
    "Soll-Leistung vom EMS [W], +laden, -entladen"
    annotation(Placement(transformation(extent={{-120,-10},{-100,10}}),
                        iconTransformation(extent={{-120,-10},{-100,10}})));

  Modelica.Blocks.Interfaces.RealOutput P_EV
    "Umgesetzte EV-Leistung [W]"
    annotation(Placement(transformation(extent={{100,10},{120,30}}),
                        iconTransformation(extent={{100,10},{120,30}})));

  Modelica.Blocks.Interfaces.RealOutput SOC_EV
    "EV-SOC [0..1]"
    annotation(Placement(transformation(extent={{100,-30},{120,-10}}),
                        iconTransformation(extent={{100,-30},{120,-10}})));

  Modelica.Blocks.Interfaces.BooleanOutput EV_present_out
    "EV anwesend/angesteckt (für EMS Feedback)"
    annotation(Placement(transformation(extent={{100,-60},{120,-40}}),
                        iconTransformation(extent={{100,-60},{120,-40}})));

  // ===========================
  // Interne Komponenten
  // ===========================

  InputFunktionEV plan(
    EV_aktiv = EV_aktiv)
    annotation (Placement(transformation(extent={{-70,40},{-30,80}})));

  // BatterieEinfach mit V2G-Logik
  BatterieEinfachV2G batt(
    v2gAktiv       = v2gAktiv,
    kapazitaet_Wh  = kapazitaet_Wh,
    SOC0           = SOC0,
    SOC_min        = SOC_min,
    SOC_max        = SOC_max,
    P_laden_max    = P_laden_max,
    P_entladen_max = P_entladen_max,
    eta_laden      = eta_laden,
    eta_entladen   = eta_entladen)
    annotation (Placement(transformation(extent={{10,-10},{60,40}})));

equation 
  // Verbindungen
  connect(plan.present, batt.present)
    annotation (Line(points={{-28,70},{0,70},{0,25},{7.5,25}},color={255,0,255}));

  connect(P_soll, batt.P_soll)
    annotation (Line(points={{-110,0},{0,0},{0,15},{7.5,15}},color={0,0,127}));

  // Ausgänge
  connect(batt.SOC, SOC_EV)
    annotation (Line(points={{62.5,10},{96,10},{96,-20},{110,-20}}, color={0,0,127}));

  connect(batt.P_batt, P_EV)
    annotation (Line(points={{62.5,20},{110,20}}, color={0,0,127}));

  connect(plan.present, EV_present_out)
    annotation (Line(points={{-28,70},{-10,70},{-10,-50},{110,-50}}, color={255,0,255}));

  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics={
        Rectangle(extent={{-100,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid, lineThickness=2),
        Text(extent={{-90,24},{90,50}}, textString="E-Auto",
             fontSize=14, fontStyle=FontStyle.Bold, lineColor={0,0,0}),
        Text(extent={{-96,-6},{-10,10}}, textString="P_soll", lineColor={0,0,127}),
        Text(extent={{12,12},{96,28}}, textString="P_EV", lineColor={0,0,127}),
        Text(extent={{12,-28},{98,-12}}, textString="SOC_EV", lineColor={0,0,127}),
        Text(extent={{12,-50},{96,-38}}, textString="present", lineColor={255,0,255})}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

end E_Auto;
