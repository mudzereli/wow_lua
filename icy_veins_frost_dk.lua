--- ========== TODO ==========

  -- Frostscythe usage wtih BOS_POOLING and BOS_TICKING

--- ========== HEADER ==========
  
  local FILE_VERSION = 20190214-1

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
    local bos_pooling = talent_enabled("Breath of Sindragosa") and S.BreathofSindragosa:CooldownRemains() < 5 and use_cooldowns and (not bos_ticking) and S.PillarOfFrost:CooldownRemains() < 7

    -- Unit Updates
    HL.GetEnemies("Melee")
    HL.GetEnemies(8,true)
    HL.GetEnemies(10,true)
    HL.GetEnemies(20,true)
    HL.GetEnemies(30,true)
    Everyone.AoEToggleEnemiesUpdate()

    -- death_strike
    -- ff10ee71-e294-46c0-8c39-f5212edb6ea7
    if Everyone.TargetIsValid() and ShouldDeathStrike() and S.DeathStrike:IsReady() then
        return "death_strike [ff10ee71-e294-46c0-8c39-f5212edb6ea7]"
    end

    --  howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsReady(30)
      and Everyone.TargetIsValid()
      and (not Target:Debuff(S.FrostFever))
      and ((not talent_enabled("Breath of Sindragosa")) or S.BreathofSindragosa:CooldownRemains() > 15) then

      return "howling_blast [328988d7-7369-48df-9692-c46fa06c86ad]"
    end

    -- Use Remorseless Winter Icon Remorseless Winter if using Gathering Storm Icon Gathering Storm, also try to use this before casting Pillar of Frost Icon Pillar of Frost.
    if S.RemorselessWinter:IsCastable() 
      and target_range(8)
      and talent_enabled("Obliteration")
      and talent_enabled("Gathering Storm") then

      return "remorseless_winter [398a54ec-89c2-409d-bc3e-d4e1e74487fb]"
    end

    -- Pillar of Frost
    if S.PillarOfFrost:IsCastable() 
      and target_range("Melee")
      and (S.EmpowerRuneWeapon:CooldownDown() or S.BreathofSindragosa:CooldownRemains() > 15 or talent_enabled("Obliteration")) then

      return "pillar_of_frost [2e7b5ff3-a86d-4864-9b88-a0ca1fe69882]"
    end

    -- Empower Rune Weapon
    if S.EmpowerRuneWeapon:IsCastable()
      and target_range(15)
      and use_cooldowns
      and ((S.PillarOfFrost:CooldownRemains() == 0
          and S.BreathofSindragosa:CooldownRemains() == 0
          and Player:Rune() >= 3 and Player:RunicPower() >= 60) 
        or (Player:BuffRemains(S.PillarOfFrost) > 15
          and talent_enabled("Obliteration"))) then

      return "empower_rune_weapon [b0a97ff0-e8b2-4715-a16e-7b2392933228]"
    end

    -- Breath of Sindragosa
    if S.BreathofSindragosa:IsCastable() 
      and target_range(15)
      and use_cooldowns
      and Player:Buff(S.EmpowerRuneWeapon) then

      return "breath_of_sindragosa [fb3a9ecf-d010-4885-9f72-6f8db764e83b]"
    end

    -- Use Chains of Ice Icon Chains of Ice, if you have 20 stacks (try to use at the end of Pillar of Frost Icon Pillar of Frost when the strength bonus is at the highest).
    if S.ChainsOfIce:IsReady(30) 
      and Everyone.TargetIsValid()
      and Player:BuffStack(S.ColdHeartBuff) >= 20
      --and (not Player:Buff(S.PillarOfFrost))
      and (not bos_pooling)
      and Target:DebuffStack(S.RazorIce) >= 5 then

      return "chains_of_ice [98cf8a0a-225e-4eb7-aa32-7636a1ce2a6f]"
    end
      
    if S.ChainsOfIce:IsReady(30) 
      and Everyone.TargetIsValid()
      and Player:BuffStack(S.ColdHeartBuff) >= 10
      and (not bos_pooling)
      and strength() > 9000
      and Target:DebuffStack(S.RazorIce) >= 5 then

      return "chains_of_ice [3058994c-265d-4731-adbb-33db0333db84]"
    end

    if bos_pooling then
      -- Use Obliterate Icon Obliterate (use Howling Blast Icon Howling Blast if you get a Rime Icon Rime proc).
      if S.HowlingBlast:IsReady(30)
        and Everyone.TargetIsValid()
        and Player:Buff(S.Rime) then

        return "howling_blast [d78edd13-d1c3-4c11-a10f-6e1298902e57]"
      end

      -- Use Obliterate Icon Obliterate (use Howling Blast Icon Howling Blast if you get a Rime Icon Rime proc).
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and Player:RunicPower() < 60 then

        return "obliterate [fd34d497-e125-45e4-afad-0e8d4e303157]"
      end
    elseif bos_ticking then
      --  obliterate,if=runic_power<=30
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and Player:RunicPower() <= 30 then

        return "obliterate [e15e2173-fe22-4d4a-b64e-45e9b6f7734e]"
      end

      -- Use Howling Blast Icon Howling Blast, only if you have a Rime Icon Rime proc or Frost Fever Icon Frost Fever is about to drop.
      if S.HowlingBlast:IsReady(30)
        and Everyone.TargetIsValid()
        and (Player:Buff(S.Rime)
          or (not Target:Debuff(S.FrostFever))
          or Target:DebuffRemains(S.FrostFever) < 3) then

        return "howling_blast [82b1d045-8eeb-438c-85e7-fbcf72ecbb3a]"
      end

      -- Use Remorseless Winter Icon Remorseless Winter on cooldown (for Gathering Storm Icon Gathering Storm, if you have taken this talent).
      if S.RemorselessWinter:IsCastable()
          and target_range(8) then
          -- and talent_enabled("Gathering Storm") then

        return "remorseless_winter [a27486c7-367a-4150-8325-0ef139c453a5]"
      end

      -- Use Obliterate Icon Obliterate with a Killing Machine Icon Killing Machine proc.
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and Player:Buff(S.KillingMachine) then

        return "obliterate [c6117762-1fdf-4ea6-a1b7-aa609f74ca93]"
      end
  
      -- Use Obliterate Icon Obliterate.
      -- obliterate,if=runic_power.deficit>25|rune>3
      -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and (Player:RunicPowerDeficit() > 25
          or Player:Rune() > 3
          or Target:DebuffRemains(S.RazorIce) < 10
          or Target:DebuffStack(S.RazorIce) < 5) then

        return "obliterate [22146275-1db7-4aed-9192-8cc0c3e3a0aa]"
      end

      -- Use Horn of Winter Icon Horn of Winter, if you are using this talent and are low on both resources.
      if talent_enabled("Horn of Winter") 
        and S.HornOfWinter:IsReady() then

          return "horn_of_winter [935f5ff3-099a-4d55-8115-a3cdd3c3362d]"
      end

      -- Use Arcane Torrent Icon Arcane Torrent if you are a Blood Elf.
    elseif talent_enabled("Obliteration") and Player:Buff(S.PillarOfFrost) then
      -- Use Remorseless Winter Icon Remorseless Winter if using Gathering Storm Icon Gathering Storm, also try to use this before casting Pillar of Frost Icon Pillar of Frost.
      if S.RemorselessWinter:IsCastable()
          and target_range(8)
          and talent_enabled("Gathering Storm")
          and not Player:Buff(S.PillarOfFrost) then

        return "remorseless_winter [10fcac9d-0552-46ea-9ef0-6549ab76def3]"
      end

      -- Use Frostscythe Icon Frostscythe, if you have a Killing Machine Icon Killing Machine proc.
      if talent_enabled("Frostscythe")
        and S.FrostScythe:IsReady()
        and target_range(8)
        and (use_aoe and Cache.EnemiesCount[10] >= 2)
        and Player:Buff(S.KillingMachine) then

        return "frostscythe [770e79ff-059b-4d98-801a-55aeb90cfc45]"
      end

      -- Use Obliterate Icon Obliterate if you have a Killing Machine Icon Killing Machine proc.
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and not (talent_enabled("Frostscythe") and use_aoe and Cache.EnemiesCount[10] >= 2)
        and Player:Buff(S.KillingMachine) then

        return "obliterate [dce9d422-3c82-41bc-b28c-2fb28282778a]"
      end

      -- Use Frost Strike Icon Frost Strike if you do not have a Rime Icon Rime proc or if you are going to cap Runic Power.
      if S.FrostStrike:IsReady()
        and target_range("Melee")
        and (not ShouldDeathStrike())
        and ((not Player:Buff(S.Rime)) or Player:RunicPower() >= 90) then

        return "frost_strike [76d45ccc-ea26-4d60-9945-d708524f00d2]"
      end

      -- Use Howling Blast Icon Howling Blast if you have a Rime Icon Rime proc or if Frost Fever Icon Frost Fever is about to drop.
      if S.HowlingBlast:IsReady(30)
        and Everyone.TargetIsValid()
        and (Player:Buff(S.Rime)
          or (not Target:Debuff(S.FrostFever))
          or Target:DebuffRemains(S.FrostFever) < 3) then

        return "howling_blast [3a16b3c5-f50e-4d98-aa67-b0234cacfdb9]"
      end

      -- Use Frost Strike Icon Frost Strike if you do not have a Killing Machine Icon Killing Machine proc.
      if S.FrostStrike:IsReady()
        and target_range("Melee")
        and (not ShouldDeathStrike())
        and not Player:Buff(S.KillingMachine) then

        return "frost_strike [135242f6-8490-489d-87a3-017066b39971]"
      end

      -- Use Obliterate Icon Obliterate if you do not have enough Runic Power to use Frost Strike Icon Frost Strike and do not have a Killing Machine Icon Killing Machine proc.
      if S.Obliterate:IsReady()
        and target_range("Melee")
        and not (talent_enabled("Frostscythe") and use_aoe and Cache.EnemiesCount[10] >= 2)
        and Player:RunicPower() < 25
        and not Player:Buff(S.KillingMachine) then

        return "obliterate [b2b78463-6be0-4cae-b210-457fec1d5b0a]"
      end

      if talent_enabled("Frostscythe")
        and S.FrostScythe:IsReady()
        and target_range(8)
        and (use_aoe and Cache.EnemiesCount[10] >= 2)
        and Player:RunicPower() < 25
        and not Player:Buff(S.KillingMachine) then

        return "frostscythe [586fa05e-63e1-43b4-b40a-43ff42fbc270]"
      end
    else
      -- AOE
        if use_aoe and talent_enabled("Frostscythe") and Cache.EnemiesCount[8] >= 2 then

          -- Use Howling Blast Icon Howling Blast, only if you have a Rime Icon Rime proc.
          if S.HowlingBlast:IsReady(30)
            and Everyone.TargetIsValid()
            and Player:Buff(S.Rime) then

            return "howling_blast [72d3e710-6c9a-48c3-9bf6-7738fa559d87]"
          end

          -- Use Frost Strike Icon Frost Strike, if you have 90+ Runic Power.
          if S.FrostStrike:IsReady()
            and target_range("Melee")
            and (not ShouldDeathStrike())
            and Player:RunicPower() >= 90 then

            return "frost_strike [3c7affd5-dce3-4440-b983-10419bfb115c]"
          end

          -- Use Frostscythe Icon Frostscythe, if you have a Killing Machine Icon Killing Machine proc.
          if talent_enabled("Frostscythe")
            and S.FrostScythe:IsReady()
            and target_range(8)
            and Player:Buff(S.KillingMachine) then

            return "frostscythe [20c9d4b5-b7f0-4e6c-bae4-dfb143100157]"
          end

          -- Use Remorseless Winter Icon Remorseless Winter on cooldown.
          if S.RemorselessWinter:IsCastable()
            and target_range(8) then

            return "remorseless_winter [40dd79f0-f639-4512-a3e7-3c1a11f4c7f8]"
          end

          -- Use Frostscythe Icon Frostscythe.
          if talent_enabled("Frostscythe")
            and S.FrostScythe:IsReady()
            and target_range(8) then

            return "frostscythe [20c9d4b5-b7f0-4e6c-bae4-dfb143100157]"
          end

          -- Use Frost Strike Icon Frost Strike, if you have 70+ Runic Power.
          if S.FrostStrike:IsReady()
            and target_range("Melee")
            and (not ShouldDeathStrike())
            and Player:RunicPower() >= 70 then

            return "frost_strike [eb6daa24-483f-4eb4-939c-bab9fe312c84]"
          end

        end

      -- SINGLE TARGET
        -- Use Frostwyrm's Fury Icon Frostwyrm's Fury at the end of Pillar of Frost Icon Pillar of Frost and after Chains of Ice Icon Chains of Ice.

        -- Use Remorseless Winter Icon Remorseless Winter, if using Gathering Storm Icon Gathering Storm.
        if S.RemorselessWinter:IsCastable() 
          and target_range(8) then
          -- Per SIMCRAFT we should use Remorseless Winter even without gathering storm
          -- and talent_enabled("Gathering Storm") then

          return "remorseless_winter [d5373287-0c90-4bbe-8a47-9a77a3efda35]"
        end

        -- Use Howling Blast Icon Howling Blast, only if you have a Rime Icon Rime proc.
        if S.HowlingBlast:IsReady(30)
          and Everyone.TargetIsValid()
          and Player:Buff(S.Rime) then

          return "howling_blast [8da88256-bedd-409b-87dc-5f27b05220fa]"
        end

        -- Use Obliterate Icon Obliterate, if you have 4 or more Runes.
        if S.Obliterate:IsReady()
          and target_range("Melee")
          and Player:Rune() >= 4 then

          return "obliterate [b61f1384-669f-4f0c-b395-9da06f269468]"
        end

        -- Use Frost Strike Icon Frost Strike, if you have 90+ Runic Power.
        if S.FrostStrike:IsReady()
          and target_range("Melee")
          and (not ShouldDeathStrike())
          and Player:RunicPower() >= 90 then

          return "frost_strike [2d3a06a3-0e05-4cd9-a9c1-b31cf70b4c06]"
        end

        -- Use Obliterate Icon Obliterate, if you have a Killing Machine Icon Killing Machine proc.
        if S.Obliterate:IsReady()
          and target_range("Melee")
          and Player:Buff(S.KillingMachine) then

          return "obliterate [2411d6cd-8b10-4e82-b3fb-d53fc82e5df0]"
        end

        -- Use Frost Strike Icon Frost Strike, if you have 70+ Runic Power.
        if S.FrostStrike:IsReady()
          and target_range("Melee")
          and (not ShouldDeathStrike())
          and Player:RunicPower() >= 70 then

          return "frost_strike [e74bb544-1e49-4b02-ba9b-41420b4942b8]"
        end

        -- Use Obliterate Icon Obliterate.
        if S.Obliterate:IsReady()
          and target_range("Melee") then

          return "obliterate [8c1c6b6b-6ca5-4a2e-95e0-009e540e3e05]"
        end

        -- Use Frost Strike Icon Frost Strike.
        if S.FrostStrike:IsReady()
          and target_range("Melee")
          and (not ShouldDeathStrike())
          and Player:RunicPower() >= 25 then

          return "frost_strike [efdfbdb5-80bc-49c8-a936-e5283110b940]"
        end

        -- Use Horn of Winter Icon Horn of Winter, if you are using this talent and are low on both resources.
        if talent_enabled("Horn of Winter") 
          and Everyone.TargetIsValid()
          and S.HornOfWinter:IsReady() then

            return "horn_of_winter [661bf360-06f0-4caf-8832-c661c5710fbc]"
        end
    end

    return "pool"
  end

  function target_range(distance)
    return Everyone.TargetIsValid() and (Target:IsInRange(distance) or (is_boss("target") and Target:IsInRange(20)))
  end
--- ========== END OF FILE ==========