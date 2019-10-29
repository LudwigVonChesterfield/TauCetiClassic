/obj/item/weapon/wand/example
	name = "examplar magic wand"
	desc = "A magic wand with magic and stuff."

	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullrod"
	item_state = "nullrod"

	always_casts_spell_type = /obj/item/spell/modifier/double_power

	spells_per_click = 1

	spells_slots = 4
	wand_components_slots = 4

	max_mana = 100
	passive_mana_charge = 2.0

	spell_cast_delay = 2
	spell_recharge_delay = 1.5 SECONDS
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/spray/water,
	                      /obj/item/spell/spray/sacid,
	                      /obj/item/spell/spray/water,
	                      /obj/item/spell/spray/sacid)

	default_wand_components = list(/obj/item/wand_component/selfcast,
	                               /obj/item/wand_component/otherscast)



/obj/item/weapon/wand/fire_fire_fire
	name = "pyromancer's cookwand"
	desc = "A magic wand that likes to play with fire."

	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullrod"
	item_state = "nullrod"

	spells_per_click = 2

	spells_slots = 2
	wand_components_slots = 1

	max_mana = 100
	passive_mana_charge = 4.0

	spell_cast_delay = 1
	spell_recharge_delay = 1 SECOND
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/spray/fuel,
	                      /obj/item/spell/projectile/fireball)

	default_wand_components = list(/obj/item/wand_component/otherscast)



/obj/item/weapon/wand/clowns_ultimatum
	name = "clown's ultimatum"
	desc = "A magic wand that likes to play with fire."

	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"

	always_casts_spell_type = /obj/item/spell/spray/lube

	spells_per_click = 1

	spells_slots = 6
	wand_components_slots = 2

	max_mana = 100
	passive_mana_charge = 2.0

	spell_cast_delay = 2
	spell_recharge_delay = 1 SECOND
	spell_queue_type = WAND_QUEUE_RANDOM

	default_spells = list(/obj/item/spell/spray/lube,
	                      /obj/item/spell/earthquake,
	                      /obj/item/spell/passive/forcefield)

	default_wand_components = list(/obj/item/wand_component/otherscast,
	                               /obj/item/wand_component/passivecast)



/obj/item/weapon/wand/dah_lazur
	name = "dah muh lazur wand"
	desc = "Wut is logek? I kent tell..."

	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"

	spells_per_click = 1

	spells_slots = 2
	wand_components_slots = 2

	max_mana = 200
	passive_mana_charge = 4.0

	spell_cast_delay = 1
	spell_recharge_delay = 2
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/projectile/muh_lazur/trigger,
	                      /obj/item/spell/on_caster/explosion)

	default_wand_components = list(/obj/item/wand_component/otherscast)



/obj/item/weapon/wand/trifecta
	name = "trifecta stick"
	desc = "Double the trouble... And make it triple!"

	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullrod"
	item_state = "nullrod"

	always_casts_spell_type = /obj/item/spell/modifier/heavy_shot

	spells_per_click = 1

	spells_slots = 4
	wand_components_slots = 3

	max_mana = 200
	passive_mana_charge = 6.0

	spell_cast_delay = 2
	spell_recharge_delay = 0.5 SECONDS
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/modifier/trifuscated,
	                      /obj/item/spell/projectile/muh_lazur/trigger,
	                      /obj/item/spell/projectile/muh_lazur/trigger,
	                      /obj/item/spell/projectile/muh_lazur/trigger)

	default_wand_components = list(/obj/item/wand_component/otherscast)



/obj/item/weapon/wand/mimetic
	name = "panthomime's adobe"
	desc = "A magic wand that allows for... Advanced panthomime."

	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"

	spells_per_click = 1

	spells_slots = 6
	wand_components_slots = 2

	max_mana = 300
	passive_mana_charge = 1.0

	spell_cast_delay = 10
	spell_recharge_delay = 2 SECONDS
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/conjure/mime/wall,
	                      /obj/item/spell/conjure/mime/chair,
	                      /obj/item/spell/conjure/mime/janicart,
	                      /obj/item/spell/conjure/mime/closet,
	                      /obj/item/spell/passive/mimefield)

	default_wand_components = list(/obj/item/wand_component/otherscast,
	                               /obj/item/wand_component/passivecast)



/obj/item/weapon/wand/seal
	name = "seal wand"
	desc = "A magic wand that seals all up."

	icon = 'icons/obj/weapons.dmi'
	icon_state = "nullrod"
	item_state = "nullrod"

	spells_per_click = 1

	spells_slots = 6
	wand_components_slots = 2

	max_mana = 300
	passive_mana_charge = 4.0

	spell_cast_delay = 1
	spell_recharge_delay = 2 SECONDS
	spell_queue_type = WAND_QUEUE_ORDER

	default_spells = list(/obj/item/spell/spray/water/trigger,
	                      /obj/item/spell/modifier/clone_next_spell,
	                      /obj/item/spell/on_caster/forcefield)

	default_wand_components = list(/obj/item/wand_component/otherscast)
