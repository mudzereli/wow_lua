--- ========== TODO ==========

  -- finish rotation
  -- use In Range OR BOSS logic to fix range issues w/ bosses

--- ========== HEADER ==========

  local FILE_VERSION = 20180919-1

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

--- ========== SIMCRAFT PRIORITY LIST ==========

  -- # # Executed every time the actor is available.
  -- x actions=auto_attack
  -- x actions+=/variable,name=pooling_for_gargoyle,value=cooldown.summon_gargoyle.remains<5&talent.summon_gargoyle.enabled
  -- # # Racials, Items, and other ogcds
  -- x actions+=/arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
  -- x actions+=/blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  -- x actions+=/berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  -- # # Custom trinkets usage
  -- x actions+=/use_items
  -- x actions+=/use_item,name=bygone_bee_almanac,if=cooldown.summon_gargoyle.remains>60|!talent.summon_gargoyle.enabled
  -- x actions+=/use_item,name=jes_howler,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  -- x actions+=/use_item,name=galecallers_beak,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  -- x actions+=/potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
  -- # # Maintain Virulent Plague
  -- * actions+=/outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
  -- * actions+=/call_action_list,name=cooldowns
  -- * actions+=/run_action_list,name=aoe,if=active_enemies>=2
  -- * actions+=/call_action_list,name=generic

  -- # # AoE rotation
  -- * actions.aoe=death_and_decay,if=cooldown.apocalypse.remains
  -- * actions.aoe+=/defile
  -- * actions.aoe+=/epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
  -- * actions.aoe+=/death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
  -- - actions.aoe+=/scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
  -- - actions.aoe+=/clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
  -- - actions.aoe+=/epidemic,if=!variable.pooling_for_gargoyle
  -- - actions.aoe+=/festering_strike,target_if=debuff.festering_wound.stack<=1&cooldown.death_and_decay.remains
  -- - actions.aoe+=/festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
  -- - actions.aoe+=/death_coil,if=buff.sudden_doom.react&rune.deficit>=4
  -- - actions.aoe+=/death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
  -- - actions.aoe+=/death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
  -- - actions.aoe+=/scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
  -- - actions.aoe+=/clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
  -- - actions.aoe+=/death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
  -- - actions.aoe+=/festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
  -- - actions.aoe+=/death_coil,if=!variable.pooling_for_gargoyle

  -- * actions.cooldowns=army_of_the_dead
  -- * actions.cooldowns+=/apocalypse,if=debuff.festering_wound.stack>=4
  -- * actions.cooldowns+=/dark_transformation
  -- * actions.cooldowns+=/summon_gargoyle,if=runic_power.deficit<14
  -- * actions.cooldowns+=/unholy_frenzy,if=debuff.festering_wound.stack<4
  -- * actions.cooldowns+=/unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
  -- * actions.cooldowns+=/soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
  -- * actions.cooldowns+=/unholy_blight

  -- - actions.generic=death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
  -- - actions.generic+=/death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
  -- - actions.generic+=/death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
  -- - actions.generic+=/defile,if=cooldown.apocalypse.remains
  -- - actions.generic+=/scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
  -- - actions.generic+=/clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
  -- - actions.generic+=/death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
  -- - actions.generic+=/festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
  -- - actions.generic+=/death_coil,if=!variable.pooling_for_gargoyle

--- ========== CONVERTED ACTION LIST ==========
  function simc_cooldowns()
    
    -- army_of_the_dead
    -- e6660f16-14ba-4d7e-aa39-7c140355c2b4
    if HR.CDsON()
      and S.ArmyOfTheDead:IsReady()
      and is_boss("target") then

      return "army_of_the_dead [e6660f16-14ba-4d7e-aa39-7c140355c2b4]"
    end

    -- apocalypse,if=debuff.festering_wound.stack>=4
    -- b99a2804-99c2-49d0-adcd-5976bc4e0da5
    if HR.CDsON()
        and S.Apocalypse:IsReady("Melee") 
        and Target:DebuffStack(S.FesteringWound) >= 4 then
      
      return "apocalypse [b99a2804-99c2-49d0-adcd-5976bc4e0da5]"
    end

    -- dark_transformation
    -- 27340745-059c-4c3e-97b8-1ed2dc6a0dc7
    if S.DarkTransformation:IsReady() 
      and (Target:FilteredTimeToDie(">",8)
        or Cache.EnemiesCount[10] >= 3
        or is_boss("target")) then

      return "dark_transformation [27340745-059c-4c3e-97b8-1ed2dc6a0dc7]"
    end

    -- summon_gargoyle,if=runic_power.deficit<14
    -- fbf25a59-fa29-4b0b-99f1-05cba77b3767
    if HR.CDsON()
      and talent_enabled("Summon Gargoyle")
      and S.SummonGargoyle:IsReady(30)
      and Player:RunicPowerDeficit() < 14
      and (Target:FilteredTimeToDie(">",15)
        or Cache.EnemiesCount[10] >= 3
        or is_boss("target")) then

      return "summon_gargoyle [fbf25a59-fa29-4b0b-99f1-05cba77b3767]"
    end

    -- unholy_frenzy,if=debuff.festering_wound.stack<4
    -- 54d5dd3d-1e86-4f71-8c86-fde4acd29410
    if HR.CDsON()
      and talent_enabled("Unholy Frenzy")
      and S.UnholyFrenzy:IsReady()
      and Target:Debuffstack(S.FesteringWound) < 4 then

      return "unholy_frenzy [54d5dd3d-1e86-4f71-8c86-fde4acd29410]"
    end

    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    -- ddb5edbd-e36b-4183-a26e-d35af9b1b016
    if HR.CDsON()
      and talent_enabled("Unholy Frenzy")
      and S.UnholyFrenzy:IsReady()
      and Cache.EnemiesCount[8] >= 2
      and (((not talent_enabled("Defile"))
        and S.DeathAndDecay:CooldownRemains() <= Player:GCD())
          or (talent_enabled("Defile")
            and S.Defile:CooldownRemains() <= Player:GCD())) then

      return "unholy_frenzy [ddb5edbd-e36b-4183-a26e-d35af9b1b016]"
    end

    -- soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
    -- a76c1952-8a73-4397-941f-0d6781f62617
    if talent_enabled("Soul Reaper")
      and S.SoulReaper:IsReady("Melee")
      and (not Player:Buff(S.UnholyFrenzy))
      and (Target:FilteredTimeToDie("<",8)
        or Player:Runes() <= 2) then

      return "soul_reaper [a76c1952-8a73-4397-941f-0d6781f62617]"
    end

    -- unholy_blight
    -- 73c5dfd9-84ca-455f-b8ae-9f5f579c5df0
    if talent_enabled("Unholy Blight")
      and S.UnholyBlight:IsReady()
      and (Target:IsInRange(8))
      and (Target:FilteredTimeToDie(">",8)
        or Cache.EnemiesCount[10] >= 3
        or is_boss("target")) then

      return "unholy_blight [73c5dfd9-84ca-455f-b8ae-9f5f579c5df0]"
    end

    return false
  end

  function simc_aoe()
    local pooling_for_gargoyle = (talent_enabled("Summon Gargoyle") and S.SummonGargoyle:CooldownRemains() < 5)

    -- death_and_decay,if=cooldown.apocalypse.remains
    -- e784331f-5e03-4790-9fb0-fab01229f545
    if S.DeathAndDecay.IsReady()
      and Cache.EnemiesCount[8] >= 2
      and (S.Apocalypse:CooldownRemains() > 0 or (not HR.CDsON())) then -- added logic for turning off CDs

      return "death_and_decay [e784331f-5e03-4790-9fb0-fab01229f545]"
    end

    -- defile
    -- dbb11eb5-ef29-4a68-9156-541be715e4ac
    if S.DeathAndDecay.IsReady()
      and Cache.EnemiesCount[8] >= 2 then

      return "defile [dbb11eb5-ef29-4a68-9156-541be715e4ac]"
    end

    -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    -- TODO: find better way to check if DND is ticking
    -- 0503b99a-e2e2-4112-9d8c-ee3431206e28
    if talent_enabled("Epidemic")
      and S.DeathAndDecay:CooldownRemains() >= 20
      and Player:Runes() < 2
      and not pooling_for_gargoyle then

      return "epidemic [0503b99a-e2e2-4112-9d8c-ee3431206e28]"
    end

    -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    -- TODO: find better way to check if DND is ticking
    -- a59f3a03-1c76-471a-b4e6-51387fcf1731
    if S.DeathCoil:IsReady(30)
      and S.DeathAndDecay:CooldownRemains() >= 20
      and Player:Runes() < 2
      and not pooling_for_gargoyle then

      return "death_coil [a59f3a03-1c76-471a-b4e6-51387fcf1731]"
    end

    return false
  end

  function simc_generic()
    return false
  end

  function UnholyDK_APL()
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

    -- In Combat
    if Everyone.TargetIsValid() then

      -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
      -- 1f1b36ae-40a3-4db5-9a1d-4c5d1548b927
      if S.Outbreak:IsReady(30)
        and Target:DebuffRemains(S.VirulentPlagueDebuff) <= Player:GCD() then 

        return "outbreak [1f1b36ae-40a3-4db5-9a1d-4c5d1548b927]"
      end

      -- call_action_list,name=cooldowns
      ShouldReturn = simc_cooldowns()
      if ShouldReturn then return ShouldReturn end
      
      -- run_action_list,name=aoe,if=active_enemies>=2
      if Cache.EnemiesCount[10] >= 2 then
        ShouldReturn = simc_aoe()
        if ShouldReturn then return ShouldReturn end
      end

      ShouldReturn = simc_generic()
      if ShouldReturn then return ShouldReturn end

      return "pool"
    end
  end

--- ========== END OF FILE ==========