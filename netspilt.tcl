bind raw - QUIT detect:netsplit

proc detect:netsplit {from key arg} {
 global netsplit_detected
 if {[info exists netsplit_detected]} { return 0 }
 set arg [string trimleft [stripcodes bcruag $arg] :]
 if {[string equal "Quit:" [string range $arg 0 4]]} { return 0 }; set arg [split $arg]
  if {([llength $arg] == "2") && [regexp {^(.*) (.*)$} $arg] && [string is lower [string map {"." "" " " ""} $arg]] && ([regexp {[0-9]} $arg] == "0") && ([string length [string map {"." "" " " ""} $arg]] == [regexp -all {[a-z]} $arg]) && ([regexp -all {\.} [lindex $arg 0]] >= 3) && ([regexp -all {\.} [lindex $arg 1]] >= 3)} {
   set server1 [string map {" " "."} [lrange [split [lindex $arg 0] "."] [expr [llength [split [lindex $arg 0] "."]] - 2] end]]
   set server2 [string map {" " "."} [lrange [split [lindex $arg 1] "."] [expr [llength [split [lindex $arg 1] "."]] - 2] end]]
    if {[string equal "dal.net" $server1] && [string equal "dal.net" $server2]} {
     foreach chan [channels] {
      putquick "NOTICE $chan :Netsplit detected: $server1 just split from $server2" -next
      set netsplit_detected 1; utimer 20 [list do:netsplit:unlock]; return 1
      }
    }
  }
}

proc do:netsplit:unlock {} {
 global netsplit_detected
 if {[info exists netsplit_detected]} {
  unset netsplit_detected
  }
} 