set operid "botnick"
set operpass "password"

set badwords { *<censored>* *service* *services* *digitalsands* *g0v* *admin* *fark* *fag* *!@#$* *suck* *shoot* *asshole* *zub* *bitch* *cock* *@#$* *whore* *slut* *fartknocker* *ass* *bastard* *black* *pussy* *dickhead* *nigga* *piss* *maricon* *shoot* *prick* *sucks* *dicks* *pricks* *.htm* *www.* *#* *channel* *sex* *ass* *trick* *fuk* *azz* *hail* *hitler* *gov* *mil* *cyberarmy* *cia* *fbi* *nsa* *dod* *undernet.org* *oper* }
 
bind evnt - init-server oper
bind pub -|- !vhost vhost
bind join -|- * joinnotice

proc oper init-server { putserv "OPER $::operid $::operpass" }

proc joinnotice {nick host handle chan } {
    putserv "NOTICE $nick :To change your host type !vhost <the.host.you.want>"
  }

proc vhost {nick host hand chan vhostcheck} {
if {[string match "*.*.*" [string tolower $vhostcheck]]} {
  set temp 0
  set results 0
   #$temp<=X X = number of space delimited tokens in the badwords variable.
   while {$temp<=47} {
     foreach x [string tolower $::badwords] {
     if {[string match $x [string tolower $vhostcheck]]} {
     incr results
     }
    }
    incr temp
   }
   unset temp
   if { $results > 0 } {
   putserv "PRIVMSG $chan :$nick Your Vhost has not been changed to $vhostcheck as it is an invalid/disallowed host."
   } else {
   putserv "PRIVMSG $chan :$nick Your vhost has been changed to '$vhostcheck'"
   putserv "PRIVMSG nickserv :vhost $nick ON $vhostcheck"
}
  } else {
  putserv "PRIVMSG $chan :$nick You must use two '.'s in your vhost"
  }
}

