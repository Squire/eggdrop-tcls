#
# ripecheck.tcl  Version: 3.4.4  Author: Stefan Wold <ratler@stderr.eu>
###
# Info:
# This script check unresolved ip addresses against a RIPE database
# and ban the user if the country match your configured top domains.
# Features:
# * Configuration through dcc console
# * Per channel settings
# * Can handle top domain banning for name based hosts
# * Custom bantime
# * Support extra resolving for domains like info, com, net, org
#   to find hosts that actually have an ip from a country
#   you wish to ban.
# * Customizable ban messages with simple keyword support, see .help ripeconfig
# * Builtin help pages, see .help ripecheck or .help
# * !ripeinfo [#channel] <nick|host> to get verbose information from whois about the host
# * !ripeinfo and !ripecheck are available as public commands and through private
#   /msg to the bot (if enabled)
# * Ban counter, number of times ripecheck have banned someone in the channel
# * !ripestatus [*|#channel] show settings and bancount stats for the channel
# * Whitelist mode. Only let hosts from a country specified by the TLD list
#   enter the channel, everyone else get banned.
# * GeoIP from ipinfodb.com
# * !ripegeo [#channel] <nick|host> to get country, region, city, latitude,
#   longitude and google map url. Available as public and private commands.
# * Ripecheck now support using GeoIP as primary ban method, if GeoIP fail ripecheck
#   will automatically fall back using whois
# * !ripetld <tld>, !ripescan [channel] and !ripehelp
###
# Information regarding ipinfodb.com usage:
#
# To enable GeoIP support registration for an API key with ipinfodb.com is required.
# Registration is free, register here: http://www.ipinfodb.com/register.php
###
# Require / Depends:
# TCL >= 8.5
# tcllib >= 1.10  (http://www.tcl.tk/software/tcllib/)
###
# Usage:
# Load the script and change the topdomains you
# wish to ban.
#
# For help and available commands see:
# .help ripecheck
#
###
# Public channel commands:
# !ripecheck <nick|host>
# !ripeinfo [#channel] <nick|host>
# !ripegeo [#channel] <nick|host>
# !ripestatus [*|#channel]
# !ripetld <tld>
# !ripescan [channel]
# !ripehelp
# Private msg commands:
# !ripecheck <host>
# !ripeinfo <host>
# !ripegeo <host>
# !ripetld <tld>
# !ripehelp
###
# Tested:
# eggdrop v1.6.19 GNU/Linux with tcl 8.5 and tcllib 1.10
# eggdrop v1.6.20 GNU/Linux with tcl 8.5 and tcllib 1.12
# - Known issues
#   - There is a known bug in 1.6.20 with the new notifier code
#     and vwait that cause segmentation fault after running
#     the bot for a while. Workaround right now is to disable
#     the new code by changing #ifdef HAVE_TCL_SETNOTIFIER 1 to
#     #undef HAVE_TCL_SETNOTIFIER in config.h and recompile your eggdrop.
###
# BUGS?!
# If you discover any problems please send an e-mail
# to ratler@stderr.eu with as detailed information as possible
# on how to reproduce the issue.
###
# LICENSE:
# Copyright (C) 2006 - 2011  Stefan Wold <ratler@stderr.eu>
#
# This code comes with ABSOLUTELY NO WARRANTY
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# RIPE Country Checker

if {[namespace exists ::ripecheck]} {namespace delete ::ripecheck}
namespace eval ::ripecheck {
    # --- Settings ---

    # RIPE query timeout setting, default 5 seconds
    variable rtimeout 5

    # Set console output flag, for debug purpose (default d, ie .console +d)
    variable conflag d

    # Path to netmask file
    variable iplistfile "scripts/iplist.txt"

    # Path to channel settings file
    variable chanfile "ripecheckchan.dat"

    # Path to tld country list file
    variable tldfile "scripts/tld_country_list.txt"

}
# ---- Only edit stuff below this line if you know what you are doing ----

# Channel flags
setudef flag ripecheck
setudef flag ripecheck.topchk
setudef flag ripecheck.topban
setudef flag ripecheck.pubcmd
setudef flag ripecheck.whitelist
setudef int ripecheck.bantime

# Packages
package require Tcl 8.4
package require ip
package require http

# Bindings
bind join - *!*@* ::ripecheck::onJoin
bind dcc -|- testripecheck ::ripecheck::test
bind dcc m|ov +ripetopdom ::ripecheck::addTopDom
bind dcc m|ov -ripetopdom ::ripecheck::delTopDom
bind dcc m|ov +ripetopresolv ::ripecheck::addTopResolve
bind dcc m|ov -ripetopresolv ::ripecheck::delTopResolve
bind dcc m|ov ripeconfig ::ripecheck::config
bind dcc m|ov ripescan ::ripecheck::dccRipeScan
bind dcc -|- ripesettings ::ripecheck::settings
bind dcc -|- help ::stderreu::help
bind pub -|- !ripecheck ::ripecheck::pubRipeCheck
bind msg -|- !ripecheck ::ripecheck::msgRipeCheck
bind pub -|- !ripeinfo ::ripecheck::pubRipeInfo
bind msg -|- !ripeinfo ::ripecheck::msgRipeInfo
bind pub -|- !ripestatus ::ripecheck::pubRipeStatus
bind msg -|- !ripegeo ::ripecheck::msgRipeGeo
bind pub -|- !ripegeo ::ripecheck::pubRipeGeo
bind msg -|- !ripetld ::ripecheck::msgRipeTld
bind pub -|- !ripetld ::ripecheck::pubRipeTld
bind pub m|o !ripescan ::ripecheck::pubRipeScan
bind pub -|- !ripehelp ::ripecheck::pubRipeHelp
bind msg -|- !ripehelp ::ripecheck::msgRipeHelp

namespace eval ::ripecheck {
    # Global variables
    variable version "3.4.4"

    variable ipinfodb "http://api.ipinfodb.com/v2/ip_query.php?"
    variable maskarray
    variable chanarr
    variable topresolv
    variable config
    variable constate
    variable tldtocountry
    variable bancount

    # Print debug
    proc debug { text } {
        putloglev $::ripecheck::conflag * "ripecheck - DEBUG: $text"
    }

    # Parse ip list file
    if {[file exists $::ripecheck::iplistfile]} {
        set fid [open $::ripecheck::iplistfile r]
        while { ![eof $fid] } {
            gets $fid line
            if {[regexp {^[0-9]} $line]} {
                regexp -nocase {^([0-9\.\/]+)[[:space:]]+([a-z0-9\.]+)} $line dummy mask whoisdb
                lappend ::ripecheck::maskarray $mask
                set ::ripecheck::maskhash($mask) $whoisdb
            }
        }
        close $fid
        # These two variables should _ALWAYS_ be of the same size, otherwise something is wrong
        ::ripecheck::debug "IP file loaded with [llength $::ripecheck::maskarray] netmask(s)"
        ::ripecheck::debug "IP file loaded with [array size ::ripecheck::maskhash] whois entries"
    }

    # Read settings - only at startup
    if {[file exists $::ripecheck::chanfile]} {
        set fchan [open $::ripecheck::chanfile r]
        while { ![eof $fchan] } {
            gets $fchan line
            if {[regexp {^\#} $line]} {
                set ::ripecheck::chanarr([string tolower [lindex [split $line :] 0]]) [split [lindex [split $line :] 1] ,]
            } elseif {[regexp {^topresolv} $line]} {
                set ::ripecheck::topresolv([string tolower [lindex [split $line :] 1]]) [split [lindex [split $line :] 2] ,]
            } elseif {[regexp {^config} $line]} {
                set ::ripecheck::config([lindex [split $line :] 1]) [lindex [split $line :] 2]
            } elseif {[regexp {^stats:bancount} $line]} {
                set ::ripecheck::bancount([lindex [split $line :] 2]) [lindex [split $line :] 3]
            }
        }
        close $fchan
        ::ripecheck::debug "Channel file loaded with settings for [array size ::ripecheck::chanarr] channel(s)"
        ::ripecheck::debug "Top resolv domains loaded for [array size ::ripecheck::topresolv] channel(s)"
    }

    # Read tld_country_list
    if {[file exists $::ripecheck::tldfile]} {
        set ftld [open $::ripecheck::tldfile r]
        while { ![eof $ftld] } {
            gets $ftld line
            if {[regexp {^[a-z]} $line]} {
                regexp -nocase {^([a-z]{2,6})[[:space:]]+(.*)} $line -> tld country
                set ::ripecheck::tldtocountry($tld) $country
            }
        }
        close $ftld
        ::ripecheck::debug "TLD country list loaded with [array size ::ripecheck::tldtocountry] entries"
    }

    # Functions
    proc onJoin { nick host handle channel } {
        # Lower case channel
        set channel [string tolower $channel]

        # Ignore myself
        if {[isbotnick $nick]} {
            ::ripecheck::debug "Found myself ($nick) - Ignoring"
            return 1
        }

        # Only run if channel is defined
        if {![channel get $channel ripecheck]} { return 1 }

        # Exclude ops, voice, friends
        if {[matchattr $handle fov|fov $channel]} {
            ::ripecheck::debug "ripecheck: $nick is on exempt list"
            return 1
        }

        # Check if channel has a domain list or complain about it and then abort
        if {![info exists ::ripecheck::chanarr($channel)]} {
            putlog "ripecheck: Ripecheck is enabled but '$channel' has no domain list!"
            return 1
        }

        # Get IP/Host part
        regexp ".+@(.+)" $host matches iphost
        set iphost [string tolower $iphost]

        # Top domain ban if enabled
        if {[channel get $channel ripecheck.topban] && ![regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $iphost]} {
            set htopdom [lindex [split $iphost "."] end]
            if {(![channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $htopdom] != -1) || \
                ([channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $htopdom] == -1 && ![::ripecheck::isInTopResolve $channel $htopdom])} {
                set country [::ripecheck::getCountry $htopdom]
                set template [list %nick% $nick \
                                   %domain% $htopdom \
                                   %tld% $htopdom \
                                   %country% $country]
                set bantime [channel get $channel ripecheck.bantime]
                if {[info exists ::ripecheck::config(bantopreason)]} {
                    set banreason [::ripecheck::templateReplace $::ripecheck::config(bantopreason) $template]
                } else {
                    set banreason "RIPE Country Check: Top domain .$htopdom is banned."
                }
                putlog "ripecheck: Matched top domain '$htopdom' banning *!*@*.$htopdom on $channel for $bantime minute(s)"
                if {![::ripecheck::isConfigEnabled logmode]} {
                    ::ripecheck::incrBanCount $channel
                    newchanban $channel "*!*@*.$htopdom" ripecheck $banreason $bantime
                }

                return 1
            }
        }
        dnslookup $iphost ::ripecheck::onJoinRouter $nick $host $channel
    }

    proc onJoinRouter { ip iphost status nick host channel } {
        # DNS lookup successfull?
        if {$status == 0 && ![regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $iphost]} {
            putlog "ripecheck: Couldn't resolve '$iphost'. No further action taken."
            return 0
        }

        ::ripecheck::debug "onJoinRouter() - Ip: $ip, Iphost: $iphost, Orghost: $host"

        # First we try geoIP if enabled
        if {[::ripecheck::isConfigEnabled geoban]} {
            ::ripecheck::debug "Using GeoIP (geoban enabled)"

            set geoData [::ripecheck::getGeoData $ip]

            if {[dict get $geoData Status] == "OK" && [dict get $geoData CountryName] != "Reserved"} {
                ::ripecheck::debug "Using GeoIP CountryCode: [dict get $geoData CountryCode]"
                ::ripecheck::ripecheck $ip $iphost $nick $channel $host [string tolower [dict get $geoData CountryCode]]
                return 1
            }
            ::ripecheck::debug "Using GeoIP failed - using whois fallback"
        }

        # Only run RIPE check on numeric IP unless ripecheck.topchk is enabled
        regexp ".+@(.+)" $host -> orghost
        if {[regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $orghost]} {
            ::ripecheck::debug "Found numeric IP $orghost ... scanning"
            ::ripecheck::whoisFindServer $orghost $orghost 1 $nick $channel $host ripecheck
        } elseif {[channel get $channel ripecheck.topchk]} {
            # Check if channel has a resolve domain list or complain about it and then abort
            if {![info exists ::ripecheck::topresolv($channel)]} {
                putlog "ripecheck: Ripecheck is enabled but '$channel' has no resolve domain list!"
                return 0
            }

            ::ripecheck::debug "Checking if host match the top resolve list..."

            set htopdom [lindex [split $iphost "."] end]
            if {[::ripecheck::isInTopResolve $channel $htopdom]} {
                ::ripecheck::debug "Matched top resolve domain '$htopdom' for host '$iphost'"
                ::ripecheck::whoisFindServer $ip $iphost 1 $nick $channel $host ripecheck
            }
        }
    }

    proc notifySender { nick channel rtype msg } {
        ::ripecheck::debug "Entering notifySender()"
        if {[regexp {^pub} $rtype]} {
            puthelp "PRIVMSG $channel :$nick: \[ripecheck\] $msg"
        } elseif {[regexp {^msg} $rtype]} {
            puthelp "PRIVMSG $nick :ripecheck: $msg"
        }
    }

    proc ripecheck { ip host nick channel orghost ripe } {
        ::ripecheck::debug "Entering ripecheck()"
        set bantime [channel get $channel ripecheck.bantime]
        if {(![channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $ripe] != -1) || \
            ([channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $ripe] == -1)} {
            ::ripecheck::debug "ripecheck() matched '$ripe'"
            set country [::ripecheck::getCountry $ripe]
            set template [list %nick% $nick \
                               %ripe% $ripe \
                               %tld% $ripe \
                               %country% $country]
            if {[info exists ::ripecheck::config(banreason)]} {
                set banreason [::ripecheck::templateReplace $::ripecheck::config(banreason) $template]
            } else {
                set banreason "RIPE Country Check: Matched $country \[$ripe\]"
            }
            putlog "ripecheck: Matched country $country \[$ripe\] banning $nick!$orghost on $channel for $bantime minute(s)"
            if {![::ripecheck::isConfigEnabled logmode]} {
                # If we get a match always use the original host or we may get fooled by DNS
                regexp ".+@(.+)" $orghost -> realhost
                ::ripecheck::incrBanCount $channel
                newchanban $channel "*!*@$realhost" ripecheck $banreason $bantime
            }
        }
    }

    proc incrBanCount { channel } {
        if {![info exists ::ripecheck::bancount($channel)]} {
            set ::ripecheck::bancount($channel) 1
        } else {
            set ::ripecheck::bancount($channel) [expr $::ripecheck::bancount($channel) + 1]
        }
        ::ripecheck::writeSettings
    }

    proc getBanCount { channel } {
        if {![info exists ::ripecheck::bancount($channel)]} {
            return 0
        }
        return $::ripecheck::bancount($channel)
    }

    # Return length of the longest string
    proc getLongLength { listOfStrings } {
        set len 0
        foreach str $listOfStrings {
            if {$len < [string length $str]} {
                set len [string length $str]
            }
        }
        return $len
    }

    # Return http data
    proc getHttpData { url } {
        if {[catch {set http [::http::geturl $url -timeout [expr {int($::ripecheck::rtimeout * 1000)}]]} error]} {
            return [dict set httpData status $error]
        }

        if {[::http::status $http] == "eof"} {
            ::http::cleanup $http
            return [dict set httpData status "Server closed the connection without replying!"]
        }

        if {[::http::status $http] == "error"} {
            set httpErr [::http::error $http]
            ::http::cleanup $http
            return [dict set httpData status $httpErr]
        }

        dict set httpData data [::http::data $http]
        dict set httpData status [::http::status $http]
        ::http::cleanup $http

        return $httpData
    }

    # Return ipinfodb data
    proc getGeoData { ip } {
        # Check if API key have been set
        if {![info exists ::ripecheck::config(ipinfodbkey)]} {
            return [dict set status Status "API key for ipinfodb.com not set!"]
        }

        set httpData [::ripecheck::getHttpData "${::ripecheck::ipinfodb}key=${::ripecheck::config(ipinfodbkey)}&ip=$ip&timezone=false"]
        if {![dict exists $httpData status]} {
            return [dict set status Status "Unknown HTTP error occured!"]
        } elseif {[dict get $httpData status] != "ok"} {
            return [dict set status Status [dict get $httpData status]]
        }

        # TODO: Consider using tdom or other xml parser
        regexp {(?i)<Status>([^<>]+)} [dict get $httpData data] -> geoData(Status)
        dict set geoDict Status $geoData(Status)

        # If status ok parse the rest
        if {$geoData(Status) == "OK"} {
            foreach tag [list "Ip" "CountryCode" "CountryName" "RegionCode" "RegionName" "City" "ZipPostalCode" "Latitude" "Longitude"] {
                regexp "(?i)<$tag>(\[^<>\]+)" [dict get $httpData data] -> geoData($tag)

                # Set blank if regexp fail to get value or if value is empty
                if {![info exists geoData($tag)]} {
                    set geoData($tag) ""
                }
                if {$tag == "CountryName" && $geoData($tag) != "Reserved" && [info exists geoData(CountryCode)]} {
                    set geoData($tag) "$geoData($tag) \[$geoData(CountryCode)\]"
                }
                dict set geoDict $tag $geoData($tag)
            }
        }

        return $geoDict
    }

    proc test { nick idx arg } {
        if {[llength [split $arg]] != 2} {
            ::stderreu::testripecheck $idx; return 0
        }

        foreach {channel ip} $arg {break}
        set ip [string tolower $ip]
        set channel [string tolower $channel]

        if {[validchan $channel]} {
            # First we check if topban is enabled
            if {[channel get $channel ripecheck.topban] && ![regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $ip]} {
                set htopdom [lindex [split $ip "."] end]
                if {(![channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $htopdom] != -1) || \
                    ([channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $htopdom] == -1 && ![::ripecheck::isInTopResolve $channel $htopdom])} {
                    ::ripecheck::debug "Topban matched '$htopdom' for host '$ip', host would get banned!"

                    return 1
                }
            }

            if {[regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $ip]} {
                ::ripecheck::whoisFindServer $ip "" ""  $nick $channel "" testRipeCheck
            } else {
                ::ripecheck::debug "Resolving..."
                set htopdom [lindex [split $ip "."] end]
                if {[lsearch -exact $::ripecheck::topresolv($channel) "*"] != -1 || [lsearch -exact $::ripecheck::topresolv($channel) $htopdom] != -1} {
                    ::ripecheck::debug "Matched top resolve domain '$htopdom' for host '$ip' on '$channel'"
                    dnslookup $ip ::ripecheck::whoisFindServer $nick $channel "" testRipeCheck
                } else {
                    putidx $idx "ripecheck: TEST - Host '$ip' did not match one of the top resolve domains, would not get banned."
                }
            }
        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid channel $channel"
        }
    }

    proc ripeInfo { target whoisData } {
        ::ripecheck::debug "Entering ripeInfo()"
        set countryname [::ripecheck::getCountry [dict get $whoisData Country]]
        if {$countryname != ""} {
            dict set whoisData Country "$countryname \[[string toupper [dict get $whoisData Country]]\]"
        }

        # Get proper string lengths for [format]
        dict for {key val} $whoisData {
            set len($key) [getLongLength [list $val $key]]
        }

        set msgheader [format "%-*s | %-*s | %-*s | %-*s | %-*s | %-*s | %-*s" \
                           $len(InetNum) "InetNum" \
                           $len(Asn) "Asn" \
                           $len(NetName) "NetName" \
                           $len(MntBy) "MntBy" \
                           $len(Country) "Country" \
                           $len(AbuseMail) "Contact" \
                           $len(Description) "Description"]

        set msg [format "%-*s | %-*s | %-*s | %-*s | %-*s | %-*s | %-*s" \
                     $len(InetNum) [dict get $whoisData InetNum] \
                     $len(Asn) [dict get $whoisData Asn] \
                     $len(NetName) [dict get $whoisData NetName] \
                     $len(MntBy) [dict get $whoisData MntBy] \
                     $len(Country) [dict get $whoisData Country] \
                     $len(AbuseMail) [dict get $whoisData AbuseMail] \
                     $len(Description) [dict get $whoisData Description]]

        putquick "PRIVMSG $target :$msgheader"
        putquick "PRIVMSG $target :$msg"
    }

    proc geoInfo { ip host status nick channel rtype } {
        ::ripecheck::debug "Entering geoInfo()"

        if {$status == 0} {
            ::ripecheck::notifySender $nick $channel $rtype "Failed to resolve '$host'!"
            putlog "ripecheck: Couldn't resolve '$host'. No further action taken."
            return 0
        }

        set geoData [::ripecheck::getGeoData $ip]

        if {[dict get $geoData Status] != "OK"} {
            ::ripecheck::notifySender $nick $channel $rtype "ERROR: [dict get $geoData Status]"
            return 0
        }

        # If it is a reserved address send notice and abort
        if {[dict get $geoData CountryName] == "Reserved"} {
            ::ripecheck::notifySender $nick $channel $rtype "$ip belongs to a reserved net range"
            return 1
        }

        # Get lengths for format
        dict for {geoKey geoVal} $geoData {
            set len($geoKey) [getLongLength [list [encoding convertfrom utf-8 $geoVal] $geoKey]]
        }

        set googleUrl "http://maps.google.com/maps?q=[dict get $geoData Latitude],[dict get $geoData Longitude]&z=7"
        set msgheader [format "%-*s | %-*s | %-*s | %-*s | %-*s | %-*s | %-*s" \
                           $len(Ip) "IP" \
                           $len(CountryName) "CountryName" \
                           $len(RegionName) "RegionName" \
                           $len(City) "City" \
                           $len(Latitude) "Latitude" \
                           $len(Longitude) "Longitude" \
                           3 "Map"]
        set msg [format "%-*s | %-*s | %-*s | %-*s | %-*s | %-*s | %-*s" \
                     $len(Ip) [dict get $geoData Ip] \
                     $len(CountryName) [dict get $geoData CountryName] \
                     $len(RegionName) [dict get $geoData RegionName] \
                     $len(City) [dict get $geoData City] \
                     $len(Latitude) [dict get $geoData Latitude] \
                     $len(Longitude) [dict get $geoData Longitude] \
                     3 $googleUrl]

        if {$rtype == "pubRipeGeo"} {
            set target $channel
        } else {
            set target $nick
        }

        putquick "PRIVMSG $target :$msgheader"
        putquick "PRIVMSG $target :$msg"
    }

    proc testripecheck { nick ip host channel ripe } {
        # Get idx from nick (handle)
        set idx [hand2idx $nick]
        if {$idx != -1} {
            if {(![channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $ripe] != -1) || \
                ([channel get $channel ripecheck.whitelist] && [lsearch -exact $::ripecheck::chanarr($channel) $ripe] == -1)} {
                putidx $idx "ripecheck: TEST - Testripecheck matched country '$ripe' for host '$host ($ip)' on channel '$channel', host would get banned!"
            } else {
                putidx $idx "ripecheck: TEST - Testripecheck host '$host ($ip)' would not get banned!"
            }
        }
    }

    proc status { outchannel channel} {
        if {[info exists ::ripecheck::topresolv($channel)]} {
            set topresolve [join $::ripecheck::topresolv($channel) ", "]
        } else {
            set topresolve "No TLD set"
        }

        if {[info exists ::ripecheck::chanarr($channel)]} {
            set tlds [join $::ripecheck::chanarr($channel) ", "]
        } else {
            set tlds "No TLD set"
        }

        putquick "PRIVMSG $outchannel :Status $channel -- Bans set by ripecheck: [::ripecheck::getBanCount $channel]"
        if {[channel get $channel ripecheck.whitelist]} {
            putquick "PRIVMSG $outchannel : Allowed TLD(s): $tlds | Resolve TLD(s): $topresolve"
        } else {
            putquick "PRIVMSG $outchannel : Banned TLDs(s): $tlds | Resolve TLD(s): $topresolve"
        }
    }

    # Check if chan is valid and that the bot is in the channel
    proc isBotOnChan { channel } {
        global botnick
        if {[validchan $channel] && [onchan $botnick $channel]} {
            return 1
        }
        return 0
    }

    proc pubParseIp { nick host handle channel ip rtype } {
        if {[regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $ip]} {
            if {$rtype == "pubRipeGeo" || $rtype == "msgRipeGeo"} {
                ::ripecheck::geoInfo $ip $ip "" $nick $channel $rtype
            } else {
                set iptype [::ip::type $ip]
                if {$iptype != "normal"} {
                    ::ripecheck::notifySender $nick $channel $rtype "Sorry but '$ip' is from a '$iptype' range"
                } else {
                    ::ripecheck::whoisFindServer $ip $ip "" $nick $channel "" $rtype
                }
            }
        } else {
            if {$rtype == "pubRipeGeo" || $rtype == "msgRipeGeo"} {
                dnslookup $ip ::ripecheck::geoInfo $nick $channel $rtype
            } else {
                dnslookup $ip ::ripecheck::whoisFindServer $nick $channel "" $rtype
            }
        }
    }

    proc pubRipeCheck { nick host handle channel arg } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }
        set ip [::ripecheck::getNickOrHost $channel $arg]
        ::ripecheck::pubParseIp $nick $host $handle $channel $ip pubRipeCheck
    }

    proc msgRipeCheck { nick host handle ip } {
        # Check if msgcmds is enabled
        if {[::ripecheck::isConfigEnabled msgcmds]} {
            ::ripecheck::pubParseIp $nick $host $handle "" $ip msgRipeCheck
        }
    }

    proc pubRipeInfo { nick host handle channel arg } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }
        foreach { arg1 arg2 } $arg {break}
        # is it a channel?
        if {[regexp {^#} $arg1] && $arg2 != ""} {
            if {[::ripecheck::isBotOnChan $arg1]} {
                set tchannel $arg1
                set targ $arg2
            } else {
                ::ripecheck::notifySender $nick $channel pubRipeGeo "Invalid channel '$arg1'!"
                return 0
            }
        } else {
            set tchannel $channel
            set targ $arg1
        }
        set ip [::ripecheck::getNickOrHost $tchannel $targ]
        ::ripecheck::pubParseIp $nick $host $handle $channel $ip pubRipeInfo
    }

    proc msgRipeInfo { nick host handle ip } {
        # Check if msgcmds is enabled
        if {[::ripecheck::isConfigEnabled msgcmds]} {
            ::ripecheck::pubParseIp $nick $host $handle "" $ip msgRipeInfo
        }
    }

    proc pubRipeGeo { nick host handle channel arg } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }
        foreach { arg1 arg2 } $arg {break}
        # is it a channel?
        if {[regexp {^#} $arg1] && $arg2 != ""} {
            if {[::ripecheck::isBotOnChan $arg1]} {
                set tchannel $arg1
                set targ $arg2
            } else {
                ::ripecheck::notifySender $nick $channel pubRipeGeo "Invalid channel '$arg1'!"
                return 0
            }
        } else {
            set tchannel $channel
            set targ $arg1
        }
        set ip [::ripecheck::getNickOrHost $tchannel $targ]
        ::ripecheck::pubParseIp $nick $host $handle $channel $ip pubRipeGeo
    }

    proc msgRipeGeo { nick host handle ip } {
        if {[::ripecheck::isConfigEnabled msgcmds]} {
            ::ripecheck::pubParseIp $nick $host $handle "" $ip msgRipeGeo
        }
    }

    proc pubRipeTld { nick host handle channel tld } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }
        set country [::ripecheck::getCountry $tld]
        if { $country != "" } {
            ::ripecheck::notifySender $nick $channel pubRipeTld "Country for TLD '$tld' is '$country'"
        } else {
            ::ripecheck::notifySender $nick $channel pubRipeTld "No matching country for TLD '$tld'"
        }
    }

    proc msgRipeTld { nick host handle tld } {
        # Check if msgcmds is enabled
        if {[::ripecheck::isConfigEnabled msgcmds]} {
            set country [::ripecheck::getCountry $tld]
            if { $country != "" } {
                ::ripecheck::notifySender $nick "" msgRipeTld "Country for TLD '$tld' is '$country'"
            } else {
                ::ripecheck::notifySender $nick "" msgRipeTld "No matching country for TLD '$tld'"
            }
        }
    }

    proc pubRipeStatus { nick host handle channel arg } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }

        # Grab only first arg and ignore the rest
        set arg [string tolower [lindex [split $arg] 0]]

        if {$arg == "*"} {
            foreach chan [channels] {
                if {[channel get $chan ripecheck]} {
                    ::ripecheck::status $channel $chan
                }
            }
        } elseif {$arg != "" && [channel get $arg ripecheck]} {
            ::ripecheck::status $channel $arg
        } else {
            ::ripecheck::status $channel $channel
        }
    }

    proc pubRipeScan { nick host handle channel arg } {
        set channel [string tolower $channel]
        if {![channel get $channel ripecheck.pubcmd]} { return 0 }

        # Grab only first arg and ignore the rest
        set arg [string tolower [lindex [split $arg] 0]]

        # Default to scanning the channel where command was issued
        if {$arg == ""} {
            set arg $channel
        }

        if {[validchan $arg] && [channel get $arg ripecheck]} {
            ::ripecheck::notifySender $nick $channel pubRipeScan "Scanning $arg, please wait..."
            ::ripecheck::runRipeScan $arg
            ::ripecheck::notifySender $nick $channel pubRipeScan "...scan complete."
        } else {
            ::ripecheck::notifySender $nick $channel pubRipeScan "Invalid channel or ripecheck is not enabled for '$arg'"
        }
    }

    proc dccRipeScan { nick idx arg } {
        if {[llength [split $arg]] != 1} {
            ::stderreu::ripescan $idx; return 0
        }
        set channel [string tolower [lindex [split $arg] 0]]

        if {[validchan $channel] && [channel get $channel ripecheck]} {
            ::ripecheck::runRipeScan $channel
        } else {
            putdcc $idx "ripecheck: Invalid channel or ripecheck is not enabled for '$arg'"
        }
    }

    proc runRipeScan { channel } {
        ::ripecheck::debug "Running ripescan..."
        foreach cnick [chanlist $channel] {
            if {[isbotnick $cnick]} {
                ::ripecheck::debug "Found myself ($cnick) - Ignoring"
                continue
            }
            # Get IP/Host part
            set nhost [getchanhost $cnick $channel]
            regexp ".+@(.+)" $nhost matches iphost
            set iphost [string tolower $iphost]

            ::ripecheck::debug "Found host '$nhost' for nick '$cnick'"
            dnslookup $iphost ::ripecheck::onJoinRouter $cnick $nhost $channel
        }
    }

    proc pubRipeHelp { nick host handle channel arg } {
        ::ripecheck::notifySender $nick $channel pubRipeHelp "Available commands: !ripecheck <nick|host>, !ripeinfo \[channel\] <nick|host>, !ripegeo \[channel\] <nick|host>, !ripestatus \[*|channel\], !ripetld <tld>, !ripehelp"
    }

    proc msgRipeHelp { nick host handle arg } {
        ::ripecheck::notifySender $nick "" msgRipeHelp "Available commands: !ripecheck <host>, !ripeinfo <host>, !ripegeo <host>, !ripetld <tld>, !ripehelp"
    }

    proc getNickOrHost { channel arg } {
        set arg [lindex [split $arg] 0]

        # Check if arg is a nick or return arg
        if {[onchan $arg $channel]} {
            # Extract host from nick
            regexp ".+@(.+)" [getchanhost $arg $channel] -> host
            set host [string tolower $host]
            if {$host != ""} {
                return $host
            }
        }
        return $arg
    }

    # Lookup which whois server to query and call whois_connect
    proc whoisFindServer { ip host status nick channel orghost rtype } {
        if {$status == 0} {
            ::ripecheck::notifySender $nick $channel $rtype "Failed to resolve '$host'!"
            putlog "ripecheck: Couldn't resolve '$host'. No further action taken."
            return 0
        }

        # Abort if we stumble upon a private or reserved net range
        set iptype [::ip::type $ip]
        if {$iptype != "normal"} {
            putlog "ripecheck: '$ip' is from a '$iptype' range. No further action taken."
            return 0
        }

        set matchmask [::ip::longestPrefixMatch $ip $::ripecheck::maskarray]
        set whoisdb [string tolower $::ripecheck::maskhash($matchmask)]
        set whoisport 43

        ::ripecheck::debug "Matching mask $matchmask using whois DB: $whoisdb"

        if {$whoisdb == "unallocated"} {
            ::ripecheck::notifySender $nick $channel $rtype "Unallocated netmask!"
            putlog "ripecheck: Unallocated netmask, bailing out!"
            return 0
        }

        ::ripecheck::whoisConnect $ip $host $nick $channel $orghost $whoisdb $whoisport $rtype
    }

    proc whoisConnect { ip host nick channel orghost whoisdb whoisport rtype } {
        # Setup timeout
        after [expr {int($::ripecheck::rtimeout * 1000)}] set ::ripecheck::constate "timeout"

        if {[catch {socket -async $whoisdb $whoisport} sock]} {
            ::ripecheck::notifySender $nick $channel $rtype "ERROR: Failed to connect to '$whoisdb'!"
            putlog "ripecheck: ERROR: Failed to connect to server $whoisdb!" ; return -1
        }
        fconfigure $sock -buffering line
        fileevent $sock writable [list ::ripecheck::whoisCallback $ip $host $nick $channel $orghost $sock $whoisdb $rtype]
        vwait ::ripecheck::constate
        if { $::ripecheck::constate == "timeout" } {
            ::ripecheck::notifySender $nick $channel $rtype "ERROR: Connection timeout using '$whoisdb'!"
            close $sock
            putlog "ripecheck: ERROR: Connection timeout against $whoisdb"; return -1
        }
    }

    proc whoisCallback { ip host nick channel orghost sock whoisdb rtype } {
        ::ripecheck::debug "Entering whois_callback() - $rtype"
        foreach entry [list InetNum NetName MntBy Description Asn AbuseMail] {
            dict set whoisData $entry ""
        }

        if {[string equal {} [fconfigure $sock -error]]} {
            puts $sock $ip
            flush $sock

            ::ripecheck::debug "State 'connected' with '$whoisdb'"

            set ::ripecheck::constate "connected"
            set descDone 0
            set previous ""

            while {![eof $sock]} {
                set row [gets $sock]

                # Probably rwhois data, strip network:
                if {[regexp -line -nocase {^network:} $row]} {
                    set row [join [lrange [split $row :] 1 end] ": "]
                }

                if {[regexp -line -nocase {referralserver:\s*(.*)} $row -> referral]} {
                    set referral [string tolower $referral]
                    ::ripecheck::debug "Found whois referral server: $referral"

                    # Extract the whois server from $referral
                    if {[regexp -line -nocase {^r?whois://(.*[^/])/?} $referral -> referral]} {
                        foreach {referral whoisport} [split $referral :] { break }

                        # Set default port if empty
                        if {$whoisport == ""} {
                            set whoisport 43
                        }

                        # Close socket, don't want to many sockets open simultaneously
                        close $sock

                        # Time for some recursive looping ;)
                        ::ripecheck::debug "Following referral server, new server is '$referral', port '$whoisport'"
                        ::ripecheck::whoisConnect $ip $host $nick $channel $orghost $referral $whoisport $rtype

                        return 1
                    } else {
                        putlog "ripecheck: ERROR: Unknown referral type from '$whoisdb' for ip '$ip', please bug report this line."
                        close $sock; return 0
                    }
                } elseif {[regexp -line -nocase {(?:Country-Code|country):\s*([a-z]{2,6})} $row -> data] && ![dict exists $whoisData Country]} {
                    dict set whoisData Country [string tolower $data]
                    ::ripecheck::debug "$whoisdb answer: [dict get $whoisData Country]"
                } elseif {[regexp -line {.*\((NET-[0-9]{1,3}-[0-9]{1,3}-[0-9]{1,3}.*)\)} $row -> data]} {
                    dict set whoisData fallback $data
                }

                # Only run this for public commands to speed things up
                if {$rtype != "ripecheck" && $rtype != "testRipeCheck"} {
                    if {[regexp -line -nocase {netname:\s*(.*)} $row -> data]} {
                        dict set whoisData NetName $data
                    } elseif {[regexp -line -nocase {descr:\s*(.*)} $row -> data] && $descDone == 0} {
                        if {![regexp -line -nocase {^\=} $data]} {
                            lappend whoisDesc $data
                        }
                    } elseif {[regexp -line -nocase {owner:\s*(.*)} $row -> data]} {
                        dict set whoisData Owner $data
                    } elseif {[dict get $whoisData MntBy] == "" && [regexp -line -nocase {(?:ownerid|mnt-by):\s*(.*)} $row -> data]} {
                        dict set whoisData MntBy $data
                    } elseif {[regexp -line -nocase {(?:Auth-Area|inetnum|NetRange):\s*(.*)} $row -> data]} {
                        dict set whoisData InetNum $data
                    } elseif {[regexp -line -nocase {origin:\s*(.*)} $row -> data]} {
                        dict set whoisData Asn $data
                    } elseif {[regexp -line -nocase {(?:Org-Name|OrgName):\s*(.*)} $row -> data]} {
                        dict set whoisData OrgName $data
                    } elseif {[regexp -line -nocase {(?:Street-Address|Address):\s*(.*)} $row -> data]} {
                        dict set whoisData StreetAddress $data
                    } elseif {[regexp -line -nocase {City:\s*(.*)} $row -> data]} {
                        dict set whoisData City $data
                    } elseif {[regexp -line -nocase {(?:Postal-Code|PostalCode):\s*(.*)} $row -> data]} {
                        dict set whoisData PostalCode $data
                    } elseif {[regexp -line -nocase {(?:State-Prov|StateProv):\s*(.*)} $row -> data]} {
                        dict set whoisData StateProv $data
                    } elseif {[regexp -line -nocase {(?:Abuse-Phone|OrgAbusePhone):\s*(.*)} $row -> data]} {
                        dict set whoisData AbusePhone $data
                    } elseif {[dict get $whoisData AbuseMail] == "" && [regexp -line -nocase {(?:Abuse-Email|abuse-mailbox|e-mail|OrgAbuseEmail):\s*(.*)} $row -> data]} {
                        dict set whoisData AbuseMail [string tolower $data]
                    }

                    if {$descDone == 0 && [regexp -line -nocase {descr:\s.*} $previous] && ![regexp -line -nocase {descr:\s.*} $row]} {
                        set descDone 1
                    }
                    set previous $row
                }
            }

            close $sock
            ::ripecheck::debug "End of while-loop in whois_callback"

            # Only run this for public commands to speed things up
            if {$rtype != "ripecheck" && $rtype != "testRipeCheck" } {
                # Append phone number to abuse contact
                if {[dict exists $whoisData AbusePhone]} {
                    if {[dict exists $whoisData AbuseMail]} {
                        dict set whoisData AbuseMail "[dict get $whoisData AbuseMail], [dict get $whoisData AbusePhone]"
                    } else {
                        dict set whoisData AbuseMail [dict get $whoisData AbusePhone]
                    }
                }

                # Set final description
                if {![info exists whoisDesc]} {
                    foreach entry [list OrgName StreetAddress City StateProv PostalCode Country] {
                        if {[dict exists $whoisData $entry]} {
                            lappend whoisDesc [dict get $whoisData $entry]
                        }
                    }
                }
                if {[info exists whoisDesc] && [llength $whoisDesc] > 0} {
                    dict set whoisData Description [join $whoisDesc ", "]
                } elseif {[dict exists $whoisData Owner]} {
                    dict set whoisData Description [dict get $whoisData Owner]
                }
            }

            # Experimental feature that might replace lastResortMasks in the future
            if {[::ripecheck::isConfigEnabled fallback] && ![dict exists $whoisData Country] && [dict exists $whoisData fallback]} {
                ::ripecheck::debug "Using fallback method for '[dict get $whoisData fallback]' original host was $host ($ip)"
                ::ripecheck::whoisConnect [dict get $whoisData fallback] $host $nick $channel $orghost $whoisdb 43 $rtype
                return 1
            }

            if {[dict exists $whoisData Country]} {
                ::ripecheck::debug "Running mode: '$rtype' for country: [dict get $whoisData Country]"
                set country [::ripecheck::getCountry [dict get $whoisData Country]]
                switch -- $rtype {
                    ripecheck {
                        ::ripecheck::ripecheck $ip $host $nick $channel $orghost [dict get $whoisData Country]
                    }
                    testRipeCheck {
                        ::ripecheck::testripecheck $nick $ip $host $channel [dict get $whoisData Country]
                    }
                    pubRipeCheck {
                        ::ripecheck::notifySender $nick $channel $rtype "$host is located in $country \[[string toupper [dict get $whoisData Country]]\]"
                    }
                    msgRipeCheck {
                        ::ripecheck::notifySender $nick $channel $rtype "$host is located in $country \[[string toupper [dict get $whoisData Country]]\]"
                    }
                    pubRipeInfo {
                        ::ripecheck::ripeInfo $channel $whoisData
                    }
                    msgRipeInfo {
                        ::ripecheck::ripeInfo $nick $whoisData
                    }
                    default {
                        ::ripecheck::ripecheck $ip $host $nick $channel $orghost [dict get $whoisData Country]
                    }
                }
            } else {
                # Respond that something went wrong
                ::ripecheck::notifySender $nick $channel $rtype "Whois query failed for '$host'!"
                putlog "ripecheck: No country found for '$ip'. No further action taken. Possible bug?"
            }
        } else {
            set ::ripecheck::constate "timeout"
        }
    }

    # Add top resolv domain for channel and write settings to file
    proc addTopResolve { nick idx arg } {
        if {[llength [split $arg]] != 2} {
            ::stderreu::+ripetopresolv $idx; return 0
        }

        foreach {channel topdom} $arg {break}

        set channel [string tolower $channel]
        set topdom [string tolower $topdom]

        if {[validchan $channel]} {
            # It's pointless to set a resolv domain if no domains have been added for banning on the
            # current channel.
            if {[info exists ::ripecheck::chanarr($channel)]} {
                # If data exist extract into a list
                if {[info exists ::ripecheck::topresolv($channel)]} {
                    ::ripecheck::debug "topresolv exists"
                    # top domain doesn't exist so lets add it
                    if {[lsearch -exact $::ripecheck::topresolv($channel) $topdom] == -1 } {
                        lappend ::ripecheck::topresolv($channel) $topdom
                    } else {
                        putdcc $idx "\002RIPECHECK\002: Resolve domain '$topdom' already exist on $channel"; return 0
                    }
                } else {
                    ::ripecheck::debug "topresolv doesn't exist"
                    set ::ripecheck::topresolv($channel) [list $topdom]
                }
                # Write to the ripecheck channel file
                ::ripecheck::writeSettings
                putdcc $idx "\002RIPECHECK\002: Top resolve domain '$topdom' successfully added to $channel."
            } else {
                putdcc $idx "\002RIPECHECK\002: You need to add a top domain for $channel before adding a resolve domain."
            }
        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid channel: $channel"
        }
    }

    # Remove resolve domain from channel and write settings to file
    proc delTopResolve { nick idx arg } {
        if {[llength [split $arg]] != 2} {
            ::stderreu::-ripetopresolv $idx; return 0
        }

        foreach {channel topdom} $arg {break}

        set channel [string tolower $channel]
        set topdom [string tolower $topdom]

        if {[validchan $channel]} {
            if {[info exists ::ripecheck::topresolv($channel)]} {
                ::ripecheck::debug "topresolv($channel) exists"
                 # resolve domain exist so lets remove it
                set dlist_index [lsearch -exact $::ripecheck::topresolv($channel) $topdom]
                if {$dlist_index != -1 } {
                    set ::ripecheck::topresolv($channel) [lreplace $::ripecheck::topresolv($channel) $dlist_index $dlist_index]
                    # More magic, lets clear array if the list is empty
                    if {![llength $::ripecheck::topresolv($channel)] > 0} {
                        unset ::ripecheck::topresolv($channel)
                    }
                } else {
                    putdcc $idx "\002RIPECHECK\002: Resolve domain '$topdom' doesn't exist on $channel"; return 0
                }

            } else {
                putdcc $idx "\002RIPECHECK\002: Nothing to do, no settings found for $channel."; return 0
            }
            # Write to the ripecheck channel file
            ::ripecheck::writeSettings
            putdcc $idx "\002RIPECHECK\002: Resolve domain '$topdom' successfully removed from $channel."

        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid channel: $channel"
        }
    }

    # List channel and top resolv domains
    proc settings { nick idx arg } {
        putdcc $idx "### \002Settings\002 - Ripecheck v$::ripecheck::version by Ratler ###"
        if {[array size ::ripecheck::chanarr] > 0} {
            foreach channel [array names ::ripecheck::chanarr] {
                if {[validchan $channel]} {
                    putdcc $idx "### \002Channel:\002 $channel"
                    if {[channel get $channel ripecheck.whitelist]} {
                        putdcc $idx "    Whitelist mode: On"
                        putdcc $idx "    \002Allowed domains:\002 [join $::ripecheck::chanarr($channel) ", "]"
                    } else {
                        putdcc $idx "    Whitelist mode: Off"
                        putdcc $idx "    \002Banned domains:\002 [join $::ripecheck::chanarr($channel) ", "]"
                    }
                    if {[info exists ::ripecheck::topresolv($channel)]} {
                        putdcc $idx "    \002Resolve domains:\002 [join $::ripecheck::topresolv($channel) ", "]"
                    }
                }
            }
        } else {
            putdcc $idx "### No channel settings exist."
        }
        foreach option [array names ::ripecheck::config] {
            putdcc $idx "### \002$option:\002 $::ripecheck::config($option)"
        }
    }

    # Function to set general options
    proc config { nick idx arg } {
        if {!([llength [split $arg]] > 0)} {
            ::stderreu::ripeconfig $idx; return 0
        }

        # Allowed string options
        set allowed_str_opts [list banreason bantopreason ipinfodbkey]

        # Allowed boolean options
        set allowed_bool_opts [list msgcmds fallback geoban logmode]

        set option [string tolower [lindex [split $arg] 0]]
        set value [join [lrange [split $arg] 1 end]]


        # Check option type
        if {[lsearch -exact $allowed_str_opts $option] != -1} {
            if {$value != ""} {
                set ::ripecheck::config($option) $value
                putdcc $idx "\002RIPECHECK\002: Option '$option' set with the value '$value'"
            } else {
                if {[info exists ::ripecheck::config($option)]} {
                    unset ::ripecheck::config($option)
                }
                # Always output unset msg for convenience
                putdcc $idx "\002RIPECHECK\002: Option '$option' unset"
            }
        } elseif {[lsearch -exact $allowed_bool_opts $option] != -1} {
            set value [string tolower $value]
            if {[string is boolean $value] && $value != ""} {
                set ::ripecheck::config($option) $value
                putdcc $idx "\002RIPECHECK\002: Option '$option' set with the value '$value'"
            } elseif { $value == "" } {
                if {[info exists ::ripecheck::config($option)]} {
                    unset ::ripecheck::config($option)
                }
                # Always output unset msg for convenience
                putdcc $idx "\002RIPECHECK\002: Option '$option' unset"
            } else {
                putdcc $idx "\002RIPECHECK\002: Value '$value' is not a boolean, should be true|false|on|off|1|0"
                return 0
            }
        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid option '$option', valid options are: [join $allowed_str_opts ", "], [join $allowed_bool_opts ", "]"
            return 0
        }

        ::ripecheck::writeSettings
    }

    # Add top domain to channel and write settings to file
    proc addTopDom { nick idx arg } {
        if {[llength [split $arg]] != 2} {
            ::stderreu::+ripetopdom $idx; return 0
        }

        foreach {channel topdom} $arg {break}

        set channel [string tolower $channel]
        set topdom [string tolower $topdom]

        if {[validchan $channel]} {
            # If data exist extract into a list
            if {[info exists ::ripecheck::chanarr($channel)]} {
                ::ripecheck::debug "chanarr exists"
                # top domain doesn't exist so lets add it
                if {[lsearch -exact $::ripecheck::chanarr($channel) $topdom] == -1 } {
                    lappend ::ripecheck::chanarr($channel) $topdom
                } else {
                    putdcc $idx "\002RIPECHECK\002: Domain '$topdom' already exist on $channel"; return 0
                }
            } else {
                ::ripecheck::debug "chanarr doesn't exist"
                set ::ripecheck::chanarr($channel) [list $topdom]
            }
            # Write to the ripecheck channel file
            ::ripecheck::writeSettings
            putdcc $idx "\002RIPECHECK\002: Top domain '$topdom' successfully added to $channel."
        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid channel: $channel"
        }
    }

    # Remove top domain for channel and write settings to file
    proc delTopDom { nick idx arg } {
        if {[llength [split $arg]] != 2} {
            ::stderreu::-ripetopdom $idx; return 0
        }

        foreach {channel topdom} $arg {break}

        set channel [string tolower $channel]
        set topdom [string tolower $topdom]

        if {[validchan $channel]} {
            if {[info exists ::ripecheck::chanarr($channel)]} {
                ::ripecheck::debug "chanarr($channel) exists"
                # top domain doesn't exist so lets add it
                set dlist_index [lsearch -exact $::ripecheck::chanarr($channel) $topdom]
                if {$dlist_index != -1 } {
                    set ::ripecheck::chanarr($channel) [lreplace $::ripecheck::chanarr($channel) $dlist_index $dlist_index]
                    # More magic, clear array if list is empty
                    if {![llength $::ripecheck::chanarr($channel)] > 0} {
                        unset ::ripecheck::chanarr($channel)
                    }
                } else {
                    putdcc $idx "\002RIPECHECK\002: Domain '$topdom' doesn't exist on $channel"; return 0
                }

            } else {
                putdcc $idx "\002RIPECHECK\002: Nothing to do, no settings found for $channel."; return 0
            }
            # Write to the ripecheck channel file
            ::ripecheck::writeSettings
            putdcc $idx "\002RIPECHECK\002: Top domain '$topdom' successfully removed from $channel."

        } else {
            putdcc $idx "\002RIPECHECK\002: Invalid channel: $channel"
        }
    }

    # Return a country based on tld or return "" if no country is found
    proc getCountry { tld } {
        if {[array size ::ripecheck::tldtocountry] > 0 && [info exists ::ripecheck::tldtocountry($tld)]} {
            set country $::ripecheck::tldtocountry($tld)
            if {$country != ""} {
                return $country
            }
        }
        return ""
    }

    # Return modified text based on template list
    proc templateReplace { text subs } {
        foreach {arg1 arg2} $subs {
            regsub -all -- $arg1 $text $arg2 text
        }
        return $text
    }

    proc isConfigEnabled { option } {
        if {[info exists ::ripecheck::config($option)] && [string is boolean $::ripecheck::config($option)] && [string is true $::ripecheck::config($option)]} {
            return true
        }
        return false
    }

    proc isInTopResolve { channel htopdom } {
        if {[lsearch -exact $::ripecheck::topresolv($channel) "*"] != -1 || [lsearch -exact $::ripecheck::topresolv($channel) $htopdom] != -1} {
            return true
        }
        return false
    }

    proc writeSettings { } {
        # Backup file in case something goes wrong
        if {[file exists $::ripecheck::chanfile]} {
            # Don't backup a zero byte file
            if {[file size $::ripecheck::chanfile] > 0} {
                file copy -force $::ripecheck::chanfile $::ripecheck::chanfile.bak
            }
        }
        set fp [open $::ripecheck::chanfile w]

        foreach key [array names ::ripecheck::chanarr] {
            puts $fp "$key:[join $::ripecheck::chanarr($key) ,]"
        }
        foreach key [array names ::ripecheck::topresolv] {
            puts $fp "topresolv:$key:[join $::ripecheck::topresolv($key) ,]"
        }
        foreach key [array names ::ripecheck::config] {
            puts $fp "config:$key:[join $::ripecheck::config($key)]"
        }
        foreach key [array names ::ripecheck::bancount] {
            puts $fp "stats:bancount:$key:$::ripecheck::bancount($key)"
        }
        close $fp
    }


}

# This name space is shared between all my script to hook into .help
namespace eval ::stderreu {
    variable helpfuncs

    dict set ::stderreu::helpfuncs ripecheck [list ripecheck +ripetopresolv -ripetopresolv +ripetopdom -ripetopdom ripescan ripesettings ripeconfig testripecheck]

    proc ripecheck { idx } {
        putidx $idx "### \002ripecheck v$::ripecheck::version\002 by Ratler ###"; putidx $idx ""
        putidx $idx "### \002chanset <channel> <+/->ripecheck\002"
        putidx $idx "    Enable (+) or disable (-) the script for specified channel"
        putidx $idx "### \002chanset <channel> ripecheck.bantime <minutes>\002"
        putidx $idx "    For how long should the ban be active in minutes"
        putidx $idx "### \002chanset <channel> <+/->ripecheck.topchk\002"
        putidx $idx "    Enable (+) or disable (-) top domain resolve check"
        putidx $idx "### \002chanset <channel> <+/->ripecheck.topban\002"
        putidx $idx "    Enable (+) or disable (-) top domain banning based on the topdomain list"
        putidx $idx "### \002chanset <channel> <+/->ripecheck.pubcmd\002"
        putidx $idx "    Enable (+) or disable (-) public commands (!ripecheck)"
        putidx $idx "### \002chanset <channel> <+/->ripecheck.whitelist\002"
        putidx $idx "    Enable (+) or disable (-) whitelist mode"
        putidx $idx "    The whitelist mode reverse the ripecheck behavior when matching"
        putidx $idx "    a country against the topdomain list. Instead of banning a country that"
        putidx $idx "    exist in the topdomain list it will let that host enter the channel and ban"
        putidx $idx "    everyone else."
        ::stderreu::+ripetopresolv $idx
        ::stderreu::-ripetopresolv $idx
        ::stderreu::+ripetopdom $idx
        ::stderreu::-ripetopdom $idx
        ::stderreu::ripescan $idx
        ::stderreu::ripesettings $idx
        ::stderreu::ripeconfig $idx
        ::stderreu::testripecheck $idx
        putidx $idx "### \002help ripecheck\002"
        putidx $idx "    This help page you're currently viewing"
    }

    proc +ripetopresolv { idx } {
        putidx $idx "### \002+ripetopresolv <channel> <topdomain|*>\002"
        putidx $idx "    Add a top domain or regexp pattern that you want to resolve for"
        putidx $idx "    further ripe checking. It's possible that domains like com, info, org"
        putidx $idx "    could be from a country that is banned in the top domain list."
        putidx $idx "    Example (match .com): .+ripetopresolv #channel com"
        putidx $idx "    Example (match everything): .+ripetopresolv #channel *"
    }

    proc -ripetopresolv { idx } {
        putidx $idx "### \002-ripetopresolv <channel> <topdomain|*>\002"
        putidx $idx "    Remove a top resolve domain or * from the channel that"
        putidx $idx "    you no longer wish to resolve."
    }

    proc +ripetopdom { idx } {
        putidx $idx "### \002+ripetopdom <channel> <topdomain>\002"
        putidx $idx "    Add a top domain for the channel that you wish to ban"
        putidx $idx "    Example: .+ripetopdom #channel ro"
    }
    proc -ripetopdom { idx } {
        putidx $idx "### \002-ripetopdom <channel> <topdomain>\002"
        putidx $idx "    Remove a top domain from the channel that you no longer wish to ban"
    }
    proc ripescan { idx } {
        putidx $idx "### \002ripescan <channel>\002"
        putidx $idx "    Scan channel and automatically ban all hosts that match existing rules for the channel"
    }
    proc ripeconfig { idx } {
        putidx $idx "### \002ripeconfig <option> \[value\]\002"
        putidx $idx "    \002Options\002:"
        putidx $idx "     banreason \[string\]    : Set custom ban reason, support substitutional keywords, see below"
        putidx $idx "     bantopreason \[string\] : Set custom TLD ban reason, support substitutional keywords, see below"
        putidx $idx "     msgcmds \[on|off\]      : Enable or disable commands through private message"
        putidx $idx "     geoban \[on|off\]       : Enable or disable GeoIP data as primary method of banning, whois will be used"
        putidx $idx "                             as fallback"
        putidx $idx "     logmode \[on|off\]      : Enable or disable log only mode, this will disable channel bans and kick counter."
        putidx $idx "     fallback \[on|off\]     : This function will _try_ to detect country for an host where the whois server"
        putidx $idx "                             only return a few NET-XXX-XXX-XXX-XXX entries."
        putidx $idx "     ipinfodbkey \[apikey\]  : Set ipinfodb.com API key."
        putidx $idx "                             Register with ipinfodb.com to recieve a FREE API key: http://www.ipinfodb.com/register.php"
        putidx $idx "    \002Examples\002:"
        putidx $idx "     TLD ban reason: .ripeconfig bantopreason Hello %nick%, TLD '%tld%' is not allowed here"
        putidx $idx "     Ban reason: .ripeconfig banreason Sorry %country%(%tld%) is not allowed in here"
        putidx $idx "     Enable msgcmds: .ripeconfig msgcmds on"
        putidx $idx "     Disable msgcmds: .ripeconfig msgcmds off"
        putidx $idx "    \002Substitutional keywords, current keywords are\002:"
        putidx $idx "     %tld% = Top level domain, ie .us, .se, .no"
        putidx $idx "     %country% = Country name"
        putidx $idx "     %nick% = Nickname of the user being banned"
        putidx $idx "    \002*NOTE*\002:"
        putidx $idx "      To completely remove an option from the configuration leave \[value\] blank, ie .ripeconfig msgcmds"
    }
    proc ripesettings { idx } {
        putidx $idx "### \002ripesettings\002"
        putidx $idx "    View current settings"
    }
    proc testripecheck { idx } {
        putidx $idx "### \002testripecheck <channel> <host>\002"
    }

    proc ripecheckdefault { idx } {
        putidx $idx "\n\nripecheck v$::ripecheck::version commands:"
        putidx $idx "   \002+ripetopresolv    -ripetopresolv    +ripetopdom    -ripetopdom\002"
        putidx $idx "   \002ripesettings      ripescan          ripeconfig     testripecheck\002"
    }

    proc help { hand idx arg } {
        set myarg [join $arg]
        # First we test if arg is all to print eggdrop builtin commands,
        # then we call the help proc for each script loaded
        if {$myarg == "all"} {
            *dcc:help $hand $idx [join $arg]
            foreach key [dict keys $::stderreu::helpfuncs] {
                ::stderreu::$key $idx
            }
            return 1
        } else {
            foreach key [dict keys $::stderreu::helpfuncs] {
                foreach helpf [dict get $::stderreu::helpfuncs $key] {
                    if { $helpf == $myarg } {
                        ::stderreu::$helpf $idx
                        return 1
                    }
                }
            }
        }

        *dcc:help $hand $idx $myarg

        if {[llength [split $arg]] == 0} {
            foreach key [dict keys $::stderreu::helpfuncs] {
                ::stderreu::${key}default $idx
            }
        }
        return 1
    }
}

putlog "\002Ripecheck v$::ripecheck::version\002 by Ratler loaded"
