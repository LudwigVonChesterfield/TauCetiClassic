/obj/effect/portal/mage_portal
	name = "magic wormhole"
	icon_state = "anom"
	icon = 'icons/obj/objects.dmi'
	failchance = 0

	destroy_after_init = FALSE

	var/list/return_clothing = list()

/obj/effect/portal/mage_portal/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/portal/mage_portal/atom_init_late()
	var/obj/effect/portal/mage_portal/exit/E = locate() in portal_list
	target = E
	creator = null

/obj/effect/portal/mage_portal/on_teleport(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/effect/portal/mage_portal/E = target

		var/list/stripped_items = list()

		for(var/obj/item/I in H)
			stripped_items += I
			H.drop_from_inventory(I, E)

		if(H.ckey)
			E.return_clothing[H.ckey] = list()
			for(var/obj/item/I in stripped_items)
				E.return_clothing[H.ckey] += I

			if(return_clothing[H.ckey])
				for(var/obj/item/I in return_clothing[H.ckey])
					I.forceMove(H.loc)
					H.equip_to_appropriate_slot(I, FALSE)
				return_clothing -= H.ckey
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), SLOT_L_EAR)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), SLOT_HEAD)
				// H.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(H), SLOT_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/spellbook(H), SLOT_R_HAND)
				// H.equip_to_slot_or_del(new /obj/item/weapon/staff(H), SLOT_L_HAND)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box(H), SLOT_IN_BACKPACK)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/pouch/wand_pouch(H), SLOT_L_STORE)

/obj/effect/portal/mage_portal/exit
	// An assoc list with ckey = list(*clothing which was stripped when teleporting inside*)

/obj/effect/portal/mage_portal/exit/atom_init_late()
	target = get_target()
	creator = null

/obj/effect/portal/mage_portal/exit/on_teleport(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/effect/portal/mage_portal/MP = target

		var/list/stripped_items = list()

		for(var/obj/item/I in H)
			stripped_items += I
			H.drop_from_inventory(I, MP)

		if(H.ckey)
			MP.return_clothing[H.ckey] = list()
			for(var/obj/item/I in stripped_items)
				MP.return_clothing[H.ckey] += I

			if(return_clothing[H.ckey])
				for(var/obj/item/I in return_clothing[H.ckey])
					I.forceMove(H.loc)
					H.equip_to_appropriate_slot(I, FALSE)
				return_clothing -= H.ckey

/obj/effect/portal/mage_portal/exit/proc/get_target()
	var/list/allowed_portals = list()
	var/list/pos_portals = list() + portal_list
	pos_portals -= src
	for(var/obj/effect/portal/mage_portal/MP in pos_portals)
		allowed_portals += MP

	var/obj/effect/portal/mage_portal/MP = locate() in allowed_portals
	return MP

/obj/structure/closet/magic_closet
	name = "magic closet"
	desc = "It's a storage unit for all your magic crafting needs."
	icon_state = "acloset"
	icon_closed = "acloset"
	icon_opened = "aclosetopen"

	spawn_destruction_reagents = list("steel" = 80)

/obj/structure/closet/magic_closet/PopulateContents()
	new /obj/random/misc/spell(src)
	new /obj/random/misc/spell(src)
	new /obj/random/misc/spell(src)
	new /obj/random/misc/spell(src)
	new /obj/random/misc/spell(src)
	new /obj/random/misc/wand_component(src)
	new /obj/random/misc/wand_component(src)
	new /obj/random/misc/wand_component(src)
	new /obj/random/misc/wand(src)
	new /obj/random/misc/wand(src)
