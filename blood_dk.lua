--- ========== TODO ==========

  -- timed based DS heals
  -- auto cd usage for IBF and AMS
  
--- ========== HEADER ==========

  local FILE_VERSION = 20180917-3

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
    Spell.DeathKnight.Blood = {
    -- Racials
      ArcaneTorrent         = Spell(50613),
      Berserking            = Spell(26297),
      BloodFury             = Spell(20572),
      -- Abilities
      BloodBoil             = Spell(50842),
      Blooddrinker          = Spell(206931),
      BloodMirror           = Spell(206977),
      BloodPlague           = Spell(55078),
      BloodShield           = Spell(77535),
      BoneShield            = Spell(195181),
      Bonestorm             = Spell(194844),
      Consumption           = Spell(205223),
      CrimsonScourge        = Spell(81141),
      DancingRuneWeapon     = Spell(49028),
      DancingRuneWeaponBuff = Spell(81256),
      DeathandDecay         = Spell(43265),
      DeathsCaress          = Spell(195292),
      DeathStrike           = Spell(49998),
      HeartBreaker          = Spell(221536),
      HeartStrike           = Spell(206930),
      Marrowrend            = Spell(195182),
      MindFreeze            = Spell(47528),
      Ossuary               = Spell(219786),
      RapidDecomposition    = Spell(194662),
      RuneStrike            = Spell(210764),
      RuneTap               = Spell(194679),
      VampiricBlood         = Spell(55233),
      HemostasisBuff       = Spell(273947),
      -- Misc
      Pool            = Spell(9999000010)
    }
    S = Spell.DeathKnight.Blood

    -- Items
    if not Item.DeathKnight then Item.DeathKnight = {} end
    Item.DeathKnight.Blood = {
      BattlePotionOfStrength = Item(163224)
    }
    I = Item.DeathKnight.Blood

    -- GUI Settings
    if (not Settings) or (not Settings.DeathKnight) then
      Settings = {
        General = HR.GUISettings.General,
        DeathKnight = HR.GUISettings.APL.DeathKnight
      }
    end
  end

--- ========== SIMCRAFT PRIORITY LIST ==========

  -- # # Executed every time the actor is available.
  -- x actions=auto_attack
  -- x actions+=/blood_fury,if=cooldown.dancing_rune_weapon.ready&(!cooldown.blooddrinker.ready|!talent.blooddrinker.enabled)
  -- x actions+=/berserking
  -- x actions+=/use_items,if=cooldown.dancing_rune_weapon.remains>90
  -- x actions+=/use_item,name=razdunks_big_red_button
  -- x actions+=/use_item,name=merekthas_fang
  -- x actions+=/potion,if=buff.dancing_rune_weapon.up
  -- * actions+=/dancing_rune_weapon,if=!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready
  -- x actions+=/tombstone,if=buff.bone_shield.stack>=7
  -- * actions+=/call_action_list,name=standard

  -- * actions.standard=death_strike,if=runic_power.deficit<=10
  -- * actions.standard+=/blooddrinker,if=!buff.dancing_rune_weapon.up
  -- * actions.standard+=/marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
  -- * actions.standard+=/blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
  -- * actions.standard+=/marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
  -- * actions.standard+=/bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
  -- * actions.standard+=/death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.time_to_die<10
  -- * actions.standard+=/death_and_decay,if=spell_targets.death_and_decay>=3
  -- * actions.standard+=/rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
  -- * actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
  -- * actions.standard+=/blood_boil,if=buff.dancing_rune_weapon.up
  -- * actions.standard+=/death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
  -- * actions.standard+=/consumption
  -- * actions.standard+=/blood_boil
  -- * actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
  -- * actions.standard+=/rune_strike
  -- x actions.standard+=/arcane_torrent,if=runic_power.deficit>20

--- ========== CONVERTED ACTION LIST ==========

  function BloodDK_APL()
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

    -- vampiric_blood -- HEALING LOGIC
    -- 1b933d26-06b2-4c22-9994-52ed5f9f58fe
    if S.VampiricBlood:IsReady()
      and Player:HealthPercentage() < 40 then

      return "vampiric_blood [1b933d26-06b2-4c22-9994-52ed5f9f58fe]"
    end

    -- don't interrupt blooddrinkers
    if Player:IsChanneling(S.Blooddrinker) then
      return "pool"
    end

    if not Player:AffectingCombat() then
      -- deaths_caress
      -- 6c485c67-8657-4a12-a363-960c2873e79b
      if Everyone.TargetIsValid() 
        and Target:IsInRange(30) 
        and (not Target:Debuff(S.BloodPlague)) then
          return "deaths_caress [6c485c67-8657-4a12-a363-960c2873e79b]"
      end
      return
    end

    -- In Combat
    if Everyone.TargetIsValid() then
      
      -- Units without Blood Plague
      local UnitsWithoutBloodPlague = 0
      for _, CycleUnit in pairs(Cache.Enemies[10]) do
        if not CycleUnit:Debuff(S.BloodPlague) then
          UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1
        end
      end

      -- dancing_rune_weapon,if=!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready
      -- 90024159-aa6f-41a8-a8cb-5123aee46958
      if HR.CDsON() 
        and S.DancingRuneWeapon:IsReady() 
        and (Cache.EnemiesCount["Melee"] >= 3 or (is_boss("target") and Target:IsInRange(8))) -- ADDED LOGIC
        and ((not talent_enabled("Blooddrinker")) 
          or (not S.Blooddrinker:CooldownUp())) then
        
        return "dancing_rune_weapon [90024159-aa6f-41a8-a8cb-5123aee46958]"
      end


      -- death_strike -- HEALING LOGIC
      -- e8c226f1-97ad-4f27-9849-82454ba6ae1e
      if S.DeathStrike:IsReady("Melee")
        and Player:HealthPercentage() < 85 then

        return "death_strike [e8c226f1-97ad-4f27-9849-82454ba6ae1e]"
      end

      -- death_strike,if=runic_power.deficit<=10
      -- 140c0716-6144-49b7-a5d5-65ddc00790eb
      if S.DeathStrike:IsReady("Melee") 
        and Player:RunicPowerDeficit() <= 10 then

        return "death_strike [140c0716-6144-49b7-a5d5-65ddc00790eb]"
      end

      -- INCREASED PRIORITY OF THIS ACTION BY COPYING BLOOD BOIL LOGIC BELOW BECAUSE OF M+ THREAT ISSUES
      -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
      -- b92a9739-6a4b-4268-9a68-f4aa79dff949
      if S.BloodBoil:IsReady() 
        and S.BloodBoil:Charges() >= 2
        and Cache.EnemiesCount[10] >= 1
        and (Player:BuffStack(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[10])
          or (not Player:Buff(S.HemostasisBuff))
          or Cache.EnemiesCount[10] > 2) then

        return "blood_boil [b92a9739-6a4b-4268-9a68-f4aa79dff949]"
      end

      -- blooddrinker,if=!buff.dancing_rune_weapon.up
      -- 4f178a0d-3f68-42ae-9a13-630d3e5984a3
      if talent_enabled("Blooddrinker")
        and S.Blooddrinker:IsReady(30)
        and (not Player:ShouldStopCasting()) 
        and (not Player:Buff(S.DancingRuneWeaponBuff)) then

        return "blooddrinker [4f178a0d-3f68-42ae-9a13-630d3e5984a3]"
      end

      -- marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
      -- 3c4db0ed-3b11-46f4-be6b-5404d29e94f7
      if S.Marrowrend:IsReady("Melee") 
        and Player:RunicPowerDeficit() >= 20
        and (Player:BuffRemains(S.BoneShield) <= Player:RuneTimeToX(3)
          or Player:BuffRemains(S.BoneShield) <= (Player:GCD() + binarize(S.Blooddrinker:CooldownUp())*binarize(talent_enabled("Blooddrinker"))*2)
          or Player:BuffStack(S.BoneShield) < 3
          or (not Player:Buff(S.BoneShield))) then

        return "marrowrend [3c4db0ed-3b11-46f4-be6b-5404d29e94f7]"
      end

      -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
      -- b5ba1f3e-e83b-440d-ade0-8d6558779b0d
      if S.BloodBoil:IsReady() 
        and S.BloodBoil:Charges() >= 2
        and Cache.EnemiesCount[10] >= 1
        and (Player:BuffStack(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[10])
          or (not Player:Buff(S.HemostasisBuff))
          or Cache.EnemiesCount[10] > 2) then

        return "blood_boil [b5ba1f3e-e83b-440d-ade0-8d6558779b0d]"
      end

      -- marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
      -- 44ae1d6e-c069-44d5-b267-e69541da9907
      if S.Marrowrend:IsReady("Melee") 
        and (Player:BuffStack(S.BoneShield) < 5
          or (not Player:Buff(S.BoneShield)))
        and talent_enabled("Ossuary")
        and Player:RunicPowerDeficit() >= 15 then

        return "marrowrend [44ae1d6e-c069-44d5-b267-e69541da9907]"
      end

      -- bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
      -- f9cd611e-7452-47f4-8853-b31238756a25
      if S.Bonestorm:IsReady("Melee")
        and Target:IsInRange("Melee")
        and Player:RunicPower() >= 100
        and (not Player:Buff(S.DancingRuneWeaponBuff)) then

        return "bonestorm [f9cd611e-7452-47f4-8853-b31238756a25]"
      end

      -- death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.time_to_die<10
      -- 1bf66980-ee7a-446f-998b-d7eb68267723
      if S.DeathStrike:IsReady("Melee")
        and (Player:RunicPowerDeficit() <= (15 + binarize(Player:Buff(S.DancingRuneWeaponBuff)) * 5 + Cache.EnemiesCount["Melee"] * binarize(talent_enabled("Heartbreaker")) * 2)
          or Target:FilteredTimeToDie("<",10)) then

        return "death_strike [1bf66980-ee7a-446f-998b-d7eb68267723]"
      end

      -- death_and_decay,if=spell_targets.death_and_decay>=3
      -- 1b63e20b-b4e1-4cf9-be40-7c33fba79b9b
      if S.DeathandDecay:IsReady()
        and Cache.EnemiesCount[8] >= 3 then

        return "death_and_decay [1b63e20b-b4e1-4cf9-be40-7c33fba79b9b]"
      end

      -- rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
      -- 115c0d62-6550-465b-b550-4fe4d89f6716
      if talent_enabled("Rune Strike")
        and S.RuneStrike:IsReady("Melee")
        and Player:RuneTimeToX(3) >= Player:GCD()
        and (S.RuneStrike:Charges() >= 2
          or Player:Buff(S.DancingRuneWeaponBuff)) then

        return "rune_strike [115c0d62-6550-465b-b550-4fe4d89f6716]"
      end

      -- heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
      -- 4403976f-8c94-4185-a90d-8e65114297e9
      if S.HeartStrike:IsReady("Melee")
        and (Player:Buff(S.DancingRuneWeaponBuff)
          or Player:RuneTimeToX(4) < Player:GCD()) then

        return "heart_strike [4403976f-8c94-4185-a90d-8e65114297e9]"
      end

      -- blood_boil,if=buff.dancing_rune_weapon.up
      -- fbd901af-8ff2-4a30-8fa3-0fa7a0f90a5c
      if S.BloodBoil:IsReady() 
        and Cache.EnemiesCount[10] >= 1
        and Player:Buff(S.DancingRuneWeaponBuff) then

        return "blood_boil [fbd901af-8ff2-4a30-8fa3-0fa7a0f90a5c]"
      end

      -- death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
      -- 4dc1c629-85c9-4e09-8fc2-ff37f4920458
      if S.DeathandDecay:IsReady()
        and (Player:Buff(S.CrimsonScourge)
          or talent_enabled("Rapid Decomposition")
          or Cache.EnemiesCount[8] >= 2) then

        return "death_and_decay [4dc1c629-85c9-4e09-8fc2-ff37f4920458]"
      end

      -- consumption
      -- f4c5dad8-d11d-4add-b531-b8d49352c3e7
      if talent_enabled("Consumption")
        and S.Consumption:IsReady()
        and Target:IsInRange(8) then

        return "consumption [f4c5dad8-d11d-4add-b531-b8d49352c3e7]"
      end

      -- blood_boil
      -- e9dd5ae9-f9c0-4f98-8e35-b1d6f0bb7389
      if S.BloodBoil:IsReady() 
        and Cache.EnemiesCount[10] >= 1 then

        return "blood_boil [e9dd5ae9-f9c0-4f98-8e35-b1d6f0bb7389]"
      end

      -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
      -- 7ae6f6f1-da2a-4260-ad62-5b4637a4748b
      if S.HeartStrike:IsReady("Melee")
        and (Player:RuneTimeToX(3) < Player:GCD()
          or Player:BuffStack(S.BoneShield) > 6) then

        return "heart_strike [7ae6f6f1-da2a-4260-ad62-5b4637a4748b]"
      end

      -- rune_strike
      -- a3c3943e-9fc5-4aa3-9a8c-a508106c1fe2
      if talent_enabled("Rune Strike")
        and S.RuneStrike:IsReady("Melee") then

        return "rune_strike [a3c3943e-9fc5-4aa3-9a8c-a508106c1fe2]"
      end
      
    end
  end

--- ========== END OF FILE ==========