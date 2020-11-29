/mob/verb/to_the_pitch()
	set name = "Teleport to the Pitch"
	set category = "Event"

	var/list/T = get_area_turfs(/area/rugby/pitch)
	forceMove(pick(T))

/mob/living/verb/mob_equip_class_gear()
	set name = "Equip class"
	set category = "Event"
	set src in view(7)

	var/chosen_class = input(usr, "Please choose a class to be equipped with.") as null|anything in inventory_crates_by_class
	if(!chosen_class)
		return

	for(var/obj/item/I in src)
		qdel(I)

	equip_class_gear(src, chosen_class)

/mob/living/verb/create_team_tablet()
	set name = "Create Team Tablet"
	set category = "Event"

	var/list/options = list()
	for(var/team_name in match.teams)
		var/datum/team/T = match.teams[team_name]
		var/repr = team_name
		if(T.role)
			repr += " "
			repr += "([T.role])"
		options[repr] = T

	var/team_name = input(usr, "Choose a team.") as null|anything in options
	if(!team_name)
		return

	var/datum/team/T = options[team_name]

	var/obj/item/device/coach_tablet/CT = new /obj/item/device/coach_tablet(loc)
	CT.team = T
	CT.icon_state = T.tablet_icon_state
	CT.name = "[CT.name] ([T.name])"

	put_in_hands(CT)

/mob/living/verb/start_match()
	set name = "Start Match"
	set category = "Event"

	match.setup()
