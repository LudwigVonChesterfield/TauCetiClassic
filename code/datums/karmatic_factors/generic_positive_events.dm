/datum/karmatic_factor/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/karmatic_factor/area/add_effects(_mood_change, _description)
	mood_change = _mood_change
	description = _description

/datum/karmatic_factor/fresh_laundry
	description = "<span class='nicegreen'>There's nothing like the feeling of a freshly laundered jumpsuit.</span>"
	mood_change = 2
	timeout = 10 MINUTES

/datum/karmatic_factor/happiness
	mood_change = 6
	description = "<span class='bold nicegreen'>For no apparent reason I feel great! I love life!</span>"

/datum/karmatic_factor/drugged
	mood_change = 6
	description = "<span class='nicegreen'>Oh my god! What a thrill!</span>"
	timeout = 1 MINUTES

/datum/karmatic_factor/blessing
	description = "<span class='nicegreen'>Я был благословлен.</span>"
	mood_change = 3
	timeout = 5 MINUTES

/datum/karmatic_factor/drunk
	mood_change = 1
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>"

/datum/karmatic_factor/very_drunk
	mood_change = 3
	description = "<span class='nicegreen'>I *hicc* do not feel my hands, what regrets?</span>"

/datum/karmatic_factor/drunk_catharsis
	mood_change = 10
	description = "<span class='bold nicegreen'>Whatever happens - happens. I do not care any longer. Void, consume me.</span>"

/datum/karmatic_factor/smoked
	description = "<span class='nicegreen'>I have had a smoke recently.</span>"
	mood_change = 2
	timeout = 6 MINUTES

/datum/karmatic_factor/shower
	description = "<span class='nicegreen'>I've had a relaxing shower-time.</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/karmatic_factor/sauna
	description = "<span class='nicegreen'>I've had a relaxing time in sauna.</span>"
	mood_change = 3
	timeout = 10 MINUTES

/datum/karmatic_factor/hug
	description = "<span class='nicegreen'>Hugs are nice.</span>"
	mood_change = 1
	timeout = 1 MINUTE

/datum/karmatic_factor/betterhug
	description = "<span class='nicegreen'>Someone was very nice to me.</span>"
	mood_change = 2
	timeout = 3 MINUTES

/datum/karmatic_factor/betterhug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] was very nice to me.</span>"

/datum/karmatic_factor/besthug
	description = "<span class='nicegreen'>Someone is great to be around, they make me feel so happy!</span>"
	mood_change = 4
	timeout = 3 MINUTES

/datum/karmatic_factor/besthug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] is great to be around, [friend.name] makes me feel so happy!</span>"

/datum/karmatic_factor/wc_used
	description = "<span class='nicegreen'>You feel clean and refreshed.</span>"
	mood_change = 1
	timeout = 10 MINUTE

/datum/karmatic_factor/clown_evil
	description = "<span class='nicegreen'>You did something delightfully devilish. HONK!</span>"
	mood_change = 5
	timeout = 30 MINUTE

/datum/karmatic_factor/swole
	description = "<span class='nicegreen'>I am getting swole!</span>"
	timeout = 6 MINUTES

/datum/karmatic_factor/swole/add_effects(pain)
	// 2.5 is stronger then cigs, because we believe in a healthy lifestyle!
	// also getting swole loses nutriments so it has a sizable debuff which we need offset
	mood_change = 2.5 + pain * 0.5
