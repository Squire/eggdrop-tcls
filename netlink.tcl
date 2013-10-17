#         Script : NetLink v1.08 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002-2003 Radical Computer Systems
#
#       Testing
#      Platforms : Linux 2.2.16   TCL v8.3
#                  Eggdrop v1.6.2
#                  Eggdrop v1.6.6
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : NetLink is a multi-net, multi-channel channel linking
#                  tool. It will echo channel chat, actions, sound
#                  commands, topic/mode changes, joins/parts/signoffs,
#                  kicks, bans, etc.
#                  Comes with commands to list who is in other channels,
#                  what network the user is on, and an easy OP command to
#                  explain what the linking is.
#                  Now comes with cross network OPing commands
#                  Crossnet whois, topic, lusers, and message commands.
#                  Now includes single bot channel spy capablities
#
#        History : 07/29/2001 - First Release
#                  12/07/2001 - v1.01
#                              o Ability to turn off nick and/or net in output
#                              o Ability to turn off linking of join, part,
#                                sign topic, kick, nick, mode, action, and
#                                sound.
#                              o Added DCC commands.
#                              o Do charactor conversion on data send via
#                                channel text and actions to keep []"/ etc
#                                charactors in tact. Will do it on kick, 
#                                sign off, etc messages if requested.
#                              o WhooHoo! I finally fixed the error that
#                                needs you to add a place holder at spot 0
#                                Shit I can be stupid at times. lol
#                              o Removed net variable and rely on network
#                              o Added in NetOP commands for
#                                kick, ban, siteban, unsiteban, op,
#                                deop, voice, devoice, modes, and topic.
#                  12/16/2001 - v1.02
#                              o Fixed error in bot_get_netop
#                              o Fixed not honoring netop requests.
#                              o Fixed the !netop help   command
#                  05/14/2002 - v1.03
#                              o Fixed linking nicks with a / in them
#                              o Added flag to display if user is +/@ in cnlist
#                              o Added flag to split long longs on cnlist
#                              o Added flag to show if user is netsplit
#                                in cnlist
#                              o Removed useage of putallbots so immature
#                                children can't fuck with the netlink.
#                              o Added command to view topics across botnet
#                              o Added in crossnet message command
#                              o Added in crossnet whois command
#                              o Added in crossnet lusers command
#                              o Made linking output user definable
#                              o Added definable user flag to ignore
#                                events from. (Users with said flag wont
#                                be linked)
#                              o Added in link-voiced-users-only flag.
#                              o Error fix on addclink. Should report
#                                adding as # it actually is, not +1.
#                  06/10/2002 - v1.04
#                              o Added in reply for "no such nick" on cnwhois
#                              o Modified "how to reply to netlink message"
#                                to have the bot use it's nick in the line.
#                              o Removed (usenick) and (usenet) variables.
#                                Definable formats made them obsolete.
#                              o Fixed error when deleting last channel link
#                                (Reported by qriff)
#                              o Fixed error if no channels are linked.
#                              o Added basic channel spy functionality
#                                (Echo events in one channel one way to
#                                 another with just 1 bot)
#                  06/28/2002 - 1.05
#                              o Fixed "what" error in topic linking
#                                (Reported by: killa--@UnderNet)
#                              o !cnlist works with diff named chans
#                              o Double entries are no longer needed
#                                when linking channels with different
#                                names.
#                              o !cntopics works with diff named chans
#                              o !netop commands can now be global
#                  08/26/2002 - v1.06
#                              o Fixed linking nicks containing }
#                                (Reported by Nighthwk@UnderNet)
#                              o Fixed linking nicks containing {
#                                (Reported by Nighthwk@UnderNet)
#                              o Fixed cutting off modes containing a \
#                                (Reported by Nighthwk@UnderNet)
#                              o Fixed linking of lines with consecutive
#                                spaces.
#                              o Will now correctlly link the & charactor
#                                (Reported by BarkerJr@UnderNet)
#                              o Added %C% token
#                                (Requested by BarkerJr@UnderNet)
#                              o Fixed linking of text containing "$"
#                   12/09/2002 - v1.07
#                              o Fixed: Tcl error [in_msay]: can't read 
#                                "clinked": no such variable
#                              o Prefix filtering
#                                (Requested by: FL|NX@UnderNet)
#                   07/13/2003 - v1.08
#                              o public cnlusers command wasn't using 
#                                 $clink_(lusersaccess)
#                              o FOrgot to include thes procedure. opsie.
#
#      Donations : https://www.paypal.com/xclick/business=rainbows%40stx.rr.com
# (If you don't have PayPal and want to donate, EMail me for an address.
#  Will take money or hardware/computer donations)
#  Significant (or even non-significant donations) can be published on a
#  web site if you so choose.
#
#   Future Plans : Send in suggestions.
# o Suspend link command
# o fix space fuckup
# o Fix netop mode command
# o <LOrdSteiN> Show text from linked channel in DCC
#
# o <Squirre1> !nlhelp    <Squirre1> would be a great addition
#
#<jekor> oh, also another suggestion for the next version (unless it's already
#        in this one), it'd be nice to be able to use regular expressions on
#        lines (to avoid relaying them) rather than just starting text
#<jekor> there's people with these dumb wb scripts, but the start of them are
#        all different
#<jekor> well, like I'd like to do .*[wW][bB].*[wW][bB].*

#
# Author Contact :     Email - DProper@chaotix.net
#                   Homepage - http://www.chaotix.net/~dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet
#                   #RCS @Choatix Addiction
#            Other channels - Check contact page for current list
#
#                Current contact information can be located at:
#                 http://rcs.chaotix.net/contact.html
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS
# ftp.eggheads.org           | Various
#
#
#   Radical Computer Systems - http://rcs.chaotix.net/
# To subscribe to the RCS mailing list:
#  http://www.chaotix.net/mailman/listinfo/rcs-list
#
#  Feel free to Email me any suggestions/bug reports/etc.
# 
# You are free to use this TCL/script as long as:
#  1) You don't remove or change author credit
#  2) You don't release it in modified form. (Only the original)
# 
# If you have a "too cool" modification, send it to me and it'll be
# included in the official. (With your credit)
#
# Commands Added:
#  Where     F CMD       F CMD         F CMD        F CMD
#  -------   - --------- - ----------- - ---------- - ---------
#  Public:   m !addclink m !delclink   o !listclink - !cnlist
#            o !cn       - !whatnet    o !netop     - !cntopics
#            ? !cnwhois  ? cnlusers
#            m !addcspy  m !delcspy    o !listcspy
#     MSG:   ? netlink   ? whois       ? lusers
#     DCC:   m addclink  m delclink    m listclink  - cnlist
#            o cntopics  o cnwhois     o cnlusers
#            m addcspy   m delcspy     o listcspy
#
# Public Matching: N/A
#

#   Add the following to your main config file:
#	set network UnderNet
#	set snet UN
#	set botnetid 123456

# A few things to point out:
#  1) In order to link channels, you need a bot on each net you want to
#     link.
#  2) All linking bots must be connected to each other via botnet links
#  3) Use the !addclink command on each net you want to link channels on.
#    Format is:   !addclink #SourceChannel #DestinationChannel
#    The best thing to do is link channels of the same name. 
#  4) The network variable is to be set with the name of the network that
#     bot is on.
#  5) The snet variable is a short name of the network to be displayed in
#     the links. EX: if snet = "UN" then output is <DrN@UN> What's up?
#     your network variable must be defined as well. Perferably the same
#     as the net variable.
#  6) The botnetid variable should be the same on all bots you want to
#     link channels. Only change on bots that are linking different
#     channels on the same botnet.
#  7) Linking channels of a different name.
#     Double entries are no longer needed. Set them up as follow:3
#   #Channel1 on Net1 - #Channel2 on Net2
#              On Net1: !addclink #channel2 #channel1
#              On Net2: !addclink #channel1 #channel2

# Set this to how many nets are being linked. (For !cn command display)
set netcount 2

# Set this to the command charactor to use for public commands.
if {![info exists cmdchar_]} {set cmdchar_ "!"}

# Set this to a space seperated list of bots to send netlink data to.
# This list MUST be set with the botnet nicks of all bots you want in your
# netlink tree.
# Also, netlink will only accept data lines from bots listed here. Any
# datalines from bots not listed will be rejected and logged. 
set clink_(botlist) "Aphex Axis"


# Set this to the textfile you want linking configuration saved to
set clinkfile "~/linked"

set cspy_(datafile) "~/spyed"

# Set this to the number of charactors to split the cnlist lines at.
# Use 0 for no splitting.
set clink_(splituserlist) 230

# [0/1] Set this to 1 to show if user is +/@ in cnlist output
set clink_(showusermode) 1

# [0/1] Set this to 1 to show if user is netsplit in cnlist output
set clink_(showusersplit) 1

# Set this to the access required to use the cross-net message command
set clink_(netlinkaccess) "o|o"

# Set this to the access required to use the cross-net whois command
set clink_(whoisaccess) "o|o"

# Set this to the access required to use the cross-net luser command
set clink_(lusersaccess) "o|o"

# Set this to a userflag to IGNORE all events from.
# (Users with this flag will NOT show up on the netlink)
set clink_(ignoreflag) "N"

# [0/1] Set this to 1 if you only want VOICED users to be linked.
set clink_(onlyvoiced) 0

# Set this to a list of charactors/words found at the start of the line
# to filter out and not link. (IE: Bot command shit)
set clink_filt(start) {
 {!}
                      }

# [0/1] Set To 1 to enable linking of the following events.
set clink_(linkjoin) 0
set clink_(linkpart) 0
set clink_(linksign) 0
set clink_(linktopic) 1
set clink_(linkkick) 0
set clink_(linknick) 0
set clink_(linkmode) 0
set clink_(linkaction) 1
set clink_(linksound) 0

# All formats should suport the following tags, only special tags are
# noted on following formats:
#    %A% - Control A              %B% - Control B (Bold)
#    %C% - Control C
# %CHAN% - Channel             %NICK% - Nickname
# %SNET% - Short network name   %NET% - Full network name
# Some support %HOST% for hostmask of user

set clink_format(public) "(%B%%NICK%%B%@%SNET%) %TEXT%"
set clink_format(join) {*** Join %NICK% (%HOST%) on %NET%}
set clink_format(part) {*** Part %NICK% (%HOST%) on %NET%}

# %COMMENT% - User's signoff message
set clink_format(signoff) {*** [signoff/%CHAN%] %NICK% (%COMMENT%) on %NET%}

# %TOPIC% - New topic
set clink_format(topic) {*** [topic/%CHAN%(%NICK%)] %TOPIC% on %NET%}

#  %KICKER% - Nickname of person kicking user
# %COMMENT% - Kick Reason
set clink_format(kick) {*** %NICK% was kicked off %CHAN% by %KICKER% on %NET% (%COMMENT%)}

# %NEWNICK% - New nickname of user
set clink_format(nick) {***  Nick Change: %NICK% is now %NEWNICK% on %NET%}

# %MODE% - Channel Mode
set clink_format(mode) {*** [mode/%CHAN%(%MODE%)] by %NICK% on %NET%}

# %TEXT% - Action Text
set clink_format(action) {* (%B%%NICK%%B%@%SNET%) %TEXT%}

# If you want actions to show as real /me actions, use the following definition:
# set clink_format(action) {%A%ACTION (%B%%NICK%%B%@%SNET%) %TEXT%%A%}

# %WAV% - Filename of WAV file being played
set clink_format(sound) {%A%SOUND %WAV% %TEXT% (%NICK% on %NET%)%A%}

####!
# All formats should suport the following tags, only special tags are
# noted on following formats:
#    %A% - Control A              %B% - Control B (Bold)
#    %C% - Control C
# %SCHAN% - Source Channel    %DCHAN% - Destination Channel
#  %NICK% - Nickname           %TEXT% - Text of event
#  %TEXT1% - First element of TEXT
#  %TEXT2% - Everything after the first element of TEXT
#   %HOST% - hostmask of user

set cspy_format(public) "(%B%%NICK%%B%@%SCHAN%) %TEXT%"
set cspy_format(join) {*** Join %NICK% (%HOST%) on %SCHAN%}
set cspy_format(part) {*** Part %NICK% (%HOST%) on %SCHAN%}
set cspy_format(signoff) {*** [signoff/%SCHAN%] %NICK% (%TEXT%)}
set cspy_format(topic) {*** [topic/%SCHAN%(%NICK%)] %TEXT%}
set cspy_format(kick) {*** %TEXT1% was kicked off %SCHAN% by %NICK% (%TEXT2%)}
set cspy_format(nick) {***  Nick Change: %NICK% is now %TEXT% on %SCHAN%}
set cspy_format(mode) {*** [mode/%SCHAN%(%TEXT%)] by %NICK%}
set cspy_format(action) {* (%B%%NICK%%B%@%SCHAN%) %TEXT%}
set cspy_format(sound) {%A%SOUND %TEXT% (%NICK% on %SCHAN%)%A%}

# [0/1] Set To 1 to enable linking of the following events.
set cspy_(public) 1
set cspy_(join) 0
set cspy_(part) 0
set cspy_(signoff) 0
set cspy_(topic) 1
set cspy_(kick) 0
set cspy_(nick) 0
set cspy_(mode) 0
set cspy_(action) 0
set cspy_(sound) 0


####!


# The following is a snet to network name map. 
# The second, long network name, must match what you have in each bot's
# network variable or netop commands will fail.
# Format is:   shortname longname
set netmap {
 {un UnderNet}
 {dn DALnet}
 {ch Chaotix}
 {ef EFNet}
 {gn GalaxyNet}
 {in IRCnet}
 {cg ChatGalaxy}
 {pn PeaceNet}
 {op OpenProjects}
 {fn FreeNode}
 {es EsperNet}
 {az AZReality}
           }

# [0/1] Set this to 1 if you do not wish to honor netop requests
set ignorenetop 0

set clink_changed 0
set clink 1
set clinked ""
set clinkver "v1.08.01"
set reverse "\026"

set cspy 1 ; set cspyed ""

proc cmdchar { } {
global cmdchar_
return $cmdchar_
}


bind bot - c_said in_say
proc in_say {from com args} {
global botnetid clink clinked clink_ clink_format
 subst -nobackslashes -nocommands -novariables args
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 1]
set who [lindex $args 2]
set mask [lindex $args 3]
set txt [lrange $args 4 end]

 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

# regsub -all {\$} $txt !DS! txt
# regsub -all {!AM!} $txt {\&} txt
 regsub -all {!PD!} $txt \. txt
 regsub -all {!CO!} $txt \: txt
 regsub -all {!SQ!} $txt \' txt
 regsub -all {!QL!} $txt \; txt
 regsub -all {!QT!} $txt \" txt
 regsub -all {!LT!} $txt \< txt
 regsub -all {!GT!} $txt \> txt
 regsub -all {!LP!} $txt \( txt
 regsub -all {!RP!} $txt \) txt
 regsub -all {!LB!} $txt \{ txt
 regsub -all {!RB!} $txt \} txt
 regsub -all {!LF!} $txt \[ txt
 regsub -all {!RF!} $txt \] txt
 regsub -all {!SL!} $txt \\ txt
 regsub -all {!SP!} $txt " " txt
 set what $txt

set clink_doit [get_clink $chan $n]

if {$clink_doit != -1} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {$botnetid == $nid} {
                           set txtout $clink_format(public)
                           regsub -all {%B%} $txtout \002 txtout
                           regsub -all {%A%} $txtout \001 txtout
                           regsub -all {%C%} $txtout \003 txtout
                           regsub -all {%CHAN%} $txtout $chan txtout
                           regsub -all {%NICK%} $txtout $who txtout
                           regsub -all {%SNET%} $txtout $sn txtout
                           regsub -all {%NET%} $txtout $n txtout
                           regsub -all {%TEXT%} $txtout $what txtout
                           regsub -all {!AM!} $txtout {\&} txtout
                           regsub -all {!DS!} $txtout {$} txtout
                           putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}

bind pubm - ***** link_mpub
proc link_mpub {nick uhost hand channel text} {
 global clinked clink network snet botnetid clink_ clink_filt
 subst -nobackslashes -nocommands -novariables text

if {(![is_cspy $channel $hand]) && (![is_clink $channel])} {return 0}


set filtered 0
foreach filt $clink_filt(start) {
 if {[string range [string tolower $text] 0 [expr [string length $filt] - 1]] == $filt} {set filtered 1}
                                }
if {$filtered == 1} {return 0}

 regsub -all {\\} $nick !SL! nick
 regsub -all {\}} $nick !LB! nick
 regsub -all {\{} $nick !RB! nick

 regsub -all { } $text !SP! text
 regsub -all {\\} $text !SL! text
 regsub -all {\<} $text !LT! text
 regsub -all {\>} $text !GT! text
 regsub -all {\"} $text !QT! text
 regsub -all {\(} $text !LP! text
 regsub -all {\)} $text !RP! text
 regsub -all {\{} $text !LB! text
 regsub -all {\}} $text !RB! text
 regsub -all {\[} $text !LF! text
 regsub -all {\]} $text !RF! text
 regsub -all {\;} $text !QL! text
 regsub -all {\:} $text !CO! text
 regsub -all {\.} $text !PD! text
 regsub -all {\&} $text !AM! text
 regsub -all {\$} $text !DS! text

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel public $text}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}
if {([is_clink $channel])} {
 netlinkout "c_msaid $botnetid $network $snet $nick $channel $text"
                           }
}

bind bot - c_msaid in_msay
proc in_msay {from com args} {
global botnetid clink clinked clink_ clink_format
 subst -nobackslashes -nocommands -novariables args
if {[llength $clinked]==0} {return 0}

if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set chan [lindex $args 4]
set txt [lrange $args 5 end]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who


 regsub -all {!PD!} $txt \. txt
 regsub -all {!CO!} $txt \: txt
 regsub -all {!SQ!} $txt \' txt
 regsub -all {!QL!} $txt \; txt
 regsub -all {!QT!} $txt \" txt
 regsub -all {!LT!} $txt \< txt
 regsub -all {!GT!} $txt \> txt
 regsub -all {!LP!} $txt \( txt
 regsub -all {!RP!} $txt \) txt
 regsub -all {!LB!} $txt \{ txt
 regsub -all {!RB!} $txt \} txt
 regsub -all {!LF!} $txt \[ txt
 regsub -all {!RF!} $txt \] txt
 regsub -all {!SL!} $txt \\ txt
 regsub -all {!SP!} $txt " " txt
 set what $txt

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                           set txtout $clink_format(public)
                           regsub -all {%C%} $txtout \003 txtout
                           regsub -all {%B%} $txtout \002 txtout
                           regsub -all {%A%} $txtout \001 txtout
                           regsub -all {%CHAN%} $txtout $chan txtout
                           regsub -all {%NICK%} $txtout $who txtout
                           regsub -all {%SNET%} $txtout $sn txtout
                           regsub -all {%NET%} $txtout $n txtout
                           regsub -all {%TEXT%} $txtout $what txtout
                           regsub -all {!AM!} $txtout {\&} txtout
                           regsub -all {!DS!} $txtout {$} txtout
                           putserv "PRIVMSG $tochan :$txtout"
                          }
                         }

return 0
}

proc out_cspy {from host chan format txt} {
global cspy cspyed cspy cspy_format cspy_
 subst -nobackslashes -nocommands -novariables args

 if {![info exists cspy_($format)]} {putlog "SPY: Fatal error: no linking switch for $format" ; return 0}
 if {![info exists cspy_format($format)]} {putlog "SPY: Fatal error: no format for $format" ; return 0}

 if {$cspy_($format)==0} {return 0}
 regsub -all {!SL!} $from \\ from
 regsub -all {!RB!} $from \} from
 regsub -all {!LB!} $from \{ from


 regsub -all {!PD!} $txt \. txt ; regsub -all {!CO!} $txt \: txt
 regsub -all {!SQ!} $txt \' txt ; regsub -all {!QL!} $txt \; txt
 regsub -all {!QT!} $txt \" txt ; regsub -all {!LT!} $txt \< txt
 regsub -all {!GT!} $txt \> txt ; regsub -all {!LP!} $txt \( txt
 regsub -all {!RP!} $txt \) txt ; regsub -all {!LB!} $txt \{ txt
 regsub -all {!RB!} $txt \} txt ; regsub -all {!LF!} $txt \[ txt
 regsub -all {!RF!} $txt \] txt ; regsub -all {!SL!} $txt \\ txt
 regsub -all {!SP!} $txt " " txt
# regsub -all {!AM!} $txt {\&} txt
 set what $txt

set cspy_doit [get_cspy $chan]

if {($cspy_doit != "")} {
  set txtout $cspy_format($format)
  regsub -all {%C%} $txtout \003 txtout
  regsub -all {%B%} $txtout \002 txtout
  regsub -all {%A%} $txtout \001 txtout
  regsub -all {%SCHAN%} $txtout $chan txtout
  regsub -all {%DCHAN%} $txtout $cspy_doit txtout
  regsub -all {%NICK%} $txtout $from txtout
  regsub -all {%TEXT%} $txtout $what txtout
  regsub -all {%TEXT1%} $txtout [lindex $what 0] txtout
  regsub -all {%TEXT2%} $txtout [lrange $what 1 end] txtout
  regsub -all {%HOST%} $txtout $host txtout
  regsub -all {!AM!} $txtout {\&} txtout
  regsub -all {!DS!} $txtout {$} txtout
  putserv "PRIVMSG $cspy_doit :$txtout"
                         }

return 0
}

proc get_clink {chan danet} {
global clinked network
set clink_doit -1
set looper 0
set maxclink [llength $clinked]
incr maxclink 1
while {($looper < $maxclink)} {
 set test_chan [lindex $clinked $looper]
 set test_chan [lindex $test_chan 0]
  if {([string toupper $test_chan]) ==
       ([string toupper $chan])} {set clink_doit $looper}
        incr looper 1
                                        }
if {($danet == $network)} {set clink_doit 0}
return $clink_doit
}

proc is_clink {chan} {
global clinked network
if {![info exists clinked]} {return 0}
set clink_doit 0
set looper 0
set maxclink [llength $clinked]
while {($looper < $maxclink)} {
 set test_chan [lindex $clinked $looper]
 set test_chan [lindex $test_chan 1]
  if {([string toupper $test_chan]) ==
      ([string toupper $chan])} {set clink_doit 1}
        incr looper 1
                                        }
return $clink_doit
}

proc is_cspy {chan hand} {
global cspyed network
if {![info exists cspyed]} {return 0}
set clink_doit 0
set looper 0
set maxclink [llength $cspyed]
while {($looper < $maxclink)} {
 set test_chan [lindex $cspyed $looper]
 set test_chan [lindex $test_chan 0]
  if {([string toupper $test_chan]) ==
      ([string toupper $chan])} {set clink_doit 1}
        incr looper 1
                                        }
return $clink_doit
}

proc get_cspy {chan} {
global cspyed network
if {![info exists cspyed]} {return ""}
set clink_doit ""
set looper 0
set maxclink [llength $cspyed]
while {($looper < $maxclink)} {
 set test_chan [lindex $cspyed $looper]
 set test_chan [lindex $test_chan 0]
  if {([string toupper $test_chan]) ==
      ([string toupper $chan])} {set clink_doit [lindex [lindex $cspyed $looper] 1]}
        incr looper 1
                                        }
return $clink_doit
}


bind join - ***** link_join
proc link_join {nick uhost hand channel} {
 global clinked clink network snet botnetid clink_
  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel join ""}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $channel])} {netlinkout "c_join $botnetid $network $snet $nick $uhost $channel"}
}

bind bot - c_join in_join
proc in_join {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linkjoin) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
 set txtout $clink_format(join)
 regsub -all {%C%} $txtout \003 txtout
 regsub -all {%B%} $txtout \002 txtout
 regsub -all {%A%} $txtout \001 txtout
 regsub -all {%CHAN%} $txtout $chan txtout
 regsub -all {%NICK%} $txtout $who txtout
 regsub -all {%SNET%} $txtout $sn txtout
 regsub -all {%NET%} $txtout $n txtout
 regsub -all {%HOST%} $txtout $host txtout
   putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}

bind part -|- ****** link_part
proc link_part {nick uhost hand channel {msg ""}} {
 global clinked clink network snet botnetid clink_
  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

#putlog "link_part $nick $uhost $hand $channel $msg"
if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel part $msg}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $channel])} {netlinkout "c_part $botnetid $network $snet $nick $uhost $channel"}
}

bind bot - c_part in_part
proc in_part {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linkpart) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                         set txtout $clink_format(part)
                         regsub -all {%C%} $txtout \003 txtout
                         regsub -all {%B%} $txtout \002 txtout
                         regsub -all {%A%} $txtout \001 txtout
                         regsub -all {%CHAN%} $txtout $chan txtout
                         regsub -all {%NICK%} $txtout $who txtout
                         regsub -all {%SNET%} $txtout $sn txtout
                         regsub -all {%NET%} $txtout $n txtout
                         regsub -all {%HOST%} $txtout $host txtout
                         putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}

bind sign - ***** link_sign
proc link_sign {nick uhost hand channel text} {
 global clinked clink network snet botnetid clink_

  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel signoff $text}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $channel])} {netlinkout "c_sign $botnetid $network $snet $nick $uhost $channel $text"}
}

bind bot - c_sign in_sign
proc in_sign {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linksign) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set text [lrange $args 6 end]

set clink_doit [get_clink $chan $n]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                          set txtout $clink_format(signoff)
                          regsub -all {%C%} $txtout \003 txtout
                          regsub -all {%B%} $txtout \002 txtout
                          regsub -all {%A%} $txtout \001 txtout
                          regsub -all {%CHAN%} $txtout $chan txtout
                          regsub -all {%NICK%} $txtout $who txtout
                          regsub -all {%SNET%} $txtout $sn txtout
                          regsub -all {%NET%} $txtout $n txtout
                          regsub -all {%TEXT%} $txtout $text txtout
                          regsub -all {%HOST%} $txtout $host txtout
                          regsub -all {%COMMENT%} $txtout $text txtout
                          putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}


bind topc - ***** link_topc
proc link_topc {nick uhost hand channel text} {
 global clinked clink network snet botnetid link_topic clink_

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel topic $text}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}
if {$nick=="*"} {set nick "Server"}

  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

set link_topic([string tolower $channel]) "$text"
if {([is_clink $channel])} {netlinkout "c_topc $botnetid $network $snet $nick $uhost $channel $text"}
}

bind bot - c_topc in_topc
proc in_topc {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}

if {$clink_(linktopic) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set text [lrange $args 6 end]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                          set txtout $clink_format(topic)
                          regsub -all {%C%} $txtout \003 txtout
                          regsub -all {%B%} $txtout \002 txtout
                          regsub -all {%A%} $txtout \001 txtout
                          regsub -all {%CHAN%} $txtout $chan txtout
                          regsub -all {%NICK%} $txtout $who txtout
                          regsub -all {%SNET%} $txtout $sn txtout
                          regsub -all {%NET%} $txtout $n txtout
                          regsub -all {%TEXT%} $txtout $text txtout
                          regsub -all {%HOST%} $txtout $host txtout
                          regsub -all {%TOPIC%} $txtout $text txtout
                          putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}

bind kick - ***** link_kick
proc link_kick {nick uhost hand channel wkick text} {
 global clinked clink network snet botnetid clink_

  regsub -all {\\} $nick !SL! nick
 regsub -all {\}} $nick !LB! nick
 regsub -all {\{} $nick !RB! nick

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel kick "$wkick $text"}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $channel])} {netlinkout "c_kick $botnetid $network $snet $nick $uhost $channel $wkick $text"}
}

bind bot - c_kick in_kick
proc in_kick {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linkkick) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set wkick [lindex $args 6]
set text [lrange $args 7 end]

set clink_doit [get_clink $chan $n]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
 set txtout $clink_format(kick)
 regsub -all {%C%} $txtout \003 txtout
 regsub -all {%B%} $txtout \002 txtout
 regsub -all {%A%} $txtout \001 txtout
 regsub -all {%CHAN%} $txtout $chan txtout
 regsub -all {%NICK%} $txtout $wkick txtout
 regsub -all {%KICKER%} $txtout $who txtout
 regsub -all {%SNET%} $txtout $sn txtout
 regsub -all {%NET%} $txtout $n txtout
 regsub -all {%HOST%} $txtout $host txtout
 regsub -all {%COMMENT%} $txtout $text txtout
 putserv "PRIVMSG $tochan :$txtout"

                                             }
                      }
return 0
}

bind nick - ***** link_nick
proc link_nick {nick uhost hand channel text} {
 global clinked clink network snet botnetid clink_
  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

  regsub -all { } $text !SP! text
  regsub -all {\\} $text !SL! text
  regsub -all {\}} $text !LB! text
  regsub -all {\{} $text !RB! text

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel nick $text}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $channel])} {netlinkout "c_nick $botnetid $network $snet $nick $uhost $channel $text"}
}

bind bot - c_nick in_nick
proc in_nick {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linknick) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set text [lrange $args 6 end]

set clink_doit [get_clink $chan $n]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

 regsub -all {!SP!} $text " " text
 regsub -all {!SL!} $text \\ text
 regsub -all {!RB!} $text \} text
 regsub -all {!LB!} $text \{ text

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
 set txtout $clink_format(nick)
 regsub -all {%C%} $txtout \003 txtout
 regsub -all {%B%} $txtout \002 txtout
 regsub -all {%A%} $txtout \001 txtout
 regsub -all {%CHAN%} $txtout $chan txtout
 regsub -all {%NICK%} $txtout $who txtout
 regsub -all {%SNET%} $txtout $sn txtout
 regsub -all {%NET%} $txtout $n txtout
 regsub -all {%HOST%} $txtout $host txtout
 regsub -all {%NEWNICK%} $txtout $text txtout
 putserv "PRIVMSG $tochan :$txtout"

                                             }
                      }
return 0
}


bind mode - ***** link_mode

#1.6
proc link_mode {nick uhost hand channel modec {target ""}} {
#if 1.6, delete next line, uncomment previous line.
#proc link_mode {nick uhost hand channel text} 
 global clinked clink network snet botnetid clink_
  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

  regsub -all {\\} $target !SL! target
  regsub -all {\}} $target !LB! target
  regsub -all {\{} $target !RB! target
  regsub -all { } $target !SP! target

if {[is_cspy $channel $hand]} {out_cspy $nick $uhost $channel mode "$modec $target"}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $channel])} {return 0}
if {(![isvoice $nick $channel]) && ($clink_(onlyvoiced)==1)} {return 0}

if {$nick == ""} {set nick $uhost}

#1.6
set text "$modec $target"

if {([is_clink $channel])} {netlinkout "c_mode $botnetid $network $snet $nick $uhost $channel $text"}
}

bind bot - c_mode in_mode
proc in_mode {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linkmode) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set text [lrange $args 6 end]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

 regsub -all {!SP!} $text " " text
 regsub -all {!SL!} $text \\ text
 regsub -all {!RB!} $text \} text
 regsub -all {!LB!} $text \{ text

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
 set txtout $clink_format(mode)
 regsub -all {%C%} $txtout \003 txtout
 regsub -all {%B%} $txtout \002 txtout
 regsub -all {%A%} $txtout \001 txtout
 regsub -all {%CHAN%} $txtout $chan txtout
 regsub -all {%NICK%} $txtout $who txtout
 regsub -all {%SNET%} $txtout $sn txtout
 regsub -all {%NET%} $txtout $n txtout
 regsub -all {%MODE%} $txtout $text txtout
 regsub -all {%HOST%} $txtout $host txtout
 putserv "PRIVMSG $tochan :$txtout"

                                             }
                      }
return 0
}

bind ctcp - ACTION link_action
proc link_action {nick uhost hand dest key text} {
 global clinked clink network snet botnetid clink_

if {[string index $dest 0] != "#"} {return 0}
if {(![is_cspy $dest $hand]) && (![is_clink $dest])} {return 0}

 regsub -all {\\} $nick !SL! nick
 regsub -all {\}} $nick !LB! nick
 regsub -all {\{} $nick !RB! nick

 regsub -all { } $text !SP! text
 regsub -all {\\} $text !SL! text
 regsub -all {\<} $text !LT! text
 regsub -all {\>} $text !GT! text
 regsub -all {\"} $text !QT! text
 regsub -all {\(} $text !LP! text
 regsub -all {\)} $text !RP! text
 regsub -all {\{} $text !LB! text
 regsub -all {\}} $text !RB! text
 regsub -all {\[} $text !LF! text
 regsub -all {\]} $text !RF! text
 regsub -all {\;} $text !QL! text
 regsub -all {\:} $text !CO! text
 regsub -all {\.} $text !PD! text
 regsub -all {\&} $text !AM! text
 regsub -all {\$} $text !DS! text

if {[is_cspy $dest $hand]} {out_cspy $nick $uhost $dest public "$text"}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $dest])} {return 0}
if {(![isvoice $nick $dest]) && ($clink_(onlyvoiced)==1)} {return 0}
if {([is_clink $dest])} {
 netlinkout "c_action $botnetid $network $snet $nick $uhost $dest $key $text"
                        }
}

bind bot - c_action in_action
proc in_action {from com args} {
global botnetid clink clinked  clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linkaction) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set key [lindex $args 6]
set text [lrange $args 7 end]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

# regsub -all {!AM!} $text {\&} text
 regsub -all {!PD!} $text \. text
 regsub -all {!CO!} $text \: text
 regsub -all {!SQ!} $text \' text
 regsub -all {!QL!} $text \; text
 regsub -all {!QT!} $text \" text
 regsub -all {!LT!} $text \< text
 regsub -all {!GT!} $text \> text
 regsub -all {!LP!} $text \( text
 regsub -all {!RP!} $text \) text
 regsub -all {!LB!} $text \{ text
 regsub -all {!RB!} $text \} text
 regsub -all {!LF!} $text \[ text
 regsub -all {!RF!} $text \] text
 regsub -all {!SL!} $text \\ text
 regsub -all {!SP!} $text " " text

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                           set txtout $clink_format(action)
                           regsub -all {%C%} $txtout \003 txtout
                           regsub -all {%B%} $txtout \002 txtout
                           regsub -all {%A%} $txtout \001 txtout
                           regsub -all {%CHAN%} $txtout $chan txtout
                           regsub -all {%NICK%} $txtout $who txtout
                           regsub -all {%SNET%} $txtout $sn txtout
                           regsub -all {%NET%} $txtout $n txtout
                           regsub -all {%TEXT%} $txtout $text txtout
                          regsub -all {!AM!} $txtout {\&} txtout
                          regsub -all {!DS!} $txtout {$} txtout
                          putserv "PRIVMSG $tochan :$txtout"
                                             }
                      }
return 0
}

bind ctcp - SOUND link_sound
proc link_sound {nick uhost hand dest key text} {
 global clinked clink network snet botnetid clink_
if {[string index $dest 0] != "#"} {return 0}

  regsub -all {\\} $nick !SL! nick
  regsub -all {\}} $nick !LB! nick
  regsub -all {\{} $nick !RB! nick

if {[is_cspy $dest $hand]} {out_cspy $nick $uhost $dest sound "key $text"}

if {([matchattr $hand $clink_(ignoreflag)]) || ([matchchanattr $hand |$clink_(ignoreflag) $dest])} {return 0}
if {(![isvoice $nick $dest]) && ($clink_(onlyvoiced)==1)} {return 0}

if {([is_clink $dest])} {netlinkout "c_sound $botnetid $network $snet $nick $uhost $dest $key $text"}

}

bind bot - c_sound in_sound
proc in_sound {from com args} {
global botnetid clink clinked clink_ clink_format
if {![authnetlink $from]} {return 0}
if {$clink_(linksound) != 1} {return 0}

set args [lindex $args 0]
set nid [lindex $args 0]
set n [lindex $args 1]
set sn [lindex $args 2]
set who [lindex $args 3]
set host [lindex $args 4]
set chan [lindex $args 5]
set key [lindex $args 6]
set wav [lindex $args 7]
set text [lrange $args 8 end]
 regsub -all {!SL!} $who \\ who
 regsub -all {!RB!} $who \} who
 regsub -all {!LB!} $who \{ who

set clink_doit [get_clink $chan $n]

if {($clink_doit != -1)} {
                       set tochan [lindex [lindex $clinked $clink_doit] 1]
                       if {($botnetid == $nid)} {
                           set txtout $clink_format(sound)
                           regsub -all {%C%} $txtout \003 txtout
                           regsub -all {%B%} $txtout \002 txtout
                           regsub -all {%A%} $txtout \001 txtout
                           regsub -all {%CHAN%} $txtout $chan txtout
                           regsub -all {%NICK%} $txtout $who txtout
                           regsub -all {%SNET%} $txtout $sn txtout
                           regsub -all {%NET%} $txtout $n txtout
                           regsub -all {%TEXT%} $txtout $text txtout
                           regsub -all {%WAV%} $txtout $wav txtout
                           putserv "privmsg $tochan :$txtout"
                                               }
                      }
return 0
}


# isnumber taken from alltools.tcl
proc isnum {string} {
  if {([string compare $string ""]) && (![regexp \[^0-9\] $string])} then {return 1}
  return 0
}

proc cout {nick txt} {
 if {[isnum $nick]} {putidx $nick "$txt"} else {putserv "NOTICE $nick :$txt"}
}
proc coutm {nick txt} {
 if {[isnum $nick]} {putidx $nick "$txt"} else {putserv "PRIVMSG $nick :$txt"}
}

bind raw - "251" get_lusers
bind raw - "252" get_lusers
bind raw - "253" get_lusers
bind raw - "254" get_lusers
bind raw - "255" get_lusers

proc get_lusers {from key text} {
global snet netlink_lusers botnetid network

if {[info exists netlink_lusers([string tolower $network])]} {
 set frombot [lindex $netlink_lusers([string tolower $network]) 0]
 set fromnet [lindex $netlink_lusers([string tolower $network]) 1]
 set fromwho [lindex $netlink_lusers([string tolower $network]) 2]
 set serverinfo [lrange $text 1 end]
 if {[string index $serverinfo 0]==":"} {set serverinfo [string range $serverinfo 1 end]}
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (LUSERS:$network) $serverinfo"
 if {$key == "255"} {unset netlink_lusers([string tolower $network])}
 return 1
 }
 return 0
}


##### MSG LUSERS ###########################################################
bind dcc $clink_(lusersaccess) cnlusers dcc_cnlusers
proc dcc_cnlusers {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
# pub_cnlist $idx * $hand $chan $arg
 msg_lusers $idx * $hand $arg
}

bind pub $clink_(lusersaccess) [cmdchar]cnlusers pub_cnlusers
proc pub_cnlusers {nick uhost hand channel rest} {
global botnetid network
msg_lusers $nick $uhost $hand $rest
}

bind msg $clink_(lusersaccess) lusers msg_lusers
proc msg_lusers {nick uhost hand rest} {
global botnetid network

set netto [lindex $rest 0]
set text [lrange $rest 2 end]
if {![validnetmap $netto]} {cout $nick "Invalid network: $netto"
                            return 0}
if {[llength $rest] != 1} {cout $nick "Calling Syntax: LUSERS Network"; return 0}

cout $nick "Attempting to get LUSERS information for $netto"
netlinkout "lusers $botnetid $network $netto $hand"

                                          }

bind bot - lusers get_bot_lusers
proc get_bot_lusers {from com args} {
global chan botnetid network botnick netlink_lusers
 subst -nobackslashes -nocommands -novariables args
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set fnet [string tolower [lindex $args 1]]
set net [string tolower [lindex $args 2]]
set hand [lindex $args 3]

if {($botnetid == $nid) && ($net == [string tolower $network])} {
set netlink_lusers([string tolower $network]) "$from $fnet $hand"
putserv "LUSERS"}
return 0
}
#####

#תש‏שת  RAW IRC: Surrey.UK.EU.Undernet.Org 401 DrN asdkjahsd :No such nick
bind raw - "401" whois_nonick
proc whois_nonick {from key text} {
global snet netlink_whois botnetid

 set fornick [lindex $text 1]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) [lrange $text 1 end]"
 return 1
 }
 return 0
}


bind raw - "317" whois_idle
proc whois_idle {from key text} {
global snet netlink_whois botnetid

 set fornick [lindex $text 1]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
if {[isnum [lindex $text 3]]} {
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) <Idle> [tdiff2 [lindex $text 2]]"
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) <Signed On> [ctime [lindex $text 3]]"
                             } else {
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) <Idle> [tdiff2 [lindex $text 2]]"
                                    }
 return 1
 }
 return 0
}

bind raw - "301" whois_away
proc whois_away {from key text} {
global snet netlink_whois botnetid
 set fornick [lindex $text 1]
 set away [lrange $text 3 end]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) <Away> $fornick $away"
 return 1
 }
 return 0
}

bind raw - "312" whois_server
proc whois_server {from key text} {
global snet netlink_whois botnetid
 set fornick [lindex $text 1]
 set server [lindex $text 2]
 set serverinfo [string range [lrange $text 3 end] 1 end]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) <Server> $server ($serverinfo)"
 return 1
 }
 return 0
}

bind raw - "313" whois_oper
proc whois_oper {from key text} {
global snet netlink_whois botnetid
 set fornick [lindex $text 1]
 set oper [string range [lrange $text 2 end] 1 end]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) $fornick $oper"
 return 1
 }
 return 0
}


bind raw - "311" whois_header
proc whois_header {from key text} {
global snet netlink_whois botnetid
 set fornick [lindex $text 1]
 set account [lindex $text 2]
 set sitemask [lindex $text 3]
 set realname [string range [lrange $text 5 end] 1 end]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) $fornick $account@$sitemask"
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) \<Realname\> $realname"
 timer 1 "unset netlink_whois([string tolower $fornick])"
 return 1
 }
 return 0

}

bind raw - "319" whois_channels
proc whois_channels {from key text} {
global netlink_whois snet botnetid network netlink_whois
set fornick [lindex $text 1]
if {[info exists netlink_whois([string tolower $fornick])]} {
 set frombot [lindex $netlink_whois([string tolower $fornick]) 0]
 set fromnet [lindex $netlink_whois([string tolower $fornick]) 1]
 set fromwho [lindex $netlink_whois([string tolower $fornick]) 2]
 putbot $frombot "unotto $botnetid $fromnet * $fromwho (WHOIS:$fornick@$snet) \<Channels\> [string range [lrange $text 2 end] 1  end]"
 return 1
 }
 return 0
}

##### MSG WhoIs ###########################################################
bind dcc o cnwhois dcc_cnwhois
proc dcc_cnwhois {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
# pub_cnlist $idx * $hand $chan $arg
 msg_whois $idx * $hand $arg
}

bind pub $clink_(whoisaccess) [cmdchar]cnwhois pub_cnwhois
proc pub_cnwhois {nick uhost hand channel rest} {
global botnetid network
msg_whois $nick $uhost $hand $rest
#  cout $nick "Attempting to get channel list for $channel across botnet"
#  netlinkout "getcnlist $botnetid $network $hand $nick $channel $rest"
}

bind msg $clink_(whoisaccess) whois msg_whois
proc msg_whois {nick uhost hand rest} {
global botnetid network
set cmdto [lindex $rest 0]
set netto [lindex $rest 1]
set text [lrange $rest 2 end]
if {[llength $rest] != 2} {cout $nick "Calling Syntax: WHOIS Nick OnNetwork"; return 0}
if {![validnetmap $netto]} {cout $nick "Invalid network: $netto"
                            return 0}

cout $nick "Attempting to get WHOIS information for $cmdto on $netto"
netlinkout "whois $botnetid $network $netto $hand $cmdto $text"

                                          }

bind bot - whois get_bot_whois
proc get_bot_whois {from com args} {
global chan botnetid network botnick netlink_whois
 subst -nobackslashes -nocommands -novariables args
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set fnet [string tolower [lindex $args 1]]
set net [string tolower [lindex $args 2]]
set hand [lindex $args 3]
set idx [lindex $args 4]
set action [lrange $args 5 end]

if {($botnetid == $nid) && ($net == [string tolower $network])} {
set netlink_whois([string tolower $idx]) "$from $fnet $hand"
putserv "WHOIS $idx"}
return 0
}


##### MSG Link ###########################################################
bind msg $clink_(netlinkaccess) netlink msg_netlink
proc msg_netlink {nick uhost hand rest} {
global botnetid network

set cmdto [lindex $rest 0]
set netto [lindex $rest 1]
set text [lrange $rest 2 end]
if {![validnetmap $netto]} {cout $nick "Invalid network: $netto"
                            return 0}
if {[llength $rest] < 3} {cout $nick "Calling Syntax: netlink ToNick ToNetwork Your Message"; return 0}

cout $nick "Attempting to deliver message for $cmdto on $netto"
netlinkout "umsgto $botnetid $netto $hand $cmdto Incomming msg from $nick on $network:"
netlinkout "umsgto $botnetid $netto $hand $cmdto $text"
netlinkout "umsgto $botnetid $netto $hand $cmdto To reply: /msg %botnick% netlink $nick $network your message"

                                          }


##### !ADDCLINK ##########################################################

bind dcc m addclink dcc_addclink
proc dcc_addclink {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_addclink $idx * $hand $chan $arg
}

bind pub m [cmdchar]addclink pub_addclink
proc pub_addclink {nick uhost hand channel rest} {
global clinked
set addwhat [lrange $rest 0 end]
if {($addwhat == "")} {cout $nick "Calling Syntax: [cmdchar]addclink srcchan deschan"
                       return 1}

lappend clinked $addwhat

cout $nick "Added linked channel data #[expr [llength $clinked] - 1] - $addwhat"
clink_write
}

##### !ADDCSPY ##########################################################

bind dcc m addcspy dcc_addcspy
proc dcc_addcspy {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_addcspy $idx * $hand $chan $arg
}

bind pub m [cmdchar]addcspy pub_addcspy
proc pub_addcspy {nick uhost hand channel rest} {
global cspyed
set addwhat [lrange $rest 0 end]
if {($addwhat == "")} {cout $nick "Calling Syntax: [cmdchar]addcspy  srcchan deschan"
                       return 1}

lappend cspyed $addwhat

cout $nick "Added channel spy data #[expr [llength $cspyed] - 1] - $addwhat"
clink_write
}


##### DELCLINK ###########################################################

bind dcc m delclink dcc_delclink
proc dcc_delclink {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_delclink $idx * $hand $chan $arg
}

bind pub m [cmdchar]delclink pub_delclink
proc pub_delclink {nick uhost hand channel rest} {
global clinked
set delwhat [lindex $rest 0]
if {($delwhat == "")} {cout $nick "Calling Syntax: [cmdchar]delclink #"
                       return 1}
if {($delwhat < 0) || ($delwhat > [llength $clinked])} {
 cout $nick "You specified an invalid reference."
 return 1
                                                             }
 set clink_temp $clinked
 unset clinked
 set deleted [lindex $clink_temp $delwhat]

set looper 0
while {($looper < [llength $clink_temp])} {
  if {($looper != $delwhat)} {lappend clinked [lindex $clink_temp $looper]}
            incr looper 1
                                             }
cout $nick "Deleted Channel Linking data #$delwhat - $deleted"
clink_write
}

##### DELCSPY ###########################################################

bind dcc m delcspy dcc_delcspy
proc dcc_delcspy {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_delcspy $idx * $hand $chan $arg
}

bind pub m [cmdchar]delcspy pub_delcspy
proc pub_delcspy {nick uhost hand channel rest} {
global cspyed
set delwhat [lindex $rest 0]
if {($delwhat == "")} {cout $nick "Calling Syntax: [cmdchar]delcspy #"
                       return 1}
if {($delwhat < 0) || ($delwhat > [llength $cspyed])} {
 cout $nick "You specified an invalid reference."
 return 1
                                                             }
 set clink_temp $cspyed
 unset cspyed
 set deleted [lindex $clink_temp $delwhat]

set looper 0
while {($looper < [llength $clink_temp])} {
  if {($looper != $delwhat)} {lappend cspyed [lindex $clink_temp $looper]}
            incr looper 1
                                             }
cout $nick "Deleted Channel Spy data #$delwhat - $deleted"
clink_write
}

##### !LISTCLINK ##########################################################
bind dcc m listclink dcc_listclink
proc dcc_listclink {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_listclink $idx * $hand $chan $arg
}

bind pub o [cmdchar]listclink pub_listclink
proc pub_listclink {nick uhost hand channel rest} {
global clinked reverse
clink_load
if {![info exists clinked]} {cout $nick "Currentlly no channels linked." ; return 0}
if {[llength $clinked]==0} {cout $nick "Currentlly no channels linked." ; return 0}
cout $nick "Listing Channel Linking Database"
set looper 0
while {($looper < [llength $clinked])} {
  cout $nick "${reverse} $looper ${reverse} : [lindex $clinked $looper]"
            incr looper 1
                                       }
cout $nick "--EOF"
}

##### !LISTCSPY ##########################################################
bind dcc m listcspy dcc_listcspy
proc dcc_listcspy {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_listcspy $idx * $hand $chan $arg
}

bind pub o [cmdchar]listcspy pub_listcspy
proc pub_listcspy {nick uhost hand channel rest} {
global cspyed reverse
clink_load
if {![info exists cspyed]} {cout $nick "Currentlly no channel spies." ; return 0}
if {[llength $cspyed]==0} {cout $nick "Currentlly no channel spies." ; return 0}
cout $nick "Listing Channel Spy Database"
set looper 0
while {($looper < [llength $cspyed])} {
  cout $nick "${reverse} $looper ${reverse} : [lindex $cspyed $looper]"
            incr looper 1
                                       }
cout $nick "--EOF"
}

#####

bind dcc m cnlist dcc_cnlist
proc dcc_cnlist {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_cnlist $idx * $hand $chan $arg
}

bind pub - [cmdchar]cnlist pub_cnlist
proc pub_cnlist {nick uhost hand channel rest} {
global botnetid network
  cout $nick "Attempting to get channel list for $channel across botnet"
  netlinkout "getcnlist $botnetid $network $hand $nick $channel $rest"
}

bind bot - getcnlist get_bot_cnlist
proc get_bot_cnlist {from com args} {
global chan botnetid network botnick clink_ clinked
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set net [lindex $args 1]
set hand [lindex $args 2]
set idx [lindex $args 3]
set chan [lindex $args 4]
set action [lrange $args 5 end]
if {$botnetid == $nid} {

#whanker
set clink_doit [get_clink $chan *]
if {$clink_doit == -1} {
netlinkout "unotto $botnetid $net $hand $idx $botnick/$network: Sorry, unable to find linking data for $chan"
return 0
                       }
set chan [lindex [lindex $clinked $clink_doit] 1]


if {[validchan $chan] == 1} {

set lusers [chanlist $chan]
set lout ""
foreach user $lusers {
 set lmode ""
 if {$clink_(showusermode)==1} {
  if {[isvoice $user $chan]} {set lmode "+"}
  if {[isop $user $chan]} {set lmode "@"}
                               }
 lappend lout $lmode$user
 if {($clink_(showusersplit)==1) && ([onchansplit $user $chan])} {append lout "(split)"}
 if {$clink_(splituserlist)>0} {
  if {[string length $lout]>$clink_(splituserlist)} {
   netlinkout "unotto $botnetid $net $hand $idx $botnick/$network ($chan) $lout"
   set lout ""
                                                    }
                               }
}
if {[string length $lout]>0} {
 netlinkout "unotto $botnetid $net $hand $idx $botnick/$network ($chan) $lout"
                             }
                            } {
netlinkout "unotto $botnetid $net $hand $idx $botnick/$network: Sorry, I'm not on $chan"
}
}
return 0
}


#####
bind dcc o cntopics dcc_cntopics
proc dcc_cntopics {hand idx arg} {
 set chan [string tolower [lindex [console $idx] 0]]
 pub_cntopics $idx * $hand $chan $arg
}

bind pub - [cmdchar]cntopics pub_cntopics
proc pub_cntopics {nick uhost hand channel rest} {
global botnetid network
  cout $nick "Attempting to get topics for $channel across botnet"
  netlinkout "gettopiclist $botnetid $network $hand $nick $channel $rest"
}

bind bot - gettopiclist get_bot_topiclist
proc get_bot_topiclist {from com args} {
global chan botnetid network botnick clink_ link_topic clinked
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set net [lindex $args 1]
set hand [lindex $args 2]
set idx [lindex $args 3]
set chan [lindex $args 4]
set action [lrange $args 5 end]
if {$botnetid == $nid} {
set clink_doit [get_clink $chan $net]
if {$clink_doit == -1} {
netlinkout "unotto $botnetid $net $hand $idx $botnick/$network: Sorry, unable to find linking data for $chan"
return 0
                       }
set chan [lindex [lindex $clinked $clink_doit] 1]

if {[validchan $chan] == 1} {
set thetopic "No topic is set"

if {[info exists link_topic([string tolower $chan])]} {set thetopic $link_topic([string tolower $chan])}

netlinkout "unotto $botnetid $net $hand $idx $network: ($chan) $thetopic"

                            } {
netlinkout "unotto $botnetid $net $hand $idx $botnick/$network: Sorry, I'm not on $chan"
                              }
}
return 0
}

#####

bind bot - unotto get_bot_unot
proc get_bot_unot {from com args} {
global chan botnetid network botnick
if {![authnetlink $from]} {return 0}
#putlog "$from $com $args"
set args [lindex $args 0]
set nid [lindex $args 0]
set net [string tolower [lindex $args 1]]
set hand [lindex $args 2]
set idx [lindex $args 3]
set action [lrange $args 4 end]
#putlog "nid:$nid net:$net hand:$hand to:$idx text:$action"
if {($botnetid == $nid) && ($net == [string tolower $network])} {
  regsub -all {%botnick%} $action $botnick action
 cout $idx "$action"
}
# netid tonet from to text
return 0
}

bind bot - umsgto get_bot_umsg
proc get_bot_umsg {from com args} {
global chan botnetid network botnick
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set nid [lindex $args 0]
set net [string tolower [lindex $args 1]]
set hand [lindex $args 2]
set idx [lindex $args 3]
set action [lrange $args 4 end]
if {($botnetid == $nid) && ($net == [string tolower $network])} {
  regsub -all {%botnick%} $action $botnick action

 coutm $idx "$action"
}
#umsgto netid tonet from to text
return 0
}

proc tdiff {t} {
 return [dotdiff 1 $t]
}
proc tdiff2 {t} {
 return [dotdiff 2 $t]
}

proc dotdiff {v ltime} {
 if {$v == 1} {
               set m_ "m"
               set h_ "h"
               set d_ "d"
               set s_ "s"
              } else {
               set m_ " minute"
               set h_ " hour"
               set d_ " day"
               set s_ " second"
                     }
set days 0
set hours 0
set minutes 0
set seconds 0
set after 0
set out ""

set seconds [expr $ltime % 60]
set ltime [expr ($ltime - $seconds) / 60]
set minutes [expr $ltime % 60]
set ltime [expr ($ltime - $minutes) / 60]
set hours [expr $ltime % 24]
set days [expr ($ltime - $hours) / 24]
if {$v == 1} {
if {$days > 0} {append out "${days}$d_ "}
if {$hours > 0} {append out "${hours}$h_ "}
if {$minutes > 0} {append out "${minutes}$m_ "}
if {$seconds > 0} {append out "${seconds}$s_ "}
             } else {
 if {$days > 0} {append out "${days}$d_[thes $days] "}
 if {$hours > 0} {append out "${hours}$h_[thes $hours] "}
 if {$minutes > 0} {append out "${minutes}$m_[thes $minutes] "}
 if {$seconds > 0} {append out "${seconds}$s_[thes $seconds] "}
                    }
return "$out"
}

proc thes {num} {
if {$num == 1} {return ""} else {return "s"}
}



proc clink_write {} {
   global clinkfile clinked clink_changed clink cspy cspyed cspy_

   set fd [open $clinkfile w]
   puts $fd "$clink"
   set looper 0
if {[info exists clinked]} {
 while {($looper < [llength $clinked])} {
             puts $fd "[lindex $clinked $looper]"
             incr looper 1
                                        }
                              }
   close $fd

   set fd [open $cspy_(datafile) w]
   puts $fd "$cspy"
   set looper 0
if {[info exists cspyed]} {
 while {($looper < [llength $cspyed])} {
             puts $fd "[lindex $cspyed $looper]"
             incr looper 1
                                        }
                              }
   close $fd

   set clinked_changed 0
   return 1
}

proc clink_load {} {
   global clinked clinkfile clink cspyed cspy cspy_

   if {[info exists cspyed]} {unset cspyed}
   if {[info exists clinked]} {unset clinked}
   set clinked "" ; set cspyed ""
   if {[catch {set fd [open $clinkfile r]}] != 0} {return 0}
   set clink [gets $fd]
   while {![eof $fd]} {
      set inp [gets $fd]
      if {[eof $fd]} {break}
      if {[string trim $inp " "] == ""} {continue}
      lappend clinked [lrange $inp 0 end]
   }
   close $fd

   if {[catch {set fd [open $cspy_(datafile) r]}] != 0} {return 0}
   set cspy [gets $fd]
   while {![eof $fd]} {
      set inp [gets $fd]
      if {[eof $fd]} {break}
      if {[string trim $inp " "] == ""} {continue}
      lappend cspyed [lrange $inp 0 end]
   }
   close $fd
   return 1
}
clink_load

bind pub o [cmdchar]cn pub_net
proc pub_net {nick uhost hand chan rest} {
global network botnick netcount
 putserv "PRIVMSG $chan :Hi! I'm $botnick, ${chan}'s channel bot. The funny stuff you see from me, like (\002$nick\002@SN), are people on other nets. I provide a channel link between this channel on $netcount nets."
 putserv "PRIVMSG $chan :To see who else is on the channel, type  !cnlist in the channel."
 return 0
}

bind pub - [cmdchar]whatnet pub_whatnet
proc pub_whatnet {nick uhost hand chan rest} {
global network
 putserv "PRIVMSG $chan :$nick: This net is named \"$network\" in my records."
 return 0
}

bind pub o|o [cmdchar]netop pub_netop
proc pub_netop {nick uhost hand chan rest} {
global network botnetid

set cmd [string tolower [string tolower [lindex $rest 0]]]
set cmdto [lindex $rest 1]
set netto [lindex $rest 2]
set reason [lrange $rest 3 end]

if {$cmd == "topic"} {set topic [lrange $rest 2 end]
                      set cmdto "topic"
                      set netto [lindex $rest 1]
                     }

if {($cmd == "help") || ($cmd == "")} {set cmd "help"
        cout $nick "Calling Syntax: [cmdchar]netop command nick/sitemask network/* \[reason\]"
        cout $nick "Commands implimented: help kick ban unban siteban unsiteban op deop voice devoice topic mode"
        return 0
                }
if {$reason == ""} {set reason "No Reason Supplied"}
if {$netto == ""} {cout $nick "Calling Syntax: [cmdchar]netop command nick/sitemask network \[reason\]"
                   return 0}
if {![validnetmap $netto] && ($netto != "*")} {cout $nick "Invalid network: $netto"
                            return 0}
switch $cmd { 
 "help" {cout $nick "Calling Syntax: [cmdchar]netop command nick/sitemask network \[reason\]"
         cout $nick "Commands implimented: help kick ban unban siteban unsiteban op deop voice devoice topic mode"
        }
 "kick" {if {[thisnet $netto]} {putserv "KICK $chan $cmdto :$reason"}
         if {![thisnet $netto]} {netlinkout "netop kick $botnetid $network $hand $nick $chan $cmdto $netto $reason"}
        }
 "ban" {#if {[thisnet $netto]} {putserv "BAN $chan $cmdto :$reason"}
         if {![thisnet $netto]} {netlinkout "netop ban $botnetid $network $hand $nick $chan $cmdto $netto $reason"}
        }
 "unban" {#if {[thisnet $netto]} {putserv "BAN $chan $cmdto :$reason"}
         if {![thisnet $netto]} {netlinkout "netop unban $botnetid $network $hand $nick $chan $cmdto $netto $reason"}
        }
 "siteban" {#if {[thisnet $netto]} {putserv "BAN $chan $cmdto :$reason"}
         if {![thisnet $netto]} {netlinkout "netop siteban $botnetid $network $hand $nick $chan $cmdto $netto $reason"}
        }
 "unsiteban" {#if {[thisnet $netto]} {putserv "BAN $chan $cmdto :$reason"}
         if {![thisnet $netto]} {netlinkout "netop unban $botnetid $network $hand $nick $chan $cmdto $netto $reason"}
        }
 "op" {if {![thisnet $netto]} {netlinkout "netop op $botnetid $network $hand $nick $chan $cmdto $netto $reason"}}
 "deop" {if {![thisnet $netto]} {netlinkout "netop deop $botnetid $network $hand $nick $chan $cmdto $netto $reason"}}
 "voice" {if {![thisnet $netto]} {netlinkout "netop voice $botnetid $network $hand $nick $chan $cmdto $netto $reason"}}
 "devoice" {if {![thisnet $netto]} {netlinkout "netop devoice $botnetid $network $hand $nick $chan $cmdto $netto $reason"}}
 "topic" {if {![thisnet $netto]} {netlinkout "netop topic $botnetid $network $hand $nick $chan $cmdto $netto $topic"}}
 "mode" {if {![thisnet $netto]} {netlinkout "netop mode $botnetid $network $hand $nick $chan $cmdto $netto $reason"}}
             }
}

bind bot - netop get_bot_netop
proc get_bot_netop {from com args} {
global chan botnetid network botnick ignorenetop
if {![authnetlink $from]} {return 0}
set args [lindex $args 0]
set cmd [lindex $args 0]
set nid [lindex $args 1]
set net [lindex $args 2]
set hand [lindex $args 3]
set idx [lindex $args 4]
set chan [lindex $args 5]
set cmdto [lindex $args 6]
set netto [lindex $args 7]
set reason [lrange $args 8 end]
if {$netto == "*"} {set netto $network}
if {($botnetid == $nid) && [thisnet $netto]} {

 set lchan [get_clink $chan $netto]
 if {($lchan == -1)} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $chan is not a linked channel"
                      return 0}
 if {![botisop $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) I am not OPed on $chan."
                        return 0}

 if {$ignorenetop == 1} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) I am not honoring netop requests."
                        return 0}


 switch $cmd {
  "kick" {putlog "NETOP:KICK from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                        return 0} else {
            putserv "KICK $chan $cmdto :($idx/$net) $reason"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was kicked on $chan"
                                       }
         }
  "ban" {putlog "NETOP:BAN from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                        return 0} else {
            set sitemask "*!*[string trimleft [maskhost [getchanhost $cmdto $chan]] *!]"
            putserv "MODE $chan +b $sitemask"
            putserv "KICK $chan $cmdto :($idx/$net) $reason"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was baned as $sitemask on $chan"
                                       }
         }
  "unban" {putlog "NETOP:UNBAN from $idx/$net on $cmdto/$chan"
          if {![ischanban $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not banned on $chan"
                        return 0} else {
            putserv "MODE $chan -b $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was unbaned on $chan"
                                       }
         }
  "siteban" {putlog "NETOP:SITEBAN from $idx/$net on $cmdto/$chan"
          if {[ischanban $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is allready banned on $chan"
                        return 0} else {
            putserv "MODE $chan +b $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was sitebaned on $chan"
                                       }
         }
  "op" {putlog "NETOP:OP from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                                       return 0}
          if {[isop $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is allready OPed on $chan"
                                    return 0}
            putserv "MODE $chan +o $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was OPed on $chan"
         }
  "deop" {putlog "NETOP:DEOP from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                                       return 0}
          if {![isop $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is allready deOPed on $chan"
                                    return 0}
            putserv "MODE $chan -o $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was deOPed on $chan"
         }
  "voice" {putlog "NETOP:VOICE from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                                       return 0}
          if {[isvoice $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is allready Voiced on $chan"
                                    return 0}
            putserv "MODE $chan +v $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was Voiced on $chan"
         }
  "devoice" {putlog "NETOP:DEVOICE from $idx/$net on $cmdto/$chan"
          if {![onchan $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is not on $chan"
                                       return 0}
          if {![isvoice $cmdto $chan]} {putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto is allready deVoiced on $chan"
                                    return 0}
            putserv "MODE $chan -v $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) $cmdto was deVoiced on $chan"
         }
   "topic" {putlog "NETOP:TOPIC from $idx/$net on $chan"
            putserv "TOPIC $chan :$reason"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) topic chaned on $chan to $reason"
           }
   "mode" {putlog "NETOP:MODE from $idx/$net on $chan"
            putserv "MODE $chan $cmdto"
            putbot $from "unotto $botnetid $net $hand $idx ($botnick/$network) modes for $chan set to $cmdto"
           }
             }
                                             }
return 0
}


# GHHFHAHAHJCAGJHDCAGBGOCAGJGNGBHEHFHCGFCAGDGIGJGMGE


proc authnetlink {cbot} {
global clink_
set auth 0
set ccbot [string tolower $cbot]
foreach bot [string tolower $clink_(botlist)] {
 if {$bot == $ccbot} {set auth 1}
                                              }
 if {$auth == 0} {putlog "-NETLINK- Data from Unathorized bot: $cbot"}
 return $auth
}

proc netlinkout {data} {
global clink_ botnick botnet-nick
 subst -nobackslashes -nocommands -novariables data
 set bn [string tolower $botnick]
 set bnn [string tolower ${botnet-nick}]
foreach bot [string tolower $clink_(botlist)] {
  if {($bn != $bot) && (${bnn} != $bot) && ([islinked $bot])} {putbot $bot "$data"}
                             }
}


proc thisnet {netto} {
global netmap network
 set netname $netto
 set netto [string tolower $netto]
 foreach nm $netmap {
  set snet [string tolower [lindex $nm 0]]
  set net [string tolower [lindex $nm 1]]
  if {($netto == $snet) || ($netto == $net)} {set netname $net}
                    }

if {([string tolower $network] == $netname)} {return 1} else {return 0}
}

proc getnetmap {netto} {
global netmap
 set netname $netto
 set netto [string tolower $netto]
 foreach nm $netmap {
  set snet [string tolower [lindex $nm 0]]
  set net [string tolower [lindex $nm 1]]
  if {($netto == $snet) || ($netto == $net)} {set netname [lindex $nm 1]}
                    }
return $netname
}

proc validnetmap {netto} {
global netmap
 set validnet 0
 set netto [string tolower $netto]
 foreach nm $netmap {
  set snet [string tolower [lindex $nm 0]]
  set net [string tolower [lindex $nm 1]]
  if {($netto == $snet) || ($netto == $net)} {set validnet 1}
                    }
return $validnet
}


if {![info exists network]} {die "netlink.tcl was not configured correctlly. Please define the network variable."}
if {![info exists snet]} {die "netlink.tcl was not configured correctlly. Please define the snet variable."}
if {![info exists botnetid]} {die "netlink.tcl was not configured correctlly. Please define the botnetid variable."}

putlog "NetLink $clinkver by David Proper (DrN) -: LoadeD :-"
return "NetLink $clinkver by David Proper (DrN) -: LoadeD :-"
