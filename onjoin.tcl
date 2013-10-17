##########################################################
# Onjoin.tcl 0.1 by Banned@abv.bg  by Banned             #
#                                                        # 
########################################################## 
set onjoin_msg {
 {
  "Welcome Pyrex Hosting %nick, For the vhost list type .vhosts - .website for information - Your Hosts are Squire, Eddie or dfz If Any Problems Please visit http://support.pyrexhosting.com"
 }
}
set onjoin_chans "#pyrexhosting"

bind join - * join_onjoin

putlog "Onjoin.tcl 0.1 by Banned loaded"

proc join_onjoin {nick uhost hand chan} {
 global onjoin_msg onjoin_chans botnick
 if {(([lsearch -exact [string tolower $onjoin_chans] [string tolower $chan]] != -1) || ($onjoin_chans == "*")) && (![matchattr $hand b]) && ($nick != $botnick)} {
  set onjoin_temp [lindex $onjoin_msg [rand [llength $onjoin_msg]]]
  foreach msgline $onjoin_temp {
   puthelp "NOTICE $nick :[subst $msgline]"
   putserv "MODE $chan +v $nick"
  }
 }
}
