/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

	outdoors = TRUE

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/asteroid/mine/biome/asteroids/explored
	name = "Mine"
	icon_state = "explored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)


/area/asteroid/mine/biome/asteroids/unexplored
	name = "Mine"
	icon_state = "unexplored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)

/area/asteroid/mine/biome/asteroids/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/maintenance
	name = "Mining Station Communications"

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/west_outpost
	name = "West Mining Outpost"

	outdoors = FALSE

/area/asteroid/mine/biome/asteroids/dwarf
	name = "Dwarf"
	icon_state = "dwarf"

	outdoors = FALSE



/area/asteroid/mine/biome
	var/basetype_turf = /turf/simulated/floor/plating/airless/asteroid
	var/cave_chance = 2
	var/cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave

	var/rock_name = "Rock"
	var/rock_icon_state = "rock"
	var/side_icon_state = "rock"
	var/mineral_icon_state = "rock"
	var/rock_hits_to_break

	var/enforce_air = FALSE

	var/oxygen = 0.01
	var/nitrogen = 0.01

	var/temperature = TCMB

	var/list/mobs_to_spawn

	var/list/resources_to_spawn

	var/fertility = 0.0

/area/asteroid/mine/biome/proc/SpawnEverything(turf/T)
	SpawnMonsters(T)
	SpawnResources(T)

/area/asteroid/mine/biome/proc/SpawnMonsters(turf/T)
	return

/area/asteroid/mine/biome/proc/SpawnTraps(turf/T)
	return

/area/asteroid/mine/biome/proc/SpawnResources(turf/T)
	if(!resources_to_spawn)
		return

	var/list/resources = pick(resources_to_spawn)
	var/chance = 100
	if(resources["chance"])
		chance = resources["chance"]

	if(!prob(chance))
		return

	for(var/resource in resources)
		if(resource == "chance")
			continue
		if(!prob(resources[resource]))
			continue

		new resource(T)

/area/asteroid/mine/biome/proc/air_check(turf/T, check_dirs)
	for(var/d in check_dirs)
		var/turf/to_check = get_step(T, d)

		var/area/asteroid/mine/biome/other = get_area(to_check)
		if(!istype(other))
			if(enforce_air)
				return FALSE
			continue
		if(!enforce_air && !other.enforce_air)
			continue

		if(istype(to_check, /turf/space))
			return FALSE

		if(other.temperature != temperature)
			return FALSE

		if(other.oxygen != oxygen)
			return FALSE
		if(other.nitrogen != nitrogen)
			return FALSE

	return TRUE

/area/asteroid/mine/biome/proc/change_wall(turf/simulated/mineral/W)
	W.oxygen = oxygen
	W.nitrogen = nitrogen

	W.rock_name = rock_name
	W.rock_icon_state = rock_icon_state
	W.side_icon_state = side_icon_state
	W.mineral_icon_state = mineral_icon_state

	W.hits_to_break = rock_hits_to_break

	W.basetype = basetype_turf

/area/asteroid/mine/biome/proc/change_floor(turf/simulated/floor/F)
	F.oxygen = oxygen
	F.nitrogen = nitrogen

	F.fertility = fertility

	F.basetype = basetype_turf

/area/asteroid/mine/biome/breathable
	enforce_air = TRUE

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

	fertility = 0.5

	temperature = T20C

	basetype_turf = /turf/simulated/floor/plating/rustsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/rustsand

/turf/simulated/floor/plating/airless/asteroid/cave/rustsand
	basetype = /turf/simulated/floor/plating/rustsand

/turf/simulated/floor/plating/airless/asteroid/cave/snow
	basetype = /turf/simulated/floor/plating/snow

/area/asteroid/mine/biome/breathable/normal
	name = "Normal"
	icon_state = "ast-normal-biome"

/area/asteroid/mine/biome/breathable/fungal
	name = "Fungal"
	icon_state = "ast-fungal-biome"

	cave_chance = 3

	resources_to_spawn = list(
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom = 1),
		list(/obj/random/scrap/moderate_weighted = 1),
	)

/area/asteroid/mine/biome/breathable/glow_cave
	name = "Glow Cave"
	icon_state = "ast-glow_cave-biome"

	cave_chance = 3

	resources_to_spawn = list(
		list(/obj/effect/glowshroom = 1)
	)

/area/asteroid/mine/biome/dark_horror
	name = "Dark Horror"
	icon_state = "ast-dark_horror-biome"

	rock_icon_state = "rock-dark"

	rock_hits_to_break = 4

	fertility = 0.1

/area/asteroid/mine/biome/breathable/ice
	name = "Ice"
	icon_state = "ast-ice-biome"

	cave_chance = 4

	basetype_turf = /turf/simulated/floor/plating/snow
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/snow

	rock_name = "Ice"

	rock_icon_state = "ice"
	side_icon_state = null

	temperature = T0C - 40

	resources_to_spawn = list(
		list(/obj/item/snowball = 2),
		list(/obj/item/decoration/snowflake = 5),
		list("chance" = 10,
			/obj/item/decoration/snowman = 1,
		)
	)

/area/asteroid/mine/biome/breathable/lor
	name = "Lots of Resources"
	icon_state = "ast-resources-biome"

/area/asteroid/mine/biome/breathable/hollow_horror
	name = "Hollow Horror"
	icon_state = "ast-hollow_horror-biome"

	resources_to_spawn = list(
		list(
			"chance" = 50,
			/obj/item/device/soulstone = 1,
		),
		list(
			/obj/item/weapon/reagent_containers/food/snacks/ectoplasm = 1,
		)
	)

/area/asteroid/mine/biome/asteroids
	name = "Asteroids"
	icon_state = "ast-asteroids-biome"

	rock_icon_state = "rock-dark"

	fertility = 1.0

/area/asteroid/mine/biome/asteroids/dark
	rock_icon_state = "rock-dark"
	rock_hits_to_break = 4

/area/asteroid/mine/biome/breathable/asteroids
	name = "Asteroids (breathable)"
	icon_state = "ast-asteroids-biome"

/area/asteroid/mine/biome/breathable/ruins
	name = "Ruins"
	icon_state = "ast-ruins-biome"

	resources_to_spawn = list(
		list(/obj/random/misc/all = 2),
		list(/obj/random/scrap/moderate_weighted = 7),
		list(
			"chance" = 1,
			/obj/random/scrap/moderate_weighted = 100,
			/obj/item/mine/shock/anchored=100
			),
		list(
			"chance" = 1,
			/obj/random/scrap/moderate_weighted = 100,
			/obj/item/mine/incendiary/anchored=100
			),
		list(/obj/item/mine/shock/anchored = 3),
		list(/obj/item/mine/incendiary/anchored = 3),
	)

/area/asteroid/mine/biome/breathable/flesh
	name = "Flesh"
	icon_state = "ast-flesh-biome"

	cave_chance = 3

/area/asteroid/mine/biome/boney_creaks
	name = "Boney Creaks"
	icon_state = "ast-boney_hills-biome"

	rock_icon_state = "rock-dark"

	rock_hits_to_break = 4

	fertility = 2.0

	resources_to_spawn = list(
		list(
			"chance" = 3,
			/obj/structure/pit/closed/grave = 90,
			/obj/structure/gravemarker = 70
		),
		list(
			"chance" = 10,
			/obj/item/device/soulstone = 1,
		)
	)
