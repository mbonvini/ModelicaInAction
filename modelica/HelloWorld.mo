model HelloWorld  "The simplest differential equation ever"
 Real x "The unknown variable";
 constant Real a = -2.0 "Constant that characterizes the model";
 parameter Real x_start = 5.0 "Initial value of the variable x";
initial equation
 // Define initial conditions here...
 x = x_start;
equation
 // Write the equations here...
 der(x) = a*x;
end HelloWorld;