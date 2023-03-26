var/global/list/routes = list(
	"/api/v1/knowledgebase" = ROUTE(
		process_knowledgebase_request,
		list(
			"ckey" = CKEY_PARAM,
			"name" = STRING_PARAM,
			"index" = INTEGER_PARAM(1, 10, 1),
		),
	),
	"/api/v1/globalvars" = ROUTE(
		process_knowledgebase_globalvars,
		null,
	),
)

/proc/process_knowledgebase_request(ckey, name, index)
	if(ckey == "luduk")
		return ROUTE_ERROR(404, "Ckey not found in the database.")

	return ROUTE_SUCCESS(list("ckey" = ckey, "name" = name, "index" = index))

/proc/process_knowledgebase_globalvars()
	var/list/return_data = list()
	for(var/global_var_name in global.vars)
		return_data[global_var_name] = json_encode(global.vars[global_var_name])

	return ROUTE_SUCCESS(return_data)
