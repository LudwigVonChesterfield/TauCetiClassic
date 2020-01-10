/obj/item/wand_component
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-mythril"

	var/obj/item/weapon/wand/holder

	var/add_spells_per_click = 0

	var/add_max_mana = 0
	var/add_passive_mana_charge = 0.0

	var/list/add_flags = list()

/obj/item/wand_component/Destroy()
	if(holder)
		remove_from_holder()
	return ..()

/obj/item/wand_component/examine(mob/user)
	..()
	if(add_spells_per_click != 0)
		to_chat(user, "<span class='info'>This component will allow to conjure [add_spells_per_click > 0 ? "<b>[add_spells_per_click]</b> more" : "<span class='warning'><b>[-add_spells_per_click]</b> less</span>"] spell[add_spells_per_click > 1.0 ? "s" : ""] per cast.</span>")
	if(add_max_mana != 0.0)
		to_chat(user, "<span class='info'>This component will [add_max_mana > 0.0 ? "increase" : "<span class='warning'>decrease</span>"] your wands max mana by <b>[add_max_mana > 0.0 ? add_max_mana : "<span class='warning'>[-add_max_mana]</span>"]</b>.</span>")
	if(add_passive_mana_charge)
		to_chat(user, "<span class='info'>This component will [add_passive_mana_charge > 0.0 ? "increase restoration rate by <b>[add_passive_mana_charge]</b>" : "<span class='warning'>decrease restoration rate by <b>[add_passive_mana_charge]</b></span>"].</span>")

	if(add_flags[WAND_COMP_SELFCAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells on yourself.</span>")
	if(add_flags[WAND_COMP_OTHERSCAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells on others.</span>")
	if(add_flags[WAND_COMP_MELEECAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells in melee[!add_flags[WAND_COMP_SELFCAST] && !add_flags[WAND_COMP_OTHERSCAST] ? ", but still requires selfcast or otherscast to work" : ""].</span>")
	if(add_flags[WAND_COMP_MELEEMAGICCAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells together with melee hits.</span>")
	if(add_flags[WAND_COMP_ENCHANTCAST])
		to_chat(user, "<span class='info'>This component will allow you to enchant spells into other items[add_flags[WAND_COMP_SELFCAST] ? ", and into the wand itself" : ""].</span>")
	if(add_flags[WAND_COMP_AREACAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells in an area by swiping.</span>")
	if(add_flags[WAND_COMP_PASSIVECAST])
		to_chat(user, "<span class='info'>This component will allow you to cast spells passively.</span>")
	if(add_flags[WAND_COMP_RELOADMOVE])
		to_chat(user, "<span class='info'>This component will allow your wand to be reloaded on the move.</span>")

/obj/item/wand_component/proc/apply_to_holder(obj/item/weapon/wand/applied_to)
	holder = applied_to
	holder.wand_components += src
	holder.spells_per_click += add_spells_per_click
	holder.passive_mana_charge += add_passive_mana_charge
	holder.set_max_mana(holder.max_mana + add_max_mana)

	var/could_enchant_self = holder.wand_component_flags[WAND_COMP_ENCHANTCAST] && holder.wand_component_flags[WAND_COMP_SELFCAST]

	for(var/fl in add_flags)
		holder.wand_component_flags[fl] = TRUE

	if(!could_enchant_self)
		if(holder.wand_component_flags[WAND_COMP_ENCHANTCAST] && holder.wand_component_flags[WAND_COMP_SELFCAST])
			holder.verbs += /obj/item/weapon/wand/proc/enchant_self
	else
		if(!holder.wand_component_flags[WAND_COMP_ENCHANTCAST] || !holder.wand_component_flags[WAND_COMP_SELFCAST])
			holder.verbs -= /obj/item/weapon/wand/proc/enchant_self
	holder.needs_reload = TRUE

/obj/item/wand_component/proc/remove_from_holder()
	holder.wand_components -= src
	holder.spells_per_click -= add_spells_per_click
	holder.passive_mana_charge -= add_passive_mana_charge
	holder.set_max_mana(holder.max_mana - add_max_mana)

	var/list/has_flags = list()
	for(var/obj/item/wand_component/WC in holder.wand_components)
		for(var/fl in WC.add_flags)
			has_flags[fl] = TRUE

	holder.wand_component_flags = has_flags
	holder.needs_reload = TRUE
	holder = null
