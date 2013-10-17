###################################################################
##                                                               ##
##         ooo        ooooo           oooooooooo.   o8o          ##
##         `88.       .888'           `888'   `Y8b  `"'          ##
##          888b     d'888   .ooooo.   888     888 oooo          ##
##          8 Y88. .P  888  d88' `88b  888oooo888' `888          ##
##          8  `888'   888  888   888  888    `88b  888          ##
##          8    Y     888  888   888  888    .88P  888          ##
##         o8o        o888o `Y8bod8P' o888bood8P'  o888o         ##
##                                                               ##
##  File Name: dNS.tCL date: 06 November 2004                    ##
##  Has Been Ripper by MoBi aka PUPEN                            ##
##  Email: mobi@internux.web.id                                  ##
###################################################################
set dnshost(cmdchar) "."


#-----------------please don't CHANGE ANY OF THE FOLLOWING LINES----------------------
bind pub - [string trim $dnshost(cmdchar)]dns dns:res
bind pub - [string trim $dnshost(cmdchar)]resolve dns:res
bind pub n|n [string trim $dnshost(cmdchar)]amsg pub:amsg
bind pub - [string trim $dnshost(cmdchar)]User@host pub:host
bind pub - [string trim $dnshost(cmdchar)]dnsnick dns:nick
bind raw * 311 raw:host
bind raw * 401 raw:fail

set dns_chan ""
set dns_host ""
set dns_nick ""
set dns_bynick ""

proc pub:host {nick uhost hand chan arg} {
global dns_chan
set dns_chan "$chan"
putserv "WHOIS [lindex $arg 0]"
}

proc raw:host {from signal arg} {
global dns_chan dns_nick dns_host dns_bynick
set dns_nick "[lindex $arg 1]"
set dns_host "*!*[lindex $arg 2]@[lindex $arg 3]"
foreach dns_say $dns_chan { puthelp "PRIVMSG $dns_say :15\[host4!15\] The User@host of \037\002$dns_nick\017 is \037\002$dns_host\017 
." }
if {$dns_bynick == "oui"} {
                set hostip [split [lindex $arg 3] ]
                dnslookup $hostip resolve_rep $dns_chan $hostip
                set dns_bynick "non"
}
}

proc raw:fail {from signal arg} {
global dns_chan
set arg "[lindex $arg 1]"
foreach dns_say $dns_chan { puthelp "PRIVMSG $dns_say :15nick4! \037\002$arg\017: No such nick." }
}

proc dns:res {nick uhost hand chan text} {
 if {$text == ""} {
            puthelp "privmsg $chan :Syntax: [string trim $dnshost(cmdchar)]dns <host or ip>"
        } else {
                set hostip [split $text]
                dnslookup $hostip resolve_rep $chan $hostip
        }
}

proc dns:nick {nick uhost hand chan arg} {
global dns_chan dns_bynick dnshost
 if {$arg == ""} {
 puthelp "privmsg $chan :Syntax: [string trim $dnshost(cmdchar)]dnsnick <nick>"
        } else {
set dns_chan "$chan"
set dns_bynick "oui"
putserv "WHOIS [lindex $arg 0]"
        }
}

proc resolve_rep {ip host status chan hostip} {
        if {!$status} {
                puthelp "privmsg $chan  :\00315,1\[\0037,1DNS\00315,1\] \0030,1Unable to Resolve $hostip"
        } elseif {[regexp -nocase -- $ip $hostip]} {
                puthelp "privmsg $chan  :\00315,1\[\0037,1DNS\00315,1\] \0030,1Resolved $ip to $host"
        } else {
                puthelp "privmsg $chan  :\00315,1\[\0037,1DNS\00315,1\] \0030,1Resolved $host to $ip"
        }
}

putlog "Dns Resolver 3.1 by Headup Loaded"

