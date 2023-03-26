/world/Topic(T, addr, master, key)
	var/list/packet_data = params2list(T)

	var/route = packet_data["route"]
	if(!route)
		return ..()

	var/datum/callback/router = global.routes[route]
	if(router)
		var/list/response_data = router.Invoke(packet_data)
		if(!response_data)
			return json_encode(ROUTE_ERROR(500, "Router did not return any data."))

		return json_encode(response_data)

	return ..()
