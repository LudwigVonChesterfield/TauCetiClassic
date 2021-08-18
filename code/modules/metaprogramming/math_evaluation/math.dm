//Define some data-types to store information
//*********************************
/Scalar	//A scalar is just a number, like 1 or 2, or 3+4i
	var/real = 0		//The real part of a number
	var/imaginary = 0	//The imaginary part
/Scalar/proc/magnitude()	//Determines the magnitude by way of Pythagoras
	return sqrt(real**2 + imaginary**2)
/Scalar/proc/conjugate()	//Finds the conjugate
	var/Scalar/conjugate = new()
	conjugate.real = real
	conjugate.imaginary = 0 - imaginary
	return conjugate
/String  //A string is a sequence of characters that form text
	var/text = ""
/String/proc/len()
	return length(text)
/Vector	//A vector is a number that has direction.  It is stored in component form.
	var/components[] = list()
/Vector/proc/magnitude()	//Determines the magnitude, also with Pythagoras
	var/total
	for(var/j in 1 to components.len)
		total += components[j]**2
	return sqrt(total)
/List	//A list is primarily used to make several calculations at once.
	var/elements[] = list()
/List/proc/len()
	return elements.len
/Matrix	//A matrix is an array of data in two directions
	var/data[][]//Shh...  this isn't here.  You didn't see it.

//Some checks for different data types.
/proc/equal(datum/A, datum/B)
	if(istype(A,/List) && istype(B,/List))
		return equal_lists(A,B)
	if(istype(A,/Scalar) && istype(B,/Scalar))
		return equal_scalars(A,B)
	if(istype(A,/String) && istype(B,/String))
		return equal_strings(A,B)
	if(istype(A,/Vector) && istype(B,/Vector))
		return equal_vectors(A,B)
	return 0

/proc/equal_strings(String/A,String/B)
	return A.text == B.text
/proc/equal_scalars(Scalar/A,Scalar/B)
	return (A.real == B.real) && (A.imaginary == B.imaginary)
/proc/equal_lists(List/A,List/B)
	if(A.len() != B.len())
		return 0
	else
		for(var/i in 1 to A.len())
			if(interpret(A.elements[i]) != interpret(B.elements[i])) return 0
	return 1
/proc/equal_vectors(Vector/A,Vector/B)
	if(A.components.len != B.components.len)
		return 0
	else
		for(var/i in 1 to A.components.len)
			if(A.components[i] != B.components[i]) return 0
	return 1

/proc/inlist(datum/A, List/L)
	for(var/x in L.elements)
		if(equal(A,x))
			return 1

	return 0


//Define some functions that will need to be used in calculations.
//*********************************
//All-purpose mathematical procs
/proc/cosh(x)
	return (e**x - e**(-x))/2
/proc/sinh(x)
	return (e**x + e**(-x))/2
/proc/tanh(x)
	return sinh(x)/cosh(x)
/proc/arcsinh(x)
	return log(x + sqrt(x*x + 1))
/proc/arccosh(x)
	return log(x + sqrt(x*x - 1))
/proc/arctanh(x)
	return log((1 + x) / (1 - x)) / 2
/proc/Sin(x)
  x%=360
  if(x<0) x+=360
  if(x>=180)
    if(x>270) return -sin(360-x)
    return -sin(x-180)
  if(x>90) return sin(180-x)
  return sin(x)
/proc/factorial(n as num) //Borrowed from Spuzzum
	if(n<=0) return 1
	return .(n-1)*n
/proc/bc(num1, num2) //Binomial Coefficient
	return factorial(num1)/(factorial(num2)*factorial(num1-2))

//Procs that act on SET objects only:
/proc/negate(Scalar/next)
	var/datum/result
	if(istype(next,/Scalar))
		result = new/Scalar
		result:real = 0 - next.real
		result:imaginary = 0 - next.imaginary
	else if(istype(next,/Vector))
		result = new/Vector
		var/Vector/V = next
		for(var/i in V.components)
			result:components += -i
	else if(istype(next,/List))
		result = new/List
		var/List/L = next
		for(var/i in L.elements)
			result:elements += negate(i)
	return result

/proc/exponent(Scalar/number, Scalar/exponent)
	var/datum/result
	if(istype(number,/Scalar) && istype(exponent,/Scalar))
		if(exponent.imaginary)
			usr << "Imaginary exponents not yet supported.  Author needs to learn more math :-)"
			return list()
		else
			result = new/Scalar()
			if(!number.imaginary)	//Special case of all real numbers.  Easy to handle.
				result:real = number.real**exponent.real
			else//Must convert to polar form and use DeMoivre's Theorem.  Yuck.
				var/r = number.magnitude()
				var/theta = 90 //If number has no real component
				if(number.real)theta = arctan((number.imaginary/number.real)*180/pi)
				result:real = (r**exponent.real)*cos(exponent.real*theta)
				result:imaginary = (r**exponent.real)*Sin(exponent.real*theta)
	else if(istype(number,/List))
		result = new/List
		var/List/L = number
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = exponent(L.elements[i], exponent)
	else if(istype(exponent,/List))
		result = new/List
		var/List/L = exponent
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = exponent(number,L.elements[i])
	return result

/proc/choose_multiply(Scalar/multiplier, Scalar/multiplicand, vector)
	var/datum/result
	if(istype(multiplier,/Scalar) && istype(multiplicand,/Scalar))
		result = multiply(multiplier, multiplicand)
	else if(istype(multiplier,/Vector) && istype(multiplicand,/Vector))
		if(vector=="dot")
			result = dot(multiplier, multiplicand)
		else if(vector=="cross")
			result = cross(multiplier, multiplicand)
	else if(istype(multiplier,/Scalar) && istype(multiplicand,/Vector))
		result = new/Vector
		var/Vector/V = multiplicand
		for(var/i in V.components)
			result:components += multiplier.real * i
	else if(istype(multiplier,/Vector) && istype(multiplicand,/Scalar))
		result = new/Vector
		var/Vector/V = multiplier
		for(var/i in V.components)
			result:components += multiplicand.real * i
	else if(istype(multiplier,/List))
		result = new/List
		var/List/L = multiplier
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = choose_multiply(L.elements[i],multiplicand)
	else if(istype(multiplicand,/List))
		result = new/List
		var/List/L = multiplicand
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = choose_multiply(L.elements[i],multiplier)
	return result

/proc/multiply(Scalar/multiplier, Scalar/multiplicand)
	var/Scalar/product = new()
	product.real = multiplier.real*multiplicand.real - multiplier.imaginary*multiplicand.imaginary
	product.imaginary = multiplier.real*multiplicand.imaginary + multiplier.imaginary*multiplicand.real
	return product

/proc/dot(Vector/multiplier, Vector/multiplicand)
	var/Scalar/product = new()
	for(var/i in 1 to multiplier.components.len)
		product.real += multiplier.components[i]*multiplicand.components[i]
	return product

/proc/cross(Vector/A, Vector/B)
	var/Vector/result = new()
	if(istype(A,/Vector) && istype(B,/Vector))
		if(A.components.len == 3 && B.components.len == 3)
			result.components += A.components[2]*B.components[3] - A.components[3]*B.components[2]
			result.components += A.components[3]*B.components[1] - A.components[1]*B.components[3]
			result.components += A.components[1]*B.components[2] - A.components[2]*B.components[1]
	return result

/proc/divide(Scalar/divisor, Scalar/dividend)
	var/datum/result
	if(istype(divisor,/Scalar) && istype(dividend,/Scalar))
		result = new/Scalar
		var/Scalar/conjugate = dividend.conjugate()
		result = multiply(divisor, conjugate)
		result:real /= dividend.magnitude()**2
		result:imaginary /= dividend.magnitude()**2
	else if(istype(divisor,/List))
		result = new/List
		var/List/L = divisor
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = divide(L.elements[i], dividend)
	else if(istype(dividend,/List))
		result = new/List
		var/List/L = dividend
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = divide(divisor,L.elements[i])
	return result

/proc/mod(Scalar/first, Scalar/second)
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real % second.real	//Imaginary parts are ignored!
	else if(istype(first,/List))
		result = new/List
		var/List/L = first
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = mod(L.elements[i], second)
	else if(istype(second,/List))
		result = new/List
		var/List/L = second
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = mod(first, L.elements[i])
	return result

/proc/add(Scalar/first, Scalar/second)
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real + second.real
		result:imaginary = first.imaginary + second.imaginary
	else if(istype(first,/String) && istype(second,/String))
		result = new/String
		result:text = first:text + second:text
	else if(istype(first,/Vector) && istype(second,/Vector))
		result = new/Vector
		var/Vector/V = first
		result:components = V.components.Copy()
		for(var/i in 1 to V.components.len)
			result:components[i] = V:components[i]
		V = second
		for(var/i in 1 to V.components.len)
			result:components[i] += V:components[i]
	else if(istype(first,/List))
		result = new/List
		var/List/L = first
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = add(L.elements[i],second)
	else if(istype(second,/List))
		result = new/List
		var/List/L = second
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = add(first, L.elements[i])
	return result

/proc/subtract(Scalar/first, Scalar/second)
	var/datum/result
	if(istype(first,/Scalar) && istype(second,/Scalar))
		result = new/Scalar
		result:real = first.real - second.real
		result:imaginary = first.imaginary + second.imaginary
	else if(istype(first,/Vector) && istype(second,/Vector))
		result = new/Vector
		var/Vector/V = first
		result:components = V.components.Copy()
		for(var/i in 1 to V.components.len)
			result:components[i] = V:components[i]
		V = second
		for(var/i in 1 to V.components.len)
			result:components[i] -= V:components[i]
	else if(istype(first,/List))
		result = new/List
		var/List/L = first
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = subtract(L.elements[i],second)
	else if(istype(second,/List))
		result = new/List
		var/List/L = second
		result:elements = L.elements.Copy()
		for(var/i in 1 to L.elements.len)
			result:elements[i] = subtract(first, L.elements[i])
	return result

//Define some constants
//*********************************
/proc/constant(string)
	switch(string)
		if("pi")
			var/Scalar/Pi = new()
			Pi.real = pi
			return Pi
		if("i")
			var/Scalar/i = new()
			i.imaginary = 1
			return i
		if("e")
			var/Scalar/E = new()
			E.real = e
			return E
