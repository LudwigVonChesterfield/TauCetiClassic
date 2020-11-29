/datum/action/palette_choice
	var/choice_key
	var/choice_value

	var/datum/palette/palette

	var/active_background_icon_state = "default"
	var/unactive_background_icon_state = "default"

	var/active_button_icon_state = "bg_default"
	var/unactive_button_icon_state = "bg_default"

/datum/action/palette_choice/New(datum/palette/palette)
	src.palette = palette

/datum/action/palette_choice/Destroy()
	palette = null
	return ..()

/datum/action/palette_choice/Activate()
	active = TRUE
	palette.SetKey(choice_key, choice_value)

	background_icon_state = active_background_icon_state
	button_icon_state = active_button_icon_state

	button.UpdateIcon()
	..()

/datum/action/palette_choice/Deactivate()
	active = FALSE
	palette.UnsetKey(choice_key)

	background_icon_state = unactive_background_icon_state
	button_icon_state = unactive_button_icon_state

	button.UpdateIcon()
	..()

/datum/palette
	var/datum/component/remote_cursor/remote
	var/list/choices = list()

/datum/palette/New(list/choices)
	for(var/ch_type in choices)
		choices += new ch_type(src)

/datum/palette/Destroy()
	QDEL_LIST(choices)
	remote = null
	return ..()

/datum/palette/proc/Grant(mob/user)
	for(var/datum/action/palette_choice/PL in choices)
		PL.Grant(user)

/datum/palette/proc/Remove(mob/user)
	for(var/datum/action/palette_choice/PL in choices)
		PL.Remove(user)

/datum/palette/proc/SetKey(key, value)
	remote.data[key] = value

/datum/palette/proc/UnsetKey(key)
	remote.data -= key
