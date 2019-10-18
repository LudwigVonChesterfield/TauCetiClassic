/datum/storage_ui/wands
	var/list/is_seeing = list() //List of mobs which are currently seeing the contents of this item's storage

	var/obj/screen/storage/boxes
	var/obj/screen/close/closer

	var/list/storage_list = list()
	var/slots = 0

/datum/storage_ui/wands/New(storage, storage_list, slots)
	..()
	src.storage_list = storage_list
	src.slots = slots

	boxes = new /obj/screen/storage()
	boxes.name = "storage"
	boxes.master = storage
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE

	closer = new /obj/screen/close()
	closer.master = storage
	closer.icon_state = "x"
	closer.layer = HUD_LAYER
	closer.plane = HUD_PLANE

/datum/storage_ui/wands/Destroy()
	close_all()
	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	. = ..()

/datum/storage_ui/wands/on_open(mob/user)
	if(user.s_active)
		user.s_active.close(user)

/datum/storage_ui/wands/after_close(mob/user)
	user.s_active = null

/datum/storage_ui/wands/on_insertion(mob/user, obj/item/I)
	//if(user.s_active)
	//	user.s_active.show_to(user)
	for(var/mob/M in can_see_contents())
		M.s_active.show_to(M)

/datum/storage_ui/wands/on_pre_remove(mob/user, obj/item/W)
	for(var/mob/M in can_see_contents())
		if(M.client)
			M.client.screen -= W

/datum/storage_ui/wands/on_post_remove(mob/user)
	if(user.s_active)
		user.s_active.show_to(user)

/datum/storage_ui/wands/on_hand_attack(mob/user)
	for(var/mob/M in range(1))
		if(M.s_active == storage)
			storage.close(M)

/datum/storage_ui/wands/show_to(mob/user)
	if(user.s_active)
		user.s_active.hide_from(user)

	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= storage_list
	user.client.screen += closer
	user.client.screen += storage_list
	user.client.screen += boxes

	is_seeing |= user
	user.s_active = storage

/datum/storage_ui/wands/hide_from(mob/user)
	is_seeing -= user
	if(!user.client)
		return

	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= storage_list
	if(user.s_active == storage)
		user.s_active = null

//Creates the storage UI
/datum/storage_ui/wands/prepare_ui()
	//if storage slots is null then use the storage space UI, otherwise use the slots UI
	slot_orient_objs()

/datum/storage_ui/wands/close_all()
	for(var/mob/M in can_see_contents())
		close(M)
		. = 1

/datum/storage_ui/wands/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == storage && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/datum/storage_ui/wands/proc/slot_orient_objs()
	var/adjusted_contents = storage_list.len
	click_border_start.Cut()
	click_border_end.Cut()

	var/row_num = 0
	var/col_count = min(7, slots) - 1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents - 1) / 7) // 7 is the maximum allowed width.
	arrange_item_slots(row_num, col_count)

//This proc draws out the inventory and places the items on it. It uses the standard position.
/datum/storage_ui/wands/proc/arrange_item_slots(var/rows, var/cols)
	var/cx = 4
	var/cy = 2 + rows
	boxes.screen_loc = "4:16,2:16 to [4 + cols]:16,[2 + rows]:16"

	for(var/obj/O in storage_list)
		O.screen_loc = "[cx]:16,[cy]:16"
		O.maptext = ""
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		cx++
		if(cx > (4+cols))
			cx = 4
			cy--

	closer.screen_loc = "[4+cols+1]:16,2:16"
