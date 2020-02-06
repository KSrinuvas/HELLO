
 Inverter netlist 
 .model MOSN NMOS level=8 version=3.3.0 
 .model MOSP PMOS level=8 version=3.3.0 
 
** DECLARE POWER HV VOLTAGES *** 
 .param HV=5v 
 .param LV=0v 
 .param TR=0.5ns 
 .param TF=0.5ns 
 .param C =0.5pf 
 
M1 1 2 3 3 MOSP L=0.18u W=0.72u 
 M2 1 2 0 0 MOSN L=0.18u W=0.36u 
 
*** input sources *** 
 
VDD 3 0 DC 'HV' 
 
** initial voltage, high voltage inital delay, rise time, fall time , pulse width, time period 
 VG 2 0 pulse('LV' 'HV' 0ns 'TR' 'TF' 20ns 40ns) 
 

** analysis type *** 
 ** step, stop, start 
 .tran 1ns 100ns 5ns 
 *Ci in 4 1.6nF 
 
*** DEFINE CAPACITANCE *** 
 
COUT 1 0 C 
 
.measure tran tpdr TRIG v(2) VAL='HV/2' FALL=1 TARG v(1) VAL = 'HV/2' RISE=1 
 .measure tran tpdf TRIG v(2) VAL='HV/2' RISE=1 TARG v(1) VAL = 'HV/2' FALL=1 
 
*.measure tran tpd param = '(tpdr+tpdf)/2' 
 
.measure tran trise TRIG v(1) VAL='0.2*HV' RISE=1 TARG v(1) VAL = '0.8*HV' RISE=1 
 
.measure tran tfall TRIG v(1) VAL='0.8*HV' FALL=1 TARG v(1) VAL = '0.2*HV' FALL=1 
 

** POWER CALCULATIONS *** 
 *.measure {DC|AC|TRAN|SP} result {AVG|MIN|MAX|PP|RMS|MIN_AT|MAX_AT} out_variable <TD=td> <FROM> <TO=val> 
 
.measure tran iavg AVG i(VDD) FROM=0ns TO=40ns *.measure tran iavg AVG i(VDD) FROM='0.2*HV' TO='0.8*HV' 
 .measure tran power PARAM='iavg*5' 
 
.control 
 run 
 .plot V(1) V(2) 
 .ENDC 
 .END 
 
