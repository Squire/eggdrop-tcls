#------------------------------------------------------------------------
# relay.tcl v1.0.0 - Send channel text from one network to another       
#   By: cl00bie <cl00bie@sorcery.net>
# relay.tcl v1.0.1 - EDITED by iamdeath @ Cricket #Undernet
# Fixed bugs and added more features and added color features.
#-------------------------------------------------------------------------
# This script takes text, joins, parts, etc.  From a channel on one network, 
# sends it to the other network on the same channel and visa versa.  This 
# script requires two bots which are botnetted (Instructions on how to link
# bots is beyond the scope of this document.  See BOTNET in the $eggdrop/doc
# directory.)
#
# Once your bots are netted, simply add the channels you'd like to relay
# to the channelList variable, fill in the server?List variables (as per
# (the instructions) and load this script on both bots.
#
# Proposed Enhancements:
#  o xkick - kick someone off the remote bot channel
#  o xwhois - do a /whois on the remote bot channel
#  o xmsg - send a private message to someone on the remote bot channel
#  o Synchronize topics
#------------------------------------------------------------------------  

# List of channels to relay between (lower case only!)
set channelList "#sharktech"

# This identifies the server information of the two networks you wish to
#  relay to each other.  There are three entries in each and they are as
#  follows:
#  0 - A unique pattern in each of the servers you use on a particular 
#      network.  (ex. all SorceryNet servers contain the word "sorcery"
#      in them, but none of the DALnet servers use this.)
#  1 - The name of the network as you'd like it to appear on the *other*
#      network (ex. <Dal-Bot> [SorceryNet] <Nickname> hi there everyone on
#      DALnet :))
#  2 - The name of the bot which sits on the *other* network.  (The bot you
#      want the informaiton sent *to*)
set server1List "EFnet EFnet Axis"
set server2List "EFnet EFnet Aphex"

# Procedure: send_across - sends the information from one network to 
#   the other.
proc send_across {cmd chan nick text} {
  global server channelList server1List server2List
  if {[lsearch $channelList [string tolower $chan]] != -1} {
    if  {[string first [lindex $server1List 0] $server] != -1} {
      set fromServer "[lindex $server1List 1]"
      set toBot "[lindex $server1List 2]" 
    } else {
      set fromServer "[lindex $server2List 1]"
      set toBot "[lindex $server2List 2]" 
    }
    set botMsg [concat $cmd $chan $fromServer $nick $text]
    putbot $toBot $botMsg
  }
}

proc send_nick {nick uhost hand chan newnick} {
  send_across "nick" $chan $nick $newnick
}
bind nick - * send_nick

proc recv_nick {frm_bot command arg} {
  putserv "PRIVMSG [lindex $arg 0] :\00303 *** [lindex $arg 2] is now known as [lrange $arg 3 end]\003"
}
bind bot - nick recv_nick

proc send_pubm {nick uhost hand chan text} {
  set cmd "pubm"
  if {[isop $nick $chan]} {set nick "\@$nick"}
  if {[isvoice $nick $chan]} {set nick "\+$nick"}
  send_across $cmd $chan $nick $text
}
bind pubm - * send_pubm

proc recv_pubm {frm_bot command arg} {
  putserv "PRIVMSG [lindex $arg 0] :\<[lindex $arg 2]\> [lrange $arg 3 end]"
}
bind bot - pubm recv_pubm

proc send_action {nick uhost hand chan keyw text} {
  send_across "act" $chan $nick $text
}
bind ctcp - "ACTION" send_action

proc recv_action {frm_bot command arg} {
  putserv "PRIVMSG [lindex $arg 0] :\00306\* [lindex $arg 2] [lrange $arg 3 end]\003"
}
bind bot - act recv_action

putlog "relay 1.0.0 by: cl00bie <cl00bie@sorcery.net> edited by: iamdeath"
