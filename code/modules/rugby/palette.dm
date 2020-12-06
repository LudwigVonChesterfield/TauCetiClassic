/datum/action/palette_choice
	action_type = AB_INNATE

	var/choice_key
	var/choice_value

	var/datum/palette/palette

	var/active_background_icon_state = "default"
	var/unactive_background_icon_state

	var/active_button_icon_state = "bg_default"
	var/unactive_button_icon_state

/datum/action/palette_choice/New(datum/palette/palette)
	src.palette = palette

	if(!unactive_button_icon_state)
		unactive_button_icon_state = active_button_icon_state

	if(!unactive_background_icon_state)
		unactive_background_icon_state = active_background_icon_state

	button_icon_state = unactive_button_icon_state
	background_icon_state = unactive_background_icon_state

/datum/action/palette_choice/Destroy()
	palette = null
	return ..()

/datum/action/palette_choice/Activate(mob/living/user)
	palette.DeactivateAll()

	active = TRUE
	if(user)
		to_chat(user, "<span class='notice>You have activated [name].</span>")
	palette.SetKey(choice_key, choice_value)

	background_icon_state = active_background_icon_state
	button_icon_state = active_button_icon_state

	button.UpdateIcon()
	..()

/datum/action/palette_choice/Deactivate(mob/living/user)
	active = FALSE
	if(user)
		to_chat(user, "<span class='notice>You have deactivated [name].</span>")
	palette.UnsetKey(choice_key)

	background_icon_state = unactive_background_icon_state
	button_icon_state = unactive_button_icon_state

	button.UpdateIcon()
	..()

/datum/palette
	var/datum/component/remote_cursor/remote
	var/list/choices = list()

/datum/palette/New(datum/component/remote_cursor/remote, list/choices)
	src.remote = remote
	for(var/ch_type in choices)
		src.choices += new ch_type(src)

/datum/palette/Destroy()
	QDEL_LIST(choices)
	remote = null
	return ..()

/datum/palette/proc/DeactivateAll()
	for(var/datum/action/palette_choice/PL in choices)
		if(PL.active)
			PL.Deactivate()

/datum/palette/proc/Grant(mob/user)
	for(var/datum/action/palette_choice/PL in choices)
		PL.Grant(user)

/datum/palette/proc/Remove(mob/user)
	for(var/datum/action/palette_choice/PL in choices)
		PL.Remove(user)

/datum/palette/proc/SetKey(key, value)
	LAZYSET(remote.data, key, value)

/datum/palette/proc/UnsetKey(key)
	LAZYREMOVE(remote.data, key)
