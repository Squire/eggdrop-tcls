# chanrelay.tcl 3.0
#
# A way to link your channels
#
# Author: CrazyCat <crazycat@c-p-f.org>
# http://www.eggdrop.fr
# irc.zeolia.net #eggdrop

## DESCRIPTION ##
#
# This TCL is a complete relay script wich works with botnet.
# All you have to do is to include this tcl in all the eggdrop who
# are concerned by it.
#
# You can use it as a spy or a full duplex communication tool.
#
# It don't mind if the eggdrops are on the same server or not,
# it just mind about the channels and the handle of each eggdrop.

## CHANGELOG ##
#
# Complete modification of configuration
# Use of namespace
# No more broadcast, the relay is done with putbot

## TODO ##
#
# Enhance configuration
# Allow save of configuration
# Multi-languages

## CONFIGURATION ##
#
# For each eggdrop in the relay, you have to
# indicate his botnet nick, the chan and the network.
#
# Syntax:
# set regg(USERNAME) {
#	"chan"		"#CHANNEL"
#	"network"	"NETWORK"
#}
# with:
# USERNAME : The username sets in eggdrop.conf (case-sensitive)
# optionaly, you can override default values:
# * highlight (0/1/2): is speaker highlighted ?
# * snet (y/n): is speaker'network shown ?
# * transmit (y/n): does eggdrop transmit his channel activity ?
# * receive (y/n): does eggdrop diffuse other channels activity ?

namespace eval crelay {
    
    variable regg
    variable default
    
    set tegg(Axis) {
        "chan"		"#sharktech"
        "network"	"EFnet"
        "highlight"	0
        "log"		"y"
		"transmit"  "y"		
    }
    
    set regg(Aphex) {
        "chan"		"#sharktech"
        "network"	"AxisIRC"
    	"transmit"  "n"	
	}
    
    set default {
        "highlight"	1; # 0 : none, 1 : bold, 2 : underline
        "snet"		"y"
        "log"		"n"
	    }
    
    # transmission configuration
    set trans_pub "y"; # transmit the pub
    set trans_act "y"; # transmit the actions (/me)
    set trans_nick "y"; # transmit the nick changement
    set trans_join "y"; # transmit the join
    set trans_part "y"; # transmit the part
    set trans_quit "y"; # transmit the quit
    set trans_topic "y"; # transmit the topic changements
    set trans_kick "y"; # transmit the kicks
    set trans_mode "y"; #transmit the mode changements
    set trans_who "y"; # transmit the who list
    
    # reception configuration
    set recv_pub "y"; # recept the pub
    set recv_act "y"; # recept the actions (/me)
    set recv_nick "y"; # recept the nick changement
    set recv_join "y"; # recept the join
    set recv_part "y"; # recept the part
    set recv_quit "y"; # recept the quit
    set recv_topic "y"; # recept the topic changements
    set recv_kick "y"; # recept the kicks
    set recv_mode "y"; # recept the mode changements
    set recv_who "y"; # recept the who list
    
    variable author "CrazyCat"
    variable version "3.0"
}

####################################
#    DO NOT EDIT ANYTHING BELOW    #
####################################
proc ::crelay::init {args} {
    variable me
	
    array set me $::crelay::default
    array set me $::crelay::regg($::username)

    ::crelay::set:hl $me(highlight);
    
    if { $me(transmit) == "y" } {
        bind msg o|o "trans" ::crelay::set:trans
        if { $::crelay::trans_pub == "y" } { bind pubm - * ::crelay::trans:pub }
        if { $::crelay::trans_act == "y" } { bind ctcp - "ACTION" ::crelay::trans:act }
        if { $::crelay::trans_nick == "y" } { bind nick - * ::crelay::trans:nick }
        if { $::crelay::trans_join == "y" } { bind join - * ::crelay::trans:join }
        if { $::crelay::trans_part == "y" } { bind part - * ::crelay::trans:part }
        if { $::crelay::trans_quit == "y" } { bind sign - * ::crelay::trans:quit }
        if { $::crelay::trans_topic == "y" } { bind topc - * ::crelay::trans:topic }
        if { $::crelay::trans_kick == "y" } { bind kick - * ::crelay::trans:kick }
        if { $::crelay::trans_mode == "y" } { bind mode - * ::crelay::trans:mode }
        if { $::crelay::trans_who == "y" } { bind pub - "!who" ::crelay::trans:who }
    }
    
    if { $me(receive) =="y" } {
        bind msg o|o "recv" set:recv
        if { $::crelay::recv_pub == "y" } { bind bot - ">pub" ::crelay::recv:pub }
        if { $::crelay::recv_act == "y" } { bind bot - ">act" ::crelay::recv:act }
        if { $::crelay::recv_nick == "y" } { bind bot - ">nick" ::crelay::recv:nick }
        if { $::crelay::recv_join == "y" } { bind bot - ">join" ::crelay::recv:join }
        if { $::crelay::recv_part == "y" } { bind bot - ">part" ::crelay::recv:part }
        if { $::crelay::recv_quit == "y" } { bind bot - ">quit" ::crelay::recv:quit }
        if { $::crelay::recv_topic == "y" } { bind bot - ">topic" ::crelay::recv:topic }
        if { $::crelay::recv_kick == "y" } { bind bot - ">kick" ::crelay::recv:kick }
        if { $::crelay::recv_mode == "y" } { bind bot - ">mode" ::crelay::recv:mode }
        if { $::crelay::recv_who == "y" } {
            bind bot - ">who" ::crelay::recv:who
            bind bot - ">wholist" ::crelay::recv:wholist
        }
    }
    
    bind msg o|o "rc.status" crelay::help::status
    bind msg - "rc.help" crelay::help::cmds
    bind msg o|o "rc.light" crelay::set::light
    bind msg o|o "rc.net" crelay::set::snet
    
    variable eggdrops
    variable chans
    variable networks
    foreach bot [array names ::crelay::regg] {
	array set tmp $::crelay::regg($bot)
        lappend eggdrops $bot
        lappend chans $tmp(chan)
        lappend networks $tmp(network)
    }
    bind evnt -|- prerehash [namespace current]::deinit
    putlog "CHANRELAY $::crelay::version lauched"
}

proc ::crelay::deinit {args} {
    catch {unbind evnt -|- prerehash [namespace current]::deinit}
    catch {
        unbind msg o|o "trans" ::crelay::set:trans
        unbind pubm - * [namespace current]::trans:pub
	unbind ctcp - "ACTION" [namespace current]::trans:act
	unbind nick - * [namespace current]::trans:nick
	unbind join - * [namespace current]::trans:join
	unbind part - * [namespace current]::trans:part
	unbind sign - * [namespace current]::trans:quit
	unbind topc - * [namespace current]::trans:topic
	unbind kick - * [namespace current]::trans:kick
	unbind mode - * [namespace current]::trans:mode
	unbind pub - "!who" [namespace current]::trans:who
    }
    catch {
	unbind msg o|o "recv" set:recv
	unbind bot - ">pub" [namespace current]::recv:pub
	unbind bot - ">act" [namespace current]::recv:act
	unbind bot - ">nick" [namespace current]::recv:nick
	unbind bot - ">join" [namespace current]::recv:join
	unbind bot - ">part" [namespace current]::recv:part
	unbind bot - ">quit" [namespace current]::recv:quit
	unbind bot - ">topic" [namespace current]::recv:topic
	unbind bot - ">kick" [namespace current]::recv:kick
	unbind bot - ">mode" [namespace current]::recv:mode
	unbind bot - ">who" ::crelay::recv:who
	unbind bot - ">wholist" ::crelay::recv:wholist
    }
    catch {
	unbind msg o|o "rc.status" [namespace current]::help:status
	unbind msg - "rc.help" [namespace current]::help:cmds
	unbind msg o|o "rc.light" [namespace current]::set:light
	unbind msg o|o "rc.net" [namespace current]::set:snet
    }

    foreach child [namespace children] {
	catch {[set child]::deinit}
    }

    namespace delete [namespace current]
}

namespace eval crelay {
    variable hlnick
    variable snet

    # Setting of hlnick
    proc set:light { nick uhost handle arg } {
	# message binding
	switch $arg {
	    "bo" { ::crelay::set:hl 1; }
	    "un" { ::crelay::set:hl 2; }
	    "off" { ::crelay::set:hl 0; }
	    default { puthelp "NOTICE $nick :you must chose \002(bo)\002ld , \037(un)\037derline or (off)" }
	}
	return 0;
    }
    
    proc set:hl { arg } {
	# global hlnick setting function
	switch $arg {
	    1 { set ::crelay::hlnick "\002"; }
	    2 { set ::crelay::hlnick "\037"; }
	    default { set ::crelay::hlnick ""; }
	}
    }
    
    # Setting of show network
    proc set:snet {nick host handle arg } {
	if { $arg == "yes" } {
	    set ::crelay::snet "y"
	} elseif { $arg == "no" } {
	    set ::crelay::snet "n"
	} else { puthelp "NOTICE $nick :you must chose yes or no" }
    }
    
    # proc setting of transmission by msg
    proc set:trans { nick host handle arg } {
	if { $me(transmit) == "y" } {
	    if { $arg == "" } {
		putquick "NOTICE $nick :you'd better try /msg $::botnick trans help"
	    }
	    if { [lindex [split $arg] 0] == "help" } {
		putquick "NOTICE $nick :usage is /msg $::botnick trans <value> on|off"
		putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
		return 0
	    } else {
		set proc_change "[namespace current]::trans_[lindex [split $arg] 0]"
		switch [lindex [split $arg] 0] {
		    "pub" { set type pubm }
		    "act" { set type ctcp }
		    "nick" { set type nick }
		    "join" { set type join }
		    "part" { set type part }
		    "quit" { set type sign }
		    "topic" { set type topc }
		    "kick" { set type kick }
		    "mode" { set type mode }
		    "who" { set type who }
		}
		if { [lindex [split $arg] 1] == "on" } {
		    bind $type - * $proc_change
		} elseif { [lindex [split $arg] 1] == "off" } {
		    unbind $type - * $proc_change
		} else {
		    putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
		}
	    }
	} else {
	    putquick "NOTICE $nick :transmission is not activated, you can't change anything"
	}
    }
    
    # proc setting of reception by msg
    proc set:recv { nick host handle arg } {
	if { $me(receive) == "y" } {
	    if { $arg == "" } {
		putquick "NOTICE $nick :you'd better try /msg $::botnick recv help"
	    }
	    if { [lindex [split $arg] 0] == "help" } {
		putquick "NOTICE $nick :usage is /msg $::botnick recv <value> on|off"
		putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
		return 0
	    } else {
		set change ">[lindex [split $arg] 0]"
		set proc_change "[namespace current]::recv_[lindex [split $arg] 0]"
		if { [lindex [split $arg] 1] == "on" } {
		    bind  bot - $change $proc_change
		} elseif { [lindex [split $arg] 1] == "off" } {
		    unbind bot - $change $proc_change
		} else {
		    putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
		}
	    }
	} else {
	    putquick "NOTICE $nick :reception is not activated, you can't change anything"
	}
    }
    
    # Generates an user@network name
    # based on nick and from bot
    proc make:user { nick frm_bot } {
	    array set him $::crelay::regg($frm_bot)
        if { $::crelay::me(snet) == "y" } {
            set speaker [concat "$::crelay::hlnick\($nick@$him(network)\)$::crelay::hlnick"]
        } else {
            set speaker $::crelay::hlnick$nick$::crelay::hlnick
        }
        return $speaker
    }
    
    # Logs virtual channel activity 
    proc cr:log { lev chan line } {
	if { $::crelay::me(log) == "y" } {
	    putloglev $lev "$chan" "$line"
    	}
        return 0
    }
    
    # Global transmit procedure
    proc trans:bot { usercmd chan usernick text } {
        set transmsg [concat $usercmd $usernick $text]
        if {$chan == $::crelay::me(chan)} {
            foreach bot [array names ::crelay::regg] {
	            if {$bot != $::botnick} {
                	putbot $bot $transmsg
            	}
            }
        } else {
            return 0
        }
    }

    # proc transmission of pub (trans_pub = y)
    proc trans:pub {nick uhost hand chan text} {
        if { [string tolower [lindex [split $text] 0]] == "!who" } { return 0; }
        trans:bot ">pub" $chan $nick [join [split $text]]
    }
    
    # proc transmission of action (trans_act = y)
    proc trans:act {nick uhost hand chan key text} {
        set arg [concat $key $text]
        trans:bot ">act" $chan $nick $arg
    }
    
    # proc transmission of nick changement
    proc trans:nick {nick uhost hand chan newnick} {
        trans:bot ">nick" $chan $nick $newnick
    }
    
    # proc transmission of join
    proc trans:join {nick uhost hand chan} {
        trans:bot ">join" $chan $chan $nick
    }
    
    # proc transmission of part
    proc trans:part {nick uhost hand chan text} {
        set arg [concat $chan $text]
        trans:bot ">part" $chan $nick $arg
    }
    
    # proc transmission of quit
    proc trans:quit {nick host hand chan text} {
        trans:bot ">quit" $chan $nick $text
    }
    
    # proc transmission of topic changement
    proc trans:topic {nick uhost hand chan topic} {
        set arg [concat $chan $topic]
        trans:bot ">topic" $chan $nick $arg
    }
    
    # proc transmission of kick
    proc trans:kick {nick uhost hand chan victim reason} {
        set arg [concat $victim $chan $reason]
        trans:bot ">kick" $chan $nick $arg
    }
    
    # proc transmission of mode changement
    proc trans:mode {nick uhost hand chan mc {victim ""}} {
        if {$victim != ""} {append mc " $victim" }
        set text [concat $nick $chan $mc]
        trans:bot ">mode" $chan $nick $text
    }
    
    # proc transmission of "who command"
    proc trans:who {nick uhost handle chan args} {
        if { [lindex [split $args] 1] != "" } {
            set him [lsearch -nocase $::crelay::networks [lindex [split $args] 1]]
            if { $him == -1 } {
                putserv "PRIVMSG $nick :$args est un réseau inconnu";
                return 0
            } else {
                putbot [lindex $::crelay::eggdrops $him] ">who" $chan $nick
            }
        } else {
            trans:bot ">who" $chan $nick ""
        }
    }

    # proc reception of pub
    proc recv:pub {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :$speaker> [join [lrange $argl 1 end]]"
            cr:log p "$::crelay::me(chan)" "<[lindex $argl 0]> [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of action
    proc recv:act {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :* $speaker [join [lrange $argl 2 end]]"
            cr:log p "$::crelay::me(chan)" "Action: [join [lrange $argl 0 end]]"
        }
        return 0
    }
    
    # proc reception of nick changement
    proc recv:nick {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker is now known as [join [lrange $argl 1 end]]"
            cr:log j "$::crelay::me(chan)" "Nick change: [lindex $argl 0] -> [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of join
    proc recv:join {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 1] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :--> $speaker has joined channel [lindex $argl 0]"
            cr:log j "$::crelay::me(chan)" "[lindex $argl 1] joined $::crelay::me(chan)."
        }
        return 0
    }
    
    # proc reception of part
    proc recv:part {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :<-- $speaker has left channel [lindex $argl 1] ([join [lrange $argl 2 end]])"
            cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left $::crelay::me(chan) ([join [lrange $argl 2 end]])"
        }
        return 0
    }
    
    # proc reception of quit
    proc recv:quit {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :-//- $speaker has quit ([join [lrange $argl 1 end]])"
            cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left irc: [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of topic changement
    proc recv:topic {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker changes topic of [lindex $argl 1] to '[join [lrange $argl 2 end]]'"
        }
        return 0
    }
    
    # proc reception of kick
    proc recv:kick {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 2] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker has been kicked from [lindex $argl 2] by [lindex $argl 0]: [join [lrange $argl 3 end]]"
            cr:log k "$::crelay::me(chan)" "[lindex $argl 1] kicked from $::crelay::me(chan) by [lindex $argl 0]:[join [lrange $argl 3 end]]"
        }
        return 0
    }
    
    # proc reception of mode changement
    proc recv:mode {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [make:user [lindex $argl 1] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker set mode [join [lrange $argl 2 end]]"
        }
        return 0
    }
    
    # reception of !who command
    proc recv:who {frm_bot command arg} {
        set nick $arg
        set ulist ""
        set cusr 0
        foreach user [chanlist $::crelay::me(chan)] {
            if { $user == $::botnick } { continue; }
            if { [isop $user $::crelay::me(chan)] == 1 } {
                set st "@"
            } elseif { [ishalfop $user $::crelay::me(chan)] == 1 } {
                set st "%"
            } elseif { [isvoice $user $::crelay::me(chan)] == 1 } {
                set st "%"
            } else {
                set st ""
            }
            incr cusr 1
            append ulist " $st$user"
            if { $cusr == 5 } {
                putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
                set ulist ""
                set cusr 0
            }
        }
        if { $ulist != "" } {
            putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
        }
    }
    
    # Proc reception of a who list
    proc recv:wholist {frm_bot command arg} {
        set nick [join [lindex [split $arg] 1]]
        set speaker [make:user $frm_bot $frm_bot]
        putserv "NOTICE $nick :$speaker [join [lrange [split $arg] 2 end]]"
    }
    
    
    ######################################
    # Private messaging
    #
    
    bind msg - "say" prv:say_send
    proc prv:say_send {nick uhost handle text} {
        set dest [join [lindex [split $text] 0]]
        set msg [join [lrange [split $text] 1 end]]
        set vict [join [lindex [split $dest @] 0]]
        set net [join [lindex [split $dest @] 1]]
        if { $vict == "" || $net == "" } {
            putserv "PRIVMSG $nick :Use \002!say user@network your message to \037user\037\002";
            return 0
        }
        set him [lsearch -nocase $::crelay::networks $net]
        if { $him == -1 } {
            putserv "PRIVMSG $nick :I don't know any network called $net.";
	    putserv "PRIVMSG $nick :Available networks: [join [split $::crelay::networks]]"
            return 0
        }
        if { [string length $msg] == 0 } {
            putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
            return 0
        }
        putbot [lindex $::crelay::eggdrops $him] ">pvmsg $vict $nick@$::crelay::me(network) $msg"
    }
    
    bind bot - ">pvmsg" prv:say_get
    proc prv:say_get {frm_bot command arg} {
        set dest [join [lindex [split $arg] 0]]
        set from [join [lindex [split $arg] 1]]
        set msg [join [lrange [split $arg] 2 end]]
        if { [onchan $dest $::crelay::me(chan)] == 1 } {
            putserv "PRIVMSG $dest :$from: $msg"
        }
    }

    ######################################
    # proc for helping
    #
    
    # proc status
    proc help:status { nick host handle arg } {
	    putquick "PRIVMSG $nick :Chanrelay status for $::crelay::me(chan)@$crelay::me(network)"
	putquick "PRIVMSG $nick :\002 Global status\002"
	putquick "PRIVMSG $nick :\037type\037   -- | trans -|- recept |"
	putquick "PRIVMSG $nick :global -- | -- $me(transmit) -- | -- $me(receive) -- |"
	putquick "PRIVMSG $nick :pub    -- | -- $::crelay::trans_pub -- | -- $::recv_pub -- |"
	putquick "PRIVMSG $nick :act    -- | -- $::crelay::trans_act -- | -- $::recv_act -- |"
	putquick "PRIVMSG $nick :nick   -- | -- $::crelay::trans_nick -- | -- $::recv_nick -- |"
	putquick "PRIVMSG $nick :join   -- | -- $::crelay::trans_join -- | -- $::recv_join -- |"
	putquick "PRIVMSG $nick :part   -- | -- $::crelay::trans_part -- | -- $::recv_part -- |"
	putquick "PRIVMSG $nick :quit   -- | -- $::crelay::trans_quit -- | -- $::recv_quit -- |"
	putquick "PRIVMSG $nick :topic  -- | -- $::crelay::trans_topic -- | -- $::recv_topic -- |"
	putquick "PRIVMSG $nick :kick   -- | -- $::crelay::trans_kick -- | -- $::recv_kick -- |"
	putquick "PRIVMSG $nick :mode   -- | -- $::crelay::trans_mode -- | -- $::recv_mode -- |"
	putquick "PRIVMSG $nick :who   -- | -- $::crelay::trans_who -- | -- $::recv_who -- |"
	putquick "PRIVMSG $nick :nicks appears as $::crelay::hlnick$nick$::crelay::hlnick"
	putquick "PRIVMSG $nick :\002 END of STATUS"
    }
        
    # proc help
    proc help:cmds { nick host handle arg } {
	putquick "NOTICE $nick :/msg $::botnick trans <type> on|off to change the transmissions"
	putquick "NOTICE $nick :/msg $::botnick recv <type> on|off to change the receptions"
	putquick "NOTICE $nick :/msg $::botnick rc.status to see my actual status"
	putquick "NOTICE $nick :/msg $::botnick rc.help for this help"
	putquick "NOTICE $nick :/msg $::botnick rc.light <bo|un|off> to bold, underline or no higlight"
	putquick "NOTICE $nick :/msg $::botnick rc.net <yes|no> to show the network"
    }
    
}

::crelay::init

putlog "CHANRELAY $::crelay::version by \002$::crelay::author\002 loaded - http://www.eggdrop.fr"