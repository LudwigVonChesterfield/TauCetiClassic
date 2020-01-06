/obj/item/weapon/wand/AltClickAction(atom/target, mob/user)
	if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	var/list/pos_wand_pouch_locs = list(H.l_store, H.r_store, H.belt, H.l_hand, H.r_hand)
	var/obj/item/weapon/storage/pouch/wand_pouch/P = locate() in pos_wand_pouch_locs
	if(P && P.contents.len)
		// Always takes out first in storage.
		// if(P.selected_wand >= P.contents.len)
		//	P.selected_wand = P.contents.len
		var/obj/item/weapon/wand/new_wand = P.contents[P.selected_wand]
		P.remove_from_storage(new_wand, user)
		P.handle_item_insertion(src, TRUE, FALSE)
		user.put_in_hands(new_wand)
		return TRUE
	return FALSE

/obj/item/weapon/storage/pouch/wand_pouch
	name = "wand pouch"
	desc = "A pouch for your magical needs. Can hold four wands."
	icon_state = "large_generic"
	item_state = "large_generic"
	w_class = ITEM_SIZE_NORMAL

	storage_slots = 4
	max_w_class = ITEM_SIZE_GARGANTUAN

	can_hold = list(
		/obj/item/weapon/wand
		)

	var/selected_wand = 1
