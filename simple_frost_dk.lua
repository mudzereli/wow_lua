--- ========== TODO ==========

  -- change is_boss ignore range checks to list of "big mobs" by name?
  -- interrupt at END of most casts -- exception lists for some?
  -- startattack in rotation 

--- ========== HEADER ==========
  
  local FILE_VERSION = 20190205-2

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
      DarkSuccor                    = Spell(101568),
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
    return ((Settings.General.SoloMode and Player:HealthPercentage() < Settings.DeathKnight.Commons.UseDeathStrikeHP)
      or (Player:Buff(S.DarkSuccor) and Player:HealthPercentage() < 75))
      and alone()
  end

--- ========== SIMCRAFT PRIORITY LIST ==========

-- x actions=auto_attack
-- * actions+=/variable,name=use_cooldowns,value=1
-- * actions+=/variable,name=use_aoe,value=1
-- * actions+=/variable,name=bos_ticking,value=dot.breath_of_sindragosa.ticking
-- * actions+=/variable,name=bos_pooling,value=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5&variable.use_cooldowns&!variable.bos_ticking
-- * actions+=/pillar_of_frost,if=cooldown.empower_rune_weapon.remains>0|!variable.use_cooldowns
-- x actions+=/frostwyrms_fury,if=variable.use_cooldowns&buff.pillar_of_frost.up&buff.pillar_of_frost.remains<=4
-- * actions+=/empower_rune_weapon,if=variable.use_cooldowns&(target.time_to_die<20|(rune>=3&runic_power>=60))&cooldown.breath_of_sindragosa.up
-- * actions+=/breath_of_sindragosa,if=variable.use_cooldowns&(target.time_to_die<cooldown.empower_rune_weapon.remains|buff.empower_rune_weapon.up)
-- * actions+=/chains_of_ice,if=buff.cold_heart.stack>=20
-- * actions+=/howling_blast,if=buff.rime.up
-- * actions+=/obliterate,if=variable.bos_ticking&runic_power<=30
-- * actions+=/frost_strike,if=!variable.bos_ticking&(runic_power>=110|(!variable.use_cooldowns&runic_power.deficit<=25))
-- * actions+=/howling_blast,if=!dot.frost_fever.ticking&variable.use_aoe
-- * actions+=/chains_of_ice,if=!variable.bos_ticking&(target.time_to_die<3|buff.cold_heart.stack>=15)
-- * actions+=/obliterate,if=variable.bos_ticking&runic_power.deficit>=25
-- * actions+=/obliterate,if=variable.bos_pooling&(rune>=3|runic_power.deficit>=25)
-- * actions+=/obliterate,if=!variable.bos_ticking&!variable.bos_pooling
-- * actions+=/remorseless_winter,if=!variable.bos_pooling&variable.use_aoe
-- * actions+=/frost_strike,if=!variable.bos_ticking&!variable.bos_pooling

--- ========== CONVERTED ACTION LIST ==========

  function FrostDK_APL()
    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not DeathKnight) or (not Settings.DeathKnight) then
      Initialize()
      return nil
    end

    -- variable,name=use_cooldowns,value=1
    local use_cooldowns = HR.CDsON()

    -- variable,name=use_aoe,value=1
    local use_aoe = HR.AoEON()

    -- variable,name=bos_ticking,value=dot.breath_of_sindragosa.ticking
    local bos_ticking = Player:Buff(S.BreathofSindragosa)

    -- variable,name=bos_pooling,value=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5&variable.use_cooldowns&!variable.bos_ticking
    local bos_pooling = talent_enabled("Breath of Sindragosa") and S.BreathofSindragosa:CooldownRemains() < 5 and use_cooldowns and not bos_ticking

    -- Unit Updates
    HL.GetEnemies("Melee")
    Everyone.AoEToggleEnemiesUpdate()

    -- death_strike
    -- ff10ee71-e294-46c0-8c39-f5212edb6ea7
    if Everyone.TargetIsValid() and ShouldDeathStrike() and S.DeathStrike:IsReady() then
        return "death_strike [ff10ee71-e294-46c0-8c39-f5212edb6ea7]"
    end

    -- pillar_of_frost,if=pillar_of_frost,if=cooldown.empower_rune_weapon.remains>0|!variable.use_cooldowns
    -- 2e7b5ff3-a86d-4864-9b88-a0ca1fe69882
    -- added extra code to handle CD variables
    if S.PillarOfFrost:IsCastable() 
      and target_range("Melee")
      --and (S.EmpowerRuneWeapon:CooldownDown() or ((not use_cooldowns) and S.BreathofSindragosa:CooldownRemains() >= 15)) then
      and (S.EmpowerRuneWeapon:CooldownDown() or (not use_cooldowns)) then

      return "pillar_of_frost [2e7b5ff3-a86d-4864-9b88-a0ca1fe69882]"
    end

    -- frostwyrms_fury,if=variable.use_cooldowns&buff.pillar_of_frost.up&buff.pillar_of_frost.remains<=4
    -- 2a41ac90-7c23-4afc-8fb3-3b908ac14190
    -- if S.FrostwyrmsFury:IsCastable()
    --   and HR.CDsON()
    --   and Player:Buff(S.PillarOfFrost)
    --   and Player:BuffRemains(S.PillarOfFrost) <= 4 then

    --   return "frostwyrms_fury [2a41ac90-7c23-4afc-8fb3-3b908ac14190]"
    -- end

    -- actions+=/empower_rune_weapon,if=variable.use_cooldowns&(target.time_to_die<20|(rune>=3&runic_power>=60))&cooldown.breath_of_sindragosa.up
    -- b0a97ff0-e8b2-4715-a16e-7b2392933228
    if S.EmpowerRuneWeapon:IsCastable()
      and Everyone.TargetIsValid()
      and Target:IsInRange(15)
      and use_cooldowns
      and S.BreathofSindragosa:CooldownRemains() == 0
      and ((is_boss("target") and Target:FilteredTimeToDie("<",20))
        or (Player:Rune() >= 3 and Player:RunicPower() > 60)) then

      return "empower_rune_weapon [b0a97ff0-e8b2-4715-a16e-7b2392933228]"
    end

    -- breath_of_sindragosa,if=variable.use_cooldowns&(target.time_to_die<cooldown.empower_rune_weapon.remains|buff.empower_rune_weapon.up)
    -- fb3a9ecf-d010-4885-9f72-6f8db764e83b
    if S.BreathofSindragosa:IsCastable() 
      and Everyone.TargetIsValid()
      and Target:IsInRange(15)
      and use_cooldowns
      and ((is_boss("target") and Target:FilteredTimeToDie("<",S.EmpowerRuneWeapon:CooldownRemains()))
        or Player:Buff(S.EmpowerRuneWeapon)) then

      return "breath_of_sindragosa [fb3a9ecf-d010-4885-9f72-6f8db764e83b]"
    end

    -- chains_of_ice,if=buff.cold_heart.stack>=20
    -- 98cf8a0a-225e-4eb7-aa32-7636a1ce2a6f
    if S.ChainsOfIce:IsReady(30) 
      and Everyone.TargetIsValid()
      and Player:BuffStack(S.ColdHeartBuff) >= 20 then

      return "chains_of_ice [98cf8a0a-225e-4eb7-aa32-7636a1ce2a6f]"
    end    

    -- howling_blast,if=buff.rime.up
    -- 8da88256-bedd-409b-87dc-5f27b05220fa
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and Player:Buff(S.Rime) then

      return "howling_blast [8da88256-bedd-409b-87dc-5f27b05220fa]"
    end

    -- obliterate,if=variable.bos_ticking&runic_power<=30
    -- aa354962-0e9b-4dd5-be84-f296d214da2e
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and (bos_ticking
        or Player:RunicPower() <= 30) then

      return "obliterate [aa354962-0e9b-4dd5-be84-f296d214da2e]"
    end

    -- frost_strike,if=!variable.bos_ticking&(runic_power>=110|(!variable.use_cooldowns&runic_power.deficit<=25))
    -- 2d3a06a3-0e05-4cd9-a9c1-b31cf70b4c06
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and not ShouldDeathStrike()
      and not bos_ticking
      and (Player:RunicPower() >= 110
        or (not use_cooldowns and Player:RunicPowerDeficit() <= 25)) then

      return "frost_strike [2d3a06a3-0e05-4cd9-a9c1-b31cf70b4c06]"
    end

    -- howling_blast,if=!dot.frost_fever.ticking&variable.use_aoe
    -- d041b15d-cae4-4c21-a394-d82b046d2bba
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and not Target:Debuff(S.FrostFever)
      and use_aoe then

      return "howling_blast [d041b15d-cae4-4c21-a394-d82b046d2bba]"
    end

    -- chains_of_ice,if=!variable.bos_ticking&(target.time_to_die<3|buff.cold_heart.stack>=15)
    -- 136ab978-d120-4a4a-a8a8-49180174ee69
    if S.ChainsOfIce:IsReady(30) 
      and Everyone.TargetIsValid()
      and not bos_ticking
      and ((is_boss("target") and Target:FilteredTimeToDie("<",3))
        or Player:BuffStack(S.ColdHeartBuff) >= 15) then

      return "chains_of_ice [136ab978-d120-4a4a-a8a8-49180174ee69]"
    end    

    -- obliterate,if=variable.bos_ticking&runic_power.deficit>=25
    -- 1db94ef8-a6c5-4beb-a33d-6cf5d1c50777
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and bos_ticking
      and Player:RunicPowerDeficit() >= 25 then

      return "obliterate [1db94ef8-a6c5-4beb-a33d-6cf5d1c50777]"
    end

    -- obliterate,if=variable.bos_pooling&(rune>=3|runic_power.deficit>=25)
    -- b61f1384-669f-4f0c-b395-9da06f269468
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and bos_pooling
      and (Player:Rune()>=3
        or Player:RunicPowerDeficit() >= 25) then

      return "obliterate [b61f1384-669f-4f0c-b395-9da06f269468]"
    end

    -- obliterate,if=!variable.bos_ticking&!variable.bos_pooling
    -- 5ef0f08c-f9de-4d33-b693-3adff75a18a5
    if S.Obliterate:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and not bos_ticking
      and not bos_pooling then

      return "obliterate [5ef0f08c-f9de-4d33-b693-3adff75a18a5]"
    end

    -- remorseless_winter,if=!variable.bos_pooling&variable.use_aoe
    -- 40dd79f0-f639-4512-a3e7-3c1a11f4c7f8
    if S.RemorselessWinter:IsCastable()
      and not bos_pooling 
      and use_aoe then

      return "remorseless_winter [40dd79f0-f639-4512-a3e7-3c1a11f4c7f8]"
    end

    -- frost_strike,if=!variable.bos_ticking&!variable.bos_pooling
    -- d3b290d0-2833-4aef-a77e-7db705dcd758
    if S.FrostStrike:IsReady()
      and (Target:IsInRange("Melee") or is_boss("target")) 
      and Everyone.TargetIsValid()
      and not ShouldDeathStrike()
      and not bos_ticking
      and not bos_pooling then

      return "frost_strike [d3b290d0-2833-4aef-a77e-7db705dcd758]"
    end

    return "pool"
  end

  function target_range(distance)
    return Everyone.TargetIsValid() and (Target:IsInRange(distance) or (is_boss("target") and Target:IsInRange(20)))
  end
--- ========== END OF FILE ==========