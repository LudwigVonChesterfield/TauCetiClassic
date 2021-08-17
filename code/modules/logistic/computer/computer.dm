/datum/node
	var/list/datum/node/children

	var/element

/datum/node/New(element)
	src.element = element

/datum/node/proc/add_child(datum/node/N)
	LAZYADD(children, N)

/datum/node/proc/bfs(list/datum/node/traversed)
	traversed += src

	if(!children)
		return traversed

	for(var/datum/node/C in children)
		traversed = C.bfs(traversed)

	return traversed



/datum/token
	var/string
	var/role

/datum/token/New(string, role)
	src.string = string
	src.role = role


/datum/peekablestream
	var/list/tokens

/datum/peekablestream/New(tokens)
	src.tokens = tokens

/datum/peekablestream/proc/consume(k)
	var/token = tokens[k]
	tokens.Cut(k, k + 1)
	return token

/datum/peekablestream/proc/peak(k)
	return tokens[k]

/datum/peekablestream/proc/isEOF()
	return tokens.len == 0



/datum/computer_environment
	var/list/callbacks
	var/list/variables
	var/list/functions

/datum/computer_environment/proc/add_variable(name, value)
	LAZYSET(variables, name, value)

/datum/computer_environment/proc/add_callback(function, freq)
	LAZYSET(callbacks, freq, function)

/datum/computer_environment/proc/add_function(name, instructions)
	LAZYSET(functions, name, instructions)

/datum/computer_environment/proc/execute(obj/machinery/computer/logistic_computer/computer, datum/node/ast, command_name)
	to_chat(world, "EXECUTING [command_name]")
	global.computer_commands[command_name].execute(computer, src, ast)



var/global/list/datum/computer_command/computer_commands = list()
var/global/list/datum/computer_type/computer_types = list()

/proc/populate_computer_commands()
	for(var/command in subtypesof(/datum/computer_command))
		var/datum/computer_command/CC = new
		global.computer_commands[CC.name] = CC

	for(var/comp_type in subtypesof(/datum/computer_type))
		var/datum/computer_type/CT = new
		global.computer_types[CT.name] = CT



/datum/computer_type
	var/name

/datum/computer_type/proc/get(datum/computer_environment/environment, datum/node/ast)
	return

/datum/computer_type/expression
	name = "EXPRESSION"

/datum/computer_type/expression/get(datum/computer_environment/environment, datum/node/ast)
	return ast

/datum/computer_type/function
	name = "FUNCTION"

/datum/computer_type/function/get(datum/computer_environment/environment, datum/node/ast)
	var/datum/token/T = ast.element
	return T.string

/datum/computer_type/freq
	name = "FREQ"

/datum/computer_type/freq/get(datum/computer_environment/environment, datum/node/ast)
	var/val = global.computer_types["EXPRESSION"].get(environment, ast)
	return sanitize_frequency(val)



/datum/computer_command
	var/name

/datum/computer_command/proc/get(datum/computer_environment/environment, datum/node/ast, index, val_type)
	var/datum/node/N = ast.children[index]

	return global.computer_types[val_type].get(environment, N)

/datum/computer_command/proc/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast)

/datum/computer_command/register_signal
	name = "REGISTERSIGNAL_COMMAND"

/datum/computer_command/register_signal/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast)
	var/function_name = get(environment, ast, 2, "FUNCTION")
	var/freq = get(environment, ast, 3, "FREQ")

	environment.add_callback(function_name, freq)



/obj/machinery/computer/logistic_computer
	name = "logistic computer"
	icon_state = "computer_regular_stock"
	state_broken_preset = "computer_regularb"
	state_nopower_preset = "computer_regular0"

	var/static/list/possible_expressions
	var/static/list/possible_symbols
	var/static/list/possible_commands

	var/static/list/possible_statements

	var/static/list/possible_productions

	var/list/output
	var/list/errors

	var/datum/computer_environment/environment

	var/obj/item/paper/code

/obj/machinery/computer/logistic_computer/atom_init()
	. = ..()

	environment = new

	possible_expressions = list(
		"integer" = regex("\[0-9\]"),
		"identifier" = regex("\[_a-z0-9\]"),
		"command_or_function" = regex("\[A-Z\]"),
	)

	possible_symbols = list(
		"operator" = list(
			"+" = TRUE,
			"-" = TRUE,
			"*" = TRUE,
			"/" = TRUE,
		),
		"comparsion" = list(
			"==" = TRUE,
			">=" = TRUE,
			"<=" = TRUE,
			"!=" = TRUE,
		),
		"definition" = list(
			":" = TRUE,
		)
	)

	possible_commands = list(
		"REGISTERSIGNAL" = TRUE,
		"DECLARE" = TRUE,
		"DECLARESTACK" = TRUE,

		"SET" = TRUE,
		"SIGNAL" = TRUE,

		"STACKPUSH" = TRUE,
		"STACKPOP" = TRUE,
		"STACKREVERSE" = TRUE,

		"FUNCTION" = TRUE,
		"RETURNIF" = TRUE,
		"RETURN" = TRUE,
	)

	possible_statements = list(
		"REGISTERSIGNAL_COMMAND" = TRUE,
		"DECLARE_COMMAND" = TRUE,
		"DECLARESTACK_COMMAND" = TRUE,
		"SET_COMMAND" = TRUE,
		"SIGNAL_COMMAND" = TRUE,
		"STACKPUSH_COMMAND" = TRUE,
		"STACKPOP_COMMAND" = TRUE,
		"STACKREVERSE_COMMAND" = TRUE,
		"FUNCTION_DEFINITION" = TRUE,
		"FUNCTION_COMMAND" = TRUE,
		"RETURNIF_COMMAND" = TRUE,
		"RETURN_COMMAND" = TRUE,
	)

	possible_productions = list(
		"REGISTERSIGNAL_COMMAND" = list(
			"REGISTERSIGNAL function EXPRESSION" = TRUE,
		),
		"DECLARE_COMMAND" = list(
			"DECLARE IDENTIFIER EXPRESSION" = TRUE,
		),
		"DECLARESTACK_COMMAND" = list(
			"DECLARESTACK IDENTIFIER" = TRUE,
		),

		"SET_COMMAND" = list(
			"SET IDENTIFIER EXPRESSION" = TRUE,
		),
		"SIGNAL_COMMAND" = list(
			"SIGNAL EXPRESSION EXPRESSION" = TRUE,
		),

		"STACKPUSH_COMMAND" = list(
			"STACKPUSH IDENTIFIER EXPRESSION" = TRUE,
		),
		"STACKPOP_COMMAND" = list(
			"STACKPOP IDENTIFIER IDENTIFIER" = TRUE,
		),
		"STACKREVERSE_COMMAND" = list(
			"STACKREVERSE IDENTIFIER" = TRUE,
		),

		"FUNCTION_DEFINITION" = list(
			"function definition" = TRUE,
		),

		"FUNCTION_COMMAND" = list(
			"function EXPRESSION" = TRUE,
		),
		"RETURNIF_COMMAND" = list(
			"RETURNIF CONDITION EXPRESSION" = TRUE,
		),
		"RETURN_COMMAND" = list(
			"RETURN EXPRESSION" = TRUE
		),

		"IDENTIFIER" = list(
			"identifier" = TRUE,
		),

		"EXPRESSION" = list(
			"integer" = TRUE,
			"integer operator EXPRESSION" = TRUE,
		),
		"CONDITION" = list(
			"EXPRESSION comparsion EXPRESSION" = TRUE,
		),
	)

	interpret("REGISTERSIGNAL TEST 1459")

/obj/machinery/computer/logistic_computer/attack_hand(mob/user)
	return ..()

/obj/machinery/computer/logistic_computer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		run_code(I)
		return

	return ..()

/obj/machinery/computer/logistic_computer/proc/run_code(obj/item/weapon/paper/P)
	var/list/lines = splittext(P.info, "\n")

	for(var/line in lines)
		interpret(line)

/obj/machinery/computer/logistic_computer/proc/interpret(txt)
	var/list/tokens = lexer(txt)

	to_chat(world, "LEXXED [tokens.len]")
	var/i = 1
	for(var/datum/token/token as anything in tokens)
		to_chat(world, "[i] [token.string] [token.role]")
		i += 1

	if(errors)
		print(errors, "bold warning")
		errors = null
		return

	var/datum/node/ast = parser(tokens)

	var/list/datum/node/traversed = ast.bfs(list())

	if(errors)
		print(errors, "bold warning")
		errors = null
		return

	i = 1
	to_chat(world, "PARSED")
	for(var/datum/node/node as anything in traversed)
		var/datum/token/token = node.element
		to_chat(world, "[i] [token.string] [token.role]")
		i += 1

	interpreter(ast)

	if(errors)
		print(errors, "bold warning")
		errors = null

/obj/machinery/computer/logistic_computer/proc/print(list/messages, span)
	for(var/message in messages)
		to_chat(world, "<span class='[span]'>[message]</span>")

/obj/machinery/computer/logistic_computer/proc/error(txt)
	LAZYADD(errors, txt)

/obj/machinery/computer/logistic_computer/proc/scan_string(datum/peekablestream/stream, delimiter)
	var/retVal = ""
	while(!stream.isEOF())
		var/lookahead = stream.consume(1)
		if(lookahead == "\n")
			error("Encountered EOS while parsing string (should've encountered [delimiter])")
			break

		if(lookahead == delimiter)
			break

		retVal += lookahead

	// skip the delimeter.
	stream.consume(1)
	return retVal

/obj/machinery/computer/logistic_computer/proc/scan(datum/peekablestream/stream, first_char, regex/expression)
	var/retVal = first_char
	while(!stream.isEOF())
		var/lookahead = stream.consume(1)
		if(lookahead == "\n")
			break

		if(!expression.Find(lookahead))
			break

		retVal += lookahead

	return retVal

/obj/machinery/computer/logistic_computer/proc/lexer(txt)
	var/list/tokens = list()

	var/static/list/whitespace = list(
		" " = TRUE,
		"\n" = TRUE,
	)

	var/static/list/string_delimeters = list(
		"'" = TRUE,
		"\"" = TRUE,
	)

	var/datum/peekablestream/stream = new(splittext(txt, ""))

	while(!errors && !stream.isEOF())
		var/lookahead = stream.consume(1)
		if(lookahead == "\n")
			break

		if(whitespace[lookahead])
			continue

		if(string_delimeters[lookahead])
			tokens += new /datum/token(scan_string(stream, lookahead), "string")
			continue

		var/matched = FALSE

		for(var/role in possible_symbols)
			var/list/symbols = possible_symbols[role]
			if(symbols[lookahead])
				tokens += new /datum/token(lookahead, role)
				matched = TRUE
				break

			if(stream.isEOF())
				continue

			var/peaked = lookahead + stream.peak(1)
			if(symbols[peaked])
				// Consume the peaked symbol.
				stream.consume(1)
				tokens += new /datum/token(peaked, role)
				matched = TRUE
				break

		if(matched)
			continue

		for(var/role in possible_expressions)
			var/regex/regexp = possible_expressions[role]
			if(!regexp.Find(lookahead))
				continue

			var/scanned = scan(stream, lookahead, regexp)

			if(role == "command_or_function")
				var/command = possible_commands[scanned]
				role = command ? scanned : "function"

			tokens += new /datum/token(scanned, role)
			matched = TRUE
			break

		if(matched)
			continue

		error("Unexpected character: [lookahead]")

	return tokens

/obj/machinery/computer/logistic_computer/proc/parser_shift(datum/stack/stack, datum/token/lookahead)
	var/datum/node/N = new(
		lookahead
	)

	stack.Push(N)

	to_chat(world, "SHIFTING [lookahead.role] ([stack_to_string(stack)])")

/obj/machinery/computer/logistic_computer/proc/parser_reduce(datum/stack/stack, role, reduce_by, stack_string)
	var/datum/node/N = new(
		new /datum/token(stack_string, role)
	)

	for(var/i in 1 to reduce_by)
		var/datum/node/C = stack.Pop()

		N.add_child(C)

	stack.Push(N)

	to_chat(world, "REDUCING [role] ([stack_to_string(stack)])")

/obj/machinery/computer/logistic_computer/proc/stack_to_string(datum/stack/stack)
	stack = stack.Copy()

	var/datum/node/N = stack.Pop()
	var/datum/token/T = N.element
	var/stack_string = T.role

	while(!stack.is_empty())
		N = stack.Pop()
		T = N.element
		stack_string += " [T.role]"

	return stack_string

/obj/machinery/computer/logistic_computer/proc/find_reduce(datum/stack/stack, datum/peekablestream/stream)
	var/datum/stack/S = stack.Copy()
	S.Reverse()

	var/peak_string = null
	if(!stream.isEOF())
		var/datum/token/T = stream.peak(1)
		peak_string = T.role

	while(!S.is_empty())
		var/stack_string = stack_to_string(S)

		if(peak_string)
			var/stack_with_peak = "[stack_string] [peak_string]"
			for(var/role in possible_productions)
				var/list/productions = possible_productions[role]
				for(var/production in productions)
					if(findtext(production, stack_with_peak, 1, length(stack_with_peak) + 1))
						return null

		for(var/role in possible_productions)
			var/list/productions = possible_productions[role]
			if(productions[stack_string])
				return list("role"=role, "reduce_by"=S.Size(), "stack_string"=stack_string)

		S.Pop()

	return null

/obj/machinery/computer/logistic_computer/proc/parser(list/tokens)
	var/datum/peekablestream/stream = new /datum/peekablestream(tokens)

	var/datum/stack/stack = new()

	while(!errors && !stream.isEOF())
		var/datum/token/lookahead = stream.consume(1)

		parser_shift(stack, lookahead)

		while(TRUE)
			var/list/reduction = find_reduce(stack, stream)
			if(!reduction)
				break

			var/role = reduction["role"]
			var/reduce_by = reduction["reduce_by"]
			var/stack_string = reduction["stack_string"]

			parser_reduce(stack, role, reduce_by, stack_string)

	var/datum/node/tree = stack.Pop()

	var/datum/token/token = tree.element
	if(!possible_statements[token.role])
		error("Parse finished with a token that is not a statement: [token.role]")

	if(!stack.is_empty())
		error("Parse finished with unconsumed tokens: [stack_to_string(stack)]")

	return tree

/obj/machinery/computer/logistic_computer/proc/interpreter(datum/node/ast)
	var/datum/token/command = ast.element
	environment.execute(src, ast, command.role)
