/obj/structure/sensor_tower
	name = "sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Has a lengthy activation process."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	obj_flags = NONE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL
	///The timer for when the sensor tower activates
	var/current_timer
	///Time it takes for the sensor tower to fully activate
	var/generate_time = 250 SECONDS
	///Time it takes to start the activation
	var/activate_time = 5 SECONDS
	///Time it takes to stop the activation
	var/deactivate_time = 10 SECONDS
	///Count amount of sensor towers existing
	var/static/id = 1
	///The id for the tower when it initializes, used for minimap icon
	var/towerid
	///True if the sensor tower has finished activation, used for minimap icon and preventing deactivation
	var/activated = FALSE
	///Prevents there being more than one sensor tower being activated
	var/static/already_activated = FALSE
	///How long is left in the game end timer. Recorded as a var to pause the timer while tower is activating
	var/remaining_game_time
	///The faction that owns this tower, and considered the defender
	var/faction = FACTION_SOM

/obj/structure/sensor_tower/Initialize(mapload)
	. = ..()
	name += " " + num2text(id)
	towerid = id
	id++
	update_icon()

/obj/structure/sensor_tower/update_icon_state()
	icon_state = initial(icon_state)
	if(current_timer || activated)
		icon_state += "_active"

/obj/structure/sensor_tower/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	if(user.faction == faction)
		defender_interaction(user)
	else
		attacker_interaction(user)

///Handles defender interactions with the tower
/obj/structure/sensor_tower/proc/defender_interaction(mob/living/user)
	if(!activated && !current_timer)
		balloon_alert(user, "This sensor tower is not activated yet, don't let it be activated!")
		return
	if(activated)
		balloon_alert(user, "This sensor tower is already fully activated, you cannot deactivate it!")
		return

	balloon_alert(user, "You begin to stop the activation process!")
	if(!do_after(user, deactivate_time, TRUE, src))
		return
	if(activated)
		balloon_alert(user, "This sensor tower is already fully activated, you cannot deactivate it!")
		return
	if(!current_timer)
		balloon_alert(user, "This sensor tower is not currently activated")
		return
	balloon_alert(user, "You stop the activation process!")
	deactivate()

///Handles attacker interactions with the tower
/obj/structure/sensor_tower/proc/attacker_interaction(mob/living/user)
	if(!attacker_state_check(user))
		return
	balloon_alert_to_viewers("Activating sensor tower...")
	if(!do_after(user, activate_time, TRUE, src))
		return
	if(!attacker_state_check(user))
		return
	balloon_alert_to_viewers("Sensor tower activated!")
	begin_activation()

///Checks whether an attack can currently activate this tower
/obj/structure/sensor_tower/proc/attacker_state_check(mob/living/user)
	if(activated)
		balloon_alert(user, "This sensor tower is already fully activated!")
		return FALSE
	if(current_timer)
		balloon_alert(user, "This sensor tower is currently activating!")
		return FALSE
	if(already_activated)
		balloon_alert(user, "There's already a sensor tower being activated!")
		return FALSE
	return TRUE

///Starts timer and sends an alert
/obj/structure/sensor_tower/proc/begin_activation()
	current_timer = addtimer(CALLBACK(src, PROC_REF(finish_activation)), generate_time, TIMER_STOPPABLE)
	already_activated = TRUE
	toggle_game_timer()
	update_icon()

	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		if(human.faction == faction)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is being activated, deactivate it!", /atom/movable/screen/text/screen_text/picture/potrait/som_over)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is being activated, get ready to defend it team!", /atom/movable/screen/text/screen_text/picture/potrait)

///When timer ends add a point to the point pool in sensor capture, increase game timer, and send an alert
/obj/structure/sensor_tower/proc/finish_activation()
	if(!current_timer)
		return
	if(activated)
		return

	current_timer = null
	activated = TRUE
	already_activated = FALSE
	toggle_game_timer(SENSOR_CAP_ADDITION_TIME_BONUS)
	update_icon()

	var/datum/game_mode/combat_patrol/sensor_capture/mode = SSticker.mode
	mode.sensors_activated += 1

	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	balloon_alert_to_viewers("[src] has finished activation!")

	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		if(human.faction == faction)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is fully activated, stop further towers from being activated!", /atom/movable/screen/text/screen_text/picture/potrait/som_over)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is fully activated, timer increased by [SENSOR_CAP_ADDITION_TIME_BONUS / 600] minutes.", /atom/movable/screen/text/screen_text/picture/potrait)

///Stops timer if activating and sends an alert
/obj/structure/sensor_tower/proc/deactivate()
	current_timer = null
	already_activated = FALSE
	toggle_game_timer()
	update_icon()

	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == faction)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] activation process has been stopped, glory to Mars!", /atom/movable/screen/text/screen_text/picture/potrait/som_over)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] activation process has been stopped<br>" + ",rally up and get it together team!", /atom/movable/screen/text/screen_text/picture/potrait)

		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)

///Pauses or restarts the gamemode timer
/obj/structure/sensor_tower/proc/toggle_game_timer(addition_time)
	var/datum/game_mode/combat_patrol/sensor_capture/mode = SSticker.mode

	if(mode.game_timer == SENSOR_CAP_TIMER_PAUSED)
		mode.game_timer = addtimer(CALLBACK(mode, TYPE_PROC_REF(/datum/game_mode/combat_patrol, set_game_end)), remaining_game_time + addition_time, TIMER_STOPPABLE)
		return

	remaining_game_time = timeleft(mode.game_timer)
	deltimer(mode.game_timer) //game timer is paused while tower is running
	mode.game_timer = SENSOR_CAP_TIMER_PAUSED

/obj/structure/sensor_tower/update_icon()
	. = ..()
	update_control_minimap_icon()

///Update minimap icon of tower if its deactivated, activated , and fully activated
/obj/structure/sensor_tower/proc/update_control_minimap_icon()
	SSminimaps.remove_marker(src)
	if(activated)
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "relay_[towerid]_on_full"))
	else
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "relay_[towerid][current_timer ? "_on" : "_off"]"))

/obj/structure/sensor_tower/psy
	icon_state = "psy"
	faction = FACTION_XENO
	deactivate_time = 5 SECONDS
	var/obj/effect/landmark/patrol_point/exit_point = /obj/effect/landmark/patrol_point
	max_integrity = 1000

/obj/structure/sensor_tower/psy/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 200, 2 SECONDS, fuel_req = 1)

/obj/structure/sensor_tower/psy/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(100)
		if(EXPLODE_HEAVY)
			take_damage(50)
		if(EXPLODE_LIGHT)
			take_damage(10)

/obj/structure/sensor_tower/psy/obj_destruction()
	deactivate()
	obj_integrity = max_integrity
	return

/obj/structure/sensor_tower/psy/begin_activation()
	. = ..()
	exit_point = new exit_point(loc)
	exit_point.id = 5
	DISABLE_BITFIELD(resistance_flags, RESIST_ALL)
	ENABLE_BITFIELD(resistance_flags, XENO_DAMAGEABLE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PSY_INHIBITOR, src)
	new /obj/effect/ai_node/goal(loc)

/obj/structure/sensor_tower/finish_activation()
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PSY_INHIBITOR_ON, src)

/obj/structure/sensor_tower/psy/deactivate()
	. = ..()
	DISABLE_BITFIELD(resistance_flags, XENO_DAMAGEABLE)
	ENABLE_BITFIELD(resistance_flags, RESIST_ALL)
	QDEL_NULL(exit_point)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PSY_INHIBITOR_OFF, src)
