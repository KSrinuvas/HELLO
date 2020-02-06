#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

sub Read_Data {
	my $file = $_[0];
	my $hash_ref = {};
	my @d1 = ();
	my @d2 = ();
	open(IN,$file) || die "Not able to open '$file' $!";
	while (my $line = <IN>)	{
		chomp($line);
		if ($line =~ /(inp.\S+)\s+\=\s+\[(\S+)\]/) {
			push(@d1,split(",",$2));
			$hash_ref->{$1} = \@d1;
		} elsif ($line =~  /(out.\S+)\s+\=\s+\[(\S+)\]/) {
			push(@d2,split(",",$2));
			$hash_ref->{$1} = \@d2;
		}
	}
	return $hash_ref;
	close(IN);
}

## return the hash
my %hash = %{Read_Data($ARGV[0])};  

## Spice netlist data store EOF varible is $var; 
my $var = '';
## declar the varible for $x is the transtation values and y is the ouputload values 
my ($x,$y) = (0,0);
foreach my $key1 (keys %hash) {
	if ($key1 =~ /inp.*/) {
		foreach my $ele1 (@{$hash{$key1}}) {
			$x = $ele1;
			foreach my $key2 (keys %hash) {
				if ($key2 =~ /out.*/) {
					foreach my $ele2 (@{$hash{$key2}}) {
						$y = $ele2;
						$var =<<"EOF";
 Inverter netlist \n \
.model MOSN NMOS level=8 version=3.3.0 \n \
.model MOSP PMOS level=8 version=3.3.0 \n \

** DECLARE POWER HV VOLTAGES *** \n \
.param HV=5v \n \
.param LV=0v \n \
.param TR=$x \n \
.param TF=$x \n \
.param C = $y \n \

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
plot V(1) V(2) \n \
.ENDC \n \
.END \n \

EOF

						my $result = $x."_and_".$y;
						open(OUT,">level_net.sp") || die "Not able to write 'level_net.sp' $!";
						print OUT $var;
						open(OUT1,">$result") || die "Not able to write '$result' $!";
						my $data = qx{ngspice -b level_net.sp};
						print OUT1 $data;
						close(OUT);
						close(OUT1);	
					}
				}

			}
		}
	}
}






