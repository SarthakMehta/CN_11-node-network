#Lan s i m u l a t i o n
set ns [new Simulator]
#d e f i n e c o l o r f o r data f l o w s
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
#open t r a c e f i l e s
set tracefile1 [open out.tr w]
set winfile [ open winfile w ]
$ns trace-all $tracefile1
#open nam f i l e
set namfile [ open out.nam w ]
$ns namtrace-all $namfile
proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}
#c r e a t e s i x nodes
set n0 [ $ns node ]
set n1 [ $ns node ]
set n2 [ $ns node ]
set n3 [ $ns node ]
set n4 [ $ns node ]
set n5 [ $ns node ]
set n6 [ $ns node ]
set n7 [ $ns node ]
set n8 [ $ns node ]
set n9 [ $ns node ]
set n10 [ $ns node ]

$n1 color Red
$n1 shape box
$n2 color Blue
$n2 shape box
$n8 color Green
$n8 shape box

#c r e a t e l i n k s between t h e nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
set lan [ $ns newLan " $n2 $n4 $n9 " 2Mb 10ms LL Queue/DropTail MAC/Csma/Cd Channel ]
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n5 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

#Give node p o s i t i o n
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n0 orient up
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n5 orient up
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n9 $n10 orient right

#s e t queue s i z e o f l i n k ( n2âˆ’n3 ) t o 20
$ns queue-limit $n1 $n2 20


#s e t u p TCP c o n n e c t i o n
set tcp [ new Agent/TCP/Newreno ]
$ns attach-agent $n2 $tcp
set sink [ new Agent/TCPSink/DelAck ]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 1000
#s e t f t p o v e r t c p c o n n  e c t i o n
set ftp [ new Application/FTP ]
$ftp attach-agent $tcp


#s e t u p a UDP c o n n e c t i o n
set udp2 [ new Agent/UDP]
$ns attach-agent $n1 $udp2
set null [ new Agent/Null ]
$ns attach-agent $n10 $null
$ns connect $udp2 $null
$udp2 set fid_ 2
$udp2 set packet_size_ 1000
#s e t u p a CBR o v e r UDP c o n n e c t i o n
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp2
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate 0.01Mb
$cbr set random false


#s e t u p a UDP c o n n e c t i o n
set udp [ new Agent/UDP]
$ns attach-agent $n8 $udp
set null [ new Agent/Null ]
$ns attach-agent $n0 $null
$ns connect $udp $null
$udp set fid_ 3
$udp set packet_size_ 1000
#s e t u p a CBR o v e r UDP c o n n e c t i o n
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp
$cbr0 set type_ CBR
$cbr0 set packet_size_ 1000
$cbr0 set rate 0.01Mb
$cbr0 set random false



#s c h e d u l i n g t h e e v e n t s
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 40.0 "$cbr stop"



$ns at 100.0 "$cbr0 start"
$ns at 110.0 "$ftp stop"
$ns at 120.0 "$cbr0 stop"



proc plotWindow {tcpSource file} \
{
global ns
set time 0.1 
set now [$ns now]
set cwnd1 [$tcpSource set cwnd_]
puts $file "$now $cwnd1"
$ns at [ expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 " plotWindow $tcp $winfile "
$ns at 125.0 "finish"
$ns run

