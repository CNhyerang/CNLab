

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhyExt         ;# network interface type, dont know if it was already here
set val(netif)          Phy/WirelessPhy            ;# network interface type 
set val(mac)            Mac/802_11Ext              ;# MAC type Mac/802_11, dont remember if it was already here
set val(mac)            Mac/802_11                 ;# MAC type Mac/802_11
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             [lindex $argv 0]           ;# default number of stations
set val(rp)             DSDV                    ;# routing protocol //AODV /DSDV                      ;# 
#set val(rp)             DumbAgent 			;
set val(x)		1000.0			   ;
set val(y)		1000.0			   ;
set val(seed)		1		  		 ;
set _startTime		41.0			   ;	

# ======================================================================
# Set up simulator
# ======================================================================
set val(simtime)	    1000.0		;# simulation time in seconds
$val(mac) set CWMin_        31	;# min contention window
$val(mac) set CWMax_        255	;# max contention window
$val(mac) set dataRate_     11Mb	;# physical layer date rate
$val(mac) set SlotTime_     0.000050
$val(mac) set SIFS_         0.000028
$val(mac) set DIFS_         0.000128
#$val(mac) set MAC Header_   272
#$val(mac) set PHY Header_   128
$val(mac) set ACK_          240
$val(mac) set RTS_          288
$val(mac) set CTS_          240
$val(mac) set ACK_Timeout   0.000300
$val(mac) set CTS_Timeout   0.000300
$val(mac) set basicRate_    1Mb	;# physical layer basic rate
# $val(mac) set basicRate_    [lindex $argv 3]Mb	;# physical layer basic rate
#$val(mac) set RTSThreshold_ 0 ;		# RTS/CTS
$val(mac) set RTSThreshold_ 99999 ;	# Basic
Agent/UDP               set packetSize_   1023 ;# packet size
Application/Traffic/CBR set rate_         1Mb  ;# application rate
Application/Traffic/CBR set packetSize_   8184 ;# packet size


# ======================================================================
# useful part for cs320 lab
# ======================================================================


# ======================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#
set ns_		[new Simulator] ;# new a simulator object
set tracefd     [open 802_11.tr w]  ;# open trace file
$ns_ trace-all $tracefd         ;# trace all protocols activities

set namtrace [open 802_11.nam w]    ;# open nam trace file which is for graphical display
#$ns_ use-newtrace		;# use the new type of trace format

# set up topography object
set topo       [new Topography] ;# new a topology object
set god_       [create-god $val(nn)] ;# useless, but have to use for no reason


############ol

set prop	[new $val(prop)]
set chan_ 	[new $val(chan)]
$topo load_flatgrid $val(x) $val(y)
###############################################################################

# configure nodes

set chan [new $val(chan)]
$ns_ node-config -adhocRouting $val(rp) \
	 -llType $val(ll) \
	 -macType $val(mac) \
	 -ifqType $val(ifq) \
	 -ifqLen $val(ifqlen) \
	 -antType $val(ant) \
	 -propType $val(prop) \
	 -phyType $val(netif) \
	 -channel $chan \
	 -topoInstance $topo \
	 -agentTrace OFF \
	 -routerTrace OFF \
	 -macTrace ON\
	 -movementTrace OFF

$ns_ set WirelessNewTrace_ ON

# create nodes
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
	$node_($i) set X_ 10.0 #// 10.0
	$node_($i) set Y_ 10.0 #//10.0
	$node_($i) set Z_ 0.0

}
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 20
}


# create applications from station 'i' to station 'i+1'
for {set i 0} {$i < $val(nn)} {incr i} {
	set udp_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($i) $udp_($i)


# 	create the destination of one CBR application
	set null_($i) [new Agent/Null]
	$ns_ attach-agent $node_([expr ($i+1)%$val(nn)]) $null_($i)

# 	create the source of one CBR application
	set cbr_($i) [new Application/Traffic/CBR]

	$cbr_($i) attach-agent $udp_($i)

	$cbr_($i) set packetSize_ 1024
	$cbr_($i) set interval_ 0.1

# 	connect the source and the destination
        $ns_ connect $udp_($i) $null_($i)

# 	start the application immediately when the simulation starts
#	$ns_ at 10 "$cbr_($i) start" 
	set startOn [expr $_startTime + 0.0005 * $i]
	$ns_ at [expr 10+0.01*($i)] "$cbr_($i) start" 
}

	
#
# Tell nodes when the simulation ends, and what to do when stops
#

$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

# now, let us start the simulation
puts "Starting Simulation..."
$ns_ run

