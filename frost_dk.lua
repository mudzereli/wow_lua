--- ========== TODO ==========

  -- better / auto cd handling?
  -- change is_boss ignore range checks to list of "big mobs" by name?
  -- dark succor death strike usage when alone
  -- no death strike in raids
  -- add back in toggles for AOE

--- ========== HEADER ==========
  
  local FILE_VERSION = 20180923-1

  WH_POOLING_FREEZE = false

  local addonName, addonTable = ...
  local HL = HeroLib
  local Cache = HeroCache
  local Unit = HL.Unit
  local Player = Unit.Player
  local Target = Unit.Target
  local Spell = HL.Spell
  local Item = HL.Item
  local HR = HeroRotation

--- ========== LOCAL VARIABLES ==========

  local Everyone = HR.Commons.Everyone
  local DeathKnight = HR.Commons.DeathKnight
  local Settings = nil
  local I = nil
  local S = nil

  local function Initialize()
    if not HL then HL = HeroLib end
    if not Cache then Cache = HeroCache end
    if not Unit then Unit = HL.Unit end
    if not Player then Player = Unit.Player end
    if not Target then Target = Unit.Target end
    if not Spell then Spell = HL.Spell end
    if not Item then Item = HL.Item end
    if not HR then HR = HeroRotation end
    if not Everyone then Everyone = HR.Commons.Everyone end
    if not DeathKnight then DeathKnight = HR.Commons.DeathKnight end

    -- Spells
    if not Spell.DeathKnight then Spell.DeathKnight = {} end
    Spell.DeathKnight.Frost = {
      -- Racials
      ArcaneTorrent                 = Spell(50613),
      Berserking                    = Spell(26297),
      BloodFury                     = Spell(20572),
      GiftoftheNaaru                = Spell(59547),

      -- Abilities
      ChainsOfIce                   = Spell(45524),
      EmpowerRuneWeapon             = Spell(47568),
      FrostFever                    = Spell(55095),
      FrostStrike                   = Spell(49143),
      HowlingBlast                  = Spell(49184),
      Obliterate                    = Spell(49020),
      PillarOfFrost                 = Spell(51271),
      RazorIce                      = Spell(51714),
      RemorselessWinter             = Spell(196770),
      KillingMachine                = Spell(51124),
      Rime                          = Spell(59052),
      UnholyStrength                = Spell(53365),
      -- Talents
      BreathofSindragosa            = Spell(152279),
      BreathofSindragosaTicking     = Spell(155166),
      FrostScythe                   = Spell(207230),
      FrozenPulse                   = Spell(194909),
      GatheringStorm                = Spell(194912),
      GatheringStormBuff            = Spell(211805),
      GlacialAdvance                = Spell(194913),
      HornOfWinter                  = Spell(57330),
      IcyTalons                     = Spell(194878),
      IcyTalonsBuff                 = Spell(194879),
      MurderousEfficiency           = Spell(207061),
      Obliteration                  = Spell(281238),
      RunicAttenuation              = Spell(207104),
      Icecap                        = Spell(207126),
      ColdHeart                     = Spell(281208),
      ColdHeartBuff                 = Spell(281209),
      FrostwyrmsFury                = Spell(279302),
      -- Defensive
      AntiMagicShell                = Spell(48707),
      DeathStrike                   = Spell(49998),
      IceboundFortitude             = Spell(48792),
      -- Utility
      ControlUndead                 = Spell(45524),
      DeathGrip                     = Spell(49576),
      MindFreeze                    = Spell(47528),
      PathOfFrost                   = Spell(3714),
      WraithWalk                    = Spell(212552),
      -- Misc
      PoolRange                   = Spell(9999000010)
      -- Macros
    }
    S = Spell.DeathKnight.Frost

    -- Items
    if not Item.DeathKnight then Item.DeathKnight = {} end
    Item.DeathKnight.Frost = {
      BattlePotionOfStrength = Item(163224)
    }
    I = Item.DeathKnight.Frost

    -- GUI Settings
    if (not Settings) or (not Settings.DeathKnight) then
      Settings = {
        General = HR.GUISettings.General,
        DeathKnight = HR.GUISettings.APL.DeathKnight
      }
    end
  end

--- ========== HELPER FUNCTIONS ==========

  local function ShouldDeathStrike()
    return (Settings.General.SoloMode and Player:HealthPercentage() < Settings.DeathKnight.Commons.UseDeathStrikeHP) and true or false
  end

--- ========== SIMCRAFT PRIORITY LIST ==========

  -- # # Executed before combat begins. Accepts non-harmful actions only.
  -- x actions.precombat=flask
  -- x actions.precombat+=/food
  -- x actions.precombat+=/augmentation
  -- # # Snapshot raid buffed stats before combat begins and pre-potting is done.
  -- x actions.precombat+=/snapshot_stats
  -- x actions.precombat+=/potion

  -- # # Executed every time the actor is available.
  -- x actions=auto_attack

  -- # # Apply Frost Fever and maintain Icy Talons
  -- * actions+=/howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  -- * actions+=/glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  -- * actions+=/frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
  -- * actions+=/call_action_list,name=cooldowns
  -- * actions+=/run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
  -- * actions+=/run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
  -- * actions+=/run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
  -- * actions+=/run_action_list,name=aoe,if=active_enemies>=2
  -- - actions+=/call_action_list,name=standard

  -- * actions.aoe=remorseless_winter,if=talent.gathering_storm.enabled
  -- * actions.aoe+=/glacial_advance,if=talent.frostscythe.enabled
  -- * actions.aoe+=/frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
  -- * actions.aoe+=/howling_blast,if=buff.rime.up
  -- * actions.aoe+=/frostscythe,if=buff.killing_machine.up
  -- * actions.aoe+=/glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
  -- * actions.aoe+=/frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
  -- * actions.aoe+=/remorseless_winter
  -- * actions.aoe+=/frostscythe
  -- * actions.aoe+=/obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
  -- * actions.aoe+=/glacial_advance
  -- * actions.aoe+=/frost_strike
  -- * actions.aoe+=/horn_of_winter
  -- x actions.aoe+=/arcane_torrent

  -- # # Breath of Sindragosa pooling rotation : starts 20s before Pillar of Frost + BoS are available
  -- * actions.bos_pooling=howling_blast,if=buff.rime.up
  -- * actions.bos_pooling+=/obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
  -- * actions.bos_pooling+=/glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&spell_targets.glacial_advance>=2
  -- * actions.bos_pooling+=/frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
  -- * actions.bos_pooling+=/frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
  -- * actions.bos_pooling+=/frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
  -- * actions.bos_pooling+=/obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
  -- * actions.bos_pooling+=/glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
  -- * actions.bos_pooling+=/frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40

  -- * actions.bos_ticking=obliterate,if=runic_power<=30
  -- * actions.bos_ticking+=/remorseless_winter,if=talent.gathering_storm.enabled
  -- * actions.bos_ticking+=/howling_blast,if=buff.rime.up
  -- * actions.bos_ticking+=/obliterate,if=rune.time_to_5<gcd|runic_power<=45
  -- * actions.bos_ticking+=/frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
  -- * actions.bos_ticking+=/horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
  -- * actions.bos_ticking+=/remorseless_winter
  -- * actions.bos_ticking+=/frostscythe,if=spell_targets.frostscythe>=2
  -- * actions.bos_ticking+=/obliterate,if=runic_power.deficit>25|rune>3
  -- x actions.bos_ticking+=/arcane_torrent,if=runic_power.deficit>20

  -- # # Cold heart conditions
  -- * actions.cold_heart=chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
  -- * actions.cold_heart+=/chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up

  -- x actions.cooldowns=use_items,if=cooldown.pillar_of_frost.ready&(!talent.breath_of_sindragosa.enabled|buff.empower_rune_weapon.up)
  -- x actions.cooldowns+=/use_item,name=razdunks_big_red_button
  -- x actions.cooldowns+=/use_item,name=merekthas_fang
  -- * actions.cooldowns+=/potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
  -- x actions.cooldowns+=/blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
  -- x actions.cooldowns+=/berserking,if=buff.pillar_of_frost.up
  -- # # Frost cooldowns
  -- * actions.cooldowns+=/pillar_of_frost,if=cooldown.empower_rune_weapon.remains
  -- * actions.cooldowns+=/breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
  -- * actions.cooldowns+=/empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
  -- * actions.cooldowns+=/empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
  -- * actions.cooldowns+=/call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.time_to_die<=gcd)
  -- x actions.cooldowns+=/frostwyrms_fury,if=buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up

  -- # # Obliteration rotation
  -- * actions.obliteration=remorseless_winter,if=talent.gathering_storm.enabled
  -- * actions.obliteration+=/obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
  -- * actions.obliteration+=/frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
  -- * actions.obliteration+=/obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
  -- * actions.obliteration+=/glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
  -- * actions.obliteration+=/howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
  -- * actions.obliteration+=/frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
  -- * actions.obliteration+=/howling_blast,if=buff.rime.up
  -- * actions.obliteration+=/obliterate

  -- # # Standard single-target rotation
  -- * actions.standard=remorseless_winter
  -- * actions.standard+=/frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
  -- * actions.standard+=/howling_blast,if=buff.rime.up
  -- * actions.standard+=/obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
  -- * actions.standard+=/frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
  -- * actions.standard+=/frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
  -- * actions.standard+=/obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
  -- * actions.standard+=/frost_strike
  -- * actions.standard+=/horn_of_winter
  -- * actions.standard+=/arcane_torrent

--- ========== CONVERTED ACTION LIST ==========

  -- validated 9/29/2018
  local function simc_standard()
    -- remorseless_winter
    -- 40dd79f0-f639-4512-a3e7-3c1a11f4c7f8
    if S.RemorselessWinter:IsCastable() then
      return "remorseless_winter [40dd79f0-f639-4512-a3e7-3c1a11f4c7f8]"
    end

    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    -- cb4a28f5-821e-4fde-9707-3a3450c2e151
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and S.RemorselessWinter:CooldownRemains() <= 2 * Player:GCD() 
      and talent_enabled("Gathering Storm") then

      return "frost_strike [cb4a28f5-821e-4fde-9707-3a3450c2e151]"
    end

    -- howling_blast,if=buff.rime.up
    -- 8da88256-bedd-409b-87dc-5f27b05220fa
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and Player:Buff(S.Rime) then

      return "howling_blast [8da88256-bedd-409b-87dc-5f27b05220fa]"
    end

    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    -- aa354962-0e9b-4dd5-be84-f296d214da2e
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and talent_enabled("Frozen Pulse")
      and (not Player:Buff(S.FrozenPulse)) then

      return "obliterate [aa354962-0e9b-4dd5-be84-f296d214da2e]"
    end

    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    -- 2d3a06a3-0e05-4cd9-a9c1-b31cf70b4c06
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and Player:RunicPowerDeficit() < (15 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "frost_strike [2d3a06a3-0e05-4cd9-a9c1-b31cf70b4c06]"
    end

    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    -- 5d131514-44a8-4dcc-bdc2-52f7dd304c8c
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Player:Buff(S.KillingMachine)
      and Player:RuneTimeToX(4) >= Player:GCD() then

      return "frostscythe [5d131514-44a8-4dcc-bdc2-52f7dd304c8c]"
    end

    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    -- 4025c58f-8fa1-41db-931a-be45cb397cbe
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:RunicPowerDeficit() > (25 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "obliterate [4025c58f-8fa1-41db-931a-be45cb397cbe]"
    end

    -- frost_strike
    -- 76ce6df2-d174-4045-9a2b-9b19939b64a5
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target"))
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike()) then

      return "frost_strike [76ce6df2-d174-4045-9a2b-9b19939b64a5]"
    end

    -- horn_of_winter
    -- d76f9ff0-804b-41fa-8e81-b67289e6f200
    if talent_enabled("Horn of Winter")
      and S.HornOfWinter:IsCastable() then

      return "horn_of_winter [d76f9ff0-804b-41fa-8e81-b67289e6f200]"
    end

    return false
  end

  local function simc_aoe()

    -- remorseless_winter,if=talent.gathering_storm.enabled
    -- d5373287-0c90-4bbe-8a47-9a77a3efda35
    if S.RemorselessWinter:IsCastable() 
      and talent_enabled("Gathering Storm") then

      return "remorseless_winter [d5373287-0c90-4bbe-8a47-9a77a3efda35]"
    end

    -- glacial_advance,if=talent.frostscythe.enabled
    -- 8e457ad4-2950-43a0-948a-f6ac6f9636c9
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable()
      and talent_enabled("Frostscythe") then

      return "glacial_advance [8e457ad4-2950-43a0-948a-f6ac6f9636c9]"
    end

    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    -- 25ba261e-8b2c-41a3-a0a0-24cb4b6c2063
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and S.RemorselessWinter:CooldownRemains() <= 2 * Player:GCD() 
      and talent_enabled("Gathering Storm") then

      return "frost_strike [25ba261e-8b2c-41a3-a0a0-24cb4b6c2063]"
    end

    -- howling_blast,if=buff.rime.up
    -- a0ba5a18-9123-4ac3-b287-f309828e3633
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid() 
      and Player:Buff(S.Rime) then

      return "howling_blast [a0ba5a18-9123-4ac3-b287-f309828e3633]"
    end

    -- frostscythe,if=buff.killing_machine.up
    -- e6cfddb1-f0b7-4449-8ca4-c082d5ca9cb7
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Player:Buff(S.KillingMachine) then

      return "frostscythe [e6cfddb1-f0b7-4449-8ca4-c082d5ca9cb7]"
    end

    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    -- 83d5fbb7-7cb5-4c1b-80e0-0cd9ae8f57d0
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable() 
      and Player:RunicPowerDeficit() < (15 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "glacial_advance [83d5fbb7-7cb5-4c1b-80e0-0cd9ae8f57d0]"
    end

    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    -- 04798d52-1baa-4eb0-ac01-955a1426d8ae
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and Player:RunicPowerDeficit() < (15 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "frost_strike [04798d52-1baa-4eb0-ac01-955a1426d8ae]"
    end

    -- remorseless_winter
    -- d8c0f089-0893-42b8-8561-29ef71b56af1
    if S.RemorselessWinter:IsCastable() then

      return "remorseless_winter [d8c0f089-0893-42b8-8561-29ef71b56af1]"
    end

    -- frostscythe
    -- 37a34895-c86a-463c-878f-e35bc98ff76f
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8) then

      return "frostscythe [37a34895-c86a-463c-878f-e35bc98ff76f]"
    end

    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    -- d256067c-9194-43fe-a8c0-69896d992187
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:RunicPowerDeficit() < (15 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "obliterate [d256067c-9194-43fe-a8c0-69896d992187]"
    end

    -- glacial_advance
    -- 304b52cf-94dc-4524-bb8c-6062a5d6eb22
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable() then

      return "glacial_advance [304b52cf-94dc-4524-bb8c-6062a5d6eb22]"
    end

    -- frost_strike
    -- f8d87eba-5bb4-4382-a9dd-ff1a98edb38e
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target"))
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike()) then

      return "frost_strike [f8d87eba-5bb4-4382-a9dd-ff1a98edb38e]"
    end

    -- horn_of_winter
    -- 6e4380d2-4063-48c5-b0a0-a8333858b349
    if talent_enabled("Horn of Winter")
      and S.HornOfWinter:IsCastable() then

      return "horn_of_winter [6e4380d2-4063-48c5-b0a0-a8333858b349]"
    end

    return false
  end

  local function simc_bos_pooling()

    -- howling_blast,if=buff.rime.up
    -- acc12d67-ec75-490d-a72f-cfec17ea3232
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()      
      and Player:Buff(S.Rime) then

      return "howling_blast [acc12d67-ec75-490d-a72f-cfec17ea3232]"
    end

    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    -- 51395f1a-afe8-4df7-9183-cc747b948f20
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:RuneTimeToX(4) < Player:GCD() 
      and Player:RunicPowerDeficit() >= 25 then

      return "obliterate [51395f1a-afe8-4df7-9183-cc747b948f20]"
    end

    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&spell_targets.glacial_advance>=2
    -- bae35292-9201-4381-a0b5-6eacfcc2deff
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable() 
      and Player:RunicPowerDeficit() < 20 
      and S.PillarOfFrost:CooldownRemains() > Player:RuneTimeToX(4)
      and Cache.EnemiesCount[10] >= 2 then

      return "glacial_advance [bae35292-9201-4381-a0b5-6eacfcc2deff]"
    end

    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    -- bfbb82a5-54b6-4c4c-9ec5-9112d1af7da8
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and Player:RunicPowerDeficit() < 20
      and S.PillarOfFrost:CooldownRemains() > Player:RuneTimeToX(4) then

      return "frost_strike [bfbb82a5-54b6-4c4c-9ec5-9112d1af7da8]"
    end

    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    -- bb9d1f32-fc9e-4a9d-83fe-baf531779878
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Player:Buff(S.KillingMachine) 
      and Player:RunicPowerDeficit() > (15 + (binarize(talent_enabled("Runic Attenuation")) * 3))
      and Cache.EnemiesCount[8] >= 2 then

      return "frostscythe [bb9d1f32-fc9e-4a9d-83fe-baf531779878]"
    end

    -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    -- 102115ba-6c9c-4676-998b-e9dcaaf2677c
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Player:RunicPowerDeficit() > (35 + (binarize(talent_enabled("Runic Attenuation")) * 3))
      and Cache.EnemiesCount[8] >= 2 then

      return "frostscythe [102115ba-6c9c-4676-998b-e9dcaaf2677c]"
    end

    -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
    -- bbada2fd-bba2-44e2-bbaa-a0d37f45ce71
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:RunicPowerDeficit() >= (35 + (binarize(talent_enabled("Runic Attenuation")) * 3)) then

      return "obliterate [bbada2fd-bba2-44e2-bbaa-a0d37f45ce71]"
    end

    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    -- bdee777f-5bc7-415d-b9fa-a74014541778
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable() 
      and S.PillarOfFrost:CooldownRemains() > Player:RuneTimeToX(4) 
      and Player:RunicPowerDeficit() < 40 
      and Cache.EnemiesCount[30] >= 2 then

      return "glacial_advance [bdee777f-5bc7-415d-b9fa-a74014541778]"
    end

    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    -- 1094aa7b-3694-4e7c-a0f3-f8e08aa0fdc0
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and S.PillarOfFrost:CooldownRemains() > Player:RuneTimeToX(4) 
      and Player:RunicPowerDeficit() < 40 then

      return "frost_strike [1094aa7b-3694-4e7c-a0f3-f8e08aa0fdc0]"
    end

    if WH_POOLING_FREEZE 
      and (not HR.CDsON())
      and (Player:Runes() >= 3
        or Player:RunicPowerDeficit() < 25) then

      --actions+=/call_action_list,name=standard
      ShouldReturn = simc_standard()
      if ShouldReturn then return ShouldReturn end
    
    end

    return false
  end

  local function simc_bos_ticking()

    -- obliterate,if=runic_power<=30
    -- 516a4de0-cb97-4d8b-8e00-8833f4fb3802
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:RunicPower() <= 30 then

      return "obliterate [516a4de0-cb97-4d8b-8e00-8833f4fb3802]"
    end

    -- remorseless_winter,if=talent.gathering_storm.enabled
    -- ca3a5d72-731e-4b0d-8d5e-01bb926713f2
    if S.RemorselessWinter:IsCastable() 
      and talent_enabled("Gathering Storm") then

      return "remorseless_winter [ca3a5d72-731e-4b0d-8d5e-01bb926713f2]"
    end

    -- howling_blast,if=buff.rime.up
    -- 983aab94-6eca-4720-8119-7f6315afef67
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and Player:Buff(S.Rime) then

      return "howling_blast [983aab94-6eca-4720-8119-7f6315afef67]"
    end

    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    -- c245b14a-c217-4e29-84a3-174755c4f724
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (Player:RuneTimeToX(5) < Player:GCD() 
        or Player:RunicPower() <= 45) then

      return "obliterate [c245b14a-c217-4e29-84a3-174755c4f724]"
    end

    -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
    -- 8544b2c9-4175-4614-abd6-8e981bec5971
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Player:Buff(S.KillingMachine) 
      and Cache.EnemiesCount[8] >= 2 then

      return "frostscythe [8544b2c9-4175-4614-abd6-8e981bec5971]"
    end

    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    -- a22bc1cc-f6d5-49dd-a5b5-84fcd91dcc5a
    if talent_enabled("Horn of Winter")
      and S.HornOfWinter:IsCastable() 
      and Player:RunicPowerDeficit() >= 30 
      and Player:RuneTimeToX(3) > Player:GCD() then

      return "horn_of_winter [a22bc1cc-f6d5-49dd-a5b5-84fcd91dcc5a]"
    end

    -- remorseless_winter
    -- 12047011-a097-47b9-81d0-ce44b729b50f
    if S.RemorselessWinter:IsCastable() then
      return "remorseless_winter [12047011-a097-47b9-81d0-ce44b729b50f]"
    end

    -- frostscythe,if=spell_targets.frostscythe>=2
    -- 891b8011-1482-4873-8da4-6a49f1302f17
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Cache.EnemiesCount[8] >= 2 then

      return "frostscythe [891b8011-1482-4873-8da4-6a49f1302f17]"
    end

    -- obliterate,if=runic_power.deficit>25|rune>3
    -- c2998ae7-9a96-4f1c-a81d-0f1e36b47122
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (Player:RunicPowerDeficit() > 25 
        or Player:Runes() > 3) then

      return "obliterate [c2998ae7-9a96-4f1c-a81d-0f1e36b47122]"
    end
    
    return false
  end

  local function simc_obliteration()

    -- remorseless_winter,if=talent.gathering_storm.enabled
    -- 633ff471-d73c-4ac3-9eb0-d83cb0495498
    if S.RemorselessWinter:IsCastable() 
      and talent_enabled("Gathering Storm") then

      return "remorseless_winter [633ff471-d73c-4ac3-9eb0-d83cb0495498]"
    end

    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    -- 8072b18a-e829-4991-aad8-5d6eca9ec7c8
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not talent_enabled("Frostscythe"))
      and (not Player:Buff(S.Rime))
      and Cache.EnemiesCount[10] >= 3 then

      return "obliterate [8072b18a-e829-4991-aad8-5d6eca9ec7c8]"
    end

    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
    -- 20c9d4b5-b7f0-4e6c-bae4-dfb143100157
    if talent_enabled("Frostscythe")
      and Everyone.TargetIsValid()
      and S.FrostScythe:IsCastable() 
      and Target:IsInRange(8)
      and Cache.EnemiesCount[8] >= 2
      and (Player:Buff(S.KillingMachine)
        or (Player:Buff(S.KillingMachine)
          and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then

      return "frostscythe [20c9d4b5-b7f0-4e6c-bae4-dfb143100157]"
    end

    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    -- 2411d6cd-8b10-4e82-b3fb-d53fc82e5df0
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (Player:Buff(S.KillingMachine)
        or (Player:Buff(S.KillingMachine)
          and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then

      return "obliterate [2411d6cd-8b10-4e82-b3fb-d53fc82e5df0]"
    end

    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    -- 0bd8c100-fdf0-4713-bec2-582c20d62693
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable()
      and Cache.EnemiesCount[30] >= 2
      and ((not Player:Buff(S.Rime)) 
        or Player:RunicPowerDeficit() < 10 
        or Player:RuneTimeToX(2) > Player:GCD()) then

      return "glacial_advance [0bd8c100-fdf0-4713-bec2-582c20d62693]"
    end

    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    -- 9d5b330d-5ebb-4efa-892f-7bab235f215d
    if S.HowlingBlast:IsReady(30) 
      and Everyone.TargetIsValid()
      and Player:Buff(S.Rime) 
      and Cache.EnemiesCount[10] >= 2 then

      return "howling_blast [9d5b330d-5ebb-4efa-892f-7bab235f215d]"
    end

    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    -- e4a5e42a-67a0-44c5-9eab-acaef30a67d1
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and (not Player:Buff(S.Rime)
        or Player:RunicPowerDeficit() < 10 
        or Player:RuneTimeToX(2) > Player:GCD()) then

      return "frost_strike [e4a5e42a-67a0-44c5-9eab-acaef30a67d1]"
    end

    -- howling_blast,if=buff.rime.up
    -- 56ca4327-20bd-4911-839d-56bb316eb2fd
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and Player:Buff(S.Rime) then

      return "howling_blast [56ca4327-20bd-4911-839d-56bb316eb2fd]"
    end

    -- obliterate
    -- bf8e9022-b9e0-40a8-8d92-c71afbe1e8e1
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid() then

      return "obliterate [bf8e9022-b9e0-40a8-8d92-c71afbe1e8e1]"
    end

    return false
  end

  local function simc_cooldowns()

    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
    -- 2e7b5ff3-a86d-4864-9b88-a0ca1fe69882
    -- added extra code to handle CD variables
    if S.PillarOfFrost:IsCastable() 
      and Everyone.TargetIsValid()
      and (S.EmpowerRuneWeapon:CooldownDown()
        or ((not HR.CDsON())
          and talent_enabled("Breath of Sindragosa")
          and S.BreathofSindragosa:CooldownRemains() > 15)) then

      return "pillar_of_frost [2e7b5ff3-a86d-4864-9b88-a0ca1fe69882]"
    end

    -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    -- fb3a9ecf-d010-4885-9f72-6f8db764e83b
    if HR.CDsON() 
      and Everyone.TargetIsValid()
      and Target:IsInRange(15)
      and S.BreathofSindragosa:IsCastable() 
      and S.EmpowerRuneWeapon:CooldownRemains() > 0 
      and S.PillarOfFrost:CooldownRemains() > 0 then

      return "breath_of_sindragosa [fb3a9ecf-d010-4885-9f72-6f8db764e83b]"
    end

    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
    -- 8cb9f142-310f-40af-b92b-b16a5f685695
    if HR.CDsON() 
      and Everyone.TargetIsValid()
      and Target:IsInRange(15)
      and S.EmpowerRuneWeapon:IsCastable() 
      and S.PillarOfFrost:CooldownUp() 
      and (not talent_enabled("Breath of Sindragosa"))
      and Player:RuneTimeToX(5) > Player:GCD() 
      and Player:RunicPowerDeficit() >= 10 then

      return "empower_rune_weapon [8cb9f142-310f-40af-b92b-b16a5f685695]"
    end

    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
    -- b0a97ff0-e8b2-4715-a16e-7b2392933228
    if HR.CDsON() 
      and Everyone.TargetIsValid()
      and Target:IsInRange(15)
      and S.EmpowerRuneWeapon:IsCastable() 
      and S.PillarOfFrost:CooldownUp()
      and talent_enabled("Breath of Sindragosa")
      and Player:Runes() >= 3 
      and Player:RunicPower() > 60 then

      return "empower_rune_weapon [b0a97ff0-e8b2-4715-a16e-7b2392933228]"
    end

    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if talent_enabled("Cold Heart")
      and ((Player:BuffStack(S.ColdHeartBuff) >= 10
        and Target:DebuffStack(S.RazorIce) == 5)
          or Target:TimeToDie() <= Player:GCD()) then

      -- chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
      -- 136ab978-d120-4a4a-a8a8-49180174ee69
      if S.ChainsOfIce:IsReady(30) 
        and Everyone.TargetIsValid()
        and Player:BuffStack(S.ColdHeartBuff) > 5 
        and Target:TimeToDie() < Player:GCD() then

        return "chains_of_ice [136ab978-d120-4a4a-a8a8-49180174ee69]"
      end

      -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up
      -- 5434b084-bb4c-4bb1-bbfb-2e2ee2b843bc
      if S.ChainsOfIce:IsReady(30) 
        and Everyone.TargetIsValid()
        and Player:Buff(S.PillarOfFrost)
        and (Player:BuffRemains(S.PillarOfFrost) <= Player:GCD() * (1 + (S.FrostwyrmsFury:CooldownUp() and 1 or 0)) 
          or Player:BuffRemains(S.PillarOfFrost) < Player:RuneTimeToX(3)) then
        return "chains_of_ice [5434b084-bb4c-4bb1-bbfb-2e2ee2b843bc]"
      end
    end

    -- frostwyrms_fury,if=buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up
    -- 2a41ac90-7c23-4afc-8fb3-3b908ac14190
    -- if HR.CDsON()
    --   and S.FrostwyrmsFury:IsCastable() 
    --   and Player:BuffRemains(S.PillarOfFrost) <= Player:GCD()
    --   and Player:Buff(S.PillarOfFrost) then

    --   return "frostwyrms_fury [2a41ac90-7c23-4afc-8fb3-3b908ac14190]"
    -- end

    return false
  end

  function FrostDK_APL()
    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not DeathKnight) or (not Settings.DeathKnight) then
      Initialize()
      return nil
    end

    -- Unit Update
    HL.GetEnemies("Melee")
    HL.GetEnemies(8,true)
    HL.GetEnemies(10,true)
    HL.GetEnemies(20,true)
    HL.GetEnemies(30,true)
    Everyone.AoEToggleEnemiesUpdate()

    -- OPENER
    if not Player:AffectingCombat() then
      -- howling_blast
      -- f362b35e-c01f-4c6c-8725-820e45eeafe8
      if Everyone.TargetIsValid() 
        and S.HowlingBlast:IsReady(30)
        and (not Target:Debuff(S.FrostFever)) then
          return "howling_blast [f362b35e-c01f-4c6c-8725-820e45eeafe8]"
      end
      return
    end

    -- ROTATION

    -- Death Strike Heal
    -- ff10ee71-e294-46c0-8c39-f5212edb6ea7
    if Everyone.TargetIsValid() and ShouldDeathStrike() and S.DeathStrike:IsReady() then
        return "death_strike [ff10ee71-e294-46c0-8c39-f5212edb6ea7]"
    end

    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    -- d041b15d-cae4-4c21-a394-d82b046d2bba
    -- added extra code to handle CD variables
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and (not Target:Debuff(S.FrostFever)) 
      and ((not talent_enabled("Breath of Sindragosa")) 
        or S.BreathofSindragosa:CooldownRemains() > 15 
        or (not HR.CDsON())) then

      return "howling_blast [d041b15d-cae4-4c21-a394-d82b046d2bba]"
    end

    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    -- 76de4f33-e708-4e48-b3e8-77ecf425ce21
    -- added extra code to handle CD variables
    if talent_enabled("Glacial Advance")
      and Everyone.TargetIsValid()
      and S.GlacialAdvance:IsCastable() 
      and Player:BuffRemains(S.IcyTalonsBuff) <= Player:GCD() 
      and Player:Buff(S.IcyTalonsBuff) 
      and (Cache.EnemiesCount[10] >= 2) 
      and ((not talent_enabled("Breath of Sindragosa")) 
        or S.BreathofSindragosa:CooldownRemains() > 15 
        or (not HR.CDsON())) then

      return "glacial_advance [76de4f33-e708-4e48-b3e8-77ecf425ce21]"
    end

    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    -- 44792852-fba8-4935-b547-27541897bf73
    -- added extra code to handle CD variables
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (not ShouldDeathStrike())
      and Player:BuffRemains(S.IcyTalonsBuff) <= Player:GCD() 
      and Player:Buff(S.IcyTalonsBuff) 
      and ((not talent_enabled("Breath of Sindragosa")) 
        or S.BreathofSindragosa:CooldownRemains() > 15 
        or (not HR.CDsON())) then

      return "frost_strike [44792852-fba8-4935-b547-27541897bf73]"
    end

    -- call_action_list,name=cooldowns
    ShouldReturn = simc_cooldowns()
    if ShouldReturn then return ShouldReturn end

    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
    if (HR.CDsON() or WH_POOLING_FREEZE)
      and talent_enabled("Breath of Sindragosa") 
      and S.BreathofSindragosa:CooldownRemains() < 5 then
        ShouldReturn = simc_bos_pooling()
        if ShouldReturn then return ShouldReturn end
        return "bos_pooling"
    end

    -- actions+=/run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
    if Player:Buff(S.BreathofSindragosa) then
        ShouldReturn = simc_bos_ticking()
        if ShouldReturn then return ShouldReturn end
        return "bos_ticking"
    end

    --actions+=/run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:Buff(S.PillarOfFrost) and talent_enabled("Obliteration")) then
        ShouldReturn = simc_obliteration()
        if ShouldReturn then return ShouldReturn end
    end

    --actions+=/run_action_list,name=aoe,if=active_enemies>=2
    if HR.AoEON() and Cache.EnemiesCount[10] >= 2 then
      ShouldReturn = simc_aoe()
      if ShouldReturn then return ShouldReturn end
    end

    --actions+=/call_action_list,name=standard
    ShouldReturn = simc_standard()
    if ShouldReturn then return ShouldReturn end

    return "pool"
  end

--- ========== END OF FILE ==========