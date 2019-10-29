/obj/item/spell/spray
	name = "spray spell"
	desc = "This spells sprays stuff."

	category = "Projectile"

	spell_icon = 'icons/obj/janitor.dmi'
	spell_icon_state = "cleaner"
	item_state = "cleaner"

	spell_components_slots = 1
	compatible_flags = list(
		WAND_SPELL_TRIGGER_ON_IMPACT = TRUE,
		WAND_SPELL_TRIGGER_ON_STEP = TRUE,
		WAND_SPELL_TIMER = TRUE,
		)

	on_trigger_cast_type = WAND_COMP_OTHERSCAST

	var/list/reagents_to_spray
	var/spray_range = 5

/obj/item/spell/spray/atom_init()
	create_reagents(1000)
	for(var/reag_id in reagents_to_spray)
		reagents.add_reagent(reag_id, reagents_to_spray[reag_id])
	if(reagents.reagent_list.len > 0)
		spell_icon += mix_color_from_reagents(reagents.reagent_list)
	return ..()

/obj/item/spell/spray/set_full_name()
	if(reagents.reagent_list.len > 0)
		full_name = "[lowertext(reagents.reagent_list[1].name)] [name]"
	else
		..()

/obj/item/spell/spray/examine(mob/living/user)
	..()
	to_chat(user, "<span class='info'>The projectile will travel approximately <b>[spray_range * 2]</b> meters.</span>")
	if(isliving(user))
		user.taste_reagents(reagents, "smell")

/obj/item/spell/spray/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()

	dat += "The projectile will travel approximately <b>[spray_range * 2]</b> meters.<BR>"

	var/reagent_txt = ""
	for(var/reagent in reagents_to_spray)
		var/datum/reagent/R = global.chemical_reagents_list[reagent]
		if(reagent_txt == "")
			reagent_txt += R.name
		else
			reagent_txt += ", " + lowertext(R.name)
	dat += "Contains: [reagent_txt].<BR>"
	return dat

/obj/item/spell/spray/get_key_words()
	return reagents_to_spray + list(name)

/obj/item/spell/spray/proc/get_spray_reagents(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/datum/reagents/R = new(1000)
	for(var/reag_id in reagents_to_spray)
		R.add_reagent(reag_id, reagents_to_spray[reag_id] * cur_mod.mult_power + cur_mod.add_power)
	return R

/obj/item/spell/spray/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/datum/reagents/R = get_spray_reagents(holder, casting_obj, target, cur_mod, next_mod)

	var/turf/casting_turf = get_turf(casting_obj)
	var/turf/target_turf = get_turf(target)
	var/turf/start_turf = get_step(casting_turf, get_dir(casting_turf, target_turf))

	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(casting_turf)
	D.create_reagents(1000)
	R.trans_to(D, R.total_volume)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)
	D.created_by = casting_obj

	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		D.on_impact_callback = CALLBACK(src, /obj/item/spell.proc/issue_event, WAND_SPELL_TRIGGER_ON_IMPACT, holder, D, list(target), cur_mod.get_copy(), next_mod.get_copy())
	if(spell_flags[WAND_SPELL_TRIGGER_ON_STEP])
		D.on_step_callback = CALLBACK(src, /obj/item/spell.proc/issue_event, WAND_SPELL_TRIGGER_ON_STEP, holder, D, list(target), cur_mod.get_copy(), next_mod.get_copy())

	INVOKE_ASYNC(GLOBAL_PROC, .proc/chempuff_spray, D, start_turf, target_turf, spray_range * cur_mod.mult_power + cur_mod.add_power, 1, 2)



/obj/item/spell/spray/random
	name = "random spray spell"

/obj/item/spell/spray/random/atom_init()
	spray_range = rand(3, 7)
	mana_cost = rand(2, 10)

	reagents_to_spray = list()

	var/regs = rand(1, 10)
	for(var/i in 1 to regs)
		var/reag = pick(chemical_reagents_list)
		reagents_to_spray[reag] = 5 / regs

	. = ..()

/obj/item/spell/spray/random/get_spray_reagents(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/datum/reagents/R = new(1000)
	var/regs = rand(1, 10)
	for(var/i in 1 to regs)
		R.add_reagent(pick(chemical_reagents_list), (5 / regs) * cur_mod.mult_power + cur_mod.add_power)
	R.my_atom = holder
	return R



/obj/item/spell/spray/water
	mana_cost = 2
	reagents_to_spray = list("water" = 5)
	spray_range = 5

/obj/item/spell/spray/water/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/step)
	can_be_crafted = FALSE


/obj/item/spell/spray/whiskey
	mana_cost = 3
	reagents_to_spray = list("whiskey" = 5)
	spray_range = 5



/obj/item/spell/spray/space_cleaner
	mana_cost = 3
	reagents_to_spray = list("cleaner" = 5)
	spray_range = 5



/obj/item/spell/spray/blood
	mana_cost = 3
	reagents_to_spray = list("blood" = 5)
	spray_range = 5


/obj/item/spell/spray/lube
	mana_cost = 10
	reagents_to_spray = list("lube" = 5)
	spray_range = 3


/obj/item/spell/spray/fuel
	mana_cost = 10
	reagents_to_spray = list("fuel" = 5)
	spray_range = 3



/obj/item/spell/spray/sacid
	mana_cost = 10
	reagents_to_spray = list("sacid" = 5)
	spray_range = 3



/obj/item/spell/spray/phoron
	mana_cost = 10
	reagents_to_spray = list("phoron" = 5)
	spray_range = 3
