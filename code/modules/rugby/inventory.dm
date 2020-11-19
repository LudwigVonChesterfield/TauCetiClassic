var/global/list/inventory_crates_by_class = list()

/obj/structure/closet/crate/class_inventory
	var/class_name = ""

/obj/structure/closet/crate/class_inventory/atom_init()
	. = ..()
	name = "[class_name] Equipment"
	if(inventory_crates_by_class[class_name])
		world.log << "Located duplicates of [class_name] inventory crates."
		to_chat(world, "<span class='warning bold'>Located duplicates of [class_name] inventory crates.</span>")
		qdel(inventory_crates_by_class[class_name])

	inventory_crates_by_class[class_name] = src
