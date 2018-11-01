--- ========== TODO ==========

  -- better / auto cd handling?
  -- change is_boss ignore range checks to list of "big mobs" by name?
  -- add back in toggles for AOE
  -- interrupt at END of most casts -- exception lists for some?

--- ========== HEADER ==========
  
  local FILE_VERSION = 20181101-1

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
  local Rogue = HR.Commons.Rogue
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
    if not Rogue then Rogue = HR.Commons.Rogue end

    -- Spells
    if not Spell.Rogue then Spell.Rogue = {} end
    Spell.Rogue.Assassination = {
        -- Racials
        ArcanePulse           = Spell(260364),
        ArcaneTorrent         = Spell(25046),
        Berserking            = Spell(26297),
        BloodFury             = Spell(20572),
        LightsJudgment        = Spell(255647),
        -- Abilities
        Envenom               = Spell(32645),
        FanofKnives           = Spell(51723),
        Garrote               = Spell(703),
        KidneyShot            = Spell(408),
        Mutilate              = Spell(1329),
        PoisonedKnife         = Spell(185565),
        Rupture               = Spell(1943),
        Stealth               = Spell(1784),
        Stealth2              = Spell(115191), -- w/ Subterfuge Talent
        Vanish                = Spell(1856),
        VanishBuff            = Spell(11327),
        Vendetta              = Spell(79140),
        -- Talents
        Blindside             = Spell(111240),
        BlindsideBuff         = Spell(121153),
        CrimsonTempest        = Spell(121411),
        DeeperStratagem       = Spell(193531),
        Exsanguinate          = Spell(200806),
        HiddenBladesBuff      = Spell(270070),
        InternalBleeding      = Spell(154953),
        MarkedforDeath        = Spell(137619),
        MasterAssassin        = Spell(255989),
        Nightstalker          = Spell(14062),
        Subterfuge            = Spell(108208),
        ToxicBlade            = Spell(245388),
        ToxicBladeDebuff      = Spell(245389),
        VenomRush             = Spell(152152),
        -- Azerite Traits
        DoubleDose            = Spell(273007),
        SharpenedBladesPower  = Spell(272911),
        SharpenedBladesBuff   = Spell(272916),
        ShroudedSuffocation   = Spell(278666),
        -- Defensive
        CrimsonVial           = Spell(185311),
        Feint                 = Spell(1966),
        -- Utility
        Blind                 = Spell(2094),
        Kick                  = Spell(1766),
        -- Poisons
        CripplingPoison       = Spell(3408),
        DeadlyPoison          = Spell(2823),
        DeadlyPoisonDebuff    = Spell(2818),
        WoundPoison           = Spell(8679),
        WoundPoisonDebuff     = Spell(8680),
        -- Misc
        TheDreadlordsDeceit   = Spell(208693),
        PoolEnergy            = Spell(9999000010)
    }
    S = Spell.Rogue.Assassination

    -- Items
    if not Item.Rogue then Item.Rogue = {} end
    Item.Rogue.Assassination = {
      BattlePotionOfStrength = Item(163224)
    }
    I = Item.Rogue.Assassination

    -- GUI Settings
    if (not Settings) or (not Settings.Rogue) then
      Settings = {
        General = HR.GUISettings.General,
        Rogue = HR.GUISettings.APL.Rogue
      }
    end
  end

--- ========== HELPER FUNCTIONS ==========

  local function ShouldCrimsonVial()
    return (Settings.General.SoloMode and Player:HealthPercentage() < 35)
      and alone()
  end

--- ========== SIMCRAFT PRIORITY LIST ==========

    -- Maintain Rupture (4+ Combo Points).
    -- Activate Vendetta when available.
    -- Activate Vanish on cooldown if using Subterfuge.
    -- Maintain Garrote.
    -- Cast Toxic Blade when available, if you have chosen this talent.
    -- Cast Envenom with 4-5 Combo Points (5-6 with Deeper Stratagem).
    -- Cast Fan of Knives when 2+ targets are within range to generate Combo Points.
    -- Cast Mutilate to generate Combo Points (do not use it if Blindside is available).

--- ========== CONVERTED ACTION LIST ==========

  function AssassinationROG_APL()
    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not Rogue) or (not Settings.Rogue) then
      Initialize()
      return nil
    end

    -- Unit Update
    HL.GetEnemies(10,true)
    Everyone.AoEToggleEnemiesUpdate()

    local use_cooldowns = HR.CDsON()
    local rupture_threshold = (4 + Player:ComboPoints() * 4) * 0.3
    local garrote_threshold = 5.4

    -- Maintain Rupture (4+ Combo Points).
    -- 1d953ad0-1ce0-4959-a687-e6c101d7515f
    if S.Rupture:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:ComboPoints() >= 4
      and Target:DebuffRefreshableP(S.Rupture, rupture_threshold) 
      and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

      return "rupture [1d953ad0-1ce0-4959-a687-e6c101d7515f]"
    end 

    -- Activate Vendetta when available.
    -- 2e63c2ff-7a3c-4bab-ace5-fdae339a4d80
    if S.Vendetta:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and use_cooldowns
      and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

      return "vendetta [2e63c2ff-7a3c-4bab-ace5-fdae339a4d80]"
    end 

    -- Activate Vanish on cooldown if using Subterfuge.
    -- 54c5e529-4834-4c10-9795-cee479a22f21
    if S.Vanish:IsReady()
      and Everyone.TargetIsValid()
      and talent_enabled("subterfuge")
      and is_boss("target") then

      return "vanish [54c5e529-4834-4c10-9795-cee479a22f21]"
    end

    -- Maintain Garrote.
    -- a2d550cf-6ad7-446a-8bf2-79b46de583a7
    if S.Garrote:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Target:DebuffRefreshableP(S.Garrote, garrote_threshold) 
      and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

      return "garrote [a2d550cf-6ad7-446a-8bf2-79b46de583a7]"
    end 

    -- Cast Toxic Blade when available, if you have chosen this talent.
    -- b77caaae-1c0e-440a-85b2-68cc753779bc
    if S.ToxicBlade:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid() then

      return "toxic_blade [b77caaae-1c0e-440a-85b2-68cc753779bc]"
    end 

    -- Cast Envenom with 4-5 Combo Points (5-6 with Deeper Stratagem).
    -- 289b8e3a-974e-445e-b83f-8d6b49cb0dc4
    if S.Envenom:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and Player:ComboPoints() >= 4 + binarize(talent_enabled("deeper stratagem")) then

      return "envenom [289b8e3a-974e-445e-b83f-8d6b49cb0dc4]"
    end 

    -- Cast Fan of Knives when 2+ targets are within range to generate Combo Points.
    -- 548c6470-5cf6-43e1-8ccc-d706b624c353
    if S.FanofKnives:IsReady()
      and Everyone.TargetIsValid()
      and Cache.EnemiesCount[10] >= 2 then

      return "fan_of_knives [548c6470-5cf6-43e1-8ccc-d706b624c353]"
    end 

    -- Cast Mutilate to generate Combo Points (do not use it if Blindside is available).
    -- b389a045-b3f0-403e-9846-34c0ce0f6f35
    if S.Mutilate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid() then

      return "mutilate [b389a045-b3f0-403e-9846-34c0ce0f6f35]"
    end 

    return "pool"
  end

--- ========== END OF FILE ==========