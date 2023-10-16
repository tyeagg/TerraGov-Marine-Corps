/obj/structure/patrol_point
	name = "Patrol start point"
	desc = "A one way ticket to the combat zone."
	icon = 'icons/effects/effects.dmi'
	icon_state = "patrolpoint"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = LADDER_LAYER
	density = TRUE
	///ID to link with associated exit point
	var/id = null
	///The linked exit point
	var/obj/effect/landmark/patrol_point/linked_point = null
	var/obj/effect/dropship_shadow/shadow
	var/shadow_icon_state = "shadow"

/obj/structure/patrol_point/Initialize(mapload)
	..()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/patrol_point/LateInitialize()
	create_link()
	set_light(15, 3, COLOR_WHITE)

///Links the patrol point to its associated exit point
/obj/structure/patrol_point/proc/create_link()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list)
		if(exit_point.id == id)
			linked_point = exit_point
			RegisterSignal(linked_point, COMSIG_QDELETING, PROC_REF(delete_link))
			return

///Removes the linked patrol exist point
/obj/structure/patrol_point/proc/delete_link()
	SIGNAL_HANDLER
	linked_point = null

/obj/structure/patrol_point/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated() || !Adjacent(user) || user.lying_angle || user.buckled || user.anchored)
		return

	activate_point(user)

/obj/structure/patrol_point/mech_shift_click(obj/vehicle/sealed/mecha/mecha_clicker, mob/living/user)
	if(!Adjacent(user))
		return
	activate_point(user, mecha_clicker)

///Handles sending someone and/or something through the patrol_point
/obj/structure/patrol_point/proc/activate_point(mob/living/user, obj/obj_mover)
	if(!user && !obj_mover)
		return
	if(!linked_point)
		create_link()
		if(!linked_point)
			//Link your stuff bro. There may be a better way to do this, but the way modular map insert works, linking does not properly happen during initialisation
			if(user)
				to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return

	if(obj_mover)
		obj_mover.forceMove(linked_point.loc)
	else if(user) //this is mainly configured under the assumption that we only have both an obj and a user if its a manned mech going through
		user.visible_message(span_notice("[user] goes through the [src]."),
		span_notice("You walk through the [src]."))
		user.trainteleport(linked_point.loc)
		add_spawn_protection(user)

	if(!shadow)
		shadow = new /obj/effect/dropship_shadow(linked_point.loc, shadow_icon_state)
		addtimer(CALLBACK(src, PROC_REF(dropship_exit)), 15 SECONDS)

	new /atom/movable/effect/rappel_rope(linked_point.loc)

	if(!user)
		return
	user.playsound_local(user, "sound/effects/CIC_order.ogg", 10, 1)
	var/message
	if(issensorcapturegamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Reactivate all sensor towers, good luck team."
			if(FACTION_SOM)
				message = "Prevent reactivation of the sensor towers, glory to Mars!"
	else if(iscombatpatrolgamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Eliminate all hostile forces in the ao, good luck team."
			if(FACTION_SOM)
				message = "Eliminate the TerraGov imperialists in the ao, glory to Mars!"
	else if(iscampaigngamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Stick together and achieve those objectives marines. Good luck."
			if(FACTION_SOM)
				message = "Remember your training marines, show those Terrans the strength of the SOM, glory to Mars!"

	if(!message)
		return

	switch(user.faction)
		if(FACTION_TERRAGOV)
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait)
		if(FACTION_SOM)
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait/som_over)
		else
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>UNKNOWN</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait/unknown)

/obj/structure/patrol_point/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(. || !linked_point)
		return

	user.forceMove(linked_point.loc)

///Temporarily applies godmode to prevent spawn camping
/obj/structure/patrol_point/proc/add_spawn_protection(mob/user)
	user.status_flags |= GODMODE
	addtimer(CALLBACK(src, PROC_REF(remove_spawn_protection), user), 10 SECONDS)

///Removes spawn protection godmode
/obj/structure/patrol_point/proc/remove_spawn_protection(mob/user)
	user.status_flags &= ~GODMODE

/obj/structure/patrol_point/proc/dropship_exit()
	animate(shadow, alpha = 0, time = 15)
	QDEL_IN(shadow, 15)

/obj/structure/patrol_point/tgmc
	name = "UD-4L Cheyenne Dropship"
	desc = "A versatile dropship and tactical transport employed in a primary role in the TGMC."
	icon = 'icons/Marine/dropship_prop.dmi'
	icon_state = "ud"
	pixel_x = -48
	bound_height = 224

/obj/structure/patrol_point/tgmc/tgmc_11
	id = "TGMC_11"

/obj/structure/patrol_point/tgmc/tgmc_21
	id = "TGMC_21"

/obj/structure/patrol_point/som
	name = "Antares Dropship"
	desc = "A versatile dropship and tactical transport employed in a primary role in the MMC."
	icon = 'icons/Marine/som_dropship_prop.dmi'
	icon_state = "antares"
	shadow_icon_state = "antares_shadow"
	pixel_x = -4
	pixel_y = -39
	bound_width = 192
	bound_height = 32

/obj/structure/patrol_point/som/som_11
	id = "SOM_11"

/obj/structure/patrol_point/som/som_21
	id = "SOM_21"

/atom/movable/effect/rappel_rope
	name = "rope"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "rope"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/effect/rappel_rope/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/effects/rappel.ogg', 50, TRUE, falloff = 2)
	playsound(loc, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	balloon_alert_to_viewers("You see a dropship fly overhead and begin dropping ropes!")
	ropeanimation()

/atom/movable/effect/rappel_rope/proc/ropeanimation()
	flick("rope_deploy", src)
	addtimer(CALLBACK(src, PROC_REF(ropeanimation_stop)), 2 SECONDS)

/atom/movable/effect/rappel_rope/proc/ropeanimation_stop()
	flick("rope_up", src)
	QDEL_IN(src, 5)

/obj/effect/dropship_shadow
	icon = 'icons/Marine/dropship_prop.dmi'
	icon_state = "shadow"
	pixel_x = -48
	pixel_y = -120
	alpha = 0
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/dropship_shadow/Initialize(mapload, new_icon_state)
	. = ..()
	if(new_icon_state)
		icon_state = new_icon_state
	animate(src, alpha = 255, time = 15)
	var/obj/effect/abstract/particle_holder/dust = new(get_turf(src), /particles/shuttle_dust)
	dust.particles.position = generator(GEN_CIRCLE, 180, 180, NORMAL_RAND)
	addtimer(VARSET_WEAK_CALLBACK(dust.particles, count, 0), 14 SECONDS)
