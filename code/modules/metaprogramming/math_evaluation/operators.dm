//Here are all of the operators that SET can use
/operator
	var/partner			//Some operators have a "partner"... specifically ? and (

/operator/proc/operate(list/symbols, position, datum/computer_environment/environment, code)
	return symbols		//By default, do nothing to the list

//Operators
/operator/parenthesis

/operator/parenthesis/close

/operator/parenthesis/operate(list/symbols, position, datum/computer_environment/environment, code)
	var/partner_pos = symbols.Find(partner)
	to_chat(world, "[type] CALLING A_EVALUATE")
	return symbols.Copy(1, position) + a_Evaluate(symbols.Copy(position+1, partner_pos), environment, code) + symbols.Copy(partner_pos+1, 0)

/operator/binary_not/operate(list/symbols, position)
	var/Scalar/next = symbols[position + 1]
	var/datum/result
	if(istype(next,/Scalar))
		result = new/Scalar
		result:real = ~next.real
	return symbols.Copy(1, position) + result + symbols.Copy(position + 2, 0)
/operator/logical_not/operate(list/symbols, position)
	var/Scalar/next = symbols[position + 1]
	var/datum/result
	if(istype(next,/Scalar))
		result = new/Scalar
		result:real = !next.real && !next.imaginary
	else if(istype(next,/String))
		result = new/Scalar
		result:real = !next:text
	else if(istype(next,/List))
		result = new/Scalar
		var/List/L = next
		result:real = !length(L.elements)
	return symbols.Copy(1, position) + result + symbols.Copy(position + 2, 0)
/operator/negative/operate(list/symbols, position)
	var/Scalar/next = symbols[position + 1]
	var/datum/result = negate(next)
	return symbols.Copy(1, position) + result + symbols.Copy(position + 2, 0)

/operator/exponent/operate(list/symbols, position)
	var/Scalar/number = symbols[position - 1]
	var/Scalar/exponent = symbols[position + 1]
	var/datum/result = exponent(number, exponent)
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/union/operate(list/symbols, position)
	var/List/first = symbols[position - 1]
	var/List/second = symbols[position + 1]
	var/List/result
	if(istype(first,/List) && istype(second,/List))
		result = new()
		for(var/i in first.elements+second.elements)
			if(!inlist(i, result))
				result.elements += i
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/intersect/operate(list/symbols, position)
	var/List/first = symbols[position - 1]
	var/List/second = symbols[position + 1]
	var/List/result
	if(istype(first,/List) && istype(second,/List))
		result = new()
		for(var/i in first.elements)
			if(inlist(i, second))
				result.elements += i
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/multiply
	var/vector = "dot"

/operator/multiply/cross
	vector = "cross"

/operator/multiply/operate(list/symbols, position)
	var/Scalar/multiplier = symbols[position - 1]
	var/Scalar/multiplicand = symbols[position + 1]
	var/datum/result = choose_multiply(multiplier, multiplicand, vector)
	return symbols.Copy(1, position - 1) + result + symbols.Copy(position + 2, 0)
/operator/divide/operate(list/symbols, position)
	var/Scalar/divisor = symbols[position - 1]
	var/Scalar/dividend = symbols[position + 1]
	var/datum/result = divide(divisor, dividend)
	return symbols.Copy(1, position - 1) + result + symbols.Copy(position + 2, 0)
/operator/mod/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result = mod(first, second)
	return symbols.Copy(1, position - 1) + result + symbols.Copy(position + 2, 0)

/operator/add/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result = add(first, second)
	return symbols.Copy(1, position - 1) + result + symbols.Copy(position + 2, 0)
/operator/subtract/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result = subtract(first, second)
	return symbols.Copy(1, position - 1) + result + symbols.Copy(position + 2, 0)

/operator/less/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		if(first.imaginary || second.imaginary)//If either is complex, use magnitude
			result:real = first.magnitude() < second.magnitude()
		else
			result:real = first.real < second.real
	else if(istype(first,/String) && istype(second,/String))
		result = new/Scalar
		result:real = first:text < second:text
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/less_equal/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		if(first.imaginary || second.imaginary)//If either is complex, use magnitude
			result:real = first.magnitude() <= second.magnitude()
		else
			result:real = first.real <= second.real
	else if(istype(first,/String) && istype(second,/String))
		result = new/Scalar
		result:real = first:text <= second:text
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/greater/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		if(first.imaginary || second.imaginary)//If either is complex, use magnitude
			result:real = first.magnitude() > second.magnitude()
		else
			result:real = first.real > second.real
	else if(istype(first,/String) && istype(second,/String))
		result = new/Scalar
		result:real = first:text > second:text
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/greater_equal/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		if(first.imaginary || second.imaginary)//If either is complex, use magnitude
			result:real = first.magnitude() >= second.magnitude()
		else
			result:real = first.real >= second.real
	else if(istype(first,/String) && istype(second,/String))
		result = new/Scalar
		result:real = first:text >= second:text
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/shift_left/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real<<second.real
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)
/operator/shift_right/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real>>second.real
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/equal/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result = new/Scalar()
	result:real = equal(first,second)
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/not_equal/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result = new/Scalar()
	result:real = !equal(first,second)
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/in_op/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/List/second = symbols[position + 1]
	var/datum/result
	if(istype(second,/List))
		result = new/Scalar
		result:real = inlist(first,second)
	else if (istype(first,/String) && istype(second,/String))
		result = new/Scalar
		if(findtext(second:text,first:text))
			result:real = 1
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/binary_and/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real&second.real
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/binary_or/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real|second.real
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/binary_xor/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real^second.real
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/and/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/e_first
	var/e_second
	if(istype(first,/Scalar))
		e_first = first.magnitude()
	else if(istype(first,/String))
		e_first = !(!first:text)
	if(istype(second,/Scalar))
		e_second = second.magnitude()
	else if(istype(second,/String))
		e_second = !(!second:text)
	var/Scalar/result = new()
	result.real = e_first && e_second
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/or/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/e_first
	var/e_second
	if(istype(first,/Scalar))
		e_first = first.magnitude()
	else if(istype(first,/String))
		e_first = !(!first:text)
	if(istype(second,/Scalar))
		e_second = second.magnitude()
	else if(istype(second,/String))
		e_second = !(!second:text)
	var/Scalar/result = new()
	result.real = e_first || e_second
	return symbols.Copy(1, position-1) + result + symbols.Copy(position + 2, 0)

/operator/question/operate(list/symbols, position)
	var/Scalar/first = symbols[position - 1]
	var/Scalar/second = symbols[position + 1]
	var/Scalar/third = symbols[symbols.Find(partner) + 1]
	var/datum/result
	if(istype(first,/Scalar))
		if(first.magnitude())
			result = second
		else
			result = third
	else if(istype(first,/String))
		result = new/Scalar
		if(first:text)
			result = second
		else
			result = third
	return symbols.Copy(1, position-1) + result + symbols.Copy(symbols.Find(third) + 1, 0)



/operator/question_partner	//Not a real operator, but it plays one on TV.

/operator/comma				//Also not real.  Used to seperate multiple arguments to a function

/proc/find_arguments(list/Symbols, start, end, datum/computer_environment/environment, code)
	var/buffer[] = list()
	var/arguments[] = list()
	var/count = 0
	for(var/i in (start+1) to (end-1))
		var/operator/current = Symbols[i]
		if(current.type==/operator/parenthesis || istype(current, /operator/function)) count++
		if(current.type==/operator/parenthesis/close) count--
		if(count==0 && istype(current,/operator/comma))
			arguments += a_Evaluate(buffer, environment, code)
			buffer = list()
		else
			buffer += current
	arguments += a_Evaluate(buffer, environment, code)
	return arguments
