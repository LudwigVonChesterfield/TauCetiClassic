/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

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

/area/asteroid/mine/biome/asteroids/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/asteroid/mine/biome/asteroids/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/asteroid/mine/biome/asteroids/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/asteroid/mine/biome/asteroids/maintenance
	name = "Mining Station Communications"

/area/asteroid/mine/biome/asteroids/west_outpost
	name = "West Mining Outpost"

/area/asteroid/mine/biome/asteroids/dwarf
	name = "Dwarf"
	icon_state = "dwarf"



/area/asteroid/mine/biome
	var/basetype_turf = /turf/simulated/floor/plating/airless/asteroid
	var/cave_chance = 2
	var/cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave

	var/rock_name = "Rock"
	var/rock_icon_state = "rock"
	var/side_icon_state = "rock"
	var/mineral_icon_state = "rock"

	var/enforce_air = FALSE

	var/oxygen = 0.01
	var/nitrogen = 0.01

	var/temperature = TCMB

	var/mob_chance = 30
	var/list/mobs_to_spawn

	var/resource_chance = 10
	var/list/resources_to_spawn

/area/asteroid/mine/biome/proc/SpawnEverything(turf/T)
	if(mob_chance)
		SpawnMonsters(T)
	if(resource_chance)
		SpawnResources(T)

/area/asteroid/mine/biome/proc/SpawnMonsters(turf/T)
	return

/area/asteroid/mine/biome/proc/SpawnTraps(turf/T)
	return

/area/asteroid/mine/biome/proc/SpawnResources(turf/T)
	if(!resources_to_spawn)
		return

	var/resource = pickweight(resources_to_spawn)
	new resource(T)

/area/asteroid/mine/biome/proc/air_check(turf/T, check_dirs)
	if(!enforce_air)
		return TRUE

	for(var/d in check_dirs)
		var/turf/to_check = get_step(T, d)
		if(istype(to_check, /turf/space))
			return FALSE

		if(istype(to_check, /turf/simulated/floor))
			var/turf/simulated/floor/F = to_check
			if(F.oxygen < oxygen || F.nitrogen < nitrogen)
				return FALSE
			if(F.temperature < temperature)
				return FALSE

	return TRUE

/area/asteroid/mine/biome/breathable
	enforce_air = TRUE

	oxygen = 0.01
	nitrogen = 0.01

	temperature = T20C

	basetype_turf = /turf/simulated/floor/plating/rustsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/rustsand

/area/asteroid/mine/biome/proc/change_wall(turf/simulated/mineral/W)
	W.oxygen = oxygen
	W.nitrogen = nitrogen

	W.rock_name = rock_name
	W.rock_icon_state = rock_icon_state
	W.side_icon_state = side_icon_state
	W.mineral_icon_state = mineral_icon_state

	W.basetype = basetype_turf

/area/asteroid/mine/biome/proc/change_floor(turf/simulated/floor/F)
	F.oxygen = oxygen
	F.nitrogen = nitrogen

	F.basetype = basetype_turf

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

/area/asteroid/mine/biome/breathable/glow_cave
	name = "Glow Cave"
	icon_state = "ast-glow_cave-biome"

	cave_chance = 3

	resources_to_spawn = list(
		/obj/effect/glowshroom = 100
	)

/area/asteroid/mine/biome/dark_horror
	name = "Dark Horror"
	icon_state = "ast-dark_horror-biome"

	rock_icon_state = "rock-dark"

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

/area/asteroid/mine/biome/breathable/lor
	name = "Lots of Resources"
	icon_state = "ast-resources-biome"

/area/asteroid/mine/biome/breathable/hollow_horror
	name = "Hollow Horror"
	icon_state = "ast-hollow_horror-biome"

/area/asteroid/mine/biome/asteroids
	name = "Asteroids"
	icon_state = "ast-asteroids-biome"

/area/asteroid/mine/biome/breathable/asteroids
	name = "Asteroids (breathable)"
	icon_state = "ast-asteroids-biome"

	rock_icon_state = "rock-dark"

/area/asteroid/mine/biome/breathable/ruins
	name = "Ruins"
	icon_state = "ast-ruins-biome"

/area/asteroid/mine/biome/breathable/flesh
	name = "Flesh"
	icon_state = "ast-flesh-biome"

	cave_chance = 3

/area/asteroid/mine/biome/boney_creaks
	name = "Boney Creaks"
	icon_state = "ast-boney_hills-biome"
