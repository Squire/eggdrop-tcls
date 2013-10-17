set scriptpath_trace "/home/digital/eggdrop/scripts"
    
bind pub - !trace trace
   
proc trace {nick host hand chan text} {
global scriptpath_trace
set result [exec $scriptpath_trace/paste.sh $text]
set result [split $result \n]
foreach line $result {
putserv "PRIVMSG $chan :Your traceroute request is now ready: $line"
}
}
