/obj/item/spell
	name = "this spell name doesn't exist"
	var/full_name // Is used in sprays, for spell books.

	var/category = "Miscellaneous"

	var/additional_delay = 0
	var/mana_cost = 0
	// var/obj/item/weapon/wand/holder
	// Whether this spell does not cause the next_mod -> cur_mod cycle.
	var/stackable = FALSE

	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "spell_words"
	item_state = "paper"

	var/last_cast = 0

	var/spell_icon
	var/spell_icon_state

	var/has_passive = FALSE
	var/passive_cast_delay = 0

	var/list/spell_sounds

	// You can set these manually, or you can let the randomized rune system to do it for you.
	var/spell_invocation = "whisper"
	var/spell_word
	var/spell_color

	var/cast_light = TRUE
	var/spell_light_range = 1.0
	var/spell_light_power = 1.0
	var/spell_light_time_to_live = 1 SECOND

	var/on_trigger_cast_type = WAND_COMP_OTHERSCAST

	// Whether the timer event is issue in before_cast proc or not.
	// Projectiles don't do this, since we want timer to be cast "from" projectile.
	var/timer_before_cast = TRUE

	var/can_be_crafted = TRUE

/obj/item/spell/atom_init()
	. = ..()
	if(spell_components_slots > 0)
		storage_ui = new /datum/storage_ui/wands(src, spell_components, spell_components_slots)

	init_setup_ui()

	for(var/comp_type in spawn_with_component_types)
		var/obj/item/spell/spell_component/SC = new comp_type(null)
		add_spell_component(SC)

	set_spell_params()
	set_full_name()
	update_icon()

/obj/item/spell/Destroy()
	QDEL_LIST(spell_components)
	QDEL_NULL(storage_ui)

	QDEL_LIST(entries)
	return ..()

/obj/item/spell/proc/get_caster(atom/casting_obj)
	if(ismob(casting_obj))
		return casting_obj
	else if(istype(casting_obj, /obj/item/projectile))
		var/obj/item/projectile/P = casting_obj
		return P.firer
	else if(istype(casting_obj, /obj/item) && ismob(casting_obj.loc))
		return casting_obj.loc
	else if(istype(casting_obj, /obj/effect/decal/chempuff))
		var/obj/effect/decal/chempuff/C = casting_obj
		if(ismob(C.created_by))
			return C.created_by
	return null

/obj/item/spell/get_light_top()
	if(istype(loc, /obj/item/weapon/wand))
		return loc.loc
	if(!ismovableatom(loc))
		return src
	return loc

/obj/item/spell/proc/set_full_name()
	full_name = name

/obj/item/spell/proc/get_key_words()
	return list(name)

/obj/item/spell/proc/get_runes_for(sent)
	sent = lowertext(sent)

	var/runes = ""
	var/list/rune_list = list()
	var/prev_rune

	var/list/words = splittext(sent, " ")

	var/list/spell_cols = list()

	var/i = 1
	for(var/word in words)
		var/word_len = length(word)
		if(word_len <= 0)
			runes += global.letter_to_rune["NONE"]
			if(i != words.len)
				runes += "`"
			continue

		var/list/symbols_to_convert = list(copytext(word, 1, 2))
		if(word_len > 1)
			symbols_to_convert += copytext(word, word_len, word_len + 1)

		var/j = 1
		for(var/symbol in symbols_to_convert)
			var/rune
			if(global.letter_to_rune[symbol])
				rune = global.letter_to_rune[symbol]
			else
				rune = global.letter_to_rune["OTHER"]
			if(rune == prev_rune)
				rune = global.letter_to_rune["NOREPEAT"]
			runes += rune
			rune_list += rune
			prev_rune = rune

			spell_cols += global.rune_to_color[rune]

			if(i != words.len || j != symbols_to_convert.len)
				runes += "`"
			j++

		if(i != words.len)
			var/none_rune = global.letter_to_rune["NONE"]
			runes += none_rune
			rune_list += none_rune
			runes += "`"
			spell_cols += global.rune_to_color[none_rune]
		i++

	var/retCol = mix_colors(spell_cols)
	return list("spell_runes"=runes, "spell_color"=retCol, "runes"=rune_list)

/obj/item/spell/proc/set_spell_params()
	if(name == "this spell name doesn't exist")
		return

	if(spell_word || !can_be_crafted)
		return

	var/list/key_words = get_key_words()
	var/hash = ""
	for(var/key in key_words)
		hash += key

	if(global.spell_word_by_hash[hash])
		spell_word = global.spell_word_by_hash[hash]
		spell_color = global.spell_color_by_hash[hash]

		if(!(type in global.spell_types_by_spell_word[spell_word]))
			if(global.spell_types_by_spell_word[spell_word])
				global.spell_types_by_spell_word[spell_word] += type
			else
				global.spell_types_by_spell_word[spell_word] = list(type)
	else
		var/rune_colors = list()
		var/rune_word = ""
		var/sent_to_use = ""

		var/i = 1
		for(var/sent in key_words)
			sent_to_use += sent
			if(i != key_words.len)
				sent_to_use += " "

		var/list/rune_obj = get_runes_for(sent_to_use)
		rune_word += rune_obj["spell_runes"]
		rune_colors += rune_obj["spell_color"]

		rune_word = capitalize(rune_word)

		spell_word = copytext(rune_word, 1, MAX_MESSAGE_LEN)
		spell_color = mix_colors(rune_colors)

		global.spell_color_by_hash[hash] = spell_color
		global.spell_word_by_hash[hash] = spell_word

		global.runes_by_spell_word[spell_word] = rune_obj["runes"]

		if(global.spell_types_by_spell_word[spell_word])
			global.spell_types_by_spell_word[spell_word] += type
		else
			global.spell_types_by_spell_word[spell_word] = list(type)

/obj/item/spell/update_icon()
	overlays.Cut()
	var/image/I = image(icon=spell_icon, icon_state=spell_icon_state)
	I.loc = src
	var/matrix/M = matrix()
	M.Scale(0.5)
	I.transform = M
	overlays += I

/obj/item/spell/examine(mob/user)
	..()
	if(has_passive)
		to_chat(user, "<span class='info'>Has a passive interaction.</span>")
	to_chat(user, "<span class='info'>Is [stackable ? "stackable" : "not stackable"]</span>")
	if(mana_cost != 0.0)
		to_chat(user, "<span class='info'>Would cost you <b>[mana_cost]</b> mana.</span>")
	if(additional_delay != 0.0)
		to_chat(user, "<span class='info'>Would [additional_delay > 0.0 ? "<span class='warning'>add <b>[abs(additional_delay / 10.0)]</b></span>" : "remove <b>[abs(additional_delay / 10.0)]</b>"] seconds of spell-cast delay.</span>")
	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		to_chat(user, "<span class='info'>Upon collision, attempts to cast another spell from thy wand.</span>")

/obj/item/spell/proc/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ""
	if(has_passive)
		dat += "Has a passive interaction.<BR>"
	dat += "Is [stackable ? "stackable" : "not stackable"]<BR>"
	if(mana_cost != 0.0)
		dat += "Would cost you <b>[mana_cost]</b> mana per cast.<BR>"
	if(additional_delay != 0.0)
		dat += "Would [additional_delay > 0.0 ? "<font color='red'>add <b>[additional_delay * 0.1]</b></font>" : "remove <b>[-additional_delay * 0.1]</b>"] seconds of spell-cast delay.<BR>"
	if(compatible_flags[WAND_SPELL_TRIGGER_ON_IMPACT] || compatible_flags[WAND_SPELL_TRIGGER_ON_STEP])
		dat += "Is compatible with trigger component.<BR>"
	if(compatible_flags[WAND_SPELL_TIMER])
		dat += "Is compatible with timer component.<BR>"
	return dat

/obj/item/spell/Moved(atom/OldLoc, Dir)
	. = ..()
	if(.)
		if(istype(OldLoc, /obj/item/weapon/wand))
			var/obj/item/weapon/wand/W = OldLoc
			W.spells -= src
			if(has_passive)
				W.passive_spells -= src
				if(W.passive_spells.len == 0)
					W.passive_spells = null
			W.spells_queue.Remove(src)
			W.needs_reload = TRUE
		else if(istype(OldLoc, /obj/item/spell/continuous))
			var/obj/item/spell/continuous/C = OldLoc
			C.spell_components -= src
			if(istype(C.loc, /obj/item/weapon/wand))
				var/obj/item/weapon/wand/W = C.loc
				W.needs_reload = TRUE

		if(istype(loc, /obj/item/weapon/wand))
			var/obj/item/weapon/wand/W = loc
			W.spells += src
			if(has_passive)
				if(W.passive_spells)
					W.passive_spells += src
				else
					W.passive_spells = list(src)
			W.needs_reload = TRUE
		else if(istype(loc, /obj/item/spell/continuous))
			var/obj/item/spell/continuous/C = loc
			C.spell_components += src
			if(istype(C.loc, /obj/item/weapon/wand))
				var/obj/item/weapon/wand/W = C.loc
				W.needs_reload = TRUE

/obj/item/spell/proc/spell_can_cast(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, spend_mana=TRUE)
	if(spend_mana)
		var/tots_mana_cost = mana_cost * targets.len
		tots_mana_cost *= cur_mod.mult_mana_cost
		tots_mana_cost += cur_mod.add_mana_cost

		var/use_mana_retval = holder.use_mana(tots_mana_cost)
		if(use_mana_retval == WAND_SUCCESS)
			return TRUE

		if(use_mana_retval == WAND_NOT_ENOUGH_MANA && ismob(casting_obj))
			to_chat(casting_obj, "<span class='warning'>Not enough mana to cast [src]!</span>")
		return FALSE
	return TRUE

/obj/item/spell/proc/before_cast(cast_type, obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(spell_word && ismob(casting_obj))
		var/mob/M = casting_obj
		switch(spell_invocation)
			if("shout")
				M.say(spell_word)
			if("whisper")
				M.whisper(spell_word)

	if(spell_sounds)
		playsound(casting_obj, pick(spell_sounds), VOL_EFFECTS_MASTER)

	if(spell_color && cast_light)
		var/new_spell_light_range = spell_light_range * cur_mod.mult_power + cur_mod.add_power
		var/new_spell_light_power = spell_light_power * cur_mod.mult_power + cur_mod.add_power
		set_light(new_spell_light_range, new_spell_light_power, spell_color)
		addtimer(CALLBACK(src, /atom.proc/set_light, 0), spell_light_time_to_live)

	if(timer_before_cast)
		issue_event(WAND_SPELL_TIMER, holder, casting_obj, targets, cur_mod.get_copy(), next_mod.get_copy())

/obj/item/spell/proc/after_cast(cast_type, obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	return

/obj/item/spell/proc/cast(cast_type, obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod, i=1)
	var/datum/spell_modifier/pass_cur_mod = cur_mod
	if(!stackable)
		pass_cur_mod = next_mod

	before_cast(cast_type, holder, casting_obj, targets, pass_cur_mod, next_mod)
	switch(cast_type)
		if(WAND_COMP_SELFCAST)
			spell_selfcast(holder, casting_obj, pass_cur_mod, next_mod)
		if(WAND_COMP_OTHERSCAST)
			for(var/atom/target in targets)
				target = cur_mod.apply_dir_effects(target, casting_obj, i)
				spell_otherscast(holder, casting_obj, target, pass_cur_mod, next_mod)
		if(WAND_COMP_AREACAST)
			spell_areacast(holder, casting_obj, targets, pass_cur_mod, next_mod)
		if(WAND_COMP_MELEEMAGICCAST)
			for(var/atom/target in targets)
				target = cur_mod.apply_dir_effects(target, casting_obj, i)
				spell_meleemagiccast(holder, casting_obj, target, pass_cur_mod, next_mod)
		if(WAND_COMP_ENCHANTCAST)
			for(var/atom/target in targets)
				// target = cur_cast_modifier.apply_dir_effects(target, casting_obj, i)
				spell_enchantcast(holder, casting_obj, target, pass_cur_mod, next_mod)
	after_cast(cast_type, holder, casting_obj, targets, pass_cur_mod, next_mod)
	last_cast = world.time

/obj/item/spell/proc/passive_cast(obj/item/weapon/wand/holder, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	before_cast(WAND_COMP_PASSIVECAST, holder, null, null, cur_mod, next_mod)
	on_passive_cast(holder, cur_mod, next_mod)
	after_cast(WAND_COMP_PASSIVECAST, holder, null, null, cur_mod, next_mod)
	last_cast = world.time


/obj/item/spell/proc/on_passive_cast(obj/item/weapon/wand/holder, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	return

/obj/item/spell/proc/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	return

/obj/item/spell/proc/spell_selfcast(obj/item/weapon/wand/holder, atom/casting_obj, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	spell_otherscast(holder, casting_obj, casting_obj, cur_mod, next_mod)

/obj/item/spell/proc/spell_meleemagiccast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(!in_range(casting_obj, target))
		target = get_step(casting_obj, get_dir(casting_obj, target))
	spell_otherscast(holder, casting_obj, target, cur_mod, next_mod)

/obj/item/spell/proc/spell_areacast(obj/item/weapon/wand/holder, atom/casting_obj, list/turfs, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/i = 1
	for(var/turf/T in turfs)
		var/atom/target = pick(list(T) + T.contents)
		target = cur_mod.apply_dir_effects(target, casting_obj, i)
		spell_otherscast(holder, casting_obj, target, cur_mod, next_mod)
		i++

/obj/item/spell/proc/spell_enchantcast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(istype(target, /obj/item))
		var/obj/item/I = target
		I.react_to_enchantment(holder, src)
