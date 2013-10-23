bind pub - ".adv" time_adv

bind time - "?0 * * * *" time_adv

proc time_adv {min hour day month year} {
	putserv "PRIVMSG #shells \0031,15 • \002Shell Solutions\002 • High Performance Internet Solutions • \002http://www.shellsolutions.net\002 • Fast Customer Support ~ Instant Setup •"
}