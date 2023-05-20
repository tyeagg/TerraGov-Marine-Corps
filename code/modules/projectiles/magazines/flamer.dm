

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the FL-240 incinerator unit. Handle with care."
	icon_state = "flametank"
	max_rounds = 150
	current_rounds = 150
	reload_delay = 2 SECONDS
	w_class = WEIGHT_CLASS_NORMAL //making sure you can't sneak this onto your belt.
	caliber = CALIBER_FUEL_THICK //Ultra Thick Napthal Fuel, from the lore book.
	flags_magazine = NONE
	icon_state_mini = "tank"

	default_ammo = /datum/ammo/flamethrower

	var/dispenser_type = /obj/structure/reagent_dispensers/fueltank

/obj/item/ammo_magazine/flamer_tank/mini
	name = "mini incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the underail incinerator unit. Handle with care."
	icon_state = "flametank_mini"
	reload_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 100
	max_rounds = 100
	icon_state_mini = "tank_orange_mini"

/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.

	if(!istype(target, /obj/structure/reagent_dispensers) || get_dist(user, target) > 1)
		return ..()
	if(!dispenser_type)
		to_chat(user, span_warning("This isn't refillable!"))
		return ..()
	if(!istype(target, dispenser_type))
		to_chat(user, span_warning("Not the right kind of tank!"))
		return ..()
	if(current_rounds >= max_rounds)
		to_chat(user, span_warning("[src] is already full."))
		return ..()
	var/obj/structure/reagent_dispensers/dispenser = target
	if(dispenser.reagents.total_volume == 0)
		to_chat(user, span_warning("This tank is empty!"))
		return..()

	//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
	var/liquid_transfer_amount = min(dispenser.reagents.total_volume, (max_rounds - current_rounds))
	dispenser.reagents.remove_any(liquid_transfer_amount)
	current_rounds += liquid_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("You refill [src] with [lowertext(caliber)]."))
	update_icon()

/obj/item/ammo_magazine/flamer_tank/update_icon()
	return

/obj/item/ammo_magazine/flamer_tank/large	// Extra thicc tank
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the FL-84 flamethrower."
	icon_state = "flametank_large"
	max_rounds = 200
	current_rounds = 200
	reload_delay = 3 SECONDS
	icon_state_mini = "tank_orange"

/obj/item/ammo_magazine/flamer_tank/large/som
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the V-62 flamethrower."
	icon_state = "flametank_som"
	max_rounds = 200
	current_rounds = 200
	reload_delay = 3 SECONDS
	icon_state_mini = "tank_orange"

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large flamethrower tank (X)"
	desc = "A large fuel tank of ultra thick napthal Fuel type X, a sticky combustable liquid chemical that burns extremely hot, for use in the FL-84 flamethrower. Handle with care."
	icon_state = "flametank_large_blue"
	default_ammo = /datum/ammo/flamethrower/blue
	icon_state_mini = "tank_blue"
	dispenser_type = /obj/structure/reagent_dispensers/fueltank/xfuel

/obj/item/ammo_magazine/flamer_tank/backtank
	name = "back fuel tank"
	desc = "A specialized fuel tank for use with the FL-84 flamethrower and FL-240 incinerator unit."
	icon_state = "flamethrower_tank"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 500
	current_rounds = 500
	reload_delay = 1 SECONDS
	caliber = CALIBER_FUEL_THICK
	flags_magazine = MAGAZINE_WORN
	icon_state_mini = "tank"

	default_ammo = /datum/ammo/flamethrower

/obj/item/ammo_magazine/flamer_tank/water
	name = "pressurized water tank"
	desc = "A cannister of water for use with the FL-84's underslung extinguisher. Can be refilled by hand."
	icon_state = "watertank"
	max_rounds = 200
	current_rounds = 200
	reload_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_WATER //Deep lore
	flags_magazine = NONE
	icon_state_mini = "tank_water"

	default_ammo = /datum/ammo/water
	dispenser_type = /obj/structure/reagent_dispensers/watertank
