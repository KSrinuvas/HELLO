#!/usr/bin/python3
import os;
import re;
import sys;

file1 = sys.argv[1];

fh = open(file1,"r");


dict_data = {};

for line in fh.readlines():
    line = line.strip()
    if re.search(r'input_transation\s+\=\s+\[(\w.+)\]',line):
        bb = re.search(r'(input_transation)\s+\=\s+\[(\w.+)\]',line)
        if bb:
            #print (bb.group(1))
            #print (bb.group(2))
            l1 = bb.group(2).split(',')
            #print (l1)
            dict_data[bb.group(1)] = []
            dict_data[bb.group(1)] = l1 

    elif re.search(r'output_capacitance\s+\=\s+\[(\w.+)\]',line):
        dd = re.search(r'(output_capacitance)\s+\=\s+\[(\w.+)\]',line)
        if dd:
            #print (dd.group(1))
            #print (dd.group(2))
            l2 = dd.group(2).split(',')
            #print (l2)
            dict_data[dd.group(1)] = []
            dict_data[dd.group(1)] = l2

fh.close();

#print (dict_data)

x = 0
y = 0
for k,v in dict_data.items():
    #print (k,v);
    if (k == 'input_transation'):
        for dd1 in v:
            #print (dd1)
            x = dd1
            for k1,v1 in dict_data.items():
                #print (k,v);
                if (k1 == 'output_capacitance'):
                    for bb1 in v1:
                        ##print (bb1)
                        y = bb1
                        #print ("{} and {} ".format(x,y))
                        
                        SPI = """
 Inverter netlist \n \
.model MOSN NMOS level=8 version=3.3.0 \n \
.model MOSP PMOS level=8 version=3.3.0 \n \

** DECLARE POWER HV VOLTAGES *** \n \
.param HV=5v \n \
.param LV=0v \n \
.param TR=%s \n \
.param TF=%s \n \
.param C =%s \n \

M1 1 2 3 3 MOSP L=0.18u W=0.72u \n \
M2 1 2 0 0 MOSN L=0.18u W=0.36u \n \

*** input sources *** \n \

VDD 3 0 DC 'HV' \n \

** initial voltage, high voltage inital delay, rise time, fall time , pulse width, time period \n \
VG 2 0 pulse('LV' 'HV' 0ns 'TR' 'TF' 20ns 40ns) \n \


** analysis type *** \n \
** step, stop, start \n \
.tran 1ns 100ns 5ns \n \
*Ci in 4 1.6nF \n \

*** DEFINE CAPACITANCE *** \n \

COUT 1 0 C \n \

.measure tran tpdr TRIG v(2) VAL='HV/2' FALL=1 TARG v(1) VAL = 'HV/2' RISE=1 \n \
.measure tran tpdf TRIG v(2) VAL='HV/2' RISE=1 TARG v(1) VAL = 'HV/2' FALL=1 \n \

*.measure tran tpd param = '(tpdr+tpdf)/2' \n \

.measure tran trise TRIG v(1) VAL='0.2*HV' RISE=1 TARG v(1) VAL = '0.8*HV' RISE=1 \n \

.measure tran tfall TRIG v(1) VAL='0.8*HV' FALL=1 TARG v(1) VAL = '0.2*HV' FALL=1 \n \


** POWER CALCULATIONS *** \n \
*.measure {DC|AC|TRAN|SP} result {AVG|MIN|MAX|PP|RMS|MIN_AT|MAX_AT} out_variable <TD=td> <FROM> <TO=val> \n \

.measure tran iavg AVG i(VDD) FROM=0ns TO=40ns \
*.measure tran iavg AVG i(VDD) FROM='0.2*HV' TO='0.8*HV' \n \
.measure tran power PARAM='iavg*5' \n \

.control \n \
run \n \
.plot V(1) V(2) \n \
.ENDC \n \
.END \n \

""" % (x,x,y)
                        result = x+"_and_"+y
                        fh1 = open('main.sp','w')
                        fh1.write(SPI)
                        os.system("ngspice main.sp")
                        #print(SPI)
                        fh1.close() 
			

