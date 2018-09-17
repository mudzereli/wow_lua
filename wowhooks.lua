local FILE_VERSION = 20180917
WH_CACHED_ENEMY_COUNT = {}
WH_CACHED_COOLDOWNS_ON = false

function ctime()
    return HeroLib.CombatTime()
end

function enemies_in_range(range)
    if WH_CACHED_ENEMY_COUNT[range] == nil then
        WH_CACHED_ENEMY_COUNT[range] = 0
    end
    local _cache = HeroCache.EnemiesCount[range]
    if _cache ~= nil then 
        WH_CACHED_ENEMY_COUNT[range] = _cache 
    end
    return WH_CACHED_ENEMY_COUNT[range]
end

function cooldowns_on()
    local _cache = HeroRotation.CDsON()
    if _cache ~= nil then
        WH_CACHED_COOLDOWNS_ON = _cache
    end
    return WH_CACHED_COOLDOWNS_ON
end

function filtered_time_to_die(param,timecheck)
    return HeroLib.Unit.Target:FilteredTimeToDie(param, timecheck) or HeroLib.Unit.Target:TimeToDieIsNotValid()
end

function last_ability_used()
    return TMW.CNDT.Env.LastPlayerCastName
end