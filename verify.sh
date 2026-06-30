#!/bin/sh

flexnumber() {
	x=$(printf '123\n' | sed -nf lex.sed)
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
	x=$(printf -- '-5\n' | sed -nf lex.sed)
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
	x=$(printf '"hello world"\n' | sed -nf lex.sed)
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
	x=$(printf '""\n' | sed -nf lex.sed)
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
	x=$(printf 'dup\n' | sed -nf lex.sed)
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
	x=$(printf '[ ]\n' | sed -nf lex.sed)
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
	x=$(printf '"a" "b" dup\n' | sed -nf lex.sed)
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
	x=$(printf '1 2 add\n[ dup mul ]\n' | sed -nf lex.sed)
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

{ flexnumber && flexnegnumber && flexstring && flexemptystring && flexword && flexbrackets && flexmulti && flexprogram; r="${?}"; } || exit 1

[ "${r}" -eq 0 ] 2>/dev/null || printf "%s\n" "${r}"
