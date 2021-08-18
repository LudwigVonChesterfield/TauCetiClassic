#define COMPUTER_MAX_CHARACTERS_PER_LINE 128
#define COMPUTER_MAX_LINES 128

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
	var/list/stacks

	var/declaring_function

	var/obj/machinery/computer/logistic_computer/computer

/datum/computer_environment/New(obj/machinery/computer/logistic_computer/computer)
	src.computer = computer

/datum/computer_environment/Destroy()
	reboot()

	computer = null

	return ..()

/datum/computer_environment/proc/reboot()
	for(var/freq in callbacks)
		computer.unregister_freq(freq)

	callbacks = null
	variables = null
	functions = null
	stacks = null

	declaring_function = null

/datum/computer_environment/proc/set_declaring_function(function)
	declaring_function = function

/datum/computer_environment/proc/add_variable(name, value)
	LAZYSET(variables, name, value)

/datum/computer_environment/proc/add_callback(function, freq)
	LAZYSET(callbacks, "[freq]", function)
	to_chat(world, "ADDING CALLBACK [function] to [freq]")
	computer.register_freq(freq)

/datum/computer_environment/proc/add_function(function)
	LAZYSET(functions, function, list())

/datum/computer_environment/proc/add_function_instruction(function, instruction)
	functions[function] += instruction

/datum/computer_environment/proc/add_stack(stack)
	LAZYSET(stacks, stack, new /datum/stack)

/datum/computer_environment/proc/get_variable(name)
	if(!variables || !variables[name])
		return 0
	return variables[name]

/datum/computer_environment/proc/set_variable(name, value)
	if(!variables || !variables[name])
		computer.add_error("Tried to set variable [name], which does not exist.")
		computer.crash()
		return
	variables[name] = value

/datum/computer_environment/proc/get_stack(stack)
	if(!stacks || !stacks[stack])
		computer.add_error("Tried to access stack [stack], which does not exist.")
		computer.crash()
		return
	return stacks[stack]


/datum/computer_environment/proc/call_function(function, code)
	if(!functions || !functions[function])
		computer.add_error("Tried to call function [function], which does not exist.")
		computer.crash()
		return 0

	var/list/instructions = functions[function]

	var/retVal = 0

	for(var/datum/node/instruction as anything in instructions)
		var/datum/token/command = instruction.element
		//to_chat(world, "WORKING ON [command] DUE TO [function] [code]")
		var/list/result = execute(instruction, command.role, code)
		if(!result)
			//to_chat(world, "no return")
			continue
		if(result["RETURN"])
			//to_chat(world, "will return [result["RETURN"]]")
			retVal = result["RETURN"]
		if(result["HALT"])
			//to_chat(world, "HALTING")
			break

	return retVal

/datum/computer_environment/proc/execute(datum/node/ast, command_name, code)
	return global.computer_commands[command_name].execute(computer, src, ast, code)



var/global/list/datum/computer_command/computer_commands = list()
var/global/list/datum/computer_type/computer_types = list()

/proc/populate_computer_commands()
	for(var/command in subtypesof(/datum/computer_command))
		var/datum/computer_command/CC = new command
		global.computer_commands[CC.name] = CC

	for(var/comp_type in subtypesof(/datum/computer_type))
		var/datum/computer_type/CT = new comp_type
		global.computer_types[CT.name] = CT



/datum/computer_type
	var/name

/datum/computer_type/proc/get_value(datum/computer_environment/environment, datum/node/ast, code)
	return

/datum/computer_type/string
	name = "STRING"

/datum/computer_type/string/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/datum/token/T = ast.element
	return T.string

/datum/computer_type/expression
	name = "EXPRESSION"

/datum/computer_type/expression/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/datum/token/T = ast.element
	return text2num(SET(T.string, environment, code))

/datum/computer_type/function
	name = "FUNCTION"

/datum/computer_type/function/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/datum/token/T = ast.element
	return T.string

/datum/computer_type/freq
	name = "FREQ"

/datum/computer_type/freq/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/val = global.computer_types["EXPRESSION"].get_value(environment, ast, code)
	return sanitize_frequency(val)

/datum/computer_type/code
	name = "CODE"

/datum/computer_type/code/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/val = global.computer_types["EXPRESSION"].get_value(environment, ast, code)
	return clamp(val, 1, 100)

/datum/computer_type/name
	name = "NAME"

/datum/computer_type/name/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/datum/token/T = ast.element
	return T.string

/datum/computer_type/stack
	name = "STACK"

/datum/computer_type/stack/get_value(datum/computer_environment/environment, datum/node/ast, code)
	var/datum/token/T = ast.element
	return T.string



/datum/computer_command
	var/name

/datum/computer_command/proc/get_value(datum/computer_environment/environment, datum/node/ast, index, val_type, code)
	var/datum/node/N = ast.children[index]

	return global.computer_types[val_type].get_value(environment, N, code)

/datum/computer_command/proc/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)

/datum/computer_command/register_signal
	name = "REGISTERSIGNAL_COMMAND"

/datum/computer_command/register_signal/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/function_name = src.get_value(environment, ast, 2, "FUNCTION", code)
	var/freq = src.get_value(environment, ast, 1, "FREQ", code)

	to_chat(world, "ADD CALLBACK ISSUED")

	environment.add_callback(function_name, freq)

/datum/computer_command/declare
	name = "DECLARE_COMMAND"

/datum/computer_command/declare/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/variable_name = src.get_value(environment, ast, 2, "NAME", code)
	var/value = src.get_value(environment, ast, 1, "EXPRESSION", code)

	environment.add_variable(variable_name, value)

/datum/computer_command/declarestack
	name = "DECLARESTACK_COMMAND"

/datum/computer_command/declarestack/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/stack_name = src.get_value(environment, ast, 1, "STACK", code)

	environment.add_stack(stack_name)

/datum/computer_command/functiondefinition
	name = "FUNCTIONDEFINITION_COMMAND"

/datum/computer_command/functiondefinition/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/function_name = src.get_value(environment, ast, 2, "FUNCTION", code)

	//to_chat(world, "FUNCTION DEFINITION OF [function_name]")

	environment.add_function(function_name)
	environment.set_declaring_function(function_name)

/datum/computer_command/function
	name = "FUNCTION_COMMAND"

/datum/computer_command/function/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/function_name = src.get_value(environment, ast, 3, "FUNCTION", code)
	var/_code = src.get_value(environment, ast, 2, "EXPRESSION", code)
	var/variable_name = src.get_value(environment, ast, 1, "NAME", code)

	environment.set_variable(variable_name, environment.call_function(function_name, _code))

/datum/computer_command/setcommand
	name = "SET_COMMAND"

/datum/computer_command/setcommand/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/variable_name = src.get_value(environment, ast, 2, "NAME", code)
	var/value = src.get_value(environment, ast, 1, "EXPRESSION", code)

	//var/datum/token/T = ast.children[1].element
	//to_chat(world, "GOT ([value]) from [T.string]")
	environment.set_variable(variable_name, value)

/datum/computer_command/signal
	name = "SIGNAL_COMMAND"

/datum/computer_command/signal/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/freq = src.get_value(environment, ast, 2, "FREQ", code)
	var/_code = src.get_value(environment, ast, 1, "EXPRESSION", code)

	computer.send_signal(freq, _code)

/datum/computer_command/print
	name = "PRINT_COMMAND"

/datum/computer_command/print/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/txt = src.get_value(environment, ast, 1, "STRING", code)

	computer.add_output(txt)

/datum/computer_command/output
	name = "OUTPUT_COMMAND"

/datum/computer_command/output/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	if(computer.output)
		computer.print(computer.output, "output", "notice")
		computer.output = null

/datum/computer_command/stackpush
	name = "STACKPUSH_COMMAND"

/datum/computer_command/stackpush/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/stack_name = src.get_value(environment, ast, 1, "STACK", code)
	var/value = src.get_value(environment, ast, 1, "EXPRESSION", code)

	var/datum/stack/stack = environment.get_stack(stack_name)
	if(!stack)
		return

	stack.Push(value)

/datum/computer_command/stackpop
	name = "STACKPOP_COMMAND"

/datum/computer_command/stackpop/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/stack_name = src.get_value(environment, ast, 2, "STACK", code)
	var/variable_name = src.get_value(environment, ast, 1, "NAME", code)

	var/datum/stack/stack = environment.get_stack(stack_name)
	if(!stack)
		return

	environment.set_variable(variable_name, stack.Pop())

/datum/computer_command/stackreverse
	name = "STACKREVERSE_COMMAND"

/datum/computer_command/stackreverse/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/stack_name = src.get_value(environment, ast, 1, "STACK", code)

	var/datum/stack/stack = environment.get_stack(stack_name)
	if(!stack)
		return

	stack.Reverse()

/datum/computer_command/returnif
	name = "RETURNIF_COMMAND"

/datum/computer_command/returnif/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/condition = src.get_value(environment, ast, 2, "EXPRESSION", code)
	var/return_value = src.get_value(environment, ast, 1, "EXPRESSION", code)

	if(condition)
		return list("HALT"=TRUE, "RETURN"=return_value)

/datum/computer_command/returncommand
	name = "RETURN_COMMAND"

/datum/computer_command/returncommand/execute(obj/machinery/computer/logistic_computer/computer, datum/computer_environment/environment, datum/node/ast, code)
	var/return_value = src.get_value(environment, ast, 1, "EXPRESSION", code)
	return list("HALT"=TRUE, "RETURN"=return_value)



/obj/machinery/computer/logistic_computer
	name = "logistic computer"
	icon_state = "computer_regular_stock"
	state_broken_preset = "computer_regularb"
	state_nopower_preset = "computer_regular0"

	var/datum/wires/wires

	var/static/list/possible_expressions
	var/static/list/possible_symbols
	var/static/list/possible_commands

	var/static/list/possible_statements

	var/static/list/possible_productions

	var/list/output
	var/list/debug
	var/list/errors

	var/datum/computer_environment/environment

	var/obj/item/weapon/paper/code

	var/list/datum/radio_frequency/radio_connections

/obj/machinery/computer/logistic_computer/atom_init()
	. = ..()

	environment = new(src)

	possible_expressions = list(
		//"integer" = regex("\[0-9\]"),
		"identifier" = regex("\[_a-z\]"),
		"command_or_function" = regex("\[A-Z\]"),
	)

	possible_symbols = list(
		/*
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
		*/
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
		"PRINT" = TRUE,
		"OUTPUT" = TRUE,

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
		"PRINT_COMMAND" = TRUE,
		"OUTPUT_COMMAND" = TRUE,
		"STACKPUSH_COMMAND" = TRUE,
		"STACKPOP_COMMAND" = TRUE,
		"STACKREVERSE_COMMAND" = TRUE,
		"FUNCTIONDEFINITION_COMMAND" = TRUE,
		"FUNCTION_COMMAND" = TRUE,
		"RETURNIF_COMMAND" = TRUE,
		"RETURN_COMMAND" = TRUE,
	)

	possible_productions = list(
		"REGISTERSIGNAL_COMMAND" = list(
			"REGISTERSIGNAL function expression" = TRUE,
		),
		"DECLARE_COMMAND" = list(
			"DECLARE identifier expression" = TRUE,
		),
		"DECLARESTACK_COMMAND" = list(
			"DECLARESTACK identifier" = TRUE,
		),

		"SET_COMMAND" = list(
			"SET identifier expression" = TRUE,
		),
		"SIGNAL_COMMAND" = list(
			"SIGNAL expression expression" = TRUE,
		),
		"PRINT_COMMAND" = list(
			"PRINT string" = TRUE,
		),
		"OUTPUT_COMMAND" = list(
			"OUTPUT" = TRUE,
		),

		"STACKPUSH_COMMAND" = list(
			"STACKPUSH identifier expression" = TRUE,
		),
		"STACKPOP_COMMAND" = list(
			"STACKPOP identifier identifier" = TRUE,
		),
		"STACKREVERSE_COMMAND" = list(
			"STACKREVERSE identifier" = TRUE,
		),

		"FUNCTIONDEFINITION_COMMAND" = list(
			"function definition" = TRUE,
		),

		"FUNCTION_COMMAND" = list(
			"function expression identifier" = TRUE,
		),
		"RETURNIF_COMMAND" = list(
			"RETURNIF expression expression" = TRUE,
		),
		"RETURN_COMMAND" = list(
			"RETURN expression" = TRUE
		),
	)

	/*
	var/test_expr = list(
		"50-2" = "48",
		"1 * 5" = "5",
		"sin(0)" = "0",
		"(4 - 2 * 5)" = "-6",
		"1459" = "1459",
	)
	for(var/expr in test_expr)
		to_chat(world, "[expr] = [SET(expr, environment, 0)] ([test_expr[expr]])")
	*/

	//var/expr = "var(\"code\")"
	//to_chat(world, "[expr] = [SET(expr, environment, 0)]")

	var/list/programs = list(
		"signal" = "SIGNAL '1457' '30'",
		"ping all" = "PREAMBLE:<br>\
			DECLARE nfreq '1441'<br>\
			DECLARE ncode '2'<br>\
			REGISTERSIGNAL NEXT '1441'<br>\
			<br>\
			GETNEXTFREQ:<br>\
			RETURNIF 'var(\"code\")  < 1489' 'var(\"code\") + 2'<br>\
			RETURN '1441'<br>\
			<br>\
			GETNEXTCODE:<br>\
			RETURNIF 'var(\"code\") < 100' 'var(\"code\") + 1'<br>\
			RETURN '2'<br>\
			<br>\
			NEXT:<br>\
			RETURNIF 'var(\"code\") != 1' '0'<br>\
			SIGNAL 'var(\"nfreq\")' 'var(\"ncode\")'<br>\
			GETNEXTCODE 'var(\"ncode\")' ncode<br>\
			RETURNIF 'var(\"ncode\" != 1)' '0'<br>\
			GETNEXTFREQ 'var(\"nfreq\")' nfreq"
	)

	for(var/program_name in programs)
		var/obj/item/weapon/paper/P = new(loc)
		P.name = program_name
		P.info = programs[program_name]
		P.update_icon()

	var/obj/item/device/assembly/signaler/onefourfourone/S1 = new(loc)
	S1.frequency = 1441
	S1.code = 1

	var/obj/item/device/assembly/signaler/onefourfourone/S2 = new(loc)
	S2.frequency = 1441
	S2.code = 3

/obj/item/device/assembly/signaler/onefourfourone
	frequency = 1441

/obj/machinery/computer/logistic_computer/Destroy()
	QDEL_NULL(environment)
	QDEL_NULL(code)
	return ..()

/obj/machinery/computer/logistic_computer/proc/register_freq(freq)
	if(!radio_controller)
		return

	//to_chat(world, "REGISTERING TO [freq]")

	LAZYSET(radio_connections, "[freq]", radio_controller.add_object(src, freq, RADIO_CHAT))

/obj/machinery/computer/logistic_computer/proc/unregister_freq(freq)
	if(!radio_controller)
		return

	radio_controller.remove_object(src, freq)

	LAZYREMOVE(radio_connections, "[freq]")

/obj/machinery/computer/logistic_computer/proc/send_signal(freq, code)
	if(!radio_controller)
		return

	var/needs_closing

	var/datum/radio_frequency/radio_connection = LAZYACCESS(radio_connections, freq)
	if(!radio_connection)
		needs_closing = TRUE
		radio_connection = radio_controller.add_object(src, freq, RADIO_CHAT)

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"

	radio_connection.post_signal(src, signal)

	if(needs_closing)
		radio_controller.remove_object(src, freq)

/obj/machinery/computer/logistic_computer/receive_signal(datum/signal/signal)
	if(!environment.callbacks)
		return

	to_chat(world, "RECEIVED [signal.frequency] [signal.encryption]")
	var/function_name = environment.callbacks["[signal.frequency]"]

	to_chat(world, "THERE IS A ([function_name]) TO CALL with code [signal.encryption]")

	environment.call_function(function_name, signal.encryption)

/obj/machinery/computer/logistic_computer/attack_hand(mob/user)
	if(code)
		halt()

	return ..()

/obj/machinery/computer/logistic_computer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper) && user.drop_from_inventory(I, src))
		run_code(I)
		return

	return ..()

/obj/machinery/computer/logistic_computer/proc/reset()
	if(!code)
		return

	code.forceMove(loc)
	code = null

	errors = null
	output = null

	environment.reboot()

/obj/machinery/computer/logistic_computer/proc/halt()
	if(output)
		print(output, "output", "notice")
	reset()

/obj/machinery/computer/logistic_computer/proc/crash()
	if(errors)
		print(errors, "error", "bold warning")
	reset()

/obj/machinery/computer/logistic_computer/proc/run_code(obj/item/weapon/paper/P)
	P.forceMove(src)
	code = P

	var/list/lines = splittext(P.info, "<br>")

	if(lines.len > COMPUTER_MAX_LINES)
		add_error("Too many lines ([lines.len]). Max is [COMPUTER_MAX_CHARACTERS_PER_LINE]")
		crash()
		return

	var/i = 0
	for(var/line in lines)
		var/line_length = length_char(line)
		if(line_length > COMPUTER_MAX_CHARACTERS_PER_LINE)
			add_error("Line [i] is too long ([line_length]). Max is [COMPUTER_MAX_CHARACTERS_PER_LINE]")
			crash()
			return

		if(!interpret(line))
			return
		i += 1

	environment.call_function("PREAMBLE", 0)

/obj/machinery/computer/logistic_computer/proc/interpret(txt)
	//to_chat(world, "INTERPRETING ([txt])")
	var/list/tokens = lexer(txt)

	/*
	var/i = 1
	for(var/datum/token/token in tokens)
		to_chat(world, "[i] [token.role] [token.string]")
	*/

	if(errors)
		crash()
		return FALSE

	if(!tokens.len)
		return TRUE

	var/datum/node/ast = parser(tokens)

	if(errors)
		crash()
		return FALSE

	interpreter(ast)

	if(errors)
		crash()
		return FALSE

	return TRUE

/obj/machinery/computer/logistic_computer/proc/print(list/messages, stream, span)
	var/obj/item/weapon/paper/P = new(loc)
	P.name = "output ([stream])"

	for(var/message in messages)
		P.info += "<span class='[span]'>[message]</span><br>"

	P.update_icon()
	P.forceMove(loc)

/obj/machinery/computer/logistic_computer/proc/add_debug(txt)
	LAZYADD(debug, txt)

/obj/machinery/computer/logistic_computer/proc/add_output(txt)
	LAZYADD(output, txt)

/obj/machinery/computer/logistic_computer/proc/add_error(txt)
	LAZYADD(errors, txt)

/obj/machinery/computer/logistic_computer/proc/scan_string(datum/peekablestream/stream, delimiter)
	var/retVal = ""
	var/found_delim = FALSE

	while(!stream.isEOF())
		var/lookahead = stream.consume(1)

		if(lookahead == delimiter)
			found_delim = TRUE
			break

		retVal += lookahead

	if(!found_delim)
		add_error("Encountered EOS while parsing string, expected [delimiter] instead.")
		return

	return retVal

/obj/machinery/computer/logistic_computer/proc/scan(datum/peekablestream/stream, first_char, regex/expression)
	var/retVal = first_char
	while(!stream.isEOF())
		var/lookahead = stream.peak(1)

		if(!expression.Find(lookahead))
			break

		stream.consume(1)

		retVal += lookahead

	return retVal

/obj/machinery/computer/logistic_computer/proc/lexer(txt)
	var/list/tokens = list()

	var/static/list/whitespace = list(
		" " = TRUE,
		//"\n" = TRUE,
	)

	var/static/list/string_delimeters = list(
		"\"" = TRUE,
	)

	var/static/list/expression_delimeters = list(
		"'" = TRUE,
	)

	var/datum/peekablestream/stream = new(splittext(txt, ""))

	while(!errors && !stream.isEOF())
		var/lookahead = stream.consume(1)

		//to_chat(world, "LOOKAHEAD: [lookahead]")

		if(whitespace[lookahead])
			continue

		if(string_delimeters[lookahead])
			tokens += new /datum/token(scan_string(stream, lookahead), "string")
			continue

		if(expression_delimeters[lookahead])
			tokens += new /datum/token(scan_string(stream, lookahead), "expression")
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

		add_error("Unexpected character: [lookahead]")

	return tokens

/obj/machinery/computer/logistic_computer/proc/parser_shift(datum/stack/stack, datum/token/lookahead)
	var/datum/node/N = new(
		lookahead
	)

	stack.Push(N)

	//to_chat(world, "SHIFTING ([lookahead.role]) [stack_to_string(stack)]")

/obj/machinery/computer/logistic_computer/proc/parser_reduce(datum/stack/stack, role, reduce_by, stack_string)
	var/datum/node/N = new(
		new /datum/token(stack_string, role)
	)

	for(var/i in 1 to reduce_by)
		var/datum/node/C = stack.Pop()

		N.add_child(C)

	stack.Push(N)

	//to_chat(world, "REDUCING ([role]) [stack_to_string(stack)]")

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
					if(findtextEx(production, stack_with_peak, 1, length(stack_with_peak) + 1))
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

	if(stack.is_empty())
		add_error("Parse finished with an empty parse stack")
		return

	var/datum/node/tree = stack.Pop()

	var/datum/token/token = tree.element
	if(!possible_statements[token.role])
		add_error("Parse finished with a token that is not a statement: [token.role]")

	if(!stack.is_empty())
		add_error("Parse finished with unconsumed tokens: [stack_to_string(stack)]")

	return tree

/obj/machinery/computer/logistic_computer/proc/interpreter(datum/node/ast)
	var/datum/token/command = ast.element

	if(environment.declaring_function && command.role != "FUNCTIONDEFINITION_COMMAND")
		//to_chat(world, "ADDING AN INSTRUCTION TO [environment.declaring_function]")
		environment.add_function_instruction(environment.declaring_function, ast)
		return

	//to_chat(world, "EXECUTING COMMAND [command.role]")
	environment.execute(ast, command.role)

#undef COMPUTER_MAX_CHARACTERS_PER_LINE
#undef COMPUTER_MAX_LINES
