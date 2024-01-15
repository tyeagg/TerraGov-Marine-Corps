/datum/loadout_item/belt
	item_slot = ITEM_SLOT_BELT

/datum/loadout_item/belt/empty
	name = "no belt"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/ammo_belt
	name = "Ammo belt"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	item_typepath = /obj/item/storage/belt/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	item_blacklist = list(
		/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/minigun/smart_minigun/motion_detector = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/belt/sparepouch
	name = "G8 storage pouch"
	desc = "A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines."
	item_typepath = /obj/item/storage/belt/sparepouch
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/sparepouch/smartgunner
	desc = "A general storage pouch. \
	Contains a MP-19 sidearm, and spare ammo for the SG-85, or addition drum magazines for the SG-29." //contents handled by the SG-85
	req_desc = "Requires an SG-85."
	jobs_supported = list(SQUAD_SMARTGUNNER)
	item_whitelist = list(
		/obj/item/weapon/gun/minigun/smart_minigun/motion_detector = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/belt/shotgun_mixed
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Loaded full of buckshot and flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/mixed
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster
	name = "SMG-25 holster"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. \
	This version is designed for the SMG-25, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	item_typepath = /obj/item/storage/holster/m25
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m25/holstered(wearer), SLOT_IN_HOLSTER)

/datum/loadout_item/belt/machete
	name = "Machete"
	desc = "A large leather scabbard carrying a M2132 machete. It can be strapped to the back, waist or armor. Extremely dangerous against human opponents - if you can get close enough."
	item_typepath = /obj/item/storage/holster/blade/machete/full
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER)

/datum/loadout_item/belt/belt_harness
	name = "Belt harness"
	desc = "A shoulder worn strap with clamps that can attach to most anything. Should keep you from losing your weapon, hopefully."
	item_typepath = /obj/item/belt_harness/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

//medic
/datum/loadout_item/belt/lifesaver
	name = "Lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	item_typepath = /obj/item/storage/belt/lifesaver/quick
	jobs_supported = list(SQUAD_CORPSMAN)

//FC
/datum/loadout_item/belt/officer_sword
	name = "Officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. \
	Well made and extremely sharp, despite its probable non-combat purpose. Comes in a leather scabbard that an attached to your waist or armor."
	item_typepath = /obj/item/storage/holster/blade/officer/full
	jobs_supported = list(FIELD_COMMANDER)
	item_blacklist = list(/obj/item/storage/holster/blade/officer/full = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/belt/fc_pistol
	name = "P-1911A1-C pistol"
	desc = "A handgun that has received several modifications. It seems to have been lovingly taken care of and passed down for generations. \
	Lacks an auto magazine eject feature. Comes in a holster that fits on your waist or armor."
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander
	jobs_supported = list(FIELD_COMMANDER)
	item_blacklist = list(/obj/item/storage/holster/belt/pistol/m4a3/fieldcommander = ITEM_SLOT_SUITSTORE)

//staff officer
/datum/loadout_item/belt/so_pistol
	name = "RT-3 pistol"
	desc = "An RT-3 target pistol, a common sight throughout the bubble. Fires 9mm in magazines. Comes in a holster to fit on your waist."
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/officer
	jobs_supported = list(STAFF_OFFICER)

//captain
/datum/loadout_item/belt/smart_pistol
	name = "SP-13 pistol"
	desc = "The SP-13 is a IFF-capable sidearm used by the TerraGov Marine Corps. A cutting-edge miniaturization technology allows mounting of a KTLD IFF system on the pistol, \
	albeit at high manufactoring cost and the usual specialized training required to use such a pistol. Unique design feature high-capacity mag on top of the barrel, with integrated sight."
	item_typepath = /obj/item/storage/holster/belt/pistol/smart_pistol/full
	jobs_supported = list(CAPTAIN)