within SimpleElectrical.Components;

model Source
  extends SimpleElectrical.Interfaces.Bipole;
  parameter Modelica.SIunits.Voltage E = 10
    "Constant voltage source";
equation
  // The source generates a voltage difference
  // between the two terminals
  V = E;
end Source;
