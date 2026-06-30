#!/bin/sh
#License GPL3 Copyright (C) 2026 Ivan Gaydardzhiev

flexnumber() {
	x=$(printf '123\n' | sed -nf sedit.sed)
	e='N:123'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex number";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex number" "${x}" "${e}";
		return 1;
	}
}

flexnegnumber() {
	x=$(printf -- '-5\n' | sed -nf sedit.sed)
	e='N:-5'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex negnumber";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex negnumber" "${x}" "${e}";
		return 2;
	}
}

flexstring() {
	x=$(printf '"hello world"\n' | sed -nf sedit.sed)
	e='S:hello world'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex string";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex string" "${x}" "${e}";
		return 3;
	}
}

flexemptystring() {
	x=$(printf '""\n' | sed -nf sedit.sed)
	e='S:'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex emptystring";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex emptystring" "${x}" "${e}";
		return 4;
	}
}

flexword() {
	x=$(printf 'dup\n' | sed -nf sedit.sed)
	e='W:dup'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex word";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex word" "${x}" "${e}";
		return 5;
	}
}

flexbrackets() {
	x=$(printf '[ ]\n' | sed -nf sedit.sed)
	e='B:[
B:]'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex brackets";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex brackets" "${x}" "${e}";
		return 6;
	}
}

flexmulti() {
	x=$(printf '"a" "b" dup\n' | sed -nf sedit.sed)
	e='S:a
S:b
W:dup'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex multi";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex multi" "${x}" "${e}";
		return 7;
	}
}

flexprogram() {
	x=$(printf '1 2 add\n[ dup mul ]\n' | sed -nf sedit.sed)
	e='N:1
N:2
W:add
B:[
W:dup
W:mul
B:]'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "lex program";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "lex program" "${x}" "${e}";
		return 8;
	}
}

fopdup() {
	{ printf 'b op_dup\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\0013' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '1\0011\0012\0013')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op dup";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op dup" "${x}" "${e}";
		return 9;
	}
}

fopdrop() {
	{ printf 'b op_drop\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\0013' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '2\0013')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op drop";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op drop" "${x}" "${e}";
		return 10;
	}
}

fopswap() {
	{ printf 'b op_swap\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\0013' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '2\0011\0013')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op swap";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op swap" "${x}" "${e}";
		return 11;
	}
}

fopover() {
	{ printf 'b op_over\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\0013' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '2\0011\0012\0013')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op over";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op over" "${x}" "${e}";
		return 12;
	}
}

foprot() {
	{ printf 'b op_rot\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\0013\0014' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '3\0011\0012\0014')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op rot";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op rot" "${x}" "${e}";
		return 13;
	}
}

fopaddbasic() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='975'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op add basic";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op add basic" "${x}" "${e}";
		return 14;
	}
}

fopaddcarry() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '299|1' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='300'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op add carry";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op add carry" "${x}" "${e}";
		return 15;
	}
}

fopaddoverflow() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '999|1' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='1000'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op add overflow";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op add overflow" "${x}" "${e}";
		return 16;
	}
}

fopaddzero() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '0|0' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op add zero";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op add zero" "${x}" "${e}";
		return 17;
	}
}

fopaddunequal() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1|12345' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='12346'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op add unequal";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op add unequal" "${x}" "${e}";
		return 18;
	}
}

{ flexnumber && flexnegnumber && flexstring && flexemptystring && flexword && flexbrackets && flexmulti && flexprogram && fopdup && fopdrop && fopswap && fopover && foprot && fopaddbasic && fopaddcarry && fopaddoverflow && fopaddzero && fopaddunequal; r="${?}"; } || exit 1

[ "${r}" -eq 0 ] 2>/dev/null || printf "%s\n" "${r}"
