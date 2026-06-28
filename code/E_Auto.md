model E_Auto
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
    "SOC-Absenkung bei Rückkehr [0..1]";
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
    annotation(Placement(transformation(extent={{-140,-10},{-120,10}}),
                        iconTransformation(extent={{-140,-10},{-120,10}})));

  Modelica.Blocks.Interfaces.RealOutput P_EV
    "Umgesetzte EV-Leistung [W]"
    annotation(Placement(transformation(extent={{100,30},{120,50}}),
                        iconTransformation(extent={{100,30},{120,50}})));

  Modelica.Blocks.Interfaces.RealOutput SOC_EV
    "EV-SOC [0..1]"
    annotation(Placement(transformation(extent={{100,-10},{120,10}}),
                        iconTransformation(extent={{100,-10},{120,10}})));

  Modelica.Blocks.Interfaces.BooleanOutput EV_present_out
    "EV anwesend/angesteckt (für EMS Feedback)"
    annotation(Placement(transformation(extent={{100,-50},{120,-30}}),
                        iconTransformation(extent={{100,-50},{120,-30}})));

  // ===========================
  // Interne Komponenten
  // ===========================

  InputFunktionEV plan(
    EV_aktiv = EV_aktiv,
    istWoche = istWoche,
    nutze5plus2 = nutze5plus2,
    startWochentag = startWochentag,
    socAbsenkungRueckkehr = socAbsenkungRueckkehr)
    annotation (Placement(transformation(extent={{-88,4},{-14,38}})));

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
    annotation (Line(points={{-9.88889,32.3333},{0,32.3333},{0,30},{7.5,30}},
                                                              color={255,0,255}));

  connect(plan.setSOC, batt.setSOC)
    annotation (Line(points={{-9.88889,21},{-2,21},{-2,20},{7.5,20}},
                                                                  color={255,0,255}));

  connect(batt.SOC, plan.SOC_aktuell)
    annotation (Line(points={{62.5,0},{80,0},{80,46},{-106,46},{-106,20},{-100,20},
          {-100,21},{-92.1111,21}},
                     color={0,0,127}));

  connect(P_soll, batt.P_soll)
    annotation (Line(points={{-130,0},{7.5,0}},              color={0,0,127}));

  // Ausgänge
  connect(batt.SOC, SOC_EV)
    annotation (Line(points={{62.5,0},{80,0},{80,0},{110,0}},       color={0,0,127}));

  connect(batt.P_batt, P_EV)
    annotation (Line(points={{62.5,10},{74,10},{74,40},{110,40}},
                                                  color={0,0,127}));

  connect(plan.present, EV_present_out)
    annotation (Line(points={{-9.88889,32.3333},{0,32.3333},{0,38},{70,38},{70,-40},
          {110,-40}},                                                color={255,0,255}));

  connect(plan.SOC_set_val, batt.SOC_set_val) annotation (Line(points={{-9.88889,
          9.66667},{-1.35,9.66667},{-1.35,10},{7.5,10}}, color={0,0,127}));
  annotation(
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-120,-100},{100,100}}),
      graphics={
        Rectangle(extent={{-120,-60},{100,60}},
                  lineColor={0,0,0}, fillColor={230,230,230},
                  fillPattern=FillPattern.Solid, lineThickness=2),
        Text(extent={{-90,24},{90,50}}, textString="E-Auto",
             fontSize=14, fontStyle=FontStyle.Bold, lineColor={0,0,0}),
        Text(extent={{-96,-6},{-10,10}}, textString="P_soll", lineColor={0,0,127}),
        Text(extent={{14,32},{98,48}}, textString="P_EV", lineColor={0,0,127}),
        Text(extent={{12,-8},{98,8}},    textString="SOC_EV", lineColor={0,0,127}),
        Text(extent={{12,-46},{96,-34}}, textString="present", lineColor={255,0,255})}),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-120,-100},{100,
            100}})));

end E_Auto;
