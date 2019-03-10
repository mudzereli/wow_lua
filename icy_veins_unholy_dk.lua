--- ========== CHANGES ==========

-- 20190219-1 - Use Dark Transformation all the time
-- 20190222-1 - Rearrange some priorities based on Simcraft
-- 20190223-1 - Use Dark Succor to Heal w/ Death Strike
-- 20190309-1 - Emergency Death Strikes when not in party

-- TODO
-- improve epidemic usage
-- improve SS usage during DND?

--- ========== HEADER ==========

  local FILE_VERSION = 20190309-1

  local addonName, addonTable = ...;
  local HL = HeroLib;
  local Cache = HeroCache;
  local Unit = HL.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = HL.Spell;
  local Item = HL.Item;
  local HR = HeroRotation;

--- ========== LOCAL VARIABLES ==========

  local Everyone = HR.Commons.Everyone;
  local DeathKnight = HR.Commons.DeathKnight;
  local Settings = nil;
  local I = nil;
  local S = nil;

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
    if not Spell.DeathKnight then Spell.DeathKnight = {}; end
    Spell.DeathKnight.Unholy = {
      -- Racials
      ArcaneTorrent                 = Spell(50613),
      Berserking                    = Spell(26297),
      BloodFury                     = Spell(20572),
      GiftoftheNaaru                = Spell(59547),
      --Abilities
      ArmyOfTheDead                 = Spell(42650),
      Apocalypse                    = Spell(275699),
      ChainsOfIce                   = Spell(45524),
      ScourgeStrike                 = Spell(55090),
      DarkTransformation            = Spell(63560),
      DeathAndDecay                 = Spell(43265),
      DeathCoil                     = Spell(47541),
      DeathStrike                   = Spell(49998),
      FesteringStrike               = Spell(85948),
      Outbreak                      = Spell(77575),
      SummonPet                     = Spell(46584),
         --Talents
      InfectedClaws                 = Spell(207272),
      AllWillServe                  = Spell(194916),
      ClawingShadows                = Spell(207311),
      PestilentPustules             = Spell(194917),
      BurstingSores                 = Spell(207264),
      EbonFever                     = Spell(207269),
      UnholyBlight                  = Spell(115989),
      HarbringerOfDoom              = Spell(276023),
      SoulReaper                    = Spell(130736),
      Pestilence                    = Spell(277234),
      Defile                        = Spell(152280),
      Epidemic                      = Spell(207317),
      ArmyOfTheDammed               = Spell(276837),
      UnholyFrenzy                  = Spell(207289),
      SummonGargoyle                = Spell(49206),
      --Buffs/Procs
      MasterOfGhouls                = Spell(246995), -- ??
      SuddenDoom                    = Spell(81340),
      UnholyStrength                = Spell(53365),
      DeathAndDecayBuff             = Spell(188290),
      --Debuffs
      FesteringWound                = Spell(194310), --max 8 stacks
      VirulentPlagueDebuff          = Spell(191587), -- 13s debuff from Outbreak
      RunicCorruption               = Spell(51462),
      --Defensives
      AntiMagicShell                = Spell(48707),
      IcebornFortitute              = Spell(48792),
       -- Utility
      ControlUndead                 = Spell(45524),
      DeathGrip                     = Spell(49576),
      MindFreeze                    = Spell(47528),
      PathOfFrost                   = Spell(3714),
      WraithWalk                    = Spell(212552),
      --SummonGargoyle HiddenAura
      SummonGargoyleActive          = Spell(212412), --tbc
      -- Misc
      PoolForResources              = Spell(9999000010)
    };
    S = Spell.DeathKnight.Unholy;

    -- Items
    if not Item.DeathKnight then Item.DeathKnight = {}; end
    Item.DeathKnight.Unholy = {
      BattlePotionOfStrength = Item(163224)
    };
    I = Item.DeathKnight.Unholy;

    -- GUI Settings
    if (not Settings) or (not Settings.DeathKnight) then
      Settings = {
        General = HR.GUISettings.General,
        DeathKnight = HR.GUISettings.APL.DeathKnight
      };
    end
  end

--- ========== HELPER FUNCTIONS ==========

  local function ShouldDeathStrike()
    return ((Settings.General.SoloMode and Player:HealthPercentage() < Settings.DeathKnight.Commons.UseDeathStrikeHP)
      or (Player:Buff(S.DarkSuccor) and Player:HealthPercentage() < 75))
      and alone()
  end

--- ========== CONVERTED ACTION LIST ==========

  function UnholyDK_APL()

    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not DeathKnight) or (not Settings.DeathKnight) then
      Initialize()
      return nil
    end

    -- variable,name=use_cooldowns,value=1
    local use_cooldowns = HR.CDsON()

    -- variable,name=use_aoe,value=1
    local use_aoe = HR.AoEON()

    -- Unit Updates
    HL.GetEnemies("Melee")
    HL.GetEnemies(8)
    HL.GetEnemies(10)
    HL.GetEnemies(20)
    HL.GetEnemies(30)
    Everyone.AoEToggleEnemiesUpdate()

    -- Emergency Death Strikes when not in party
    if S.DeathStrike:IsReady()
      and target_range("Melee")
      and Player:HealthPercentage() < 50
      and (Player:RunicPower() >= 35 or Player:Buff(S.DarkSuccor))
      and alone() then

      return "death_strike [a14c3c7a-9e34-4d8d-aab8-9e13be5626ee]"
    end

    -- Maintain Virulent Plague Icon Virulent Plague on the target, using Outbreak Icon Outbreak to refresh it when it is about to expire.
    if S.Outbreak:IsReady()
      and target_range(30)
      and Target:DebuffRemains(S.VirulentPlagueDebuff) <= Player:GCD() then 

      return "outbreak [1f1b36ae-40a3-4db5-9a1d-4c5d1548b927]"
    end

    -- Cast Apocalypse Icon Apocalypse when you have 4 stacks of Festering Wound Icon Festering Wounds.
    if use_cooldowns
      and S.Apocalypse:IsReady() 
      and target_range("Melee")
      and Target:DebuffStack(S.FesteringWound) >= 4 then
      
      return "apocalypse [b99a2804-99c2-49d0-adcd-5976bc4e0da5]"
    end

    -- Cast Dark Transformation Icon Dark Transformation.
    if S.DarkTransformation:IsReady() 
      and target_range(30) then

      return "dark_transformation [27340745-059c-4c3e-97b8-1ed2dc6a0dc7]"
    end

    -- This single target rotation assumes you have taken the tier 7 talent Unholy Frenzy Icon Unholy Frenzy. 
    -- In order to maximize this talent, you should use it when you are very low on Festering Wound Icon Festering Wounds and have at least 2 Runes available to cast Scourge Strike Icon Scourge Strikes after using the cooldown.
    if use_cooldowns
      and talent_enabled("Unholy Frenzy")
      and S.UnholyFrenzy:IsReady()
      and target_range("Melee")
      and Target:DebuffStack(S.FesteringWound) <= 3 then

      return "unholy_frenzy [54d5dd3d-1e86-4f71-8c86-fde4acd29410]"
    end

    -- Cast Soul Reaper Icon Soul Reaper if you have fewer than 2 Runes.
    if talent_enabled("Soul Reaper")
      and S.SoulReaper:IsReady()
      and target_range("Melee")
      and Player:Rune() < 2 then

      return "soul_reaper [a76c1952-8a73-4397-941f-0d6781f62617]"
    end

    -- [AOE] Cast Death and Decay Icon Death and Decay.
    if S.DeathAndDecay:IsReady()
      and target_range(8)
      and enemy_count("Melee") >= 2
      and Target:DebuffStack(S.FesteringWound) >= 1
      and current_speed("target") == 0
      and current_speed("player") == 0 then

      return "death_and_decay [05bbedc1-d299-4f1f-a948-8b361db6fba5]"
    end

    -- Epidemic Icon Epidemic takes priority over Death Coil Icon Death Coil when there are 2+ targets.
    if talent_enabled("Epidemic")
      and S.Epidemic:IsReady()
      and target_range(10)
      and enemy_count(10) >= 2
      and Target:DebuffRemains(S.VirulentPlagueDebuff) > 0
      and Player:RunicPower() >= 80 then

      return "epidemic [0503b99a-e2e2-4112-9d8c-ee3431206e28]"
    end

    -- Cast Death Coil Icon Death Coil to avoid capping Runic Power (80+ Runic Power) OR if you have a proc of Sudden Doom Icon Sudden Doom.
    if S.DeathCoil:IsReady()
      and target_range(30)
      and (Player:RunicPower() >= 80 
        or Player:Buff(S.SuddenDoom)) then

      return "death_coil [a59f3a03-1c76-471a-b4e6-51387fcf1731]"
    end

    -- Cast Scourge Strike Icon Scourge Strike (or Clawing Shadows Icon Clawing Shadows, if you have taken this talent), if there are 1+ Festering Wound Icon Festering Wounds on the target.
    -- If there are 0 Festering Wound Icon Festering Wounds on the target, use Festering Strike Icon Festering Strike.
    if S.ScourgeStrike:IsReady()
      and target_range("Melee")
      and Target:DebuffStack(S.FesteringWound) >= 1
      and (S.Apocalypse:CooldownRemains() > 0  or (not use_cooldowns)) then

      return "scourge_strike [93f717d1-1f5b-4e8b-a6da-b5a67e35d801]"
    end

    -- Cast Festering Strike Icon Festering Strike.
    -- This applies 2-3 stacks of the Festering Wound Icon Festering Wound debuff, which caps at 6 stacks. Do not use Festering Strike if you are at maximum stacks, and ideally avoid wasting any potential stacks unless Apocalypse Icon Apocalypse is available or will be available shortly (so try not to cast it when you have 4 or more stacks).
    if S.FesteringStrike:IsReady()
      and target_range("Melee")
      and Target:DebuffStack(S.FesteringWound) < 4 then

      return "festering_strike [4e33465d-df62-4100-9961-f1d7cec16529]"
    end

    -- ADDED SELF Try to proc Runic Corruption
    if talent_enabled("Epidemic")
      and S.Epidemic:IsReady()
      and target_range(10)
      and enemy_count(10) >= 2
      and Player:RunicPower() >= 30 
      and Target:DebuffRemains(S.VirulentPlagueDebuff) > 0
      and not Player:Buff(S.RunicCorruption) then

      return "epidemic [0503b99a-e2e2-4112-9d8c-ee3431206e28]"
    end

    if S.DeathCoil:IsReady()
      and target_range(30)
      and Player:RunicPower() >= 40 
      and not Player:Buff(S.RunicCorruption) then

      return "death_coil [d3006e18-5099-440e-ab2a-6dc5b9eabd27]"
    end

    if S.DeathStrike:IsReady()
      and target_range("Melee")
      and Player:HealthPercentage() < 80
      and (alone() or Player:HealthPercentage() < 35)
      and Player:Buff(S.DarkSuccor) then

      return "death_strike [eb8505cf-e184-432d-95b2-fb6ffcd47774]"
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