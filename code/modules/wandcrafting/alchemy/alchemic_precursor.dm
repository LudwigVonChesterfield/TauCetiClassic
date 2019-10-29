var/global/list/alchemic_precursor_recipes = list()

var/global/list/pos_alchemic_precursor_reagents = list(
	"water",
	"holywater",
	"unholywater",
	"copper",
	"mercury",
	"sugar",
	"iron",
	// All things that react to precursor can't be it's components.
	// "gold",
	"silver",
	"orangejuice",
	"tomatojuice",
	"limejuice",
	"carrotjuice",
	"berryjuice",
	"grapejuice",
	"watermelonjuice",
	"lemonjuice",
	"banana",
	"nothing",
	"potato",
	"milk",
	"soymilk",
	"cream",
	"grenadine",
	"coffee",
	"tea",
	"ice",
	"Honey",
	"beer",
	"whiskey",
	"gin",
	"rum",
	"champagne",
	"tequilla",
	"vermouth",
	"wine",
	"cognac",
	"ale",
	"absinthe",
	"pwine",
	"sake",
	"nutriment",
	"protein",
	"plantmatter",
	"dairy",
	"flour",
	"sodiumchloride",
	"blackpepper",
	"rice",
	"egg",
	"cheese",
	"vitamin",
	"blood",
	"nicotine",
	"ammonia",
	// "ectoplasm",
	)

/obj/machinery/chem_dispenser/alchemic_precursor/atom_init()
	dispensable_reagents = list() + pos_alchemic_precursor_reagents
	. = ..()

/datum/chemical_reaction/alchemic_precursor
	name = "Alchemic Precursor"
	id = "alchemic_precursor"
	result = "alchemic_precursor"

	required_reagents = list()
	required_catalysts = list()

	// required_container = /obj/structure/rune_pot

	result_amount = 0
	secondary_results = list() //additional reagents produced by the reaction
	// requires_heating = TRUE

/datum/chemical_reaction/mana_catalyst
	name = "Mana Catalyst"
	id = "mana_catalyst"
	result = "mana_catalyst"
	required_reagents = list("gold" = 1, "alchemic_precursor" = 1)
	result_amount = 2.0

/proc/set_alchemic_precursor_recipes()
	var/list/usable_reags = list() + global.pos_alchemic_precursor_reagents
	for(var/i in 1 to 7)
		var/datum/chemical_reaction/alchemic_precursor/AP = new()

		var/create_am = 0

		while(AP.required_reagents.len < 3)
			if(usable_reags.len == 0)
				break

			var/new_reag = pick(usable_reags)
			for(var/datum/chemical_reaction/rem_recipe in global.chemical_reactions_list[new_reag])
				for(var/rem_reag in rem_recipe.required_reagents)
					if(rem_reag in usable_reags)
						usable_reags -= rem_reag

			var/reag_am = rand(1, 3)
			AP.required_reagents[new_reag] = reag_am
			create_am += reag_am

		AP.result_amount = create_am

		global.alchemic_precursor_recipes += AP
		for(var/req_reag in AP.required_reagents)
			if(global.chemical_reactions_list[req_reag])
				global.chemical_reactions_list[req_reag] += AP
			else
				global.chemical_reactions_list[req_reag] = list(AP)
			break

/datum/reagent/alchemic_precursor
	name = "Alchemic Precursor"
	id = "alchemic_precursor"
	description = "A mysterious reagent that is required to brew advanced potions."
	reagent_state = LIQUID
	color = "#5fafde" // rgb: 95, 175, 222
	taste_message = "<font color='purple'>magic</font>"

	density = 1.0

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 1.0,
	                         "other" = 0.0)

/datum/reagent/mana_catalyst
	name = "Mana Catalyst"
	id = "mana_catalyst"
	description = "Catalyst required for convertion of anything into mana."
	reagent_state = LIQUID
	color = "#d3de5f" // rgb: 211, 222, 95
	taste_message = "<font color='purple'>magic</font>"

	density = 1.0

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 1.0,
	                         "other" = 0.0)

/obj/item/weapon/reagent_containers/glass/bottle/mana_catalyst
	name = "mana catalyst bottle"
	desc = "A small bottle of mana catalyst."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/mana_catalyst/atom_init()
	. = ..()
	reagents.add_reagent("mana_catalyst", 30)

/obj/item/weapon/paper/alchemic_precursor_recipe
	name = "a recipe of success"

/obj/item/weapon/paper/alchemic_precursor_recipe/atom_init()
	. = ..()
	get_ap_recipe()

/obj/item/weapon/paper/alchemic_precursor_recipe/proc/get_ap_recipe()
	var/dat = "The first step to success is<br>"
	dat += "<center><b>The Alchemic Precursor</b></center><br>"

	var/datum/chemical_reaction/alchemic_precursor/AP = pick(global.alchemic_precursor_recipes)
	var/first = TRUE
	for(var/reag in AP.required_reagents)
		var/datum/reagent/R = global.chemical_reagents_list[reag]
		if(first)
			dat += capitalize(lowertext(R.name))
			first = FALSE
		else
			dat += ", " + lowertext(R.name)
	info = dat

	/*
	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "This paper has been stamped by the Mage Federation.")
	*/

	update_icon()
	updateinfolinks()
