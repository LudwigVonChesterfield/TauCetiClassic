//These procedures are responsible for transforming the text string into a list of datums
//*********************************

//To avoid iterating through the entire list, the list is split based on what character the
//operator/function/constant begins with.
//They're sorted decreasingly by length of text.  This is to ensure that things like && are caught
//instead of using just the first &
var/known[] = list(\
	"a"=list("arctanh(","arccosh(","arcsinh(","arccos(","arcsin(","arctan(","abs(","avg("),\
	"b"=list("bc("),\
	"c"=list("cosh(","conj(","ceil(","cos("),\
	"e"=list("e"),\
	"f"=list("floor(","func(","fac("),\
	"i"=list("int(","in","i"),\
	"I"=list("I"),\
	"l"=list("logx(","list(","log(","len(","ln("),\
	"m"=list("mag(","max(","min("),\
	"p"=list("pi"),\
	"r"=list("round(","rand("),\
	"s"=list("sqrt(","sinh(","sin(","sum("),\
	"t"=list("tanh(","tan("),\
	"U"=list("U"),\
	"v"=list("vecc(","vec(","var("),\
	"X"=list("X"),\
	"+"=list("+"),\
	"&"=list("&&","&"),\
	"~"=list("~"),\
	"|"=list("||","|"),\
	"^"=list("^"),\
	","=list(","),\
	"/"=list("/"),\
	"="=list("==","="),\
	"*"=list("**","*"),\
	">"=list(">=",">>",">"),\
	"<"=list("<=","<<","<>","<"),\
	"!"=list("!=","!"),\
	"("=list("("),\
	")"=list(")"),\
	"?"=list("?"),\
	":"=list(":"),\
	"-"=list("-"),\
	"%"=list("%")\
	)
var/operators[] = list("("=/operator/parenthesis,")"=/operator/parenthesis/close,"!"=/operator/logical_not,"**"=/operator/exponent,"/"=/operator/divide,"%"=/operator/mod,\
	"+"=/operator/add,"<"=/operator/less,">"=/operator/greater,"<="=/operator/less_equal,">="=/operator/greater_equal,"*"=/operator/multiply,\
	"=="=/operator/equal,"!="=/operator/not_equal,"<>"=/operator/not_equal,"&&"=/operator/and,"||"=/operator/or,"?"=/operator/question,":"=/operator/question_partner,","=/operator/comma,\
	"<<"=/operator/shift_left,">>"=/operator/shift_right,"&"=/operator/binary_and,"|"=/operator/binary_or,"^"=/operator/binary_xor,"~"=/operator/binary_not,\
	"sin("=/operator/function/SIN,"cos("=/operator/function/COS,"tan("=/operator/function/TAN,"arcsin("=/operator/function/ARCSIN,\
	"arccos("=/operator/function/ARCCOS,"arctan("=/operator/function/ARCTAN,"ln("=/operator/function/LN,"log("=/operator/function/LOG,"abs("=/operator/function/ABS,\
	"mag("=/operator/function/MAG,"conj("=/operator/function/CONJ,"fac("=/operator/function/FAC,"int("=/operator/function/INT,"round("=/operator/function/ROUND,\
	"vec("=/operator/function/VEC,"vecc("=/operator/function/VECC,"logx("=/operator/function/LOGX,"sqrt("=/operator/function/SQRT,"max("=/operator/function/MAX,\
	"min("=/operator/function/MIN,"floor("=/operator/function/FLOOR,"ceil("=/operator/function/CEIL,"sum("=/operator/function/SUM,"avg("=/operator/function/AVG,\
	"bc("=/operator/function/BC,"sinh("=/operator/function/SINH,"cosh("=/operator/function/COSH,"tanh("=/operator/function/TANH,"arccosh("=/operator/function/ARCCOSH,\
	"arcsinh("=/operator/function/ARCSINH,"arctanh("=/operator/function/ARCTANH,"rand("=/operator/function/RAND,"X"=/operator/multiply/cross,"list("=/operator/function/LIST,\
	"len("=/operator/function/LEN,"in"=/operator/in_op,"U"=/operator/union,"I"=/operator/intersect, "func("=/operator/function/FUNC, "var("=/operator/function/VAR)

/proc/starts_with(string, prefix)
	return copytext(string, 1, length(prefix) + 1)==prefix

/proc/is_num(char)
	if(char in list("0","1","2","3","4","5","6","7","8","9",".")) return 1
	return 0

/proc/split_text(string)
	var/symbols[] = list()
	while(string)
		var/start_string = string
		var/number = string[1]
		if(number==" ")
			string = copytext(string, length(number)+1, 0)
			continue
		else if(is_num(number))
			var/check
			for(var/i = length(number) + 1; i <= length(string); i += length(check))
				check = string[i]
				if(is_num(check))
					number += check
				else
					break
			string = copytext(string, length(number)+1, 0)
			var/Scalar/S = new()
			S.real = text2num(number)
			symbols += S
		else if(number == "\"" || number == "'")
			var/next=findtextEx(string, number, 1 + length(number), 0)
			var/String/S = new()
			S.text = eval_text(copytext(string, 1 + length(number), next))
			string = copytext(string, next + length(number), 0)
			symbols += S
		else
			for(var/check in known[number])
				if(starts_with(string, check))
					string = copytext(string, length(check)+1, 0)
					if(check==" ")break
					var/type = operators[check]
					if(check=="-")
						var/operator/O
						if(symbols.len)
							var/datum/last = symbols[symbols.len]
							if((last.type in list(/Scalar,/operator/parenthesis/close)))
								O = new/operator/subtract
							else
								O = new/operator/negative
						else
							O = new/operator/negative
						symbols += O
					else if(type)
						var/operator/O = new type()
						symbols += O
					else
						var/Scalar/S = constant(check)
						symbols += S
					break
		if(start_string==string)
			return list()
	return(partnerize(symbols))

/proc/eval_text(string) //Takes a string and evaluates special characters in it
	var/j_char
	for(var/j = 1; j <= length(string); j += length(j_char))
		j_char = string[j]
		if(j_char=="(")
			var/count
			var/k_char
			for(var/k = j; k <= length(string); k += length(k_char))
				k_char = string[k]
				if(k_char=="(")
					count++
				else if(k_char==")")
					count--
					if(count==0)
						string = copytext(string,1,j) + SET(copytext(string,j+1,k)) + copytext(string,k+1,0)
	return string
