/*SET = SET a_Evaluates Things   (v2.2)
  written by AbyssDragon (abyssdragon@hotmail.com)

  Feel free to modify/improve/destroy/steal/use any of this code however you see fit.
  A thanks or mention in your project would be nice, but neither are required.

  The recursive name "SET" was chosen because of the high amount of recursion used.  Plus,
  recursive acronyms are just really nerdy, so I couldn't pass up the opportunity.

  The usage is simple.  Pass to SET() a text string containing what you want it to evaluate.
  Functions currently available:
	  abs(x) //returns the absolute value of x
	  arccos(x) //returns the arc-cosine of x (in degrees)
	  arccosh(x) //returns the arc-hyperbolic cosine of x
	  arcsin(x) //returns the arc-sine of x
	  arcsinh(x) //returns the arc-hyperbolic sine of x
	  arctan(x) //returns the arc-tangent of x
	  arctanh(x) //returns the arc-hyperbolic tangent of x
	  avg(a, b, ...) //returns the mean average of a, b, ...
	  bc(a, b) //returns the binomial coefficient (a b)
	  ceil(x) //returns the least integer not lesser than x
	  conj(x) //returns the imaginary conjugate of x
	  cos(x) //returns the cosine of x (where x is in degrees)
	  cosh(x) //returns the hyperbolic cosine of x
	  fac(x) //returns x factorial
	  floor(x) //returns the greatest integer not greater than x
	  int(x) //returns the integer part of x
	  len(x) //returns the length of the string or list x
	  list(a, b, ...) //returns a list with elements a, b, ...  elements can be scalars, vectors
	  		matrices, strings, or even other lists.
	  ln(x) //returns the natural log of x
	  log(x) //returns the common log of x
	  logx(a,x) //returns the log (base a) of x
	  min(a, b, ...) //returns the least of a, b, ...
	  mag(x) //returns the magnitude of x
	  max(a, b, ...) //returns the greatest of a, b, ...
	  rand(a, b) //returns a random number between a and b, inclusive
	  round(x) //rounds x to the nearest integer
	  sin(x) //returns the sine of x
	  sinh(x) //returns the hyperbolic sine of x
	  sqrt(x) //returns the square root of x
	  sum(a, b, ...) //returns the sum of a, b, ...
	  tan(x) //returns the tangent of x
	  tanh(x) //returns the hyperbolic tangent of x
	  vec(a, b) //returns a vector with magnitude a, and direction b (in degrees)
	  vecc(a1, a2, ...) //returns a vector with components of a1, a2, ...
  Constants currently implemented are pi, e, and i.
  It follows the same notation as BYOND, and allows for all operators, except for those
  that modify only variables (as would be expected).  Note that for vectors * represents dot
  product, and X represents cross product.
  It follows the standard order of operations, the same as BYOND.  Check the Help on Operators to see this
  in a list.  If you do MASSIVE evaluation, you may cause BYOND to think it's in an infinite loop.  You'll
  have to turn loop checks off, in that case.  Rest assured that the loop WILL complete, eventually.
  The limit to the number of numbers/objects plus the number of operations is the limit on objects BYOND can handle.
  In other words, you shouldn't have to worry about it.  It would take an expression several *pages* long before
  that ever happened.

  Here are some examples:
  SET("2+2") 		//returns "4"
  SET("2**2")		//returns "4"
  SET("!5")			//returns "0"
  SET("5%2")		//returns "1"
  SET("(2**2)**2") 	//returns "16"
  SET("((2+1)*(5+7)/3)**3") //returns "1728"
  SET("(1+2)==3") 	//returns "1" (TRUE)
  SET("sin(90)") 	//returns "1"
  SET("ln(e)")		//returns "1"
  SET("(1+2)(3+4)")	//returns "21". Implicit multiplication between parenthesis sets is automatically determined.
  SET("(3+i)*(1+i)")//returns "4 + 4i".  Yes, it even supports complex numbers!

  If it ever produces an incorrect result (other than one caused by a BYOND rounding error),
  REPORT IT IMMEDIATELY.  I believe this to be bugless, but it's impossible to check every case.
  Certain features are not fully implemented, most notably lacking is handling of complex numbers
  for all operations and functions.
  There is also very little error reporting.  Whats there as of now isn't very good, either.  In
  future versions it will be streamlined.  Currently, malformed strings like "(1+2" or "4+/7" will
  just crash a proc during execution.
*/

//The core procedures of the program.
//*********************************
/proc/SET(T as text, datum/computer_environment/environment=null, code=0) //The text evaluation proc
	return interpret(Evaluate(T, environment, code))

/proc/Evaluate(T as text, datum/computer_environment/environment, code=0)//Call Evaluate to get the object
	return a_Evaluate(split_text(T), environment, code)

/proc/partnerize(list/symbols)//Certain operators have "partner" operators (like parentheses)
	for(var/i in 1 to symbols.len)
		var/operator/current = symbols[i]
		if(current.type == /operator/parenthesis || istype(current, /operator/function))
			var/count = 1
			for(var/j in (i+1) to symbols.len)
				var/operator/search = symbols[j]
				if(search.type == /operator/parenthesis) count++
				else if(istype(search, /operator/function)) count++
				else if(search.type == /operator/parenthesis/close)
					count--
					if(count == 0)
						current.partner = search
						break
		else if(current.type == /operator/question)
			var/count = 1
			for(var/j in (i + 1) to symbols.len)
				var/operator/search = symbols[j]
				if(search.type == /operator/question) count++
				else if(search.type == /operator/question_partner)
					count--
					if(count == 0)
						current.partner = search
						break
	return symbols

//The evaluator.  Loops through the list of datums and performs the operations
/proc/a_Evaluate(list/symbols, datum/computer_environment/environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if((O.type == /operator/parenthesis) || istype(O, /operator/function))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/binary_not,/operator/logical_not,/operator/negative))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/exponent,/operator/union,/operator/intersect))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 2 to symbols.len)	//This inserts implicit multiplication, as in (a+b)(c+d)
		var/operator/O = symbols[i]
		var/operator/prev = symbols[i - 1]
		if(O.type in list(/Scalar,/Vector,/List,/Matrix))
			if(O.type == prev.type)
				return .(symbols.Copy(1, i) + new/operator/multiply + symbols.Copy(i, 0), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/multiply,/operator/multiply/cross,/operator/divide,/operator/mod))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/add,/operator/subtract))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/less,/operator/less_equal,/operator/greater,/operator/greater_equal))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/shift_left,/operator/shift_right))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/equal,/operator/not_equal,/operator/in_op))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/binary_and,/operator/binary_or,/operator/binary_xor))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/and))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/or))
			return .(O.operate(symbols, i, environment, code), environment, code)
	for(var/i in 1 to symbols.len)
		var/operator/O = symbols[i]
		if(O.type in list (/operator/question))
			return .(O.operate(symbols, i, environment, code), environment, code)
	if(symbols.len) return symbols[1]
	return null

/proc/interpret(result)
	if(istype(result,/Scalar))
		var/Scalar/S = result
		if(!S.imaginary)
			return "[S.real]"
		else
			return "[S.real] + [S.imaginary]i"
	else if(istype(result,/Vector))
		var/c
		var/string = "Vector:("
		var/Vector/V  = result
		for(c in V.components)
			string += "[c] "
		string += ")"
		return string
	else if(istype(result,/List))
		var/c
		var/string = "List:("
		var/List/L  = result
		for(c in L.elements)
			string += interpret(c) + " "
		string += ")"
		return string
	else if(istype(result, /String))
		var/String/S = result
		return S.text
