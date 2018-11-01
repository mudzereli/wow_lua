--- ========== TODO ==========

  -- better / auto cd handling?
  -- change is_boss ignore range checks to list of "big mobs" by name?
  -- add back in toggles for AOE
  -- interrupt at END of most casts -- exception lists for some?

--- ========== HEADER ==========
  
  local FILE_VERSION = 20181029-3

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
      -- Abilities
      CloakOfShadows              = Spell(31224)
      CrimsonVial                 = Spell(185311),
      Envenom                     = Spell(32645),
      Evasion                     = Spell(5277),
      FanOfKnives                 = Spell(51723),
      Feint                       = Spell(1966),
      Garrote                     = Spell(703),
      Kick                        = Spell(1766),
      Mutilate                    = Spell(1329),
      PoisonedKnife               = Spell(185565),
      DeadlyPoison                = Spell(2823),
      WoundPoison                 = Spell(8679),
      CripplingPoison             = Spell(3408),
      Rupture                     = Spell(1943),
      ShadowStep                  = Spell(36554),
      Sprint                      = Spell(2983),
      Stealth                     = Spell(115191),
      ToxicBlade                  = Spell(245388),
      Vanish                      = Spell(1856),
      Vendetta                    = Spell(79140),
      -- Misc
      PoolRange                   = Spell(9999000010)
      -- Macros
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

-- x actions=auto_attack
-- * actions+=/variable,name=use_cooldowns,value=1
-- * actions+=/variable,name=bos_ticking,value=dot.breath_of_sindragosa.ticking
-- * actions+=/variable,name=bos_pooling,value=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5&variable.use_cooldowns&!variable.bos_ticking
-- * actions+=/pillar_of_frost,if=cooldown.empower_rune_weapon.remains>0|!variable.use_cooldowns
-- x actions+=/frostwyrms_fury,if=variable.use_cooldowns&buff.pillar_of_frost.up&buff.pillar_of_frost.remains<=4
-- * actions+=/empower_rune_weapon,if=variable.use_cooldowns&(target.time_to_die<20|(rune>=3&runic_power>=60))&cooldown.breath_of_sindragosa.up
-- * actions+=/breath_of_sindragosa,if=variable.use_cooldowns&(target.time_to_die<cooldown.empower_rune_weapon.remains|buff.empower_rune_weapon.up)
-- * actions+=/howling_blast,if=buff.rime.up
-- * actions+=/obliterate,if=variable.bos_ticking&runic_power<=30
-- * actions+=/frost_strike,if=!variable.bos_ticking&(runic_power>=110|(!variable.use_cooldowns&runic_power.deficit<=25))
-- * actions+=/howling_blast,if=!dot.frost_fever.ticking
-- * actions+=/chains_of_ice,if=!variable.bos_ticking&(target.time_to_die<3|buff.cold_heart.stack>=15)
-- * actions+=/obliterate,if=variable.bos_ticking&runic_power.deficit>=25
-- * actions+=/obliterate,if=variable.bos_pooling&(rune>=3|runic_power.deficit>=25)
-- * actions+=/obliterate,if=!variable.bos_ticking&!variable.bos_pooling
-- * actions+=/remorseless_winter,if=!variable.bos_pooling
-- * actions+=/frost_strike,if=!variable.bos_ticking&!variable.bos_pooling

--- ========== CONVERTED ACTION LIST ==========

  function AssassinationDK_APL()
    if (not S) or (not I) or (not Settings) or (not HR) or (not HL) or (not Cache) or (not Unit) or (not Player) or (not Target) or (not Spell) or (not Item) or (not HR) or (not Everyone) or (not Rogue) or (not Settings.Rogue) then
      Initialize()
      return nil
    end

    -- variable,name=use_cooldowns,value=1
    local use_cooldowns = HR.CDsON()

    return "pool"
  end

--- ========== END OF FILE ==========