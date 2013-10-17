set userflag "-"
set trig ".uptime"

bind PUB $userflag $trig show_uptime
proc show_uptime {nick uhost hand chan arg} {show_uptime $nick $uhost $hand $chan $arg}
proc show_uptime {nick uhost hand chan arg} {
catch {exec uptime} uptime
putserv "PRIVMSG $chan :\00315,1\[\0037,1romania-it\00315,1\] \0030,1Uptime is: $uptime"
}

bind time - "00 00 * * *" time_update
bind time - "00 06 * * *" time_update
bind time - "00 12 * * *" time_update
bind time - "00 18 * * *" time_update

proc time_update {min hour day month year} {
catch {exec uptime} uptime
putserv "PRIVMSG #pyrexhosting :\00315,1\[\0037,1romania-it\00315,1\] \0030,1uptime is: $uptime"
} 
