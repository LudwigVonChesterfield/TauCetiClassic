/datum/game
	var/list/teams

/datum/game

/datum/game/proc/add_team(datum/team/T)
	LAZYSET(teams, T.name, T)

/datum/game/proc/setup()

/datum/game/proc/tick()

/datum/game/proc/end()



// When a game is not even beggining to play.
#define GS_NONE "none"
// When teams are not ready.
#define GS_POSITIONAL_PLANNING "positional_planning"
#define GS_COMPOSITION_CHOOSING "composition_choosing"
// When teams are ready. Coin toss, etc.
#define GS_SETUP "setup"
// When a Kickoff is occuring.
#define GS_KICKOFF "kickoff"
// Play itself.
#define GS_PLAY "play"

/datum/game/rugby
	var/datum/team/red
	var/datum/team/blue

	var/red_ready = FALSE
	var/blue_ready = FALSE

	var/state = GS_NONE

	var/list/player_tablets

/datum/game/rugby/New()
	load_teams()

/datum/game/rugby/setup()
	choose_teams()

	step_positional_planning()

/datum/game/rugby/proc/can_ready_up()
	switch(state)
		if(GS_POSITIONAL_PLANNING)
			return TRUE
		if(GS_COMPOSITION_CHOOSING)
			return TRUE

	return FALSE

/datum/game/rugby/proc/next_step()
	switch(state)
		if(GS_POSITIONAL_PLANNING)
			step_composition_choosing()
		if(GS_COMPOSITION_CHOOSING)
			step_setup()

/datum/game/rugby/proc/step_positional_planning()
	state = GS_POSITIONAL_PLANNING

	spawn_coaches()

/datum/game/rugby/proc/step_composition_choosing()
	state = GS_COMPOSITION_CHOOSING

	player_tablets = list()

	for(var/team_name in teams)
		var/datum/team/T = teams[team_name]
		for(var/datum/player/P in T.players)
			var/obj/item/device/player_tablet/PT = new /obj/item/device/player_tablet(P.model.loc)

			PT.team = T
			PT.icon_state = T.tablet_icon_state
			PT.name = "[PT.name] ([T.name])"

			player_tablets += PT

			P.model.put_in_hands(PT)
			if(P.model.client)
				PT.grant_control(P.model)

/datum/game/rugby/proc/step_setup()
	state = GS_SETUP

	for(var/PT in player_tablets)
		qdel(PT)
	player_tablets = null

/datum/game/rugby/proc/choose_teams()
	var/list/options = list() + teams

	var/red_name = pick(options)
	options -= red_name

	var/blue_name = pick(options)

	choose_red(teams[red_name])
	choose_blue(teams[blue_name])

/datum/game/rugby/proc/spawn_coaches()
	for(var/team_name in teams)
		var/datum/team/T = teams[team_name]
		T.spawn_coach()

/datum/game/rugby/proc/spawn_player(datum/team/T, datum/player/P)
	for(var/O in landmarks_list)
		var/obj/effect/landmark/rugby/R = O
		if(!istype(R))
			continue

		if(R.name != "Team Member Spawn")
			continue
		if(R.team != T.role)
			continue
		if(R.data["Player"] != P.number)
			continue

		P.model.forceMove(get_turf(R))

		var/obj/structure/closet/C
		for(var/d in cardinal)
			var/turf/target = get_step(R, d)
			C = locate(/obj/structure/closet) in target
			if(C)
				break

		strip_to_closet(P.model, C)
		equip_class_gear(P.model, T.default_class)

/datum/game/rugby/proc/spawn_players()
	for(var/O in landmarks_list)
		var/obj/effect/landmark/rugby/R = O

		if(R.name == "Team Member Spawn")
			var/datum/team/T
			for(var/team_name in teams)
				var/datum/team/team = teams[team_name]
				if(team.role == R.team)
					T = team

			if(!T)
				continue

			var/datum/player/P = T.get_player_num(R.data["Player"])
			if(!P)
				continue
			P.model.forceMove(get_turf(R))

			var/obj/structure/closet/C
			for(var/d in cardinal)
				var/turf/target = get_step(R, d)
				C = locate(/obj/structure/closet) in target
				if(C)
					break

			strip_to_closet(P.model, C)
			equip_class_gear(
				P.model, T.class_name_to_loadout[P.class]
			)

/datum/game/rugby/proc/load_teams()
	var/list/team_names = list(
		"A B C" = "pda-j",
		"Testing Testifiers" = "pda-s",
		//"Whateverevers" = "pda-e"
	)

	for(var/team_name in team_names)
		var/datum/team/T = new /datum/team
		T.name = team_name
		T.tablet_icon_state = team_names[team_name]
		add_team(T)

/datum/game/rugby/proc/choose_red(datum/team/T)
	T.role = "red"
	T.default_class = "Generic Red"

	T.class_name_to_loadout = list(
		"lineman" = "Red Lineman",
		"blitzer" = "Red Blitzer",
		"catcher" = "Red Catcher",
		"thrower" = "Red Thrower"
	)

	red = T

/datum/game/rugby/proc/unchoose_red()
	red.role = null
	red = null

/datum/game/rugby/proc/choose_blue(datum/team/T)
	T.role = "blue"
	T.default_class = "Generic Blue"

	T.class_name_to_loadout = list(
		"lineman" = "Blue Lineman",
		"blitzer" = "Blue Blitzer",
		"catcher" = "Blue Catcher",
		"thrower" = "Blue Thrower"
	)

	blue = T

/datum/game/rugby/proc/unchoose_blue()
	blue.role = null
	blue = null
