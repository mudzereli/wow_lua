local FILE_VERSION = 20180917

WH_DO_INTERRUPT = true
WH_DPS_AVERAGE_PERSON = 8000

WH_INTERRUPT_TABLE = {}
WH_INTERRUPT_TABLE["Normal Tank Dummy"] = "Uber Strike"

-- FREEHOLD
    WH_INTERRUPT_TABLE["Irontide Bonesaw"] = "Healing Balm"
    WH_INTERRUPT_TABLE["Skycap'n Kragg"] = "Revitalizing Brew"
    WH_INTERRUPT_TABLE["Irontide Oarsman"] = "Sea Spout"
    WH_INTERRUPT_TABLE["Blacktooth Knuckleduster"] = "Shattering Bellow"
    WH_INTERRUPT_TABLE["Irontide Stormcaller"] = "Thundering Squall"

-- SHRINE OF THE STORM
    WH_INTERRUPT_TABLE["Shrine Templar"] = "Tidal Surge"
    WH_INTERRUPT_TABLE["Temple Attendant"] = "Water Blast"
    --WH_INTERRUPT_TABLE["Tidesage Spiritualist"] = "Anchor of Binding"
    WH_INTERRUPT_TABLE["Tidesage Spiritualist"] = "Mending Rapids"
    WH_INTERRUPT_TABLE["Galecaller Apprentice"] = "Tempest"
    WH_INTERRUPT_TABLE["Galecaller Faye"] = "Slicing Blast"
    WH_INTERRUPT_TABLE["Deepsea Ritualist"] = "Unending Darkness"
    WH_INTERRUPT_TABLE["Drowned Depthbringer"] = "Touch of the Drowned"
    --WH_INTERRUPT_TABLE["Drowned Depthbringer"] = "Rip Mind"
    --WH_INTERRUPT_TABLE["Drowned Depthbringer"] = "Void Bolt"
    WH_INTERRUPT_TABLE["Abyssal Cultist"] = "Detect Thoughts"
    WH_INTERRUPT_TABLE["Abyssal Cultist"] = "Consuming Void"
    WH_INTERRUPT_TABLE["Lord Stormsong"] = "Void Bolt"
    WH_INTERRUPT_TABLE["Forgotten Denizen"] = "Consume Essence"

-- SIEGE OF BORALUS
    WH_INTERRUPT_TABLE["Kul Tiran Wavetender"] = "Watertight Shell"
    WH_INTERRUPT_TABLE["Bilge Rat Tempest"] = "Revitalizing Mist"
    WH_INTERRUPT_TABLE["Bilge Rat Tempest"] = "Choking Waters"
    --WH_INTERRUPT_TABLE["Bilge Rat Tempest"] = "Water Spray"

-- TOL DAGOR
    WH_INTERRUPT_TABLE["Irontide Thug"] = "Debilitating Shout"
    WH_INTERRUPT_TABLE["Bilge Rat Seaspeaker"] = "Watery Dome"
    --WH_INTERRUPT_TABLE["Bilge Rat Seaspeaker"] = "Salt Blast"
    WH_INTERRUPT_TABLE["Jes Howlis"] = "Howling Fear"
    WH_INTERRUPT_TABLE["Bobby Howlis"] = "Howling Fear"
    WH_INTERRUPT_TABLE["Ashvane Officer"] = "Handcuff"
    WH_INTERRUPT_TABLE["Ashvane Flamecaster"] = "Blaze"
    WH_INTERRUPT_TABLE["Ashvane Flamecaster"] = "Fuselighter"
    WH_INTERRUPT_TABLE["Ashvane Priest"] = "Inner Flames"

-- WAYCREST MANOR
    WH_INTERRUPT_TABLE["Soul Essence"] = "Scar Soul"
    WH_INTERRUPT_TABLE["Bewitched Captain"] = "Spirited Defense"
    WH_INTERRUPT_TABLE["Thistle Acolyte"] = "Bone Splinter"
    WH_INTERRUPT_TABLE["Thistle Acolyte"] = "Drain Essence"
    WH_INTERRUPT_TABLE["Sister Solena"] = "Soul Bolt"
    WH_INTERRUPT_TABLE["Sister Malady"] = "Ruinous Bolt"
    WH_INTERRUPT_TABLE["Sister Briar"] = "Bramble Bolt"
    WH_INTERRUPT_TABLE["Coven Thornshaper"] = "Soul Fetish"
    WH_INTERRUPT_TABLE["Heartsbane Runeweaver"] = "Etch"
    WH_INTERRUPT_TABLE["Devouring Maggot"] = "Infest"
    WH_INTERRUPT_TABLE["Banquet Steward"] = "Dinner Bell"
    WH_INTERRUPT_TABLE["Matron Alma"] = "Ruinous Volley"
    WH_INTERRUPT_TABLE["Marked Sister"] = "Runic Mark"
    WH_INTERRUPT_TABLE["Coven Diviner"] = "Soul Fetish"
    WH_INTERRUPT_TABLE["Heartsbane Soulcharmer"] = "Ruinous Volley"
    WH_INTERRUPT_TABLE["Lady Waycrest"] = "Wracking Chord"
    WH_INTERRUPT_TABLE["Gorak Tul"] = "Darkened Lightning"

-- ATAL DAZAR
    WH_INTERRUPT_TABLE["Dazar'ai Juggernaut"] = "Fanatic's Rage"
    WH_INTERRUPT_TABLE["Dazar'ai Augur"] = "Fiery Enchant"
    WH_INTERRUPT_TABLE["Feasting Skyscreamer"] = "Terrifying Screech"
    WH_INTERRUPT_TABLE["Dinomancer Kish'o"] = "Dino Might"
    WH_INTERRUPT_TABLE["Zanchuli Witch-Doctor"] = "Unstable Hex"
    WH_INTERRUPT_TABLE["Vol'kaal"] = "Noxious Stench"
    WH_INTERRUPT_TABLE["Yazma"] = "Wracking Pain"

-- TEMPLE OF SETHRALIS
    WH_INTERRUPT_TABLE["Charged Dust Devil"] = "Healing Surge"
    WH_INTERRUPT_TABLE["Aspix"] = "Jolt"
    WH_INTERRUPT_TABLE["Faithless Tender"] = "Greater Healing Potion"
    WH_INTERRUPT_TABLE["Agitated Nimbus"] = "Accumulate Charge"
    WH_INTERRUPT_TABLE["Spark Channeler"] = "Shock"
    WH_INTERRUPT_TABLE["Plague Doctor"] = "Chain Lightning"

-- MOTHERLODE
    WH_INTERRUPT_TABLE["Refreshment Vendor"] = "Kaja'Cola Refresher"
    WH_INTERRUPT_TABLE["Refreshment Vendor"] = "Iced Spritzer"
    WH_INTERRUPT_TABLE["Hired Assassin"] = "Hail of Flechettes"
    WH_INTERRUPT_TABLE["Hired Assassin"] = "Toxic Blades"
    WH_INTERRUPT_TABLE["Addled Thug"] = "Inhale Vapors"
    WH_INTERRUPT_TABLE["Venture Co. Earthshaper"] = "Earth Shield"
    WH_INTERRUPT_TABLE["Stonefury"] = "Tectonic Barrier"
    --WH_INTERRUPT_TABLE["Stonefury"] = "Furious Quake"
    WH_INTERRUPT_TABLE["Feckless Assassin"] = "Transfiguration Serum"
    WH_INTERRUPT_TABLE["Feckless Assassin"] = "Blowtorch"
    WH_INTERRUPT_TABLE["Venture Co. Alchemist"] = "Transmute: Enemy to Goo"
    WH_INTERRUPT_TABLE["Ordnance Specialist"] = "Artillery Barrage"
    WH_INTERRUPT_TABLE["Venture Co. Skyscorcher"] = "Concussion Charge"
    WH_INTERRUPT_TABLE["Expert Technician"] = "Overcharge"

-- UNDERROT
    WH_INTERRUPT_TABLE["Devout Blood Priest"] = "Dark Reconstitution"
    WH_INTERRUPT_TABLE["Befouled Spirit"] = "Harrowing Despair"
    WH_INTERRUPT_TABLE["Elder Leaxa"] = "Blood Bolt"
    WH_INTERRUPT_TABLE["Feral Bloodswarmer"] = "Sonic Screech"
    --WH_INTERRUPT_TABLE["Living Rot"] = "Wave of Decay"
    WH_INTERRUPT_TABLE["Diseased Lasher"] = "Decaying Mind"
    WH_INTERRUPT_TABLE["Reanimated Guardian"] = "Bone Shield"
    WH_INTERRUPT_TABLE["Fallen Deathspeaker"] = "Raise Dead"
    --WH_INTERRUPT_TABLE["Fallen Deathspeaker"] = "Wicked Frenzy"
    WH_INTERRUPT_TABLE["Grotesque Horror"] = "Death Bolt"
    WH_INTERRUPT_TABLE["Bloodsworn Defiler"] = "Withering Curse"
    WH_INTERRUPT_TABLE["Bloodsworn Defiler"] = "Shadow Bolt Volley"

-- KINGS REST
    WH_INTERRUPT_TABLE["Shadow-Borne Witch Doctor"] = "Shadow Bolt Volley"
    --WH_INTERRUPT_TABLE["Shadow-Borne Witch Doctor"] = "Deathly Chill"
    WH_INTERRUPT_TABLE["Queen Wasi"] = "Shadow Bolt"
    WH_INTERRUPT_TABLE["Seneschal M'bara"] = "Induce Regeneration"
    WH_INTERRUPT_TABLE["Half-Finished Mummy"] = "Wretched Discharge"
    WH_INTERRUPT_TABLE["Spectral Hex Priest"] = "Hex"
    WH_INTERRUPT_TABLE["Zanazal the Wise"] = "Poison Nova"

-- ULDIR [TODO]

WH_INTERRUPT_TABLE["_____"] = "_____"

WH_ICEBOUND_TABLE = {}
WH_ICEBOUND_TABLE["Normal Tank Dummy"] = "Uber Strike"

WH_AMS_TABLE = {}
WH_AMS_TABLE["Normal Tank Dummy"] = "Uber Strike"

---- BASIC WRAPPER FUNCTIONS
function is_casting(unit)
    local spellName = UnitCastingInfo(unit)
    return spellName ~= nil
end

function is_channeling(unit)
    local spellName = UnitChannelInfo(unit)
    return spellName ~= nil
end

function remaining_cast_time_ms(unit)
    local _, _, _, _, castEndTime = UnitCastingInfo(unit)
    if castEndTime == nil then return nil end
    local currentTime = GetTime() * 1000
    return castEndTime - currentTime
end

function channel_time_ms(unit)
    local _, _, _, castStartTime = UnitChannelInfo(unit)
    if castStartTime == nil then return nil end
    local currentTime = GetTime() * 1000
    return currentTime - castStartTime
end

function cast_time_ms(unit)
    local _, _, _, castStartTime = UnitCastingInfo(unit)
    if castStartTime == nil then return nil end
    local currentTime = GetTime() * 1000
    return currentTime - castStartTime
end

function interrupt_target_with_cast_time_ms(timeMS)
    local remainingCastTimeMS = remaining_cast_time_ms("target")
    local castTimeMS = cast_time_ms("target")
    local channelTimeMS = channel_time_ms("target")
    return (remainingCastTimeMS ~= nil and castTimeMS ~= nil and remainingCastTimeMS < timeMS and castTimeMS > timeMS) or (channelTimeMS ~= nil and channelTimeMS > timeMS)
end

function should_interrupt(unit)
    local _unitName = UnitName(unit)
    local _castingSpellName = UnitCastingInfo(unit)
    local _channelingSpellName = UnitChannelInfo(unit)
    local _do_interrupt = false
    if not WH_DO_INTERRUPT then return false end
    if _unitName == nil then return false end
    if _castingSpellName == nil and _channelingSpellName == nil then return false end
    for u, s in pairs(WH_INTERRUPT_TABLE) do
        if(_unitName == u and (_castingSpellName == s or _channelingSpellName == s)) then
            _do_interrupt = true
        end
    end
    return _do_interrupt
end

function is_mount_usable(indx)
    local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(indx)
    return isUsable
end

function remaining_aura_duration(unit, aura, filter)
    local _, _, _, _, _, duration, expire = UnitAura(unit, aura, "" , filter)
    if duration ~= nil then
        local remains = expire - GetTime()
        return remains
    end
    return 0
end

function has_aura(unit, aura, filter)
    local name = UnitAura(unit, aura, "" , filter)
    return name ~= nil
end

function get_party_members()
    local party={}
    if IsInRaid() then
        for i=1,40 do
            if (UnitName('raid'..i)) then
                tinsert(party,{(UnitName('raid'..i)), UnitGroupRolesAssigned('raid'..i), 'raid'..i})
            end
        end
    elseif IsInGroup() then
        for i=1,4 do
            if (UnitName('party'..i)) then
                tinsert(party,{(UnitName('party'..i)), UnitGroupRolesAssigned('party'..i), 'party'..i})
            end
        end
        tinsert(party,{(UnitName('player')), UnitGroupRolesAssigned('player'), 'player'})
    else
        tinsert(party,{(UnitName('player')), 'DAMAGER', 'player'})
    end
    return party
end

function count_nearby_party_members()
    local party = get_party_members()
    local countNearbyMembers = 0
    for i,member in ipairs(party) do
        local memRef = member[3]
        if UnitInRange(memRef) or UnitIsUnit(memRef,"player") then
            countNearbyMembers = countNearbyMembers + 1
        end
    end
    return countNearbyMembers
end

function alone()
    return count_nearby_party_members() == 1
end

function health_percent(unit)
    local HP = UnitHealth(unit)
    local maxHP = UnitHealthMax(unit)
    if not HP or not maxHP or HP < 0 or maxHP <= 0 then return 0 end
    return HP / maxHP * 100
end

function aura_stacks(unt,buf)
    local _, _, _, count = UnitBuff(unt, buf)
    if count == nil then return 0 end
    return count
end

function combo_points()
    return UnitPower("player",4)
end

function max_combo_points()
    return  MAX_COMBO_POINTS + binarize(talent_enabled("Deeper Stratagem")) + (binarize(talent_enabled("Anticipation")) * 5)
end

function combo_point_deficit()
    return max_combo_points() - combo_points()
end

function boolean_to_string(bool)
    if bool then return "true" else return "false" end
end

function remaining_aura_duration(unit, aura, filter)
    local _, _, _, _, _, duration, expire = UnitAura(unit, aura, "" , filter)
    if duration ~= nil then
        local remains = expire - GetTime()
        return remains
    end
    return 0
end

function binarize(flag)
    if (flag) then
        return 1
    else
        return 0
    end
end

function cp_max_spend() 
    return  MAX_COMBO_POINTS + binarize(talent_enabled("Deeper Stratagem"))
end 

function buff_stacks(buffName)
    local name,_,_,count=UnitBuff("player",buffName)
    if count == nil then return 0 end
    return count
end

function energy()
    return UnitPower("player")
end

function item_cooldown_remains(itemID)
    local _start, _duration, _ = GetItemCooldown(itemID)
    if _start ~= nil and _duration ~= nil and _start > 0 and _duration > 0 then
        return _start + _duration - GetTime()
    else
        return 0
    end
end

function cooldown_up(spellName)
    return cooldown_remains(spellName) == 0
end

function cooldown_remains(spellName)
    local _start, _duration, _, _ = GetSpellCooldown(spellName)
    if _start ~= nil and _duration ~= nil and _start > 0 and _duration > 0 then
        return _start + _duration - GetTime()
    else
        return 0
    end
end

function gcd_remains()
    local _start, _duration, _, _ = GetSpellCooldown(61304)
    local _r = _start + _duration - GetTime()
    if _r < 0 then
        _r = 0
    end
    return _r
end

function debuff_remains(buffName)
    local _r = remaining_aura_duration("target", buffName, "HARMFUL|PLAYER")
    if _r > 0 then 
        return _r 
    else 
        return 0 
    end
end

function buff_remains(buffName)
    local _r = remaining_aura_duration("player", buffName, "")
    if _r > 0 then 
        return _r 
    else 
        return 0 
    end
end

function debuff_up(debuffName)
    return has_aura("target", debuffName,"HARMFUL|PLAYER")
end

function buff_up(buffName)
    return has_aura("player", buffName)
end

function buff_down(buffName)
    return cooldown_remains(buffName) > 0 and (not buff_up(buffName))
end

function talent_enabled(talentName)
    for _t=1,7 do
        for _c=1,3 do
            local _, name, _, selected = GetTalentInfo(_t, _c, GetActiveSpecGroup(), false, nil)
            if selected and name:lower() == talentName:lower() then
                return true
            end
        end
    end
    return false
end

function stealthed_all()
    return buff_up("Stealth") 
    or buff_up("Vanish") 
    or buff_up("Shadow Dance") 
    or buff_up("Subterfuge") 
    or buff_up("Shadowmeld")
end

function equipped(itemName)
    return IsEquippedItem(itemName:lower()) 
end

function energy_pct()
    return UnitPowerMax("player") - UnitPower("player")
end

function energy_pct()
    return UnitPower("player") / UnitPowerMax("player") * 100
end

function off_cooldown(spellName)
    return cooldown_remains(spellName) == 0
end

function on_cooldown(spellName)
    return cooldown_remains(spellName) > 0
end

function is_boss(unit)
    return UnitLevel(unit) == -1
end

function encounter_in_progress()
    return IsEncounterInProgress()
end

function has_enemy_target()
    if(not UnitExists("target")) then
        return false
    end
    if(UnitIsDeadOrGhost("target")) then
        return false
    end
    if(UnitIsDeadOrGhost("player")) then
        return false
    end
    if(UnitReaction("target","player") == nil) then
        return false
    end
    if(UnitReaction("target","player") < 5 or UnitName("target"):find("Dummy")) then
        return true
    end
end

function in_range_of(unit,spellName)
    local _r = IsSpellInRange(spellName, unit)
    if (_r == nil) then
        return false
    elseif (_r == 0) then
        return false
    else
        return true
    end
end