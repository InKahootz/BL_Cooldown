--------------------------------------------------------
-- Blood Legion Raidcooldowns - Options --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things really easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

function BLCD:SetupOptions()
	BLCD.options.args.profile = AceDBOptions:GetOptionsTable(BLCD.db)
	AceConfig:RegisterOptionsTable("BLCD", BLCD.options, nil)

	BLCD.optionsFrames = {}
	BLCD.optionsFrames.general = AceConfigDialog:AddToBlizOptions("BLCD", "Blood Legion Cooldown", nil, "general")
	BLCD.optionsFrames.cooldowns = AceConfigDialog:AddToBlizOptions("BLCD", "Cooldown Settings", "Blood Legion Cooldown", "cooldown")
	BLCD.optionsFrames.profile = AceConfigDialog:AddToBlizOptions("BLCD", "Profiles", "Blood Legion Cooldown", "profile")
end

local order = 0
local function getOrder()
	order = order + 1
	return order
end

BLCD.TexCoords = {.08, .92, .08, .92}

BLCD.defaults = {
	profile = {
		castannounce = false,
		cdannounce = false,
		announcechannel = false,
		clickannounce = false,
		scale = 1,
		xOffset = 0,
		yOffset = 0,
		framePoint = 'TOPLEFT',
		relativePoint = 'TOPLEFT',
		growth = "right",
		show = "raidorparty",
		autocheckextra = true,
		hideempty = false,
		availablebars = false,
		classcolorbars = false,
		cooldown = {
			PAL_DEAU = true,
			PAL_HAOFSA = true,
			PAL_HAOFPR = false,
			PAL_HOAV = false,
			PAL_HAOFSAL = false,
			PAL_HAOFPU = false,
			PAL_LIHA = false,
			PRI_POWOBA = true,
			PRI_PASU = false,
			PRI_DIHY = true,
			PRI_GUSP = true,
			PRI_VAEM = false,
			DRU_TR = true,
			DRU_IR = false,
			DRU_RE = true,
			DRU_HEOFTHWI = false,
			SHA_SPLITO = false,
			SHA_HETITO = true,
			SHA_TRTO = false,
			SHA_BL = false,
			SHA_HE = false,
			SHA_RE = false,
			SHA_ANGU = false,
			MON_ZEME = false,
			MON_LICO = false,
			MON_RE = true,
			WARL_SORE = true,
			DEA_RAAL = true,
			DEA_ANMAZO = false,
			WARR_RACR = true,
			WARR_VI = false,
			WARR_SHTH = false,
			WARR_IN = false,
			MAG_TIWA = false,
			MAG_AMMA = true,
			ROG_SMBO = true,
			HUN_ASOFTHFO = true,
		},
	},
}

BLCD.options =  {
	type = "group",
	name = "Blood Legion Cooldown",
	args = {
		general = {
			order = getOrder(),
			type = "group",
			name = "General Settings",
			cmdInline = true,
			args = {
				castannounce = {
					type = "toggle",
					name = "Announce Casts",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.castannounce
					end,
					set = function(key, value)
						BLCD.profileDB.castannounce = value
					end,
				},
				cdannounce = {
					type = "toggle",
					name = "Announce CD Expire",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.cdannounce
					end,
					set = function(key, value)
						BLCD.profileDB.cdannounce = value
					end,
				},
				announcechannel = {
					order = getOrder(),
					name = "Announce to Custom Channel",
					type = 'toggle',
					get = function()
						return BLCD.profileDB.announcechannel 
					end,
					set = function(info, value)
						BLCD.profileDB.announcechannel = value;
					end,
					
				},
				customchan = {
					order = getOrder(),
					type = "input",
					name = "Channel Name",
					desc = "Channel you want to announce to",
					get = function()
						return BLCD.profileDB.customchan
					end,
					set = function(info, value)
						BLCD.profileDB.customchan = value;
					end,
				},
				scale = {
					order = getOrder(),
					type = "range",
					name = 'Set Scale',
					desc = "Sets Scale of Raid Cooldowns",
					min = 0.3, max = 2, step = 0.01,
					get = function()
						return BLCD.profileDB.scale 
					end,
					set = function(info, value)
						BLCD.profileDB.scale = value;
						BLCD:Scale();
					end,
				},
				grow = {
					order = getOrder(),
					name = "Bar Grow Direction",
					type = 'select',
					get = function()
						return BLCD.profileDB.growth 
					end,
					set = function(info, value)
						BLCD.profileDB.growth = value; BLCD:UpdateBarGrowthDirection()
					end,
					values = {
						['left'] = "Left",
						['right'] = "Right",
					},
				},
				show = {
					order = getOrder(),
					name = "Show Main Frame",
					type = 'select',
					get = function()
						return BLCD.profileDB.show 
					end,
					set = function(info, value)
						BLCD.profileDB.show = value; BLCD:CheckVisibility()
					end,
					values = {
						['always'] = "Always",
						['raid'] = "Raid",
						['party'] = "Party (BG's/Arena included)",
						['raidorparty'] = "Raid or Party",
						['never'] = "Never",
						['solo'] = "Solo",
					},			
				},
				--[[configure = {
					type = "execute",
					name = "Apply Changes",
					desc = "Apply the changes to the active cooldowns and reload the UI.",
					func = function()
						BLCD:DebugFunc()
					end,
					order = getOrder(),
					width = "full",
				},]]
				clickannounce = {
					type = "toggle",
					name = "Click to Announce Available",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.clickannounce
					end,
					set = function(key, value)
						BLCD.profileDB.clickannounce = value
					end,
				},
				autocheckextra = {
					type = "toggle",
					name = "Automatically Check for Extras",
					desc = "Enabling this option will automatically filter out extra players in the raid.\n\nIf enabled only players in the first groups up to the maximum players allowed will be tracked by BLCD.\n\nYou can manually filter out extras with \"/blcd ext\" and you can resume showing all players with \"/blcd clrext\"",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.autocheckextra
					end,
					set = function(key, value)
						BLCD.profileDB.autocheckextra = value
					end,
				},
				hideempty = {
					type = "toggle",
					name = "Hide Empty Cooldowns",
					desc = "Hide the icons for cooldowns which no one in the raid has",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.hideempty
					end,
					set = function(key, value)
						BLCD.profileDB.hideempty = value; 
						--local i
						--for i in select('#', BLCD.cooldowns) do
							BLCD:DynamicCooldownFrame()
						--end
					end,
				},
				availablebars = {
					type = "toggle",
					name = "Ready bar mode",
					desc = "Always show bars",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.availablebars
					end,
					set = function(key, value)
						BLCD.profileDB.availablebars = value; BLCD:AvailableBars(value)
					end,
				},
				classcolorbars = {
					type = "toggle",
					name = "Class color bars",
					desc = "Color the cooldown bars according to class",
					order = getOrder(),
					get = function()
						return BLCD.profileDB.classcolorbars
					end,
					set = function(key, value)
						BLCD.profileDB.classcolorbars = value; BLCD:RecolorBars(value)
					end,
				},
			},
		},
		cooldown = {
			order = getOrder(),
			type = "group",
			name = "Cooldown Settings",
			cmdInline = true,
			args = {
				paladin = {
					type = "group",
					name = "Paladin Cooldowns",
					order = getOrder(),
					args ={
						PAL_DEAU = {
							type = "toggle",
							name = "Devotion Aura",
							desc = "Inspire all party and raid members within 40 yards, granting them immunity to Silence and Interrupt effects and reducing all magic damage taken by 20%. Lasts 6 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_DEAU
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_DEAU = value; BLCD:DynamicCooldownFrame()
							end,
						},
						PAL_HAOFSA = {
							type = "toggle",
							name = "Hand of Sacrifice",
							desc = "Places a Hand on a party or raid member, transferring 30% damage taken to the Paladin. Lasts 12 sec or until the Paladin has transferred 100% of their maximum health.  Players may only have one Hand on them per Paladin at any one time.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_HAOFSA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_HAOFSA = value; BLCD:DynamicCooldownFrame()
							end,
						},					
						PAL_HAOFPR = {
							type = "toggle",
							name = "Hand of Protection",
							desc = "Places a Hand on a party or raid member, protecting them from all physical attacks for 10 sec, but during that time they cannot attack or use physical abilities.  Players may only have one Hand on them per Paladin at any one time.\n\nCannot be used on a target with Forbearance.  Causes Forbearance for 1 min.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_HAOFPR
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_HAOFPR = value; BLCD:DynamicCooldownFrame()
							end,
						},					
						PAL_HOAV = {
							type = "toggle",
							name = "Holy Avenger",
							desc = "Abilities that generate Holy Power will deal 30% additional damage and healing, and generate 3 charges of Holy Power for the next 18 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_HOAV
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_HOAV = value; BLCD:DynamicCooldownFrame()
							end,
						},					
						PAL_HAOFSAL = {
							type = "toggle",
							name = "Hand of Salvation",
							desc = "Places a Hand on the party or raid member, temporarily removing all their threat for 10 sec. Players may only have one Hand on them per Paladin at any one time.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_HAOFSAL
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_HAOFSAL = value; BLCD:DynamicCooldownFrame()
							end,
						},
						PAL_HAOFPU = {
							type = "toggle",
							name = "Hand of Purity",
							desc = "Places a Hand on the friendly target, reducing damage taken by 10% and damage from harmful periodic effects by an additional 70% for 6 sec. Players may only have one Hand on them per Paladin at any one time.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_HAOFPU
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_HAOFPU = value; BLCD:DynamicCooldownFrame()
							end,
						},
						PAL_LIHA = {
							type = "toggle",
							name = "Light's Hammer",
							desc = "Hurl a Light-infused hammer into the ground, where it will blast a 10 yard area with Arcing Light for (15 sec) sec.\n\nArcing Light\nDeals 100 to 121 (+ 32.1% of Spell Power) Holy damage to enemies and reduces their movement speed by 50% for 2 sec. Heals allies for 100 to 121 (+ 32.1% of Spell Power) every 2 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PAL_LIHA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PAL_LIHA = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				priest = {
					type = "group",
					name = "Priest Cooldowns",
					order = getOrder(),
					args ={
						PRI_POWOBA = {
							type = "toggle",
							name = "Power Word: Barrier",
							desc = "Summons a holy barrier on the target location that reduces all damage done to friendly targets by 25%. While within the barrier, spellcasting will not be interrupted by damage. The barrier lasts for 10 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PRI_POWOBA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PRI_POWOBA = value; BLCD:DynamicCooldownFrame()
							end,
						},
						PRI_PASU = {
							type = "toggle",
							name = "Pain Suppression",
							desc = "Instantly reduces a friendly target's threat by 5%, and reduces all damage they take by 40% for 8 sec. Castable while stunned.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PRI_PASU
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PRI_PASU = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						PRI_DIHY = {
							type = "toggle",
							name = "Divine Hymn",
							desc = "Heals 5 nearby lowest health friendly party or raid targets within 40 yards for 7987 (+ 154.2% of Spell Power) every 2 sec for 8 sec, and increases healing done to them by 10% for 8 sec. The Priest must channel to maintain the spell.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PRI_DIHY
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PRI_DIHY = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						PRI_GUSP = {
							type = "toggle",
							name = "Guardian Spirit",
							desc = "Calls upon a guardian spirit to watch over the friendly target. The spirit increases the healing received by the target by 60%, and also prevents the target from dying by sacrificing itself. This sacrifice terminates the effect but heals the target of 50% of their maximum health. Lasts 10 sec. Castable while stunned.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PRI_GUSP
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PRI_GUSP = value; BLCD:DynamicCooldownFrame()
							end,
						},
						PRI_VAEM = {
							type = 'toggle',
							name = "Vampiric Embrace",
							desc = "Fills you with the embrace of Shadow energy, causing you and your allies to be healed for 50% of any single-target Shadow spell damage you deal, split evenly between them. Lasts 15 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.PRI_VAEM
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PRI_VAEM = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				druid = {
					type = "group",
					name = "Druid Cooldowns",
					order = getOrder(),
					args ={
						DRU_TR = {
							type = "toggle",
							name = "Tranquility",
							desc = "Heals 5 nearby lowest health party or raid targets within 40 yards with Tranquility every 2 sec for 8 sec.\n\nTranquility heals for 9037 (+ 83.5% of Spell Power) plus an additional 1542 (+ 14.2% of Spell Power) every 2 sec over 8 sec. Stacks up to 3 times. The Druid must channel to maintain the spell.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DRU_TR
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DRU_TR = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						DRU_IR = {
							type = "toggle",
							name = "Ironbark",
							desc = "The target's skin becomes as tough as Ironwood, reducing all damage taken by 20%. Lasts 12 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DRU_IR
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DRU_IR = value; BLCD:DynamicCooldownFrame()
							end,
						},	
						DRU_RE = {
							type = "toggle",
							name = "Rebirth",
							desc = "Returns the spirit to the body, restoring a dead target to life with 60% health and 20% mana.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DRU_RE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DRU_RE = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						DRU_HEOFTHWI = {
							type = "toggle",
							name = "Heart of the Wild",
							desc = "Increases Stamina, Agility, and Intellect by 6% at all times.  When activated, dramatically improves the Druid's ability to perform roles outside of their normal specialization for 45 sec. Grants the following benefits based on current specialization:\n\nNon-Guardian\nWhile in Bear Form, Agility, Expertise, Hit Chance, and armor bonuses increased, Vengeance granted, chance to be hit by melee critical strikes reduced.\n\nNon-Feral\nWhile in Cat Form, Agility, Hit Chance, and Expertise increased.\n\nNon-Restoration\nHealing increased and mana cost of all healing spells reduced by 100%.  Guardian Druids may also cast Rejuvenation while shapeshifted.\n\nNon-Balance\nSpell Damage and Hit Chance increased.  Mana cost of all damage spells reduced by 100%.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DRU_HEOFTHWI
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DRU_HEOFTHWI = value; BLCD:DynamicCooldownFrame()
							end,
						},		
					},
				},
				shaman = {
					type = "group",
					name = "Shaman Cooldowns",
					order = getOrder(),
					args ={
						SHA_SPLITO = {
							type = "toggle",
							name = "Spirit Link Totem",
							desc = "Summons an Air Totem with 5 health at the feet of the caster. The totem reduces damage taken by all party and raid members within 10 yards by 10%. Every 1 sec, the health of all affected players is redistributed, such that each player ends up with the same percentage of their maximum health. Lasts 6 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.SHA_SPLITO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_SPLITO = value; BLCD:DynamicCooldownFrame()
							end,
						},				
						SHA_HETITO = {
							type = "toggle",
							name = "Healing Tide Totem",
							desc = "Summons a Water Totem with 10% of the caster's health at the feet of the caster for (11 sec) sec. The Healing Tide Totem pulses every 2 sec, healing the 5 most injured party or raid members within 40 yards for 4932 (+ 48.4% of Spell Power).",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.SHA_HETITO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_HETITO = value; BLCD:DynamicCooldownFrame()
							end,
						},			
						SHA_TRTO = {
							type = "toggle",
							name = "Tremor Totem",
							desc = "Summons an Earth Totem with 5 health at the feet of the caster that shakes the ground around it for 6 sec, removing Fear, Charm and Sleep effects from party and raid members within 30 yards.  This totem may be dropped even while the caster is afflicted with such effects.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.SHA_TRTO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_TRTO = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						SHA_BL = {
							type = "toggle",
							name = "Bloodlust",
							desc = "Increases melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become Sated and be unable to benefit from Bloodlust or Time Warp again for 10 min.",
							order = getOrder(),
							disabled = function()
								return (UnitFactionGroup("player") ~= "Horde")
							end,
							get = function()
								if (UnitFactionGroup("player") ~= "Horde") then
									return false
								else
									return BLCD.profileDB.cooldown.SHA_BL
								end
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_BL = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						SHA_HE = {
							type = "toggle",
							name = "Heroism",
							desc = "Increases melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become Exhausted and be unable to benefit from Heroism or Time Warp again for 10 min.",
							order = getOrder(),
							disabled = function()
								return (UnitFactionGroup("player") ~= "Alliance")
							end,
							get = function()
								if (UnitFactionGroup("player") ~= "Alliance") then
									return false
								else
									return BLCD.profileDB.cooldown.SHA_HE
								end
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_HE = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						SHA_RE = {
							type = "toggle",
							name = "Reincarnation",
							desc = "Allows you to resurrect yourself upon death with 20% health and mana.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.SHA_RE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_RE = value; BLCD:DynamicCooldownFrame()
							end,
						},		
						SHA_ANGU = {
							type = "toggle",
							name = "Ancestral Guidance",
							desc = "When you deal direct damage or healing for the next 10 sec, 40% of damage or 60% of healing is copied as healing to up to 3 nearby injured party or raid members.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.SHA_ANGU
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SHA_ANGU = value; BLCD:DynamicCooldownFrame()
							end,
						},		
					},
				},
				monk = {
					type = "group",
					name = "Monk Cooldowns",
					order = getOrder(),
					args ={
						MON_ZEME = {
							type = "toggle",
							name = "Zen Meditation",
							desc = "Reduces all damage taken by 90% and redirects to you up to 5 harmful spells cast against party and raid members within 30 yards.  Lasts 8 sec.\n\nBeing the victim of a melee attack will break your meditation, cancelling the effect.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.MON_ZEME
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MON_ZEME = value; BLCD:DynamicCooldownFrame()
							end,
						},	
						MON_LICO = {
							type = "toggle",
							name = "Life Cocoon",
							desc = "Encases the target in a cocoon of Chi energy, absorbing 79916 (+ 1100% of Spell Power) damage and increasing all periodic healing taken by 50%. Lasts for 12 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.MON_LICO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MON_LICO = value; BLCD:DynamicCooldownFrame()
							end,
						},	
						MON_RE = {
							type = "toggle",
							name = "Revival",
							desc = "Instantly heals all party and raid members within vision for 13684 (+ 500% of Spell Power), and clears them of any harmful Magical, Poison and Disease effects.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.MON_RE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MON_RE = value; BLCD:DynamicCooldownFrame()
							end,
						},		
					},
				},
				warlock = {
					type = "group",
					name = "Warlock Cooldowns",
					order = getOrder(),
					args ={
						WARL_SORE = {
							type = "toggle",
							name = "Soulstone Resurrection",
							desc = "When cast on living party or raid members, the soul of the target is stored and they will be able to resurrect upon death.\n\nIf cast on a dead target, they are instantly resurrected. Targets resurrect with 60% health and 20% mana.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.WARL_SORE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.WARL_SORE = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				DK = {
					type = "group",
					name = "Death Knight Cooldowns",
					order = getOrder(),
					args ={
						DEA_RAAL = {
							type = "toggle",
							name = "Raise Ally",
							desc = "Pours dark energy into a dead target, reuniting spirit and body to allow the target to reenter battle with 60% health and 20% mana.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DEA_RAAL
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DEA_RAAL = value; BLCD:DynamicCooldownFrame()
							end,
						},
						DEA_ANMAZO = {
							type = "toggle",
							name = "Anti-Magic Zone",
							desc = "Places a large, stationary Anti-Magic Zone that reduces spell damage done to party or raid members inside it by 75%.  The Anti-Magic Zone lasts for 10 sec or until it absorbs at least 136800 (+ 400% of Strength) spell damage.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.DEA_ANMAZO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DEA_ANMAZO = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				warrior = {
					type = "group",
					name = "Warrior Cooldowns",
					order = getOrder(),
					args ={
						WARR_RACR = {
							type = "toggle",
							name = "Rallying Cry",
							desc = "Temporarily grants you and all party or raid members within 30 yards 20% of maximum health for 10 sec.  After the effect expires, the health is lost.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.WARR_RACR
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.WARR_RACR = value; BLCD:DynamicCooldownFrame()
							end,
						},
						WARR_VI = {
							type = "toggle",
							name = "Vigilance",
							desc = "Focus your protective gaze on a party or raid member, transferring 30% of damage taken to you for 12 sec.\n\nDuring the duration of Vigilance, your Taunt has no cooldown.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.WARR_VI
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.WARR_VI = value; BLCD:DynamicCooldownFrame()
							end,
						},
						WARR_SHTH = {
							type = "toggle",
							name = "Shattering Throw",
							desc = "Throws your weapon at the enemy causing 12 damage, reducing the armor on the target by 20% for 10 sec or removing any invulnerabilities.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.WARR_SHTH
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.WARR_SHTH = value; BLCD:DynamicCooldownFrame()
							end,
						},
						WARR_IN = {
							type = "toggle",
							name = "Intervene",
							desc = "Run at high speed towards a party or raid member, intercepting the next melee or ranged attack within 10 sec while the target remains within 10 yards.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.WARR_IN
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.WARR_IN = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				mage = {
					type = "group",
					name = "Mage Cooldowns",
					order = getOrder(),
					args ={
						MAG_TIWA = {
							type = "toggle",
							name = "Time Warp",
							desc = "Warp the flow of time, increasing melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become unstuck in time, and be unable to benefit from Bloodlust, Heroism, or Time Warp again for 10 min.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.MAG_TIWA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MAG_TIWA = value; BLCD:DynamicCooldownFrame()
							end,
						},
						MAG_AMMA = {
							type = "toggle",
							name = "Amplify Magic",
							desc = "Amplify the effects of helpful magic, increasing all healing received by 12% for all party and raid members within 100 yards. Lasts 6 sec.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.MAG_AMMA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MAG_AMMA = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				rogue = {
					type = "group",
					name = "Rogue Cooldowns",
					order = getOrder(),
					args ={
						ROG_SMBO = {
							type = "toggle",
							name = "Smoke Bomb",
							desc = "Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud. Allies take 20% less damage while within the cloud.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.ROG_SMBO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.ROG_SMBO = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
				hunter = {
					type = "group",
					name = "Hunter Cooldowns",
					order = getOrder(),
					args ={
						HUN_ASOFTHFO = {
							type = "toggle",
							name = "Aspect of the Fox",
							desc = "Party and raid members within 40 yards take on the aspects of a fox, allowing them to move while casting all spells and abilities for 6 sec. Only one Aspect can be active at a time.",
							order = getOrder(),
							get = function()
								return BLCD.profileDB.cooldown.HUN_ASOFTHFO
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.HUN_ASOFTHFO = value; BLCD:DynamicCooldownFrame()
							end,
						},
					},
				},
			},
		},
	},
}
--------------------------------------------------------