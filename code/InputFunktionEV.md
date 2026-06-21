model InputFunktionEV
  // ===========================
  // Parameter
  // ===========================
  parameter Boolean EV_aktiv = true "EV aktivieren (Ein/Aus)";

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

  // ===========================
  // Interne Blöcke
  // ===========================
  // EV-Präsenz: Tabelle für 0-8h und 16-24h (28800s und 86400s in Sekunden)
  // 0 = nicht anwesend, 1 = anwesend
  Modelica.Blocks.Sources.TimeTable CT_Present(table=[
    0,      1;
    28800,  1;
    28800,  0;
    57600,  0;
    57600,  1;
    86400,  1]        // 00:00 anwesend (Start)
                      // 08:00 noch anwesend
                      // 08:00 weg
                      // 16:00 noch weg
                      // 16:00 anwesend
                      // 24:00 (Mitternacht) noch anwesend
)   annotation (Placement(transformation(extent={{-80,74},{-60,94}})));

  // SOC bei Ankunft: 0.8 (hoch, für V2G-Test)
  Modelica.Blocks.Sources.Constant const_soc(k=0.8)
    annotation (Placement(transformation(extent={{-80,44},{-60,64}})));

  // Real→Boolean per Schwellwert (0.5)
  Modelica.Blocks.Logical.GreaterEqualThreshold thr(threshold=0.5)
    annotation (Placement(transformation(extent={{-40,74},{-16,98}})));

  // Flankendetektor (0→1 Ankunftsimpuls)
  Modelica.Blocks.Logical.Edge edgeArr
    annotation (Placement(transformation(extent={{10,74},{34,98}})));

protected 
  Real soc_hold "SOC-Wert bei Ankunft [0..1]";

equation 
  // Wert bei Ankunft abtasten und halten
  when edgeArr.y then
    soc_hold = const_soc.y;
  end when;

  // Präsenz: EV anwesend gemäß Zeitplan
  present = if EV_aktiv then CT_Present.y > 0.5 else false;

  // SOC-Setzimpuls und -wert ausgeben
  setSOC      = edgeArr.y;
  SOC_set_val = soc_hold;

  // ===========================
  // Verbindungen
  // ===========================
  connect(CT_Present.y, thr.u)
    annotation (Line(points={{-59,84},{-42.4,86}}, color={0,0,127}));
  connect(thr.y, edgeArr.u)
    annotation (Line(points={{-14.8,86},{7.6,86}}, color={255,0,255}));

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
        Ellipse(extent={{92,-18},{112,-38}}, lineColor={0,0,127}, fillColor={220,255,220},
                fillPattern=FillPattern.Solid),
        Text(extent={{-60,-30},{-10,-20}}, textString="SOC_set_val")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

end InputFunktionEV;
