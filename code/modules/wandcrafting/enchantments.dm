/obj/item
	var/image/enchantment_overlay

	var/datum/spell_modifier/enchant_mod

	var/list/enchanted_spells

	var/total_received_enchantments = 0

	var/obj/item/weapon/wand/enchantment_wand

	var/enchantable = TRUE
	var/enchanted = FALSE

/obj/item/proc/get_default_cast_modifier()
	var/datum/spell_modifier/SM = new()
	return SM

/obj/item/proc/react_to_enchantment(obj/item/weapon/wand/holder, obj/item/spell/enchanting_with)
	if(!enchantable)
		visible_message("<span class='notice'>[src] trembles lightly, as it rejects the enchantment.</span>")
		return

	if(enchanted_spells && enchanted_spells.len >= w_class)
		visible_message("<span class='danger'>[src] shakes violently, as it rejects the enchantment!</span>")
		return

	if(enchantment_wand && holder != enchantment_wand)
		visible_message("<span class='warning'>[src] rejects [holder]!</span>")
		return

	if(!enchanted)
		enchant(holder)

	var/spell_type = enchanting_with.type
	enchanted_spells += new spell_type(null)

	total_received_enchantments += 1

	if(total_received_enchantments >= w_class * 3)
		var/to_break_prob = 0.0
		if(holder.crit_fail)
			to_break_prob += 50.0
		to_break_prob += holder.max_mana / 100.0 // Strong wands have an effect.
		to_break_prob += holder.passive_mana_charge
		to_break_prob += holder.spells_slots * 0.5
		to_break_prob += holder.wand_components_slots
		if(prob(to_break_prob * 0.01))
			visible_message("<span class='danger'>[src] crumbles into nothing!</span>")
			qdel(src)
			return
		if(prob(to_break_prob))
			visible_message("<span class='warning'>[src] wears down, as it can receive magic no more.</span>")
			make_old()
		enchantable = FALSE

/obj/item/proc/enchant(obj/item/weapon/wand/holder)
	enchanted = TRUE
	enchantment_wand = holder
	enchant_mod = get_default_cast_modifier()
	enchanted_spells = list()

	enchantment_overlay = image(icon=icon, icon_state=icon_state)
	enchantment_overlay.loc = src

	enchantment_overlay.color = TO_NEGATIVE_COLOR

	overlays.Add(enchantment_overlay)

	var/def_pixel_x = enchantment_overlay.pixel_x
	var/def_pixel_y = enchantment_overlay.pixel_y
	var/def_transform = enchantment_overlay.transform

	for(var/i in 1 to rand(3, 5))
		var/matrix/M = matrix()
		M.Turn(rand(-180, 180))
		animate(enchantment_overlay, pixel_x=rand(-world.icon_size * 0.5, world.icon_size * 0.5), pixel_y=rand(-world.icon_size * 0.5, world.icon_size * 0.5), transform=M, time=3)
		sleep(3)
		if(QDELING(enchantment_overlay) || QDELING(src))
			return

	enchantment_overlay.pixel_x = def_pixel_x
	enchantment_overlay.pixel_y = def_pixel_y
	enchantment_overlay.transform = def_transform

/obj/item/proc/disenchant()
	QDEL_NULL(enchant_mod)
	QDEL_LIST(enchanted_spells)

	overlays.Remove(enchantment_overlay)
	QDEL_NULL(enchantment_overlay)
	enchanted = FALSE

/obj/item/proc/cast_enchantments(list/targets)
	if(!enchanted_spells)
		disenchant()
		return
	if(QDELETED(enchantment_wand))
		disenchant()
		return

	var/obj/item/spell/S = enchanted_spells[1]

	if(S.spell_can_cast(enchantment_wand, src, targets, enchant_mod, spend_mana = FALSE))
		var/i = 1
		for(var/atom/target in targets)
			target = enchant_mod.apply_dir_effects(target, src, i)
			INVOKE_ASYNC(S, /obj/item/spell.proc/spell_meleemagiccast, enchantment_wand, src, target, enchant_mod, enchant_mod)
			i++

	enchanted_spells -= S

	if(enchanted_spells.len == 0)
		disenchant()



/obj/item/weapon/paper/react_to_enchantment(obj/item/weapon/wand/holder, obj/item/spell/enchanting_with)
	var/spell_type = enchanting_with.type
	new spell_type(loc)
	qdel(src)
