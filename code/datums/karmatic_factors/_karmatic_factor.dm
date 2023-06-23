/datum/karmatic_factor
	var/id // Id to clear the event
	var/description ///For descriptions, use the span classes boldnicegreen, nicegreen, notice, warning and boldwarning in order from great to horrible.
	var/mood_change = 0
	var/timeout = 0
	var/hidden = FALSE//Not shown on examine
	var/category // Must be set for all factors. see __DEFINES/karma.dm
	var/special_screen_obj //if it isn't null, it will replace or add onto the mood icon with this (same file). see happiness drug for example
	var/special_screen_replace = TRUE //if false, it will be an overlay instead
	var/mob/owner

/datum/karmatic_factor/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	add_effects(arglist(params))

/datum/karmatic_factor/Destroy()
	remove_effects()
	owner = null
	return ..()

/datum/karmatic_factor/proc/add_effects(param)
	return

/datum/karmatic_factor/proc/remove_effects()
	return
