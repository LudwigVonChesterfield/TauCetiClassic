// var/global/list/rune_rock_icons = list()

/proc/spell_word_from_runes(list/runes)
	var/retVal = ""
	var/i = 1
	for(var/rune in runes)
		retVal += rune
		if(i != runes.len)
			retVal += "`"
		i++
	return capitalize(retVal)

/obj/item/rune
	name = "rune"
	desc = "A potent rune for crafting spells."
	icon = 'icons/obj/spell_runes.dmi'
	icon_state = "rune_rock_1"

	light_range = 1.0
	light_power = 1.0

	w_class = ITEM_SIZE_SMALL

	var/rune_color
	var/rune_word = ""
	var/colorized_rune_word = ""
	var/list/runes

	spawn_destruction_reagents = list("stone" = 5.0)

/obj/item/rune/atom_init(mapload, list/my_runes)
	if(my_runes)
		var/list/rune_cols = list()
		for(var/rune in my_runes)
			rune_cols += global.rune_to_color[rune]
		rune_color = mix_colors(rune_cols)

	if(!rune_color)
		rune_color = pick(global.spell_colors_to_use)

	light_color = rune_color

	. = ..()
	icon_state = "rune_rock_[rand(1, 6)]"

	runes = my_runes

	var/main_color
	var/shade_color
	if(runes)
		if(runes.len == 1)
			main_color = global.rune_to_color[runes[1]]
			shade_color = global.rune_to_color[runes[1]]
		else if(runes.len >= 2)
			main_color = global.rune_to_color[runes[1]]
			var/list/shade_runes = list() + runes
			shade_runes -= shade_runes[1]
			shade_color = global.rune_to_color[pick(shade_runes)]

	if(!main_color)
		main_color = pick(global.spell_colors_to_use)
	if(!shade_color)
		shade_color = pick(global.spell_colors_to_use)

	// #define RUNE_SCALE 1.0

	// var/matrix/M = matrix()
	// M.Scale(RUNE_SCALE)
	// M.Turn(rand(-180, 180))

	var/rune_t = rand(1, 6)

	var/image/shade_rune = image(icon='icons/obj/rune.dmi', icon_state="shade[rune_t]")
	shade_rune.loc = src
	shade_rune.layer = ABOVE_LIGHTING_LAYER
	shade_rune.plane = ABOVE_LIGHTNING_PLANE
	// shade_rune.transform = M
	shade_rune.icon += shade_color
	shade_rune.alpha = 100
	overlays += shade_rune

	var/image/main_rune = image(icon='icons/obj/rune.dmi', icon_state="main[rune_t]")
	main_rune.loc = src
	main_rune.layer = ABOVE_LIGHTING_LAYER
	main_rune.plane = ABOVE_LIGHTNING_PLANE
	// main_rune.transform = M
	main_rune.icon += main_color
	main_rune.alpha = 100
	overlays += main_rune

	// #undef RUNE_SCALE

	rune_word = spell_word_from_runes(runes)

	name = "[rune_word] [name]"

	var/rune_txt = ""
	var/i = 1
	for(var/rune in runes)
		rune_txt += "<font color=[global.rune_to_color[rune]]>[rune]</span>"
		if(i != runes.len)
			rune_txt += "`"
		i++

	colorized_rune_word = rune_txt
	desc += " Seems to be inscribed with <span class='danger'>[colorized_rune_word]</span>."

/obj/item/rune/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage/spellbook))
		if(global.spell_types_by_spell_word[rune_word])
			var/spell_type = pick(global.spell_types_by_spell_word[rune_word])
			var/obj/item/weapon/storage/spellbook/SB = I
			SB.learn_spell(spell_type, reveal_rune_word=TRUE)
			if(user.machine == SB)
				SB.browse_ui(user)
		return
	if(istype(I, /obj/item/rune) && !merge_with(I))
		visible_message("<span class='notice'>Scribings on [src] glow ominously, as it rejects [I].</span>")
		return
	return ..()

// Merges R into src. Return the combined rune if succesful.
/obj/item/rune/proc/merge_with(obj/item/rune/R)
	if(runes.len + R.runes.len > MAX_RUNES)
		return

	. = new /obj/item/rune(loc, runes + R.runes)
	qdel(src)
	qdel(R)

/obj/item/rune/react_to_damage(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	// rune_anvil.dm allows to split runes muuuch easier.
	var/obj/structure/table/rune_anvil/RA = locate() in loc
	if(RA && RA.anchored)
		var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = TRUE
		pulse2.dir = pick(cardinal)

		QDEL_IN(pulse2, 1 SECOND)

		on_destroy()
		return

	..()

/obj/item/rune/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	. = ..()
	if(DM.damage_type == BRUTE)
		var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = TRUE
		pulse2.dir = pick(cardinal)

		QDEL_IN(pulse2, min(DM.applied_force, 1 SECOND))

/obj/item/rune/on_destroy()
	if(runes.len > 1.0)
		var/halve = round(runes.len * 0.5)
		var/list/runes_to_pass = list()
		for(var/i in 1 to halve)
			runes_to_pass += runes[1]
			runes -= runes[1]

		var/obj/item/rune/rune1 = new(loc, list() + runes)
		rune1.pixel_x = rand(-world.icon_size * 0.5, world.icon_size * 0.5)
		rune1.pixel_y = rand(-world.icon_size * 0.5, world.icon_size * 0.5)
		var/obj/item/rune/rune2 = new(loc, runes_to_pass)
		rune2.pixel_x = rand(-world.icon_size * 0.5, world.icon_size * 0.5)
		rune2.pixel_y = rand(-world.icon_size * 0.5, world.icon_size * 0.5)
		qdel(src)
	else
		..()
