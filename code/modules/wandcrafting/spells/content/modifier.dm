/datum/spell_setup_entry/stackability
	name = "Stackability"
	desc = "Toggles whether this spell can be stacked."
	category = "Technical"

	setup_word = "Toggle"

/datum/spell_setup_entry/stackability/can_setup(mob/user, obj/item/spell/holder)
	return TRUE

/datum/spell_setup_entry/stackability/on_setup(mob/user, obj/item/spell/holder)
	holder.stackable = !holder.stackable
	to_chat(user, "<span class='notice'>[holder] is now [holder.stackable ? "" : "not"] stackable.</span>")

/datum/spell_setup_entry/stackability/get_setup_line(mob/user, obj/item/spell/holder, i)
	return "<a href='?src=\ref[holder];setup=[i]'>[holder.stackable ? "Make not stackable" : "Make stackable"]</a><br>"

// These spells do not "cast" anything themself, but modify the next cast.
/obj/item/spell/modifier
	// name = "modifier spell"
	desc = "This spell modifies next cast's spells."

	category = "Modifier"

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "paper_words"
	item_state = "paper"

	// If false, the modifier itself will cause next_mod to become cur_mod.
	stackable = TRUE
	spawn_entries_types = list(/datum/spell_setup_entry/stackability)

	additional_delay = 2.0

	var/add_casts = 0

	var/power_multi = 1.0
	var/power_add = 0.0

	var/delay_multi = 1.0
	var/delay_add = 0.0

	var/mana_cost_add = 0.0
	var/mana_cost_multi = 1.0

	var/add_next_spell_copies = 0

	var/boomerang = FALSE

	// Will cause each spell to diverge from target into diverge_dir
	var/list/diverge_dirs
	// If add_casts > 0, this will cause the spells to fly into different directions, or whatever.
	var/list/additional_cast_dirs

/obj/item/spell/modifier/examine(mob/living/user)
	..()
	if(add_casts != 0.0)
		to_chat(user, "<span class='info'>[add_casts > 0.0 ? "Adds" : "<span class='warning'>Removes</span>"] [add_casts > 0.0 ? "<b>[add_casts]</b>" : "<span class='warning'><b>[add_casts]</b></span>"] spell[abs(add_casts) == 1.0 ? "" : "s"] [add_casts > 0.0 ? "to" : "from"] next cast.</span>")
	if(power_add != 0.0)
		to_chat(user, "<span class='info'>[power_add > 0.0 ? "Increases" : "<span class='warning'>Decreases</span>"] next cast's damage by [power_add > 0.0 ? "<b>[power_add * 0.01]</b>%" : "<span class='warning'><b>[power_add * 0.01]</b>%</span>"].</span>")
	if(power_multi != 1.0)
		to_chat(user, "<span class='info'>Mulltiplies next cast's damage by [power_multi > 1.0 ? "<b>[power_multi * 0.01]</b>%" : "<span class='warning'><b>[power_multi * 0.01]</b>%</span>"].</span>")
	if(delay_add != 0.0)
		to_chat(user, "<span class='info'>[delay_add > 0.0 ? "<span class='warning'>Increases</span>" : "Decreases"] next cast's delay by [power_add > 0.0 ? "<span class='warning'><b>[delay_add * 0.01]</b>%</span>" : "<b>[delay_add * 0.01]</b>%"].</span>")
	if(delay_multi != 1.0)
		to_chat(user, "<span class='info'>Mulltiplies next cast's delay by [delay_multi > 1.0 ? "<span class='warning'><b>[delay_multi * 0.01]</b>%</span>" : "<b>[delay_multi * 0.01]</b>%"].</span>")
	if(mana_cost_add != 0.0)
		to_chat(user, "<span class='info'>[mana_cost_add > 0.0 ? "<span class='warning'>Increases</span>" : "Decreases"] next cast's delay by [mana_cost_add > 0.0 ? "<span class='warning'><b>[mana_cost_add * 0.01]</b>%</span>" : "<b>[mana_cost_add * 0.01]</b>%"].</span>")
	if(mana_cost_multi != 1.0)
		to_chat(user, "<span class='info'>Mulltiplies next cast's delay by [mana_cost_multi > 1.0 ? "<span class='warning'><b>[mana_cost_multi * 0.01]</b>%</span>" : "<b>[mana_cost_multi * 0.01]</b>%"].</span>")
	if(add_next_spell_copies)
		to_chat(user, "<span class='info'>Adds <b>[add_next_spell_copies]</b> copies of next spell in the queue, to the queue.</span>")
	if(boomerang)
		to_chat(user, "<span class='info'>Makes next cast's spells exhibit boomerang-ish tendencies.</span>")

/obj/item/spell/modifier/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()
	if(add_casts != 0.0)
		dat += "[add_casts > 0.0 ? "Adds" : "<font color='red'>Removes</font>"] [add_casts > 0.0 ? "<b>[add_casts]</b>" : "<font color='red'><b>[add_casts]</b></font>"] spell[abs(add_casts) == 1.0 ? "" : "s"] [add_casts > 0.0 ? "to" : "from"] next cast.<BR>"
	if(power_add != 0.0)
		dat += "[power_add > 0.0 ? "Increases" : "<span class='warning'>Decreases</font>"] next cast's damage by [power_add > 0.0 ? "<b>[power_add * 0.01]</b>%" : "<font color='red'><b>[power_add * 0.01]</b>%</font>"].<BR>"
	if(power_multi != 1.0)
		dat += "Mulltiplies next cast's damage by [power_multi > 1.0 ? "<b>[power_multi * 0.01]</b>%" : "<font color='red'><b>[power_multi * 0.01]</b>%</font>"].<BR>"
	if(delay_add != 0.0)
		dat += "[delay_add > 0.0 ? "<font color='red'>Increases</span>" : "Decreases"] next cast's delay by [power_add > 0.0 ? "<font color='red'><b>[delay_add * 0.01]</b>%</font>" : "<b>[delay_add * 0.01]</b>%"].<BR>"
	if(delay_multi != 1.0)
		dat += "Mulltiplies next cast's delay by [delay_multi > 1.0 ? "<font color='red'><b>[delay_multi * 0.01]</b>%</font>" : "<b>[delay_multi * 0.01]</b>%"].<BR>"
	if(mana_cost_add != 0.0)
		dat += "[mana_cost_add > 0.0 ? "<font color='red'>Increases</font>" : "Decreases"] next cast's delay by [mana_cost_add > 0.0 ? "<font color='red'><b>[mana_cost_add * 0.01]</b>%</font>" : "<b>[mana_cost_add * 0.01]</b>%"].<BR>"
	if(mana_cost_multi != 1.0)
		dat += "Mulltiplies next cast's delay by [mana_cost_multi > 1.0 ? "<font color='red'><b>[mana_cost_multi * 0.01]</b>%</font>" : "<b>[mana_cost_multi * 0.01]</b>%"].<BR>"
	if(add_next_spell_copies)
		dat += "Adds <b>[add_next_spell_copies]</b> copies of next spell in the queue, to the queue.<BR>"
	if(boomerang)
		dat += "Makes next cast's spells exhibit boomerang-ish tendencies.<BR>"
	return dat

/obj/item/spell/modifier/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	next_mod.add_casts += add_casts

	next_mod.add_power += power_add
	next_mod.mult_power *= power_multi

	next_mod.add_power += delay_add
	next_mod.mult_delay *= delay_multi

	next_mod.add_mana_cost += mana_cost_add
	next_mod.mult_mana_cost *= mana_cost_multi

	if(diverge_dirs)
		next_mod.diverge_dirs += diverge_dirs
	if(additional_cast_dirs)
		next_mod.additional_cast_dirs += additional_cast_dirs

	if(add_next_spell_copies > 0 && holder.spells_queue.len > 0)
		var/spell_type = holder.spells_queue[1].type
		for(var/i in 1 to add_next_spell_copies)
			var/obj/item/spell/S = new spell_type(null)
			holder.spells_queue += S

	if(boomerang)
		next_mod.boomerang = TRUE

/obj/item/spell/modifier/double_power
	name = "double power spell"
	desc = "Next cast's spells will be conjured with double their power."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_red"

	power_multi = 2.0


/obj/item/spell/modifier/additional_cast
	name = "additional cast spell"
	desc = "This spell allows the next cast to conjure one more spell."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_purple"

	add_casts = 1



/obj/item/spell/modifier/half_delay
	name = "halve delay spell"
	desc = "This spell allows the next cast to half the delay."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_white"

	delay_multi = 0.5



/obj/item/spell/modifier/half_cost
	name = "halve mana cost spell"
	desc = "This spell allows the next cast to be cast with half the required mana."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_blue"

	delay_multi = 0.5



/obj/item/spell/modifier/heavy_shot
	name = "heavy shot spell"
	desc = "Next cast's spells will be conjured with triple their power, but at a cost..."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_red"

	power_multi = 3.0
	mana_cost_multi = 2.0



/obj/item/spell/modifier/boomerang
	name = "boomerang spell"
	desc = "Next cast's spells will be conjured with boomerang-ish behaviour."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_yellow"

	boomerang = TRUE



/obj/item/spell/modifier/clone_next_spell
	name = "clone next spell"
	desc = "Creates two copies of the next spell in the queue."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_purple"

	add_next_spell_copies = 2
