# Add ChanServ and NickServ as a bot on the eggdrops userlist.

# Change the password
set np "********"
bind notc - "*This nickname is registered*" id-bot
proc id-bot {nick uhost handle text {dest ""}} {
    global np  botnick
if {[string tolower $nick] == [string tolower "nickserv"]} {
if {$dest==""} { set dest $botnick }
    putserv "PRIVMSG NickServ :identify $np"
    }
 return 0
}

#bind notc - "*You are now identified*" OpAll
#	proc OpAll {nick uhost handle text {dest ""}} {
#	global botnick 
#if {[string tolower $nick] == [string tolower "nickserv"]} {
#if {$dest==""} { set dest $botnick }
#	putserv "PRIVMSG ChanServ :Op #lounge $botnick"
#	putserv "PRIVMSG ChanServ :Op #pyrexhosting $botnick"	
#	}
# return 0
#}
