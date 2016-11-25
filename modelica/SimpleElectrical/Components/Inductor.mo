within SimpleElectrical.Components;

model Inductor
  extends SimpleElectrical.Interfaces.Bipole;
  parameter Modelica.SIunits.Inductance L = 1e-3
    "Inductance";
  parameter Modelica.SIunits.Current i_start = 0.0
    "Initial current of the inductor";
initial equation
  i = i_start;
equation
  // Change in the magnetic field is proportional
  // to the voltage
  L*der(i) = V;
end Inductor;
