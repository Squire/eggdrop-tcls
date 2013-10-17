## -----------------------------------------------------------------------
##     The Real Multiusable script v2.9b4+FIX (C)2000 OUTsiders WORLD
## -----------------------------------------------------------------------
## Contacting:
## OUTsider@undernet (irc.undernet.org)
## outsider@key2peace.org
## SMS@+31627231098

## ----------------------------------------------------------------
## Set global variables
## ----------------------------------------------------------------
set scriptversion "v2.9b4+FIX"
set home "#snoop"
set password "ddpludo"
set emailbot "$botnick@yourservice.org"
set service "*******"
set rnconf "$username.rn"

## ----------------------------------------------------------------
## OptionPack (Remove the ## to enable loading. Be sure to put em 
##       in your scripts directory and specify the correct path!)
## ----------------------------------------------------------------
# source scripts/multi.opmod ; #OperServ module
# source scripts/multi.csmod ; #ChanServ module
# source scripts/multi.lsmod ; #LoadSave module

## ----------------------------------------------------------------
## Specific Settings related to notify system.
## ----------------------------------------------------------------
set notnotify "0" ; #Send notice with eggs internal Note System.

## ----------------------------------------------------------------
## --- Don't change anything below here if you don't know how ! ---
## ----------------------------------------------------------------
bind pub - $botnick pub_cd
bind pub - $shortnick pub_cd
bind pub o *** pub_cd
bind pub - !shortnick pub_shortie
bind pub m !notify pub_chanownnote
bind ctcr - PING ping_me_reply
bind msg - login msg_login
bind msg - logoff msg_logout
bind notc - "*nickname is registered*" nickident
bind notc - "*nick is owned by someone else*" nickident
bind notc - "*seconds to identify or change*" nickident
bind notc - "*you for registering. Your initial password is set to*" nickPident
bind dcc m flagnote dcc_flagnote
bind part Q * part_deauth
bind sign Q * sign_deauth
bind bot - $service botnet_proc
bind kick - * prot_kick
bind mode - *-o* prot_deop
bind topc - * topic_check
bind join - * welcomer
bind nick Q * nick_change
bind raw - 311 multi:getrn

if { $numversion <= "1040000" } {
putlog "WARNING ! Some options will not work using this version of eggdrop !"}

if {![file exists $rnconf]} {
 set fd [open $rnconf w]
 puts $fd "#RealBan Conf Multi $scriptversion - created "
 close $fd
}

proc do_channels {} {
 foreach a [channels] {
 if {![info exists topicinfo(locked$a)]} { set topicinfo(locked$a) 0 }
 if {![info exists topicinfo(ltopic$a)]} { set topicinfo(ltopic$a) "" }
 if {![info exists topicinfo(lwho$a)]} { set topicinfo(lwho$a) "" }
 if {![info exists topicinfo(vchan$a)]} { set topicinfo(vchan$a) "" }}
 utimer 30 do_channels}

do_channels

proc botnet_proc {bot cmd args} {
 global home service
 set chans [channels]
 set args [lindex $args 0]
 set blah [lindex $args 0]
 switch -exact $blah {
   "banner" { foreach chn $chans {
	      putserv "PRIVMSG $chn :Global [lrange $args 2 end] [lindex $args 1]" }}
"blacklist" { set ban [lindex [lrange $args 2 end] 0]
	      set res [lrange [lrange $args 2 end] 1 end]
	      putserv "PRIVMSG $home :Blacklist received from [lindex $args 1]: [lrange $args 2 end]"
	      newban $ban [lindex $args 1] [lrange $args 2 end] 
              set fd [open blacklist.dat a]
              puts $fd "Host: $ban from [lindex $args 1] : $res"
              close $fd }
"whitelist" { set ban [lindex [lrange $args 2 end] 0]
	      set res [lrange [lrange $args 2 end] 1 end]
	      putserv "PRIVMSG $home :Blacklist remove received from [lindex $args 1]: [lrange $args 2 end]"
	      killban $ban}
  "rehash"  { putserv "PRIVMSG $home :Global rehash received from $bot"
	      foreach timer [timers] {killtimer [lindex $timer 2]}
              rehash }
    "save"  { putserv "PRIVMSG $home :Global save received from $bot"
	      save }}}

proc sign_deauth {nick uhost hand chan rest} { 
 if {[getuser $hand XTRA SECNICK] == $nick} {
 chattr $hand -Q
 setuser $hand XTRA SECNICK ""
 setuser $hand XTRA SECHOST ""}}

proc nick_change {nick uhost hand chan rest} { 
 if {[getuser $hand XTRA SECNICK] == $nick} {
 setuser $hand XTRA SECNICK "$rest" }}

proc part_deauth {nick uhost hand chan args} {
 foreach chanl [channels] {
 if {[onchan $nick $chanl]} {
 return 0 }
 if {[getuser $hand XTRA SECNICK] == $nick} {
 chattr $hand -Q
 setuser $hand XTRA SECNICK ""
 setuser $hand XTRA SECHOST ""
 putserv "NOTICE $nick :You have been deauthed."
}}}

proc msg_login {nick uhost hand rest} {
 global botnick
 set pw [lindex $rest 0]
 set op [lindex $rest 1]
 if {$pw == ""} {
 putserv "NOTICE $nick :Usage: /msg $botnick login <password> \[recover\]"
 return 0 }
 if {[matchattr $hand Q]} {
 if {[string tolower $op] == "recover"} {
 if {[passwdok $hand $pw]} {
 setuser $hand XTRA SECNICK $nick
 setuser $hand XTRA SECHOST $uhost
 putserv "NOTICE $nick :New Identity confirmed. Recover Successful" }
 if {![passwdok $hand $pw]} {
 putserv "NOTICE $nick :Wrong password. Recover failed !"
 return 0 }
 return 0 }
 putserv "NOTICE $nick :You are already Authenticated."
 putserv "NOTICE $nick :Nick: [getuser $hand XTRA SECNICK]"
 putserv "NOTICE $nick :Host: [getuser $hand XTRA SECHOST]"
 putserv "NOTICE $nick :Try to login with /msg $botnick login <pass> recover"
 return 0 }
 if {[passwdok $hand $pw] == 1} {
 chattr $hand +Q
 putserv "NOTICE $nick :Authentication successful!"
 setuser $hand XTRA SECNICK $nick
 setuser $hand XTRA SECHOST $uhost }
 if {[passwdok $hand $pw] == 0} {
 putserv "NOTICE $nick :Authentication failed!" }}

proc msg_logout {nick uhost hand rest} {
 if {[getuser $hand XTRA SECNICK] == $nick} {
 chattr $hand -Q
 setuser $hand XTRA SECNICK $nick
 setuser $hand XTRA SECHOST $nick
 putserv "NOTICE $nick :DeAuthentication successful!" }}

proc nickident { nick uhost hand text blah } { 
 global home password network botnick
 if {[string tolower $network] == "galaxynet"} {
 putserv "PRIVMSG NS@services.galaxynet.org :AUTH $botnick Glx2serv"
 putserv "PRIVMSG $home :Identifying to NS..."
 return 0}
 if {[string tolower $network] == "irc-chat" || [string tolower $network] == "webchat"} {
 putserv "NICKSERV identify $password"
 putserv "PRIVMSG $home :Identifying to NickServ..."
 return 0}
 putserv "PRIVMSG nickserv :identify $password"
 putserv "PRIVMSG nickop@austnet.org :identify $password"
 putserv "PRIVMSG $home :Identifying to NickServ..."}

proc nickPident { nick uhost hand text blah } {
 global home password network botnick
 if {[string tolower $network] == "planetarion"} {
 if {$nick != "P"} {return 0}
 putserv "PRIVMSG P :AUTH $botnick [lindex $text 10]"
 putserv "PRIVMSG P :NEWPASS $password $password"
 return 0}
}

proc ping_me_reply {nick uhost hand dest key arg} {
 set dur [expr [unixtime] - $arg]
 puthelp "NOTICE $nick :Your ping reply took $dur seconds"
 return 0}

proc pub_shortie {nick host handle channel var} {
 global shortnick botnick
 putserv "NOTICE $nick :I respond to $shortnick and $botnick"
 return 1}

proc dcc_flagnote {handle command arg} {
 set notes 0
 set toflag [lindex $arg 0]
 set msg [lrange $arg 1 end]
 if {[string index $toflag 0] == "+"} {
 set toflag [string index $toflag 1]
 if {$toflag == "b"} {
 putidx $command "You really think bot read notes ?"
 return 0 }}
 if {$toflag == "" || ($msg == "")} {
 putidx $command "Usage: .flagnote <flag> <message>"
 return 0 }
 putcmdlog "#$handle# flagnote +$toflag ..."
 foreach user [userlist] {
 if {![matchattr $user b] && [matchattr $user $toflag] && $user != $handle} {
 sendnote $handle $user "\[\002+$toflag\002\] :$msg"
 incr notes }}
 if {$notes == 0} {set notestring "no notes"}
 if {$notes == 1} {set notestring "1 note "}
 if {$notes >= 2} {set notestring "$notes notes have been"}
 putidx $command "Done... $notestring delivered!"}

proc pub_chanownnote {nick host handle chan args} {
 global botnick
 set arg [lindex $args 0]
 set toflag [lindex $arg 0]
 set msg [lrange $arg 1 end]
 if {[validchan $toflag]} { 
 putcmdlog "#$handle# chanownnote $toflag ..."
 foreach user [userlist |n $toflag] {
 sendnote $handle $user "\[\002+$toflag\002\] :$msg" }
 putserv "NOTICE $nick :Note to chanowner of $toflag delivered"}}

proc pub_cd {nick host handle channel var} {
 global network botname server version botnick ver home scriptversion shortnick emailbot password topicinfo service rnconf rnnick
 set cmd [string tolower [lindex $var 0]]
 set who [string tolower [lindex $var 1]]
 set oldwho [lindex $var 1]
 switch $cmd {
 operlist { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
            putserv "NOTICE $nick :Opers spotted by this bot:"
            foreach oper [userlist +O] {
             set lastontime [ctime [lindex [getuser $oper LASTON] 0]]
             set lastonchan [lindex [getuser $oper LASTON] 1]
             putserv "NOTICE $nick : Nick: $oper \[[getuser $oper HOSTS]\] Last seen: $lastontime on $lastonchan"
            }}}
 nickserv { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    
            if {[string tolower $network] == "webchat"} {
            putserv "NickServ :register $password $emailbot"
            putserv "PRIVMSG $home :Registering at NickServ..."
            return 0}
 
            if {[string tolower $network] == "planetarion"} {
            putserv "PRIVMSG P :hello"
            putserv "PRIVMSG $home :Registering at P..."
            return 0}
            
            if {[string tolower $network] == "galaxynet"} {
            putserv "PRIVMSG NS :register Glx2serv $emailbot"
            putserv "PRIVMSG $home :Registering at NS..."
            return 0}
            
            if {[string tolower $network] == "irc-chat"} {
            putserv "NICKSERV register $password $emailbot"
            putserv "PRIVMSG $home :Registering at NickServ..."
            return 0}
            
            putserv "PRIVMSG nickserv :register $password"
	    putserv "PRIVMSG nickop@austnet.org :register $password $emailbot"
	    putserv "NOTICE $nick :Registered myself to NickServ"
	    putserv "PRIVMSG $home :Registering to NickServ..." }}
     nick { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lindex $var 2]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: nick <nickname> <shortnick>"
	    return 0 }
	    if {$why == ""} {
	    putserv "NICK $oldwho" } else {
	    putserv "NICK $oldwho"
	    set shortnick $why }
	    putserv "NOTICE $nick :Nick changed to $who and shortnick now is $shortnick" }}
     lock { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: lock <channel>"
	    return 0 }
	    putserv "NOTICE $nick :Locking the channel $who."
	    putserv "PRIVMSG $who :!!! WARNING: Channel will be locked !!!"
	    channel set $who chanmode "+stnmi"  
	    set dorks [chanlist $who]
	    foreach p $dorks {
	    set victim [nick2hand $p $who]
	    if {![matchattr $p o] && $p != $botnick} {
	    putserv "KICK $who $p :This channel has been locked"
	    chattr $p |-o $who }}
	    putserv "TOPIC $channel :Channel locked. Contact dreamweaver@cosnet.co.nz or socks@mintsock.com for details"
	    putserv "PRIVMSG $home :$nick made me lock channel $who" 
            servicenote "$handle locked $who"}}
     jump { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: jump <server>"
	    return 0 }
	    putserv "NOTICE $nick :Jumping to $who"
	    jump $who
            servicenote "$handle made me jump to $who" }}
      die { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set who [lrange $var 1 end]
	    die $who }}
  gchattr { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
            set why [lindex $var 2]
            if {$who == ""} {
            putserv "NOTICE $nick :Usage: gchattr <Changer Persons attributes.>"
            return 0 }
            chattr [nick2hand $who $channel] $why
            putserv "NOTICE $nick :Added global attribute $why to $who."
            putserv "PRIVMSG $home :$nick made me change $who's global attributes to $why."
            return 1 }}
   chattr { if {[matchattr $handle &n channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lindex $var 2]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: chattr <Changer Persons attributes.>"
	    return 0 }
	    chattr [nick2hand $who $channel] |$why $channel
	    putserv "NOTICE $nick :Added attribute $why to $who on $channel."
	    putserv "PRIVMSG $home :$nick made me change $who's attributes to $why on $channel."
	    putserv "NOTICE $who :$nick changed your attributes on $channel to $why on $channel."
	    return 1 }}
   rehash { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    putserv "NOTICE $nick :Rehashing"
	    putserv "PRIVMSG $home :$nick made me rehash"
	    foreach timer [timers] {killtimer [lindex $timer 2]}
            rehash }}
  restart { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    putserv "NOTICE $nick :Restarting"
	    putserv "PRIVMSG $home :$nick made me restart"
	    restart }}
   banner { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: banner <message>"
	    return 0 }
	    putserv "NOTICE $nick :Sent banner: $why"
            foreach chn [channels] {
            putserv "PRIVMSG $chn :GLOBAL $why \[$nick\]" }
	    putallbots "$service banner $nick $why" }}
rehashall { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    putserv "NOTICE $nick :Rehashing all bots"
	    putallbots "$service rehash"
            foreach timer [timers] {killtimer [lindex $timer 2]}
            rehash }}
     join { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: join <channel>"
	    return 0 }
            foreach chn [channels] { 
            if {[string tolower $who] == [string tolower $chn]} {
            if {[string match +inactive [channel info $who]]} {
            channel set $who -inactive
            putserv "NOTICE $nick :Reactivated $who" 
            putserv "PRIVMSG $home :$nick made me reactivate $who"
            servicenote "$handle made me reactivate $who"
            return 0 }}}
	    channel add $who
	    putserv "NOTICE $nick :Joined $who" 
	    putserv "PRIVMSG $home :$nick made me join $who" 
	    servicenote "$handle made me join $who"
	    return 0 }}
     part { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: part <channel>"
	    return 0 }
	    channel set $who +inactive
	    putserv "NOTICE $nick :Left $who"
	    putserv "PRIVMSG $home :$nick made me part $who" 
	    servicenote "$handle made me part $who" }}
    purge { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} {return 0}
            if {$who == ""} {
            putserv "NOTICE $nick :Usage purge <channel>"
            return 0 }
            channel remove $who
            putserv "NOTICE $nick :Purged $who"
            putserv "PRIVMSG $home :$nick made me purge $who"
            servicenote "$handle made me purge $who" }}
     away { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set who [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage :away <message>" 
	    return 0 }
	    putserv "AWAY :$who"
	    putserv "NOTICE $nick :Bot is set to AWAY ($who)."
	    putserv "PRIVMSG $home :$nick made me put away ($who)." }}
     back { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    putserv "AWAY"
	    putserv "NOTICE $nick :Bot is set to BACK."
	    putserv "PRIVMSG $home :$nick made me put back."}}
     save { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    save
	    putserv "NOTICE $nick :Saved."
	    putserv "PRIVMSG $home :$nick made me save." }}
  allbans { if {[matchattr $handle m]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set banl [banlist]
	    putserv "NOTICE $nick :Global Banlist"
	    if {$banl == ""} {
            putserv "NOTICE $nick :Global Banlist is empty"
            return 0}
            foreach owns $banl {
	    set hm [lindex $owns 0]
	    set cm [lindex $owns 1]
	    set ex [ctime [lindex $owns 2]]
	    set ad [ctime [lindex $owns 3]]
	    set cr [lindex $owns 5]
	    putserv "NOTICE $nick :Host : $hm Creator : $cr Added : $ad Expires : $ex Reason : $cm" }}}
blacklist { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: blacklist <host> <reason>"
	    return 0 }
	    set ban $who
	    set why [lrange $var 2 end]
            if {$ban == "*!*@*"} {
	    putserv "NOTICE $nick :Nice Try.. Should read the manual more often !" 
            return 0}
	    newban $ban $nick $why
	    putallbots "$service blacklist $nick $ban $why"
	    putserv "KICK $channel $who :$why"
	    putserv "PRIVMSG $home :$nick made me blacklist $ban reason: $why."
	    putserv "NOTICE $nick :Blacklisted $who with reason: $why." 
	    servicenote "$handle made me blacklist $who :$why"}}
   unlock { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: unlock <channel>"
	    return 0 }
	    putserv "NOTICE $nick :UnLocking the channel $who."
	    channel set $who chanmode "+tn"
	    putserv "MODE $channel :-smi"
	    putserv "PRIVMSG $home :$nick made me unlock channel $who"
	    servicenote "$handle unlocked channel $who" }}
whitelist { if {[matchattr $handle n]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 2 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: whitelist <mask>"
	    return 0 }
	    killban $who
	    putallbots "$service whitelist $nick $who"
	    putserv "PRIVMSG $home :$nick made me remove $who from the blacklist."
	    putserv "NOTICE $nick :Removed $who from the blacklist" 
	    servicenote "$handle removed $who from blacklist" }}
      msg { if {[matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 2 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: msg <nick to msg> <What to say>"
	    return 0 }
	    putserv "PRIVMSG $who :$why"
	    putserv "NOTICE $nick :Msg'd $who with :$why"
	    return 0 }}
      say { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set who [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: say <What to say>"
	    return 0 }
	    putserv "PRIVMSG $channel :$who"
	    putserv "NOTICE $nick :Say'd $who"
	    return 0 }}
      act { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
            set who [lrange $var 1 end]
            if {$who == ""} {
            putserv "NOTICE $nick :Usage: act <what to put as action>"
            return 0 }
            putserv "PRIVMSG $channel :\001ACTION $who\001"
            putserv "NOTICE $nick :Actioned $who"
            return 0 }}
     deop { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "MODE $channel -o $nick"
	    return 0 }
	    if {[string tolower $who] == [string tolower $botnick]} {
	    putserv "MODE $channel -o $nick"
	    return 0 }
	    putserv "MODE $channel -o $who" }}
  banmask { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 3 end]
	    set dur [lindex $var 2]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: banmask <mask> <duration> <reason>"
	    return 0 }
	    newchanban $channel $who $nick "$why" $dur
	    putserv "MODE $channel +b $who"
	    putserv "NOTICE $nick :Banned mask $who on $channel with reason: $why." }}
      ban { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 3 end]
	    set dur [lindex $var 2]
	    set ban [maskhost [getchanhost $who $channel]]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: ban <nick> <duration> <reason>"
	    return 0 }
	    if {![onchan $who $channel]} {
	    putserv "NOTICE $nick :$who aint on $channel."
	    return 0 }
            if {[matchattr [nick2hand $who $channel] oQ]} {
            putserv "NOTICE $nick :You cannot ban a botservice member"
            return 0 }
	    if {$dur == ""} {
	    set dur "10"}
	    newchanban $channel $ban $nick "$why" $dur
	    putserv "MODE $channel +b $ban"
	    putserv "KICK $channel $who :$why"
	    putserv "NOTICE $nick :Kick-Banned $who on $channel with reason: $why." }}
    unban { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: unban <user@host>"
	    return 0 }
	    if {[string tolower $who] == "all"} {
	    set banl [banlist $channel]
	    foreach owns $banl {
	    killchanban $channel [lindex $owns 0]
	    putserv "NOTICE $nick :Removed [lindex $owns 0] from $channel 's banlist" }
	    return 0 }
	    killchanban $channel $who
	    putserv "MODE $channel -b $who"
	    putserv "PRIVMSG $home :$nick made me unban $who on $channel"
	    putserv "NOTICE $nick :Removed $who from $channel 's banlist" }}
  banlist { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set banl [banlist $channel]
            if {$banl == ""} {
            putserv "NOTICE $nick :Banlist for $channel is empty"
            return 0}
	    putserv "NOTICE $nick :Banlist for $channel"
	    foreach owns $banl {
	    set hm [lindex $owns 0]
	    set cm [lindex $owns 1]
	    set ex [ctime [lindex $owns 2]]
	    set ad [ctime [lindex $owns 3]]
	    set cr [lindex $owns 5]
	    putserv "NOTICE $nick :Host : $hm Creator : $cr Added : $ad Expires : $ex Reason : $cm" }}}
       op { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "MODE $channel +o $nick"
	    return 0 }
	    putserv "MODE $channel +o $who" }}
     kick { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set why [lrange $var 2 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: kick <nick to kick>"
	    return 0 }
	    if {![onchan $who $channel]} {
	    putserv "NOTICE $nick :$who isnt on $channel."
	    return 0 }
	    if {[string tolower $who] == [string tolower $botnick]} {
	    putserv "KICK $channel $nick :hah. funny."
	    return 0 }
	    putserv "KICK $channel $who :$why"
	    putserv "NOTICE $nick :Kicked $who from $channel stating: $why." }}
    cycle { if {[matchattr $handle &n $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Cycling $channel"
	    putserv "PART $channel"} else {
	    putserv "NOTICE $nick :Cycling $who"
	    putserv "PART $who" }}}
     mode { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
            set who [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: mode <Channel mode you want to set>"
	    return 0 }
	    if {![botisop $channel]} {
	    putserv "NOTICE $nick :I'm not op'd in $channel you LAMER!"
	    return 0 }
	    putserv "MODE $channel $who" }}
    voice { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "MODE $channel +v $nick"
	    return 0 }
	    putserv "MODE $channel +v $who" }}
  devoice { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "MODE $channel -v $nick"
	    return 0 }
	    putserv "MODE $channel -v $who" }}
shortnick { putserv "NOTICE $nick :My shortnick is $shortnick." }
   verify { set user [nick2hand $who $channel]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: verify <nick>"
	    putserv "NOTICE $nick :This command is to verify if a user is authorized to operate this bot, and shows you what level the user has"
	    return 0}
	    if {![onchan $who $channel]} {
	    putserv "NOTICE $nick :$who isnt on $channel."
	    return 0}
            putserv "NOTICE $nick :User is known in the bot as $user"
	    if {[matchattr $user Q]} {
            if {[getuser $user XTRA SECHOST] == [getchanhost $who $channel]} {
	    if {[string tolower [getuser $user XTRA SECNICK]] == [string tolower $who] } {
	    putserv "NOTICE $nick :$who is authenticated."}}}
	    if {[matchattr $user Q&H $home]} {
            if {[getuser $user XTRA SECHOST] == [getchanhost $who $channel]} {
	    putserv "NOTICE $nick :$who is an authenticated helper of $home"}}
	    if {[matchattr $user b]} {
	    putserv "NOTICE $nick :$who is a bot."
	    return 0}
	    if {[matchattr $user n]} {
	    putserv "NOTICE $nick :$who is the owner of the bot."
	    return 0}
	    if {[matchattr $user m]} {
	    putserv "NOTICE $nick :$who is a master of the bot."
	    return 0}
	    if {[matchattr $user o]} {
	    putserv "NOTICE $nick :$who is a global operator of the bot."
	    return 0}
	    if {[matchattr $user &n $channel]} {
	    putserv "NOTICE $nick :$who is the channelowner of $channel."
	    return 0}
	    if {[matchattr $user &m $channel]} {
	    putserv "NOTICE $nick :$who is the channelmaster of $channel."
	    return 0}
	    if {[matchattr $user &a $channel]} {
	    putserv "NOTICE $nick :$who is a channelbot of $channel."
	    return 0}
	    if {[matchattr $user &o $channel]} {
	    putserv "NOTICE $nick :$who is a chanop of $channel."
	    return 0}
	    if {[matchattr $user &v $channel]} {
	    putserv "NOTICE $nick :$who is chanvoice of $channel."
	    return 0}
	    if {[string tolower $channel] != [string tolower $home]} {
	    putserv "NOTICE $nick :$who is not known to the bot in $channel." }}
  chanset { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage :chanset <settings> :Valid settings are + means yes, - means no :autoop, clearbans, enforcebans, dynamicbans, userbans, bitch, greet, protectops and statuslog. " 
	    return 0 }
	    channel set $channel $who
	    putserv "NOTICE $nick :Changed settings on $channel to $who."
	    putserv "PRIVMSG $home :$nick made me change settings on $channel to $who." }}
 channels { set chans ""; set opless ""; set deact "" 
            foreach chan [channels] {
            set counter "0"; foreach user [chanlist $chan] {incr counter}
            if {[onchan W $chan]} {append chans " \[$counter\]W" $chan}
            if {[onchan X $chan]} {append chans " \[$counter\]X" $chan}
            if {![onchan X $chan] && ![onchan W $chan] && ![string match +inactive [channel info $chan]]} {append chans " \[$counter\]" $chan}} 
	    putserv "NOTICE $nick :I am currently on :$chans"
            foreach chan [channels] {
            if {![isop $botnick $chan] && ![string match "+inactive" [channel info $chan]] } {append opless " " $chan }
            if {[string match "+inactive" [channel info $chan]]} {append deact " " $chan }}
            if {$opless != ""} {putserv "NOTICE $nick :Opless in: $opless"}
            if {$deact != ""} {putserv "NOTICE $nick :Inactive on: $deact" } }
     ping { putserv "PRIVMSG $nick :\001PING [unixtime]\001" }
 userlist { if {$who == ""} {
            putserv "NOTICE $nick :Usage: userlist <channel>"
            return 0}
            if {![validchan $who]} {
            putserv "NOTICE $nick :I'm not on $who"
            return 0}
            putserv "NOTICE $nick :Users present in $who :"
            foreach p [chanlist $who] {
            set appender "\[[getchanhost $p $who]\] Idle: [getchanidle $p $who] seconds."
            if {[isop $p $who]} {
            putserv "NOTICE $nick :@$p $appender" } else {
            if {[isvoice $p $who]} {
            putserv "NOTICE $nick :+$p $appender" } else {
            putserv "NOTICE $nick :-$p $appender" }}}}
 chaninfo { if {$who == ""} {
	    putserv "NOTICE $nick :Usage: chaninfo <channel>"
	    return 0}
	    set uc "0"
	    set oc "0"
	    set vc "0"
            set ul ""
            if {![validchan $who]} {
            putserv "NOTICE $nick :I'm not on $who"
            return 0}
	    foreach p [chanlist $who] {
	    set uc [expr $uc + 1]
	    if {[isop $p $who]} {
	    set oc [expr $oc + 1] 
            append ul " @" $p } else {
	    if {[isvoice $p $who]} {
	    set vc [expr $vc + 1] 
            append ul " +" $p } else { 
            append ul " " $p }}}
	    putserv "NOTICE $nick :=-=-=-=-=-=-=-= $who =-=-=-=-=-=-=-=" 
	    if {[matchattr $handle o] && [checksec $nick $host $handle]} {
            putserv "NOTICE $nick :Current chansets  :[channel info $who]"
	    putserv "NOTICE $nick :Current chanmodes :[getchanmode $who]"}
	    putserv "NOTICE $nick :Current usercount :$uc"
	    putserv "NOTICE $nick :Currently ops     :$oc"
	    putserv "NOTICE $nick :Currently voiced  :$vc"
	    putserv "NOTICE $nick :=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-="
	    putserv "NOTICE $nick :Currently present users:"
	    putserv "NOTICE $nick : $ul"
	    putserv "NOTICE $nick :=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=" }
   server { putserv "NOTICE $nick :I'm currently on $server." }
     time { putserv "NOTICE $nick :The current time is [time]" }
     date { putserv "NOTICE $nick :Today is [date]" }
  version { putserv "NOTICE $nick :Running $service Multi $scriptversion (c)2000 OUTsiders WORLD on eggdrop $version." }
    queue { putserv "NOTICE $nick :Current queue in bot:"
	    putserv "NOTICE $nick :Mode: [queuesize mode] Server: [queuesize server] Help: [queuesize server]" } 
   uptime { putserv "NOTICE $nick :[exec uptime]" }
    count { set a [chanlist $channel]
	    set i "0"
	    putserv "Notice $nick :Counting Users on $channel..."
	    foreach p [chanlist $channel] {
	    set i [expr $i + 1] }
	    putserv "Notice $nick :There are $i users in $channel" }
   status { putserv "NOTICE $nick :=-=-=-=-=-=-=-= $botnick =-=-=-=-=-=-=-="
	    putserv "NOTICE $nick :           Eggdrop $version"
	    putserv "NOTICE $nick :Channels : [channels]"
	    putserv "NOTICE $nick :user@host: $botname"
	    putserv "NOTICE $nick :DCC IP   : [myip]"
	    putserv "NOTICE $nick :Server   : $server"
	    putserv "NOTICE $nick :$botnick contains a record of [countusers] users."
	    putserv "NOTICE $nick :=-=-=-=-=-=-= End Of Status =-=-=-=-=-=-" }
     drop { if {[matchattr $nick &n $channel]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    channel remove $channel }}
    clean { if {[matchattr $nick &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set dorks [chanlist $channel]
	    set dorklist ""
	    set reason "$nick requested channel cleanup"
	    foreach p $dorks {
	    set who [nick2hand $p $channel]
	    if {![matchattr $who o] && ![isop $p $channel] && ![isvoice $p $channel]} {
	    append dorklist " " $p }}
	    if {$dorklist == ""} {
	    putserv "NOTICE $nick :Couldn't find anyone needing kicking"
	    return 0 }
	    set blah "[llength $dorklist]"
	    putserv "NOTICE $nick :Kicking $blah Users: $dorklist"
	    set count 0
	    while {$count < $blah} {
	    putserv "KICK $channel [lindex $dorklist $count] :$reason"
	    incr count 1 }}}
      add { set mode [string tolower [lindex $var 2]]
            if {![checksec $nick $host $handle]} { return 0 }
	    set hmsk [lindex $var 3]
	    if {$hmsk == "" } {
	    set ophost [maskhost [getchanhost $who $channel]]
	    } else {
	    set ophost $hmsk }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: add <nick> <chanmode> <optional usermask>"
	    if {[matchattr $handle n]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice chanbot chanop chanmaster chanowner globalop master owner oper"
	    return 0}
	    if {[matchattr $handle m]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice chanbot chanop chanmaster chanowner globalop"
	    return 0}
	    if {[matchattr $handle o]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice chanbot chanop chanmaster chanowner"
	    return 0}
	    if {[matchattr $handle &n $channel]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice chanbot chanop chanmaster"
	    return 0}
	    if {[matchattr $handle &m $channel]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice chanbot chanop"
	    return 0}
	    if {[matchattr $handle &o $channel]} {
	    putserv "NOTICE $nick :Usage: <chanmode> can be chanvoice"
	    return 0} }
	    if {$who == $nick} {
	    putserv "NOTICE $nick :Yeah right... try again !"
	    return 0 }
	    if {![onchan $who $channel]} {
	    putserv "NOTICE $nick : $who must be on the channel for this to work!"
	    return 0 }
            if {[nick2hand $who $channel] != "*"} {
	    putserv "NOTICE $nick :Nick already available as [nick2hand $who $channel]."
            putserv "NOTICE $who :You have been recognized as [nick2hand $who $channel]."
            putserv "NOTICE $who :If this is not you. Please tell this to the one adding you."
	    set who [nick2hand $who $channel] } else {
	    adduser $who $ophost
	    putserv "NOTICE $who :Please set a pass: /msg $botnick pass <password>."
	    putserv "NOTICE $who :All commands are available by $botnick help." }
	    switch $mode {
	     chanvoice { if {[matchattr $handle o] || [matchattr $handle &o $channel]} {
			 chattr $who +h|+vf $channel
			 putserv "NOTICE $nick :Added user as chanvoice of $channel to the bot"
			 return 0 }}
		chanop { if {[matchattr $handle o] || [matchattr $handle &m $channel]} {
			 chattr $who +h|+ovf $channel
			 putserv "NOTICE $nick :Added user as chanop of $channel to the bot"
			 return 0 }}
	       chanbot { if {[matchattr $handle o] || [matchattr $handle &m $channel]} {
			 chattr $who -|+aovf $channel
			 putserv "NOTICE $nick :Added user as chanbot of $channel to the bot"
			 return 0 }}
	    chanmaster { if {[matchattr $handle o] || [matchattr $handle &n $channel]} {
			 chattr $who +h|+ovmf $channel
			 putserv "NOTICE $nick :Added user as chanmaster of $channel to the bot"
			 return 0 }}
	     chanowner { if {[matchattr $handle o]} {
			 chattr $who +h|+ovnmf $channel
			 putserv "PRIVMSG $home :$nick added $who ($ophost) as chanowner of $channel to the bot"
			 putserv "NOTICE $nick :Added user as chanowner of $channel to the bot"
			 return 0 }}
	      globalop { if {[matchattr $handle m]} {
			 chattr $who +o
			 putserv "PRIVMSG $home :$nick added $who ($ophost) as global operator to the bot"
			 putserv "NOTICE $nick :Added user as global operator to the bot"
			 return 0 }}
		master { if {[matchattr $handle n]} {
			 chattr $who +m
			 putserv "PRIVMSG $home :$nick added $who ($ophost) as master to the bot"
			 putserv "NOTICE $nick :Added user as master to the bot"
                         return 0 }}
		 owner { if {[matchattr $handle n]} {
			 chattr $who +n
			 putserv "PRIVMSG $home :$nick added $who ($ophost) as owner to the bot"
			 putserv "NOTICE $nick :Added user as owner to the bot"}}
                  oper { if {[matchattr $handle n]} {
                         chattr $who +O
                         putserv "PRIVMSG $home :$nick added $who ($ophost) as oper to the bot"
                         putserv "NOTICE $nick :Added user as oper to the bot"}}
}}
      del { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage: del <nick>"
	    return 0}
	    if {[matchattr [nick2hand $who $channel] &n $channel]} {
            if {![matchattr [nick2hand $nick $channel] +o]} {
	    putserv "NOTICE $nick :You cannot delete the chanowner"
	    return 0}}
	    if {[matchattr [nick2hand $who $channel] o]} {
	    putserv "NOTICE $nick :You cannot delete a botmember"
	    return 0}
	    delchanrec [nick2hand $who $channel] $channel
	    putserv "NOTICE $nick :Removed $who from the channeldatabase" }}
    rnban { if {[matchattr $handle &n $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
            if { $who == "" } {
            putserv "NOTICE $nick :Usage: rnban <nick>"
            return 0}
            if {![onchan $who $channel]} {
            putserv "NOTICE $nick :User $who is not on this channel."
            return 0}
            if {[matchattr [nick2hand $who $channel] &o $channel]} {
            putserv "NOTICE $nick :You cannot ban an op from this channel."
            return 0}
            if {[matchattr [nick2hand $who $channel] o]} {
            putserv "NOTICE $nick :You cannot ban a botservice member."
            return 0}
            if {![info exists rnnick($who)]} {
            putserv "NOTICE $nick :Sorry.. user $who not indexed yet. Try again later."
            putserv "WHOIS $who"
            return 0}
            putserv "NOTICE $nick :Issueing ban on realname $rnnick($who)" 
            set fd [open $rnconf a]
            puts $fd "$channel $handle [unixtime] $rnnick($who)"
            close $fd
            putserv "WHOIS $who" }}
   rnlist { if {[matchattr $handle &n $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
            set fd [open $rnconf r]
            gets $fd dummy
            putserv "NOTICE $nick :Realname banlist for channel $channel :" 
            while {![eof $fd]} {
            gets $fd line
            set chan [string tolower [lindex $line 0]]
            set crea [lindex $line 1]
            set rnid [lindex $line 2]
            set rndt [ctime $rnid]
            set real [string tolower [lrange $line 3 end]]
            if {[string tolower $channel] == [string tolower $chan]} {
            putserv "NOTICE $nick :Id: $rnid Creator: $crea Created: $rndt Realname: $real" }}}}
  rnunban { if {[matchattr $handle &n $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
            if {$who == ""} {
            putserv "NOTICE $nick :Usage rnunban <id>"
            return 0 }
            set fd [open $rnconf r]
            set ft [open "$rnconf.bak" w]
            gets $fd dummy
            puts $ft $dummy
            while {![eof $fd]} {
            gets $fd line
            set chan [string tolower [lindex $line 0]]
            set rnid [lindex $line 2]
            set real [string tolower [lrange $line 3 end]]
            if {$who == $rnid && [string tolower $channel] == [string tolower $chan]} { 
            putserv "NOTICE $nick :Removing $real from the list" } { 
            puts $ft $line }}
            close $fd; close $ft
            exec mv $rnconf.bak $rnconf
            exec rm $rnconf.bak
            }}
    greet { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set who [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :Usage greet <message> or OFF to disable greet"
	    if {![info exists topicinfo(greet$channel)]} {
	    putserv "NOTICE $nick :Current setting: DISABLED" } else {
	    putserv "NOTICE $nick :Current setting: $topicinfo(greet$channel)" }
	    return 0 }
	    if {[string tolower $who] == "off"} {
            unset topicinfo(greet$channel)
	    putserv "NOTICE $nick :Greet disabled"
	    return 0 }
	    set topicinfo(greet$channel) $who
	    putserv "NOTICE $nick :Greet set to $who"
	    return 0 }}
    topic { if {[matchattr $handle &o $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    set who [lrange $var 1 end]
	    if {$who == ""} {
	    putserv "NOTICE $nick :USAGE: topic <topic>"
	    return 0 }
	    putserv "TOPIC $channel :$who"
	    putserv "NOTICE $nick :Topic on channel $channel set to $who"
	    return 0 }}
topiclock { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
            putserv "NOTICE $nick :USAGE: topiclock <on|off>"
	    return 0 }
            switch $who {
            off { if {$topicinfo(locked$channel)=="1"} {
                  set topicinfo(locked$channel) "0"
                  set topicinfo(ltopic$channel) ""
                  set topicinfo(lwho$channel) ""
                  putserv "NOTICE $nick :Topic is UNlocked."
                  return 0 } else {
                  putserv "NOTICE $nick :No need to unlock \(it's not locked\)"
                  return 0 }}
             on { if {$topicinfo(locked$channel)=="1"} {
                  putserv "NOTICE $nick :Topic already locked by $topicinfo(lwho$channel). Unlock first."
                  return 0}
                  set topicinfo(locked$channel) 1
                  set topicinfo(ltopic$channel) [topic $channel]
                  set topicinfo(lwho$channel) $nick
                  putserv "NOTICE $nick :Topic is Locked." }}}}
autovoice { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
            putserv "NOTICE $nick :Usage: autovoice <on|off>"
	    return 0 }
            switch $who {
            off { set topicinfo(vchan$channel) "0"
                  putserv "NOTICE $nick :AutoVoice disabled."
                  return 0 }
             on { set topicinfo(vchan$channel) "1"
                  putserv "NOTICE $nick :AutoVoice enabled."
                  return 0 }}}}
chanflood { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
            putserv "NOTICE $nick :Usage: chanflood <amount>"
            putserv "NOTICE $nick : example: $shortnick chanflood 5 will kick when someone types 5 lines in 10 seconds. Use 0 to disable. amount may be between 3 and 10" 
	    return 0 }
            switch $who {
             0 { channel set $channel flood-chan 0:0
                 putserv "NOTICE $nick :ChanFlood disabled" }
             3 { channel set $channel flood-chan 3:10
                 putserv "NOTICE $nick :ChanFlood set to 3" }
             4 { channel set $channel flood-chan 4:10
                 putserv "NOTICE $nick :ChanFlood set to 4" }
             5 { channel set $channel flood-chan 5:10
                 putserv "NOTICE $nick :ChanFlood set to 5" }
             6 { channel set $channel flood-chan 5:10
                 putserv "NOTICE $nick :ChanFlood set to 5" }
             7 { channel set $channel flood-chan 7:10
                 putserv "NOTICE $nick :ChanFlood set to 7" }
             8 { channel set $channel flood-chan 8:10
                 putserv "NOTICE $nick :ChanFlood set to 8" }
             9 { channel set $channel flood-chan 9:10
                 putserv "NOTICE $nick :ChanFlood set to 9" }
            10 { channel set $channel flood-chan 10:10
                 putserv "NOTICE $nick :ChanFlood set to 10" }}
            return 0 }}
ctcpflood { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
            putserv "NOTICE $nick :Usage: ctcpflood <amount>"
            putserv "NOTICE $nick : example: $shortnick ctcpflood 5 will kick when someone uses 5 ctcp's in 10 seconds. Use 0 to disable. amount may be between 3 and 10" 
	    return 0 }
            switch $who {
             0 { channel set $channel flood-ctcp 0:0
                 putserv "NOTICE $nick :CTCPFlood disabled" }
             3 { channel set $channel flood-ctcp 3:10
                 putserv "NOTICE $nick :CTCPFlood set to 3" }
             4 { channel set $channel flood-ctcp 4:10
                 putserv "NOTICE $nick :CTCPFlood set to 4" }
             5 { channel set $channel flood-ctcp 5:10
                 putserv "NOTICE $nick :CTCPFlood set to 5" }
             6 { channel set $channel flood-ctcp 5:10
                 putserv "NOTICE $nick :CTCPFlood set to 5" }
             7 { channel set $channel flood-ctcp 7:10
                 putserv "NOTICE $nick :CTCPFlood set to 7" }
             8 { channel set $channel flood-ctcp 8:10
                 putserv "NOTICE $nick :CTCPFlood set to 8" }
             9 { channel set $channel flood-ctcp 9:10
                 putserv "NOTICE $nick :CTCPFlood set to 9" }
            10 { channel set $channel flood-ctcp 10:10
                 putserv "NOTICE $nick :CTCPFlood set to 10" }}
            return 0 }}
nickflood { if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
            if {![checksec $nick $host $handle]} { return 0 }
	    if {$who == ""} {
            putserv "NOTICE $nick :Usage: nickflood <amount>"
            putserv "NOTICE $nick : example: $shortnick nickflood 5 will kick when someone changing nicks 5 times within 10 seconds. Use 0 to disable. amount may be between 3 and 10" 
	    return 0 }
            switch $who {
             0 { channel set $channel flood-nick 0:0
                 putserv "NOTICE $nick :NickFlood disabled" }
             3 { channel set $channel flood-nick 3:10
                 putserv "NOTICE $nick :NickFlood set to 3" }
             4 { channel set $channel flood-nick 4:10
                 putserv "NOTICE $nick :NickFlood set to 4" }
             5 { channel set $channel flood-nick 5:10
                 putserv "NOTICE $nick :NickFlood set to 5" }
             6 { channel set $channel flood-nick 5:10
                 putserv "NOTICE $nick :NickFlood set to 5" }
             7 { channel set $channel flood-nick 7:10
                 putserv "NOTICE $nick :NickFlood set to 7" }
             8 { channel set $channel flood-nick 8:10
                 putserv "NOTICE $nick :NickFlood set to 8" }
             9 { channel set $channel flood-nick 9:10
                 putserv "NOTICE $nick :NickFlood set to 9" }
            10 { channel set $channel flood-nick 10:10
                 putserv "NOTICE $nick :NickFlood set to 10" }}
            return 0 }}
     help { putserv "NOTICE $nick :All commands are available at http://www.key2peace.org/commands.htm." 
            return 0 }
            putserv "NOTICE $nick :*CrK* Houston *crk* I th*crk*nk we go*crrrrk* a problem h*crk*e can you HELP us *Crk* Houston ?"
}}

proc prot_deop {nick host hand chan mdechg dnick} {
 global botnick home service
 set deophand [nick2hand $dnick $chan]
 if {$dnick == $botnick} {
  if {$dnick != ""} {
    putserv "PRIVMSG $home :$nick deopped me on $chan"
    putserv "NOTICE $nick :Your deop of the bot has been logged"
    foreach user [userlist |n $chan] {
    sendnote "$serviceWarning" $user "$nick \[$host\] deopped me on $chan" }
    set fd [open deop.dat a]
    puts $fd "$nick deopped $botnick on $chan"
    close $fd}
  if {$dnick == ""} {
    putserv "PRIVMSG $home :Serverdeop on $chan" }
}}


proc servicenote { msg } {
 global service smsnotify icqnotify notnotify
 if {$notnotify == "1"} {
  foreach user [userlist n] { 
  sendnote "$serviceNotify" $user $msg }}
}

proc prot_kick {nick host hand chan knick reason} {
 global botnick home service
 set chan [string tolower $chan]
 set knick [string tolower $knick]
 set kickhand [nick2hand $knick $chan]
 if {$knick == [string tolower $botnick]} {
    putserv "PRIVMSG $home :$nick kicked me from $chan stating $reason"
    putserv "NOTICE $nick :Your kick of the bot has been logged"
    foreach user [userlist |n $chan] {
    sendnote "$serviceWarn" $user "$nick \[$host\] kicked me from $chan stating: $reason" }
    set fd [open kick.dat a]
    puts $fd "$nick kicked $botnick from $chan stating $reason"
    close $fd}}

proc welcomer {nick host handle channel} {
 global topicinfo network botnick home
 if {$nick == $botnick} {return 0}
 putserv "WHOIS $nick"
 if {[info exists topicinfo(greet$channel)]} {
 putserv "NOTICE $nick :$topicinfo(greet$channel)"}
 if {[info exists topicinfo(vchan$channel)] && $topicinfo(vchan$channel) == 1} { putserv "MODE $channel +v $nick"} 
 foreach user [chanlist $channel] { if {[isop $user $channel]} {return 0}}
 if {[matchattr $handle +O]} {return 0}
 if {[string tolower $channel] == [string tolower $home]} {return 0}
 putserv "NOTICE $nick :This channel is opless, please type $botnick verify <nick> to see who is a verified op in this channel. You will see the users level and if he is authenticated or not." }

proc topic_check {nick uhost hand channel arg} {
 global topicinfo botnick
 if {$nick=="$botnick"} { return 0 }
 set chan [string tolower $channel]
 if {![info exists topicinfo(locked$chan)]} { set topicinfo(locked$chan) 0 }
 if {$topicinfo(locked$chan)=="0"} { return 0 } else {
 putserv "TOPIC $channel :$topicinfo(ltopic$chan)"
 putserv "NOTICE $nick :Sorry topic already locked by $topicinfo(lwho$chan)." }
 return 1 }

proc checksec {nick host hand} {
 global botnick
 if {![matchattr $hand +Q]} {
 putserv "NOTICE $nick :You are not authenticated."
 putserv "NOTICE $nick :Please login with /msg $botnick login <password>."
 return 0}
 if {[getuser $hand XTRA SECNICK] != $nick} {
 putserv "NOTICE $nick :Sorry. But I don't like user@host abusers :p"
 return 0}
 if {[getuser $hand XTRA SECHOST] != $host} {
 putserv "NOTICE $nick :Sorry. But it seems that you are not really the one you pretend to be :p"
 return 0}
 return 1}

proc multi:getrn {from idx args} {
 global rnconf rnnick
 set args [lindex $args 0]
 set nick [string tolower [lindex $args 1]]
 set client [lrange $args 5 end]
 set rnnick($nick) "$client"
 set fd [open $rnconf r]
 gets $fd dummy
 while {![eof $fd]} {
  gets $fd line
  set chan [string tolower [lindex $line 0]]
  set crea [lindex $line 1]
  set rnid [string tolower [lindex $line 2]]
  set real [string tolower [lrange $line 3 end]]
  if {[validchan $chan]} {
  if {[onchan $nick $chan]} {
   if {![matchattr [nick2hand $nick $chan] o]} {
   if {![matchattr [nick2hand $nick $chan] &o $chan]} {
   if { $client == $real } {
    putserv "MODE $chan +b [maskhost [getchanhost $nick $chan]]"
    putserv "KICK $chan $nick :You are banned by $crea"
   }}}}
  }
 }
 close $fd
}

if {[info exists multils(timerid)]} { loadconfig }

putlog "$service Multi $scriptversion (C)2000 OUTsiders WORLD loaded."
