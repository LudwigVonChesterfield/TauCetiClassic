/obj/random/misc/musical
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/musical/item_to_spawn()
		return pick(\
						/obj/item/device/guitar,\
						/obj/item/device/harmonica,\
						/obj/item/device/violin,\
						/obj/item/device/guitar/electric\
					)

/obj/random/misc/storage
	name = "Random boxes"
	desc = "This is a random boxes ."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/storage/item_to_spawn()
		return pick(\
						prob(40);/obj/item/weapon/storage/fancy/crayons,\
						prob(40);/obj/item/weapon/storage/fancy/glowsticks,\
						prob(40);/obj/item/weapon/storage/fancy/vials,\
						prob(40);/obj/item/weapon/storage/fancy/donut_box,\
						prob(40);/obj/item/weapon/storage/fancy/candle_box,\
						prob(60);/obj/item/weapon/storage/fancy/egg_box,\
						prob(10);/obj/item/weapon/storage/box/lights,\
						prob(10);/obj/item/weapon/storage/box/lights/tubes,\
						prob(10);/obj/item/weapon/storage/box/lights/mixed,\
						prob(10);/obj/item/weapon/storage/box/engineer,\
						prob(10);/obj/item/weapon/storage/box/gloves,\
						prob(60);/obj/item/weapon/storage/box/mousetraps,\
						prob(60);/obj/item/weapon/storage/box/pillbottles,\
						prob(40);/obj/item/weapon/storage/box/snappops,\
						prob(10);/obj/item/weapon/storage/box/holobadge,\
						prob(30);/obj/item/weapon/storage/box/evidence,\
						prob(40);/obj/item/weapon/storage/box/solution_trays,\
						prob(40);/obj/item/weapon/storage/box/beakers,\
						prob(10);/obj/item/weapon/storage/box/beanbags,\
						prob(40);/obj/item/weapon/storage/box/drinkingglasses,\
						prob(40);/obj/item/weapon/storage/box/condimentbottles,\
						prob(40);/obj/item/weapon/storage/box/cups,\
						prob(40);/obj/item/weapon/storage/box/donkpockets,\
						prob(8);/obj/item/weapon/storage/box/monkeycubes,\
						prob(8);/obj/item/weapon/storage/box/monkeycubes/farwacubes,\
						prob(8);/obj/item/weapon/storage/box/monkeycubes/stokcubes,\
						prob(8);/obj/item/weapon/storage/box/monkeycubes/neaeracubes,\

						prob(30);/obj/item/weapon/storage/box/ids,\
						prob(20);/obj/item/weapon/storage/box/handcuffs,\
						prob(10);/obj/item/weapon/storage/box/contraband,\
						prob(10);/obj/random/pouch
					)

/obj/random/misc/smokes
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/smokes/item_to_spawn()
		return pick(\
						prob(100);/obj/item/weapon/cigbutt,\
						prob(80);/obj/item/clothing/mask/cigarette,\
						prob(10);/obj/item/clothing/mask/cigarette/cigar,\
						prob(5);/obj/item/clothing/mask/cigarette/cigar/cohiba,\
						prob(3);/obj/item/clothing/mask/cigarette/cigar/havana,\
						prob(3);/obj/item/clothing/mask/cigarette/pipe,\
						prob(5);/obj/item/clothing/mask/cigarette/pipe/cobpipe,\
						prob(10);/obj/item/weapon/storage/fancy/cigarettes,\
						prob(10);/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,\
						prob(1);/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate\
					)


/obj/random/misc/lighters
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/lighters/item_to_spawn()
		return pick(\
						prob(100);/obj/item/weapon/storage/box/matches,\
						prob(30);/obj/item/weapon/lighter/random,\
						prob(10);/obj/item/weapon/lighter/zippo,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/li_matsuda_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/michael_guess_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/riley_rohtin_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/fay_sullivan_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/executivekill_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/naples_1\
					)




/obj/random/misc/toy
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/toy/item_to_spawn()
		return pick(subtypesof(/obj/item/toy))



/obj/random/misc/lightsource
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/lightsource/item_to_spawn()
		return pick(
					prob(45);/obj/random/misc/lighters,\
					prob(20);/obj/item/device/flashlight/flare,\
					prob(20);/obj/item/device/flashlight/pen,\
					prob(5);/obj/item/weapon/storage/fancy/glowsticks,\
					prob(10);/obj/item/weapon/storage/fancy/candle_box,\
					prob(5);/obj/item/device/flashlight\
					)



/obj/random/misc/pack
	name = "Random Misc"
	desc = "This is a random misc pack."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/pack/item_to_spawn()
		return pick(\
						prob(90);/obj/random/misc/toy,\
						prob(40);/obj/random/misc/lighters,\
						prob(40);/obj/random/misc/smokes,\
						prob(90);/obj/random/misc/storage,\
						prob(1);/obj/random/misc/musical\
					)

#define WAND_COL_RED       "#ff0000"
#define WAND_COL_GREEN     "#00ff00"
#define WAND_COL_BLUE      "#0000ff"
#define WAND_COL_YELLOW    "#ffff00"
#define WAND_COL_PURPLE    "#ff00ff"
#define WAND_COL_CYAN      "#00ffff"

#define WAND_COL_PINK      "#ffc0cb"
#define WAND_COL_ORANGE    "#ffa500"
#define WAND_COL_TURQUOISE "#40e0d0"

var/global/list/wand_icon_by_icon_state = list(
	"banana" = 'icons/obj/items.dmi',
	"nettle" = 'icons/obj/weapons.dmi',
	"deathnettle" = 'icons/obj/weapons.dmi',
	"broom_sauna" = 'icons/obj/weapons.dmi',
	"cane" = 'icons/obj/weapons.dmi',
	"nullrod" = 'icons/obj/weapons.dmi',
	"telebaton_0" = 'icons/obj/weapons.dmi',
	"metal-rod" = 'icons/obj/weapons.dmi', // rod, staff
	"metal-rod-superheated" = 'icons/obj/weapons.dmi', // rod, staff
	"implanter0" = 'icons/obj/items.dmi',
	"implanter1" = 'icons/obj/items.dmi',
	"dnainjector" = 'icons/obj/items.dmi',
	"dnainjector0" = 'icons/obj/items.dmi', // dagger
	"toyhammer" = 'icons/obj/items.dmi', // hammer
	"bike_horn" = 'icons/obj/items.dmi', // mace
	"rods-1" = 'icons/obj/items.dmi', // rod, staff
	"lipstick" = 'icons/obj/items.dmi',
	"sheet-gold" = 'icons/obj/items.dmi', // mace
	"cimplanter1" = 'icons/obj/items.dmi', // dagger
	"cimplanter0" = 'icons/obj/items.dmi', // dagger
	"purplecomb" = 'icons/obj/items.dmi',
	"pen" = 'icons/obj/bureaucracy.dmi', // dagger
	"stamp-hos" = 'icons/obj/bureaucracy.dmi', // mace
	"subspace_amplifier" = 'icons/obj/stock_parts.dmi',
	"ansible_crystal" = 'icons/obj/stock_parts.dmi',
	"quadultra_micro_laser" = 'icons/obj/stock_parts.dmi',
	"scalpel_laser1_off" = 'icons/obj/surgery.dmi',
	"scalpel_laser2_off" = 'icons/obj/surgery.dmi',
	"scalpel_laser3_off" = 'icons/obj/surgery.dmi',
	"autoinjector1" = 'icons/obj/syringe.dmi',
	"unknown1" = 'icons/obj/xenoarchaeology/finds.dmi', // wand
	"wave_searcher" = 'icons/obj/xenoarchaeology/tools.dmi',
	"pick_brush" = 'icons/obj/xenoarchaeology/tools.dmi',
	"sampler" = 'icons/obj/xenoarchaeology/tools.dmi',
	"foamdart" = 'icons/obj/toy.dmi',
	"screwdriver_brown" = 'icons/obj/tools.dmi', // dagger
	"unathiknife" = 'icons/obj/weapons.dmi', // dagger, blade
	"cutlass1" = 'icons/obj/weapons.dmi',
	"switchblade_ext" = 'icons/obj/weapons.dmi', // dagger, blade
	"ice_pick" = 'icons/obj/weapons.dmi',
	"lipstick_red" = 'icons/obj/items.dmi', // dagger
	"razor" = 'icons/obj/items.dmi', // dagger
	"scissors" = 'icons/obj/items.dmi', // dagger, blade
	"scalpel" = 'icons/obj/surgery.dmi', // rod
	"hemostat" = 'icons/obj/surgery.dmi',
	"cautery" = 'icons/obj/surgery.dmi',
	"stabslash" = 'icons/obj/surgery.dmi',
	"render" = 'icons/obj/wizard.dmi',
	"cutters_black" = 'icons/obj/tools.dmi',
	"baton" = 'icons/obj/weapons.dmi',
	"crossbowframe0" = 'icons/obj/weapons.dmi', // club
	"text" = 'icons/obj/weapons.dmi', // club
	"peace" = 'icons/obj/weapons.dmi', // club
	"fire_extinguisher0" = 'icons/obj/items.dmi', // club
	"miniFE0" = 'icons/obj/items.dmi', // club
	"mjollnir0" = 'icons/obj/wizard.dmi', // hammer
	"pick1" = 'icons/obj/xenoarchaeology/tools.dmi',
	"pick_hand" = 'icons/obj/xenoarchaeology/tools.dmi',
	"shovel" = 'icons/obj/tools.dmi',
	"spade" = 'icons/obj/tools.dmi',
	"fireaxe0" = 'icons/obj/weapons.dmi', // axe
	"sledgehammer" = 'icons/obj/weapons.dmi', // axe
	"axe0" = 'icons/obj/weapons.dmi',
	"hatchet" = 'icons/obj/weapons.dmi',
	"cultblade" = 'icons/obj/weapons.dmi',
	"sord" = 'icons/obj/weapons.dmi',
	"claymore" = 'icons/obj/weapons.dmi',
	"katana" = 'icons/obj/weapons.dmi',
	"powerfist_1" = 'icons/obj/weapons.dmi',
	"telebaton_1" = 'icons/obj/weapons.dmi',
	"harpoon" = 'icons/obj/weapons.dmi',
	"bolt" = 'icons/obj/weapons.dmi',
	"quill" = 'icons/obj/weapons.dmi', // rod, staff
	"stunprod" = 'icons/obj/makeshift.dmi', // rod, staff
	"spearglass0" = 'icons/obj/makeshift.dmi',
	"staff" = 'icons/obj/wizard.dmi',
	"broom" = 'icons/obj/wizard.dmi', // rod
	"focus" = 'icons/obj/wizard.dmi',
	"staffofchange" = 'icons/obj/wizard.dmi',
	"staffofanimation" = 'icons/obj/wizard.dmi',
	"staffofhealing" = 'icons/obj/wizard.dmi',
	"staffofdoor" = 'icons/obj/wizard.dmi',
	)

/obj/random/misc/rune
	name = "rune"
	desc = "A random rune."
	icon = 'icons/obj/spell_runes.dmi'
	icon_state = "rune_rock_1"

/obj/random/misc/rune/atom_init(mapload, rune_min_am=1, rune_max_am=5)
	. = ..()
	var/rune_am = rand(rune_min_am, rune_max_am)
	var/list/inscribed_with = list()
	var/list/to_choose = list() + global.rune_to_color

	for(var/i in 1 to rune_am)
		var/rune = pick(to_choose)
		inscribed_with += rune
		to_choose -= rune

	new /obj/item/rune(loc, inscribed_with)

	return INITIALIZE_HINT_QDEL

/obj/random/misc/spell
	name = "Random spell"
	desc = "This is a random spell."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/misc/spell/item_to_spawn()
	var/list/pick_from = subtypesof(/obj/item/spell) - list(
		/obj/item/spell/legacy, /obj/item/spell/projectile, /obj/item/spell/spray,
		/obj/item/spell/modifier, /obj/item/spell/passive, /obj/item/spell/conjure,
		/obj/item/spell/conjure/mime, /obj/item/spell/conjure/weapon, /obj/item/spell/on_caster,
		/obj/item/spell/spell_component,)
	return pick(pick_from)

/obj/random/misc/wand_component
	name = "Random spell"
	desc = "This is a random wand component."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/misc/wand_component/proc/rand_in_rang(points, min_in, max_in, min_out, max_out, round_prec=1.0)
	var/min_clamp = min_out
	var/max_clamp = max_out
	if(min_out > max_out)
		min_clamp = max_out
		max_clamp = min_out
	return CLAMP(round(((points - min_in) / (max_in - min_in)) * (max_out - min_out) + min_out, round_prec), min_clamp, max_clamp)

/obj/random/misc/wand_component/atom_init(mapload, strength_p=200)
	. = ..()
	var/obj/item/wand_component/random_comp = new(loc)

	var/list/distribute_among = list(
		"add_spells_per_click",
		"add_max_mana",
		"add_passive_mana_charge",
		"flags",
		)
	var/list/pos_attributes = list(
		"add_spells_per_click"=0,
		"add_max_mana"=0,
		"add_passive_mana_charge"=0,
		"flags"=0,
		)
	var/list/max_possible = list(
		"add_spells_per_click"=100.0,
		"add_max_mana"=100.0,
		"add_passive_mana_charge"=100.0,
		"flags"=100.0,
		)

	var/list/pos_name_attr = list()

	var/dist_strength = strength_p
	while(dist_strength > 0)
		if(distribute_among.len == 0)
			break
		var/increase_stat = pick(distribute_among)
		var/increase_by = rand(1, dist_strength)

		pos_attributes[increase_stat] += increase_by
		dist_strength -= increase_by
		if(pos_attributes[increase_stat] >= max_possible[increase_stat])
			dist_strength += max_possible[increase_stat] - pos_attributes[increase_stat]
			distribute_among -= increase_stat

	var/flags_txt = ""
	var/flags_gened = 0
	var/max_flags_am = 4
	var/need_per_flag = max_possible["flags"] / max_flags_am
	if(pos_attributes["flags"] >= need_per_flag)
		pos_name_attr += "Mystical"
		pos_name_attr += "Mythical"
		var/list/choose_from = list() + wand_comp_all
		flags_gen:
			while(flags_gened < pos_attributes["flags"] / need_per_flag)
				if(choose_from.len == 0)
					break flags_gen
				var/new_fl = pick(choose_from)

				for(var/list/incomp_group in wand_component_incompatible_flags)
					for(var/cur_fl in random_comp.add_flags)
						if((new_fl in incomp_group) && (cur_fl in incomp_group))
							choose_from -= new_fl
							continue flags_gen

				random_comp.add_flags[new_fl] = TRUE
				choose_from -= new_fl
				flags_txt += " " + pick("of", "with", "and", "or") + " " + capitalize(new_fl)
				flags_gened += 1
	else
		pos_name_attr += "Void"
		pos_name_attr += "Empty"

	var/leftover = round(pos_attributes["flags"] / need_per_flag) - flags_gened
	if(leftover > 0.0)
		distribute_among.Remove("flags")

		dist_strength = leftover
		while(dist_strength > 0)
			if(distribute_among.len == 0)
				break
			var/increase_stat = pick(distribute_among)
			var/increase_by = rand(1, dist_strength)

			pos_attributes[increase_stat] += increase_by
			dist_strength -= increase_by
			if(pos_attributes[increase_stat] >= max_possible[increase_stat])
				dist_strength += max_possible[increase_stat] - pos_attributes[increase_stat]
				distribute_among -= increase_stat

	random_comp.add_spells_per_click = rand_in_rang(pos_attributes["add_spells_per_click"], 0, max_possible["add_spells_per_click"], -2, 2, round_prec=1.0)
	random_comp.add_max_mana = rand_in_rang(pos_attributes["add_max_mana"], 0, max_possible["add_max_mana"], -50, 50, round_prec=1.0)
	random_comp.add_passive_mana_charge = rand_in_rang(pos_attributes["add_passive_mana_charge"], 0, max_possible["add_passive_mana_charge"], -2.0, 2.0, round_prec=0.1)

	if(random_comp.add_spells_per_click > 0.0)
		pos_name_attr += "Familiar"
	else
		pos_name_attr += "Uncaring"

	if(random_comp.add_max_mana > 0.0)
		pos_name_attr += "Wise"
	else
		pos_name_attr += "Stupendous"

	if(random_comp.add_passive_mana_charge > 0.0)
		pos_name_attr += "Arcane"
	else
		pos_name_attr += "Cruel"

	var/caster_name = pick("Angel's", "Familiar's", "Mage's", "Sorcerer's", "Wizard's", "Witch's")
	switch(caster_name)
		if("Angel's", "Familiar's")
			random_comp.color = pick(WAND_COL_RED, WAND_COL_BLUE, WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_PINK, null)
		if("Witch's")
			random_comp.color = pick(WAND_COL_GREEN, WAND_COL_YELLOW, WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_TURQUOISE, null)
		if("Wizard's", "Mage's")
			random_comp.color = pick(WAND_COL_BLUE, WAND_COL_PURPLE, WAND_COL_CYAN, null)
		if("Sorcerer's")
			random_comp.color = pick(WAND_COL_RED, WAND_COL_ORANGE, WAND_COL_YELLOW, null)
		else
			random_comp.color = pick(WAND_COL_RED, WAND_COL_GREEN, WAND_COL_BLUE, WAND_COL_YELLOW,
			                         WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_PINK, WAND_COL_ORANGE,
			                         WAND_COL_TURQUOISE, null)

	random_comp.name = pick(pos_name_attr) + " " + pick(caster_name) + " "+ pick("Scroll", "Manifesto", "Book", "Paper", "Thesis") + flags_txt + " " + pick("and", "or", "with") + " " + pick("Magic", "Arcane", "Knowledge", "Wisdom", "Sage")

	random_comp.icon = 'icons/obj/items.dmi'
	random_comp.icon_state = pick("wrap_paper", "deliveryPaper", "sheet-mythril", "sheet-cloth", "sheet-hide", "gauze")

	return INITIALIZE_HINT_QDEL

/obj/random/misc/wand
	name = "Random wand"
	desc = "This is a random wand."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/misc/wand/proc/rand_in_rang(points, min_in, max_in, min_out, max_out, round_prec=1.0)
	var/min_clamp = min_out
	var/max_clamp = max_out
	if(min_out > max_out)
		min_clamp = max_out
		max_clamp = min_out
	return CLAMP(round(((points - min_in) / (max_in - min_in)) * (max_out - min_out) + min_out, round_prec), min_clamp, max_clamp)

/obj/random/misc/wand/atom_init(mapload, strength_p=300)
	var/obj/item/weapon/wand/random_wand = new(loc)

	var/list/distribute_among = list(
		"spells_per_click",
		"spells_slots",
		"wand_components_slots",
		"max_mana",
		"passive_mana_charge",
		"spell_cast_delay",
		"spell_recharge_delay",
		"always_casts",
		)
	var/list/pos_attributes = list(
		"spells_per_click"=0,
		"spells_slots"=0,
		"wand_components_slots"=0,
		"max_mana"=0,
		"passive_mana_charge"=0,
		"spell_cast_delay"=0,
		"spell_recharge_delay"=0,
		"always_casts"=0,
		)
	var/list/max_possible = list(
		"spells_per_click"=100.0,
		"spells_slots"=100.0,
		"wand_components_slots"=100.0,
		"max_mana"=100.0,
		"passive_mana_charge"=100.0,
		"spell_cast_delay"=100.0,
		"spell_recharge_delay"=100.0,
		"always_casts"=100.0,
		)

	var/list/prefixal_attributes = list() // These will 100% be on the item.
	var/list/add_prefixal_attributes = list() // Each of these can be on the item with 75%(and less for each consecutive one)

	var/dist_strength = strength_p
	random_wand.spell_queue_type = pick(WAND_QUEUE_ORDER, WAND_QUEUE_SHUFFLE, WAND_QUEUE_RANDOM)
	switch(random_wand.spell_queue_type)
		if(WAND_QUEUE_ORDER)
			add_prefixal_attributes += pick("Orderly", "Formal")
		if(WAND_QUEUE_SHUFFLE)
			add_prefixal_attributes += pick("Shuffled", "Informal")
			dist_strength *= 1.25
		if(WAND_QUEUE_RANDOM)
			add_prefixal_attributes += pick("Chaotic", "Random")
			dist_strength *= 1.5

	while(dist_strength > 0)
		if(distribute_among.len == 0)
			break
		var/increase_stat = pick(distribute_among)
		var/increase_by = rand(1, dist_strength)

		pos_attributes[increase_stat] += increase_by
		dist_strength -= increase_by
		if(pos_attributes[increase_stat] >= max_possible[increase_stat])
			dist_strength += max_possible[increase_stat] - pos_attributes[increase_stat]
			distribute_among -= increase_stat

	if(pos_attributes["always_casts"] >= max_possible["always_casts"])
		add_prefixal_attributes += "Mysterious"
		var/obj/random/misc/spell/pick_with = new(null)
		var/spell_type = pick_with.item_to_spawn()
		random_wand.always_casts = new spell_type(null)
	else
		dist_strength = pos_attributes["always_casts"]

		distribute_among.Remove("always_casts")
		while(dist_strength > 0)
			if(distribute_among.len == 0)
				break
			var/increase_stat = pick(distribute_among)
			var/increase_by = rand(1, dist_strength)

			pos_attributes[increase_stat] += increase_by
			dist_strength -= increase_by
			if(pos_attributes[increase_stat] >= max_possible[increase_stat])
				dist_strength += max_possible[increase_stat] - pos_attributes[increase_stat]
				distribute_among -= increase_stat

	random_wand.spells_per_click = max(rand_in_rang(pos_attributes["spells_per_click"], 0, max_possible["spells_per_click"], 0, 3, round_prec=1.0), 1)
	random_wand.spells_slots = rand_in_rang(pos_attributes["spells_slots"], 0, max_possible["spells_slots"], 1, 12, round_prec=1.0)
	random_wand.wand_components_slots = rand_in_rang(pos_attributes["wand_components_slots"], 0, max_possible["wand_components_slots"], 1, 8, round_prec=1.0)
	random_wand.max_mana = rand_in_rang(pos_attributes["max_mana"], 0, max_possible["max_mana"], 50, 300, round_prec=1.0)
	random_wand.passive_mana_charge = rand_in_rang(pos_attributes["passive_mana_charge"], 0, max_possible["passive_mana_charge"], -1.0, 5.0, round_prec=0.1)
	random_wand.spell_cast_delay = 16 - rand_in_rang(pos_attributes["spell_cast_delay"], 0, max_possible["spell_cast_delay"], 0, 16, round_prec=1.0)
	random_wand.spell_recharge_delay = rand_in_rang(pos_attributes["spell_recharge_delay"], 0, max_possible["spell_recharge_delay"], 4.0 SECONDS, 0.3 SECONDS, round_prec=1.0)

	if(random_wand.spells_per_click > 1.0)
		add_prefixal_attributes += "Familiar"

	if(random_wand.spells_slots > 6)
		add_prefixal_attributes += "Potent"

	if(random_wand.wand_components_slots > 4)
		add_prefixal_attributes += "Hoarding"

	if(random_wand.max_mana > 200)
		add_prefixal_attributes += "Wise"

	if(random_wand.passive_mana_charge > 2.0)
		add_prefixal_attributes += "Arcane"

	if(random_wand.spell_cast_delay < 7.5)
		add_prefixal_attributes += "Swift"

	if(random_wand.spell_recharge_delay < 1 SECOND)
		add_prefixal_attributes += "Quick"

	random_wand.mana = random_wand.max_mana

	random_wand.storage_ui = null
	QDEL_NULL(random_wand.spells_storage)
	QDEL_NULL(random_wand.wand_components_storage)

	random_wand.spells_storage = new(random_wand, random_wand.spells, random_wand.spells_slots)
	random_wand.wand_components_storage = new(random_wand, random_wand.wand_components, random_wand.wand_components_slots)

	random_wand.storage_ui = random_wand.spells_storage

	var/item_attribute = pick("Battle", "Fighting", "Brawl", "Enchantment", "Casting", "Magic", "Arcane", "Witchery", "Tomfoolery", "Wizardry", "Spells",
	                          "Sorcery", "Trickery")
	switch(item_attribute)
		if("Battle", "Fighting", "Brawl")
			var/obj/item/wand_component/WC = new /obj/item/wand_component/brawl(null)
			random_wand.add_wand_component(WC)
		if("Enchantment", "Magic", "Arcane")
			var/obj/item/wand_component/WC = new /obj/item/wand_component/enchanting(null)
			random_wand.add_wand_component(WC)
		if("Casting", "Wizardry", "Spells")
			var/obj/item/wand_component/WC = new /obj/item/wand_component/wizardry(null)
			random_wand.add_wand_component(WC)
		if("Witchery", "Tomfoolery")
			var/obj/item/wand_component/WC = new /obj/item/wand_component/tomfoolery(null)
			random_wand.add_wand_component(WC)
		if("Sorcery", "Trickery")
			var/obj/item/wand_component/WC = new /obj/item/wand_component/sorcery(null)
			random_wand.add_wand_component(WC)

	switch(item_attribute)
		if("Enchantment", "Magic", "Arcane")
			random_wand.color = pick(WAND_COL_RED, WAND_COL_BLUE, WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_PINK, null)
		if("Witchery", "Tomfoolery")
			random_wand.color = pick(WAND_COL_GREEN, WAND_COL_YELLOW, WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_TURQUOISE, null)
		if("Casting", "Wizardry", "Spells")
			random_wand.color = pick(WAND_COL_BLUE, WAND_COL_PURPLE, WAND_COL_CYAN, null)
		if("Battle", "Fighting", "Brawl", "Sorcery", "Trickery")
			random_wand.color = pick(WAND_COL_RED, WAND_COL_ORANGE, WAND_COL_YELLOW, null)
		else
			random_wand.color = pick(WAND_COL_RED, WAND_COL_GREEN, WAND_COL_BLUE, WAND_COL_YELLOW,
			                         WAND_COL_PURPLE, WAND_COL_CYAN, WAND_COL_PINK, WAND_COL_ORANGE,
			                         WAND_COL_TURQUOISE, null)

	random_wand.w_class = pick(ITEM_SIZE_TINY, ITEM_SIZE_SMALL, ITEM_SIZE_NORMAL, ITEM_SIZE_LARGE, ITEM_SIZE_HUGE)
	var/item_type = "Wand"
	switch(random_wand.w_class)
		if(ITEM_SIZE_TINY)
			item_type = pick("Sprig", "Stick", "Twig")
		if(ITEM_SIZE_SMALL)
			item_type = pick("Cane", "Wand", "Knife", "Dagger")
		if(ITEM_SIZE_NORMAL)
			item_type = pick("Rod", "Pole", "Mace", "Club", "Hammer", "Hatchet", "Axe", "Blade", "Sword", "Baton")
		if(ITEM_SIZE_LARGE)
			item_type = pick("Staff", "Spear", "Sceptre", "Gauntlet")
		else
			prefixal_attributes += pick("Giant", "Huge", "Enormous", "Oversized")
			item_type = pick("Staff", "Spear", "Sceptre", "Rod", "Pole", "Mace", "Club", "Hatchet",
			                 "Axe", "Blade", "Sword", "Baton", "Cane", "Wand", "Knife", "Dagger",
			                 "Sprig", "Stick", "Twig")
	switch(item_type)
		if("Sprig", "Stick", "Twig")
			random_wand.force = rand(1, 5)
			random_wand.sharp = prob(10) ? TRUE : FALSE
			random_wand.edge = FALSE
		if("Cane", "Wand")
			random_wand.force = rand(5, 10)
			random_wand.sharp = prob(30) ? TRUE : FALSE
			random_wand.edge = FALSE
		if("Knife","Dagger")
			random_wand.force = rand(5, 10)
			random_wand.sharp = TRUE
			random_wand.edge = TRUE
		if("Mace", "Club", "Staff", "Sceptre", "Baton", "Gauntlet")
			random_wand.force = rand(5, 15)
			random_wand.sharp = FALSE
			random_wand.edge = FALSE
		if("Spear", "Rod", "Pole")
			random_wand.force = rand(10, 15)
			random_wand.sharp = TRUE
			random_wand.edge = FALSE
		if("Hatchet", "Axe", "Blade", "Sword")
			random_wand.force = rand(5, 15)
			random_wand.sharp = TRUE
			random_wand.edge = TRUE

	if(sharp)
		prefixal_attributes += pick("Sharp", "Cutting", "Slashing", "Stabby", "", "", "")
	else if(edge)
		prefixal_attributes += pick("Pointy", "Piked", "")

	if(random_wand.w_class > ITEM_SIZE_LARGE)
		random_wand.force *= 1.5

	switch(item_type)
		if("Sprig", "Stick", "Twig")
			random_wand.icon_state = pick("banana", "nettle", "deathnettle", "broom_sauna")
		if("Cane", "Wand")
			random_wand.icon_state = pick("banana", "cane", "nullrod", "telebaton_0", "metal-rod",
				"metal-rod-superheated", "implanter0", "implanter1",
				"dnainjector", "dnainjector0", "toyhammer", "bike_horn",
				"rods-1", "lipstick", "sheet-gold", "cimplanter1",
				"cimplanter0", "purplecomb", "pen", "subspace_amplifier",
				"ansible_crystal", "quadultra_micro_laser", "scalpel_laser1_off",
				"scalpel_laser2_off", "scalpel_laser3_off", "autoinjector1",
				"foamdart", "screwdriver_brown", "unknown1", "wave_searcher",
				"pick_brush", "sampler")
		if("Knife", "Dagger")
			random_wand.icon_state = pick("dnainjector0", "cimplanter1", "cimplanter0", "pen",
				"screwdriver_brown", "cutlass1", "switchblade_ext", "ice_pick", "lipstick_red",
				"razor", "scissors", "scalpel", "hemostat", "cautery", "stabslash", "render",
				"cutters_black", "unathiknife")
		if("Mace", "Club", "Baton", "Hammer")
			random_wand.icon_state = pick("toyhammer", "bike_horn", "sheet-gold", "stamp-hos", "baton",
				"crossbowframe0", "text", "peace", "fire_extinguisher0", "miniFE0", "mjollnir0", "pick1",
				"pick_hand", "shovel", "spade", "sledgehammer")
		if("Spear", "Rod", "Pole")
			random_wand.icon_state = pick("metal-rod", "metal-rod-superheated", "rods-1", "scalpel",
				"broom", "harpoon", "bolt", "quill", "stunprod", "spearglass0")
		if("Staff", "Sceptre")
			random_wand.icon_state = pick("telebaton-1", "bolt", "cane", "nullrod", "metal-rod",
				"metal-rod-superheated", "rods-1", "stunprod", "quill", "focus", "broom",
				"staffofchange", "staffofanimation", "staffofhealing", "staffofdoor")
		if("Blade", "Sword")
			random_wand.icon_state = pick("unathiknife", "cutlass1", "switchblade_ext", "scissors",
				"cultblade", "sord", "claymore", "katana")
		if("Axe", "Hatchet")
			random_wand.icon_state = pick("fireaxe0", "sledgehammer", "axe0", "hatchet")
		if("Gauntlet")
			random_wand.icon_state = "powerfist_1"
		else
			random_wand.icon_state = pick(wand_icon_by_icon_state)
	random_wand.icon = wand_icon_by_icon_state[random_wand.icon_state]

	add_prefixal_attributes += pick("Arcane", "Mystical", "Enchanted", "Mocked", "Stolen", "Magical",
	                            "Enthralling", "Mythical", "")

	var/add_chance = 75
	var/cons_add_multi = 0.5

	while(add_prefixal_attributes.len > 0)
		var/pref = pick(add_prefixal_attributes)
		if(prob(add_chance))
			prefixal_attributes += pref
			add_chance *= cons_add_multi
		add_prefixal_attributes -= pref

	var/prefix_string = ""
	for(var/att in prefixal_attributes)
		prefix_string += att + " "

	random_wand.name = prefix_string + item_type + " " + pick("of", "with") + " " + item_attribute

	random_wand.setup_destructability()

	return INITIALIZE_HINT_QDEL

#undef WAND_COL_RED
#undef WAND_COL_GREEN
#undef WAND_COL_BLUE
#undef WAND_COL_YELLOW
#undef WAND_COL_PURPLE
#undef WAND_COL_CYAN
#undef WAND_COL_PINK
#undef WAND_COL_ORANGE
#undef WAND_COL_TURQUOISE
