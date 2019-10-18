/atom/proc/get_size()
	return 32.0

/obj/structure/stool/bed/chair/get_size()
	return 4.0

/obj/structure/closet/get_size()
	return storage_capacity

/obj/item/get_size()
	return w_class

/turf/get_size()
	return 32.0

/mob/living/carbon/human/get_size()
	. = 0
	for(var/obj/item/organ/external/BP in bodyparts)
		. += BP.w_class

/atom/proc/get_mass()
	return (get_size() * total_density) / 1000.0