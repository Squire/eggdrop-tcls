### Random CTCP Version Reply v1.0
### by Progeny <progeny@azzurra.org>
### AzzurraNet - #EggHelp (TCL & Eggdrop)

bind ctcp - version ctcpreply
set ver 1.0
set ctcps {
 {HexChat 2.9.6 [x64] / Windows 7 [3.21GHz]}
}

proc ctcpreply {nick uhost handle dest keyword text} {
global ctcps ctcp-version
set {ctcp-version} [lindex $ctcps [rand [llength $ctcps]]]
}

putlog "TCL Loaded: Random CTCP Reply $ver by Progeny"