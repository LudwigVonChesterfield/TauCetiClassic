/datum/karmatic_factor/naked
	description = "<span class='warning'>I am naked... And the worst part, people are noticing it!</span>"
	mood_change = -10
	timeout = 1 MINUTE

/datum/karmatic_factor/dirty_clothes
	description = "<span class='warning'>I don't like wearing dirty clothes...</span>"
	mood_change = -1

/datum/karmatic_factor/dirty_clothes/add_effects(_mood_change)
	mood_change = _mood_change

/datum/karmatic_factor/wet_clothes
	description = "<span class='warning'>I don't like wearing wet clothes...</span>"
	mood_change = -1

/datum/karmatic_factor/wet_clothes/add_effects(_mood_change)
	mood_change = _mood_change

// ipc and other synths
/datum/karmatic_factor/dangerous_clothes
	description = "<span class='warning'>I am pretty sure these wet clothes are dangerous to me...</span>"
	mood_change = -2

/datum/karmatic_factor/dangerous_clothes/add_effects(_mood_change)
	mood_change = _mood_change

// skrells and dionaea I guess
/datum/karmatic_factor/refreshing_clothes
	description = "<span class='nicegreen'>Ah yes, nothing better than refreshing, wet clothes!</span>"
	mood_change = 1

/datum/karmatic_factor/refreshing_clothes/add_effects(_mood_change)
	mood_change = _mood_change

/datum/karmatic_factor/slipped
	description = "<span class='warning'>I slipped. I should be more careful next time...</span>"
	mood_change = -2
	timeout = 3 MINUTES

/datum/karmatic_factor/self_tending
	description = "<span class='warning'>I had to tend my own wounds, is there nobody else to help me?</span>"
	mood_change = -3
	timeout = 1 MINUTE

/datum/karmatic_factor/depression
	description = "<span class='boldwarning'>I feel bad for no apparent reason. My life sucks...</span>"
	mood_change = -6

/datum/karmatic_factor/puke
	description = "<span class='warning'>I puked. Gross!</span>"
	mood_change = -3
	timeout = 5 MINUTES

/datum/karmatic_factor/scared
	description = "<span class='warning'>I'm scared.</span>"
	mood_change = -2
	timeout = 1 MINUTE
