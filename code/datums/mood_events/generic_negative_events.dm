/datum/mood_event/self_tending
	description = "<span class='warning'>I had to tend my own wounds, is there nobody else to help me?</span>\n"
	mood_change = -3
	timeout = 1 MINUTE

/datum/mood_event/on_fire
	description = "<span class='boldwarning'>I'M ON FIRE!!!</span>\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "<span class='boldwarning'>CAN'T... BREATHE...</span>\n"
	mood_change = -12

/datum/mood_event/cold
	description = "<span class='warning'>It's way too cold in here.</span>\n"
	mood_change = -5

/datum/mood_event/hot
	description = "<span class='warning'>It's getting hot in here.</span>\n"
	mood_change = -5

/datum/mood_event/slipped
	description = "<span class='warning'>I slipped. I should be more careful next time...</span>\n"
	mood_change = -2
	timeout = 3 MINUTES
