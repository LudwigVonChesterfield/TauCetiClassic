var/const/SCRAP_BEACON_WIRE_ACTIVATE = 1

/datum/wires/scrap_beacon
	holder_type = /obj/structure/scrap_beacon
	wire_count = 3
	window_y = 240

/datum/wires/scrap_beacon/can_use()
	var/obj/structure/scrap_beacon/S = holder
	return S.panel_open

/datum/wires/scrap_beacon/update_cut(index, mended)
	var/obj/structure/scrap_beacon/S = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!S.can_activate())
				return
			S.activate()

/datum/wires/scrap_beacon/update_pulsed(index)
	var/obj/structure/scrap_beacon/S = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!S.can_activate())
				return
			S.activate()
