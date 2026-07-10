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

fopsubbasic() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '654|321' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='-333'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub basic";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub basic" "${x}" "${e}";
		return 19;
	}
}

fopsubnegative() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='333'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub negative";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub negative" "${x}" "${e}";
		return 20;
	}
}

fopsubborrow() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '300|1' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='-299'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub borrow";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub borrow" "${x}" "${e}";
		return 21;
	}
}

fopsubzero() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5|5' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub zero";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub zero" "${x}" "${e}";
		return 22;
	}
}

fopsubunequal() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1|12345' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='12344'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub unequal";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub unequal" "${x}" "${e}";
		return 23;
	}
}

fopsubboundary() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1000|999' | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='-1'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op sub boundary";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op sub boundary" "${x}" "${e}";
		return 24;
	}
}

funderflowdup() {
	{ printf 'b op_dup\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '\n' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow dup";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow dup" "${x}" "${r}";
		return 25;
	}
}

funderflowdrop() {
	{ printf 'b op_drop\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '\n' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow drop";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow drop" "${x}" "${r}";
		return 26;
	}
}

funderflowswap() {
	{ printf 'b op_swap\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow swap";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow swap" "${x}" "${r}";
		return 27;
	}
}

funderflowover() {
	{ printf 'b op_over\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow over";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow over" "${x}" "${r}";
		return 28;
	}
}

funderflowrot() {
	{ printf 'b op_rot\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5\0011' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow rot";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow rot" "${x}" "${r}";
		return 29;
	}
}

funderflowadds() {
	{ printf 'b op_add\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow add";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow add" "${x}" "${r}";
		return 30;
	}
}

funderflowsub() {
	{ printf 'b op_sub\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '5' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "underflow sub";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow sub" "${x}" "${r}";
		return 31;
	}
}

fopeq() {
	{ printf 'b op_eq\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|321' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op eq equal";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op eq equal" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 32;
	}
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op eq unequal";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op eq unequal" "${x}" "${e}";
		return 33;
	}
}

fopne() {
	{ printf 'b op_ne\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op ne unequal";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op ne unequal" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 34;
	}
	x=$(printf '321|321' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op ne equal";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op ne equal" "${x}" "${e}";
		return 35;
	}
}

foplt() {
	{ printf 'b op_lt\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '654|321' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op lt true";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op lt true" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 36;
	}
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op lt false";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op lt false" "${x}" "${e}";
		return 37;
	}
}

fople() {
	{ printf 'b op_le\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '654|321' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op le lt";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op le lt" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 38;
	}
	x=$(printf '321|321' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op le eq";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op le eq" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 39;
	}
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op le gt";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op le gt" "${x}" "${e}";
		return 40;
	}
}

fopgt() {
	{ printf 'b op_gt\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op gt true";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op gt true" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 41;
	}
	x=$(printf '654|321' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op gt false";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op gt false" "${x}" "${e}";
		return 42;
	}
}

fopge() {
	{ printf 'b op_ge\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '321|654' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op ge gt";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op ge gt" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 43;
	}
	x=$(printf '321|321' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op ge eq";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op ge eq" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 44;
	}
	x=$(printf '654|321' | sed -f /tmp/sedit_entry.$$)
	e='false'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "op ge lt";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "op ge lt" "${x}" "${e}";
		return 45;
	}
}

funderflowcmp() {
	for op in eq ne lt le gt ge; do
		{ printf "b op_${op}\n"; cat sedit.sed; } > /tmp/sedit_entry.$$
		x=$(printf '5' | sed -f /tmp/sedit_entry.$$)
		r=$?
		rm -f /tmp/sedit_entry.$$
		[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
			printf "%-15s PASSED\n" "underflow ${op}";
		} || {
			printf "%-15s FAILED\ngot '%s' exit %s\n" "underflow ${op}" "${x}" "${r}";
			return 46;
		}
	done
	return 0
}


fdispatchliteral() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '\nN:7\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch num";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch num" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 47;
	}
	x=$(printf '7\nS:hi\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'hi\0017')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch str";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch str" "${x}" "${e}";
		return 48;
	}
}

fdispatchstack() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '1\0012\nW:dup\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\0011\0012')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch dup";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch dup" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 49;
	}
	x=$(printf '1\0012\nW:swap\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '2\0011')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch swap";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch swap" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 50;
	}
	x=$(printf '1\0012\nW:drop\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '2')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch drop";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch drop" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 55;
	}
	x=$(printf '1\0012\0013\nW:over\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '2\0011\0012\0013')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch over";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch over" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 56;
	}
	x=$(printf '1\0012\0013\nW:rot\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '3\0011\0012')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch rot";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch rot" "${x}" "${e}";
		return 57;
	}
}

fdispatcharith() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '654\001321\nW:sub\n' | sed -f /tmp/sedit_entry.$$)
	e='-333'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch sub";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch sub" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 51;
	}
	x=$(printf '1\nW:add\n' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:UNDERFLOW" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "dispatch under";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "dispatch under" "${x}" "${r}";
		return 52;
	}
}

fdispatchaddtail() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '4\0015\001keep\nW:add\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '9\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch addtail";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch addtail" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 53;
	}
	x=$(printf '99\0011\001z\nW:add\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '100\001z')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch addcar";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch addcar" "${x}" "${e}";
		return 54;
	}
}

fdispatchboolerr() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '\nW:true\n' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch true";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch true" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 58;
	}
	x=$(printf 'x\nW:false\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'false\001x')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch false";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch false" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 59;
	}
	x=$(printf 'x\nW:nope\n' | sed -f /tmp/sedit_entry.$$)
	r=$?
	[ "${x}" = "ERR:UNKNOWN_WORD" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "dispatch unknown";
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "dispatch unknown" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 60;
	}
	x=$(printf 'x\nB:[\n' | sed -f /tmp/sedit_entry.$$)
	r=$?
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "ERR:BAD_TOKEN" ] && [ "${r}" -eq 1 ] && {
		printf "%-15s PASSED\n" "dispatch badtok";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' exit %s\n" "dispatch badtok" "${x}" "${r}";
		return 61;
	}
}

fdispatchsubtail() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '4\0015\001keep\nW:sub\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch subtai";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch subtai" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 62;
	}
	x=$(printf '5\0014\001keep\nW:sub\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf -- '-1\001keep')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "dispatch subneg";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch subneg" "${x}" "${e}";
		return 63;
	}
}

fdispatchcmptail() {
	{ printf 'N\nb op_dispatch\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	for row in 'eq 5 5 true' 'ne 5 4 true' 'lt 5 4 true' 'le 5 5 true' 'gt 4 5 true' 'ge 5 5 true'; do
		set -- ${row}
		op=${1}; a=${2}; b=${3}; want=${4}
		x=$(printf '%s\001%s\001keep\nW:%s\n' "${a}" "${b}" "${op}" | sed -f /tmp/sedit_entry.$$)
		e=$(printf '%s\001keep' "${want}")
		[ "${x}" = "${e}" ] && {
			printf "%-15s PASSED\n" "dispatch ${op}tail";
		} || {
			printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "dispatch ${op}tail" "${x}" "${e}";
			rm -f /tmp/sedit_entry.$$; return 64;
		}
	done
	rm -f /tmp/sedit_entry.$$
	return 0
}

fevaltokens() {
	{ printf 'b op_eval\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf 'N:4\nN:5\nW:add\n' | sed -f /tmp/sedit_entry.$$)
	e='9'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval add";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval add" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 65;
	}
	x=$(printf 'N:4\nN:5\nW:add\nN:2\nW:sub\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval chain";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval chain" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 66;
	}
	x=$(printf 'S:keep\nN:4\nN:5\nW:add\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '9\001keep')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval tail";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval tail" "${x}" "${e}";
		return 67;
	}
}

fevallexed() {
	{ printf 'b op_eval\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '4 5 add 2 sub\n' | sed -nf sedit.sed | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval lexed";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval lexed" "${x}" "${e}";
		return 68;
	}
}


fevalmore() {
	{ printf 'b op_eval\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf 'N:1\nN:2\nW:swap\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\0012')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval swap";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval swap" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 69;
	}
	x=$(printf 'N:1\nN:2\nW:over\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\0012\0011')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval over";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval over" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 70;
	}
	x=$(printf 'N:1\nN:2\nN:3\nW:rot\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\0013\0012')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval rot";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval rot" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 71;
	}
	x=$(printf 'N:4\nN:5\nW:lt\n' | sed -f /tmp/sedit_entry.$$)
	e='true'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval lt";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval lt" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 72;
	}
	x=$(printf 'S:keep\nN:5\nN:5\nW:eq\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'true\001keep')
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval eqtail";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval eqtail" "${x}" "${e}";
		return 73;
	}
}

fevalerrors() {
	{ printf 'b op_eval\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf 'N:1\nW:add\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNDERFLOW' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "eval under";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNDERFLOW' nonzero\n" "eval under" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 74;
	}
	x=$(printf 'N:1\nW:nope\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNKNOWN_WORD' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "eval unknown";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNKNOWN_WORD' nonzero\n" "eval unknown" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 75;
	}
	x=$(printf 'N:1\nBAD\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = 'ERR:BAD_TOKEN' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "eval badtok";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:BAD_TOKEN' nonzero\n" "eval badtok" "${x}" "${r}";
		return 76;
	}
}

fevallexedmulti() {
	{ printf 'b op_eval\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '4 5\nadd 2 sub\n' | sed -nf sedit.sed | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval lexmulti";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval lexmulti" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 77;
	}
	x=$(printf '"keep"\n4 5 add\n' | sed -nf sedit.sed | sed -f /tmp/sedit_entry.$$)
	rm -f /tmp/sedit_entry.$$
	e=$(printf '9\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "eval lexstack";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "eval lexstack" "${x}" "${e}";
		return 78;
	}
}


frunsource() {
	{ printf 'b op_run\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '4 5 add 2 sub\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run source";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run source" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 79;
	}
	x=$(printf '"keep"\n4 5 add\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '9\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run stack";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run stack" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 80;
	}
	x=$(printf '4 5\nadd 2 sub\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run multi";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run multi" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 81;
	}
	x=$(printf '4 add\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNDERFLOW' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run under";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNDERFLOW' nonzero\n" "run under" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 82;
	}
	x=$(printf '4 nope\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = 'ERR:UNKNOWN_WORD' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run unknown";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNKNOWN_WORD' nonzero\n" "run unknown" "${x}" "${r}";
		return 83;
	}
}


fquote() {
	{ printf 'b op_run\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '[ 1 2 add ]\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'Q:N:1\005N:2\005W:add')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quote";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quote" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 84;
	}
	x=$(printf '"keep" [ 4 5 add ]\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'Q:N:4\005N:5\005W:add\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quotetail";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quotetail" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 85;
	}
	x=$(printf '[ 4 5 add ] 2\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '2\001Q:N:4\005N:5\005W:add')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quotenoexec";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quotenoexec" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 86;
	}
	x=$(printf '[ ]\n' | sed -f /tmp/sedit_entry.$$)
	e='Q:'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quoteempty";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quoteempty" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 87;
	}
	x=$(printf '[ 1 [ 2 ] 3 ]\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'Q:N:1\005B:[\005N:2\005B:]\005N:3')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quotenest";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quotenest" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 88;
	}
	x=$(printf '[ [ ] ]\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'Q:B:[\005B:]')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run quotedeep";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run quotedeep" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 89;
	}
	x=$(printf '[ 1 [ 2 ]\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNTERMINATED_QUOTE' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run qnesterr";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNTERMINATED_QUOTE' nonzero\n" "run qnesterr" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 90;
	}
	x=$(printf '[ 1 2\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = 'ERR:UNTERMINATED_QUOTE' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run quoteerr";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNTERMINATED_QUOTE' nonzero\n" "run quoteerr" "${x}" "${r}";
		return 91;
	}
}


fcall() {
	{ printf 'b op_run\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '[ 1 2 add ] call\n' | sed -f /tmp/sedit_entry.$$)
	e='3'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run call";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run call" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 92;
	}
	x=$(printf '"keep" [ 4 5 add ] call\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '9\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run calltail";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run calltail" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 93;
	}
	x=$(printf '[ 1 2 add ] call 3 add\n' | sed -f /tmp/sedit_entry.$$)
	e='6'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run callcont";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run callcont" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 94;
	}
	x=$(printf '[ ] call 7\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run callempty";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run callempty" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 95;
	}
	x=$(printf 'call\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNDERFLOW' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run callunder";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNDERFLOW' nonzero\n" "run callunder" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 96;
	}
	x=$(printf '[ [ 1 2 add ] ] call\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf 'Q:N:1\005N:2\005W:add')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run callquote";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run callquote" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 97;
	}
	x=$(printf '[ [ 1 2 add ] call ] call\n' | sed -f /tmp/sedit_entry.$$)
	e='3'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run callnest";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run callnest" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 98;
	}
	x=$(printf '1 call\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = 'ERR:CALL_NON_QUOTE' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run callbad";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:CALL_NON_QUOTE' nonzero\n" "run callbad" "${x}" "${r}";
		return 99;
	}
}


fif() {
	{ printf 'b op_run\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf 'true [ 1 ] [ 2 ] if\n' | sed -f /tmp/sedit_entry.$$)
	e='1'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run iftrue";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run iftrue" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 100;
	}
	x=$(printf 'false [ 1 ] [ 2 ] if\n' | sed -f /tmp/sedit_entry.$$)
	e='2'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run iffalse";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run iffalse" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 101;
	}
	x=$(printf '"keep" true [ 1 ] [ 2 ] if\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '1\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run iftail";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run iftail" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 102;
	}
	x=$(printf 'true [ 1 2 add ] [ 9 ] if 3 add\n' | sed -f /tmp/sedit_entry.$$)
	e='6'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run ifcont";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run ifcont" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 103;
	}
	x=$(printf 'false [ 1 ] [ 2 3 add ] if\n' | sed -f /tmp/sedit_entry.$$)
	e='5'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run ifelsecall";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run ifelsecall" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 104;
	}
	x=$(printf 'if\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNDERFLOW' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run ifunder";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNDERFLOW' nonzero\n" "run ifunder" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 105;
	}
	x=$(printf '"maybe" [ 1 ] [ 2 ] if\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:IF_NON_BOOL' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run ifbool";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:IF_NON_BOOL' nonzero\n" "run ifbool" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 106;
	}
	x=$(printf 'true [ 1 ] 2 if\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = 'ERR:IF_NON_QUOTE' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run ifquote";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:IF_NON_QUOTE' nonzero\n" "run ifquote" "${x}" "${r}";
		return 107;
	}
}



fwhile() {
	{ printf 'b op_run\n'; cat sedit.sed; } > /tmp/sedit_entry.$$
	x=$(printf '0 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f /tmp/sedit_entry.$$)
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whilefalse";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whilefalse" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 108;
	}
	x=$(printf '3 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f /tmp/sedit_entry.$$)
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whilecount";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whilecount" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 109;
	}
	x=$(printf '"keep" 3 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '0\001keep')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whiletail";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whiletail" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 110;
	}
	x=$(printf '3 [ dup 0 gt ] [ 1 sub ] while 7 add\n' | sed -f /tmp/sedit_entry.$$)
	e='7'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whilecont";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whilecont" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 111;
	}
	x=$(printf '3 [ [ dup 0 gt ] call ] [ [ 1 sub ] call ] while\n' | sed -f /tmp/sedit_entry.$$)
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whilecall";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whilecall" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 112;
	}
	x=$(printf '3 [ dup 0 gt ] [ true [ 1 sub ] [ 9 ] if ] while\n' | sed -f /tmp/sedit_entry.$$)
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whileif";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whileif" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 113;
	}
	x=$(printf '2 [ dup 0 gt ] [ 1 sub 2 [ dup 0 gt ] [ 1 sub ] while drop ] while\n' | sed -f /tmp/sedit_entry.$$)
	e='0'
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whilenest";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whilenest" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 114;
	}
	x=$(printf '0 [ dup 0 gt ] [ ] while 7\n' | sed -f /tmp/sedit_entry.$$)
	e=$(printf '7\0010')
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run whileempty";
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run whileempty" "${x}" "${e}";
		rm -f /tmp/sedit_entry.$$; return 115;
	}
	x=$(printf 'while\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:UNDERFLOW' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run whileunder";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:UNDERFLOW' nonzero\n" "run whileunder" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 116;
	}
	x=$(printf '1 2 while\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:WHILE_NON_QUOTE' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run whilequote";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:WHILE_NON_QUOTE' nonzero\n" "run whilequote" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 117;
	}
	x=$(printf '[ 1 ] [ ] while\n' | sed -f /tmp/sedit_entry.$$ 2>/dev/null); r=${?}
	[ "${x}" = 'ERR:WHILE_NON_BOOL' ] && [ "${r}" -ne 0 ] && {
		printf "%-15s PASSED\n" "run whilebool";
	} || {
		printf "%-15s FAILED\ngot '%s' status '%s'\nexpected 'ERR:WHILE_NON_BOOL' nonzero\n" "run whilebool" "${x}" "${r}";
		rm -f /tmp/sedit_entry.$$; return 118;
	}
	x=$(printf '3 4 0 [ over 0 gt ] [ rot dup rot add rot 1 sub swap ] while swap drop swap drop\n' | sed -f /tmp/sedit_entry.$$)
	e='12'
	rm -f /tmp/sedit_entry.$$
	[ "${x}" = "${e}" ] && {
		printf "%-15s PASSED\n" "run selfmul";
		return 0;
	} || {
		printf "%-15s FAILED\ngot '%s'\nexpected '%s'\n" "run selfmul" "${x}" "${e}";
		return 119;
	}
}

{ flexnumber && flexnegnumber && flexstring && flexemptystring && flexword && flexbrackets && flexmulti && flexprogram && fopdup && fopdrop && fopswap && fopover && foprot && fopaddbasic && fopaddcarry && fopaddoverflow && fopaddzero && fopaddunequal && fopsubbasic && fopsubnegative && fopsubborrow && fopsubzero && fopsubunequal && fopsubboundary && funderflowdup && funderflowdrop && funderflowswap && funderflowover && funderflowrot && funderflowadds && funderflowsub && fopeq && fopne && foplt && fople && fopgt && fopge && funderflowcmp && fdispatchliteral && fdispatchstack && fdispatcharith && fdispatchaddtail && fdispatchboolerr && fdispatchsubtail && fdispatchcmptail && fevaltokens && fevallexed && fevalmore && fevalerrors && fevallexedmulti && frunsource && fquote && fcall && fif && fwhile; r="${?}"; } || exit 1

[ "${r}" -eq 0 ] 2>/dev/null || printf "%s\n" "${r}"
