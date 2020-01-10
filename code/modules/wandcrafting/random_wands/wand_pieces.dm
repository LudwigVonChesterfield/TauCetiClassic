/obj/item/weapon/wand/generated
	var/list/pieces = list()

	var/datum/wand_piece/cap/wand_cap
	var/datum/wand_piece/guard/wand_guard
	var/datum/wand_piece/body/wand_body

	var/list/wand_acccessories = list()

/datum/wand_piece
	var/name = ""
	var/icon_state = "template"

	var/list/decorations

	var/icon/overlay

	var/add_max_mana = 0
	var/add_passive_mana_charge = 0

	var/add_spells_slots = 0
	var/add_wand_components_slots = 0

	var/add_spell_cast_delay = 0
	var/add_spell_recharge_delay = 0

/datum/wand_piece/New(obj/item/weapon/wand/generated/W)
	pre_generate()
	apply_to_wand(W)

/datum/wand_piece/proc/pre_generate()
	overlay = icon(icon='icons/obj/spell_wand_components.dmi', icon_state=icon_state)

/datum/wand_piece/proc/apply_to_wand(obj/item/weapon/wand/generated/W)
	W.max_mana += add_max_mana
	W.passive_mana_charge += add_passive_mana_charge
	W.spells_slots += add_spells_slots
	W.wand_components_slots += add_wand_components_slots
	W.spell_cast_delay += add_spell_cast_delay
	W.spell_recharge_delay += add_spell_recharge_delay
