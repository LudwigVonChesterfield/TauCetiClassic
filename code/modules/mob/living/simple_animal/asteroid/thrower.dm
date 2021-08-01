/obj/item/weapon/reagent_containers/food/snacks/egg/random_alcohol/atom_init()
	. = ..()
	// Have either an interesting effect, or are a favored drink of this snippet's author.
	var/static/list/pos_reagents = list(
		"silencer" = 5,
		"iced_beer" = 3,
		"sbiten" = 3,
		"manhattan_proj" = 3,
		"beepskysmash" = 1,
		"pwine" = 1,
		"vodka" = 7,
		"absinthe" = 5,
		"beer" = 10,
		"wine" = 9,
	)
	var/reagent = pickweight(pos_reagents)
	var/amount = rand(1, reagents.maximum_volume - reagents.total_volume)

	reagents.add_reagent(reagent, amount)

/obj/item/weapon/storage/backpack/throwerbag
	name = "Very Giant Big Bag"
	desc = "A bag that is very big."
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = ITEM_SIZE_HUGE
	max_w_class = ITEM_SIZE_LARGE
	max_storage_space = 40

/mob/living/simple_animal/hostile/asteroid/thrower
	name = "thrower"
	desc = "Blah blah blah flavor text."

	icon = 'icons/mob/monsters.dmi'

	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"

	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	maxHealth = 150
	health = 150

	harm_intent_damage = 7

	melee_damage = 1
	attacktext = "push"

	throw_message = "hits"

	environment_smash = 1

	move_to_delay = 8
	speed = 0

	ranged = TRUE
	ranged_message = null

	// Gives the player a bit of leeway to run away.
	ranged_cooldown = 1
	ranged_cooldown_cap = 3

	friendly = "stares at"
	vision_range = 7

	loot_list = list()

	aggro_vision_range = 9
	idle_vision_range = 7

	min_ranged_dist = 0

	amount_shoot = 2

	var/stamina = 100

	var/loaded_thing = FALSE

	var/obj/item/weapon/storage/backpack/bag

/mob/living/simple_animal/hostile/asteroid/thrower/atom_init()
	. = ..()
	create_bag()
	fill_bag()

/mob/living/simple_animal/hostile/asteroid/thrower/Destroy()
	QDEL_NULL(bag)
	return ..()

/mob/living/simple_animal/hostile/asteroid/thrower/proc/AdjustStaminaLoss(amount)
	stamina -= amount

	if(stamina <= 0)
		stamina = 0
		stance = HOSTILE_STANCE_TIRED
		fill_bag()
		emote("gasp")

/mob/living/simple_animal/hostile/asteroid/thrower/proc/create_bag()
	bag = new /obj/item/weapon/storage/backpack/throwerbag(src)
	bag.add_fingerprint(src)

/mob/living/simple_animal/hostile/asteroid/thrower/proc/fill_bag()
	// A list of things that are either interesting to throw
	// or make general sense to have in your bag.
	var/list/throwables = list(
		/obj/item/stack/rods = 30,
		/obj/item/toy/minimeteor = 20,
		/obj/item/weapon/grenade/cancasing = 20,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 16,
		/obj/item/weapon/shard = 16,
		/obj/item/weapon/legcuffs/bola = 15,
		/obj/item/weapon/legcuffs/beartrap = 15,
		/obj/item/weapon/light/tube = 15,
		/obj/item/weapon/light/bulb = 15,
		/obj/item/device/assembly/mousetrap = 12,
		/obj/random/misc/all/guaranteed = 10,
		/obj/item/weapon/reagent_containers/food/snacks/egg/random_alcohol = 10,
		/obj/item/weapon/bananapeel = 10,
		/obj/item/toy/snappop = 8,
		/obj/item/weapon/twohanded/spear = 8,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 8,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/beer = 8,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 8,
		/obj/item/weapon/lighter = 8,
		/obj/item/weapon/grenade/flashbang = 8,
		/obj/item/weapon/grenade/smokebomb = 8,
		/obj/item/weapon/grenade/empgrenade = 8,
		/obj/item/mine/incendiary = 8,
		/obj/item/mine/emp = 8,
		/obj/item/mine/shock = 8,
		/obj/item/weapon/soap = 6,
		/obj/item/weapon/dice/d2 = 6,
		/obj/item/weapon/dice = 6,
		/obj/item/weapon/dice/d20 = 6,
		/obj/item/weapon/reagent_containers/food/snacks/pie = 4,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 4,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato = 4,
		/obj/item/bluespace_crystal = 2,
		/obj/item/weapon/reagent_containers/syringe = 2,
		/obj/item/clothing/mask/facehugger_toy = 2,
		/obj/item/weapon/match = 2,
		/obj/item/device/flashlight/on = 2,
		/obj/item/device/flashlight = 1,
		// grenades are cool but they need to be primed and this mob is not about that :(
	)

	var/area/asteroid/mine/biome/biome = get_area(src)
	if(istype(biome))
		for(var/res_list in biome.resources_to_spawn)
			for(var/thing_type in res_list)
				if(!ispath(thing_type, /obj/item))
					continue
				var/chance = 1.0
				if(res_list["chance"])
					chance = res_list["chance"]

				if(!throwables[thing_type])
					throwables[thing_type] = 0
				throwables[thing_type] += res_list[thing_type] * chance * 5.0

	var/obj/randomcatcher/CATCHER = new

	for(var/i in 1 to 20)
		var/thing_type = pickweight(throwables)
		var/obj/item/I = CATCHER.get_item(thing_type)

		if(!I)
			continue

		if(prob(30))
			I.make_old()
		if(prob(1))
			I.prototipify(min_reliability=0, max_reliability=150)

		I.add_fingerprint(src)

		if(!bag.can_be_inserted(I, stop_messages=TRUE))
			qdel(I)
			break

		bag.handle_item_insertion(I, prevent_warning=TRUE, NoUpdate=TRUE)

/mob/living/simple_animal/hostile/asteroid/thrower/emote(act = "", message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	var/cloud_emote = ""

	switch(act)
		if("scream")
			message_type = SHOWMSG_AUDIO
			message = pick("screams loudly!", "screams!")

			if(auto)
				message = pick("screams in agony!", "writhes in heavy pain and screams!", "screams in pain loudly!")

			cloud_emote = "cloud-scream"
			add_combo_value_all(10)

		if("gasp")
			message_type = SHOWMSG_AUDIO
			cloud_emote = "cloud-gasp"
			message = "gasps!"

		else
			return ..()

	if(message_type & SHOWMSG_VISUAL)
		visible_message("<B>[src]</B> [message]", ignored_mobs = observer_list)
	else if(message_type & SHOWMSG_AUDIO)
		audible_message("<B>[src]</B> [message]", ignored_mobs = observer_list)

	log_emote("[key_name(src)] : [message]")

	for(var/mob/M in observer_list)
		if(!M.client)
			continue // skip leavers
		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				to_chat(M, "[FOLLOW_LINK(M, src)] <B>[src]</B> [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(!auto)
					to_chat(M, "[FOLLOW_LINK(M, src)] <B>[src]</B> [message]")

	if(cloud_emote)
		var/image/emote_bubble = image('icons/mob/emote.dmi', src, cloud_emote, EMOTE_LAYER)
		emote_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		flick_overlay(emote_bubble, clients, 30)
		QDEL_IN(emote_bubble, 3 SECONDS)

/mob/living/simple_animal/hostile/asteroid/thrower/death(gibbed)
	..()
	bag.forceMove(loc)
	bag = null

/mob/living/simple_animal/hostile/asteroid/thrower/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!bag)
		var/obj/item/weapon/storage/backpack/throwerbag/TB = locate() in loc
		bag = TB
		TB.forceMove(src)

	if(!bag)
		return

	for(var/obj/item/I in loc)
		I.add_fingerprint(src)
		if(!bag.can_be_inserted(I))
			continue

		bag.handle_item_insertion(I, NoUpdate=TRUE)

/mob/living/simple_animal/hostile/asteroid/thrower/HandleRest()
	stop_automated_movement = TRUE
	AdjustStaminaLoss(-15)

	if(stamina >= 100)
		stamina = 100
		stop_automated_movement = FALSE

		if(target && (target in ListTargets(10)))
			stance = HOSTILE_STANCE_ATTACK
		else
			stance = HOSTILE_STANCE_IDLE

// For your cool thrower variations you can make so they assess the strength of an item first.
/mob/living/simple_animal/hostile/asteroid/thrower/proc/assess_throwability(atom/movable/thing, atom/movable/remembered_thing)
	if(!Adjacent(thing))
		return remembered_thing

	if(istype(thing, /mob/living) && !thing.anchored)
		loaded_thing = TRUE
		return thing

	if(istype(thing, /obj/structure) && !thing.anchored)
		return thing

	if(istype(thing, /obj/item) && !istype(remembered_thing, /obj/structure) && !thing.anchored)
		return thing

	return remembered_thing

/mob/living/simple_animal/hostile/asteroid/thrower/proc/assess_stamina_waste(atom/movable/thing)
	if(istype(thing, /mob/living))
		return 2 ** ITEM_SIZE_GARGANTUAN

	if(istype(thing, /obj/structure))
		return 2 ** ITEM_SIZE_HUGE

	if(istype(thing, /obj/item))
		var/obj/item/I = thing
		return 2 ** I.w_class

	return 0

/mob/living/simple_animal/hostile/asteroid/thrower/proc/take_thing_out()
	if(!bag)
		return null

	if(bag.contents.len == 0)
		return null

	var/atom/movable/thing = bag.contents[1]
	bag.remove_from_storage(thing, loc, NoUpdate=TRUE)
	return thing

/mob/living/simple_animal/hostile/asteroid/thrower/proc/get_throwable_thing()
	var/atom/movable/to_throw
	for(var/atom/movable/AM in oview(1, src))
		to_throw = assess_throwability(AM, to_throw)
		if(loaded_thing)
			loaded_thing = FALSE
			break

	if(!to_throw)
		to_throw = take_thing_out()

	return to_throw

/mob/living/simple_animal/hostile/asteroid/thrower/proc/prepare_throwable_thing(atom/thing)
	if(istype(thing, /obj/item/weapon/grenade))
		var/obj/item/weapon/grenade/G = thing
		G.activate(src)

	else if(istype(thing, /obj/item/mine))
		var/obj/item/mine/M = thing
		M.anchor_on_impact = TRUE

	else if(istype(thing, /obj/item/device/assembly/mousetrap))
		var/obj/item/device/assembly/mousetrap/M = thing
		M.icon_state = "mousetraparmed"
		M.armed = TRUE

	else if(istype(thing, /obj/item/weapon/legcuffs/beartrap))
		var/obj/item/weapon/legcuffs/beartrap/B = thing
		B.icon_state = "beartrap1"
		B.armed = TRUE

	else if(istype(thing, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = thing
		if(M.lit || M.burnt)
			return

		if(prob(20))
			playsound(src, 'sound/items/matchstick_hit.ogg', VOL_EFFECTS_MASTER, 20)
			return

		playsound(src, 'sound/items/matchstick_light.ogg', VOL_EFFECTS_MASTER, 20)
		M.lit = TRUE
		M.damtype = "burn"
		M.icon_state = "match_lit"
		START_PROCESSING(SSobj, M)
		M.update_icon()

	else if(istype(thing, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = thing
		if(!L.lit)
			L.lit = TRUE
			L.icon_state = L.icon_on
			L.item_state = L.icon_on

			if(istype(L, /obj/item/weapon/lighter/zippo) )
				playsound(src, 'sound/items/zippo.ogg', VOL_EFFECTS_MASTER, 25)
				visible_message("<span class='notice'>Without even breaking stride, [src] flips open and lights [L] in one smooth movement.</span>")
			else
				playsound(src, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
				visible_message("<span class='notice'>After a few attempts, [src] manages to light the [L].</span>")

			L.set_light(2)
			START_PROCESSING(SSobj, L)

/mob/living/simple_animal/hostile/asteroid/thrower/start_shoot(the_target)
	emote("scream")
	sleep(2)

	var/tturf
	for(var/i in 1 to amount_shoot)
		tturf = get_turf(the_target) // need for refresh target location between shoots
		if(prob((i - 1) * 100 / amount_shoot))
			tturf = get_step(tturf, pick(cardinal))
		sleep(6)
		Shoot(tturf, src.loc, src)
		if(casingtype)
			new casingtype(get_turf(src))

/mob/living/simple_animal/hostile/asteroid/thrower/Shoot(target, start, user, bullet = 0)
	if(target == start)
		return

	var/atom/movable/AM = get_throwable_thing()
	if(!AM)
		AdjustStaminaLoss(-100)
		return

	SEND_SIGNAL(src, COMSIG_MOB_HOSTILE_SHOOT, target)

	visible_message("<span class='rose'>[src] has thrown [AM].</span>")

	if(isitem(AM))
		var/obj/item/O = AM
		if(O.w_class >= ITEM_SIZE_NORMAL)
			playsound(loc, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)

	else
		playsound(loc, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)

	AM.add_fingerprint(src)

	do_attack_animation(target, has_effect = FALSE)

	newtonian_move(get_dir(target, src))

	prepare_throwable_thing(AM)
	AdjustStaminaLoss(assess_stamina_waste(AM))
	AM.throw_at(target, aggro_vision_range, harm_intent_damage, src, spin=TRUE)
