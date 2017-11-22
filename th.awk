BEGIN {
 recv=0;
 gotime = 1;
 time = 0;
 sum = 0;
 packet_size = 1023;
 time_interval=1;
 }
 #body
 {
         event = $1
         time = $2
         node_id = $3
         level = $4
         pktType = $7
 
 if(time>gotime) {
#  print gotime, (packet_size * recv); #packet size * ... gives results in kbps
 # print gotime, recv, (packet_size * recv);   

sum = sum + (packet_size * recv);
   gotime+= time_interval;
   recv=0;
   }


 
 
#============= CALCULATE throughput=================
 
if (( event == "r") && ( level=="MAC" ) && ( pktType == "cbr" ))
 {
  recv++;
 }
 
} #body
 


END {
print sum, gotime-11, sum/(gotime-11)/1024/1024; #Mbps
 }
