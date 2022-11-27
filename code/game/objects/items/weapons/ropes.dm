/obj/item/rope
	name = "rope"
	desc = "What do you call a tangled rope on a Space Station? Astroknot."
	// desc = "No strings attached."

	force = 1.0

	icon = 'icons/obj/power.dmi'
	icon_state = "coil"

/obj/item/rope/atom_init()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MOUSEDROP_ONTO, .proc/try_tie_together)

/obj/item/rope/proc/try_tie_together(datum/source, atom/over, atom/from, mob/user)
	SIGNAL_HANDLER

	to_chat(world, "[source] [over] [from] [user]")

	if(!ismovable(from))
		return

	if(!user.in_interaction_vicinity(over))
		return
	if(!user.in_interaction_vicinity(from))
		return
	if(!over.Adjacent(from))
		return

	if(ismovable(over))
		over.AddComponent(/datum/component/bounded/rope, from, -1, 1, null, TRUE, FALSE, FALSE)

	from.AddComponent(/datum/component/bounded/rope, over, -1, 1, null, TRUE, FALSE, TRUE)

	qdel(src)
