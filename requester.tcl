bind pub -|- !request requestadd
bind pubm -|- !todo todo

proc requestadd {nick uhost hand chan text} {
 set date [strftime %d/%m/%y] 
   # The new line.
   set line_to_add "$text Requested By: $nick Date: $date"

   # Name of file to append to.
   set fname "scripts/todo.txt"

   # Open the file in append mode.
   set fp [open $fname "a"]

   # Add the line.
   puts $fp $line_to_add

   # We're done!
   close $fp

   putserv "PRIVMSG #shellsolutions :\00314Request: \002\00310[lindex [split $text "|"] 0] \002\00310 Requested By: $nick $date \037\00314. Added successfully!\003"
} 



proc todo {nick uhost hand chan text} {
    set number [lindex [split $text] 0]
    set filename "scripts/todo.txt"
    if {![file exists $filename]} {
        putquick "NOTICE $nick :Track list file not found."
        return
    }

    set tracks [open $filename]
    set data [split [read $tracks] \n]
    close $tracks
    foreach music_info $data {
putserv "PRIVMSG #shellsolutions :\00314Request \002\00310$music_info"
    }
 } 