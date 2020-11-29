var/global/datum/game/rugby/match = new /datum/game/rugby()

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

/datum/game/rugby/New()
	load_teams()

/datum/game/rugby/setup()
	state = GS_POSITIONAL_PLANNING

	choose_teams()
	spawn_players()

/datum/game/rugby/proc/choose_teams()
	var/list/options = list() + teams

	var/red_name = pick(options)
	options -= red_name

	var/blue_name = pick(options)

	choose_red(teams[red_name])
	choose_blue(teams[blue_name])

/datum/game/rugby/proc/spawn_coaches()
	state = GS_POSITIONAL_PLANNING

	for(var/O in landmarks_list)
		var/obj/effect/landmark/rugby/R = O

		if(R.name == "Coach Spawn")
			if(istype(R, red.landmark_type))
				if(red.coach)
					red.coach.forceMove(get_turf(R))
			else if(istype(R, blue.landmark_type))
				if(blue.coach)
					blue.coach.forceMove(get_turf(R))

/datum/game/rugby/proc/spawn_players()
	state = GS_COMPOSITION_CHOOSING

	for(var/O in landmarks_list)
		var/obj/effect/landmark/rugby/R = O

		if(R.name == "Team Member Spawn")
			var/datum/team/T
			if(istype(R, red.landmark_type))
				T = red
			else if(istype(R, blue.landmark_type))
				T = blue

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
			equip_class_gear(P.model, T.default_class)

/datum/game/rugby/proc/load_teams()
	var/list/team_names = list(
		"A B C" = "pda-j",
		"Testing Testifiers" = "pda-s",
		"Whateverevers" = "pda-e"
	)

	for(var/team_name in team_names)
		var/datum/team/T = new /datum/team
		T.name = team_name
		T.tablet_icon_state = team_names[team_name]
		add_team(T)

/datum/game/rugby/proc/choose_red(datum/team/T)
	T.landmark_type = /obj/effect/landmark/rugby/red
	T.role = "red"
	T.default_class = "Generic Red"
	red = T

/datum/game/rugby/proc/unchoose_red()
	red.landmark_type = null
	red = null

/datum/game/rugby/proc/choose_blue(datum/team/T)
	T.landmark_type = /obj/effect/landmark/rugby/blue
	T.role = "blue"
	T.default_class = "Generic Blue"
	blue = T

/datum/game/rugby/proc/unchoose_blue()
	blue.landmark_type = null
	blue = null
