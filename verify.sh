#!/bin/sh
#License GPL3 Copyright (C) 2026 Ivan Gaydardzhiev

_t=0
_ent=/tmp/sedit_entry.$$

chk() {
	_t=$((_t+1))
	[ "${2}" = "${3}" ] && {
		printf "%-15s PASSED\n" "${1}"
		return 0
	} || {
		printf "%-15s FAILED [test %d]\ngot '%s'\nexpected '%s'\n" "${1}" "${_t}" "${2}" "${3}"
		return 1
	}
}

chke() {
	_t=$((_t+1))
	[ "${2}" = "${4}" ] && [ "${3}" -ne 0 ] && {
		printf "%-15s PASSED\n" "${1}"
		return 0
	} || {
		printf "%-15s FAILED [test %d]\ngot '%s' status '%s'\nexpected '%s' nonzero\n" "${1}" "${_t}" "${2}" "${3}" "${4}"
		return 1
	}
}

mkent() {
	{ printf '%s\n' "${1}"; cat sedit.sed; } > "${_ent}"
}

rment() {
	rm -f "${_ent}"
}

flexnumber() {
	chk "lex number" "$(printf '123\n' | sed -nf sedit.sed)" 'N:123'
}

flexnegnumber() {
	chk "lex negnumber" "$(printf -- '-5\n' | sed -nf sedit.sed)" 'N:-5'
}

flexstring() {
	chk "lex string" "$(printf '"hello world"\n' | sed -nf sedit.sed)" 'S:hello world'
}

flexemptystring() {
	chk "lex emptystring" "$(printf '""\n' | sed -nf sedit.sed)" 'S:'
}

flexword() {
	chk "lex word" "$(printf 'dup\n' | sed -nf sedit.sed)" 'W:dup'
}

flexbrackets() {
	chk "lex brackets" "$(printf '[ ]\n' | sed -nf sedit.sed)" "$(printf 'B:[\nB:]')"
}

flexmulti() {
	chk "lex multi" "$(printf '"a" "b" dup\n' | sed -nf sedit.sed)" "$(printf 'S:a\nS:b\nW:dup')"
}

flexprogram() {
	chk "lex program" "$(printf '1 2 add\n[ dup mul ]\n' | sed -nf sedit.sed)" "$(printf 'N:1\nN:2\nW:add\nB:[\nW:dup\nW:mul\nB:]')"
}

fopdup() {
	mkent 'b op_dup'
	x=$(printf '1\0012\0013' | sed -f "${_ent}"); rment
	chk "op dup" "${x}" "$(printf '1\0011\0012\0013')"
}

fopdrop() {
	mkent 'b op_drop'
	x=$(printf '1\0012\0013' | sed -f "${_ent}"); rment
	chk "op drop" "${x}" "$(printf '2\0013')"
}

fopswap() {
	mkent 'b op_swap'
	x=$(printf '1\0012\0013' | sed -f "${_ent}"); rment
	chk "op swap" "${x}" "$(printf '2\0011\0013')"
}

fopover() {
	mkent 'b op_over'
	x=$(printf '1\0012\0013' | sed -f "${_ent}"); rment
	chk "op over" "${x}" "$(printf '2\0011\0012\0013')"
}

foprot() {
	mkent 'b op_rot'
	x=$(printf '1\0012\0013\0014' | sed -f "${_ent}"); rment
	chk "op rot" "${x}" "$(printf '3\0011\0012\0014')"
}

fopaddbasic() {
	mkent 'b op_add'
	x=$(printf '321|654' | sed -f "${_ent}"); rment
	chk "op add basic" "${x}" '975'
}

fopaddcarry() {
	mkent 'b op_add'
	x=$(printf '299|1' | sed -f "${_ent}"); rment
	chk "op add carry" "${x}" '300'
}

fopaddoverflow() {
	mkent 'b op_add'
	x=$(printf '999|1' | sed -f "${_ent}"); rment
	chk "op add overflow" "${x}" '1000'
}

fopaddzero() {
	mkent 'b op_add'
	x=$(printf '0|0' | sed -f "${_ent}"); rment
	chk "op add zero" "${x}" '0'
}

fopaddunequal() {
	mkent 'b op_add'
	x=$(printf '1|12345' | sed -f "${_ent}"); rment
	chk "op add unequal" "${x}" '12346'
}

fopsubbasic() {
	mkent 'b op_sub'
	x=$(printf '654|321' | sed -f "${_ent}"); rment
	chk "op sub basic" "${x}" '-333'
}

fopsubnegative() {
	mkent 'b op_sub'
	x=$(printf '321|654' | sed -f "${_ent}"); rment
	chk "op sub negative" "${x}" '333'
}

fopsubborrow() {
	mkent 'b op_sub'
	x=$(printf '300|1' | sed -f "${_ent}"); rment
	chk "op sub borrow" "${x}" '-299'
}

fopsubzero() {
	mkent 'b op_sub'
	x=$(printf '5|5' | sed -f "${_ent}"); rment
	chk "op sub zero" "${x}" '0'
}

fopsubunequal() {
	mkent 'b op_sub'
	x=$(printf '1|12345' | sed -f "${_ent}"); rment
	chk "op sub unequal" "${x}" '12344'
}

fopsubboundary() {
	mkent 'b op_sub'
	x=$(printf '1000|999' | sed -f "${_ent}"); rment
	chk "op sub boundary" "${x}" '-1'
}

funderflowdup() {
	mkent 'b op_dup'
	x=$(printf '\n' | sed -f "${_ent}"); r=$?; rment
	chke "underflow dup" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowdrop() {
	mkent 'b op_drop'
	x=$(printf '\n' | sed -f "${_ent}"); r=$?; rment
	chke "underflow drop" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowswap() {
	mkent 'b op_swap'
	x=$(printf '5' | sed -f "${_ent}"); r=$?; rment
	chke "underflow swap" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowover() {
	mkent 'b op_over'
	x=$(printf '5' | sed -f "${_ent}"); r=$?; rment
	chke "underflow over" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowrot() {
	mkent 'b op_rot'
	x=$(printf '5\0011' | sed -f "${_ent}"); r=$?; rment
	chke "underflow rot" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowadds() {
	mkent 'b op_add'
	x=$(printf '5' | sed -f "${_ent}"); r=$?; rment
	chke "underflow add" "${x}" "${r}" 'ERR:UNDERFLOW'
}

funderflowsub() {
	mkent 'b op_sub'
	x=$(printf '5' | sed -f "${_ent}"); r=$?; rment
	chke "underflow sub" "${x}" "${r}" 'ERR:UNDERFLOW'
}

fopeq() {
	mkent 'b op_eq'
	chk "op eq equal" "$(printf '321|321' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '321|654' | sed -f "${_ent}"); rment
	chk "op eq unequal" "${x}" 'false'
}

fopne() {
	mkent 'b op_ne'
	chk "op ne unequal" "$(printf '321|654' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '321|321' | sed -f "${_ent}"); rment
	chk "op ne equal" "${x}" 'false'
}

foplt() {
	mkent 'b op_lt'
	chk "op lt true" "$(printf '654|321' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '321|654' | sed -f "${_ent}"); rment
	chk "op lt false" "${x}" 'false'
}

fople() {
	mkent 'b op_le'
	chk "op le lt" "$(printf '654|321' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	chk "op le eq" "$(printf '321|321' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '321|654' | sed -f "${_ent}"); rment
	chk "op le gt" "${x}" 'false'
}

fopgt() {
	mkent 'b op_gt'
	chk "op gt true" "$(printf '321|654' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '654|321' | sed -f "${_ent}"); rment
	chk "op gt false" "${x}" 'false'
}

fopge() {
	mkent 'b op_ge'
	chk "op ge gt" "$(printf '321|654' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	chk "op ge eq" "$(printf '321|321' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf '654|321' | sed -f "${_ent}"); rment
	chk "op ge lt" "${x}" 'false'
}

funderflowcmp() {
	for op in eq ne lt le gt ge; do
		{ printf "b op_${op}\n"; cat sedit.sed; } > "${_ent}"
		x=$(printf '5' | sed -f "${_ent}"); r=$?; rment
		chke "underflow ${op}" "${x}" "${r}" 'ERR:UNDERFLOW' || return 1
	done
}

fdispatchliteral() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch num" "$(printf '\nN:7\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	x=$(printf '7\nS:hi\n' | sed -f "${_ent}"); rment
	chk "dispatch str" "${x}" "$(printf 'hi\0017')"
}

fdispatchstack() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch dup" "$(printf '1\0012\nW:dup\n' | sed -f "${_ent}")" "$(printf '1\0011\0012')" || { rment; return 1; }
	chk "dispatch swap" "$(printf '1\0012\nW:swap\n' | sed -f "${_ent}")" "$(printf '2\0011')" || { rment; return 1; }
	chk "dispatch drop" "$(printf '1\0012\nW:drop\n' | sed -f "${_ent}")" "$(printf '2')" || { rment; return 1; }
	chk "dispatch over" "$(printf '1\0012\0013\nW:over\n' | sed -f "${_ent}")" "$(printf '2\0011\0012\0013')" || { rment; return 1; }
	x=$(printf '1\0012\0013\nW:rot\n' | sed -f "${_ent}"); rment
	chk "dispatch rot" "${x}" "$(printf '3\0011\0012')"
}

fdispatcharith() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch sub" "$(printf '654\001321\nW:sub\n' | sed -f "${_ent}")" '-333' || { rment; return 1; }
	x=$(printf '1\nW:add\n' | sed -f "${_ent}"); r=$?; rment
	chke "dispatch under" "${x}" "${r}" 'ERR:UNDERFLOW'
}

fdispatchaddtail() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch addtail" "$(printf '4\0015\001keep\nW:add\n' | sed -f "${_ent}")" "$(printf '9\001keep')" || { rment; return 1; }
	x=$(printf '99\0011\001z\nW:add\n' | sed -f "${_ent}"); rment
	chk "dispatch addcar" "${x}" "$(printf '100\001z')"
}

fdispatchboolerr() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch true" "$(printf '\nW:true\n' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	chk "dispatch false" "$(printf 'x\nW:false\n' | sed -f "${_ent}")" "$(printf 'false\001x')" || { rment; return 1; }
	x=$(printf 'x\nW:nope\n' | sed -f "${_ent}"); r=$?
	chke "dispatch unknown" "${x}" "${r}" 'ERR:UNKNOWN_WORD' || { rment; return 1; }
	x=$(printf 'x\nB:[\n' | sed -f "${_ent}"); r=$?; rment
	chke "dispatch badtok" "${x}" "${r}" 'ERR:BAD_TOKEN'
}

fdispatchsubtail() {
	mkent "$(printf 'N\nb op_dispatch')"
	chk "dispatch subtai" "$(printf '4\0015\001keep\nW:sub\n' | sed -f "${_ent}")" "$(printf '1\001keep')" || { rment; return 1; }
	x=$(printf '5\0014\001keep\nW:sub\n' | sed -f "${_ent}"); rment
	chk "dispatch subneg" "${x}" "$(printf -- '-1\001keep')"
}

fdispatchcmptail() {
	mkent "$(printf 'N\nb op_dispatch')"
	for row in 'eq 5 5 true' 'ne 5 4 true' 'lt 5 4 true' 'le 5 5 true' 'gt 4 5 true' 'ge 5 5 true'; do
		set -- ${row}
		op=${1}; a=${2}; b=${3}; want=${4}
		x=$(printf '%s\001%s\001keep\nW:%s\n' "${a}" "${b}" "${op}" | sed -f "${_ent}")
		chk "dispatch ${op}tail" "${x}" "$(printf '%s\001keep' "${want}")" || { rment; return 1; }
	done
	rment
}

fevaltokens() {
	mkent 'b op_eval'
	chk "eval add" "$(printf 'N:4\nN:5\nW:add\n' | sed -f "${_ent}")" '9' || { rment; return 1; }
	chk "eval chain" "$(printf 'N:4\nN:5\nW:add\nN:2\nW:sub\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	x=$(printf 'S:keep\nN:4\nN:5\nW:add\n' | sed -f "${_ent}"); rment
	chk "eval tail" "${x}" "$(printf '9\001keep')"
}

fevallexed() {
	mkent 'b op_eval'
	x=$(printf '4 5 add 2 sub\n' | sed -nf sedit.sed | sed -f "${_ent}"); rment
	chk "eval lexed" "${x}" '7'
}

fevalmore() {
	mkent 'b op_eval'
	chk "eval swap" "$(printf 'N:1\nN:2\nW:swap\n' | sed -f "${_ent}")" "$(printf '1\0012')" || { rment; return 1; }
	chk "eval over" "$(printf 'N:1\nN:2\nW:over\n' | sed -f "${_ent}")" "$(printf '1\0012\0011')" || { rment; return 1; }
	chk "eval rot" "$(printf 'N:1\nN:2\nN:3\nW:rot\n' | sed -f "${_ent}")" "$(printf '1\0013\0012')" || { rment; return 1; }
	chk "eval lt" "$(printf 'N:4\nN:5\nW:lt\n' | sed -f "${_ent}")" 'true' || { rment; return 1; }
	x=$(printf 'S:keep\nN:5\nN:5\nW:eq\n' | sed -f "${_ent}"); rment
	chk "eval eqtail" "${x}" "$(printf 'true\001keep')"
}

fevalerrors() {
	mkent 'b op_eval'
	x=$(printf 'N:1\nW:add\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "eval under" "${x}" "${r}" 'ERR:UNDERFLOW' || { rment; return 1; }
	x=$(printf 'N:1\nW:nope\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "eval unknown" "${x}" "${r}" 'ERR:UNKNOWN_WORD' || { rment; return 1; }
	x=$(printf 'N:1\nBAD\n' | sed -f "${_ent}" 2>/dev/null); r=$?; rment
	chke "eval badtok" "${x}" "${r}" 'ERR:BAD_TOKEN'
}

fevallexedmulti() {
	mkent 'b op_eval'
	chk "eval lexmulti" "$(printf '4 5\nadd 2 sub\n' | sed -nf sedit.sed | sed -f "${_ent}")" '7' || { rment; return 1; }
	x=$(printf '"keep"\n4 5 add\n' | sed -nf sedit.sed | sed -f "${_ent}"); rment
	chk "eval lexstack" "${x}" "$(printf '9\001keep')"
}

frunsource() {
	mkent 'b op_run'
	chk "run source" "$(printf '4 5 add 2 sub\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	chk "run stack" "$(printf '"keep"\n4 5 add\n' | sed -f "${_ent}")" "$(printf '9\001keep')" || { rment; return 1; }
	chk "run multi" "$(printf '4 5\nadd 2 sub\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	x=$(printf '4 add\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run under" "${x}" "${r}" 'ERR:UNDERFLOW' || { rment; return 1; }
	x=$(printf '4 nope\n' | sed -f "${_ent}" 2>/dev/null); r=$?; rment
	chke "run unknown" "${x}" "${r}" 'ERR:UNKNOWN_WORD'
}

fquote() {
	mkent 'b op_run'
	chk "run quote" "$(printf '[ 1 2 add ]\n' | sed -f "${_ent}")" "$(printf 'Q:N:1\005N:2\005W:add')" || { rment; return 1; }
	chk "run quotetail" "$(printf '"keep" [ 4 5 add ]\n' | sed -f "${_ent}")" "$(printf 'Q:N:4\005N:5\005W:add\001keep')" || { rment; return 1; }
	chk "run quotenoexec" "$(printf '[ 4 5 add ] 2\n' | sed -f "${_ent}")" "$(printf '2\001Q:N:4\005N:5\005W:add')" || { rment; return 1; }
	chk "run quoteempty" "$(printf '[ ]\n' | sed -f "${_ent}")" 'Q:' || { rment; return 1; }
	chk "run quotenest" "$(printf '[ 1 [ 2 ] 3 ]\n' | sed -f "${_ent}")" "$(printf 'Q:N:1\005B:[\005N:2\005B:]\005N:3')" || { rment; return 1; }
	chk "run quotedeep" "$(printf '[ [ ] ]\n' | sed -f "${_ent}")" "$(printf 'Q:B:[\005B:]')" || { rment; return 1; }
	x=$(printf '[ 1 [ 2 ]\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run qnesterr" "${x}" "${r}" 'ERR:UNTERMINATED_QUOTE' || { rment; return 1; }
	x=$(printf '[ 1 2\n' | sed -f "${_ent}" 2>/dev/null); r=$?; rment
	chke "run quoteerr" "${x}" "${r}" 'ERR:UNTERMINATED_QUOTE'
}

fcall() {
	mkent 'b op_run'
	chk "run call" "$(printf '[ 1 2 add ] call\n' | sed -f "${_ent}")" '3' || { rment; return 1; }
	chk "run calltail" "$(printf '"keep" [ 4 5 add ] call\n' | sed -f "${_ent}")" "$(printf '9\001keep')" || { rment; return 1; }
	chk "run callcont" "$(printf '[ 1 2 add ] call 3 add\n' | sed -f "${_ent}")" '6' || { rment; return 1; }
	chk "run callempty" "$(printf '[ ] call 7\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	x=$(printf 'call\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run callunder" "${x}" "${r}" 'ERR:UNDERFLOW' || { rment; return 1; }
	chk "run callquote" "$(printf '[ [ 1 2 add ] ] call\n' | sed -f "${_ent}")" "$(printf 'Q:N:1\005N:2\005W:add')" || { rment; return 1; }
	chk "run callnest" "$(printf '[ [ 1 2 add ] call ] call\n' | sed -f "${_ent}")" '3' || { rment; return 1; }
	x=$(printf '1 call\n' | sed -f "${_ent}" 2>/dev/null); r=$?; rment
	chke "run callbad" "${x}" "${r}" 'ERR:CALL_NON_QUOTE'
}

fif() {
	mkent 'b op_run'
	chk "run iftrue" "$(printf 'true [ 1 ] [ 2 ] if\n' | sed -f "${_ent}")" '1' || { rment; return 1; }
	chk "run iffalse" "$(printf 'false [ 1 ] [ 2 ] if\n' | sed -f "${_ent}")" '2' || { rment; return 1; }
	chk "run iftail" "$(printf '"keep" true [ 1 ] [ 2 ] if\n' | sed -f "${_ent}")" "$(printf '1\001keep')" || { rment; return 1; }
	chk "run ifcont" "$(printf 'true [ 1 2 add ] [ 9 ] if 3 add\n' | sed -f "${_ent}")" '6' || { rment; return 1; }
	chk "run ifelsecall" "$(printf 'false [ 1 ] [ 2 3 add ] if\n' | sed -f "${_ent}")" '5' || { rment; return 1; }
	x=$(printf 'if\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run ifunder" "${x}" "${r}" 'ERR:UNDERFLOW' || { rment; return 1; }
	x=$(printf '"maybe" [ 1 ] [ 2 ] if\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run ifbool" "${x}" "${r}" 'ERR:IF_NON_BOOL' || { rment; return 1; }
	x=$(printf 'true [ 1 ] 2 if\n' | sed -f "${_ent}" 2>/dev/null); r=$?; rment
	chke "run ifquote" "${x}" "${r}" 'ERR:IF_NON_QUOTE'
}

fwhile() {
	mkent 'b op_run'
	chk "run whilefalse" "$(printf '0 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f "${_ent}")" '0' || { rment; return 1; }
	chk "run whilecount" "$(printf '3 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f "${_ent}")" '0' || { rment; return 1; }
	chk "run whiletail" "$(printf '"keep" 3 [ dup 0 gt ] [ 1 sub ] while\n' | sed -f "${_ent}")" "$(printf '0\001keep')" || { rment; return 1; }
	chk "run whilecont" "$(printf '3 [ dup 0 gt ] [ 1 sub ] while 7 add\n' | sed -f "${_ent}")" '7' || { rment; return 1; }
	chk "run whilecall" "$(printf '3 [ [ dup 0 gt ] call ] [ [ 1 sub ] call ] while\n' | sed -f "${_ent}")" '0' || { rment; return 1; }
	chk "run whileif" "$(printf '3 [ dup 0 gt ] [ true [ 1 sub ] [ 9 ] if ] while\n' | sed -f "${_ent}")" '0' || { rment; return 1; }
	chk "run whilenest" "$(printf '2 [ dup 0 gt ] [ 1 sub 2 [ dup 0 gt ] [ 1 sub ] while drop ] while\n' | sed -f "${_ent}")" '0' || { rment; return 1; }
	chk "run whileempty" "$(printf '0 [ dup 0 gt ] [ ] while 7\n' | sed -f "${_ent}")" "$(printf '7\0010')" || { rment; return 1; }
	x=$(printf 'while\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run whileunder" "${x}" "${r}" 'ERR:UNDERFLOW' || { rment; return 1; }
	x=$(printf '1 2 while\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run whilequote" "${x}" "${r}" 'ERR:WHILE_NON_QUOTE' || { rment; return 1; }
	x=$(printf '[ 1 ] [ ] while\n' | sed -f "${_ent}" 2>/dev/null); r=$?
	chke "run whilebool" "${x}" "${r}" 'ERR:WHILE_NON_BOOL' || { rment; return 1; }
	x=$(printf '3 4 0 [ over 0 gt ] [ rot dup rot add rot 1 sub swap ] while swap drop swap drop\n' | sed -f "${_ent}"); rment
	chk "run selfmul" "${x}" '12'
}

{ flexnumber && flexnegnumber && flexstring && flexemptystring && flexword && flexbrackets && flexmulti && flexprogram && fopdup && fopdrop && fopswap && fopover && foprot && fopaddbasic && fopaddcarry && fopaddoverflow && fopaddzero && fopaddunequal && fopsubbasic && fopsubnegative && fopsubborrow && fopsubzero && fopsubunequal && fopsubboundary && funderflowdup && funderflowdrop && funderflowswap && funderflowover && funderflowrot && funderflowadds && funderflowsub && fopeq && fopne && foplt && fople && fopgt && fopge && funderflowcmp && fdispatchliteral && fdispatchstack && fdispatcharith && fdispatchaddtail && fdispatchboolerr && fdispatchsubtail && fdispatchcmptail && fevaltokens && fevallexed && fevalmore && fevalerrors && fevallexedmulti && frunsource && fquote && fcall && fif && fwhile; r="${?}"; } || exit 1

[ "${r}" -eq 0 ] 2>/dev/null || printf "%s\n" "${r}"
