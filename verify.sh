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

{ flexnumber && flexnegnumber && flexstring && flexemptystring && flexword && flexbrackets && flexmulti && flexprogram && fopdup && fopdrop && fopswap && fopover && foprot && fopaddbasic && fopaddcarry && fopaddoverflow && fopaddzero && fopaddunequal && fopsubbasic && fopsubnegative && fopsubborrow && fopsubzero && fopsubunequal && fopsubboundary && funderflowdup && funderflowdrop && funderflowswap && funderflowover && funderflowrot && funderflowadds && funderflowsub && fopeq && fopne && foplt && fople && fopgt && fopge && funderflowcmp; r="${?}"; } || exit 1

[ "${r}" -eq 0 ] 2>/dev/null || printf "%s\n" "${r}"
