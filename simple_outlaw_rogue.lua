--- ========== CHANGES ==========

-- 20190309-1 - Remove Shadowmeld Usage -- too many issues
-- 20190309-1 - Incorporate Blade Flurry Usage
-- 20190309-2 - only use Blade Flurry if AOE is toggled on
-- 20190310-1 - cache enemies within 8 yards so Blade Flurry will go off
-- 20190323-1 - fix LUA error with blade_flurry_range

--- ========== HEADER ==========
  
  local FILE_VERSION = 20190323-1

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
    Spell.Rogue.Outlaw = {
      -- Racials
      AncestralCall                   = Spell(274738),
      ArcanePulse                     = Spell(260364),
      ArcaneTorrent                   = Spell(25046),
      Berserking                      = Spell(26297),
      BloodFury                       = Spell(20572),
      Fireblood                       = Spell(265221),
      LightsJudgment                  = Spell(255647),
      Shadowmeld                      = Spell(58984),
      -- Abilities
      AdrenalineRush                  = Spell(13750),
      Ambush                          = Spell(8676),
      BetweentheEyes                  = Spell(199804),
      BladeFlurry                     = Spell(13877),
      Opportunity                     = Spell(195627),
      PistolShot                      = Spell(185763),
      RolltheBones                    = Spell(193316),
      Dispatch                        = Spell(2098),
      SinisterStrike                  = Spell(193315),
      Stealth                         = Spell(1784),
      Vanish                          = Spell(1856),
      VanishBuff                      = Spell(11327),
      -- Talents
      AcrobaticStrikes                = Spell(196924),
      BladeRush                       = Spell(271877),
      DeeperStratagem                 = Spell(193531),
      GhostlyStrike                   = Spell(196937),
      KillingSpree                    = Spell(51690),
      LoadedDiceBuff                  = Spell(256171),
      MarkedforDeath                  = Spell(137619),
      QuickDraw                       = Spell(196938),
      SliceandDice                    = Spell(5171),
      -- Azerite Traits
      AceUpYourSleeve                 = Spell(278676),
      Deadshot                        = Spell(272935),
      SnakeEyesPower                  = Spell(275846),
      SnakeEyesBuff                   = Spell(275863),
      -- Defensive
      CrimsonVial                     = Spell(185311),
      Feint                           = Spell(1966),
      -- Utility
      Kick                            = Spell(1766),
      -- Roll the Bones
      Broadside                       = Spell(193356),
      BuriedTreasure                  = Spell(199600),
      GrandMelee                      = Spell(193358),
      RuthlessPrecision               = Spell(193357),
      SkullandCrossbones              = Spell(199603),
      TrueBearing                     = Spell(193359)
    };
    S = Spell.Rogue.Outlaw;


    -- Items
    if not Item.Rogue then Item.Rogue = {}; end
    Item.Rogue.Outlaw = {
      BattlePotionOfStrength = Item(163224)
    };
    I = Item.Rogue.Outlaw;

    -- GUI Settings
    if (not Settings) or (not Settings.Rogue) then
      Settings = {
        General = HR.GUISettings.General,
        Rogue = HR.GUISettings.APL.Rogue
      }
    end
  end

--- ========== HELPER FUNCTIONS ==========

  local function numRTB()
    local bs = Player:Buff(S.Broadside)
    local bt = Player:Buff(S.BuriedTreasure)
    local gm = Player:Buff(S.GrandMelee)
    local rp = Player:Buff(S.RuthlessPrecision)
    local sb = Player:Buff(S.SkullandCrossbones)
    local tb = Player:Buff(S.TrueBearing)
    local c = 0
    if bs then c = c + 1 end
    if bt then c = c + 1 end
    if gm then c = c + 1 end
    if rp then c = c + 1 end
    if sb then c = c + 1 end
    if tb then c = c + 1 end
    return c
  end

  local function durRTB()
    local bs = Player:BuffRemains(S.Broadside)
    local bt = Player:BuffRemains(S.BuriedTreasure)
    local gm = Player:BuffRemains(S.GrandMelee)
    local rp = Player:BuffRemains(S.RuthlessPrecision)
    local sb = Player:BuffRemains(S.SkullandCrossbones)
    local tb = Player:BuffRemains(S.TrueBearing)
    if bs > 0 then return bs end
    if bt > 0 then return bt end
    if gm > 0 then return gm end
    if rp > 0 then return rp end
    if sb > 0 then return sb end
    if tb > 0 then return tb end
    return 0
  end

  local function ShouldCrimsonVial()
    return S.CrimsonVial:IsReady() and Player:HealthPercentage() < 75 and alone()
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

  local function num(val)
    if val then return 1 else return 0 end
  end

  local function EnergyTimeToMaxRounded ()
    -- Round to the nearesth 10th to reduce prediction instability on very high regen rates
    return math.floor(Player:EnergyTimeToMaxPredicted() * 10 + 0.5) / 10;
  end

  local function Ambush_Condition ()
    -- actions+=/variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
    return Player:ComboPointsDeficit() >= 2 + 2 * ((S.GhostlyStrike:IsAvailable() and S.GhostlyStrike:CooldownRemainsP() < 1) and 1 or 0)
      + (Player:Buff(S.Broadside) and 1 or 0) and Player:EnergyPredicted() > 60 and not Player:Buff(S.SkullandCrossbones);
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

  function OutlawROG_APL()
    local e = nil
    if (not S) then
      e = "NOT DEFINED: S"
    end
    if (not I) then
      e = "NOT DEFINED: I"
    end 
    if (not Settings) then
      e = "NOT DEFINED: Settings"
    end 
    if (not HR) then
      e = "NOT DEFINED: HR"
    end  
    if (not HL) then
      e = "NOT DEFINED: HL"
    end 
    if (not Cache)  then
      e = "NOT DEFINED: Cache"
    end 
    if (not Unit) then
      e = "NOT DEFINED: Unit"
    end  
    if (not Player) then
      e = "NOT DEFINED: Player"
    end  
    if (not Target) then
      e = "NOT DEFINED: Target"
    end  
    if (not Spell) then
      e = "NOT DEFINED: Spell"
    end  
    if (not Item) then
      e = "NOT DEFINED: Item"
    end 
    if (not Everyone) then
      e = "NOT DEFINED: Everyone"
    end   
    if (not Rogue) then
      e = "NOT DEFINED: Rogue"
    end   
    if (Settings and not Settings.Rogue) then
      e = "NOT DEFINED: Settings.Rogue"
    end  
    if e ~= nil then
      Initialize()
      return e
    end

    -- Unit Update
    HL.GetEnemies(8,true)
    HL.GetEnemies(10,true)
    Everyone.AoEToggleEnemiesUpdate()

    local use_cooldowns = HR.CDsON()
    local use_aoe = HR.AoEON()
    local rupture_threshold = (4 + Player:ComboPoints() * 4) * 0.3
    local garrote_threshold = 5.4
    local rtb_count = numRTB()
    local rtb_duration = durRTB()
    local blade_flurry_range = talent_enabled("Acrobatic Strikes") and 10 or "Melee"
    local blade_flurry_sync = use_aoe or Cache.EnemiesCount[blade_flurry_range] < 2 or Player:BuffP(S.BladeFlurry)

    -- Crimson Vial if hp low and not in group environment.
    -- d53882c9-fb9f-4715-8c2c-f95d7574e509
    if ShouldCrimsonVial() then
        return "crimson_vial [d53882c9-fb9f-4715-8c2c-f95d7574e509]"
    end

    -- STEALTH

      -- ambush from stealth
      -- aa8f1bfc-3e2e-4e45-ba75-795e0ac71039
      if S.Ambush:IsReady()
        and target_range(8)
        and Player:Buff(S.Stealth) then

        return "ambush [aa8f1bfc-3e2e-4e45-ba75-795e0ac71039]"
      end 

    -- CDS

      -- adrenaline_rush,if=!buff.adrenaline_rush.up&energy.time_to_max>1
      -- 2e63c2ff-7a3c-4bab-ace5-fdae339a4d80
      if S.AdrenalineRush:IsReady()
        and use_cooldowns
        and target_range(8)
        and (not Player:Buff(S.Stealth))
        and EnergyTimeToMaxRounded() > 1
        and (Target:FilteredTimeToDie(">",5) or is_boss("target")) then

        return "adrenaline_rush [2e63c2ff-7a3c-4bab-ace5-fdae339a4d80]"
      end 

      -- blade_flurry,if=spell_targets>=2&!buff.blade_flurry.up&
      -- e16fb760-0877-4035-9dac-1aab82bac463
      if S.BladeFlurry:IsReady()
        and use_aoe
        and target_range(8)
        and enemy_count(8) >= 2
        and not Player:Buff(S.BladeFlurry) then

        return "blade_flurry [e16fb760-0877-4035-9dac-1aab82bac463]"
      end

      -- blade_rush,if=variable.blade_flurry_sync&energy.time_to_max>1
      -- b77caaae-1c0e-440a-85b2-68cc753779bc
      if S.BladeRush:IsReady()
        and target_range(20)
        and blade_flurry_sync
        and EnergyTimeToMaxRounded() > 1 then

        return "blade_rush [b77caaae-1c0e-440a-85b2-68cc753779bc]"
      end 

      -- vanish,if=!stealthed.all&variable.ambush_condition
      -- 54c5e529-4834-4c10-9795-cee479a22f21
      if S.Vanish:IsReady()
        and use_cooldowns
        and (not alone())
        and target_range(8)
        and (not Player:Buff(S.Stealth))
        and (Target:FilteredTimeToDie(">",5) or is_boss("target"))
        and Ambush_Condition() then

        return "vanish [54c5e529-4834-4c10-9795-cee479a22f21]"
      end

      -- shadowmeld,if=!stealthed.all&variable.ambush_condition
      -- 91db660c-2d6a-4f9e-953c-c9284fcebc57
      -- if S.Shadowmeld:IsReady()
      --   and use_cooldowns
      --   and (not alone())
      --   and target_range(8)
      --   and (not Player:Buff(S.Stealth))
      --   and (Target:FilteredTimeToDie(">",5) or is_boss("target"))
      --   and Ambush_Condition() then

      --   return "shadowmeld [91db660c-2d6a-4f9e-953c-c9284fcebc57]"
      -- end

    -- FINISH
      -- call_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))

      if Player:ComboPoints() >= Rogue.CPMaxSpend() - (num(Player:BuffP(S.Broadside)) + num(Player:BuffP(S.Opportunity))) * num(S.QuickDraw:IsAvailable() and (not S.MarkedforDeath:IsAvailable() or S.MarkedforDeath:CooldownRemainsP() > 1)) then

        -- between_the_eyes,if=buff.ruthless_precision.up|(azerite.deadshot.enabled|azerite.ace_up_your_sleeve.enabled)&buff.roll_the_bones.up
        -- BtE over RtB rerolls with Deadshot/Ace traits or Ruthless Precision.
        -- a2d550cf-6ad7-446a-8bf2-79b46de583a7
        if S.BetweentheEyes:IsReady()
          and target_range(20)
          and rtb_duration > 0
          and (Player:BuffP(S.RuthlessPrecision) or S.Deadshot:AzeriteEnabled() or S.AceUpYourSleeve:AzeriteEnabled()) then

          return "between_the_eyes [a2d550cf-6ad7-446a-8bf2-79b46de583a7]"
        end 

        -- roll_the_bones,if=buff.roll_the_bones.remains<=3|variable.rtb_reroll
        -- 1d953ad0-1ce0-4959-a687-e6c101d7515f
        if S.RolltheBones:IsReady()
          and target_range(8)
          and (rtb_duration <= 3 or (rtb_count <= 1 and (not (Player:Buff(S.GrandMelee) or Player:Buff(S.RuthlessPrecision))))) then

          return "roll_the_bones [1d953ad0-1ce0-4959-a687-e6c101d7515f]"
        end 

        -- dispatch
        -- 8012c385-007d-47a3-8d3e-6e4ab4468e7a
        if S.Dispatch:IsReady()
          and target_range(8) then

          return "dispatch [8012c385-007d-47a3-8d3e-6e4ab4468e7a]"
        end

      end

    -- BUILDERS
      -- TODO: FINISH IMPLEMENTING BUILDERS HERE

      -- pistol_shot,if=combo_points.deficit>=1+buff.broadside.up+talent.quick_draw.enabled&buff.opportunity.up&(buff.keep_your_wits_about_you.stack<25|buff.deadshot.up)
      -- 289b8e3a-974e-445e-b83f-8d6b49cb0dc4
      if S.PistolShot:IsReady()
        and target_range(20)
        and Player:ComboPointsDeficit() >= 1 + binarize(Player:Buff(S.Broadside)) + binarize(talent_enabled("Quick Draw") and Player:Buff(S.Opportunity))
        and Player:Buff(S.Opportunity) then

        return "pistol_shot [289b8e3a-974e-445e-b83f-8d6b49cb0dc4]"
      end 

      -- sinister_strike
      -- 548c6470-5cf6-43e1-8ccc-w
      if S.SinisterStrike:IsReady()
        and target_range(8) then

        return "sinister_strike [548c6470-5cf6-43e1-8ccc-d706b624c353]"
      end 

    -- Stealth when out of combat.
    -- 57689e7f-6865-48eb-acd6-48379520862a
    if (S.Stealth:IsReady())
      and not Player:Buff(S.Stealth) then

      return "stealth [57689e7f-6865-48eb-acd6-48379520862a]"
    end

    return "pool"
  end

--- ========== END OF FILE ==========