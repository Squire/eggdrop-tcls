# paste.sh --
#
#	Made by ev0x 
#
#	You will need 3 scripts to use this product
#
#	trace.tcl
#	paste.php
#	paste.sh ( needs to be chmod +x ) 

#!/bin/sh

traceroute $1 | grep -v "\* \*" > ../trace.log
returned=`php -f ~/eggdrop/scripts/paste.php`
    
#now return the data to screen
echo -e "${returned%?}"