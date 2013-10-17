###  facelift.tcl v3.6.1 by Kindred <kindred@kindreds.net>    ###
###  Based on a script by quest.                            ###  
###  Special thanks to zen and guppy for their work.        ###


## THIS REQUIRES eggdrop v1.3.7 or later with toolkit.tcl or alltools.tcl
## For  .(ch)email, (ch)url cmd via dcc chat load facelift after userinfo1.0.tcl


### Version History
## Version 3.6.1 (eggdrop version 1.3.7 or later)
##   Quick fix on another bug found in join_greet.

## Version 3.6
##   Added channel user suppost for most +o cmds and all +p cmds.
##   Added shortcuts for whois and userinfo pub/dcc cmds
##   Fixed a bug in the public command for whois
##   Fixed a major bug in the greet/email/url commands/usage


## Version 3.5 
##   added commas for the .who, .whom cmds
##   revamped .whois cmd
##   fixed match cmd to be more specific to errors.
##   added option to show nick in topic if desired.
##   added switches to .+ban,.ban,.kb,.kickban, example .+ban *!*test@*test.com -hours 4 out! -perm, -min, -hours, -days, -weeks
##   added default time for bans indicated by the config file.
##   touched up typing errors in the code.
##   added userport and hostmask option for +bot cmd
##   added password option for .jump cmd
##   added password/fix for join cmd
##   secured +host/-host a little more
##   +user now allows for it to auto add hostmask if not specified
##   greet, chgreet, churl, url, chemail, email have been massively improved with a new saving system.
##   userinfo has been revised for the cmds mentioned above.
##   improved whois cmd
##   dccstats works now
##   shortened .rehash, .restart
##   dump cmd now works.
##   fixed minor bugs in ignores, +ignore
##   motd is now a 3 line alternate version, similar to how undernet does it.
##   if no nick is offered for op/deop then it ops user doing the cmd.

## Version 1.0.1 --> 3.1
##  E-Mail me for the history, this file has become to big.

## Version 1.0
##   Released


### Set your Command Character below
set CC "."

### Set Your Bot's Time Zone here
set timezone "PST"

### Set channel to NEVER part from! (this is your main channel)
set nopart ""

### Adds the users nick in the topic when they set it via the bot. 1=yes 0=no
set topicnick 0

### Set Greet flag (must be capitalized)
set greetflag G

### How often to backup facelift files. (in minutes)
set min 60

### Do you want public commands for flags o p x? 1=yes 0=no
set pubcommands 1

### Do you want public commands for flag m? 1=yes 0=no
set mastercommands 1

### Do you want public commands for flag n? 1=yes 0=no
set ownercommands 1

### Do you want additional dcc commands? 1=yes 0=no
set moredcc 1

### Do you want combot commands? 1=yes 0=no
set combot 1

### Do you want pez and ramen commands? 1=yes 0=no
set funny_stuff 1

### Do you want dumb beer and drug commands? (VERY FUNNY!) 1=yes 0=no
set rrated_funny_stuff 1

### This is where your bot path is set, dont change it if you dont know what your doing
set path "[pwd]/"


######################################################################













############################################################
############# DON'T CHANGE BELOW THIS LINE!!!! #############
############################################################








































if {$numversion < 1030700} {
  putlog "*** Can't load Facelift -- At least Eggdrop v1.3.7 required"
  return 0
}

set thepath $path
set newpath $path
set greetfile "${nick}.greet"
set emailfile "${nick}.email"
set urlfile "${nick}.url"
if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}
if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}

foreach x [timers] {
  if {[lindex $x 1] == "facelift_autosave"} {
    killtimer [lindex $x 2]
  }
}

#foreach u [utimers] {
#  if {[lindex $u 1] == "facelift_check"} {
#    killutimer [lindex $u 2]
#  }
#}

bind join G|G * join_greet
bind pub p|p ${CC}about pub_about
bind dcc p|p about dcc_about
bind pub p|p ${CC}version pub_version
bind dcc p|p version dcc_version
bind msg p|p auth msg_auth
bind msg p|p deauth msg_deauth
bind sign p|p * sign_deauth
bind part p|p * part_deauth

proc botname {} {global botname;return $botname}

if {$pubcommands==1} {
bind pub p|p ${CC}echo pub_echo
bind pub p|p ${CC}seen pub_seen
bind pub p|p ${CC}who pub_who
bind pub p|p ${CC}whois pub_whois
bind pub p|p ${CC}wi pub_whois
bind pub p|p ${CC}whom pub_whom
bind pub o|o ${CC}match pub_match
bind pub p|p ${CC}bots pub_bots
bind pub p|p ${CC}bottree pub_bottree
bind pub p|p ${CC}notes pub_notes
bind pub o ${CC}+ban pub_+ban
bind pub o ${CC}ban pub_ban
bind pub o ${CC}kb pub_kb
bind pub o ${CC}kickban pub_kickban
bind pub o ${CC}-ban pub_-ban
bind pub o ${CC}bans pub_bans
bind pub o ${CC}resetbans pub_resetbans
bind pub o|o ${CC}op pub_op
bind pub o|o ${CC}deop pub_deop
bind pub o|o ${CC}topic pub_topic
bind pub o|o ${CC}act pub_act
bind pub o|o ${CC}say pub_say
bind pub o|o ${CC}msg pub_msg
bind pub o|o ${CC}motd pub_motd
bind pub o|o ${CC}addlog pub_addlog
bind pub o|o ${CC}invite pub_invite
bind pub o|o ${CC}nick pub_nick
bind pub o|o ${CC}away pub_away
bind pub o|o ${CC}back pub_back
bind pub p|p ${CC}note pub_note
bind pub x|x ${CC}files pub_files
bind pub p|p ${CC}newpass pub_newpass
bind pub o|o ${CC}console pub_console
bind pub p|p ${CC}quit pub_quit
bind pub p|p ${CC}info pub_info
bind pub x|x ${CC}get pub_get
bind pub p|p ${CC}botinfo pub_botinfo
bind pub p|p ${CC}chat pub_chat
bind pub p|p ${CC}channel pub_channel
bind pub p|p ${CC}time pub_time
bind pub o|o ${CC}kick pub_kick
bind pub p|o ${CC}k pub_k
bind pub p|p ${CC}channels pub_channels
bind pub o|o ${CC}botinfo pub_botinfo
bind pub o|o ${CC}traced pub_trace
bind pub o|o ${CC}stick pub_stick
bind pub o|o ${CC}unstick pub_unstick
bind pub o|o ${CC}su pub_su
bind pub p|p ${CC}page pub_page
bind pub p|p ${CC}comment pub_comment
bind pub o|o ${CC}+t mode_+t
bind pub o|o ${CC}+n mode_+n 
bind pub o|o ${CC}+s mode_+s
bind pub o|o ${CC}+i mode_+i
bind pub o|o ${CC}+p mode_+p
bind pub o|o ${CC}+m mode_+m
bind pub o|o ${CC}+k mode_+k
bind pub o|o ${CC}+l mode_+l
bind pub o|o ${CC}-v mode_-v
bind pub o|o ${CC}-t mode_-t
bind pub o|o ${CC}-s mode_-s
bind pub o|o ${CC}-l mode_-l
bind pub o|o ${CC}-k mode_-k
bind pub o|o ${CC}-m mode_-m 
bind pub o|o ${CC}-i mode_-i
bind pub o|o ${CC}-n mode_-n
bind pub o|o ${CC}-p mode_-p
bind pub p|p ${CC}email pub_email
bind pub p|p ${CC}url pub_url
bind pub p|p ${CC}greet pub_greet
bind pub p|p ${CC}userinfo pub_userinfo
bind pub p|p ${CC}ui pub_userinfo
}

if {$mastercommands==1} {
bind pub m ${CC}adduser pub_adduser
bind pub m ${CC}+user pub_+user
bind pub m ${CC}-user pub_-user
bind pub m ${CC}deluser pub_deluser
bind pub m ${CC}+bot pub_+bot
bind pub m ${CC}-bot pub_-bot
bind pub p ${CC}+host pub_+host
bind pub p ${CC}-host pub_-host
bind pub m ${CC}chattr pub_chattr
bind pub m ${CC}save pub_save
bind pub m ${CC}chpass pub_chpass
bind pub m ${CC}chinfo pub_chinfo
bind pub m ${CC}chnick pub_chnick
bind pub m ${CC}chcomment pub_chcomment
bind pub m ${CC}+ignore pub_+ignore
bind pub m ${CC}-ignore pub_-ignore
bind pub m ${CC}ignores pub_ignores
bind pub m ${CC}reload pub_reload
bind pub m ${CC}jump pub_jump
bind pub m ${CC}rehash pub_rehash
bind pub m ${CC}restart pub_restart
bind dcc m join cmd_join
bind pub m ${CC}join pub_join
bind dcc m part cmd_part
bind pub m ${CC}part pub_part
bind dcc m global cmd_global
bind pub m ${CC}chaddr pub_chaddr
bind pub m ${CC}filestats pub_filestats
bind pub m ${CC}fixcodes pub_fixcodes
bind pub m ${CC}strip pub_strip
bind pub m ${CC}link pub_link
bind pub m ${CC}unlink pub_unlink
bind pub m ${CC}chbotattr pub_chbotattr
bind pub m ${CC}assoc pub_assoc
bind pub m ${CC}status pub_status
bind pub m ${CC}chaninfo pub_chaninfo
bind pub m ${CC}boot pub_boot
bind pub m ${CC}relay pub_relay
bind pub m ${CC}set pub_set
bind pub m ${CC}flush pub_flush
bind pub m ${CC}banner pub_banner
bind pub m ${CC}reset pub_reset
bind pub m ${CC}binds pub_binds
bind pub m ${CC}dump pub_dump
bind pub m ${CC}debug pub_debug
bind pub m ${CC}+chrec pub_+chrec
bind pub m ${CC}-chrec pub_-chrec
bind pub m ${CC}dccstat pub_dccstat
bind pub m ${CC}botattr pub_botattr
bind pub m ${CC}chemail pub_cchemail
bind pub m ${CC}churl pub_churl
bind pub m ${CC}chgreet pub_chgreet
bind dcc m chemail dcc_chemail
bind dcc m churl dcc_churl
bind dcc m chgreet dcc_chgreet
bind pub m ${CC}chemail pub_chemail
bind pub m ${CC}churl pub_churl
bind pub m ${CC}chgreet pub_chgreet
}

if {$ownercommands==1} {
bind dcc n botnick dcc_botnick
bind pub n ${CC}botnick pub_botnick
bind pub n ${CC}die pub_die
bind pub n ${CC}chanset pub_chanset
bind pub n ${CC}chansave pub_chansave
bind pub n ${CC}chanload pub_chanload
bind pub n ${CC}+chan pub_+chan
bind pub n ${CC}-chan pub_-chan
bind pub n ${CC}simul pub_simul
bind pub n ${CC}modules pub_modules
bind pub n ${CC}loadmodule pub_loadmodule
bind pub n ${CC}unloadmodule pub_unloadmodule
bind dcc n flsave dcc_flsave 
}

if {$moredcc==1} {
bind dcc o|o userlist cmd_userlist
bind dcc p|p channels cmd_channels
bind dcc o|o flagnote cmd_flagnote
bind dcc o|o say cmd_say
bind dcc o|o act cmd_act
bind dcc o|o addlog cmd_addlog
bind dcc o|o op cmd_op
bind dcc o|o deop cmd_deop
bind dcc m aop cmd_aop
bind dcc m raop cmd_raop
bind dcc o|o match dcc_match
bind filt p \001ACTION*\001 cmd_action
bind dcc p|p email dcc_email
bind dcc p|p url dcc_url
bind dcc p|p greet dcc_greet
bind dcc p|p userinfo dcc_userinfo
bind dcc p|p ui dcc_userinfo
bind dcc p|p wi dcc_wi
}

if {$combot==1} {
bind pub m ${CC}aop pub_aop
bind pub m ${CC}raop pub_raop
bind pub o|o ${CC}userlist pub_userlist
bind pub o|o ${CC}me pub_me
bind pub o|o up pub_up
bind pub o|o ${CC}up pub_up
bind pub o|o down pub_down
bind pub o|o ${CC}down pub_down
bind pub p|p ${CC}pong pub_pong
bind pub p|p ${CC}ping pub_ping
bind pub o ${CC}ban pub_ban
bind pub p|p ${CC}access pub_access
bind dcc p|p access dcc_access
bind pub -|- rollcall pub_rollcall
bind pub -|- ${CC}rollcall pub_rollcall
bind pub m ${CC}massunban pub_massunban
bind pub m ${CC}mub pub_massunban
bind dcc m massunban dcc_massunban
bind dcc m mub dcc_mub
bind dcc m massdeop dcc_massdeop
bind dcc m massop dcc_massop
bind dcc m mdeop cmd_mdeop
bind dcc m mop cmd_mop
bind pub m ${CC}massdeop pub_massdeop
bind pub m ${CC}massop pub_massop
bind pub m ${CC}mop pub_massop
bind pub m ${CC}mdeop pub_massdeop
}


if {$funny_stuff==1} {
bind pub p|p ${CC}pez pub_pez
bind pub p|p ${CC}ramen pub_ramen
}

if {$rrated_funny_stuff==1} {
bind pub p|p ${CC}beer pub_beer
bind pub p|p ${CC}drug pub_drug
}

## modes via pubic cmd -- start
proc mode_+v {nick uhost hand chan rest} {  
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+v <nick>"
  return 0
 }
 if {[onchan $rest $chan] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not on the channel."
  return 0
 }
 if {[isvoice $rest $chan] == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already +v"
 }
 if {[onchan $rest $chan] == 1} {
  pushmode $chan +v $rest
 }
}

proc mode_-v {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
}
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-v <nick>"
  return 0
 }
 if {[onchan $rest $chan] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not on the channel."
  return 0
 }
 if {[isvoice $rest $chan] == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already -v"
 }
 if {[onchan $rest $chan] == 1} {
  pushmode $chan -v $rest
 }
}

proc mode_+t {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +t
}

proc mode_-t {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -t
}

proc mode_+s {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +s-p
}

proc mode_-s {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -s
}

proc mode_+p {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +p-s
}

proc mode_-p {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -p
}

proc mode_+n {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +n
}

proc mode_-n {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -n
}

proc mode_+i {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +i
}

proc mode_-i {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -i
}

proc mode_+m {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan +m
}

proc mode_-m {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -m
}

proc mode_+l {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+l <limit>"
  return 0
 }
 pushmode $chan +l $rest
}

proc mode_-l {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -l $rest
}

proc mode_+k {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+k <key>"
  return 0
 }
 pushmode $chan +k $rest
}

proc mode_-k {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 pushmode $chan -k $rest
}

proc mode_+b {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+b <hostmask>"
  return 0
 }
 pushmode $chan +b $rest
}

proc mode_-b {nick uhost hand chan rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-b <hostmask>"
  return 0
 }
 pushmode $chan -b $rest
}
## modes via pubic cmd -- stop


## public cmd echo -- start
proc pub_echo {nick uhost hand chan rest} {
global botnick version CC
 puthelp "NOTICE $nick :\002\[FL\]\002 echo is only available via dcc chat."
} 

## start of dcc/pub cmds for userinfo, greet, chgreet, chemail, email, churl, url

proc url_read {} {
 global url botnick nick thepath
 set urlfile "${nick}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 if {![file exists $urlpath]} {
   set fd [open $urlpath w]
   puts $fd "### \[FL\] Created on [unixtime]"
   close $fd
   putlog "\002\[FL\]\002 Creating url file information."
 }
 if {[file exists $urlpath]} {
   set fd [open $urlpath r]
   while {![eof $fd]} {
     set urlinfo [gets $fd]
     if {[string trim $urlinfo " "] != ""} {
       set url([lindex $urlinfo 0]) [lrange $urlinfo 1 end]
     }
   }
   close $fd
   return "url_read" 
 }
}

proc greet_read {} {
 global greet nick thepath
 set greetfile "${nick}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 if {![file exists $greetpath]} {
   set fd [open $greetpath w]
   puts $fd "### \[FL\] Created on [unixtime]"
   close $fd
   putlog "\002\[FL\]\002 Creating greet file information"
 }
 if {[file exists $greetpath]} {
   set fd [open $greetpath r]
   while {![eof $fd]} {
     set greetinfo [gets $fd]
     if {[string trim [lindex $greetinfo 0] " "] != ""} {
       set greet([lindex $greetinfo 0]) [lrange $greetinfo 1 end]
     }
   }
   close $fd
   return "greet_read" 
 }
}

proc email_read {} {
 global email nick thepath
 set emailfile "${nick}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"} 
 if {![file exists $emailpath]} {
   set fd [open $emailpath w]
   puts $fd "### \[FL\] Created on [unixtime]"
   close $fd
   putlog "\002\[FL\]\002 Creating email file information"
 }
 if {[file exists $emailpath]} {
   set fd [open $emailpath r]
   while {![eof $fd]} {
     set emailinfo [gets $fd]
     if {[string trim [lindex $emailinfo 0] " "] != ""} {
       set email([lindex $emailinfo 0]) [lrange $emailinfo 1 end]
     }
   }
   close $fd
   return "email_read"
 }
}



if {(![info exists greet]) || ([array size greet] == 0)} {
  greet_read
  putlog "Loading \[FL\] Greet File..."
}
if {(![info exists url]) || ([array size url] == 0)} {
  url_read
  putlog "Loading \[FL\] URL File..."
}
if {(![info exists email]) || ([array size email] == 0)} {
  email_read
  putlog "Loading \[FL\] E-Mail File..."
}


timer $min facelift_autosave
proc facelift_autosave {} {
 global min
 putlog "\002\[FL\]\002 Automatically backing up greet information"
 greet_save
 putlog "\002\[FL\]\002 Automatically backing up email information"
 email_save
 putlog "\002\[FL\]\002 Automatically backing up url information"
 url_save
 timer $min facelift_autosave
}

proc dcc_flsave {hand idx arg} {
 putcmdlog "#$hand# flsave"
 putlog "\002\[FL\]\002 ${hand} requested backup of greet information"
 greet_save
 putlog "\002\[FL\]\002 ${hand} requested backup of email information"
 email_save
 putlog "\002\[FL\]\002 ${hand} requested backup of url information"
 url_save
}

proc url_save {} {
 global url nick thepath
 set urlfile "${nick}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 if {[file exists $urlpath]} {
   set fd [open $urlpath w]
   set start [array startsearch url]
   puts $fd "### $url(###)"
   while {[array anymore url $start]} {
     set item [array nextelement url $start]
     if {$item != "###"} {
       puts $fd "$item $url($item)"
     }
   }
   array donesearch url $start
   unset start
   close $fd
   putlog "\002\[FL\]\002 saving url information complete."
   return "url_save"
 }
}

proc greet_save {} {
 global greet botnick nick thepath
 set greetfile "${nick}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 if {[file exists $greetpath]} {
   set fd [open $greetpath w]
   set start [array startsearch greet]
   puts $fd "### $greet(###)"
   while {[array anymore greet $start]} {
     set item [array nextelement greet $start]
     if {$item != "###"} {
       puts $fd "$item $greet($item)"
     }
   }
   array donesearch greet $start
   close $fd
   putlog "\002\[FL\]\002 saving greet information complete."
 }
}

proc email_save {} {
 global email nick thepath
 set emailfile "${nick}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"} 
 if {[file exists $emailpath]} {
   set fd [open $emailpath w]
   set start [array startsearch email]
   puts $fd "### $email(###)"
   while {[array anymore email $start]} {
     set item [array nextelement email $start]
     if {$item != "###"} {
       puts $fd "$item $email($item)"
     }
   }
   array donesearch email $start
   unset start
   close $fd
   putlog "\002\[FL\]\002 saving email information complete."
   return "email_save"
 }
}

catch {unbind dcc - restart *dcc:restart ;bind dcc m restart fl_orig_restart} 0
proc fl_orig_restart {hand idx arg} {
 global greet url email thepath
 greet_save;email_save;url_save
 *dcc:restart $hand $idx $arg
}

catch {unbind dcc - rehash *dcc:rehash ;bind dcc m rehash fl_orig_rehash} 0
proc fl_orig_rehash {hand idx arg} {
 global greet url email thepath
 greet_save;email_save;url_save
 *dcc:rehash $hand $idx $arg
}

catch {unbind dcc - die *dcc:die ;bind dcc n die fl_orig_die} 0
proc fl_orig_die {hand idx arg} {
 greet_save;email_save;url_save
 *dcc:die $hand $idx $arg
}

set thebot $nick

proc pub_greet {nick uhost hand chan rest} {
 global greet botnick CC thepath thebot
 set greetfile "${thebot}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 set greetinfo [lrange $rest 0 end]
 if {$greetinfo == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}greet <new greet>"
   return 0
 }
 if {[lindex $greetinfo 0] == "none"} {
   set greet([string tolower $hand]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# greet $greetinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 Your Greet msg has been removed." 
   return 0
 }
 set greet([string tolower $hand]) "$greetinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# greet $greetinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 Setting for '\002greet\002' is now $greetinfo"
}

proc dcc_greet {hand idx arg} {
 global greet botnick thebot CC thepath
 set greetfile "${thebot}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 set greetinfo [lrange $arg 0 end]
 if {$greetinfo == ""} {
   putdcc $idx "\002\[FL\]\002 Usage: .greet <new greet>"
   return 0
 }
 if {[lindex $greetinfo 0] == "none"} {
   set greet([string tolower $hand]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# greet $greetinfo"
   putdcc $idx "\002\[FL\]\002 Your Greet msg has been removed."
   return 0
 }
 set greet([string tolower $hand]) "$greetinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# greet $greetinfo"
 putdcc $idx "\002\[FL\]\002 Setting for '\002greet\002' is now $greetinfo"
}

proc pub_email {nick uhost hand chan rest} { 
 global email botnick CC thebot thepath
 set emailfile "${thebot}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}
 set emailinfo [lrange $rest 0 end]
 if {$emailinfo == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}email <new email>"
   return 0
 }
 if {[lindex $emailinfo 0] == "none"} {
   set email([string tolower $hand]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# email $emailinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 Your email msg has been removed."
   return 0
 }
 set email([string tolower $hand]) "$emailinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# email $emailinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 Setting for '\002email\002' is now $emailinfo"
}

proc dcc_email {hand idx arg} { 
 global email botnick thebot CC thepath
 set emailfile "${thebot}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}
 set emailinfo [lrange $arg 0 end]
 if {$emailinfo == ""} {
   putdcc $idx "\002\[FL\]\002 Usage: email <new email>"
   return 0
 }
 if {[lindex $emailinfo 0] == "none"} {
   set email([string tolower $hand]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# email $emailinfo"
   putdcc $idx "\002\[FL\]\002 Your email msg has been removed."
   return 0
 }
 set email([string tolower $hand]) "$emailinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# email $emailinfo"
 putdcc $idx "\002\[FL\]\002 Setting for '\002email\002' is now $emailinfo"
}

proc pub_chemail {nick uhost hand chan rest} { 
 global email botnick thebot CC thepath
 set emailfile "${thebot}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}
 set user [string tolower [lindex $rest 0]]
 set emailinfo [lrange $rest 1 end]
 if {($emailinfo == "") || ($user == "")} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chemail <new email>"
   return 0
 }
 if {![validuser $user]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $emailinfo 0] == "none"} {
   set email([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# chemail $user $emailinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s email msg has been removed."
   return 0
 }
 set email([string tolower $user]) "$emailinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# chemail $user $emailinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s Setting for '\002email\002' is now $emailinfo"
}

proc dcc_chemail {hand idx arg} { 
 global email botnick thebot thepath
 set emailfile "${thebot}.email"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}
 set user [string tolower [lindex $arg 0]]
 set emailinfo [lrange $arg 1 end]
 if {($emailinfo == "") || ($user == "")} {
   putdcc $idx "\002\[FL\]\002 Usage: ${CC}chemail <new email>"
   return 0
 }
 if {![validuser $user]} {
   putdcc $idx "\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $emailinfo 0] == "none"} {
   set email([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# chemail $user $emailinfo"
   putdcc $idx "\002\[FL\]\002 ${user}'s email msg has been removed."
   return 0
 }
 set email([string tolower $user]) "$emailinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# chemail $user $emailinfo"
 putdcc $idx "\002\[FL\]\002 ${user}'s Setting for '\002email\002' is now $emailinfo"
}

proc pub_chgreet {nick uhost hand chan rest} { 
 global greet botnick thebot CC thepath
 set greetfile "${thebot}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 set user [string tolower [lindex $rest 0]]
 set greetinfo [lrange $rest 1 end]
 if {($greetinfo == "") || ($user == "")} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chgreet <new greet>"
   return 0
 }
 if {![validuser $user]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $greetinfo 0] == "none"} {
   set greet([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# chgreet $user $greetinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s greet msg has been removed."
   return 0
 }
 set greet([string tolower $user]) "$greetinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# chgreet $user $greetinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s Setting for '\002greet\002' is now $greetinfo"
}

proc dcc_chgreet {hand idx arg} { 
 global greet botnick thebot thepath
 set greetfile "${thebot}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 set user [string tolower [lindex $arg 0]]
 set greetinfo [lrange $arg 1 end]
 if {($greetinfo == "") || ($user == "")} {
   putdcc $idx "\002\[FL\]\002 Usage: ${CC}chgreet <new greet>"
   return 0
 }
 if {![validuser $user]} {
   putdcc $idx "\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $greetinfo 0] == "none"} {
   set greet([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# chgreet $user $greetinfo"
   putdcc $idx "\002\[FL\]\002 ${user}'s greet msg has been removed."
   return 0
 }
 set greet([string tolower $user]) "$greetinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# chgreet $user $greetinfo"
 putdcc $idx "\002\[FL\]\002 ${user}'s Setting for '\002greet\002' is now $greetinfo"
}

proc pub_url {nick uhost hand chan rest} {
 global url botnick thebot CC thepath
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 set urlinfo [lrange $rest 0 end]
 if {$urlinfo == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}url <new url>"
   return 0
 }
 if {[lindex $urlinfo 0] == "none"} {
   set url([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# url $urlinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 Your url msg has been removed." 
   return 0
 }
 set url([string tolower $hand]) "$urlinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# url $urlinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 Setting for '\002url\002' is now $urlinfo"
}

proc dcc_url {hand idx arg} {
 global url botnick thebot thepath
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 set urlinfo [lrange $arg 0 end]
 if {$urlinfo == ""} {
   putdcc $idx "\002\[FL\]\002 Usage: .url <new url>"
   return 0
 }
 if {[lindex $urlinfo 0] == "none"} {
   set url([string tolower $hand]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# url $urlinfo"
   putdcc $idx "\002\[FL\]\002 Your url msg has been removed."
   return 0
 }
 set url([string tolower $hand]) "$urlinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# url $urlinfo"
 putdcc $idx "\002\[FL\]\002 Setting for '\002url\002' is now $urlinfo"
}

proc pub_churl {nick uhost hand chan rest} { 
 global url botnick thebot CC thepath
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 set user [string tolower [lindex $rest 0]]
 set urlinfo [lrange $rest 1 end]
 if {($urlinfo == "") || ($user == "")} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}churl <new url>"
   return 0
 }
 if {![validuser $user]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $urlinfo 0] == "none"} {
   set url([string tolower $user]) ""
   putcmdlog "\002\[FL\]\002 #${hand}# churl $user $urlinfo"
   puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s url msg has been removed."
   return 0
 }
 set url([string tolower $user]) "$urlinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# churl $user $urlinfo"
 puthelp "NOTICE $nick :\002\[FL\]\002 ${user}'s Setting for '\002url\002' is now $urlinfo"
}

proc dcc_churl {hand idx arg} { 
 global url botnick thebot thepath
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 set user [string tolower [lindex $arg 0]]
 set urlinfo [lrange $arg 1 end]
 if {($urlinfo == "") || ($user == "")} {
   putdcc $idx "\002\[FL\]\002 Usage: ${CC}churl <new url>"
   return 0
 }
 if {![validuser $user]} {
   putdcc $idx "\002\[FL\]\002 no such user."
   return 0
 }
 if {[lindex $urlinfo 0] == "none"} {
   set url($user) ""
   putcmdlog "\002\[FL\]\002 #${hand}# churl $user $urlinfo"
   putdcc $idx "\002\[FL\]\002 ${user}'s url msg has been removed."
   return 0
 }
 set url(${user}) "$urlinfo"
 putcmdlog "\002\[FL\]\002 #${hand}# churl $user $urlinfo"
 putdcc $idx "\002\[FL\]\002 ${user}'s Setting for '\002url\002' is now $urlinfo"
}

proc pub_ui {nick uhost hand chan rest} {
 global greet url thebot email CC timezone botnick thepath 
 pub_userinfo $nick $uhost $hand $chan $rest
}
 
proc pub_userinfo {nick uhost hand chan rest} {
 global greet url thebot email CC timezone botnick thepath
 set greetfile "${thebot}.greet"
 set emailfile "${thebot}.email"
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}   
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}

 set user [lindex $rest 0]
 if {$user == ""} {set user $hand}
 puthelp "NOTICE $nick :\002\[FL\]\002 Information about $user" 
 puthelp "NOTICE $nick :\002\[FL\]\002 Current Time   : [ctime [unixtime]] $timezone"
 if {[validuser $user] == 0} {
   puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
   return 0
 }
 if {[onchan $user $chan]} {
   set last "Is currently online."
 } else {
   set last "[ctime [lindex [getuser $user LASTON] 0]]"
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 Last Online    : $last"
 set emailyes 0;set urlyes 0;set greetyes 0
 if {![info exists email([string tolower $user])]} {set emailyes 1}
 if {![info exists url([string tolower $user])]} {set urlyes 1}
 if {![info exists email([string tolower $user])]} {set greetyes 1}
 if {!$emailyes} {
   if {$email([string tolower $user]) != ""} {  
     puthelp "NOTICE $nick :\002\[FL\]\002 E-Mail Address : $email([string tolower $user])"
   }
 }
 if {!$urlyes} {
   if {$url([string tolower $user]) != ""} {  
     puthelp "NOTICE $nick :\002\[FL\]\002 Web Address    : $url([string tolower $user])"
   }
 }
 if {!$greetyes} {
   if {$greet([string tolower $user]) != ""} {  
     puthelp "NOTICE $nick :\002\[FL\]\002 Greet          : $greet([string tolower $user])"
   }
 }
 if {[getuser $user INFO] != ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Info           : [getuser $user INFO]"
 }
}

proc dcc_ui {hand idx arg} {
 global greet url email thebot CC timezone botnick thepath
 dccsimul $idx ".userinfo $arg"
}

proc dcc_userinfo {hand idx arg} {
 global greet url email thebot CC timezone botnick thepath
 set greetfile "${thebot}.greet"
 set emailfile "${thebot}.email"
 set urlfile "${thebot}.url"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set emailpath "$thepath/$emailfile"} else {set emailpath "$thepath$emailfile"}   
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set urlpath "$thepath/$urlfile"} else {set urlpath "$thepath$urlfile"}
 set user [lindex $arg 0]
 if {$user == ""} {set user $hand}
 putdcc $idx "\002\[FL\]\002 Information about $user"
 putdcc $idx "\002\[FL\]\002 Current Time   : [ctime [unixtime]] $timezone"
 if {[validuser $user] == 0} {
   putdcc $idx "\002\[FL\]\002 No such user."
   return 0
 }
 foreach x [channels] {
   if {[onchan $user $x]} {
     set last "Is currently online in ${x}."
   } else {
     set last "[ctime [lindex [getuser $user LASTON] 0]]" 
   }
 }
 putdcc $idx "\002\[FL\]\002 Last Online    : $last"
 set emailyes 0;set urlyes 0;set greetyes 0
 if {![info exists url([string tolower $user])]} {set urlyes 1}
 if {![info exists email([string tolower $user])]} {set emailyes 1}
 if {![info exists greet([string tolower $user])]} {set greetyes 1}
 if {!$emailyes} {
   if {$email([string tolower $user]) != ""} {
     putdcc $idx "\002\[FL\]\002 E-Mail Address : $email([string tolower $user])"
   }
 }
 if {!$urlyes} {
   if {$url([string tolower $user]) != ""} {
     putdcc $idx "\002\[FL\]\002 Web Address    : $url([string tolower $user])"
   }
 }
 if {!$greetyes} {
   if {$greet([string tolower $user]) != ""} {
     putdcc $idx "\002\[FL\]\002 Greet          : $greet([string tolower $user])"
   }
 }
 if {[getuser $user INFO] != ""} {
   putdcc $idx "\002\[FL\]\002 Info           : [getuser $user INFO]"
 }
}

proc join_greet {nick uhost hand chan} {
 global greet botnick thebot thepath
 set greetfile "${thebot}.greet"
 if {[string index $thepath [expr [string length $thepath]-1]] != "/"} {set greetpath "$thepath/$greetfile"} else {set greetpath "$thepath$greetfile"}
 if {[string tolower $nick] != [string tolower $botnick]} {
   if {![info exists greet([string tolower $hand])]} {return 0}
   if {[info exists greet([string tolower $hand])]} {
     if {$greet([string tolower $hand]) != ""} {
       if {[string tolower $nick] != [string tolower $hand]} {
         putserv "PRIVMSG $chan :\002\[\002${nick} \(${hand}\)\002]\002 $greet([string tolower $hand])"
       } else {
         putserv "PRIVMSG $chan :\002\[\002${nick}\002]\002 $greet([string tolower $hand])"
       }
     }
   }
 }
}


## end of dcc/pub cmds for userinfo, greet, chgreet, chemail, email, churl, url

## public cmd seen -- start
proc pub_seen {nick uhost hand chan rest} {
global botnick version CC
set handle [lindex $rest 0]
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}seen <handle>"
   return 0
 }
 if {[validuser $handle] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user in my userlist."
  return 0
 }
 if {[string tolower $handle] == [string tolower $nick]} {
  puthelp "NOTICE $nick :\002\[FL\]\002 You are here."
  return 0
 }
 if {[onchan $handle $chan] == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $handle is currently on $chan."
  return 0
 }
 set lastseen [getuser $handle LASTON]
 if {$lastseen == ""} {puthelp "NOTICE $nick :\002\[FL\]\002 $handle was never here";return 0}
  set lastseen [lindex $lastseen 0]
	set totalyear [expr [unixtime] - $lastseen]
	if {$totalyear < 60} {
		return "$handle has left $chan less than a minute ago."
                return 0
	}
	if {$totalyear >= 31536000} {
		set yearsfull [expr $totalyear/31536000]
		set years [expr int($yearsfull)]
		set yearssub [expr 31536000*$years]
		set totalday [expr $totalyear - $yearssub]
	}
	if {$totalyear < 31536000} {
		set totalday $totalyear
		set years 0
	}
	if {$totalday >= 86400} {
		set daysfull [expr $totalday/86400]
		set days [expr int($daysfull)]
		set dayssub [expr 86400*$days]
		set totalhour [expr $totalday - $dayssub]
	}
	if {$totalday < 86400} {
		set totalhour $totalday
		set days 0
	}
	if {$totalhour >= 3600} {
		set hoursfull [expr $totalhour/3600]
		set hours [expr int($hoursfull)]
		set hourssub [expr 3600*$hours]
		set totalmin [expr $totalhour - $hourssub]
	}
	if {$totalhour < 3600} {
		set totalmin $totalhour
		set hours 0
	}
	if {$totalmin >= 60} {
		set minsfull [expr $totalmin/60]
		set mins [expr int($minsfull)]
	}
	if {$totalmin < 60} {
		set mins 0
	}
	if {$years < 1} {set yearstext ""} elseif {$years == 1} {set yearstext "$years year, "} {set yearstext "$years years, "}

	if {$days < 1} {set daystext ""} elseif {$days == 1} {set daystext "$days day, "} {set daystext "$days days, "}

	if {$hours < 1} {set hourstext ""} elseif {$hours == 1} {set hourstext "$hours hour, "} {set hourstext "$hours hours, "}

	if {$mins < 1} {set minstext ""} elseif {$mins == 1} {set minstext "$mins minute"} {set minstext "$mins minutes"}

	set output $yearstext$daystext$hourstext$minstext
	set output [string trimright $output ", "]
	puthelp "NOTICE $nick :\002\[FL\]\002 $nick, I last saw $handle $output ago"
}
## pub cmd seen -- stop

## msg cmd auth -- start
proc msg_auth {nick uhost hand rest} {
 global botnick
 set pw [lindex $rest 0]
 if {$pw == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: /msg $botnick auth <password>"
  return 0
 }
 if {[matchattr $hand Q] == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 You are already Authenticated."
  return 0
 }
 set ch [passwdok $hand ""]
 if {$ch == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No password set. Type /msg $botnick pass <password>" 
  return 0
 }
 if {[passwdok $hand $pw] == 1} {
  chattr $hand +Q
  putcmdlog "\002\[FL\]\002 #$hand# auth ..."
  puthelp "NOTICE $nick :\002\[FL\]\002 Authentication successful!"
 }
 if {[passwdok $hand $pw] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Authentication failed!"
 }
}
## msg cmd auth -- stop

## msg cmd deauth -- start
proc msg_deauth {nick uhost hand rest} {
 global botnick
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: /msg $botnick auth <password>"
  return 0
 }
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 You never authenticated."
  return 0
 }
 if {[passwdok $hand $rest] == 1} {
  chattr $hand -Q
  putcmdlog "\002\[FL\]\002 #$hand# deauth ..."
  puthelp "NOTICE $nick :\002\[FL\]\002 DeAuthentication successful!"
 }
 if {[passwdok $hand $rest] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 DeAuthentication failed!"
 }
}
## msg cmd deauth -- stop

## sign cmd deauth -- start
proc sign_deauth {nick uhost hand chan rest} { 
 if {[matchattr $hand Q] == 1} {
  chattr $hand -Q
  putlog "\002\[FL\]\002 $nick has signed off, automatic deauthentication."
 }
 if {[matchattr $hand Q] == 0} {
  return 0
 }
}
## sign cmd deauth -- stop

## part cmd deauth -- start
proc part_deauth {nick uhost hand chan} {
  if {[matchattr $hand Q] == 1} {
  chattr $hand -Q
  putlog "\002\[FL\]\002 $nick has parted $chan, automatic deauthentication."
 }
 if {[matchattr $hand Q] == 0} {
  return 0
 }
}
## part cmd deauth -- stop

## public cmd about -- start
proc pub_about {nick uhost hand chan rest} {
 global vers
 putcmdlog "\002\[FL\]\002 #$hand# about facelift.tcl"
 puthelp "NOTICE $nick :\002\[FL\]\002 \26facelift.tcl\26 $vers by Kindred <kindred@kindreds.net>"
 puthelp "NOTICE $nick :\002\[FL\]\002 Based on a script by quest."
 puthelp "NOTICE $nick :\002\[FL\]\002 Special thanks to zen and guppy for their work."
}
## public cmd about -- stop

## dcc cmd about -- start
proc dcc_about {hand idx args} {
 global vers
 putcmdlog "\002\[FL\]\002 #$hand# about facelift.tcl"
 putdcc $idx "\002\[FL\]\002 \26facelift.tcl\26 $vers by Kindred <kindred@kindreds.net>"
 putdcc $idx "\002\[FL\]\002 Based on a script by quest."
 putdcc $idx "\002\[FL\]\002 Special thanks to zen and guppy for their work."
}
## dcc cmd about - stop

## public cmd version -- start
proc pub_version {nick uhost hand chan rest} {
 putcmdlog "\002\[FL\]\002 #$hand# version"
 global vers
 puthelp "NOTICE $nick :\002\[FL\]\002 \26facelift.tcl\26 $vers"
}
## public cmd version -- stop

## dcc cmd version -- start
proc dcc_version {hand idx args} {
 global vers
 putcmdlog "\002\[FL\]\002 #$hand# version"
 putdcc $idx "\002\[FL\]\002 \26facelift.tcl\26 $vers"
}
## dcc cmd version -- stop

## public cmd help -- start
proc pub_help {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 help is only available via dcc chat."
} 
## public cmd help -- stop

## public cmd FLHelp -- start
proc pub_flhelp {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 FLHelp is only available via dcc chat."
}
## public cmd FLHelp -- stop

## dcc cmd FLHelp -- start
proc dcc_flhelp {hand idx args} {
 global botnick version vers
 set FL "\002\[FL\]\002"
 set args [lindex $args 0]
 global CC NC
 if {$args == ""} {
  putdcc $idx "$FL \26Facelift.tcl\26 ${vers}, Author Kindred <kindred@kindreds.net>"
  putdcc $idx "$FL PUBLIC COMMANDS for $botnick, eggdrop v[lindex $version 0]"
  putdcc $idx "$FL MY DCC CMD CHAR IS: \002'\002.\002'\002 MY PUBLIC CMD CHAR IS: \002'\002${CC}\002'\002"
  putdcc $idx "$FL"
  putdcc $idx "$FL \002\[\002\037For partyline users\037\002\]\002"
  putdcc $idx "$FL   ping         access        version      time"
  putdcc $idx "$FL   pong         rollcall      about        seen"
  if {[matchattr $hand o] == 1} {
   putdcc $idx "$FL \002\[\002\037For channel ops\037\002\]\002"
   putdcc $idx "$FL   who          +ban         say          away        quit"
   putdcc $idx "$FL   whom         -ban         msg          back        servers"
   putdcc $idx "$FL   whois        ban          act          note        channel"
   putdcc $idx "$FL   match        bans         me           files       kick"
   putdcc $idx "$FL   bots         addlog       newpass      su          k"    
   putdcc $idx "$FL   bottree      op           invite       console     kickban"
   putdcc $idx "$FL   notes        deop         nick         email       kb"
   putdcc $idx "$FL   echo         up           stick        unstick     info"
   putdcc $idx "$FL   trace        down         filestats    page        strip"
   putdcc $idx "$FL   topic        fixcodes     userlist     flagnote    comment"
   putdcc $idx "$FL   chat         botinfo      motd         modes       info"
   putdcc $idx "$FL   wi           ui"
  }
  if {[matchattr $hand m] == 1} {
   putdcc $idx "$FL \002\[\002\037For masters\037\002\]\002"
   putdcc $idx "$FL   adduser      +host        chattr       save        reload"
   putdcc $idx "$FL   deluser      -host        status       boot        chaninfo"
   putdcc $idx "$FL   +bot         botattr      chnick       chpass      chinfo"
   putdcc $idx "$FL   -bot         link         unlink       chaddr      chcomment"
   putdcc $idx "$FL   +user        set          jump         dump        +ignores"
   putdcc $idx "$FL   -user        flush        dccstat      debug       -ignores"
   putdcc $idx "$FL   join         aop          +chrec       reset       ignores"
   putdcc $idx "$FL   part         raop         -chrec       rehash      restart"   
   putdcc $idx "$FL   massop       mop          massunban    boot        banner"
   putdcc $idx "$FL   massdeop     mdeop        mub          assoc       relay"
   putdcc $idx "$FL   botattr"
  }
  if {[matchattr $hand n] == 1} {
   putdcc $idx "$FL \002\[\002\037For owners\037\002\]\002"
   putdcc $idx "$FL   chanset      chansave     chanload     simul"
   putdcc $idx "$FL   +chan        -chan        die          botnick"
   putdcc $idx "$FL   modules      loadmodule   unloadmodule"
  }
  putdcc $idx "$FL All of these commands are available in the channel and in dcc chat."
  return 0
 }
 if {[string tolower $args] == "kb"} {
   putcmdlog "$FL #$hand# FLHelp kb"
   putdcc $idx "$FL \#\#\# kb"
   putdcc $idx "$FL kickbans a user off of the channel."
   return 0
 }
 if {[string tolower $args] == "chcomment"} {
   putcmdlog "$FL #$hand# FLHelp chcomment"
   putdcc $idx "$FL \#\#\# chcomment"
   putdcc $idx "$FL Allows masters/owners to set users comment line."
   return 0
 }
 if {[string tolower $args] == "seen"} {
   putcmdlog "$FL #$hand# FLHelp seen"
   putdcc $idx "$FL \#\#\# seen"
   putdcc $idx "$FL Gives the last time a user was on the channel."
   return 0
 }
 if {[string tolower $args] == "time"} {
   putcmdlog "$FL #$hand# FLHelp time"
   putdcc $idx "$FL \#\#\# time"
   putdcc $idx "$FL Gives the user the current time according to the bots location."
   return 0
 }
 if {[string tolower $args] == "mdeop"} {
   putcmdlog "$FL #$hand# FLHelp mdeop"
   putdcc $idx "$FL \#\#\#  mdeop"
   putdcc $idx "$FL MassDeops all non-ops on the channel."
   return 0
 }
 if {[string tolower $args] == "mop"} {
   putcmdlog "$FL #$hand# FLHelp mop"
   putdcc $idx "$FL \#\#\#  mop"
   putdcc $idx "$FL MassOps all non-ops on the channel."
   return 0
 }
 if {[string tolower $args] == "massdeop"} {
   putcmdlog "$FL #$hand# FLHelp massdeop"
   putdcc $idx "$FL \#\#\#  massdeop"
   putdcc $idx "$FL MassDeops all non-ops on the channel."
   return 0
 }
 if {[string tolower $args] == "massop"} {
   putcmdlog "$FL #$hand# FLHelp massop"
   putdcc $idx "$FL \#\#\#  massop"
   putdcc $idx "$FL MassOps all non-ops on the channel."
   return 0
 }
 if {[string tolower $args] == "mub"} {
   putcmdlog "$FL #$hand# FLHelp mub"
   putdcc $idx "$FL \#\#\#  mub"
   putdcc $idx "$FL Removes all bans currently set on the channel."
   return 0
 }
 if {[string tolower $args] == "massuban"} {
   putcmdlog "$FL #$hand# FLHelp massuban"
   putdcc $idx "$FL \#\#\#  massunban"
   putdcc $idx "$FL Removes all bans currently set on the channel."
   return 0
 }
 if {[string tolower $args] == "about"} {
   putcmdlog "$FL #$hand# FLHelp about"
   putdcc $idx "$FL \#\#\#  about"
   putdcc $idx "$FL About facelift.tcl"
   return 0
 }
 if {[string tolower $args] == "version"} {
   putcmdlog "$FL #$hand# FLHelp version"
   putdcc $idx "$FL \#\#\#  version"
   putdcc $idx "$FL facelift.tcl verion"
   return 0
 }
 if {[string tolower $args] == "back"} {
   putcmdlog "$FL #$hand# FLHelp back"
   putdcc $idx "$FL \#\#\#  back"
   putdcc $idx "$FL Back states that your bot is back after being away"
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "down"} {
   putcmdlog "$FL #$hand# FLHelp down"
   putdcc $idx "$FL \#\#\#  down"
   putdcc $idx "$FL bot deops you on the channel."
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "up"} {
   putcmdlog "$FL #$hand# FLHelp up"
   putdcc $idx "$FL \#\#\#  up"
   putdcc $idx "$FL bot ops on the channel."
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "userlist"} {
   putcmdlog "$FL #$hand# FLHelp userlist"
   putdcc $idx "$FL \#\#\#  userlist"
   putdcc $idx "$FL \#\#\#  userlist <flags>"
   putdcc $idx "$FL Lists all users currently on the bot"
   return 0
 } 
 if {[string tolower $args] == "ping"} {
   putcmdlog "$FL #$hand# FLHelp ping"
   putdcc $idx "$FL \#\#\#  ping"
   putdcc $idx "$FL Shows bot response time."
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "pong"} {
   putdcc $idx "$FL \#\#\#  pong"
   putcmdlog "$FL #$hand# FLHelp pong"
   putdcc $idx "$FL Shows bot response time"
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "access"} {
   putcmdlog "$FL #$hand# FLHelp access"
   putdcc $idx "$FL \#\#\#  acess"
   putdcc $idx "$FL \#\#\#  access <nick>"
   putdcc $idx "$FL shows user flags currently enabled."
   return 0
 }
 if {[string tolower $args] == "rollcall"} {
   putcmdlog "$FL #$hand# FLHelp rollcall"
   putdcc $idx "$FL \#\#\#  rollcall"
   putdcc $idx "$FL shows bots command char \& shows current bot version."
   putdcc $idx "$FL (only available via PUBLIC CMD)"
   return 0
 }
 if {[string tolower $args] == "aop"} {
   putcmdlog "$FL #$hand# FLHelp aop"
   putdcc $idx "$FL \#\#\#  aop <nick>"
   putdcc $idx "$FL aop Auto-op's a user when they enter a channel."
   return 0
 }
 if {[string tolower $args] == "raop"} {
   putcmdlog "$FL #$hand# FLHelp raop"
   putdcc $idx "$FL \#\#\#  raop <nick>"
   putdcc $idx "$FL Removes user's auto-op privilege."
   return 0
 }
 if {[string tolower $args] == "botnick"} {
   putcmdlog "$FL #$hand# FLHelp botnick"
   putdcc $idx "$FL \#\#\#  botnick <new botnick>"
   putdcc $idx "$FL changes the bots irc nick - \002\037NOT\037\002 botnet nick."
   return 0
 }
 if {[string tolower $args] == "join"} {
   putcmdlog "$FL #$hand# FLHelp join"
   putdcc $idx "$FL \#\#\#  join <#channel>"
   putdcc $idx "$FL Forces the bot to join a channel"
   return 0
 }
 if {[string tolower $args] == "part"} {
   putcmdlog "$FL #$hand# FLHelp part"
   putdcc $idx "$FL \#\#\#  part <#channel>"
   putdcc $idx "$FL Forces a bot to leave a channel."
   return 0
 }
 if {[string tolower $args] == "modes"} {
   putcmdlog "$FL #$hand# FLHelp modes"
   putdcc $idx "$FL \#\#\#  modes"
   putdcc $idx "$FL Lets you auto set channel modes."
   putdcc $idx "$FL Current modes are t,n,i,p,s,m,l,k,v"
   putdcc $idx "$FL Example: ${CC}+v lamest, ${CC}+k private, +t"
   return 0
 }
 if {[string tolower $args] == "flagnote"} {
   putcmdlog "$FL #$hand# FLHelp flagnote"
   putdcc $idx "$FL \#\#\#  flagnote <flag>"
   putdcc $idx "$FL flagnote Sends a message to all users with a certain flag"
   return 0
 }
 if {$args != ""} {
  dccsimul $idx ".help $args"
 }
}
## dcc cmd FLHelp -- stop

## dcc cmd wi -- start
proc dcc_wi {hand idx arg} {
 global botnick
 if {$arg == ""} {
   putdcc $idx "\002\[FL\]\002 Usage: whois <handle>"
   return 0
 }
 dccsimul $idx ".whois $arg"
}
## dcc cmd wi -- stop


## public cmd massunban -- start
proc pub_massunban {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putserv "MODE $chan +b"
}
## public cmd massunban -- stop

## dcc cmd mub -- start
proc dcc_mub {hand idx args} {
set channel [lindex $args 0]
 if {[validchan $channel]} {
  putserv "MODE $channel +b"
 } else {
  putdcc $idx "\002\[FL\]\002 Usage: mub <#channel>"
 }
}
## dcc cmd mub -- stop

## dcc cmd massunban -- start
proc dcc_massunban {hand idx args} {
set channel [lindex $args 0]
 if {[validchan $channel]} {
  putserv "MODE $channel +b"
 } else {
  putdcc $idx "\002\[FL\]\002 Usage: massunban <#channel>"
 }
}
## dcc cmd massunban -- stop

## public cmd dccstat -- start
proc pub_dccstat {nick uhost hand chan rest} {
 set socksp "    ";set usersp "         ";set hostsp "                 "
   puthelp "NOTICE $nick :\002\[FL\]\002 SOCK NICK      HOST              TYPE"
   puthelp "NOTICE $nick :\002\[FL\]\002 ---- --------- ----------------- ----"
 foreach info [dcclist] { 
#   set info [lsort -integer [lindex $info 0]] [lrange $info 1 end]
   set sock [lindex $info 0]
   set user [lindex $info 1]
   set host [lindex $info 2]
   set type [lindex $info 3]
   if {[string length $sock] < 4} {
     set socksize [expr [string length $socksp]-[string length $sock]]
     set newsocksp [string range $socksp 0 [expr $socksize - 1]]
     set sock "${sock}${newsocksp}"
   }
   if {[string length $user] < 9} {
     set usersize [expr [string length $usersp]-[string length $user]]
     set newusersp [string range $usersp 0 [expr $usersize - 1]]
     set user "${user}${newusersp}"
   }
   if {[string length $user] > 9} {set user [string range $user 0 8}  
   if {[string length $host] < 17} {
     set hostsize [expr [string length $hostsp]-[string length $host]]
     set newhostsp [string range $hostsp 0 [expr $hostsize - 1]]
     set host "${host}${newhostsp}"
   }
   if {[string length $host] > 17} {
     set hostsize [expr [string length $host] -17]
     set host [string range $host $hostsize end]
   }
   if {$type == "TELNET"} {set type "lstn"}
   set type [string range [string tolower $type] 0 3]
   puthelp "NOTICE $nick :\002\[FL\]\002 $sock $user $host $type"
   putcmdlog "\002\[FL\]\002 #$hand# dccstat"
 }
}
## public cmd dccstat -- stop

## public cmd -chrec -- start
proc pub_-chrec {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 -chrec is only available via dcc chat."
}
## public cmd -chrec -- stop

## public cmd +chrec -- start
proc pub_+chrec {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 +chrec is only available via dcc chat."
}
## public cmd +chrec -- stop

## public cmd debug -- start
proc pub_debug {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 debug is only available via dcc chat."
}
## public cmd debug -- stop

## public cmd dump -- start
proc pub_dump {nick uhost hand chan rest} {
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putserv "$rest"
 puthelp "NOTICE $nick :Dumped Information to Server"
 putcmdlog "#$hand# dump $rest"
}
## public cmd dump -- stop

## public cmd unloadmodule -- start
proc pub_unloadmodule {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 unloadmodule is only available via dcc chat."
}
## public cmd unloadmodule -- stop

## public cmd loadmodule -- start
proc pub_loadmodule {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 loadmodule is only available via dcc chat."
}
## public cmd loadmodule -- stop

## public cmd modules -- start
proc pub_modules {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 modules is only available via dcc chat."
}
## public cmd modules -- stop

## public cmd simul -- start
proc pub_simul {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 simul is only available via dcc chat."
}
## public cmd simul -- stop

## public cmd botattr -- start
proc pub_botattr {nick uhost hand channel rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set chan [lindex $rest 2]
 set bot [lindex $rest 0]
 set bflags [lindex $rest 1]
 if {($bot == "") || ($bflags == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}botattr <bot> <flags> \[channel\]"
  return 0
 }
 if {[validuser $bot] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such bot!"
  return 0
 }
 if {[matchattr $bot b] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot is not a bot"
  return 0
 }
 if {$chan != ""} {
  if {[validchan $chan]} {
   putcmdlog "\002\[FL\]\002 #$hand# botattr $bot $bflags $chan"
   if {[string trim $bflags abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {
    botattr $bot $bflags $chan
   } else {
    botattr $bot |$bflags $chan
   }
   set chanflags [chattr $bot | $chan]
   set chanflags [string trimleft "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-"]
   set chanflags [string trim $chanflags "|"] 
   set globalflags [chattr $ownern]
   puthelp "NOTICE $nick :\002\[FL\]\002 botattr $bot \002\[\002${bflags}\002\]\002 $chan"
   puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $bot are \002\[\002${globalflags}\002\]\002"   
   if {$chanflags != "-"} {
    puthelp "NOTICE $nick :\002\[FL\]\002 Channel \002\"\002${chan}\002\"\002 Flags for $bot are \002\[\002${chanflags}\002\]\002"
   } else {
    puthelp "NOTICE $nick :\002\[FL\]\002 $bot does not have any channel specific flags."
   }
  } else {
   puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
  }
 } else {
  putcmdlog "\002\[FL\]\002 #$hand# botattr $bot $bflags"
  botattr $bot $bflags
  set bflags [getuser $bot BOTFL]
  puthelp "NOTICE $nick :\002\[FL\]\002 botattr $bot \002\[\002${bflags}\002\]\002"
  puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $bot are now \002\[\002${bflags}\002\]\002"
 }
}
## public cmd -chan -- stop
proc pub_-chan {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set channel [lindex $rest 0]
 if {$channel == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+chan <#channel>"
  return 0
 }
 if {[string first # $channel]!=0} {
  set channel "#$channel"
 }
 if {[validchan $channel]} {
  putcmdlog "\002\[FL\]\002 #$hand# -chan $channel"
  channel remove $channel
  puthelp "NOTICE $nick :\002\[FL\]\002 Channel $channel removed from the bot."
  puthelp "NOTICE $nick :\002\[FL\]\002 This includes any channel specific bans you set."
 } else {
  puthelp "NOTICE $nick :\002\[FL\]\002 That channel doesnt exist!"
 }
}
## public cmd -chan -- stop

## public cmd +chan -- start
proc pub_+chan {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set channel [lindex $rest 0]
 set options [lindex $rest 1]
 if {$channel == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+chan <#channel> \[option-list\]"
  return 0
 }
 if {[validchan $channel]} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Your already in $channel"
 } else {
  if {[string first # $channel]!=0} {
   set channel "#$channel"
  }
 putcmdlog "\002\[FL\]\002 #$hand# +chan $channel $options"
 channel add $channel $options
 }
}
## public cmd +chan -- stop

## public cmd binds -- start
proc pub_binds {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 binds is only available via dcc chat."
}
## public cmd binds -- stop

## public cmd reset -- start
proc pub_reset {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 reset is only available via dcc chat."
}
## public cmd reset -- stop

## public cmd banner -- start
proc pub_banner {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 banner is only available via dcc chat."
}
## public cmd banner -- stop

## public cmd resetbans -- start
proc pub_resetbans {nick uhost hand channel rest} {
 global CC botnick
 set chan $rest
 if {$chan != ""} {
  if {[validchan $chan]} {
   foreach ban [banlist $chan] {
    pushmode $chan +b [lindex $ban 0]
   }
   putserv "MODE $chan +b"
   putcmdlog "\002\[FL\]\002 #$hand# (${chan}) resetbans"
   puthelp "NOTICE $nick :\002\[FL\]\002 Resetting bans on $chan..."
   return 0
  } else {
   puthelp "NOTICE $nick :\002\[FL\]\002 $chan is an invalid channel."
   return 0
  }
 }
 if {$chan == ""} {
  foreach ban [banlist] {
   foreach i [channels] {
    pushmode $i +b [lindex $ban 0]
    puthelp "NOTICE $nick :\002\[FL\]\002 Resetting bans on $i"
   }
  }
  foreach x [channels] {
   putserv "MODE $x +b"
  }
  putcmdlog "\002\[FL\]\002 #$hand# resetbans"
 }
}
## public cmd resetbans -- stop

## public cmd flush -- start
proc pub_flush {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 flush is only available via dcc chat."
}
## public cmd flush -- stop

## public cmd set -- start
proc pub_set {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 set is only available via dcc chat."
}
## public cmd set -- stop

## public cmd chanload -- start
proc pub_chanload {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putcmdlog "\002\[FL\]\002 #$hand# chanload"
 loadchannels
 puthelp "NOTICE $nick :\002\[FL\]\002 Reloading all dynamic channel settings."
}
## public cmd chanload -- stop

## public cmd chansave -- start
proc pub_chansave {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putcmdlog "\002\[FL\]\002 #$hand# chansave"
 puthelp "NOTICE $nick :\002\[FL\]\002 Saving all dynamic channel settings."
 savechannels
 puthelp "NOTICE $nick :\002\[FL\]\002 Writing channel file ..."
}
## public cmd chansave -- stop

## public cmd chanset -- start
proc pub_chanset {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set channel [lindex $rest 0]
 set options [lindex $rest 1]
 if {($channel == "") || ($options == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chanset #<channel> <option...>"
  return 0
 }
 if {[validchan $channel]} {
  putcmdlog "\002\[FL\]\002 #$hand# chanset $channel $options"
  channel set $channel $options
  puthelp "NOTICE $nick :\002\[FL\]\002 Successfully set modes \{ $options \} on $channel"
  puthelp "NOTICE $nick :\002\[FL\]\002 Changes to $channel are not permanent."
 } else {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such channel."
 }
}
## public cmd chanset -- stop

## pubic cmd restart -- start
proc pub_restart {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
  utimer 1 restart
  putcmdlog "#${hand}# restart"
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user file... Writing channel file ... Restarting ..."
}
## public cmd restart -- stop

## pubic cmd rehash -- start
proc pub_rehash {nick uhost hand chan rest} {
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
  utimer 1 rehash
  putcmdlog "#${hand}# rehash"
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user & channel file... Rehashing.. Userfile loaded, unpacking..."
}
## public cmd rehash -- stop

## public cmd relay -- start
proc pub_relay {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 relay is only available via dcc chat."
}
## public cmd relay -- stop

## public cmd chaninfo -- start
proc pub_chaninfo {nick uhost hand chan rest} {
 global CC
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chaninfo <#channel>"
  return 0
 }
 if {[validchan $rest]} {
  set em [lindex [channel info $rest] 0]
  putcmdlog "\002\[FL\]\002 #$hand# chaninfo $rest"
  puthelp "NOTICE $nick :\002\[FL\]\002 Settings for static channel $rest"
  set em [lindex [channel info $rest] 0]
  puthelp "NOTICE $nick :\002\[FL\]\002 Protect modes (chanmode): $em"
 if {[lindex [channel info $rest] 1] == "0"} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Idle Kick after (idle-kick): DONT!"
 } else {
  puthelp "NOTICE $nick :\002\[FL\]\002 Idle Kick after (idle-kick): [lindex [channel info $rest] 1] min"
 } 
  puthelp "NOTICE $nick :\002\[FL\]\002 Other modes:" 
  puthelp "NOTICE $nick :\002\[FL\]\002      [lindex [channel info $rest] 12]  [lindex [channel info $rest] 13]  [lindex [channel info $rest] 14]  [lindex [channel info $rest] 15]"
  puthelp "NOTICE $nick :\002\[FL\]\002      [lindex [channel info $rest] 16]     [lindex [channel info $rest] 17]        [lindex [channel info $rest] 18]        [lindex [channel info $rest] 19]"
  puthelp "NOTICE $nick :\002\[FL\]\002      [lindex [channel info $rest] 20]  [lindex [channel info $rest] 21]  [lindex [channel info $rest] 22]      [lindex [channel info $rest] 23]"
  puthelp "NOTICE $nick :\002\[FL\]\002      [lindex [channel info $rest] 24]      [lindex [channel info $rest] 25]   [lindex [channel info $rest] 26]"
  set ichan [lindex [channel info $rest] 7]
  set ictcp [lindex [channel info $rest] 8]
  set ijoin [lindex [channel info $rest] 9]
  set ikick [lindex [channel info $rest] 10]
  set ideop [lindex [channel info $rest] 11]
  puthelp "NOTICE $nick :\002\[FL\]\002 flood settings: chan: $ichan  ctcp: $ictcp  join: $ijoin  kick: $ikick  deop: $ideop"    
 } else { 
  puthelp "NOTICE $nick :\002\[FL\]\002 No such channel defined."
 }
}
## public cmd chaninfo -- stop

## public cmd status -- start
proc pub_status {nick uhost hand chan rest} {
 global botnick CC server max-file-users max-filesize admin chanmode version uptime timezone files-path incoming-path
 putcmdlog "\002\[FL\]\002 #$hand# status"
 set vers [lindex $version 0]
 set users [countusers]
 regsub -all " " [channels] ", " chans
 puthelp "NOTICE $nick :\002\[FL\]\002 I am $botnick, running eggdrop v${vers}: $users users"
 puthelp "NOTICE $nick :\002\[FL\]\002 Running on [exec uname -sr]"
 puthelp "NOTICE $nick :\002\[FL\]\002 Server $server"
	set totalyear [expr [unixtime] - $uptime]
	if {$totalyear >= 31536000} {
		set yearsfull [expr $totalyear/31536000]
		set years [expr int($yearsfull)]
		set yearssub [expr 31536000*$years]
		set totalday [expr $totalyear - $yearssub]
	}
	if {$totalyear < 31536000} {
		set totalday $totalyear
		set years 0
	}
	if {$totalday >= 86400} {
		set daysfull [expr $totalday/86400]
		set days [expr int($daysfull)]
		set dayssub [expr 86400*$days]
		set totalhour [expr $totalday - $dayssub]
	}
	if {$totalday < 86400} {
		set totalhour $totalday
		set days 0
	}
	if {$totalhour >= 3600} {
		set hoursfull [expr $totalhour/3600]
		set hours [expr int($hoursfull)]
		set hourssub [expr 3600*$hours]
		set totalmin [expr $totalhour - $hourssub]
	}
	if {$totalhour < 3600} {
		set totalmin $totalhour
		set hours 0
	}
	if {$totalmin >= 60} {
		set minsfull [expr $totalmin/60]
		set mins [expr int($minsfull)]
	}
	if {$totalmin < 60} {
		set mins 0
	}
	if {$years < 1} {set yearstext ""} elseif {$years == 1} {set yearstext "$years year, "} {set yearstext "$years years, "}

	if {$days < 1} {set daystext ""} elseif {$days == 1} {set daystext "$days day, "} {set daystext "$days days, "}

	if {$hours < 1} {set hourstext ""} elseif {$hours == 1} {set hourstext "$hours hour, "} {set hourstext "$hours hours, "}

	if {$mins < 1} {set minstext ""} elseif {$mins == 1} {set minstext "$mins minute"} {set minstext "$mins minutes"}

        if {[string length $mins] == 1} {set mins "0${mins}"}
        if {[string length $hours] == 1} {set hours "0${hours}"}
	set output "${yearstext}${daystext}${hours}:${mins}"
	set output [string trimright $output ", "]
 set cpu [lindex [exec ps ux [exec cat pid.${botnick}]] 13]
 puthelp "NOTICE $nick :\002\[FL\]\002 Online for $output  (background)  CPU $cpu"  
 puthelp "NOTICE $nick :\002\[FL\]\002 Admin: $admin"
 puthelp "NOTICE $nick :\002\[FL\]\002     DCC file path: ${files-path}"
 puthelp "NOTICE $nick :\002\[FL\]\002         incoming: ${incoming-path}"
 puthelp "NOTICE $nick :\002\[FL\]\002        max users is ${max-file-users}"
 puthelp "NOTICE $nick :\002\[FL\]\002     DCC max file size: ${max-filesize}k"
 puthelp "NOTICE $nick :\002\[FL\]\002 Channels: $chans"
 puthelp "NOTICE $nick :\002\[FL\]\002 Server $server" 
 foreach x [channels] {
  set ch [llength [chanlist $x]]
  set em [lindex [channel info $x] 0]
  puthelp "NOTICE $nick :\002\[FL\]\002 $x :  $ch members, enforcing \"${em}\""
 }
}
## public cmd status -- stop

## public cmd boot -- start
proc pub_boot {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Access denied, people should know who is booting them."
}
## public cmd boot -- stop

## public cmd assoc -- start
proc pub_assoc {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 assoc is only available via dcc chat."
}
## public cmd assoc -- stop

## public cmd chbotattr -- start
proc pub_chbotattr {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 See botattr command."
}
## public cmd chbotattr -- stop

## public cmd unlink -- start
proc pub_unlink {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}unlink <bot>"
  return 0
 }
 if {([validuser $rest] == 0) || ([matchattr $rest b] == 0)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not in my userlist as a bot."
  return 0
 }
 if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] == -1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not linked on the botnet."
  return 0
 }
 if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] > -1} {
  putcmdlog "\002\[FL\]\002 #$hand# unlink $rest"
  unlink $rest
  puthelp "NOTICE $nick :\002\[FL\]\002 Breaking link with $rest"
 }
}
## public cmd unlink -- stop

## public cmd link -- start
proc pub_link {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}link <bot>"
  return 0
 }
 if {([validuser $rest] == 0) || ([matchattr $rest b] == 0)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not in my userlist as a bot."
  return 0
 }
 if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] > -1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already linked on the botnet."
  return 0
 }
 if {[lsearch -exact [string tolower [bots]] [string tolower $rest]] == -1} {
  putcmdlog "\002\[FL\]\002 #$hand# link $rest"
  link $rest
  puthelp "NOTICE $nick :\002\[FL\]\002 Linking to $rest at [getaddr $rest]"
 }
}
## public cmd link -- end

## public cmd su -- start
proc pub_su {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 su is only available via dcc chat."
}
## public cmd strip -- start
proc pub_strip {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 strip is only available via dcc chat."
}
## public cmd strip -- stop

## public cmd page -- start
proc pub_page {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 page is only available via dcc chat."
}
## public cmd page -- stop

## public cmd filestats -- start
proc pub_filestats {nick uhost hand chan rest} {
 global CC
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}filestats <handle>"
  return 0
 }
 if {[validuser $rest] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not in my userlist."
  return 0
 }
 if {[validuser $rest] == 1} {
  set uploads [getuploads $rest]
  set nul [lindex [getuploads $rest] 0]
  set tul [lindex [getuploads $rest] 1]
  set ndl [lindex [getdnloads $rest] 0]
  set tdl [lindex [getdnloads $rest] 1] 
  putcmdlog "\002\[FL\]\002 #$hand# filestats $rest"
  if {$tul >9} {set main "   "} else {set main "    "}
  if {$tul >99} {set main "  "} else {set main "    "}
  if {$tdl >9} {set main "   "} else {set main "    "}
  if {$tdl >99} {set main "  "} else {set main "    "}
  if {$nul >9} {set s "     "} else {set s "      "}
  if {$nul >99} {set s "    "} else {set s "      "}
  if {$nul >999} {set s "   "} else {set s "      "}
  if {$nul >9999} {set s "  "} else {set s "      "}
  if {$ndl >9} {set s "     "} else {set s "      "}
  if {$ndl >99} {set s "    "} else {set s "      "}
  if {$ndl >999} {set s "   "} else {set s "      "}
  if {$ndl >9999} {set s "  "} else {set s "      "}
 puthelp "NOTICE $nick :\002\[FL\]\002 \037${rest}'s filestats\037"
 puthelp "NOTICE $nick :\002\[FL\]\002   uploads:${main}${nul} /${s}${tul}k"
 puthelp "NOTICE $nick :\002\[FL\]\002 downloads:${main}${ndl} /${s}${tdl}k"
 }
}
## public cmd filestats -- stop

## public cmd unstick -- start
proc pub_unstick {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 unstick is only available via dcc chat."
}
## public cmd unstick -- stop

## public cmd stick -- start
proc pub_stick {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 stick is only available via dcc chat."
}
## public cmd stick -- stop

## public cmd fixcodes -- start
proc pub_fixcodes {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 fixcodes is only available via dcc chat."
}
## public cmd fixcodes -- stop

## public cmd trace -- start
proc pub_trace {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 trace is only available via dcc chat."
}
## public cmd trace -- stop

## public cmd botinfo -- start
proc pub_botinfo {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 botinfo is only available via dcc chat."
}
## public cmd botinfo -- stop

## public cmd chaddr -- start
proc pub_chaddr {nick uhost hand chan rest} {
global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate. /msg $botnick auth <password>"
  return 0
 }
 set botname [lindex $rest 0]
 set changes [lindex $rest 1]
 if {($botname == "") || ($changes == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chaddr <bot> <address:port#\[relay-port#\]>"
  return 0
 }
 set porttest [string trim $changes "abcdefghijklmnopqrstuvwxyx."]
 set porttest [string trim $porttest ":"]
 if {$porttest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chaddr <bot> <address:port#\[relay-port#\]>"
  return 0
 }
 if {[validuser $botname] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 There is no such bot in the userlist." 
  return 0
 }
 if {[matchattr $botname b] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is not a bot."
  return 0
 }
 botattr $botname $changes
 set oldaddy [getuser $botname BOTADDR]
 set oldaddy [lindex $oldaddy 0]:[lindex $oldaddy 1]/[lindex $oldaddy 2]
 puthelp "NOTICE $nick :\002\[FL\]\002 Changed ${botname}'s Address from \002\[\002${oldaddy}\002\]\002 to \002\[\002$changes\002\]\002"
}
## public cmd chaddr -- stop

## public cmd rollcall -- start

proc pub_rollcall {nick uhost hand chan rest} {
 global CC botnick version
 set botvers [lindex $version 0]
 set cmdchar $CC
 putlog "\002\[FL\]\002 <<$nick>> !$hand! rollcall"
 puthelp "NOTICE $nick :\002\[FL\]\002 I am ${botnick}, running eggdrop v${botvers}"
 puthelp "NOTICE $nick :\002\[FL\]\002 My Command Charactor is \002\[\002${CC}\002\]\002"
}
## public cmd rollcall -- stop

## dcc cmd access -- start
proc dcc_access {hand idx rest} {
 global CC
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who == ""} {
  putdcc $idx "\002\[FL\]\002 Usage: .access <nick | me>"
  return 0
 }
 if {$who == "me"} {
  if {$chan != ""} { 
   if {[validchan $chan]} {
    set swho $hand
    set cflags [chattr $swho | $chan]
    set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set cfflags [string trim $nflags "|"]
    putlog "\002\[FL\]\002 !$hand! access $swho $chan"
    if {$cfflags == "-"} {
     putdcc $idx "\002\[FL\]\002 You do not have any channel specific flags on ${chan}."
     return 0
    } else {
     putdcc $idx "\002\[FL\]\002 Your access is \002\[\002${cfflags}\002\]\002 on ${chan}."
     return 0
    }
   } else {
    putdcc $idx "\002\[FL\]\002 $chan is not a valid channel."
    return 0
   }
  }
  if {$chan == ""} {
   set mwho $hand
   set mflags [chattr $mwho]
   putlog "\002\[FL\]\002 !$hand! access $mwho"
   putdcc $idx "\002\[FL\]\002 Your access is \002\[\002${mflags}\002\]\002"
   return 0
  }
 }
 if {[validuser $who] == 1} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    set cflags [chattr $who | $chan]
    set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set cfflags [string trim $nflags "|"]
    putlog "\002\[FL\]\002 !$hand! access $who $chan"
    if {$cfflags == "-"} {
     putdcc $idx "\002\[FL\]\002 You do not have any channel specific flags on ${chan}."
     return 0
    } else {
     putdcc $idx "\002\[FL\]\002 ${who}'s access is \002\[\002${cfflags}\002\]\002 on ${chan}."
     return 0
    }
   } else {
    putdcc $idx "\002\[FL\]\002 $chan is not a valid channel."
    return 0
   }
  }
  if {$chan == ""} {
   set flags [chattr $who]
   putlog "\002\[FL\]\002 !$hand! access $who"
   putdcc $idx "\002\[FL\]\002 ${who}'s access is \002\[\002${flags}\002\]\002"
   return 0
  }
 }
 if {[validuser $who] == 0} {
  putdcc $idx "\002\[FL\]\002 No such user!"
  return 0
 }
}
## dcc cmd access -- stop

## public cmd access -- start
proc pub_access {nick uhost hand chan rest} {
 global CC
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}access <nick | me>"
  return 0
 }
 if {$who == "me"} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    set swho $hand
    set cflags [chattr $swho | $chan]
    set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set cfflags [string trim $nflags "|"]
    putlog "\002\[FL\]\002 !$hand! access $swho $chan"
    if {$cfflags == "-"} {
     puthelp "NOTICE $nick :\002\[FL\]\002 You do not have any channel specific flags on ${chan}."
     return 0
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 Your access is \002\[\002${cfflags}\002\]\002 on ${chan}."
     return 0
    }
   } else {
    puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel."
    return 0
   }
  }
  if {$chan == ""} {
   set mwho $hand
   set mflags [chattr $mwho]
   putlog "\002\[FL\]\002 !$hand! access $mwho"
   puthelp "NOTICE $nick :\002\[FL\]\002 Your access is \002\[\002${mflags}\002\]\002"
   return 0
  }
 }
 if {[validuser $who] == 1} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    set cflags [chattr $who | $chan]
    set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set cfflags [string trim $nflags "|"]
    putlog "\002\[FL\]\002 !$hand! access $who $chan"
    if {$cfflags == "-"} {
     puthelp "NOTICE $nick :\002\[FL\]\002 ${who} does not have any channel specific flags on ${chan}."
     return 0
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 ${who}'s access is \002\[\002${cfflags}\002\]\002 on ${chan}."
     return 0
    }
   } else {
    puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel."
    return 0
   }
  }
  if {$chan == ""} {
   set flags [chattr $who]
   putlog "\002\[FL\]\002 !$hand! access $who"
   puthelp "NOTICE $nick :\002\[FL\]\002 ${who}'s access is \002\[\002${flags}\002\]\002"
   return 0
  }
 }
 if {[validuser $who] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user!"
  return 0
 }
}
## public cmd access -- stop

## public cmd botnick -- start
proc pub_botnick {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set bot [lindex $rest 0]
 if {$bot==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 ${CC}botnick <new botnick>."
  return 0
 }
 putcmdlog "\002\[FL\]\002 #$hand# botnick $bot"
 putserv "NICK $bot"
}
## public cmd botnick -- stop

## dcc cmd botnick -- start
proc dcc_botnick {hand idx rest} {
 set bot [lindex $rest 0]
 if {$bot==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 .botnick <new botnick>."
  return 0
 }
 putcmdlog "\002\[FL\]\002 #$hand# botnick $bot"
 putserv "NICK $bot"
}
## dcc cmd botnick -- stop

## public cmd jump -- start
proc pub_jump {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set server [lindex $rest 0]
 if {$server == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: jump <server> \[port\] \[password\]"
  return 0
 }
 set port [lindex $rest 1]
 if {$port == ""} {set port "6667"}
 set password [lindex $rest 2]
 putcmdlog "\002\[FL\]\002 #$hand# jump $server $port $password"
 jump $server $port $password 
}
## public cmd jump -- stop

## public cmd die -- start
proc pub_die {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set idx [hand2idx $nick]
 if {$rest == ""} {set rest "No given reason"}
 save

 putcmdlog "\002\[FL\]\002 #$hand# quit $rest"
 if {$rest == ""} {set rest "Requested"} 
 foreach x [userlist] {
  chattr $x -Q
 }
 putserv "QUIT :\002${rest}\002"
 utimer 2 {die}
}
## public cmd die -- stop

## public cmd ban -- start
proc pub_ban  {nick uhost hand channel rest} {
 global botnick CC ban-time
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}ban <nick> \[reason\]"
   return 0
  }
  if {$rest!=""} {
   set handle [lindex $rest 0]
   set reason [lrange $rest 1 end]
   append userhost $handle "!*" [getchanhost $handle $channel]
   set hostmask [maskhost $userhost]
   if {![onchan $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is not on the channel."
    return 0
   }
   if {[onchansplit $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is currently net-split."
    return 0
   }
   if {[string tolower $handle] == [string tolower $botnick]} {
    putserv "KICK $channel $nick :\002\[FL\]\002 You really shouldn't try that..."
    return 0
   }    
   if {$reason == ""} { 
    set reason "requested" 
   }
   set options [lindex $reason 0]
   if {[string index $options 0] == "-"} {
     set options [string range $options 1 end]
   }
   switch -exact  $options {
     perm {
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" 0
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
           }
     min {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [lindex $reason 1]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
          }
     hours {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [lindex $reason 1]*60]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
     }
     days {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [lindex $reason 1]*60]*24]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
     }
     weeks {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [expr [lindex $reason 1]*60]*24]*7]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
     }
   }
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" $ban-time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! ban $channel $hostmask $options $reason"
             return 0
  } 
 }
 if {[isop $botnick $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## public cmd ban -- stop

## public cmd reload -- start
proc pub_reload {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 reload
 putcmdlog "\002\[FL\]\002 #$hand# reload"
 puthelp "NOTICE $nick :\002\[FL\]\002 Reloading user file..."
}
## public cmd restart -- stop

## public cmd ignores -- start
proc pub_ignores {nick uhost hand chan rest} {
 global CC botnick
 set iglist ""
 foreach x [ignorelist] {
  set iglister [lindex $x 0]
  set iglist "$iglist $iglister"
 }
 if {[ignorelist]==""} {
  putserv "NOTICE $nick :No ignores."
  return 0
 }
 regsub -all " " $iglist ", " iglist
 set iglist [string range $iglist 1 end]
 puthelp "NOTICE $nick :\002\[FL\]\002 Currently ignoring:$iglist"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! ignores"
 return 0
}
## public cmd ignores -- stop

## public cmd -ignore -- start
proc pub_-ignore {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set hostmask [lindex $rest 0]
 if {$hostmask == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-ignore <hostmask>"
  return 0
 }
 if {[isignore $hostmask] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $hostmask is not on my ignore list."
  return 0
 }
 if {[isignore $hostmask] == 1} {
  putcmdlog "\002\[FL\]\002 #$hand# -ignore $hostmask"
  killignore $hostmask
  puthelp "NOTICE $nick :\002\[FL\]\002 No longer ignoring \002\[\002${hostmask}\002\]\002"
  save
 }
}
## public cmd -ignore -- stop

## public cmd +ignore -- start
proc pub_+ignore {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set hostmask [lindex $rest 0]
 set comment [lindex $rest 1]
 if {$hostmask == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+ignore <hostmask> \[comment\]"
  return 0
 }
 if {[isignore $hostmask] == 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $hostmask is alreay set on ignore."
  return 0
 }
 if {[isignore $hostmask] == 0} {
  putcmdlog "\002\[FL\]\002 #$hand# +ignore $hostmask"
  newignore $hostmask $nick $comment 0
  puthelp "NOTICE $nick :\002\[FL\]\002 Now ignoring \002\[\002${hostmask}\002\]\002"
  save
 }
}
## public cmd +ignore -- stop

## public cmd comment -- start
proc pub_comment {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set comment [lrange $rest 0 end]
 if {($comment == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}comment <new comment>"
  return 0
 }
  putcmdlog "\002\[FL\]\002 #$hand# comment $comment"
  setuser $hand comment $comment
  puthelp "NOTICE $nick :\002\[FL\]\002 Added comment \002\[\002${comment}\002\]\002"
}
## public cmd comment -- stop

## public cmd chnick -- start
proc pub_chnick {nick uhost hand chan rest} {
 global CC owner botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set old [lindex $rest 0]
 set new [lindex $rest 1]
 if {($old == "") || ($new == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chnick <old nick> <new nick>"
  return 0
 }
 if {[validuser $old]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {([matchattr $old n] == 1)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 cannot change the bot owner's nick"
  return 0
 }
 if {[validuser $old]==1} {
  putcmdlog "\002\[FL\]\002 #$hand# chnick $old $new"
  chnick $old $new
  puthelp "NOTICE $nick :\002\[FL\]\002 Changed partyline nick from \002\[\002${old}\002\]\002 to \002\[\002${new}\002\]\002"
 }
}
## public cmd chnick -- stop

## public cmd chinfo -- start
proc pub_chinfo {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set info [lrange $rest 1 end]
 if {($who == "") || ($info == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chinfo <nick> <info>"
  return 0
 }
 if {[validuser $who]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {[validuser $who]==1} {
  putcmdlog "\002\[FL\]\002 #$hand# chinfo $who $info"
  setuser $who info $info
  puthelp "NOTICE $nick :\002\[FL\]\002 Added info \002\[\002${info}\002\]\002 to $who."
 }
}
## public cmd chinfo -- stop

## public cmd chcomment -- start
proc pub_chcomment {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botn$
  return 0
 }
 set who [lindex $rest 0]
 set comment [lrange $rest 1 end]
 if {($who == "") || ($comment == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chcomment <nick> <new comment>"
  return 0
 }
 if {[validuser $who]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {[validuser $who]==1} {
  putcmdlog "\002\[FL\]\002 #$hand# chcomment $who $comment"
  setuser $who comment $comment
  puthelp "NOTICE $nick :\002\[FL\]\002 Added info \002\[\002${comment}\002\]\002 to $who."
 }
}
## public cmd chcomment -- stop

## public cmd chemail -- start
proc pub_chemail {nick uhost hand chan rest} {
 global CC botnick
# puthelp "NOTICE $nick :\002\[FL\]\002 This command is only available via dcc chat"
# return 0
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set email [lindex $rest 1]
 if {($who == "") || ($email == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chemail <nick> <email>"
  return 0
 }
 if {[validuser $who]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {[validuser $who]==1} {
  putcmdlog "\002\[FL\]\002 #$hand# chemail $who $email"
  setuser $who email $email
  puthelp "NOTICE $nick :\002\[FL\]\002 Added email address \002\[\002${email}\002\]\002 to $who."
 }
}
## public cmd chemail -- stop

## public cmd chpass -- start
proc pub_chpass {nick chan uhost hand rest} {
 global CC
 puthelp "NOTICE $nick :\002\[FL\]\002 Can only be changed via dcc chat."
}
## public cmd chpass -- stop

## public cmd me -- start
proc pub_me {nick uhost hand channel rest} {
 global CC
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage ${CC}me <msg>"
  return 0
 }
 putlog "\002\[FL\]\002 <<$nick>> !$hand! me $rest"
 putserv "PRIVMSG $channel :\001ACTION $rest\001"
}
## public cmd me -- stop

## public cmd save -- start
proc pub_save {nick uhost hand channel rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putcmdlog "\002\[FL\]\002 #$hand# save"
 save
 puthelp "NOTICE $nick :\002\[FL\]\002 Writing channel & user file ..."
}
## public cmd save -- stop

## public cmd chattr -- start
proc pub_chattr {nick uhost hand channel rest} {
 global ownern flagss lowerflag nflagl CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set ownern [lindex $rest 0]
 set flagss [lindex $rest 1]
 set chan [lindex $rest 2]
 if {$ownern==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chattr <nick> <flags>"
  return 0
 }
 if {[validuser $ownern]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user!"
  return 0
 }
 if {$flagss==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}chattr <nick> <flags>"
  return 0
 }
 if {([matchattr $ownern n] == 1) && ([matchattr $nick n] == 0)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 You do not have access to change ${ownern}'s flags."
 }
 if {[matchattr $nick n] == 1} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    putcmdlog "\002\[FL\]\002 #$hand# chattr $ownern $flagss $chan"
    if {[string trim $flagss abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {
     chattr $ownern $flagss $chan
    } else {
     chattr $ownern |$flagss $chan
    }
    set chanflags [chattr $ownern | $chan]
    set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set chanflags [string trim $chanflags "|"]
    set globalflags [chattr $ownern]
    puthelp "NOTICE $nick :\002\[FL\]\002 chattr $ownern \002\[\002${flagss}\002\]\002 $chan"
    puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $ownern are \002\[\002${globalflags}\002\]\002"
    if {$chanflags != "-"} {
     puthelp "NOTICE $nick :\002\[FL\]\002 Channel \002\"\002${chan}\002\"\002 Flags for $ownern are \002\[\002${chanflags}\002\]\002"
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $ownern does not have any channel specific flags on ${chan}."
    }
   } else {
    puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
   }
  } else {
   putcmdlog "\002\[FL\]\002 #$hand# chattr $ownern $flagss $chan"
   chattr $ownern $flagss
   set flags [chattr $ownern]
   puthelp "NOTICE $nick :\002\[FL\]\002 Chattr $ownern \002\[\002${flagss}\002\]\002"
   puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $ownern are now \002\[\002${flags}\002\]\002" 
  }
  if {[matchattr $ownern a] == 1} {
   pushmode $channel +o $ownern
  }
  if {([matchattr $ownern a] == 0) && ([matchattr $ownern o] == 0)} {
   pushmode $channel -o $ownern
  }
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user file ..."
 }
  ##stop them from adding/removing +n if their not a owner.
 if {[matchattr $nick n] == 0} {
  set lowerflag [string tolower $flagss]
  set nflagl [string trim $flagss abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-]
  if {$nflagl != ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 You do not have access to add or remove the flag \002'\002n\002'\002 from that user."
   return 0
  }
 }
  ##stops other users from giving others +m.
 if {([matchattr $nick n] == 0) && ([matchattr $nick  m] == 1) && ([matchattr $ownern m] == 1)} {
  set lowerflag [string tolower $flagss]
  set nflagl [string trim $flagss abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-]
  if {$nflagl != ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 You do not have access to add or remove the flag \002'\002m\002'\002 from $ownern."
   return 0
  }
 }
 if {([matchattr $nick n] == 0) && ([matchattr $ownern n] == 0)} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    putcmdlog "\002\[FL\]\002 #$hand# chattr $ownern $flagss"
    if {[string trim $flagss abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {
     chattr $ownern $flagss $chan
    } else {
     chattr $ownern |$flagss $chan
    }
    set chanflags [chattr $ownern | $chan]
    set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set chanflags [string trim $chanflags "|"]
    set globalflags [chattr $ownern]
    puthelp "NOTICE $nick :\002\[FL\]\002 Chattr $ownern \002\[\002${flagss}\002\]\002 $chan"
    puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $ownern are \002\[\002${globalflags}\002\]\002"
    if {$chanflags != "-"} {
     puthelp "NOTICE $nick :\002\[FL\]\002 Channel \002\"\002${chan}\002\"\002 Flags for $ownern are \002\[\002${chanflags}\002\]\002"
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $ownern does not have any channel specific flags on ${chan}."
    }
   } else {
    puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
    return 0
   }
  } else {
   putcmdlog "\002\[FL\]\002 #$hand# chattr $ownern $flagss"
   chattr $ownern $flagss
   set flags [chattr $ownern]
   puthelp "NOTICE $nick :\002\[FL\]\002 Chattr $ownern \002\[\002${flagss}\002\]\002"
   puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $ownern are now \002\[\002${flags}\002\]\002"
  }
  if {[matchattr $ownern a] == 1} {
   pushmode $channel +o $ownern
  }
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user file ..."
 }
}
## public cmd chattr -- stop

## public cmd -host -- start
proc pub_-host {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set hostname [lindex $rest 1]
 set completed 0
 if {($who == "") || ($hostname == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-host <nick> <hostmask>"
  return 0
 }
 if {[validuser $who]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {([matchattr $nick n] == 0) && ([matchattr $who n] == 1)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Can't remove hostmasks from the bot owner."
  return 0
 }
 if {[matchattr $nick m] == 0} {
  if {[string tolower $hand] != [string tolower $who]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 You need '+m' to change other users hostmasks"
   return 0
  }
 }
 foreach * [getuser $who HOSTS] {
  if {${hostname} == ${*}} {
   putcmdlog "\002\[FL\]\002 #$hand# -host $who $hostname"
   delhost $who $hostname
   save 
   puthelp "NOTICE $nick :\002\[FL\]\002 Removed \002\[\002${hostname}\002\]\002 from $who."
    ### Make it do the -host thing here, and any message that goes along with it
   set completed 1
  }
 }
 if {$completed == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such hostmask!"
 }
}
## public cmd -host -- stop

## public cmd +host -- start
 set thehosts {
              *@* * *!*@* *!* *!@* !*@*  *!*@*.* *!@*.* !*@*.* *@*.*
              *!*@*.com *!*@*com *!*@*.net *!*@*net *!*@*.org *!*@*org
              *!*@*gov *!*@*.ca *!*@*ca *!*@*.uk *!*@*uk *!*@*.mil
              *!*@*.fr *!*@*fr *!*@*.au *!*@*au *!*@*.nl *!*@*nl *!*@*edu
              *!*@*se *!*@*.se *!*@*.nz *!*@*nz *!*@*.eg *!*@*eg *!*@*dk
              *!*@*.il *!*@*il *!*@*.no *!*@*no *!*@*br *!*@*.br *!*@*.gi
              *!*@*.gov *!*@*.dk *!*@*.edu *!*@*gi *!*@*mil *!*@*.to *!@*.to 
              *!*@*to *@*.to *@*to

 }

proc pub_+host {nick uhost hand chan rest} {
 global CC thehosts botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set hostname [lindex $rest 1]
 if {($who == "") || ($hostname == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+host <nick> <new hostmask>"
  return 0
 }
 if {[validuser $who] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user!"
  return 0
 }
 set badhost 0
 foreach * [getuser $who HOSTS] {
  if {${hostname} == ${*}} {
   puthelp "NOTICE $nick :\002\[FL\]\002 That hostmask is already there."
   return 0
  }
 }
 if {($who == "") && ($hostname == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+host <nick> <new hostmask>"
  return 0
 }
 if {([lsearch -exact $thehosts $hostname] > "-1") || ([string match *@* $hostname] == 0)} {
     if {[string index $hostname 0] != "*"} {
       set hostname "*!*@*${hostname}"
     } else {
       set hostname "*!*@${hostname}"
     }
 }
 if {([string match *@* $hostname] == 1) && ([string match *!* $hostname] == 0)} { 
   if {[string index $hostname 0] == "*"} {
     set hostname "*!${hostname}"
   } else {
     set hostname "*!*${hostname}"
   }
 }
 puthelp "NOTICE kindred :$hostname"
 if {[validuser $who]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No such user."
  return 0
 }
 if {([matchattr $nick n] == 0) && ([matchattr $who n] == 1)} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Can't add hostmasks to the bot owner."
  return 0
 }
 foreach * $thehosts {
  if {${hostname} == ${*}} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Invalid hostmask!"
   set badhost 1
  }
 }
 if {$badhost != 1} {
  if {[matchattr $nick m] == 0} {
   if {[string tolower $hand] != [string tolower $who]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 You need '+m' to change other users hostmasks"
    return 0
   }
  }
  putcmdlog "\002\[FL\]\002 #$hand# +host $who $hostname"
  setuser $who HOSTS $hostname
  puthelp "NOTICE $nick :\002\[FL\]\002 Added \002\[\002${hostname}\002\]\002 to $who."
  if {[matchattr $who a] == 1} {
   pushmode $chan +o $who
  }
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user file ..."
 }
}
## public cmd +host -- stop

## public cmd -bot -- start
proc pub_-bot {nick uhost hand chan rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set bot [lindex $rest 0]
 if {$bot==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-bot <handle>"
  return 0
 }
 if {[validuser $bot] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot is not on my userlist."
  return 0
 }
 if {[matchattr $bot b] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot is not a bot on the userlist."
  return 0
 }
 if {[matchattr $bot b] == 1} {
  putcmdlog "\002\[FL\]\002 #$hand# -bot $bot"
  deluser $bot
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot has been deleted from the userlist."
  save
 }
}
## public cmd -bot -- stop

## public cmd +bot -- start
proc pub_+bot {nick uhost hand channel rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set bot [lindex $rest 0]
 set address [lindex $rest 1] 
 set hostmask [lindex $rest 2]
 if {[validuser $bot]==1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot is already in my userlist."
  return 0
 }
 if {($bot=="") || ($address=="")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+bot <botname> <address:botport#\[userport#\]> \[hostmask\]"
  return 0
 }
 set porttest [string trim $address "abcdefghijklmnopqrstuvwxyx."]
 set porttest [string trim $porttest ":"]
 if {$porttest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+bot <botname> <address:botport#\[userport#\]> \[hostmask\]" 
  return 0
 }
 if {[validuser $bot]==0} {
  putcmdlog "\002\[FL\]\002 #$hand# +bot $bot $address $hostmask"
  addbot $bot $address
  if {$hostmask != ""} {
    setuser $bot HOSTS $hostmask
  }
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 $bot \002\[\002${address}\002\]\002 has been add to userlist as a bot."
  return 0
 }
}
## public cmd +bot -- stop

## public cmd deluser -- start
proc pub_deluser {nick uhost hand channel rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}deluser <handle>"
  return 0
 } else {
  pub_-user $nick $uhost $hand $channel $rest} {
 }
}
## public cmd deluser -- stop

## public cmd -user -- start
proc pub_-user {nick uhost hand channel rest} {
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 if {$who == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}-user <nick>"
 } else {
  if {[validuser $who] == 0} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $who is not on my userlist."
  } else {
   if {[matchattr $who n] == 1}  {
    puthelp "NOTICE $nick :\002\[FL\]\002 You cannot delete a bot owner."
   } else {
    if {([matchattr $who m] == 1) && ([matchattr $nick n] == 0)} {
     puthelp "NOTICE $nick :\002\[FL\]\002 You don't have access to delete $who."
    } else {
     putcmdlog "\002\[FL\]\002 #$hand# -user $who"
     deluser $who
     save
     puthelp "NOTICE $nick :\002\[FL\]\002 $who has been deleted."
    }
   }
  }
 }
}
## public cmd -user -- stop

## public cmd +user -- start
proc pub_+user {nick uhost hand channel rest} {
 global CC botnick thehosts
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set hostmask [lindex $rest 1]
 if {([lsearch -exact $thehosts $hostmask] > "-1") || ([string match *@* $hostmask] == 0)} {
     if {[string index $hostmask 0] != "*"} {
       set hostmask "*!*@*${hostmask}"
     } else {
       set hostmask "*!*@${hostmask}"
     }
 }
 if {([string match *@* $hostmask] == 1) && ([string match *!* $hostmask] == 0)} {
   if {[string index $hostmask 0] == "*"} {
     set hostmask "*!${hostmask}"
   } else {
     set hostmask "*!*${hostmask}"
   }
 }
 if {$hostmask == ""} {
   if {[onchan $who $channel] == 1} {
     regsub -all " " [split [maskhost [getchanhost mark- #wonkegg]] !] "!*" hostmask
   }
 }
 if {[validuser $who]==1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $who is already in my userlist."
  return 0
 }
 if {($who=="") || ($hostmask=="")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+user <nick> <hostmask>"
  return 0
 }
 set who [lindex $rest 0]
 set flags [lindex $rest 2]
 if {[validuser $who]==0} {
  putcmdlog "\002\[FL\]\002 #$hand# +user $who $hostmask"
  adduser $who $hostmask
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 $who has been added to userlist with hostmask \002\[\002$hostmask\002\]\002."
  if {$flags != ""} {
   chattr $who $flags $channel
   puthelp "NOTICE $nick :\002\[FL\]\002 Added $flags to $who"
  }
  return 0
 }
}
## public cmd +user -- stop

## public cmd adduser -- start
proc pub_adduser {nick uhost hand channel rest} {
 global CC botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[lindex $rest 0] == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}adduser <nick> \[optional flags\]"
  return 0
 }
 if {[validuser [lindex $rest 0]]} {
  puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already in my userlist."
  return 0
 }
 if {[onchan [lindex $rest 0] $channel]==1} {
  set who [lindex $rest 0]
  set oflags [lindex $rest 1]
  set host [maskhost [getchanhost [lindex $rest 0] $channel]]
  putcmdlog "\002\[FL\]\002 #$hand# adduser $who $oflags"
  adduser $who $host
  if {$oflags != ""} {
   if {[lindex $rest 2] != ""} {
    chattr $who |${oflags} [lindex $rest 2]
    set flags [chattr $who]
    set newhost [getuser $who HOSTS]
    puthelp "NOTICE $nick :\002\[FL\]\002 $who \002\[\002$newhost\002\]\002 has been added to the userlist."
    puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $who are \002\[\002${flags}\002\]\002"
    set chanflags [chattr [lindex $rest 0] | [lindex $rest 2]]
    set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set chanflags [string trim $chanflags |]
    puthelp "NOTICE $nick :\002\[FL\]\002 Channel \002\"\002[lindex $rest 2]\002\"\002 Flags for $who are \002\[\002${chanflags}\002\]\002"
    save
    return 0
   } else {
    chattr $who $oflags
    set flags [chattr $who]
    set newhost [getuser $who HOSTS]
    puthelp "NOTICE $nick :\002\[FL\]\002 $who \002\[\002$newhost\002\]\002 has been added to the userlist."
    puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $who are \002\[\002${flags}\002\]\002"
    save
    return 0
   }
  } else {
   set flags [chattr $who]
   puthelp "NOTICE $nick :\002\[FL\]\002 $who \002\[\002$host\002\]\002 has been added to the userlist."
   puthelp "NOTICE $nick :\002\[FL\]\002 Global Flags for $who are \002\[\002${flags}\002\]\002"
   save
   return 0
  }
 }
 if {[onchan [lindex $rest 0] $channel]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 That user is not on $channel."
 }
}
## public cmd adduser -- stop

## dcc cmd action -- start
proc cmd_action {idx text} {
 set text [string trim $text \001]
 set text [lrange $text 1 end]
 dccsimul $idx ".me $text"
 return 1
}
## dcc cmd action -- stop

## public cmd part -- start
proc pub_part {nick uhost hand chan rest} { 
 set rest [lindex $rest 0]
 global nopart botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[string first # $rest]!=0} {
  set rest "#$rest"
 }
 if {$rest==""} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Usage: part <#channel>"
  return 0
 } else {
  foreach x [channels] {
   if {[string tolower $x]==[string tolower $rest]} {
    if {[string tolower $rest]==[string tolower $nopart]} {
     puthelp "NOTICE $nick :\002\[FL\]\002 Sorry I can not part $nopart \[PROTECTED\]"
     return 0
    }
    channel remove $rest
    puthelp "NOTICE $nick :\002\[FL\]\002 I have left $x"
    putcmdlog "\002\[FL\]\002 #$hand# part $x"
    return 0
   }
  }
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 I wasn't in $rest"
}
## public cmd part -- stop

## public cmd join -- start 
proc pub_join {nick uhost hand chan rest} {
 global CC botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set chan [lindex $rest 0]
 if {[string first # $chan]!=0} {
  set chan "#$chan"
 }
 if {$chan=="#"} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}join <#channel>"
 } else {
 foreach x [channels] {
  if {[string tolower $x]==[string tolower $chan]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Your already in $x"
   return 0
  }
 }
 if {[lindex $rest 1] == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 I have joined $chan"
 } else {
   puthelp "NOTICE $nick :\002\[FL\]\002 I have joined $chan (key: [lindex $rest1])"
 }
 channel add $chan
  if {$rest!=""} {
   putserv "JOIN $chan :[lindex $rest 1]"
   putcmdlog "\002\[FL\]\002 #$hand# join $chan (key: [lindex $rest1])"
  }
 }
}
## public cmd join -- stop

## dcc cmd join -- start
proc cmd_join {hand idx rest} {
 set chan [lindex $rest 0]
 if {[string first # $chan]!=0} {
  set chan "#$chan"
 }
 if {$chan=="#"} {
  putdcc $idx "\002\[FL\]\002 Usage: join <#channel> \[key\]"
 } else {
 foreach x [channels] { 
  if {[string tolower $x]==[string tolower $chan]} {
   putdcc $idx "\002\[FL\]\002 Your already in $x"
   return 0
  }
 }
 if {[lindex $rest 1] == ""} {
   putdcc $idx "\002\[FL\]\002 I have joined $chan"
 } else {
   putdcc $idx "\002\[FL\]\002 I have joined $chan (key: [lindex $rest 1])"
 }
 channel add $chan
  if {$rest!=""} {
   putserv "JOIN $chan :[lindex $rest 1]"
   putcmdlog "\002\[FL\]\002 #$hand# join $chan (key: [lindex $rest 1])"
  }
 }
}
## dcc cmd join -- stop

## dcc cmd part -- start
proc cmd_part {hand idx rest} {
 set rest [lindex $rest 0]
 global nopart
 if {[string first # $rest]!=0} {
  set rest "#$rest"
 }
 if {$rest==""} {
 putdcc $idx "\002\[FL\]\002 Usage: part <#channel>"
  return 0
 } else {
  foreach x [channels] {
   if {[string tolower $x]==[string tolower $rest]} {
    if {[string tolower $rest]==[string tolower $nopart]} {
     putdcc $idx "\002\[FL\]\002 Sorry I can not part $nopart \[PROTECTED\]"
     return 0 
    }
    channel remove $rest
    putdcc $idx "\002\[FL\]\002 I have left $x"
    putcmdlog "\002\[FL\]\002 #$hand# part $x"
    return 0
   }
  }
 }
 putdcc $idx "\002\[FL\]\002 I wasn't in $rest"
}
## dcc cmd part -- stop

## public cmd channels -- start
proc pub_channels {nick hand uhost chan rest} {
 regsub -all " " [channels] ", " chans
 puthelp "NOTICE $nick :\002\[FL\]\002 Channels: $chans"
}
## public cmd channels -- stop

## dcc cmd say -- start
proc cmd_say {hand idx rest} {
 if {$rest==""} {
  putdcc $idx "\002\[FL\]\002 Usage: say <msg>"
 }
 if {$rest!=""} {
  set chan2send [lindex [console $idx] 0]
  puthelp "PRIVMSG $chan2send :$rest"
  putcmdlog "\002\[FL\]\002 #$hand# say $rest"
 }
}
## dcc cmd say -- stop

## dcc cmd act -- start
proc cmd_act {hand idx rest} {
 if {$rest==""} {
  putdcc $idx "\002\[FL\]\002 Usage: act <msg>"
 }
 if {$rest!=""} {
  set chan2send [lindex [console $idx] 0]
  putserv "PRIVMSG $chan2send :\001ACTION $rest\001"
  putcmdlog "\002\[FL\]\002 #$hand# act $rest"
 }
}
## dcc cmd act -- stop

## dcc cmd addlog -- start
proc cmd_addlog {hand idx rest} {
 if {$rest==""} {
  putdcc $idx "\002\[FL\]\002 Usage: addlog <log>"
 } else {
  putcmdlog "\002\[FL\]\002 $hand: $rest"
 }
}
## dcc cmd addlog -- stop

## dcc cmd invite -- start
proc cmd_invite {hand idx rest} {
 set rest [lindex $rest 0]
 set activechan [lindex [console $idx] 0]
 if {$rest==""} {
  putdcc $idx "\002\[FL\]\002 Usage: invite <nick>"
  return 0
 } else {
  if {[onchan $rest $activechan]==1} {
  putdcc $idx "\002\[FL\]\002 $rest is on $activechan already!" 
  return 0
   } else {
   putserv "INVITE $rest :$activechan"
   putdcc $idx "\002\[FL\]\002 Invitation sent to $rest"
   putcmdlog "\002\[FL\]\002 #$hand# invite $rest"
  }
 }
}
## public cmd invite -- stop

## cmd aop join -- start
proc aop_join {nick hand uhost channel} {
 global botnick
 if {[botisop $channel]==1} {
  foreach x $channel {
   if {[string tolower $channel]==[string tolower $x]} {
    pushmode $channel +o $nick
   } 
  } 
 }
 if {[botisop $channel]!=1} {
  if {$botnick!=$nick} {
   puthelp "NOTICE $nick :\002\[FL\]\002 I would have auto oped you... but I am not oped"
  } 
 } 
}
## cmd aop join -- stop

## dcc cmd raop -- start
proc cmd_raop {hand idx rest} {
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who != ""} {
  if {[validuser $who] == 1} {
   if {$chan != ""} {
    if {[validchan $chan]} {
     if {[matchattr $who |a $chan] == 1} {
      chattr $who |-a $chan
      puthelp "NOTICE $nick :\002\[FL\]\002 $who is no longer auto oped on $chan"
      putlog "\002\[FL\]\002 <<$nick>> !$hand! raop $who $chan"
      return 0
     } else {
      puthelp "NOTICE $nick :\002\[FL\]\002 $who wasn't auto oped on $chan"
      return 0
     }
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
     return 0
    }
   } else {
    if {[matchattr $who a] == 1} {
     chattr $who -a
     puthelp "NOTICE $nick :\002\[FL\]\002 $who is no longer a global auto oped"
     putlog "\002\[FL\]\002 <<$nick>> !$hand! raop $who $chan"
     return 0
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $who wasn't auto oped"
     return 0
    }
   }
  }
  if {[validuser $who] == 0} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $who is not a valid user"
  }
 }
 if {$who == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: raop <nick>"
 }
}
## dcc cmd raop -- stop

## public cmd raop -- start
proc pub_raop {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who != ""} {
  if {[validuser $who] == 1} {
   if {$chan != ""} {
    if {[validchan $chan]} {
     if {[matchattr $who |a $chan] == 1} {
      chattr $who |-a $chan
      puthelp "NOTICE $nick :\002\[FL\]\002 $who is no longer auto oped on $chan" 
      putlog "\002\[FL\]\002 <<$nick>> !$hand! raop $who $chan"
      return 0
     } else {
      puthelp "NOTICE $nick :\002\[FL\]\002 $who wasn't auto oped on $chan"
      return 0
     }
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
     return 0
    }
   } else {
    if {[matchattr $who a] == 1} {
     chattr $who -a
     puthelp "NOTICE $nick :\002\[FL\]\002 $who is no longer a global auto oped"
     putlog "\002\[FL\]\002 <<$nick>> !$hand! raop $who $chan"
     return 0
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $who wasn't auto oped"
     return 0
    }
   }
  }
  if {[validuser $who] == 0} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $who is not a valid user"
  }
 }
 if {$who == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: raop <nick>"
 }
}
## public cmd raop -- start

## public cmd aop -- start
proc pub_aop {nick uhost hand channel rest} {
 global botnick CC
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who != ""} {
  if {[validuser $who] == 1} {
   if {$chan != ""} {
    if {[validchan $chan]} {
     if {[matchattr $who |a $chan] == 0} {
      chattr $who |a $chan
      puthelp "NOTICE $nick :\002\[FL\]\002 $who is now auto oped on $chan"
      putlog "\002\[FL\]\002 <<$nick>> !$hand! aop $who $chan"
      return 0
     } else {
      puthelp "NOTICE $nick :\002\[FL\]\002 $who is already auto oped on $chan"
      return 0
     }
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $chan is not a valid channel"
     return 0
    }
   } else {
    if {[matchattr $who a] == 0} {
     chattr $who +a
     puthelp "NOTICE $nick :\002\[FL\]\002 $who is now global auto oped."
     putlog "\002\[FL\]\002 <<$nick>> !$hand! aop $who"
     return 0
    } else {
     puthelp "NOTICE $nick :\002\[FL\]\002 $who is already auto oped"
     return 0
    }  
   }
  }
  if {[validuser $who] == 0} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $who is not a valid user"
  }
 }
 if {$who == ""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}aop <nick>"
 }
}
## public cmd aop -- stop

## dcc cmd aop -- start
proc cmd_aop {hand idx rest} {
 set who [lindex $rest 0]
 set chan [lindex $rest 1]
 if {$who != ""} {
  if {[validuser $who] == 1} {
   if {$chan != ""} {
    if {[validchan $chan]} {
     if {[matchattr $who |a $chan] == 0} {
      chattr $who |a $chan
      putdcc $idx "\002\[FL\]\002 $who is now auto oped on $chan"
      putlog "\002\[FL\]\002 <<$nick>> !$hand! aop $who $chan"
      return 0
     } else {
      putdcc $idx "\002\[FL\]\002 $who is already auto oped on $chan"
      return 0
     }
    } else {
     putdcc $idx "\002\[FL\]\002 $chan is not a valid channel"
     return 0
    }
   } else {
    if {[matchattr $who a] == 0} {
     chattr $who +a
     putdcc $idx "\002\[FL\]\002 $who is now global auto oped."
     putlog "\002\[FL\]\002 <<$nick>> !$hand! aop $who"
     return 0
    } else {
     putdcc $idx "\002\[FL\]\002 $who is already auto oped"
     return 0
    }
   }
  }
  if {[validuser $who] == 0} {
   putdcc $idx "\002\[FL\]\002 $who is not a valid user"
  }
 }
 if {$who == ""} {
  putdcc $idx "\002\[FL\]\002 Usage: aop <nick>"
 }
}
## dcc cmd aop -- stop

## public cmd channel -- start
proc pub_channel {nick uhost hand channel rest} {
 global botnick
 set rest [lindex $rest 0]
 set chanlisting ""
 foreach x [chanlist $channel] {
  set dathand [nick2hand $x $channel]
  if {$dathand=="*"} {set dathand "?"}
  set chanlisting "$chanlisting $x\[$dathand\]"
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 Channel:$chanlisting" 
 putlog "\002\[FL\]\002 <<$nick>> !$hand! channel"
}
## public cmd channel -- stop

## public cmd who -- start
proc pub_who {nick uhost hand channel rest} {
 global botnick
 set peoplelist ""
 set botlist ""
 set e " "
 foreach x [dcclist] {
  set people [lindex $x 1]
  set type [lindex $x 3]
  set bot [lindex $x 1]
  if {$type == "CHAT"} {
   string trim $people " "
   set peoplelist "$peoplelist $people"
   set peoplenum $e\[[llength $peoplelist]\]
  }
  if {$type == "BOT"} {
   string trim $bot " "
   set botlist "$botlist $bot"
   set botnum $e\[[llength $bot]\]
  }
 }
 if {[string trim ${peoplelist} " "]==""} {
  set peoplelist " No one is on $botnick"
  set peoplenum ""
 }
 if {[string trim ${botlist} ""]==""} {
  set botlist " No bots are linked to $botnick"
  set botnum ""
 }
 regsub -all " " $peoplelist ", " peoplelist
 regsub -all " " $botlist ", " botlist

 set peoplelist [string range $peoplelist 1 end]
 set botlist [string range $botlist 1 end]
 puthelp "NOTICE $nick :\002\[FL\]\002 People$peoplenum:$peoplelist"
 puthelp "NOTICE $nick :\002\[FL\]\002 Bots$botnum:$botlist" 
 putlog "\002\[FL\]\002 <<$nick>> !$hand! who" 
 return 0
}
## public cmd who -- stop

proc pub_wi {nick uhost hand channel rest} {
 global botnick max-notes
 pub_whois $nick $uhost $hand $channel $rest
}

proc pub_whois {nick uhost hand channel rest} { 
 global botnick max-notes
 set fl "\002\[FL\]\002"
 if {[validuser $rest] == 0} {
   putserv "NOTICE $nick :\002\[FL\]\002 No such user!"
   return 0
 }
 set user [lindex $rest 0]
 set ch [passwdok "$rest" ""]
 if {!$ch} {set pass "yes"} else {set pass "no "}
 set notes [notes $user]
 set flags [chattr $user]
 while {[string length $flags] < 15} {
   append flags " "
 }
 while {[string length $user] < 9} {
   append user " "
 }   
 if {[string length $notes] == "1"} {set notes "  ${notes}"}
 if {[string length $notes] == "2"} {set notes " ${notes}"}
 #set flags [chattr $user]
 #set userlen [string length $user]
 #set bl1 "         "
 #if {$userlen < 9} {
 #  set dt1 [expr 8-$userlen]
 #  set add [string range $bl1 0 $dt1]
 #  append user $add
 #}
 #if {$userlen > 9} {set user [string range $userlen 0 8]} 
 #set flagslen [string length $flags]
 #set bl2 "               "
 #if {$flagslen < 15} {
 #  set dt2 [expr 14-$flagslen]
 #  set add [string range $bl2 0 $dt2]
 #  append flags $add
 #}
 set lastseen [ctime [lindex [getuser [string trim $user] LASTON] 0]]
 set day "[lindex $lastseen 0]."
 set month "[lindex $lastseen 1], [lindex $lastseen 2]"
 set time [lindex $lastseen 3]
 set year "[string range [lindex $lastseen 4] 2 3]"
 set last "$time on $month"
   

 #if {$flagslen > 15} {set flags [string range $flagslen 0 14]}
 puthelp "NOTICE $nick :$fl HANDLE    PASS NOTES FLAGS           LAST"
 puthelp "NOTICE $nick :$fl $user $pass    $notes $flags $last"
 set user [string trim $user]
 if {![matchattr $user b]} {
 foreach i [channels] {
    set tchan [string length $i]

    set bl3 "                  "
   if {$tchan < 18} {
     set dt3 [expr 17-$tchan]
     set add2 [string range $bl3 0 $dt3]
     append chans $i$add2
   }
    set cflags [chattr $user | $i] 
    set nflags [string trimleft $cflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]

    set cfflags [string trim $nflags "|"]
    set cf [string length $cfflags]
 set flagslen2 [string length $cf]
 set bl26 "               "
 if {$flagslen2 < 14} {
   set dt26 [expr 13-$flagslen2]
   set add4 [string range $bl26 0 $dt26]
   append flags12 $add4
 }
 if {$flagslen2 > 14} {set flags12 [string range $flagslen2 0 13]}
 set lastseen2 [ctime [lindex [getuser $user LASTON $i] 0]]
 set day2 "[lindex $lastseen2 0]."
 set month2 "[lindex $lastseen2 1], [lindex $lastseen2 2]"
 set time2 [lindex $lastseen2 3]
 set year2 "`[string range [lindex $lastseen2 4] 2 3]"
 set last2 "$time on $month2"
   puthelp "NOTICE $nick :$fl   $chans $cfflags $flags12 $last2"   
 }
 }
   if {[getuser $user HOSTS] != ""} {
     set hosts [getuser $user hosts]
     puthelp "NOTICE $nick :$fl   HOSTS: $hosts" 
   }
     if {[getuser $user BOTFL] != ""} {
       puthelp "NOTICE $nick :$fl   BOT FLAGS: [getuser $user BOTFL]"
     }
     if {[getuser $user BOTADDR] != ""} {
       set botinfo [getuser $user BOTADDR]
       puthelp "NOTICE $nick :$fl   ADDRESS: [lindex $botinfo 0]"
       puthelp "NOTICE $nick :$fl      telnet: [lindex $botinfo 1], relay: [lindex $botinfo 2]"
     }
}
## public cmd whois -- stop

## public cmd whom -- start
proc pub_whom {nick uhost hand channel rest} {
 set peoplelist ""
 foreach x [whom 0] {
  set people [lindex $x 0]
  string trim $people " "
  set peoplelist "$peoplelist ${people}@[lindex [string trim $x ""] 1]"
 }
 regsub -all " " $peoplelist ", " peoplelist 
 set peoplelist [string range $peoplelist 1 end]
 if {[string trim ${peoplelist} " "]==""} {
  set peoplelist " No one is on the partyline"
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 People:$peoplelist"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! whom"
 return 0
}
## public cmd whom -- stop

## public cmd match -- start
proc pub_match {nick uhost hand chan rest} {
 global CC
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}match <flags>"
  return 0
 }
 set rest [string trim $rest +]
 if {[string length $rest] > 1} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Invalid option."
   return 0
 }
 if {$rest!=""} {
  set rest "+[lindex $rest 0]"
  if {[userlist $rest]!=""} {
   regsub -all " " [userlist $rest] ", " users 
   puthelp "NOTICE $nick :\002\[FL\]\002 Match \[$rest\]: $users" 
   putlog "\002\[FL\]\002 <<$nick>> !$hand! match $rest"
   return 0
  }
  if {[userlist $rest]==""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 No users with flags \[$rest\]"
   return 0
  }
 }
}
## public cmd match -- stop

## dcc cmd match -- start
proc dcc_match {hand idx args} {
 set flags [lindex $args 0]
 set flags [string trim $flags +]
 if {$flags==""} {
   putdcc $idx "\002\[FL\]\002 Usage: match <flags>"
   return 0
 }
 if {[string length $flags] > 1} {
   putdcc $idx "\002\[FL\]\002 Invalid Option."
   return 0
 }
 if {$flags!=""} {
  if {[userlist $flags]!=""} {
   regsub -all " " [userlist $flags] ", " users
   putdcc $idx "\002\[FL\]\002 Match \[$flags\]: $users"
   putlog "\002\[FL\]\002 #$hand# match $flags"
   return 0
  }
  if {[userlist $flags]==""} {
   putdcc $idx "\002\[FL\]\002 No users with flags \[$flags\]"
   return 0
  }
 }
}
## dcc cmd match -- stop

## public cmd bots -- start
proc pub_bots {nick uhost hand chan rest} {
 if {[bots]==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No bots connected"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! bots"
  return 0
 }
 if {[bots]!=""} {
  regsub -all " " [bots] ", " bots
  puthelp "NOTICE $nick :\002\[FL\]\002 Bots: $bots"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! bots"
  return 0
 }
}
## public cmd bots -- stop

## public cmd bottree -- start 
proc pub_bottree {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Bottree is only available via dcc chat, try Bots" 
}
## public cmd bottree - stop

## public cmd notes -- start
proc pub_notes {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 notes is only available via dcc chat"
}
## public cmd notes -- stop

proc val {string} {
  set arg [string trim $string /ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]
  set arg2 [string trim $arg #!%()@-_+=\[\]|,.?<>{}]
  return $arg2
}

## public cmd +ban -- start
proc pub_+ban  {nick uhost hand channel rest} {
 global botnick CC ban-time
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}+ban <hostmask> \[reason\]"
   return 0
  }
  if {$rest!=""} {
   set host [lindex $rest 0]
   set reason [lrange $rest 1 end]
   if {[string tolower $host] == [string tolower $botnick]} {
    putserv "KICK $channel $nick :\002\[FL\]\002 You really shouldn't try that..."
    return 0
   }    
   if {$reason == ""} {
    set reason "\002requested\002" 
   }
   set options [lindex $reason 0]
   if {[string index $options 0] == "-"} {
     set options [string range $options 1 end]
   }
   switch -exact  $options {
     perm {
             set reason [lrange $reason 1 end]
             newban $host $nick "$reason" 0
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0
           }
     min {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [lindex $reason 1]
             set reason [lrange $reason 2 end]
             newban $host $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0
          }
     hours {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [lindex $reason 1]*60]
             set reason [lrange $reason 2 end]
             newban $host $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0    
     }
     days {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [lindex $reason 1]*60]*24]
             set reason [lrange $reason 2 end]
             newban $host $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0
     }
     weeks {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [expr [lindex $reason 1]*60]*24]*7]
             set reason [lrange $reason 2 end]
             newban $host $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0
     }
   }
             set reason [lrange $reason 1 end]
             newban $host $nick "$reason" $ban-time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! +ban $reason"
             return 0
  } 
 }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## public cmd +ban -- stop

## public cmd -ban -- start
proc pub_-ban {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
  if {[botisop $channel]==1} {
   if {$rest==""} {
    puthelp "NOTICE $nick :\002\[FL\]\002 Usage: -ban <ban #>"
   }
  if {$rest!=""} {
   set mbantester [catch {expr $rest-1}]
   if {$mbantester==1} {
    puthelp "NOTICE $nick :\002\[FL\]\002 Usage: -ban <ban #>"
    return 0
   }
   if {[lindex [banlist $channel] [expr ${rest}-1]]==""} {
    puthelp "NOTICE $nick :\002\[FL\]\002 No such channel ban. It may be a global ban" 
    return 0 
   }  
   if {[lindex [banlist $channel] [expr ${rest}-1]]!=""} {
    set restban [lindex [lindex [banlist $channel] 0] [expr ${rest}-1]]
    killchanban $channel $rest
    puthelp "NOTICE $nick :\002\[FL\]\002 Ban $restban was removed"
    putlog "\002\[FL\]\002 <<$nick>> !$hand! -ban $rest"
    return 0
   }
  }
 }
 if {[isop $botnick $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## public cmd -ban -- stop

## public cmd bans -- start
proc pub_bans {nick uhost hand chan rest} {
 global CC ban-time
 set rest [lindex $rest 0]
 set rest [string toupper $rest]
 if {$rest!="CHANNEL"} {
  if {$rest!="GLOBAL"} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: bans <global | channel>"
  }
 }
 set banlistchan ""
 if {$rest=="CHANNEL"} {
  foreach x [banlist $chan] {
   set banlister [lindex $x 0]
   set banlistchan "$banlistchan $banlister"
  }
  if {[banlist $chan]==""} { 
   set banlistchan " No channel bans in $chan"
  }
  puthelp "NOTICE $nick :\002\[FL\]\002 Channel Bans:$banlistchan"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! bans channel"
  return 0
 }
 set banlist ""
 if {$rest=="GLOBAL"} {
  foreach x [banlist] {
   set banlisting [lindex $x 0]
   set banlist "$banlist $banlisting"
  }
  if {$banlist==""} {
   set banlist " No global bans"
  }
  puthelp "NOTICE $nick :\002\[FL\]\002 Global Bans:$banlist"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! bans global"
  return 0
 }
}
## public cmd bans -- stop

## dcc cmd op -- start
proc cmd_op {hand idx rest} {
 set rest [lindex $rest 0]
 set channel [lindex [console $idx] 0]
 global botnick  
 if {[botisop $channel]==1} { 
  if {$rest==""} {
   putdcc $idx "\002\[FL\]\002 Usage: op <nick>"
  }
  if {[onchan $rest $channel]=="1"} {  
   if {[isop $rest $channel]=="1"} {
    putdcc $idx "\002\[FL\]\002 $rest is already oped"
   }
  }
  if {$rest!=""} {
   if {[onchan $rest $channel]=="0"} {
    putdcc $idx "\002\[FL\]\002 $rest isn't on the channel"
   }
  }
  if {[onchan $rest $channel]=="1"} {
   if {[isop $rest $channel]=="0"} {
    pushmode $channel +o $rest
    putlog "\002\[FL\]\002 #$hand# op $rest"
   }
  }
 }
 if {[botisop $channel]!=1} {
  putdcc $idx "\002\[FL\]\002 I am not oped, sorry."
 }
}
## dcc cmd op -- stop

## public cmd op -- start
proc pub_op {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest==""} {
    if {![botisop $channel]} {
      putserv "NOTICE $nick :Sorry, Im not op'd."
      return 0
    }
    if {[isop $nick $channel]} {
      putserv "NOTICE $nick :You are already op'd."
      return 0
    }
    putcmdlog "#$hand# op $nick"
    pushmode $channel +o $nick
    return 0
  }
  if {[onchan $rest $channel]==1} {
   if {[isop $rest $channel]==1} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already oped."
   }
  }
  if {$rest!=""} {
   if {[onchan $rest $channel]==0} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $rest isn't on the channel."
   }
  }
  if {[onchan $rest $channel]==1} {
   if {[isop $rest $channel]==0} {
    pushmode $channel +o $rest 
    putlog "\002\[FL\]\002 <<$nick>> !$hand! op $rest"
   }
  }
 }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped, sorry."
 }
}
## public cmd op -- stop

## dcc cmd deop -- start
proc cmd_deop {hand idx rest} {
 global botnick
 set rest [lindex $rest 0]
 set channel [lindex [console $idx] 0]
 if {[botisop $channel]==1} { 
  if {$rest==""} {
   putdcc $idx "\002\[FL\]\002 Usage: deop <nick>"
  }
  if {$rest!=""} {
   if {[onchan $rest $channel]=="0"} {
    putdcc $idx "\002\[FL\]\002 $rest isn't on the channel"
   }
  }
  if {[onchan $rest $channel]=="1"} {
   if {[isop $rest $channel]=="0"} {
    putdcc $idx "\002\[FL\]\002 $rest is already deoped"
   }
  }
  if {[string tolower $botnick] == [string tolower $rest]} {
   putdcc $idx "\002\[FL\]\002 I don't deop myself..."
  }
  if {[isop $rest $channel]=="1"} {
   if {[onchan $rest $channel]=="1"} {
    if {$botnick!=$rest} {
     pushmode $channel -o $rest
     putlog "\002\[FL\]\002 #$hand# deop $rest"
    }
   }
  } 
 }
 if {[botisop $channel]!=1} {
  putdcc $idx "\002\[FL\]\002 I am not oped"
 }
}
## dcc cmd deop -- stop

## public cmd deop -- start
proc pub_deop {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set rest [lindex $rest 0]
 if {[botisop $channel]==1} {
  if {$rest==""} {
    if {![botisop $channel]} {
      putserv "NOTICE $nick :Sorry, Im not op'd."
      return 0
    }
    if {![isop $nick $channel]} {
      putserv "NOTICE $nick :You are already deop'd."
      return 0
    }
    putcmdlog "#$hand# deop $nick"
    pushmode $channel -o $nick
    return 0
  }
  if {$rest!=""} {
   if {[onchan $rest $channel] == 0} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $rest isn't on the channel."
    return 0
   }
  }
  if {[onchan $rest $channel]=="1"} {
   if {[isop $rest $channel]=="0"} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already deoped."
    return 0
   }
  }
  if {[string tolower $botnick] == [string tolower $rest]} {
   putserv "KICK $channel $nick :I don't deop myself..."
   return 0
  }
  if {[isop $rest $channel]=="1"} {
   if {[onchan $rest $channel]=="1"} {
    if {[string tolower $botnick] != [string tolower $rest]} {
     pushmode $channel -o $rest
     putlog "\002\[FL\]\002 <<$nick>> !$hand! deop $rest"
    }
   }
  }
 }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped, sorry."
 }
}
## public cmd deop -- stop

## public cmd topic -- start
proc pub_topic {nick uhost hand channel rest} {
 global botnick topicnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest!=""} {
  if {[botisop $channel]==1} {
   if {$topicnick == 0} {
     putserv "TOPIC $channel :$rest"
     putlog "\002\[FL\]\002 <<$nick>> !$hand! topic $rest" 
   } else {
     putserv "TOPIC $channel :$rest (${hand})" 
     putlog "\002\[FL\]\002 <<$nick>> !$hand! topic $rest" 
   } 
  }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped" }
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: topic <topic>"
 }
}
## public cmd topic -- stop

## public cmd act -- start
proc pub_act {nick uhost hand channel rest} {
 if {$rest!=""} {
  putserv "PRIVMSG $channel :\001ACTION $rest\001"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! act $rest"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: act <msg>"
 }
}
## public cmd act -- stop

## public cmd say -- start
proc pub_say {nick uhost hand channel rest} {
 if {$rest!=""} {
  puthelp "PRIVMSG $channel :$rest"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! say $rest"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: say <msg>"
 }
}
## public cmd say -- stop

## public cmd msg -- start
proc pub_msg {nick uhost hand channel rest} {
 set person [lindex $rest 0] 
 set rest [lrange $rest 1 end]
 if {$rest!=""} {
  puthelp "PRIVMSG $person :$rest"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! msg $rest"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: msg <nick> <msg>"
 }
}
## public cmd msg -- stop

## public cmd motd -- start
proc pub_motd {nick uhost hand channel rest} {
 global newpath botnick version vers admin network
 set mfile "${newpath}alt.motd"
 if {![file exists $mfile]} {
   set new [open $mfile w]
   putserv "NOTICE $nick :I am $botnick, running v[lindex $version 0] with facelift.tcl v${vers}"
   puts $new "I am $botnick, running v[lindex $version 0] with facelift.tcl v${vers}"
   putserv "NOTICE $nick :Admin: $admin"  
   puts $new "Admin: $admin"
   regsub -all " " [channels] ", " chans
   putserv "NOTICE $nick :Located: $chans on $network"
   puts $new "Located: $chans on $network"
   close $new 
 } else {
   set info [fileinfo $mfile]
   set info [lrange $info 0 2]
   foreach x $info {
     putserv "NOTICE $nick :$x"
   }
 }
}
## public cmd motd -- stop

## public cmd addlog -- start
proc pub_addlog {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: addlog <msg>"
 }
 if {$rest!=""} {
  putlog "\002\[FL\]\002 $hand: $rest"
 }
}
## public cmd addlog -- stop

## public cmd invite -- start
proc pub_invite {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set rest [lindex $rest 0]
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: invite <nick>"
 }
 if {$rest!=""} {
  if {[onchan $rest $chan]==0} {
   putserv "INVITE $rest :$chan"
   puthelp "NOTICE $nick :\002\[FL\]\002 Invitation to $chan has been sent to $rest" 
   putlog "\002\[FL\]\002 <<$nick>> !$hand! invite $rest"
   return 0
  }
  if {[onchan $rest $chan]==1} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $rest is already on the channel"
  }
 }
}
## public cmd invite -- stop

## public cmd nick -- start
proc pub_nick {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set rest [lindex $rest 0]
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: nick <new nick on bot>"
 }
 if {$rest!=""} {
  chnick $hand $rest
  puthelp "NOTICE $nick :\002\[FL\]\002 Your partyline handle is now [nick2hand $nick $chan]" 
  putlog "\002\[FL\]\002 <<$nick>> !$hand! nick $rest"
  return 0
 }
}
## public cmd nick -- stop

## public cmd away -- start
proc pub_away {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest!=""} {
  putserv "AWAY :$rest"
  putserv "PRIVMSG $channel :\001ACTION is now marked as away: $rest\001"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! away $rest"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: away <msg>"
 }
}
## public cmd away -- stop
## public cmd back -- start
proc pub_back {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 putserv "AWAY :"
 putserv "PRIVMSG $channel :\001ACTION is back...\001"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! back"
 return 0
}
## public cmd back -- stop

## public cmd chat -- start
proc pub_chat {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Chat is only available via dcc chat"
}
## public cmd chat -- stop

## public cmd note -- start
proc pub_note {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set reciever [lindex $rest 0]
 set rest [lrange $rest 1 end]
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: note <hand> <note>"
 }
 if {$rest!=""} {
  set notetest [sendnote $hand $reciever $rest]
  if {$notetest==1} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Note to $reciever was recieved"
  }
  if {$notetest==2} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Note to $reciever was stored \[local\]"
  }
  if {$notetest==3} {
   puthelp "NOTICE $nick :\002\[FL\]\002 ${reciever}'s mailbox was full"
  }
  if {$notetest==4} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Tcl binding intercepted the note"
  }
  if {$notetest==5} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $reciever was away, note stored"
  }
  if {$notetest==0} {
   puthelp "NOTICE $nick :Send to $reciever failed" 
   return 0
  }
  putlog "\002\[FL\]\002 <<$nick>> !$hand! note $reciever *masked*"
 }
}
## public cmd chat -- stop

## public cmd files -- start
proc pub_files {nick uhost hand chan rest} {
 global botnick
 global sizeoffile
 set wowfiles [getfiles /]
 set wowdirs [getdirs /]
 if {$wowfiles!=""} {
 set z 0
 puthelp "NOTICE $nick :\002\[FL\]\002 $botnick is offering \002[llength $wowfiles] packs\002, type \002.get \[X\]\002 to recieve a file" 
 foreach x $wowfiles { 
  set z [expr $z+1]
  set sizeoffile [string trim [exec du dcc/$x] dcc/$x]
   if {[expr $sizeoffile/1024]!=0} {
    set sizeofthefile \[[expr $sizeoffile/1024]MB\]
    while {[string length $sizeofthefile]<7} {
     set sizeofthefile " $sizeofthefile"
    } 
   }  
   if {[expr $sizeoffile/1024]==0} { 
    set sizeofthefile \[${sizeoffile}k\]
    while {[string length $sizeofthefile]<8} {
     set sizeofthefile " $sizeofthefile"
    }
   }
   set wowfiles "\002${sizeofthefile}\002  $x"
   if {$z<10} {
    set z " $z"
   }
   puthelp "NOTICE $nick :\002\[FL\]\002 $z\002)\002 $wowfiles"
  }
 }
 if {$wowfiles==""} {set wowfiles "No files available"}  
 if {$wowdirs==""} {set wowdirs "No directories available"}
 if {$wowfiles=="No files available"} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Files: $wowfiles"
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 Directories: $wowdirs"
 puthelp "NOTICE $nick :\002\[FL\]\002 Many more commands available via dcc chat" 
 putlog "\002\[FL\]\002 <<$nick>> !$hand! files"
 return 0
}
## public cmd files -- stop

## public cmd newpass -- start
proc pub_newpass {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Newpass: For some reason, I think not"
}
## public cmd newpass -- stop

## public cmd console -- start
proc pub_console {nick uhost hand chan rest} {
 puthelp "NOTICE $nick :\002\[FL\]\002 Console is only available via dcc chat"
}
## public cmd console -- stop

## publuc cmd quit -- strt
proc pub_quit {nick uhost hand channel rest} {
puthelp "NOTICE $nick :\002\[FL\]\002 quit is only available via dcc chat."
}
## public cmd quit -- stop

## public cmd k -- start
proc pub_k {nick uhost hand channel rest} { 
 global CC botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}k <nick> \[reason\]"
 }
 if {$rest!=""} {
  pub_kick $nick $uhost $hand $channel $rest
 }
}
## public cmd k -- stop

## public cmd kick -- start
proc pub_kick {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: kick <nick> \[reason\]"
   return 0
  }
  set handle [lindex $rest 0]
  set reason [lrange $rest 1 end]
  if {![onchan $handle $channel]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $handle is not on the channel!"
   return 0
  }
  if {[onchansplit $handle $channel]} {
   puthelp "NOTICE $nick :\002\[FL\]\002 $handle is currently net-split."
   return 0
  }
  if {$reason == ""} {
   set reason "requested" 
  }   
  if {[string tolower $handle] == [string tolower $botnick]} {
   putserv "KICK $channel $nick :That was not Smart!"
   return 0
  } else {
   if {[matchattr $handle n] == 1} {
    putserv "KICK $channel $nick :Don't kick the boss..."
   return 0
   } else {
    putserv "KICK $channel $handle :\002${reason}\002"
    if {$reason == ""} {set reason "No given reason"}
    putcmdlog "\002\[FL\]\002 #$hand# kick $handle $reason"
    return 0
   }
  }
 }
 if {[botisop $channel]==0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## dcc cmd kick -- stop

## public cmd mdeop -- start
proc cmd_mdeop {hand idx arg} {
 global botnick
 set args [lindex $arg 0]
 if {$args == ""} {
  putdcc $idx "\002\[FL\]\002 Usage: mdeop <#channel>"
 }
 if {$args != ""} {  
  dcc_massdeop $hand $idx $arg
 }
}
## public cmd mdeop -- stop

## public cmd mop -- start
proc cmd_mop {hand idx arg} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set args [lindex $arg 0]
 if {$args == ""} {
  putdcc $idx "\002\[FL\]\002 Usage: mop <#channel>"
 }
 if {$args != ""} {
  dcc_massop $hand $idx $arg
 }
}
## public cmd mop -- stop

## public cmd massdeop -- start
proc pub_massdeop {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set deopnicks ""
 set mass 1
 if {$mass==1} {
  set deopnicks ""
  set massdeop 0
  set members [chanlist $chan]
  foreach x $members {
   if {([isop $x $chan] == 1) && ([onchansplit $x $chan] == 0) && ($x != $botnick) && ($x != $hand)} {
    if {$massdeop < 6} {
     append deopnicks " $x"
     set massdeop [expr $massdeop + 1]
    }
    if {$massdeop == 6} {
     set massdeop 0
     putserv "MODE $chan -oooooo $deopnicks"
     set deopnicks ""
     append deopnicks " $x"
     set massdeop 1
    }
   }
  }
  putserv "MODE $chan -oooooo $deopnicks"
  putlog "\002\[FL\]\002 #$hand# massdeop"
 }
}
## public cmd massdeop -- stop

## public cmd massop -- start
proc pub_massop {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set deopnicks ""
 set mass 1
 if {$mass == 1} {
  set opnicks ""
  set massops 0
  set members [chanlist $chan]
  foreach x $members {
   if {([isop $x $chan] == 0) && ([onchansplit $x $chan] == 0) && ($x != $botnick)} {
    if {$massops < 6} {
     append opnicks " $x"
     set massops [expr $massops + 1]
    }
    if {$massops == 6} {
     set massops 0
     pushmode $chan +oooooo $opnicks
     set opnicks ""
     append opnicks " $x"
     set massops 1
    }
   }
  }
  pushmode $chan +oooooo $opnicks
  putlog "\002\[FL\]\002 #$hand# massop"
 }
}
## public cmd massop -- stop

## dcc cmd massdeop -- start
proc dcc_massdeop {hand idx arg} {
 global botnick
 set deopnicks ""
 set mass 1
 set chan [lindex $arg 0]
 if {$chan == ""} {
  putdcc $idx "\002\[\FL\]\002 Usage: massdeop <#channel>"
  return 1
 }
 if {$mass==1} {
  set deopnicks ""
  set massdeop 0
  set members [chanlist $chan]
  foreach x $members {
   if {([isop $x $chan] == 1) && ([onchansplit $x $chan] == 0) && ($x != $botnick) && ($x != $hand)} {
    if {$massdeop < 6} {
     append deopnicks " $x"
     set massdeop [expr $massdeop + 1]
    }
    if {$massdeop == 6} {
     set massdeop 0
     putserv "MODE $chan -oooooo $deopnicks"
     set deopnicks ""
     append deopnicks " $x"
     set massdeop 1
    }
   }
  }
  putserv "MODE $chan -oooooo $deopnicks"
  putlog "\002\[FL\]\002 #$hand# massdeop"
 }
}
## dcc cmd massdeop -- stop

## dcc cmd massop -- start
proc dcc_massop {hand idx arg} {
 global botnick
 set deopnicks ""
 set mass 1
 set chan [lindex $arg 0]
 if {$chan == ""} {
  putdcc $idx "\002\[\FL\]\002 Usage: massop <#channel>"
  return 1
 }
 if {$mass == 1} {
  set opnicks ""
  set massops 0
  set members [chanlist $chan]
  foreach x $members {
   if {([isop $x $chan] == 0) && ([onchansplit $x $chan] == 0) && ($x != $botnick)} {
    if {$massops < 6} {
     append opnicks " $x"
     set massops [expr $massops + 1]
    }
    if {$massops == 6} {
     set massops 0
     pushmode $chan +oooooo $opnicks
     set opnicks ""
     append opnicks " $x"
     set massops 1
    }
   }
  }
  pushmode $chan +oooooo $opnicks
  putlog "\002\[FL\]\002 #$hand# massop"
 }
}
## dcc cmd massop -- stop

## public cmd kickban -- start
proc pub_kickban  {nick uhost hand channel rest} {
 global botnick CC ban-time
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}kickban <nick> \[reason\]"
   return 0
  }
  if {$rest!=""} {
   set handle [lindex $rest 0]
   set reason [lrange $rest 1 end]
   append userhost $handle "!*" [getchanhost $handle $channel]
   set hostmask [maskhost $userhost]
   if {![onchan $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is not on the channel."
    return 0
   }
   if {[onchansplit $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is currently net-split."
    return 0
   }
   if {[string tolower $handle] == [string tolower $botnick]} {
    putserv "KICK $channel $nick :\002\[FL\]\002 You really shouldn't try that..."
    return 0
   }    
   if {$reason == ""} { 
    set reason "requested" 
   }
   set options [lindex $reason 0]
   if {[string index $options 0] == "-"} {
     set options [string range $options 1 end]
   }
   switch -exact  $options {
     perm {
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" 0
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
           }
     min {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [lindex $reason 1]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
          }
     hours {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [lindex $reason 1]*60]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
     days {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [lindex $reason 1]*60]*24]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
     weeks {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [expr [lindex $reason 1]*60]*24]*7]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
   }
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" $ban-time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
  } 
 }
 if {[isop $botnick $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## public cmd kickban -- stop

## public cmd kb -- start
proc pub_kb  {nick uhost hand channel rest} {
 global botnick CC
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: ${CC}kb <nick> \[reason\]"
   return 0
  }
  if {$rest!=""} {
   set handle [lindex $rest 0]
   set reason [lrange $rest 1 end]
   append userhost $handle "!*" [getchanhost $handle $channel]
   set hostmask [maskhost $userhost]
   if {![onchan $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is not on the channel."
    return 0
   }
   if {[onchansplit $handle $channel]} {
    puthelp "NOTICE $nick :\002\[FL\]\002 $handle is currently net-split."
    return 0
   }
   if {[string tolower $handle] == [string tolower $botnick]} {
    putserv "KICK $channel $nick :\002\[FL\]\002 You really shouldn't try that..."
    return 0
   }    
   if {$reason == ""} { 
    set reason "requested" 
   }
   set options [lindex $reason 0]
   if {[string index $options 0] == "-"} {
     set options [string range $options 1 end]
   }
   switch -exact  $options {
     perm {
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" 0
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
           }
     min {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [lindex $reason 1]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
          }
     hours {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [lindex $reason 1]*60]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
     days {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [lindex $reason 1]*60]*24]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
     weeks {
             if {[val [lindex $reason 1]] == ""} {
               puthelp "NOTICE $nick :\002\[FL\]\002 Error, invalid time period"
               return 0
             }
             set time [expr [expr [expr [lindex $reason 1]*60]*24]*7]
             set reason [lrange $reason 2 end]
             newchanban $channel $hostmask $nick "$reason" $time
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
     }
   }
             set reason [lrange $reason 1 end]
             newchanban $channel $hostmask $nick "$reason" 0
             if {$reason == ""} {set reason "No reason given"}
             putlog "\002\[FL\]\002 <<$nick>> !$hand! kicban $channel $hostmask $options $reason"
             putserv "KICK $channel $handle :$reason"
             return 0
  } 
 }
 if {[isop $botnick $channel]!=1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 I am not oped"
 }
}
## public cmd ban -- stop

## public cmd info -- start
proc pub_info {nick uhost hand chan rest} {
 global botnick
# puthelp "NOTICE $nick :\002\[FL\]\002 This command is only available via dcc chat"
# return 0
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {$rest==""} {
 set wowthatinfo [getuser $hand INFO]
 if {$wowthatinfo==""} {set wowthatinfo "No info is set"}
  puthelp "NOTICE $nick :\002\[FL\]\002 Info: $wowthatinfo"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! info"
  return 0
 }
 if {$rest!=""} {
  if {[string toupper $rest]=="NONE"} {
   setuser $hand info ""
   puthelp "NOTICE $nick :\002\[FL\]\002 Your info has been cleared"
   putlog "\002\[FL\]\002 <<$nick>> !$hand! info none"
   return 0
  }
  if {[string toupper $rest]!="NONE"} {
   setuser $hand info $rest
   puthelp "NOTICE $nick :\002\[FL\]\002 Your info is now $rest"
   putlog "\002\[FL\]\002 <<$nick>> !$hand! info $rest"
   return 0
  }
 }
}
## public cmd info -- stop

## public cmd get -- start
proc pub_get {nick uhost hand chan rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 set rest [lindex $rest 0]
 if {$rest==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: get <file #>"
 }
 if {$rest!=""} {
  set f 0
  if {[catch {set numberoffile [expr $rest-1]}]==1} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Usage: get <file #>"
   return 0
  }
  foreach x [getfiles /] {
   if {$x==[lrange [getfiles /] $numberoffile $numberoffile]} {
    set f 1
   } 
  }
  if {$f==1} {
   puthelp "NOTICE $nick :\002\[FL\]\002 Sending you [lrange [getfiles /] $numberoffile $numberoffile]" 
   dccsend dcc/[lrange [getfiles /] $numberoffile $numberoffile] $nick
   putlog "\002\[FL\]\002 <<$nick>> !$hand! get $rest"
   return 0
  } 
  if {$f!="1"} {
   puhelp "NOTICE $nick :\002\[FL\]\002 Incorrect file number"
  }
 }
}
## public cmd get -- stop

## dcc cmd userlist -- start
proc cmd_userlist {hand idx args} {
 set args [lindex $args 0]
 set f [lindex $args 0]
 if {[userlist $f] ==""} {
  putdcc $idx "\002\[FL\]\002 No users with flag(s) $f."
  putcmdlog "\002\[FL\]\002 #$hand# userlist $f"
  return 0
 }
 if {[userlist $f] !=""} {
  regsub -all " " [userlist $f]  ", " userlist
  putdcc $idx "\002\[FL\]\002 Userlist: $userlist"
  putcmdlog "\002\[FL\]\002 #$hand# userlist $f"
  return 0
 }
}
## dcc cmd userlist -- stop

## public cmd userlist -- start
proc pub_userlist {nick uhost hand chan rest} {
 set rest [lindex $rest 0]
 set f [lindex $rest 0]
 if {[userlist $f] ==""} {
  puthelp "NOTICE $nick :\002\[FL\]\002 No users with flag(s) \[$f\]"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! userlist $f"
}
if {[userlist $f] !=""} {
 set tester $f
 if {$tester!=""} {set tester " \[$tester\]"}
  regsub -all " " [userlist $f]  ", " userlist 
  puthelp "NOTICE $nick :\002\[FL\]\002 Userlist$tester: $userlist"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! userlist $f"
 }
}
## public cmd userlist -- stop

## dcc cmd ramen -- start
proc cmd_ramen {hand idx args} {
 global botnick
 set cmd [string tolower [lindex $args 0]]
 putdcc $idx "* $botnick makes you some good ass ramen noodles"
 putdcc $idx "Enjoy!"
 putcmdlog "\002\[FL\]\002 #$hand# ramen"
 return 0
}
## dcc cmd ramen -- stop

## public cmd pez -- start
proc pub_pez {nick uhost hand chan rest} {
 global botnick
 set cmd [string tolower [lindex $rest 0]]
 puthelp "PRIVMSG $chan :\001ACTION rips open a pack of pez for $nick\001"
 puthelp "PRIVMSG $chan :ENJOY!"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! pez"
 return 0
}
## public cmd ramen -- start
proc pub_ramen {nick uhost hand chan rest} {
 global botnick
 set cmd [string tolower [lindex $rest 0]]
 puthelp "PRIVMSG $chan :\001ACTION makes $nick some good ass ramen noodles.\001"
 puthelp "PRIVMSG $chan :ENJOY!"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! ramen"
 return 0
}
## public cmd ramen -- stop

## public cmd ping -- start
proc pub_ping {nick uhost hand chan rest} {
 global botnick
 set cmd [string tolower [lindex $rest 0]]
 puthelp "PRIVMSG $chan :${nick}, \002PONG\002"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! ping"
}
## public cmd ping -- stop

## public cmd pong -- start
proc pub_pong {nick uhost hand chan rest} {
 global botnick
 set cmd [string tolower [lindex $rest 0]]
 puthelp "PRIVMSG $chan :${nick}, \002PING\002"
 putlog "\002\[FL\]\002 <<$nick>> !$hand! pong"
}
## public cmd pong -- stop

## dcc cmd channels -- start
proc cmd_channels {hand idx args} {
 putdcc $idx "\002\[FL\]\002 Channels: [channels]"
 putcmdlog "\002\[FL\]\002 #$hand# channels"
}
## dcc cmd channels --- stop

## public cmd beer -- start
proc pub_beer {nick uhost hand chan rest} {
 global botnick
 set rest [string tolower [lindex $rest 0]]
 if {$rest==""} {
  puthelp "PRIVMSG $chan :\001ACTION hands $nick a frothy beer.\001"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! beer"
  return 0 
 }
 switch $rest {
    sixpack  { putserv "PRIVMSG $chan :Here's some sixpacks, it's on me... =]"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"              
               return 0 }
    keg { putserv "PRIVMSG $chan :Hey...lets go in the woods and have a kegger!"
          putserv "PRIVMSG $chan :hurry up and give me one =]"
          putserv "PRIVMSG $chan :Damn...I can't walk....tink I am done..."
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    mug     {  putserv "PRIVMSG $chan :Here's your mug of beer.... <g>"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    can      { putserv "PRIVMSG $chan :\001ACTION calls Fido\001"
               putserv "PRIVMSG $chan :Fido...get me a beer...thx"
               putserv "PRIVMSG $chan :\001ACTION hands $nick a can of beer\001"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    tap      { putserv "PRIVMSG $chan :\001ACTION puts his head under the tap\001"
               putserv "PRIVMSG $chan :\001ACTION opens his mouth\001"
               putserv "PRIVMSG $chan :\001ACTION gets plastered\001"
               putserv "PRIVMSG $chan :Sorry....all gone =P"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    time    { putserv "PRIVMSG $chan :Guess what time it is guys?"
               if {[isop $botnick $chan]==1} {
               putserv "TOPIC $chan :\002It's Beer Time!!"}
               if {[isop $botnick $chan]!=1} {
               putserv "PRIVMSG $chan :\002It's Beer Time!!"}
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    help     { putserv "NOTICE $nick :\002\[FL\]\002 Beer Help"
               putserv "NOTICE $nick :\002\[FL\]\002 Usage: beer <command>"
               putserv "NOTICE $nick :\002\[FL\]\002 Usable Beer Types Are:"
               putserv "NOTICE $nick :\002\[FL\]\002 Sixpack, Keg, Mug, Can, Tap, Time"
               putserv "NOTICE $nick :\002\[FL\]\002 End Of Help -"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! beer $rest"
               return 0 }
    return 0
 }
 puthelp "NOTICE $nick :\002\[FL\]\002 Usage: beer <help | command>'"
}
## public cmd beer -- stop

## public cmd drug -- start
proc pub_drug {nick uhost hand chan rest} {
 global botnick
 set rest [string tolower [lindex $rest 0]]
 if {$rest == ""} {
  puthelp "PRIVMSG $chan :\001ACTION hands $nick a phat joint.\001"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! drug"
  return 0 
 }
 switch $rest {
    weed    { putserv "PRIVMSG $chan :Here's some weed, now pack a bong =]"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"      
               return 0 }
    bud      { putserv "PRIVMSG $chan :Beer or Weed?"
               putserv "PRIVMSG $chan :...ummm...here's some of both..."
               putserv "PRIVMSG $chan :Have a good time $nick <g>"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    shrooms  { putserv "PRIVMSG $chan :Here's your shrooms, hope their good..."
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    acid     { putserv "PRIVMSG $chan :\001ACTION grabs some sheets\001"
               putserv "PRIVMSG $chan :\001ACTION quickly eats one\001"
               putserv "PRIVMSG $chan :HeRe'S YOUr shEEt $nick =]"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    time    { putserv "PRIVMSG $chan :Guess what time it is guys?"
              if {[isop $botnick $chan]==1} {
               putserv "TOPIC $chan :\002It's Time for Drugs!!" }
              if {[isop $botnick $chan]!=1} {
               putserv "PRIVMSG $chan :\002It's Time for Drugs!!" }
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    help     { putserv "NOTICE $nick :\002\[FL\]\002  Drug Help"
               putserv "NOTICE $nick :\002\[FL\]\002  Usage: drug <cmd>"
               putserv "NOTICE $nick :\002\[FL\]\002  Usable Drug Types Are:"
               putserv "NOTICE $nick :\002\[FL\]\002  Weed, Bud, Shrooms, Acid, Opium, " 
               putserv "NOTICE $nick :\002\[FL\]\002  Extasy, Time"
               putserv "NOTICE $nick :\002\[FL\]\002  End Of Help -"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    opium    { putserv "PRIVMSG $chan :Yummmy....$nick has good taste"
               putserv "PRIVMSG $chan :\001ACTION packs a bowl for $nick\001"
               putserv "PRIVMSG $chan :Here is OUR bowl of opium =P"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    extasy   { putserv "PRIVMSG $chan :Wow....I love this shit..."
               putserv "PRIVMSG $chan :\001ACTION gets two pills\001"
               putserv "PRIVMSG $chan :\001ACTION gives $nick a pill"
               putserv "PRIVMSG $chan :\001ACTION eats a pill"
               putserv "PRIVMSG $chan :hey $nick where are the women?"
               putlog "\002\[FL\]\002 <<$nick>> !$hand! drug $rest"
               return 0 }
    return 0
  }
 puthelp "NOTICE $nick :\002\[FL\]\002 Usage: drug <help | command>"
}
## public cmd drug -- stop

## dcc cmd global -- start
proc cmd_global {hand idx args} {
 set gsay [lindex $args 0]
 global botnick
 if {$gsay!=""} {
  dccbroadcast "\002GLOBAL <${hand}@${botnick}>\002 : $gsay"
  putcmdlog "\002\[FL\]\002  #$hand# global $gsay"
 }
 if {$gsay==""} {
 putdcc $idx "\002\[FL\]\002 Usage: global <msg>"
 }
}
## dcc global -- stop

## dcc cmd flagnote -- start
 set oldflags "c d f j k m n o p x t h a v q"
 set botflags "a b h l r s p"

proc cmd_flagnote {hand idx arg} {
 global oldflags botflags
 set whichflag [lindex $arg 0]
 set message [lrange $arg 1 end]
 if {$whichflag == "" || $message == ""} {
  putdcc $idx "\002\[FL\]\002 Usage: flagnote <flag> <msg>"
  return 0
 }
 if {[string index $whichflag 0] == "+"} {
  set whichflag [string index $whichflag 1]
 }
 set normwhichflag [string tolower $whichflag]
 set boldwhichflag \[\002+$normwhichflag\002\]
 if {([lsearch -exact $botflags $normwhichflag] > 0)} {
  putdcc $idx "\002\[FL\]\002 The flag $boldwhichflag is for bots only"
  putdcc $idx "\002\[FL\]\002 Choose from the following: $oldflags $newflags"
  return 0
 }
 if {([lsearch -exact $oldflags $normwhichflag] < 0) && ([lsearch -exact $botflags $normwhichflag] < 0)} {
  putdcc $idx "\002\[FL\]\002 The flag $boldwhichflag is not a defined flag"
  putdcc $idx "\002\[FL\]\002 Choose from the following: $oldflags"
  return 0
 }
 putlog "\002\[FL\]\002 #$hand# flagnote [string tolower \[+$whichflag\]] ..."
 putdcc $idx "\002\[FL\]\002  Sending FlagNote to all $boldwhichflag users"
 foreach user [userlist $normwhichflag] {
  if {(![matchattr $user b])} {
   sendnote $hand $user "$whichflag $message"
  }
 }
}
## dcc cmd flagnote -- stop

## public cmd time -- start
proc pub_time {nick uhost hand chan rest} {
 global timezone
 set fronttime [string range [time] 0 1]
 set backtime [string range [time] 2 4]
 if {$fronttime == "00"} {
  puthelp "NOTICE $nick :\002\[FL\]\002 The current time is 12$backtime AM $timezone"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! time"
  return 0
 }
 if {$fronttime < 12} {
  puthelp "NOTICE $nick :\002\[FL\]\002 The current time is $fronttime$backtime AM $timezone"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! time"
  return 0
 }
 if {$fronttime >= 12} {
  putserv "NOTICE $nick :\002\[FL\]\002 The current time is [expr $fronttime-12]$backtime PM $timezone"
  putlog "\002\[FL\]\002 <<$nick>> !$hand! time"
  return 0
 }
}
## public cmd time -- stop

## public cmd down -- start
proc pub_down {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel] != 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Im not oped, sorry."
  return 0
 }
 if {[isop $nick $channel] == 1} {
  putlog "\002\[FL\]\002 <<$nick>> !$hand! down"
  pushmode $channel -o $nick
 } else {
  puthelp "NOTICE $nick :\002\[FL\]\002 You are already deoped."
  return 0
 }
}
## public cmd down -- stop

## public cmd up -- start
proc pub_up {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002\[FL\]\002 This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel] != 1} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Im not oped, sorry."
  return 0
 }
 if {[isop $nick $channel] == 0} {
  putlog "\002\[FL\]\002 <<$nick>> !$hand! up"
  pushmode $channel +o $nick
 } else {
  puthelp "NOTICE $nick :\002\[FL\]\002 You are already oped."
  return 0
 }
}
## public cmd up -- stop
set vers "v3.6.1"
putlog "\02\[FL\]\02 \26facelift.tcl\26 $vers by Kindred loaded"

