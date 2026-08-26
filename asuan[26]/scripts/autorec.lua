local sampev = require 'samp.events'

-- config
local WAIT_BEFORE_MONITORING = 60   -- secunde de la intrare pana pornim supravegherea
local RECONNECT_DELAY = 60         -- secunde dupa moarte pana reconect

-- stare
local started = false
local monitoring = false
local startTime = nil

local pendingReconnect = false
local deathTime = nil

-- rulăm la fiecare tick pentru a gestiona timerele (nu e yield în callbacks)
function sampev.onUpdate()
    -- pornim timerul la prima detectare a SA:MP activ (intrare in joc)
    if not started then
        if isSampAvailable and isSampAvailable() then
            started = true
            startTime = os.time()
            print("[Vivi] Timer pornit — monitorizarea va începe în " .. WAIT_BEFORE_MONITORING .. "s.")
        end
        return
    end

    -- după WAIT_BEFORE_MONITORING secunde activăm supravegherea morții
    if not monitoring and startTime and os.time() - startTime >= WAIT_BEFORE_MONITORING then
        monitoring = true
        print("[Vivi] Supravegherea morții este ACTIVĂ.")
    end

    -- dacă avem un reconnect programat, vedem dacă a trecut RECONNECT_DELAY
    if pendingReconnect and deathTime and os.time() - deathTime >= RECONNECT_DELAY then
        pendingReconnect = false
        deathTime = nil
        print("[Vivi] Timpul a expirat — reconectez acum.")
        pcall(function() reconnect() end) -- apelăm reconnect() sigur
    end
end

-- callback apelat la moartea unui jucător
function sampev.onPlayerDeathNotification(killerId, killedId, reason)
    -- nu procedăm dacă monitorizarea nu e activă încă
    if not monitoring then
        print("[Vivi] S-a înregistrat moarte, dar monitorizarea nu e activă încă.")
        return
    end

    -- încercăm să verificăm dacă moartea e a ta
    local myId = nil
    if sampGetPlayerId then myId = sampGetPlayerId() end

    if myId then
        if killedId ~= myId then
            -- nu e moartea ta -> ignorăm
            return
        end
    else
        -- atenție: nu am putut obține player id; în acest caz, scriptul va presupune
        -- că eventul e relevant. Dacă ai sampGetPlayerId, acest bloc nu se execută.
        print("[Vivi] ATENȚIE: nu am sampGetPlayerId(), voi programa reconnect pentru orice death event.")
    end

    -- programăm reconnect după RECONNECT_DELAY secunde (fără wait în callback)
    deathTime = os.time()
    pendingReconnect = true
    print("[Vivi] Ai murit — reconnect programat în " .. RECONNECT_DELAY .. "s.")
end
