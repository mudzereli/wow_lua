--- ========== HEADER ==========

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
    };
    S = Spell.DeathKnight.Blood;

    -- Items
    if not Item.DeathKnight then Item.DeathKnight = {}; end
    Item.DeathKnight.Blood = {
      BattlePotionOfStrength = Item(163224)
    };
    I = Item.DeathKnight.Blood;

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
  -- - actions.standard+=/marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
  -- - actions.standard+=/bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
  -- - actions.standard+=/death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.time_to_die<10
  -- - actions.standard+=/death_and_decay,if=spell_targets.death_and_decay>=3
  -- - actions.standard+=/rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
  -- - actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
  -- - actions.standard+=/blood_boil,if=buff.dancing_rune_weapon.up
  -- - actions.standard+=/death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
  -- - actions.standard+=/consumption
  -- - actions.standard+=/blood_boil
  -- - actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
  -- - actions.standard+=/rune_strike
  -- x actions.standard+=/arcane_torrent,if=runic_power.deficit>20

--- ========== CONVERTED ACTION LIST ==========

  function BloodDK_APL()
    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not DeathKnight) or (not Settings.DeathKnight) then
      Initialize()
      return nil
    end

    -- Unit Update
    HL.GetEnemies("Melee");
    HL.GetEnemies(8, true); -- Death and Decay & Bonestorm
    HL.GetEnemies(10, true); -- Blood Boil
    HL.GetEnemies(20, true);

    -- In Combat
    if Everyone.TargetIsValid() then
      -- Units without Blood Plague
      local UnitsWithoutBloodPlague = 0;
      for _, CycleUnit in pairs(Cache.Enemies[10]) do
        if not CycleUnit:Debuff(S.BloodPlague) then
          UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1;
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

      -- death_strike,if=runic_power.deficit<=10
      -- 140c0716-6144-49b7-a5d5-65ddc00790eb
      if S.DeathStrike:IsReady("Melee") 
        and Player:RunicPowerDeficit() <= 10 then

        return "death_strike [140c0716-6144-49b7-a5d5-65ddc00790eb]"
      end

      -- blooddrinker,if=!buff.dancing_rune_weapon.up
      -- 4f178a0d-3f68-42ae-9a13-630d3e5984a3
      if talent_enabled("Blooddrinker")
        and S.Blooddrinker:IsCastable(30) 
        and (not Player:ShouldStopCasting()) 
        and (not Player:Buff(S.DancingRuneWeaponBuff)) then

        return "blooddrinker [4f178a0d-3f68-42ae-9a13-630d3e5984a3]"
      end

      -- marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
      -- 3c4db0ed-3b11-46f4-be6b-5404d29e94f7
      if S.Marrowrend:IsCastable("Melee") 
        and Player:RunicPowerDeficit() >= 20
        and (Player:BuffRemainsP(S.BoneShield) <= Player:RuneTimeToX(3)
          or Player:BuffRemainsP(S.BoneShield) <= (Player:GCD() + binarize(S.Blooddrinker:CooldownUp())*binarize(talent_enabled("Blooddrinker"))*2)
          or Player:BuffStack(S.BoneShield) < 3) then

        return "marrowrend [3c4db0ed-3b11-46f4-be6b-5404d29e94f7]"
      end

      -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
      -- b5ba1f3e-e83b-440d-ade0-8d6558779b0d
      if S.BloodBoil:IsCastableP() 
        and S.BloodBoil:Charges() >= 2
        and (Player:BuffStack(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[10])
          or Cache.EnemiesCount[10] > 2) then

        return "blood_boil [b5ba1f3e-e83b-440d-ade0-8d6558779b0d]"
      end
    end
  end

--- ========== END OF FILE ==========