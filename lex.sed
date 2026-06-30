:line
t clear
:clear
s/^[ \t]\+//
/^$/{
	d
}
s/^"\([^"]*\)"/\1\x01S/
t emit
s/^\[/[\x01B/
t emit
s/^\]/]\x01B/
t emit
s/^\(-\?[0-9]\+\)\([ \t]\|$\)/\1\x01N\2/
t emit
s/^\([^ \t]\+\)/\1\x01W/
t emit
b line
:emit
s/^\([^\x01]*\)\x01\([A-Z]\)\([ \t]*\)\(.*\)$/\2:\1\n\4/
P
D
