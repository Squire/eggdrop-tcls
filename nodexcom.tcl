##########################################################################################################
##########################################################################################################
### Custom Channel Command Script By Squire ### This script quite obviously is for channel commands       ##
############################################# such as .op .deop and so forth. The security it will use, ## 
############################################# is that it will check what their flags are on the channel ##
############################################# through the bot.											##
##########################################################################################################
##########################################################################################################
##    You might want to change some of the flags that control the binds if you know what your doing.    ##
##########################################################################################################
bind msg p|p auth msg_auth             
bind msg p|p deauth msg_deauth         
bind sign p|p * sign_deauth            
bind part p|p * part_deauth            
bind pub -|- .version pub_version      ;## Format: .version, tell channel what version                  ##
bind pub o .op pub_op                  ;## Format: .op USER, .op will give you ops.                     ##
bind pub o .deop pub_deop              ;## Format: .deop USER, .deop will take your ops.                ##
bind pub o up pub_up                   ;## Format:  up, up will give you ops.                           ##
bind pub o down pub_down               ;## Format:  down, down will take your ops.                      ##
bind pub o .voice pub_voice            ;## Format: .voice USER, .voice will give you voice.             ## 
bind pub o .devoice pub_devoice        ;## Format: .devoice USER, .devoice  will take your voice.       ##
bind pub m .join pub_join              ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .part pub_part              ;## Format: .chattr USER <flags> - will change the flags of the user##
bind pub m .+chan pub_join             ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .-chan pub_part             ;## Format: .chattr USER <flags> - will change the flags of the user##
bind pub m .addchan pub_join           ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .delchan pub_part           ;## Format: .chattr USER <flags> - will change the flags of the user##
bind pub m .adduser add_user           ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .deluser pub_-user          ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .chattr pub_chattr          ;## Format: .chattr USER <flags> - will change the flags of the user##
bind pub n .save sa_ve                 ;## Format: .save - will save the the current user/chan files.   ##
bind pub n .reload re_load             ;## Format: .reload - will reload the saved user file.           ##
bind pub n .rehash rehash_bot          ;## Format: .rehash - will rehash the bot.                       ##
bind pub n .restart restart_bot        ;## Format: .restart - will restart the bot.                     ##
bind pub n .die die_exit               ;## Format: .die - will kill the bot instantly.                  ##
bind pub - .help help                  ;## Format: .help - will display available commands.             ##
bind pub - .exthelp ext_help           ;## Format: .exthelp - will display available commands.          ##
bind pub o .kick kick
bind pub o .ban ban
bind pub o .unban unban
bind pub m .addhost pub_+host           ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .delhost pub_-host
bind pub m .+host pub_+host           ;## Format: .adduser USER <host> - will add the user with host.  ##
bind pub m .-host pub_-host

set homechan "#netcentral"
set nopart ""
##########################################################################################################
#                                      msg cmd auth -- start                                             #
##########################################################################################################

proc msg_auth {nick uhost hand rest} {
 global botnick
 set pw [lindex $rest 0]
 if {$pw == ""} {
  puthelp "NOTICE $nick :\002Usage: /msg $botnick auth <password>\002"
  return 0
 }
 if {[matchattr $hand Q] == 1} {
  puthelp "NOTICE $nick :\002You are already Authenticated.\002"
  return 0
 }
 set ch [passwdok $hand ""]
 if {$ch == 1} {
  puthelp "NOTICE $nick :\002No password set. Type /msg $botnick pass <password>\002" 
  return 0
 }
 if {[passwdok $hand $pw] == 1} {
  chattr $hand +Q
  putcmdlog "\002#$hand# auth ...\002"
  puthelp "NOTICE $nick :\002Authentication successful!\002"
 }
 if {[passwdok $hand $pw] == 0} {
  puthelp "NOTICE $nick :\002Authentication failed!\002"
 }
}
## msg cmd auth -- stop

## msg cmd deauth -- start
proc msg_deauth {nick uhost hand rest} {
 global botnick
 if {$rest == ""} {
  puthelp "NOTICE $nick :\002Usage: /msg $botnick auth <password>\002"
  return 0
 }
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :\002You never authenticated.\002"
  return 0
 }
 if {[passwdok $hand $rest] == 1} {
  chattr $hand -Q
  putcmdlog "\002\[FL\]\002 #$hand# deauth ...\002"
  puthelp "NOTICE $nick :\002DeAuthentication successful!\002"
 }
 if {[passwdok $hand $rest] == 0} {
  puthelp "NOTICE $nick :\002DeAuthentication failed!\002"
 }
}
## msg cmd deauth -- stop

## sign cmd deauth -- start
proc sign_deauth {nick uhost hand chan rest} { 
 if {[matchattr $hand Q] == 1} {
  chattr $hand -Q
  putlog "\002$nick has signed off, automatic deauthentication.\002"
 }
 if {[matchattr $hand Q] == 0} {
  return 0
 }
}
## sign cmd deauth -- stop

## part cmd deauth -- start
proc part_deauth {nick uhost hand chan args} {
  if {[matchattr $hand Q] == 1} {
  chattr $hand -Q
  putlog "\002$nick has parted $chan, automatic deauthentication.\002"
 }
 if {[matchattr $hand Q] == 0} {
  return 0
 }
}

##########################################################################################################
#                                      part cmd deauth -- stop                                           #
##########################################################################################################

proc pub_version {nick uhost hand chan args} {
putquick "PRIVMSG $chan :Current version is: \002EggCommand\002 by \002Squire\002 \00312,1\[\0039Eggdrop Command TCL\00312\]\003 on \002Eggdrop v1.6.20\002"
} 

## public cmd -host -- start
proc pub_-host {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set who [lindex $rest 0]
 set hostname [lindex $rest 1]
 set completed 0
 if {($who == "") || ($hostname == "")} {
  puthelp "NOTICE $nick :\002\[FL\]\002 Usage: -host <nick> <hostmask>"
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
   puthelp "privmsg $channel :\0039 Removed \002\[\002${hostname}\002\]\002 from $who."
    ### Make it do the -host thing here, and any message that goes along with it
   set completed 1
  }
 }
 if {$completed == 0} {
  puthelp "privmsg $channel :\0039 No such hostmask!"
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

proc pub_+host {nick uhost hand channel rest} {
 global thehosts botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set who [lindex $rest 0]
 set hostname [lindex $rest 1]
 if {($who == "") || ($hostname == "")} {
  puthelp "NOTICE $nick :Usage: +host <nick> <new hostmask>"
  return 0
 }
 if {[validuser $who] == 0} {
  puthelp "privmsg $channel :\0039 No such user!"
  return 0
 }
 set badhost 0
 foreach * [getuser $who HOSTS] {
  if {${hostname} == ${*}} {
   puthelp "privmsg $channel :\0039 That hostmask is already there."
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
  puthelp "privmsg $channel :\0039 Added \002\[\002${hostname}\002\]\002 to $who."
  if {[matchattr $who a] == 1} {
   pushmode $chan +o $who
  }
  save
  puthelp "NOTICE $nick :\002\[FL\]\002 Writing user file ..."
 }
}
## public cmd +host -- stop

## public cmd -user -- start
proc pub_-user {nick uhost hand channel rest} {
 global botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set who [lindex $rest 0]
 if {$who == ""} {
    puthelp "privmsg $channel :\0039Usage: .-user <nick>"
 } else {
  if {[validuser $who] == 0} {
    puthelp "privmsg $channel :\0039$who is not on my userlist."
  } else {
   if {[matchattr $who n] == 1}  {
    puthelp "privmsg $channel :\0039You cannot delete a bot owner."
   } else {
    if {([matchattr $who m] == 1) && ([matchattr $nick n] == 0)} {
    puthelp "privmsg $channel :\0039You don't have access to delete $who."
    } else {
     deluser $who
     save
    puthelp "privmsg $channel :\0039$who has been deleted."
    }
   }
  }
 }
}
## public cmd -user -- stop

## public cmd +user -- start
proc pub_+user {nick uhost hand channel rest} {
 global botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
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
     regsub -all " " [split [maskhost [getchanhost mark- #chat]] !] "!*" hostmask
   }
 }
 if {[validuser $who]==1} {
    puthelp "privmsg $channel :\0039$who is already in my userlist."
  return 0
 }
 if {($who=="") || ($hostmask=="")} {
    puthelp "privmsg $channel :\0039Usage: .+user <nick> <hostmask>"
  return 0
 }
 set who [lindex $rest 0]
 set flags [lindex $rest 2]
 if {[validuser $who]==0} {
  adduser $who $hostmask
  save
    puthelp "privmsg $channel :\0039$who has been added to userlist with hostmask \002\[\002$hostmask\002\]\002."
  if {$flags != ""} {
   chattr $who $flags $channel
    puthelp "privmsg $channel :\0039Added $flags to $who"
  }
  return 0
 }
}
## public cmd +user -- stop

## public cmd adduser -- start
proc add_user {nick uhost hand channel rest} {
 global botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {[lindex $rest 0] == ""} {
  return 0
 }
 if {[validuser [lindex $rest 0]]} {
  puthelp "privmsg $channel :\0039 Error, could not add user $who, he already exists!!"
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
    puthelp "privmsg $channel :\0039Successfully added $who \002\[\002$newhost\002\]\002 to the userlist."
    puthelp "privmsg $channel :\0039Global Flags for $who are \002\[\002${flags}\002\]\002"
    set chanflags [chattr [lindex $rest 0] | [lindex $rest 2]]
    set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set chanflags [string trim $chanflags |]
    puthelp "privmsg $channel :\0039Channel \002\"\002[lindex $rest 2]\002\"\002 Flags for $who are \002\[\002${chanflags}\002\]\002"
    save
    return 0
   } else {
    chattr $who $oflags
    set flags [chattr $who]
    set newhost [getuser $who HOSTS]
    puthelp "privmsg $channel :\0039Successfully added $who \002\[\002$newhost\002\]\002 to the userlist."
    puthelp "privmsg $channel :\0039Global Flags for $who are \002\[\002${flags}\002\]\002"
    save
    return 0
   }
  } else {
   set flags [chattr $who]
   puthelp "privmsg $channel :\0039Successfully added $who \002\[\002$host\002\]\002 has been added to the userlist."
   puthelp "privmsg $channel :\0039Global Flags for $who are \002\[\002${flags}\002\]\002"
   save
   return 0
  }
 }
 if {[onchan [lindex $rest 0] $channel]==0} {
  puthelp "privmsg $channel :\0039That user is not on $channel."
 }
}
## public cmd adduser -- stop

## public cmd chattr -- start
proc pub_chattr {nick uhost hand channel rest} {
 global ownern flagss lowerflag nflagl botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set ownern [lindex $rest 0]
 set flagss [lindex $rest 1]
 set chan [lindex $rest 2]
 if {$ownern==""} {
    puthelp "privmsg $channel :\0039Usage:.chattr <nick> <flags>"
  return 0
 }
 if {[validuser $ownern]==0} {
    puthelp "privmsg $channel :\0039No such user!"
  return 0
 }
 if {$flagss==""} {
    puthelp "privmsg $channel :\0039.chattr <nick> <flags>"
  return 0
 }
 if {([matchattr $ownern n] == 1) && ([matchattr $nick n] == 0)} {
    puthelp "privmsg $channel :\0039You do not have access to change ${ownern}'s flags."
 }
 if {[matchattr $nick n] == 1} {
  if {$chan != ""} {
   if {[validchan $chan]} {
    if {[string trim $flagss abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-] == "|"} {
     chattr $ownern $flagss $chan
    } else {
     chattr $ownern |$flagss $chan
    }
    set chanflags [chattr $ownern | $chan]
    set chanflags [string trimleft $chanflags "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    set chanflags [string trim $chanflags "|"]
    set globalflags [chattr $ownern]
    puthelp "privmsg $channel :\0039chattr $ownern \002\[\002${flagss}\002\]\002 $chan"
    puthelp "privmsg $channel :\0039Global Flags for $ownern are \002\[\002${globalflags}\002\]\002"
    if {$chanflags != "-"} {
    puthelp "privmsg $channel :\0039Channel \002\"\002${chan}\002\"\002 Flags for $ownern are \002\[\002${chanflags}\002\]\002"
    } else {
    puthelp "privmsg $channel :\0039$ownern does not have any channel specific flags on ${chan}."
    }
   } else {
    puthelp "privmsg $channel :\0039$chan is not a valid channel"
   }
  } else {
   chattr $ownern $flagss
   set flags [chattr $ownern]
    puthelp "privmsg $channel :\0039Chattr $ownern \002\[\002${flagss}\002\]\002"
    puthelp "privmsg $channel :\0039Global Flags for $ownern are now \002\[\002${flags}\002\]\002" 
  }
  if {[matchattr $ownern a] == 1} {
   pushmode $channel +o $ownern
  }
  if {([matchattr $ownern a] == 0) && ([matchattr $ownern o] == 0)} {
   pushmode $channel -o $ownern
  }
  save
    puthelp "privmsg $channel :\0039Writing user file ..."
 }
  ##stop them from adding/removing +n if their not a owner.
 if {[matchattr $nick n] == 0} {
  set lowerflag [string tolower $flagss]
  set nflagl [string trim $flagss abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-]
  if {$nflagl != ""} {
    puthelp "privmsg $channel :\0039You do not have access to add or remove the flag \002'\002n\002'\002 from that user."
   return 0
  }
 }
  ##stops other users from giving others +m.
 if {([matchattr $nick n] == 0) && ([matchattr $nick  m] == 1) && ([matchattr $ownern m] == 1)} {
  set lowerflag [string tolower $flagss]
  set nflagl [string trim $flagss abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-]
  if {$nflagl != ""} {
    puthelp "privmsg $channel :\0039You do not have access to add or remove the flag \002'\002m\002'\002 from $ownern."
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
    puthelp "privmsg $channel :\0039Chattr $ownern \002\[\002${flagss}\002\]\002 $chan"
    puthelp "privmsg $channel :\0039Global Flags for $ownern are \002\[\002${globalflags}\002\]\002"
    if {$chanflags != "-"} {
    puthelp "privmsg $channel :\0039Channel \002\"\002${chan}\002\"\002 Flags for $ownern are \002\[\002${chanflags}\002\]\002"
    } else {
    puthelp "privmsg $channel :\0039$ownern does not have any channel specific flags on ${chan}."
    }
   } else {
    puthelp "privmsg $channel :\0039$chan is not a valid channel"
    return 0
   }
  } else {
   chattr $ownern $flagss
   set flags [chattr $ownern]
    puthelp "privmsg $channel :\0039Chattr $ownern \002\[\002${flagss}\002\]\002"
    puthelp "privmsg $channel :\0039Global Flags for $ownern are now \002\[\002${flags}\002\]\002"
  }
  if {[matchattr $ownern a] == 1} {
   pushmode $channel +o $ownern
  }
  save
    puthelp "privmsg $channel :\0039Writing user file ..."
 }
}
## public cmd chattr -- stop

##########################################################################################################
#                                      Channel Commands -- start                                         #
##########################################################################################################

## public cmd op -- start
proc pub_op {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest==""} {
    if {![botisop $channel]} {
      return 0
    }
    if {[isop $nick $channel]} {
      return 0
    }
    pushmode $channel +o $nick
    return 0
  }
  if {[onchan $rest $channel]==1} {
   if {[isop $rest $channel]==1} {
   }
  }
  if {$rest!=""} {
   if {[onchan $rest $channel]==0} {
   }
  }
  if {[onchan $rest $channel]==1} {
   if {[isop $rest $channel]==0} {
    pushmode $channel +o $rest 
   }
  }
 }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :I am not oped, sorry."
 }
}
## public cmd op -- stop

## public cmd deop -- start
proc pub_deop {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set rest [lindex $rest 0]
 if {[botisop $channel]==1} {
  if {$rest==""} {
    if {![botisop $channel]} {
      return 0
    }
    if {![isop $nick $channel]} {
      return 0
    }
    pushmode $channel -o $nick
    return 0
  }
  if {$rest!=""} {
   if {[onchan $rest $channel] == 0} {
    return 0
   }
  }
  if {[onchan $rest $channel]=="1"} {
   if {[isop $rest $channel]=="0"} {
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
    }
   }
  }
 }
 if {[botisop $channel]!=1} {
  puthelp "NOTICE $nick :\002I am not oped, sorry.\002"
 }
}
## public cmd deop -- stop

## public cmd down -- start
proc pub_down {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {[botisop $channel] != 1} {
  return 0
 }
 if {[isop $nick $channel] == 1} {
  pushmode $channel -o $nick
 } else {
  return 0
 }
}
## public cmd down -- stop

## public cmd up -- start
proc pub_up {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {[botisop $channel] != 1} {
  return 0
 }
 if {[isop $nick $channel] == 0} {
  pushmode $channel +o $nick
 } else {
  return 0
 }
}
## public cmd up -- stop

## public pub_devoice -- start
proc pub_devoice {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
}
 if {$rest == ""} {
  return 0
 }
 if {[onchan $rest $channel] == 0} {
  return 0
 }
 if {[isvoice $rest $channel] == 1} {
 }
 if {[onchan $rest $channel] == 1} {
  pushmode $channel -v $rest
 }
}
## public cmd devoice -- stop

## public cmd voice -- start
proc pub_voice {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {$rest == ""} {
  return 0
 }
 if {[onchan $rest $channel] == 0} {
  return 0
 }
 if {[isvoice $rest $channel] == 0} {
 }
 if {[onchan $rest $channel] == 1} {
  pushmode $channel +v $rest
 }
}
## public cmd voice -- stop

## public cmd join -- start 
proc pub_join {nick uhost hand chan rest} {
 global botnick homechan
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 set chan [lindex $rest 0]
 if {[string first # $chan]!=0} {
  set chan "#$chan"
 }
 if {$chan=="#"} {
    puthelp "privmsg $chan :\0039Usage: .join <#channel>"
 } else {
 foreach x [channels] {
  if {[string tolower $x]==[string tolower $chan]} {
    puthelp "privmsg $chan :\0039Your already in $x"
   return 0
  }
 }
 if {[lindex $rest 1] == ""} {
    puthelp "privmsg $homechan :\0039I have joined $chan"
 } else {
    puthelp "privmsg $homechan :\0039I have joined $chan (key: [lindex $rest1])"
 }
 channel add $chan
  if {$rest!=""} {
   putserv "JOIN $chan :[lindex $rest 1]"
  }
 }
}
## public cmd join -- stop

## public cmd part -- start
proc pub_part {nick uhost hand chan rest} { 
 set rest [lindex $rest 0]
 global nopart botnick
  if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
 if {[string first # $rest]!=0} {
  set rest "#$rest"
 }
 if {$rest==""} {
    puthelp "privmsg $chan :\0039Usage: .part <#channel>"
  return 0
 } else {
  foreach x [channels] {
   if {[string tolower $x]==[string tolower $rest]} {
    if {[string tolower $rest]==[string tolower $nopart]} {
    puthelp "privmsg $chan :\0039Sorry I can not part $nopart \[PROTECTED\]"
     return 0
    }
    channel remove $rest
    puthelp "privmsg $chan :\0039I have left $x"
    return 0
   }
  }
 }
    puthelp "privmsg $chan :\0039I wasn't in $rest"
}
## public cmd part -- stop

##########################################################################################################
#                                      Channel Commands -- stop                                          #
##########################################################################################################

proc die_exit {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
exit
}

proc sa_ve {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
putserv "PRIVMSG $channel :\0039The user and channel files have successfully been written to disk.\003"
save
}

proc re_load {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
reload
putserv "PRIVMSG $channel :\0039The user file has been successfully re-loaded.\003"
}

proc rehash_bot {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
global botnick; rehash
putserv "PRIVMSG $channel :\0039 Rehash Successful.\003"
}

proc restart_bot {nick uhost hand channel rest} {
 set rest [lindex $rest 0]
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. \002Please /msg $botnick auth <password>\002"
  return 0
 }
putserv "PRIVMSG $channel :\0039 Restarting! Please wait...\003"
utimer 1 restart
}

## public cmd kick -- start
proc kick {nick uhost hand channel rest} {
 global botnick
 if {[matchattr $hand Q] == 0} {
  puthelp "NOTICE $nick :This command requires you to authenticate yourself. Please /msg $botnick auth <password>"
  return 0
 }
 if {[botisop $channel]==1} {
  if {$rest == ""} {
   puthelp "NOTICE $nick :\0039 Usage: kick <nick> \[reason\]"
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
   set reason "Don't Let The Door Hit You On The Way Out!" 
  }   
  if {[string tolower $handle] == [string tolower $botnick]} {
   putserv "KICK $channel $nick :That was not Smart!"
   return 0
  } else {
   if {[matchattr $handle n] == 1} {
    putserv "KICK $channel $nick :Don't kick the boss..."
   return 0
   } else {
    putserv "KICK $channel $handle :\00310${reason}"
    if {$reason == ""} {set reason "No given reason"}
    return 0
   }
  }
 }
 if {[botisop $channel]==0} {
  puthelp "NOTICE $nick :\0039 I am not oped"
 }
}
## dcc cmd kick -- stop

## public cmd kb -- start
proc ban  {nick uhost hand channel rest} {
 global botnick 
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

## public cmd -ban -- start
proc unban {nick uhost hand channel rest} {
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

proc help {nick uhost hand channel rest} {
putserv "NOTICE $nick :****   Available commands are the following  ****"
putserv "NOTICE $nick :up - will give you ops." 
putserv "NOTICE $nick :down - will take ops."
putserv "NOTICE $nick :.op USER, - will give ops to user." 
putserv "NOTICE $nick :.deop USER - will take ops from user."
putserv "NOTICE $nick :.voice USER, - will give voice to user." 
putserv "NOTICE $nick :.devoice USER - will take voice from user."
putserv "NOTICE $nick :.version - will display the current version of nodexcom"
putserv "NOTICE $nick :.exthelp - Owner / Bot Master Help Commands"
putserv "NOTICE $nick :****      End Of Nodexcom Help System         ****"
}

proc ext_help {nick uhost hand channel rest} {
putserv "NOTICE $nick :****     Owner / Bot Master Commands        ****"
putserv "NOTICE $nick :.join - will make me join a channel"
putserv "NOTICE $nick :.part - will make me part a channel"
putserv "NOTICE $nick :.adduser - will add a user in channel"
putserv "NOTICE $nick :.deluser - will delete a user."
putserv "NOTICE $nick :.chattr USER <flags> - will change the flags of the user"
putserv "NOTICE $nick :.save - will save the the current user/chan files."
putserv "NOTICE $nick :.reload - will reload the saved user file."
putserv "NOTICE $nick :.rehash - will rehash the bot."
putserv "NOTICE $nick :.restart - will restart the bot."
putserv "NOTICE $nick :.die - will kill the bot instantly."
putserv "NOTICE $nick :****      End Of Nodexcom Help System         ****"
}


set leversion "Nodecom"
putlog "$leversion by Squire - Eggdrop Command TCL - LOADED"