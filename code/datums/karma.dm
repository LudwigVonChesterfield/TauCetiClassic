/datum/karma
	var/mob/living/mob_parent

	var/karma
	var/shown_karma //This is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very positive.

	var/spirit = SPIRIT_NEUTRAL //Current spirit
	var/karma_level = 5 //To track what stage of karma they're on
	var/spirit_level = 2 //To track what stage of spirit they're on
	var/list/datum/karmatic_factor/karmatic_factors = list()
	var/atom/movable/screen/mood/screen_obj

/datum/karma/Initialize()
	if(!isliving(mob_parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSkarma, src)

	RegisterSignal(mob_parent, COMSIG_ENTER_AREA, PROC_REF(check_area_mood))
	RegisterSignal(mob_parent, COMSIG_LIVING_REJUVENATE, PROC_REF(on_revive))
	RegisterSignal(mob_parent, COMSIG_MOB_HUD_CREATED, PROC_REF(modify_hud))
	RegisterSignal(mob_parent, COMSIG_MOB_SLIP, PROC_REF(on_slip))

	mob_parent.become_area_sensitive(KARMA_TRAIT)
	if(mob_parent.hud_used)
		modify_hud()
		var/datum/hud/hud = mob_parent.hud_used
		hud.show_hud(hud.hud_version)

/datum/karma/Destroy()
	STOP_PROCESSING(SSkarma, src)
	REMOVE_TRAIT(mob_parent, TRAIT_AREA_SENSITIVE, KARMA_TRAIT)
	unmodify_hud()
	QDEL_LIST_ASSOC_VAL(karmatic_factors)
	return ..()

/datum/karma/proc/print_karma(mob/user)
	var/msg = "<span class='info'>*---------*\n<EM>My current mental status:</EM></span>\n"
	msg += "<span class='notice'>My current spirit: </span>" //Long term
	switch(spirit)
		if(SPIRIT_HIGH to INFINITY)
			msg += "<span class='nicegreen'>My mind feels like a temple!</span>\n"
		if(SPIRIT_NEUTRAL to SPIRIT_HIGH)
			msg += "<span class='nicegreen'>I have been feeling great lately!</span>\n"
		if(SPIRIT_DISTURBED to SPIRIT_NEUTRAL)
			msg += "<span class='nicegreen'>I have felt quite decent lately.</span>\n"
		if(SPIRIT_POOR to SPIRIT_DISTURBED)
			msg += "<span class='warning'>I haven't felt good in a while.</span>\n"
		if(SPIRIT_LOW to SPIRIT_POOR)
			msg += "<span class='boldwarning'>I'm feeling a bit down.</span>\n"
		if(SPIRIT_BAD to SPIRIT_LOW)
			msg += "<span class='boldwarning'>My mind feels like a wasteland of sadness.</span>\n"

	msg += "<span class='notice'>My current karma: </span>" //Short term
	switch(karma_level)
		if(1)
			msg += "<span class='boldwarning'>I feel terribly bad and not okay at all...</span>\n"
		if(2)
			msg += "<span class='boldwarning'>I feel terrible...</span>\n"
		if(3)
			msg += "<span class='boldwarning'>I feel very upset.</span>\n"
		if(4)
			msg += "<span class='boldwarning'>I'm a bit sad.</span>\n"
		if(5)
			msg += "<span class='nicegreen'>I'm alright.</span>\n"
		if(6)
			msg += "<span class='nicegreen'>I feel pretty okay.</span>\n"
		if(7)
			msg += "<span class='nicegreen'>I feel pretty good.</span>\n"
		if(8)
			msg += "<span class='nicegreen'>I feel amazing!</span>\n"
		if(9)
			msg += "<span class='nicegreen'>I love life!</span>\n"

	msg += "<span class='notice'>Karmatic Factors:</span>\n"
	if(karmatic_factors.len)
		for(var/datum/karmatic_factor/factor in karmatic_factors)
			msg += "- [event.description]\n"
	else
		msg += "<span class='notice'>I don't have much impacting my karma right now.\n</span>"
	to_chat(user, msg)

///Called after karmatic factors have been added/removed.
/datum/karma/proc/update_karma()
	karma = 0
	shown_karma = 0
	for(var/datum/karmatic_factor/factor as anything in karmatic_factors)
		karma += factor.karma_change
		if(!event.hidden)
			shown_karma += factor.karma_change

	switch(karma)
		if(-INFINITY to KARMA_LEVEL_SAD4)
			karma_level = 1
		if(KARMA_LEVEL_SAD4 to KARMA_LEVEL_SAD3)
			karma_level = 2
		if(KARMA_LEVEL_SAD3 to KARMA_LEVEL_SAD2)
			karma_level = 3
		if(KARMA_LEVEL_SAD2 to KARMA_LEVEL_SAD1)
			karma_level = 4
		if(KARMA_LEVEL_SAD1 to KARMA_LEVEL_HAPPY1)
			karma_level = 5
		if(KARMA_LEVEL_HAPPY1 to KARMA_LEVEL_HAPPY2)
			karma_level = 6
		if(KARMA_LEVEL_HAPPY2 to KARMA_LEVEL_HAPPY3)
			karma_level = 7
		if(KARMA_LEVEL_HAPPY3 to KARMA_LEVEL_HAPPY4)
			karma_level = 8
		if(KARMA_LEVEL_HAPPY4 to INFINITY)
			karma_level = 9
	update_karma_icon()
	update_karma_client_color()

/datum/karma/proc/update_karma_icon()
	if(!screen_obj)
		return

	if(!mob_parent.client)
		return

	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)

	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_factors = list()
	var/highest_absolute_mood = 0
	for(var/datum/karmatic_factor/factor as anything in karmatic_factors)
		if(!factor.special_screen_obj)
			continue

		if(!factor.special_screen_replace)
			screen_obj.add_overlay(factor.special_screen_obj)
		else
			conflicting_factors += factor
			var/absmood = abs(factor.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	switch(spirit_level)
		if(1)
			screen_obj.color = "#2eeb9a"
		if(2)
			screen_obj.color = "#86d656"
		if(3)
			screen_obj.color = "#4b96c4"
		if(4)
			screen_obj.color = "#dfa65b"
		if(5)
			screen_obj.color = "#f38943"
		if(6)
			screen_obj.color = "#f15d36"

	if(!conflicting_factors.len) //no special icons- go to the normal icon states
		screen_obj.icon_state = "mood[karma_level]"
		return

	for(var/datum/karmatic_factor/factor as anything in karmatic_factors)
		if(abs(factor.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[factor.special_screen_obj]"
			break

/datum/karma/proc/update_karma_client_color()
	var/mob/living/carbon/human/H = mob_parent
	if(!istype(H))
		return

	H.moody_color = null

	if(H.stat == DEAD)
		return

	if(spirit_level < 4)
		return

	var/dissapointment
	switch(spirit_level)
		if(6)
			dissapointment = 0.8
		if(5)
			dissapointment = 0.4
		if(4)
			dissapointment = 0.2

	H.moody_color = SADNESS_COLOR(dissapointment)

///Called on SSkarma process
/datum/karma/process(delta_time)
	if(mob_parent.stat == DEAD)
		return //updating spirit during death leads to people getting revived and being completely sad for simply being dead for a long time

	switch(karma_level)
		if(1)
			setSpirit(spirit - 0.3 * delta_time, SPIRIT_BAD)
		if(2)
			setSpirit(spirit - 0.15 * delta_time, SPIRIT_BAD)
		if(3)
			setSpirit(spirit - 0.1 * delta_time, SPIRIT_LOW)
		if(4)
			setSpirit(spirit - 0.05 * delta_time, SPIRIT_POOR)
		if(5)
			setSpirit(spirit, SPIRIT_POOR) //This makes sure that mood gets increased should you be below the minimum.
		if(6)
			setSpirit(spirit + 0.2 * delta_time, SPIRIT_POOR)
		if(7)
			setSpirit(spirit  +0.3 * delta_time, SPIRIT_POOR)
		if(8)
			setSpirit(spirit + 0.4 * delta_time, SPIRIT_NEUTRAL, SPIRIT_MAXIMUM)
		if(9)
			setSpirit(spirit + 0.6*  delta_time, SPIRIT_NEUTRAL, SPIRIT_MAXIMUM)

///Sets spirit to the specified amount and applies effects.
/datum/karma/proc/setSpirit(amount, minimum=SPIRIT_BAD, maximum=SPIRIT_HIGH)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if(amount > maximum)
		amount = min(spirit, amount)

	if(amount == spirit) //Prevents stuff from flicking around.
		return
	spirit = amount

	var/prev_spirit_level = spirit_level

	var/mob/living/master = parent
	switch(spirit)
		if(SPIRIT_BAD to SPIRIT_LOW)
			master.mood_additive_speed_modifier = 1.0
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 6
		if(SPIRIT_LOW to SPIRIT_POOR)
			master.mood_additive_speed_modifier = 0.5
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 5
		if(SPIRIT_POOR to SPIRIT_DISTURBED)
			master.mood_additive_speed_modifier = 0.25
			master.mood_multiplicative_actionspeed_modifier = 0.25
			spirit_level = 4
		if(SPIRIT_DISTURBED to SPIRIT_NEUTRAL)
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = 0.0
			spirit_level = 3
		if(SPIRIT_NEUTRAL + 1 to SPIRIT_HIGH + 1) //shitty hack but +1 to prevent it from responding to super small differences
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = -0.1
			spirit_level = 2
		if(SPIRIT_HIGH + 1 to INFINITY)
			master.mood_additive_speed_modifier = 0.0
			master.mood_multiplicative_actionspeed_modifier = -0.1
			spirit_level = 1
	update_karma_icon()
	update_karma_client_color()

	if(spirit_level > prev_spirit_level)
		to_chat(parent, "<span class='warning'>Ваше настроение ухудшилось.</span>")
	if(spirit_level < prev_spirit_level)
		to_chat(parent, "<span class='notice'>Ваше настроение улучшилось.</span>")

// Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
/datum/karma/proc/add_karmatic_factor(id, type, ...)
	SIGNAL_HANDLER

	var/datum/karmatic_factor/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)
			return //Don't have to update the event.

	var/list/params = args.Copy(4)
	params.Insert(1, parent)
	the_event = new type(arglist(params))

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

	mood_events = sortTim(mood_events, cmp=GLOBAL_PROC_REF(cmp_abs_mood_dsc), associative=TRUE)

/datum/karma/proc/clear_event(id)
	SIGNAL_HANDLER

	var/datum/karmatic_factor/event = mood_events[category]
	if(!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

// Removes all temp factors
/datum/karma/proc/remove_temp_moods()
	for(var/i in mood_events)
		var/datum/karmatic_factor/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
	update_mood()

/datum/karma/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	screen_obj.color = "#4b96c4"
	screen_obj.add_to_hud(hud)

	RegisterSignal(hud, COMSIG_PARENT_QDELETING, PROC_REF(unmodify_hud))
	RegisterSignal(screen_obj, COMSIG_CLICK, PROC_REF(hud_click))

	update_mood_icon()
	update_mood_client_color()

/datum/karma/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!screen_obj)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj.remove_from_hud(hud)
	QDEL_NULL(screen_obj)

/datum/karma/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != parent)
		return
	print_mood(user)

/datum/karma/proc/check_area_mood(datum/source, area/A, atom/OldLoc)
	SIGNAL_HANDLER

	update_beauty(A)
	if(A.mood_bonus && (!A.mood_trait || HAS_TRAIT(source, A.mood_trait)))
		add_karmatic_factor("area", /datum/karmatic_factor/area, A.mood_bonus, A.mood_message)
	else
		clear_karmatic_factor("area")

/datum/karma/proc/update_beauty(area/A)
	SIGNAL_HANDLER

	//if we're outside, we don't care.
	if(A.outdoors)
		clear_karmatic_factor("area_beauty")
		return FALSE

	switch(A.beauty)
		if(-INFINITY to BEAUTY_LEVEL_HORRID)
			add_karmatic_factor("area_beauty", /datum/karmatic_factor/horridroom)
		if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
			add_karmatic_factor("area_beauty", /datum/karmatic_factor/badroom)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
			clear_karmatic_factor("area_beauty")
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_karmatic_factor("area_beauty", /datum/karmatic_factor/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_karmatic_factor("area_beauty", /datum/karmatic_factor/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_karmatic_factor("area_beauty", /datum/karmatic_factor/greatroom)

///Called when parent is ahealed.
/datum/karma/proc/on_revive(datum/source)
	SIGNAL_HANDLER

	remove_temp_moods()
	setSpirit(initial(spirit))

///Causes direct drain of someone's spirit, call it with a numerical value corresponding how badly you want to hurt their spirit
/datum/karma/proc/direct_spirit_drain(datum/source, amount)
	SIGNAL_HANDLER

	setSpirit(spirit + amount)

///Called when parent slips.
/datum/karma/proc/on_slip(datum/source)
	SIGNAL_HANDLER

	add_karmatic_factor("slipped", /datum/karmatic_factor/slipped)
