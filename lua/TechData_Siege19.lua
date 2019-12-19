//*Judge me for this all you want. IT's necessary. Yes, messy as well. Because it's complete replacement with code that should never need to be changed
//YET FOR SOME REASON SOME PEOPLE KEEP CHANGING IT. WWWWWWWWWWWWWWHHHHHHHHHHHYYYYYYYYYYYYY

local kCachedTechCategories
local kCachedMapNameTechIds
local kCachedTechData

-- Remap techdata for faster lookups
function BuildTechDataCache()
    kCachedTechData = {}
    kCachedMapNameTechIds = {}
    kCachedTechCategories = {}

    if kTechData == nil then
        kTechData = BuildTechData()
    end
    
    for i = 1, #kTechData do
        local data = kTechData[i]
        local techId = data[kTechDataId]
        if techId then
            kCachedTechData[techId] = data

            local mapName = data[kTechDataMapName]
            -- same mapname is sometimes used twice, e.g. for weapon and dropweapon tech
            if mapName and not kCachedMapNameTechIds[mapName] then
                kCachedMapNameTechIds[mapName] = techId
            end

            local category = data[kTechDataCategory]
            if category ~= nil then
                local t = kCachedTechCategories[category] or {}
                table.insert(t, techId)
                kCachedTechCategories[category] = t
            end
        end
    end
end

-- Deprecated
-- No, NOT deprecated.  Beige needs it for tutorials! :(
function SetCachedTechData(techId, fieldName, data, force)

    if kCachedTechData == nil then
        BuildTechDataCache()
    end
    
    assert(kCachedTechData)
    local techData = kCachedTechData[techId]
    
    -- Cannot be used to create a new techData entry -- would screw up the enumeration otherwise.
    assert(techData ~= nil)
    
    techData[fieldName] = data
    return true
    
end

function LookupTechId(mapName)

    -- Initialize table if necessary
    if kTechData == nil then
        kTechData = BuildTechData()
    end

    if kCachedMapNameTechIds == nil then
        BuildTechDataCache()
    end
    
    return kCachedMapNameTechIds[mapName] or kTechId.None

end

function GetCachedTechData(techId, fieldName)

    if kCachedTechData == nil then
        BuildTechDataCache()
    end
    
    local entry = kCachedTechData[techId]
    return entry and entry[fieldName]

end

function GetTechForCategory(techId)

    if kCachedTechCategories == nil then
        BuildTechDataCache()
    end
    
    return kCachedTechCategories[techId] or {}

end