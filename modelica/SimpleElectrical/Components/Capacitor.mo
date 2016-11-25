within SimpleElectrical.Components;

model Capacitor
  extends SimpleElectrical.Interfaces.Bipole;
  parameter Modelica.SIunits.Capacitance C = 1e-3
    "Capacitance";
  parameter Modelica.SIunits.Voltage V_start = 0.0
    "Initial voltage of the capacitor";
initial equation
  V = V_start;
equation
  // Change in the charge is equal to the current flow
  C*der(V) = i;
end Capacitor;
