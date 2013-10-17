#################################################
# clink.tcl Channel Linker v1.2
# Written by {SImPhAt}, May 6th 2002
#
# This script lets you link channels (as many as you
# like) on different (or same) IRC Networks using 2 or
# more eggdrops.
#
# Messages are sent in a botnet-link connection.
#
# Easy to configure.
#
# Join, Part, Nick change, Quit, Kick, Msgs and 
# Actions (/me) are currently relayed.
#
# Tested on eggdrop v1.6.x (3 bots) relaying between 3
# different channels.
#
# E-mail questions or comments to simon.boulet@divahost.net.
# I'd like to know who is using my script and where, just to
# see it live in action =).
#
# Changes since 1.0:
#	1) Linking of channels that do not have the same name
#	   (ex: linking #help with #help.quebec-chat)
#	2) Spelling correction in "nick as joined #chan" should be has
#	3) Stupid bug showing empty () on kick/part/quit with no reason
#	4) Tested everything with 3 channels/networks/bots.
#
# TODO:
#	1) Flood protection.
#	2) List current nicks on the linked side (.names).
#	3) Remote topic change, kick/ban, op.
#
#################################################
# Configuration
#################################################
#
# Note: I was relaying #clink.qc(Quebec-Chat) #clink.io(Ionical) and
# #clink.un(Undernet) all together (those 3 eggdrops where using the
# same .tcl source).
#
# CLink-QC on Quebec-Chat, CLink-IO on Ionical and CLink-UN on Undernet.
#
# Nickname (botnet-nick) of the bots who are involved in the relaying.
# Enter all of them, case-sensitive.
#
set clink_botnicks {"Aphex" "Axis"}
#
# The channel(s) you want to relay messages from and the bot that is on.
#
# You need to "set network 'Network-Name'" in your bot(s) .conf file.
# If you don't want to waste time searching what you put there, simply
# .rehash your bot with clink.tcl loaded and you should see something like:
#
# clink.tcl: I am CLink-UN running on Undernet.
# --- Network-Name -------------------^^^^^^^^
# Loaded clink.tcl: {SImPhAt} Channel Linker v1.x
#
# Case-sensitive.
#
# Syntax: set clink_onchan(#chan@network) "bot-name"
set clink_onchan(#sharktech@AxisIRC) "Aphex"
set clink_onchan(#sharktech@EFnet) "Axis"
#
# The channel(s) where you want the messages to be relayed.
#
# For each channels you need to tell where you want everything
# to be sent to.
#
# Case-sensitive.
#
# Syntax: set clink_relayto(#from_chan@network1) {"#destination_chan@network2"}
set clink_relayto{"#sharktech@EFnet" "#sharktech@AxisIRC"}
set clink_relayto{"#sharktech@AxisIRC" "#sharktech@EFnet"}
#
# Should we add colors to join, part, nick, quit,
# action, etc.
#
set clink_usecolor 0
#
# Do you want me to display the network name?
#
set clink_relaynet 0
#
# Characters to use when displaying the nicknames in channels msgs.
#
# Exemples:
# <Nickname> hello
# set clink_charmsgs {"<" ">"}
#
# (Nickname) hello
set clink_charmsgs {"(" ")"}
#
#################################################
# Script, you should *not* need to change
# anything below.
#################################################
bind pubm - * clink_chanpubm
bind nick - * clink_channick
bind sign - * clink_chanquit
bind kick - * clink_chankick
bind join - * clink_chanjoin
bind part - * clink_chanpart
bind ctcp - "ACTION" clink_chanacti 
bind bot - clink clink_botdat

# Colors settings (Default: mIRC style)
if {$clink_usecolor == 1} {
	set clink_color(pubm) ""
	set clink_color(nick) "\0033"
	set clink_color(quit) "\0032"
	set clink_color(kick) "\0033"
	set clink_color(join) "\0033"
	set clink_color(part) "\0033"
	set clink_color(acti) "\0036"
} else {
        set clink_color(pubm) ""
        set clink_color(nick) ""
        set clink_color(quit) ""
        set clink_color(kick) ""
        set clink_color(join) ""
        set clink_color(part) ""
        set clink_color(acti) ""
}
# Done

# Check current configuration
if {${botnet-nick} == ""} {
	set {botnet-nick} $nick
	putlog "clink.tcl: Warning: botnet-nick not defined in .conf file, using \"$nick\"."
}
if {[lsearch $clink_botnicks ${botnet-nick}] == -1} {
	die "clink.tcl: Fatal: Bot \"${botnet-nick}\" not defined in clink_botnicks. Please edit clink.tcl and check your configuration."
}
if {$network == "unknown-net"} {
	putlog "clink.tcl: Warning: network not defined in .conf file, using \"unknown-net\"."
}
# Done

proc clink_botsend {chan param} {
	global clink_onchan {botnet-nick} network clink_relayto
	foreach clink_relaychan $clink_relayto($chan@$network) {
		if {[lsearch -exact [bots] $clink_onchan($clink_relaychan)] == -1} {
			putlog "clink.tcl: Warning: bot $clink_onchan($clink_relaychan) not linked."
		} else {
			putbot $clink_onchan($clink_relaychan) "clink $chan $network $param"
		}
	}
}
proc clink_chanpubm {nick uhost hand chan text} {
	global clink_onchan network
	if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "pubm" [clink_cleannick $nick] $text]
	}
}
proc clink_channick {nick uhost hand chan newnick} {
        global clink_onchan network
        if {[info exist clink_onchan($chan@network)]} {
		clink_botsend $chan [concat "nick" [clink_cleannick $nick] [clink_cleannick $newnick]]
	}
}
proc clink_chanquit {nick uhost hand chan reason} {
        global clink_onchan network
        if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "quit" [clink_cleannick $nick] $uhost $reason]
	}
}
proc clink_chankick {nick uhost hand chan knick reason} {
	global clink_onchan network
	if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "kick" [clink_cleannick $nick] [clink_cleannick $knick] $reason]
	}
}
proc clink_chanjoin {nick uhost hand chan} {
        global clink_onchan network
        if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "join" [clink_cleannick $nick] $uhost]
	}
}
proc clink_chanpart {nick uhost hand chan reason} {
        global clink_onchan network
        if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "part" [clink_cleannick $nick] $uhost $reason]
	}
}
proc clink_chanacti {nick uhost hand chan action text} {
        global clink_onchan network
	if {[info exist clink_onchan($chan@$network)]} {
		clink_botsend $chan [concat "acti" [clink_cleannick $nick] $action $text]
	}
}
proc clink_botdat {bot clink param} {
	global clink_relaynet clink_color clink_charmsgs clink_relayto network
	if {$clink_relaynet == 1} {
		set clink_network "\[[lindex $param 1]\] "
	} else {
		set clink_network ""
	}
	if {[lrange $param 5 end] != ""} {
		set reason "\([lrange $param 5 end]\)"
	} else {
		set reason ""
	}
	set clink_destchan [lindex [split [lindex $clink_relayto([lindex $param 0]@[lindex $param 1]) [lsearch -glob $clink_relayto([lindex $param 0]@[lindex $param 1]) "*@$network"]] @] 0]
	switch [lindex $param 2] {
		pubm	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(pubm)[lindex $clink_charmsgs 0][lindex $param 3][lindex $clink_charmsgs 1] [lrange $param 4 end]" }
		nick	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(nick)*** [lindex $param 3] is now known as [lindex $param 4]" }
		quit	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(quit)*** [lindex $param 3] \([lindex $param 4]\) Quit $reason" }
		kick	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(kick)*** [lindex $param 4] was kicked by [lindex $param 3] $reason" }
		join	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(join)*** [lindex $param 3] \([lindex $param 4]\) has joined [lindex $param 0]" }
		part	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(part)*** [lindex $param 3] \([lindex $param 4]\) has left [lindex $param 0] $reason" }
		acti	{ putserv "PRIVMSG $clink_destchan :$clink_network$clink_color(acti)* [lindex $param 3] [lrange $param 5 end]" }
		default { putlog "clink.tcl: Warning: unknown action type \"[lindex $param 2]\" for [lindex $param 0]." }
	}
}
proc clink_cleannick {nick} {
	if {[string range $nick 0 0] == "\{"} {
		set nick "\\$nick"
	}
        return $nick
}
putlog "clink.tcl: I am ${botnet-nick} running on $network."
putlog "Loaded clink.tcl: {SImPhAt} Channel Linker v1.2"
