# shoutcast.tcl v1.03 by domsen <domsen@domsen.org> (c)2oo5
#
# comments? bugs? ideas? requests? money? beer? 
# plz mail me or visit my homepage @ www.domsen.org
# visit #newsticker@ircnet
#
#
# whats this script all about?
# -----------------------------
#
# this script is for all the online radio admins out there. it announces serveral
# stuff like the status of your radio, the current song, new listener peaks,
# the current listeners and much much more to the channels you want.
# the users can get infos by public and msg command, too, like the stream url,
# stream stats, the last played songs, the current song, the dj... and much much
# more.
# also the bot informs the users about the current dj, whenever he changes or
# a certain command is triggered. the dj name doesnt need to be your nickname,
# so you can also call yourself "goethe mc" even if your irc nickname is
# [gay]michael. the good thing about this is: nobody knows your nickname, so 
# you wont get unwanted querys with wishes and greets. the dj can also change
# his nickname and the wish- and greet-feature will still work fine.
# only users with the flag +D can be djs, so make sure to give this flag to
# your djs -> .chattr djnick +D in the partyline.
# 
# the script also changes the topic when your stream goes on or offline and
# sends a public message, which is fully costumizeable. try it out yourself
# and maybe it suits your needs :)
#
# it was tested with shoutcast 1.9.2 on debian linux.
#
# NOTE 1: make sure youve got a good connection from your shellserver to your
# streamserver - if its the same server then thats very very good. the bot
# checks every minute if something happened, so if the connection is not fast
# the bot will lag like hell or timeout. make sure to change your settings
# for the eggdrop floodprotection.
#
# NOTE 2: read the text here carefully, i get many many emails asking questions
# which are acutally answered in this manual here. dont expect me to answer
# these mails. :P
#
#
# script history:
# ----------------
#
# v1.03 - different variables in the texts/topics possible
#       - possibility to unset the dj
#	- splitted the scripts chans in 'radiochans' and 'adminchans'
#	- 'advertiseonlyifonline'-function
#	- possibility to get a msg if the bot goes down
#	- more regexes
#	- some bugfixes 
# v1.02 - added the .listener command, corrected some typos ;>
# v1.01 - fixed a string i forgot to replace
# v1.0  - first public release
#
#
#
# what does what config option mean/do?
# --------------------------------------
#
# radiochans - the channels the tcl is active in, "" for all, or "#aurorfm"
# adminchans - the channels the admin commands work in
#
# streamip - the ip of your radio
# streamport - the port of your radio
# streampass - the admin pass of your radio
#
# scstatstrigger - the trigger for the radio stats
# scplayingtrigger - shows the song the radio is playing now
# sclistenertrigger - shows the current listenercount
# scdjtrigger - shows the current dj name
# scstreamtrigger - shows your stream url -> streamtext
# scsetdjtrigger - sets the current dj name, this doesnt have to be your nickname.
#                  your nick will be saved too and all wishes and greets will be
#                  redirected to this nickname. only availavle for ppl with the +D
#                  flag.
# scunsetdjtrigger - unsets the current dj, needs the +D flag
# scwishtrigger - the command which the users can use if they wish a certain song
# scgreettrigger - the command which users can use if the want to greet sb
# sclastsongstrigger - the commands which users can use if they want to see the
#                      songhistory
# schelptrigger - shows the available commands
#
# alertadmin - the userhandle of the user who will get a msg if the server goes down
# doalertadmin - 1 if you want to get a msg if the server goes offline, 0 if you
#		 dont. this is done through the bots notes system because its
#		 more comfortable and persistent this way.
#
# announce - shall the bot announce any stuff? 1 for yes, 0 for no
# urltopic - shall the bot change the topic everytime the radio goes on or off?
# tellsongs - shall the bot post the songtitle to the channels everytime a
#             new song starts?
# tellusers - shall the bot post the number of current users to the channel
#             everytime it changes or a new user maximum is reached?
# tellbitrate - shall the bot announce bitrate changes?
#
# offlinetext - the reason the bot says when the radio goes offline
# offlinetopic - the topic which is set when the radio goes offline
#
# onlinetext - the reason the bot says when the radio goes online
# onlinetopic - the topic which is set when the radio goes online
#
# streamtext - the text with your stream infos
# advertise - shall the bot advertist the advertisetext?
# advertiseonlyifonline - 1 if the bot only should advertise the radio if the stream
#			  is up and running, 0 for all-the-time advertisement
# advertisetext - the text the bot will post once every 10 minutes.
#
#
#
# how do i put veriables in the different texts and topics?
# ----------------------------------------------------------
#
# the script knows the following variables which can be used in the offlinetext,
# offlinetopic, onlinetext, onlinetopic, streamtext and advertisetext:
# 
# /dj/ - the djnickname
# /sgenre/ - the servers music genre
# /stitle/ - the streamtitle
# /surl/ - the servers url
# /bitrate/ - the current streaming bitrate
# /curlist/ - current listeners
# /curhigh/ - current listener peak
# /cursong/ - the current song
# $streamip - the streams ip
# $streamport - the streams port
# 
#
#
# known bugs:
# ------------
#
# -numbers in the songhistory are killed, this is a xml sourcecode problem
# -öäü are not shown correctly in the songtitles, because xml replaces each
#  of them with the same chars, so i cant fix it :( bitnapper told me it
#  would work anyway, but i cant confirm it. maybe my shoutcast version sucks.
#  the string replacements are included, so if it works youre a lucky guy.
#
#
# loser of the day:
# ------------------
#
# loops aka edema for ripping the whole script, removing all of my copyright
# infos and comments and putting his name under it. yeah, thats the open source
# spirit...
#
#
#
# config ##########################

set radiochans "#chat"
set adminchans "#solutionsradio"
set streamip "radio.shellsolutions.net"
set streamport "8064"
set streampass "tsarabe1"
set scstatstrigger "!stats"
set scstreamtrigger "!stream"
set scplayingtrigger "!playing"
set sclistenertrigger "!listener"
set scdjtrigger "!dj"
set scsetdjtrigger "!setdj"
set scunsetdjtrigger "!unsetdj"
set scwishtrigger "!wish"
set scgreettrigger "!greet"
set sclastsongstrigger "!lastsongs"
set schelptrigger "!help"

set alertadmin ""
set doalertadmin "1"

set announce "1"

set urltopic "0"
set ctodjc "0"
set tellsongs "1"
set tellusers "0"
set tellbitrate "0"

set advertise "0"
set advertiseonlyifonline "0"

set offlinetext "\0037Solutions Radio\00310 Now Is \0034Offline"
set offlinetopic "\0037Solutions Radio\00310 now \0034Offline\00310 - Check Out Our Hosting Deals http://www.shellsolutions.net"

set onlinetopic "\0037Solutions Radio\00310 now \0039Online\00310 - Check Out Our Hosting Deals http://www.shellsolutions.net"
set onlinetext "\0037Solutions Radio\00310 now \0039Online\00310 @ http://$streamip:$streamport with /bitrate/kbits"

set streamtext "tune in /dj/ @ http://$streamip:$streamport/listen.pls"

set advertisetext "\0037Solutions Radio\00310 streaming @ http://$streamip:$streamport/listen.pls - powered by ShellSolutions - http://www.shellsolutions.net"

# end of config #####################

bind pub - $scstatstrigger  pub_scstat
bind msg - $scstatstrigger  msg_scstat

bind pub - $scplayingtrigger  pub_playing
bind msg - $scplayingtrigger  msg_playing

bind pub - $scdjtrigger  pub_dj
bind msg - $scdjtrigger  msg_dj

bind pub D $scsetdjtrigger  pub_setdj
bind msg D $scsetdjtrigger  msg_setdj

bind pub D $scunsetdjtrigger  pub_unsetdj
bind msg D $scunsetdjtrigger  msg_unsetdj

bind pub - $scwishtrigger  pub_wish
bind msg - $scwishtrigger  msg_wish

bind pub - $scgreettrigger  pub_greet
bind msg - $scgreettrigger  msg_greet

bind pub - $scstreamtrigger pub_stream
bind msg - $scstreamtrigger msg_stream

bind pub - $sclastsongstrigger pub_lastsongs
bind msg - $sclastsongstrigger msg_lastsongs

bind pub - $sclistenertrigger pub_listener
bind msg - $sclistenertrigger msg_listener

bind pub - $schelptrigger pub_help
bind msg - $schelptrigger msg_help

bind time - "* * * * *" isonline
bind time - "30 * * * *" advertise
bind nick D * djnickchange


set dj ""
set surl ""
set bitrate ""
set stitle ""

if {[file exists dj]} {
set temp [open "dj" r]
set dj [gets $temp]
close $temp
}

proc shrink { calc number string start bl} { return [expr [string first "$string" $bl $start] $calc $number] }


proc status { } {
global streamip streamport streampass
if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0 } else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set streamstatus [string range $bl [shrink + 14 "<STREAMSTATUS>" 0 $bl] [shrink - 1 "</STREAMSTATUS>" 0 $bl]]
}}
close $sock
} 
if { $streamstatus == "1" } { return 1 } else { return 0 }
}




proc poststuff { mode text } {
global radiochans dj
set curlist "0"
set curhigh "0"
set surl ""
set cursong ""
set sgenre ""
set bitrate "0"
set stitle ""

set temp [open "isonline" r]
while {[eof $temp] != 1} {
set zeile [gets $temp]
if {[string first "curlist:" $zeile] != -1 } { set curlist $zeile }
if {[string first "curhigh:" $zeile] != -1 } { set curhigh $zeile }
if {[string first "cursong:" $zeile] != -1 } { set cursong [lrange $zeile 1 [llength $zeile]]] }
if {[string first "sgenre:" $zeile] != -1 } { set sgenre [lrange $zeile 1 [llength $zeile]]}
if {[string first "serverurl:" $zeile] != -1 } { set surl [lindex $zeile 1] }
if {[string first "bitrate:" $zeile] != -1 } { set bitrate [lindex $zeile 1] }
if {[string first "stitle:" $zeile] != -1 } { set stitle [lindex $zeile 1] }
}
close $temp

regsub -all "/stitle/" $text "$stitle" text
regsub -all "/curlist/" $text "$curlist" text
regsub -all "/curhigh/" $text "$curhigh" text
regsub -all "/cursong/" $text "$cursong" text
regsub -all "/sgenre/" $text "$sgenre" text
regsub -all "/surl/" $text "$surl" text
regsub -all "/bitrate/" $text "$bitrate" text
regsub -all "/dj/" $text "$dj" text

foreach chan [channels] {
if {$radiochans == "" } { putserv "$mode $chan :$text" }
if {$radiochans != "" } {
if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1)} {putserv "$mode $chan :$text"}
}}}


proc schelp { target } {
global scstatstrigger scstreamtrigger scplayingtrigger scdjtrigger sclastsongstrigger scwishtrigger scgreettrigger sclistenertrigger
putserv "notice $target :the following commands are available:"
putserv "notice $target :$scstatstrigger - $scstreamtrigger - $scplayingtrigger - $scdjtrigger - $sclastsongstrigger - $scwishtrigger - $scgreettrigger - $sclistenertrigger"
putserv "notice $target :shoutcast.tcl by domsen <domsen@domsen.org>"
}

proc pub_help {nick uhost hand chan arg} {
global radiochans
if {$radiochans == "" } { schelp $nick }
if {$radiochans != "" } {
if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { schelp $nick}
}}

proc advertise { nick uhost hand chan arg } {
global advertisetext advertise advertiseonlyifonline
if {$advertise == "1" && $advertiseonlyifonline == "0"} { poststuff privmsg "$advertisetext" }
if {$advertise == "1" && $advertiseonlyifonline == "1" && [status] == 1} { poststuff privmsg "$advertisetext" }
}


proc setdj {nickname djnickname } {
if {$djnickname == "" } { set djnickname $nickname }
global streamip streamport streampass dj 
putlog "shoutcast: new dj: $djnickname ($nickname)"
set temp [open "dj" w+]
puts $temp $djnickname
close $temp
set temp [open "djnick" w+]
puts $temp $nickname
close $temp
if { [status] == "1" } { poststuff privmsg "$djnickname is now rocking the turntables, enjoy."
if { $ctodjc == "1" } {
set temp [open "isonline" r]
while {[eof $temp] != 1} {
set zeile [gets $temp]
if {[string first "isonline:" $zeile] != -1 } { set oldisonline $zeile }
if {[string first "curlist:" $zeile] != -1 } { set oldcurlist $zeile }
if {[string first "curhigh:" $zeile] != -1 } { set oldcurhigh $zeile }
if {[string first "cursong:" $zeile] != -1 } { set oldsong $zeile }
if {[string first "bitrate:" $zeile] != -1 } { set oldbitrate $zeile }
}
close $temp
}
} else {
putserv "privmsg $nickname :this has not been announced because the radio is currentlfy offline." }
}


proc msg_setdj { nick uhost hand arg } { setdj $nick $arg }
proc pub_setdj { nick uhost hand chan arg } { global adminchans; if {([lsearch -exact [string tolower $adminchans] [string tolower $chan]] != -1) || ($adminchans == "")} { setdj $nick $arg }}

proc unsetdj { nick } {
global dj
set dj ""
file delete dj
putserv "notice $nick :dj deleted"
}



proc msg_unsetdj { nick uhost hand arg } { unsetdj $nick }
proc pub_unsetdj { nick uhost hand chan arg } { global adminchans; if {([lsearch -exact [string tolower $adminchans] [string tolower $chan]] != -1) || ($adminchans == "")} { unsetdj $nick }}


proc listener { target } {
global streamip streamport streampass
putlog "shoutcast: $target requested listener count"
if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0 } else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set repl [string range $bl [shrink + 19 "<REPORTEDLISTENERS>" 0 $bl] [shrink - 1 "</REPORTEDLISTENERS>" 0 $bl]]
set curhigh [string range $bl [shrink + 15 "<PEAKLISTENERS>" 0 $bl] [shrink - 1 "</PEAKLISTENERS>" 0 $bl]]
set maxl [string range $bl [shrink + 14 "<MAXLISTENERS>" 0 $bl] [shrink - 1 "</MAXLISTENERS>" 0 $bl]]
set avgtime [string range $bl [shrink + 13 "<AVERAGETIME>" 0 $bl] [shrink - 1 "</AVERAGETIME>" 0 $bl]]
}}
close $sock
putserv "notice $target :there are currently $repl unique people listening, the listener maximum is $maxl, our user peak was at $curhigh listeners, the listening time average is $avgtime"
}}

proc msg_listener { nick uhost hand arg } { listener $nick }
proc pub_listener { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { listener $nick  }}

proc wish { nick arg } {
if {$arg == ""} { putserv "notice $nick :you forgot to add your wish"; return 0}
if { [status] == "1" } { 
set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
putserv "privmsg $djnick :(WISH) - $nick - $arg"
} else {
putserv "notice $nick :sorry radio is currently offline" }
}


proc msg_wish { nick uhost hand arg } { wish $nick $arg }
proc pub_wish { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { wish $nick $arg }}




proc sclastsongs { target } {
global streamip streamport streampass
putlog "shoutcast: $target requested songhistory"
if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0 } else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set songs [string range $bl [string first "<TITLE>" $bl] [expr [string last "</TITLE>" $bl] + 7]]

regsub -all "&#x3C;" $songs "<" songs
regsub -all "&#x3E;" $songs ">" songs
regsub -all "&#x26;" $songs "+" songs
regsub -all "&#x22;" $songs "\"" songs
regsub -all "&#x27;" $songs "'" songs
regsub -all "&#xFF;" $songs "" songs
regsub -all "<TITLE>" $songs "(" songs
regsub -all "</TITLE>" $songs ")" songs
regsub -all "<SONG>" $songs "" songs
regsub -all "</SONG>" $songs " - " songs
regsub -all "<PLAYEDAT>" $songs "" songs
regsub -all "</PLAYEDAT>" $songs "" songs
regsub -all {\d} $songs "" songs

regsub -all "&#xB4;" $songs "´" songs
regsub -all "&#x96;" $songs "-" songs
regsub -all "&#xF6;" $songs "ö" songs
regsub -all "&#xE4;" $songs "ä" songs
regsub -all "&#xFC;" $songs "ü" songs
regsub -all "&#xD6;" $songs "Ö" songs
regsub -all "&#xC4;" $songs "Ä" songs
regsub -all "&#xDC;" $songs "Ü" songs
regsub -all "&#xDF;" $songs "ß" songs



}}
close $sock
putserv "notice $target :$songs"
}}


proc msg_lastsongs { nick uhost hand arg } { sclastsongs $nick }
proc pub_lastsongs { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { sclastsongs $nick }}



proc scstream { target } {
global streamip streamport streamtext
putlog "shoutcast: streaminfo requested by $target"
putserv "notice $target :$streamtext"
}

proc msg_stream { nick uhost hand arg } { scstream $nick }
proc pub_stream { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scstream $nick }}

proc scgreet { nick arg } {
if {$arg == ""} { putserv "notice $nick :you forgot to add your greetmessage"; return 0}
if { [status] == "1" } { 
set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
putserv "privmsg $djnick :(GREET) - $nick - $arg"
} else {
putserv "notice $nick :sorry radio is currently offline" }
}


proc msg_greet { nick uhost hand arg } { scgreet $nick $arg }
proc pub_greet { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreet $nick $arg }}



proc djnickchange { oldnick uhost hand chan newnick } {
set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
if {$oldnick == $djnick} {
putlog "shoutcast: dj nickchange $oldnick -> $newnick"
set temp [open "djnick" w+]
puts $temp $newnick
close $temp
}}





proc dj { target } {
global streamip streamport streampass dj
putlog "shoutcast: $target asked for dj info" 
if {[status] == 1} {
if {[file exists dj]} {
set temp [open "dj" r]
set dj [gets $temp]
close $temp
putserv "notice $target :$dj is at the turntables!"
} else { putserv "notice $target :sorry, no dj name available" }
} else { putserv "notice $target :sorry radio is currently offline" }
}



proc msg_dj { nick uhost hand arg } { dj $nick"}
proc pub_dj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { dj $nick  }}



proc scstat {target} {
global streamip streamport streampass
putlog "shoutcast: $target asked for serverstats"
if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0 } else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set streamstatus [string range $bl [shrink + 14 "<STREAMSTATUS>" 0 $bl] [shrink - 1 "</STREAMSTATUS>" 0 $bl]]
set repl [string range $bl [shrink + 19 "<REPORTEDLISTENERS>" 0 $bl] [shrink - 1 "</REPORTEDLISTENERS>" 0 $bl]]
set curhigh [string range $bl [shrink + 15 "<PEAKLISTENERS>" 0 $bl] [shrink - 1 "</PEAKLISTENERS>" 0 $bl]]
set currentl [string range $bl [shrink + 18 "<CURRENTLISTENERS>" 0 $bl] [shrink - 1 "</CURRENTLISTENERS>" 0 $bl]]
set surl [string range $bl [shrink + 11 "<SERVERURL>" 0 $bl] [shrink - 1 "</SERVERURL>" 0 $bl]]
set maxl [string range $bl [shrink + 14 "<MAXLISTENERS>" 0 $bl] [shrink - 1 "</MAXLISTENERS>" 0 $bl]]
set bitrate [string range $bl [shrink + 9 "<BITRATE>" 0 $bl] [shrink - 1 "</BITRATE>" 0 $bl]]
set stitle [string range $bl [shrink + 13 "<SERVERTITLE>" 0 $bl] [shrink - 1 "</SERVERTITLE>" 0 $bl]]
set sgenre [string range $bl [shrink + 13 "<SERVERGENRE>" 0 $bl] [shrink - 1 "</SERVERGENRE>" 0 $bl]]
if {$sgenre != ""} {set sgenre " ($sgenre)"}
set avgtime [string range $bl [shrink + 13 "<AVERAGETIME>" 0 $bl] [shrink - 1 "</AVERAGETIME>" 0 $bl]]
set irc [string range $bl [shrink + 5 "<IRC>" 0 $bl] [shrink - 1 "</IRC>" 0 $bl]]
set icq [string range $bl [shrink + 5 "<ICQ>" 0 $bl] [shrink - 1 "</ICQ>" 0 $bl]]
if {$icq == 0} { set icq "N/A" }
set aim [string range $bl [shrink + 5 "<AIM>" 0 $bl] [shrink - 1 "</AIM>" 0 $bl]]
set webhits [string range $bl [shrink + 9 "<WEBHITS>" 0 $bl] [shrink - 1 "</WEBHITS>" 0 $bl]]
set streamhits [string range $bl [shrink + 12 "<STREAMHITS>" 0 $bl] [shrink - 1 "</STREAMHITS>" 0 $bl]]
set version [string range $bl [shrink + 9 "<VERSION>" 0 $bl] [shrink - 1 "</VERSION>" 0 $bl]]
if {$streamstatus == 1} {
if {[file exists dj]} {
set temp [open "dj" r]
set dj [gets $temp]
close $temp
} else { set dj "none" }
putserv "notice $target :$stitle$sgenre is online, running shoutcast $version and streaming at $bitrate kbps,  your dj is $dj. please visit $surl"
} else {
putserv "notice $target :$stitle$sgenre is currenty offline, running shoutcast $version and streaming at $bitrate kbps, check out $surl" }
putserv "notice $target :there are currently $repl unique people listening, the listener maximum is $maxl, our user peak was at $curhigh listeners."
putserv "notice $target :the average user is listening $avgtime seconds, our stream had $webhits webhits and $streamhits streamhits."
putserv "notice $target :you can contact the team by irc on $irc, via aim at $aim and with icq by the uin $icq."
}}
close $sock
}}


proc msg_scstat { nick uhost hand arg } { scstat $nick}
proc pub_scstat { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scstat $nick  }}


proc playing {target} {
global streamip streamport streampass dj
putlog "shoutcast: $target asked for current song"
if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0 } else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set streamstatus [string range $bl [shrink + 14 "<STREAMSTATUS>" 0 $bl] [shrink - 1 "</STREAMSTATUS>" 0 $bl]]
set songtitle [string range $bl [shrink + 11 "<SONGTITLE" 0 $bl] [shrink - 1 "</SONGTITLE>" 0 $bl]]
set songurl [string range $bl [shrink + 9 "<SONGURL>" 0 $bl] [shrink - 1 "</SONGURL>" 0 $bl]]
if {$songurl != ""} { set songurl " ($songurl)"}
regsub -all "&#x3C;" $songtitle "<" songtitle
regsub -all "&#x3E;" $songtitle ">" songtitle
regsub -all "&#x26;" $songtitle "+" songtitle  
regsub -all "&#x22;" $songtitle "\"" songtitle
regsub -all "&#x27;" $songtitle "'" songtitle
regsub -all "&#xFF;" $songtitle "" songtitle
regsub -all "&#xB4;" $songtitle "´" songtitle
regsub -all "&#x96;" $songtitle "-" songtitle
regsub -all "&#xF6;" $songtitle "ö" songtitle
regsub -all "&#xE4;" $songtitle "ä" songtitle
regsub -all "&#xFC;" $songtitle "ü" songtitle
regsub -all "&#xD6;" $songtitle "Ö" songtitle
regsub -all "&#xC4;" $songtitle "Ä" songtitle
regsub -all "&#xDC;" $songtitle "Ü" songtitle
regsub -all "&#xDF;" $songtitle "ß" songtitle

if {$streamstatus == 1} {
putserv "notice $target :Solutions Radio Now Playing $songtitle$songurl"
} else {
putserv "notice $target :server is currently offline, sorry"
}}}
close $sock
}}

proc msg_playing { nick uhost hand arg } { playing $nick}
proc pub_playing { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { playing $nick  }}



proc isonline { nick uhost hand chan arg } {
global radiochans announce tellusers tellsongs tellbitrate urltopic dj
global offlinetext offlinetopic onlinetext onlinetopic
global streamip streampass streamport dj
global doalertadmin alertadmin

if {$announce == 1 || $tellsongs == 1 || $tellusers == 1 || $tellbitrate == 1} {
set isonlinefile "isonline"
set oldisonline "isonline: 0"
set oldcurlist "curlist: 0"
set oldcurhigh "curhigh: 0"
set oldsong "cursong: 0"
set oldbitrate "bitrate: 0"
if {[file exists $isonlinefile]} {
putlog "shoutcast: checking if stream is online"
set temp [open "isonline" r]
while {[eof $temp] != 1} {
set zeile [gets $temp]
if {[string first "isonline:" $zeile] != -1 } { set oldisonline $zeile }
if {[string first "curlist:" $zeile] != -1 } { set oldcurlist $zeile }
if {[string first "curhigh:" $zeile] != -1 } { set oldcurhigh $zeile }
if {[string first "cursong:" $zeile] != -1 } { set oldsong $zeile }
if {[string first "bitrate:" $zeile] != -1 } { set oldbitrate $zeile }
}
close $temp
}


if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
putlog "error: $sockerror"
return 0} else {
puts $sock "GET /admin.cgi?pass=$streampass&mode=viewxml&page=0 HTTP/1.0"
puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
puts $sock "Host: $streamip"
puts $sock "Connection: close"
puts $sock ""
flush $sock
while {[eof $sock] != 1} {
set bl [gets $sock]
if { [string first "standalone" $bl] != -1 } {
set streamstatus "isonline: [string range $bl [shrink + 14 "<STREAMSTATUS>" 0 $bl] [shrink - 1 "</STREAMSTATUS>" 0 $bl]]"
set repl "curlist: [string range $bl [shrink + 19 "<REPORTEDLISTENERS>" 0 $bl] [shrink - 1 "</REPORTEDLISTENERS>" 0 $bl]]"
set curhigh "curhigh: [string range $bl [shrink + 15 "<PEAKLISTENERS>" 0 $bl] [shrink - 1 "</PEAKLISTENERS>" 0 $bl]]"
set currentl [string range $bl [shrink + 18 "<CURRENTLISTENERS>" 0 $bl] [shrink - 1 "</CURRENTLISTENERS>" 0 $bl]]
set surl "serverurl: [string range $bl [shrink + 11 "<SERVERURL>" 0 $bl] [shrink - 1 "</SERVERURL>" 0 $bl]]"
set cursong "cursong: [string range $bl [shrink + 11 "<SONGTITLE" 0 $bl] [shrink - 1 "</SONGTITLE>" 0 $bl]]"
set songurl [string range $bl [shrink + 9 "<SONGURL>" 0 $bl] [shrink - 1 "</SONGURL>" 0 $bl]]
set bitrate "bitrate: [string range $bl [shrink + 9 "<BITRATE>" 0 $bl] [shrink - 1 "</BITRATE>" 0 $bl]]"
set stitle "stitle: [string range $bl [shrink + 13 "<SERVERTITLE>" 0 $bl] [shrink - 1 "</SERVERTITLE>" 0 $bl]]"
set sgenre "sgenre: [string range $bl [shrink + 13 "<SERVERGENRE>" 0 $bl] [shrink - 1 "</SERVERGENRE>" 0 $bl]]"
}}
close $sock
}

set temp [open "isonline" w+]
puts $temp "$streamstatus\n$repl\n$curhigh\n$cursong\n$bitrate\n$stitle\n$sgenre\n$surl"
close $temp
if {$announce == 1 } {
if {$streamstatus == "isonline: 0" && $oldisonline == "isonline: 1"} {
	poststuff privmsg $offlinetext
	if {$doalertadmin == "1"} { sendnote domsen $alertadmin "radio is now offline" }
	if {$urltopic == 1} { poststuff topic $offlinetopic }
}
if {$streamstatus == "isonline: 1" && $oldisonline == "isonline: 0" } {
if {$sgenre != ""} {
set sgenre " ([lrange $sgenre 1 [llength $sgenre]] )"
}
poststuff privmsg "$onlinetext"
if {$urltopic == 1} { poststuff topic "$onlinetopic" }
}}
if {($tellusers == 1) && ($streamstatus == "isonline: 1") && ($oldcurhigh != "curhigh: 0") } {
if {$oldcurhigh != $curhigh} {
poststuff privmsg "new listener peak: [lindex $curhigh 1]"
}}
if {($tellsongs == 1) && ($oldsong != $cursong) && ($streamstatus == "isonline: 1") } {
if {$songurl != ""} { set songurl " ($songurl)"}
regsub -all "&#x3C;" $cursong "<" cursong
regsub -all "&#x3E;" $cursong ">" cursong
regsub -all "&#x26;" $cursong "+" cursong  
regsub -all "&#x22;" $cursong "\"" cursong
regsub -all "&#x27;" $cursong "'" cursong
regsub -all "&#xFF;" $cursong "" cursong
regsub -all "&#xB4;" $cursong "´" cursong
regsub -all "&#x96;" $cursong "-" cursong
regsub -all "&#xF6;" $cursong "ö" cursong
regsub -all "&#xE4;" $cursong "ä" cursong
regsub -all "&#xFC;" $cursong "ü" cursong
regsub -all "&#xD6;" $cursong "Ö" cursong
regsub -all "&#xC4;" $cursong "Ä" cursong
regsub -all "&#xDC;" $cursong "Ü" cursong
regsub -all "&#xDF;" $cursong "ß" cursong
putlog $cursong
poststuff privmsg "\00310np: [lrange $cursong 1 [llength $cursong]]$songurl ..:: Stream/128kbps/44kHz ::.."
}

if {($tellbitrate == 1) && ($oldbitrate != $bitrate) && ($streamstatus == "isonline: 1") && ($oldbitrate != "bitrate: 0")} {
poststuff privmsg "\0037Solutions Radio\00310 bitrate switched to \0039 [lindex $bitrate 1]kbps"
}}}

putlog "*** shoutcast.tcl v1.03 by domsen <domsen@domsen.org> succesfully loaded. turn it up baby."