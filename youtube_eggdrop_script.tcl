package require http
bind pubm - *http://*youtu*/watch* pubm:youtube
bind ctcp - * action:youtube

proc action:youtube {nick host hand dest keyword args} {
        set args [lindex $args 0]
        if {![validchan $dest]} {return}
        if {$keyword == "ACTION" && [string match *http://*youtu*/watch* $args]} {pubm:youtube $nick $host $hand $dest $args}
}

proc pubm:youtube {nick host hand chan args} {
        set args [lindex $args 0]
        while {[regexp -- {(http:\/\/.*youtub.*/watch.*)} $args -> url args]} {
                while {[regexp -- {v=(.*)&?} $url -> vid url]} {
                        set vid [lindex [split $vid &] 0]

                        set gurl "http://gdata.youtube.com/feeds/api/videos/$vid"
                        set search [http::formatQuery v 2 alt jsonc prettyprint true]
                        set token [http::config -useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11" -accept "*/*"]
                        set token [http::geturl "$gurl?$search"]
                        set data [::http::data $token]
                        http::cleanup $token
                        set lines [split $data "\n"]
                        set title ""
                        set duration ""
                        set viewCount ""
                        foreach line $lines {
                                if {$title==""} {set title [lindex [regexp -all -nocase -inline {\"title\"\: \"(.*)\"} $line] 1]}
                                if {$duration==""} {set duration [lindex [regexp -all -nocase -inline {\"duration\"\: ([0-9]+)} $line] 1]}
                                if {$viewCount==""} {set viewCount [lindex [regexp -all -nocase -inline {\"viewCount\"\: ([0-9]+)} $line] 1]}
                        }
                        set title [yturldehex $title]
                        putmsg $chan "\002\00301,00You\00300,04Tube\017\002 $title | Duration: [shortduration $duration] | $viewCount views"
                }
        }
}

bind pub - !youtube pub:youtube
proc pub:youtube {nick host hand chan args} {
        set args [lindex $args 0]
        if {$args == ""} {
                putnotc $nick "Gebruik: \002!youtube <zoeksleutel>\002 om te zoeken"
                return
        }
        set search [http::formatQuery v 2 alt jsonc q $args orderby viewCount max-results 5 prettyprint true]
        set token [http::config -useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11" -accept "*/*"]
        set token [http::geturl "http://gdata.youtube.com/feeds/api/videos?$search"]
        set data [::http::data $token]
        http::cleanup $token

        set totalitems [lindex [regexp -all -nocase -inline {\"totalItems\"\: ([0-9]+)} $data] 1]
        putnotc $nick "\002\00301,00You\00300,04Tube\017 Er zijn $totalitems resultaten die voldoen aan de zoeksleutel \002$args\002"
        set lines [split $data "\n"]
        set results ""
        foreach line $lines {
                if {[regexp -all -nocase -inline {\"id\"\: \"(.*)\"} $line] != ""} {
                        set id [lindex [regexp -all -nocase -inline {\"id\"\: \"(.*)\"} $line] 1]
                        lappend results $id
                }
                if {[regexp -all -nocase -inline {\"title\"\: \"(.*)\"} $line] != ""} {
                        set result($id,title) [yturldehex [lindex [regexp -all -nocase -inline {\"title\"\: \"(.*)\"} $line] 1]]
                }
                if {[regexp -all -nocase -inline {\"duration\"\: ([0-9]+)} $line] != ""} {
                        set result($id,duration) [lindex [regexp -all -nocase -inline {\"duration\"\: ([0-9]+)} $line] 1]
                }
                if {[regexp -all -nocase -inline {\"viewCount\"\: ([0-9]+)} $line] != ""} {
                        set result($id,viewCount) [lindex [regexp -all -nocase -inline {\"viewCount\"\: ([0-9]+)} $line] 1]
                }
        }
        foreach res $results {
                putnotc $nick "\002\00301,00You\00300,04Tube\017 \002$result($res,title)\002 | [shortduration $result($res,duration)] | $result($res,viewCount) views | http://www.youtube.com/watch?v=$res"
        }
}

proc yturldehex {string} {
        regsub -all {[\[\]]} $string "" string
        set string [subst [regsub -nocase -all {\&#([0-9]{2,4});} $string {[format %c \1]}]]
        return [string map {&quot; \"} $string]
}

proc shortduration {seconds} {
        set hours [expr int(floor($seconds/3600))]
        set minutes [expr int(floor(($seconds%3600)/60))]
        set seconds [expr $seconds - ($hours*3600) - ($minutes*60)]
        if {$hours<10} { set hours "0$hours" }
        if {$minutes<10} { set minutes "0$minutes" }
        if {$seconds < 10} { set seconds "0$seconds" }
        return "$hours:$minutes:$seconds"
}