#  ChanLimit.tcl by Nils Ostbjerg <shorty@business.auc.dk>
#  (C) Copyright (1999)
#
#  This script will limit a channel to the current number of users plus
#  5 once every min.
#
#  This version of the ChanLimit script is useable with Eggdrop version
#  1.3.x
#
#  Please report any bugs to me at shorty@business.auc.dk.
#  Idea and suggestion to new features are also welcome.
#
#                                 - Nils Ostbjerg <shorty@business.auc.dk>
#
#  Version 1.3.2 - 19 Jun 2000  Made a grademargin so if the limit only 
#                               needs to be change by 1 then it wont get 
#                               changed. Thanks to Harvey for this idea.
#                                 - Nils Ostbjerg <shorty@business.auc.dk>
#
#  Version 1.3.1 - 30 Nov 1999  Minor cosmetic changes, so that all my 
#                               scripts follow the same scheme. 
#                                 - Nils Ostbjerg <shorty@business.auc.dk>
#
#  Version 1.3.0 - 30 Mar 1999  First version and should work ok
#                                 - Nils Ostbjerg <shorty@business.auc.dk>
# 

##########################################################################
# Binds                                                                  #
##########################################################################

bind time - "* * * * *" time:ChanLimit

##########################################################################
# time:ChanLimit start                                                   #
##########################################################################

proc time:ChanLimit {min hour day month year} {
    foreach chan [channels] {
	set newlimit [expr [llength [chanlist $chan]] + 5]
	set currentlimit [currentlimit $chan]
	if {$currentlimit < [expr $newlimit - 1] || $currentlimit > [expr $newlimit + 1]} {
	    putserv "mode $chan +l $newlimit"
	}
    }    
}

##########################################################################
# time:ChanLimit end                                                     #
##########################################################################

##########################################################################
# currentlimit start                                                     #
##########################################################################

proc currentlimit {chan} {
    set currentmodes [getchanmode $chan]
    if {[string match "*l*" [lindex $currentmodes 0]]} {
	return [lindex $currentmodes end] 
    }
    return 0
}

##########################################################################
# currentlimit end                                                       #
##########################################################################

##########################################################################
# putlog                                                                 #
##########################################################################
 
putlog "Loaded ChanLimit (DLF)"
