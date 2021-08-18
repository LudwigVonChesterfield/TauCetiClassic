/operator/function

/operator/function/VAR/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/argument = a_Evaluate(symbols.Copy(position+1, partner_pos), environment, code)
	var/result = 0
	if(istype(argument,/String))
		var/String/name = argument
		if(name.text == "code")
			result = code
		else
			result = environment.get_variable(name.text)
	var/Scalar/S = new
	S.real = result
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)

/operator/function/FUNC/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/name = arguments[1]
	var/_code = arguments[2]
	var/result = 0
	if(istype(name,/String) && istype(_code,/Scalar))
		var/String/name_string = name
		var/Scalar/code_scalar = _code
		result = environment.call_function(name_string.text, code_scalar.real)
	var/Scalar/S = new
	S.real = result
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)

/operator/function/VEC/operate(list/symbols, position, datum/computer_environment/environment, code) //Create a vector by magnitude and direction
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Vector/V = new()
	var/Scalar/magnitude = arguments[1]
	var/Scalar/direction = arguments[2]
	V.components = list(magnitude.real*cos(direction.real), magnitude.real*Sin(direction.real))
	return symbols.Copy(1, position) + V + symbols.Copy(partner_pos+1, 0)

/operator/function/VECC/operate(list/symbols, position, datum/computer_environment/environment, code) //Create a vector by components
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Vector/V = new()
	for(var/Scalar/S in arguments)
		V.components += S.real
	return symbols.Copy(1, position) + V + symbols.Copy(partner_pos+1, 0)

/operator/function/LIST/operate(list/symbols, position, datum/computer_environment/environment, code) //Create a list
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/List/L = new()
	for(var/S in arguments)
		L.elements += S
	return symbols.Copy(1, position) + L + symbols.Copy(partner_pos+1, 0)

/operator/function/SQRT/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	var/Scalar/exponent = new()
	exponent.real = 1/2
	var/insert[] = list(argument,new/operator/exponent,exponent)
	return symbols.Copy(1, position) + insert + symbols.Copy(partner_pos+1, 0)

/operator/function/SIN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = Sin(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/COS/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = cos(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/TAN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = Sin(argument.real)/cos(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/SINH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = sinh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/COSH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = cosh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/TANH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = sinh(argument.real)/cosh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCSIN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arcsin(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCCOS/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arccos(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCTAN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arctan(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCSINH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arcsinh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCCOSH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arccosh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ARCTANH/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = arctanh(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/LN/operate(list/symbols, position, datum/computer_environment/environment, code)		//Natural Log
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = log(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/LOG/operate(list/symbols, position, datum/computer_environment/environment, code)		//Common Log
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = log(10,argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/LOGX/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/S = new()
	var/Scalar/first = arguments[1]
	var/Scalar/second = arguments[2]
	S.real = log(first.real,second.real)
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)

/operator/function/ABS/operate(list/symbols, position, datum/computer_environment/environment, code)		//Absolute value
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = abs(argument.real)
	argument.imaginary = abs(argument.imaginary)
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/MAG/operate(list/symbols, position, datum/computer_environment/environment, code)		//Magnitude
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	if(istype(argument,/Scalar))
		argument.real = argument.magnitude()
		argument.imaginary = 0
		return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)
	else if(istype(argument,/Vector))
		var/Scalar/S = new()
		S.real = argument.magnitude()
		return symbols.Copy(1, position) + S  + symbols.Copy(partner_pos+1, 0)

/operator/function/CONJ/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	return symbols.Copy(1, position) + argument.conjugate() + symbols.Copy(partner_pos+1, 0)

/operator/function/FAC/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = factorial(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/INT/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	var/real = argument.real
	var/imaginary = argument.real
	argument.real = round(argument.real)
	argument.imaginary = round(argument.imaginary)
	if(argument.real < 0)
		if(real != argument.real)
			argument.real += 1
	if(argument.imaginary < 0)
		if(imaginary != argument.imaginary)
			argument.imaginary += 1
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/ROUND/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = round(argument.real, 1)
	argument.imaginary = round(argument.imaginary, 1)
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/MAX/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/maximum
	for(var/Scalar/S in arguments)
		if(!maximum || (S.magnitude() > maximum.magnitude()))
			maximum = S
	return symbols.Copy(1, position) + maximum + symbols.Copy(partner_pos+1, 0)

/operator/function/MIN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/minimum
	for(var/Scalar/S in arguments)
		if(!minimum || (S.magnitude() < minimum.magnitude()))
			minimum = S
	return symbols.Copy(1, position) + minimum + symbols.Copy(partner_pos+1, 0)

/operator/function/FLOOR/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	argument.real = round(argument.real)
	argument.imaginary = 0
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/CEIL/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/Scalar/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	var/old = argument.real
	argument.real = round(argument.real)
	if(old != argument.real)
		argument.real += 1
	return symbols.Copy(1, position) + argument + symbols.Copy(partner_pos+1, 0)

/operator/function/SUM/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/sum = new()
	for(var/Scalar/S in arguments)
		sum.real += S.real
		sum.imaginary += S.imaginary
	return symbols.Copy(1, position) + sum + symbols.Copy(partner_pos+1, 0)

/operator/function/AVG/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/sum = new()
	for(var/Scalar/S in arguments)
		sum.real += S.real
		sum.imaginary += S.imaginary
	sum.real /= arguments.len
	sum.imaginary /= arguments.len
	return symbols.Copy(1, position) + sum + symbols.Copy(partner_pos+1, 0)

/operator/function/BC/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/S = new()
	var/Scalar/first = arguments[1]
	var/Scalar/second = arguments[2]
	S.real = bc(first.real, second.real)
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)

/operator/function/RAND/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/arguments[] = find_arguments(symbols, position, partner_pos)
	var/Scalar/S = new()
	var/Scalar/first = arguments[1]
	var/Scalar/second = arguments[2]
	S.real = rand(first.real, second.real)
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)

/operator/function/LEN/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	var/String/argument = a_Evaluate(symbols.Copy(position+1, partner_pos))
	var/Scalar/S = new()
	if(istype(argument,/String))
		S.real = argument.len()
	else if(istype(argument,/List))
		S.real = argument.len()
	return symbols.Copy(1, position) + S + symbols.Copy(partner_pos+1, 0)
