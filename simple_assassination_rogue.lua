--- ========== TODO ==========

-- 20190225-1 - don't vanish when alone

--- ========== HEADER ==========
  
  local FILE_VERSION = 20190225-1

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
    return S.CrimsonVial:IsReady() and Player:HealthPercentage() < 75 and alone()
  end

--- ========== SIMCRAFT PRIORITY LIST ==========

    -- Crimson Vial if hp low and not in group environment.
    -- Maintain Rupture (4+ Combo Points).
    -- Activate Vendetta when available.
    -- Activate Vanish on cooldown if using Subterfuge.
    -- Maintain Garrote.
    -- Cast Toxic Blade when available, if you have chosen this talent.
    -- Cast Envenom with 4-5 Combo Points (5-6 with Deeper Stratagem).
    -- Cast Fan of Knives when 2+ targets are within range to generate Combo Points.
    -- Cast Mutilate to generate Combo Points (do not use it if Blindside is available).
    -- Stealth when out of combat.

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
    local use_aoe = HR.AoEON()
    local rupture_threshold = (4 + Player:ComboPoints() * 4) * 0.3
    local garrote_threshold = 5.4

    -- Crimson Vial if hp low and not in group environment.
    -- d53882c9-fb9f-4715-8c2c-f95d7574e509
    if ShouldCrimsonVial() then
        return "crimson_vial [d53882c9-fb9f-4715-8c2c-f95d7574e509]"
    end

    -- STEALTH

      -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&refreshable&target.time_to_die-remains>2
      -- aa8f1bfc-3e2e-4e45-ba75-795e0ac71039
      if S.Garrote:IsReady()
        and target_range("Melee")
        and (Player:Buff(S.Stealth) or Player:Buff(S.Stealth2))
        and talent_enabled("Subterfuge")
        and Target:DebuffRefreshableP(S.Garrote, garrote_threshold) 
        and Target:FilteredTimeToDie(">",2) then

        return "garrote [aa8f1bfc-3e2e-4e45-ba75-795e0ac71039]"
      end 

    -- CDS

      -- Activate Vendetta when available.
      -- 2e63c2ff-7a3c-4bab-ace5-fdae339a4d80
      if S.Vendetta:IsReady()
        and use_cooldowns
        and target_range("Melee")
        and (not (Player:Buff(S.Stealth) or Player:Buff(S.Stealth2)))
        and Target:DebuffRemains(S.Rupture) > 0
        and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

        return "vendetta [2e63c2ff-7a3c-4bab-ace5-fdae339a4d80]"
      end 

      -- Activate Vanish on cooldown if using Subterfuge.
      -- 54c5e529-4834-4c10-9795-cee479a22f21
      if S.Vanish:IsReady()
        and use_cooldowns
        and (not alone())
        and talent_enabled("Subterfuge")
        and Everyone.TargetIsValid()
        and (not (Player:Buff(S.Stealth) or Player:Buff(S.Stealth2)))
        and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

        return "vanish [54c5e529-4834-4c10-9795-cee479a22f21]"
      end

      -- Cast Toxic Blade when available, if you have chosen this talent.
      -- b77caaae-1c0e-440a-85b2-68cc753779bc
      if S.ToxicBlade:IsReady()
        and target_range("Melee")
        and Target:DebuffRemains(S.Rupture) > 0 then

        return "toxic_blade [b77caaae-1c0e-440a-85b2-68cc753779bc]"
      end 

    -- DOT

      -- Maintain Garrote.
      -- a2d550cf-6ad7-446a-8bf2-79b46de583a7
      if S.Garrote:IsReady()
        and target_range("Melee")
        and Target:DebuffRefreshableP(S.Garrote, garrote_threshold) 
        and Target:FilteredTimeToDie(">",2) then

        return "garrote [a2d550cf-6ad7-446a-8bf2-79b46de583a7]"
      end 
    
      -- Maintain Rupture (4+ Combo Points).
      -- 1d953ad0-1ce0-4959-a687-e6c101d7515f
      if S.Rupture:IsReady()
        and target_range("Melee")
        and Player:ComboPoints() >= 4
        and Target:DebuffRefreshableP(S.Rupture, rupture_threshold) 
        and Target:FilteredTimeToDie(">",4) then

        return "rupture [1d953ad0-1ce0-4959-a687-e6c101d7515f]"
      end 

    -- DIRECT

      -- Cast Envenom with 4-5 Combo Points (5-6 with Deeper Stratagem).
      -- 289b8e3a-974e-445e-b83f-8d6b49cb0dc4
      if S.Envenom:IsReady()
        and target_range("Melee")
        and Player:ComboPoints() >= 4 + binarize(talent_enabled("deeper stratagem")) then

        return "envenom [289b8e3a-974e-445e-b83f-8d6b49cb0dc4]"
      end 

      -- Cast Fan of Knives when 2+ targets are within range to generate Combo Points.
      -- 548c6470-5cf6-43e1-8ccc-w
      if S.FanofKnives:IsReady()
        and Everyone.TargetIsValid()
        and (not ShouldCrimsonVial())
        and use_aoe
        and Cache.EnemiesCount[10] >= 2 then

        return "fan_of_knives [548c6470-5cf6-43e1-8ccc-d706b624c353]"
      end 

      -- Cast Mutilate to generate Combo Points (do not use it if Blindside is available).
      -- b389a045-b3f0-403e-9846-34c0ce0f6f35
      if S.Mutilate:IsReady()
        and target_range("Melee")
        and (not ShouldCrimsonVial()) then

        return "mutilate [b389a045-b3f0-403e-9846-34c0ce0f6f35]"
      end 

    -- Stealth when out of combat.
    -- 57689e7f-6865-48eb-acd6-48379520862a
    if (S.Stealth:IsReady() or S.Stealth2:IsReady())
      and not (Player:Buff(S.Stealth) or Player:Buff(S.Stealth2)) then

      return "stealth [57689e7f-6865-48eb-acd6-48379520862a]"
    end

    return "pool"
  end

  function target_range(distance)
    return Everyone.TargetIsValid() and (Target:IsInRange(distance) or (is_boss("target") and Target:IsInRange(20)))
  end

  function enemy_count(range)
    local num = Cache.EnemiesCount[range]
    if num == nil then
      num = WH_ENEMY_CACHE[range]
    else
      WH_ENEMY_CACHE[range] = num
    end
    if num == nil then
      if target_range(range) then
        num = 1
      else
        num = 0
      end
    end
    --print(range.."//"..num)
    return num
  end
--- ========== END OF FILE ==========