#!/bin/sh
     
traceroute $1 | grep -v "\* \*" > ../trace.log
returned=`php -f /home/digital/eggdrop/scripts/paste.php`
    
#now return the data to screen
echo -e "${returned%?}"