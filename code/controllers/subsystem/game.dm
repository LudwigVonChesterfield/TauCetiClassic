var/global/datum/game/rugby/match

SUBSYSTEM_DEF(game)
	name = "Game"
	init_order = SS_INIT_GAME
	flags = SS_NO_FIRE

/datum/controller/subsystem/game/Initialize(timeofday)
	. = ..()
	match = new /datum/game/rugby()
