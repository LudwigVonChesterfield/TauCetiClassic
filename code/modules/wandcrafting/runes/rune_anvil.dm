/obj/structure/table/rune_anvil
	name = "runic anvil"
	desc = "Put runes on it, and any damage to them will result in their split."

	icon = 'icons/obj/spell_structures.dmi'
	icon_state = "talismanaltar"

	smooth = SMOOTH_FALSE

	flipable = FALSE

	spawn_destruction_reagents = list("iron" = 80, "stone" = 20)

/obj/structure/table/rune_anvil/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		if(user.is_busy())
			return
		if(anchored)
			user.visible_message("[user] unsecures \the [src].", "You start to unsecure \the [src] from the floor.")
		else
			user.visible_message("[user] secures \the [src].", "You start to secure \the [src] to the floor.")

		if(I.use_tool(src, user, 40, volume = 50))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secured \the [src]!</span>")
			anchored = !anchored
	else
		..()
