# trace.tcl --
#
#	Made by ev0x 
#
#	You will need 3 scripts to use this product
#
#	trace.tcl
#	paste.php
#	paste.sh ( needs to be chmod +x ) 

set scriptpath_trace "~/eggdrop/scripts"
    
bind pub - !trace trace
bind pub - .trace trace
   
proc trace {nick host hand chan text} {
	global scriptpath_trace
	set result [exec $scriptpath_trace/paste.sh $text]
	set result [split $result \n]
	foreach line $result {
	putserv "PRIVMSG $chan :Your traceroute request is now ready: $line"
	}
}
