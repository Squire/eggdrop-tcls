# Fully Automated Away Detection by speechles
# Egghelp version v1.3 - tested and working.. yay!!
# Donate to slennox @ egghelp.org if you like this script!

# Fully automatic, you configure nothing.
# The script will decide based upon the length of the nicklist
# or the length of user input on which to scan with, it will
# use whichever is shorter which makes it faster, enjoy.

# MAKE SURE TO .chanset #yourchan +checkaway
# afterwards the script will function in #yourchan

# revision history
# v1.3 - added idle time duration to the away message reply
# v1.2 - now wont react if that nickname is away and
#        mentions their own nickname in channel. This prevents
#        public away messages, etc from making this script
#        spam channels.
# v1.1 - now fully automated, no more checklist
# v1.0 - scripted using checklist user sets in config.

# SCRIPT begins: there is no config this is 100% automatic.
# -----------

# initialize the global variables
variable checknick ""
variable checkchan ""

# flag to control behavior per channel
setudef flag checkaway

# bind to raw reply concerning away status of whois
bind RAW  -|-  301 checkaway

# bind to everything said in channel
bind pubm -|- * checkcriteria

# check which token to whois phrased from user input.
# if we have a match, discern which token to evaluate as nick
# and if they are indeed on the channel issue a whois request
proc checkcriteria {nick uhost hand chan text} {
   if {[lsearch -exact [channel info $chan] +checkaway] == -1} { return }
   set ::checkchan $chan
   set ::checknick ""
   if {[llength [chanlist $chan]] < [llength [split $text]]} {
      foreach n [chanlist $chan] {
         if {[lsearch [split [string tolower $text]] [string tolower $n]] != -1} {
            if {[string equal [string length $n] [string length [lindex [split $text] [lsearch [split [string tolower $text]] [string tolower $n]]]]]} {
               set ::checknick $n
               break
            }
         }
      }
   } else {
      foreach n [split $text] {
         if {[lsearch [split [string tolower [join [chanlist $chan]]]] [string tolower $n]] != -1} {
            set ::checknick $n 
            break
         }
      }
   }
   if {[string length $::checknick] && ![string equal $n $nick] && [onchan $::checknick $chan]} {
      putserv "WHOIS $::checknick"
   }
}

# interpret the whois request and make sure the nick requested matches
# the whois reply we are searching for. If the person is not away, a 301
# will not be sent, and the whois will be ignored as per requested.
proc checkaway {from key text} {
   if {![string match -nocase [lindex [split $text] 1] $::checknick]} { return }
   putserv "privmsg $::checkchan :[lindex [split $text] 1] is away if you need help with your hosting services please submit a ticket via http://billing.shellsolutions.net and we will act on it asap."
   set ::checknick ""
}

putlog "Automated away detection has been loaded."