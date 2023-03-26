#define ROUTE_ERROR(code, message) list("status" = "error", "data" = null, "code" = code, "message" = message)
#define ROUTE_SUCCESS(data) list("status" = "success", "data" = data, "message" = null)

/proc/_ckey(t)
	return ckey(t)

/proc/_optional(datum/callback/param_type, default, value)
	if(value == null)
		return default

	return param_type.Invoke(value)

/proc/_sanitize_integer(min, max, default, value)
	return sanitize_integer(text2num(value), min, max, default)

/proc/_route(datum/callback/proc_to_call, params, packed_data)
	var/list/proc_params = list()

	for(var/param in params)
		var/value = packed_data[param]
		var/datum/callback/param_type = params[param]

		var/sanitized_value = param_type.Invoke(value)

		// Error: Required Param Missing.
		if(sanitized_value == null)
			return ROUTE_ERROR(422, "Parameter [param] is empty or unprocessable, but is required by this route.")

		if(islist(sanitized_value) && sanitized_value["status"] == "error")
			return sanitized_value

		proc_params += sanitized_value

	return proc_to_call.Invoke(arglist(proc_params))

#define INTEGER_PARAM(min, max, default) (CALLBACK(GLOBAL_PROC, .proc/_sanitize_integer, min, max, default))
#define STRING_PARAM (CALLBACK(GLOBAL_PROC, .proc/sanitize_text))
#define CKEY_PARAM (CALLBACK(GLOBAL_PROC, .proc/_ckey))

#define OPTIONAL_PARAM(param_type) CALLBACK(GLOBAL_PROC, .proc/_optional, param_type, default)

#define ROUTE(proc_to_call, params) (CALLBACK(GLOBAL_PROC, .proc/_route, CALLBACK(GLOBAL_PROC, .proc/##proc_to_call), params))
