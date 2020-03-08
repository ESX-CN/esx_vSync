ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-------------------- DON'T CHANGE THIS --------------------
local baseTime = 0
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 10

RegisterServerEvent('esx_vSync:requestSync')
AddEventHandler('esx_vSync:requestSync', function()
    TriggerClientEvent('esx_vSync:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('esx_vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local newBaseTime = os.time(os.date("!*t"))/2 + 360
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime			
        end
        baseTime = newBaseTime
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        TriggerClientEvent('esx_vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        TriggerClientEvent('esx_vSync:updateWeather', -1, CurrentWeather, blackout)
    end
end)

Citizen.CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Citizen.Wait(60000)
        if newWeatherTimer == 0 then
            if Config.DynamicWeather then
                NextWeatherStage()
            end
            newWeatherTimer = 10
        end
    end
end)

function NextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "RAIN" end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("esx_vSync:requestSync")
    if Config.debugprint then
        print(_U('debug_1', CurrentWeather))
        print(_U('debug_2'))
    end
end

function ShiftToMinute(minute)
    timeOffset = timeOffset - ( ( (baseTime+timeOffset) % 60 ) - minute )
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
end

-- 冻结时间
ESX.RegisterCommand('freezetime', 'admin', function(xPlayer, args, showError)
    if xPlayer.source ~= 0 then
        freezeTime = not freezeTime
        if freezeTime then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('frozen_time'))
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_frozen_time'))
        end
    else
        freezeTime = not freezeTime
        if freezeTime then
            print(_U('frozen_time'))
        else
            print(_U('no_frozen_time'))
        end
    end
end, true, {help = _U('freeze_time_help'), validate = false, arguments = {}})

-- 冻结天气
ESX.RegisterCommand('freezeweather', 'admin', function(xPlayer, args, showError)
    if xPlayer.source ~= 0 then
        DynamicWeather = not DynamicWeather
        if not DynamicWeather then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('dynamic_weather_off'))
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('dynamic_weather_on'))
        end
    else
        DynamicWeather = not DynamicWeather
        if not DynamicWeather then
            print(_U('dynamic_weather_off'))
        else
            print(_U('dynamic_weather_on'))
        end
    end
end, true, {help = _U('dynamic_weather_help'), validate = false, arguments = {}})

-- 更改天气
ESX.RegisterCommand('weather', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        local validWeatherType = false
        if args.weatherType == nil then
            print(_U('weather_invalid_syntax'))
            return
        else
            for i,wtype in ipairs(Config.AvailableWeatherTypes) do
                if wtype == string.upper(args.weatherType) then
                    validWeatherType = true
                end
            end
            if validWeatherType then
                print(_U('weather_has_been_updated'))
                CurrentWeather = string.upper(args.weatherType)
                newWeatherTimer = 10
                TriggerEvent('esx_vSync:requestSync')
            else
                print(_U('invalid_weather_type'))
            end
        end
    else
        local validWeatherType = false
        if args.weatherType == nil then
            TriggerClientEvent('chatMessage', xPlayer.source, '', {255,255,255}, _U('invalid_weather_syntax_c'))
        else
            for i,wtype in ipairs(Config.AvailableWeatherTypes) do
                if wtype == string.upper(args.weatherType) then
                    validWeatherType = true
                end
            end
            if validWeatherType then
                TriggerClientEvent('esx:showNotification', xPlayer.source, _U('change_weather', string.lower(args.weatherType)))
                CurrentWeather = string.upper(args.weatherType)
                newWeatherTimer = 10
                TriggerEvent('esx_vSync:requestSync')
            else
                TriggerClientEvent('chatMessage', xPlayer.source, '', {255,255,255}, _U('invalid_weather_type'))
            end
        end
    end
end, true, {help = _U('weather_help'), validate = true, arguments = {
    {name = "weatherType", help = _U('weatherType_help'), type = 'string'}
}})

-- 切换停电模式。
ESX.RegisterCommand('blackout', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        blackout = not blackout
        if blackout then
            print(_U('blackout_enabled'))
        else
            print(_U('blackout_disabled'))
        end
    else
        blackout = not blackout
        if blackout then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('blackout_enabled'))
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('blackout_disabled'))
        end
        TriggerEvent('esx_vSync:requestSync')
    end
end, true, {help = _U('blackout_help'), validate = false, arguments = {}})

ESX.RegisterCommand('morning', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        print(_U('use_time'))
        return
    end
    ShiftToMinute(0)
    ShiftToHour(9)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('morning_time'))
    TriggerEvent('esx_vSync:requestSync')
end, true, {help = _U('morning_help'), validate = false, arguments = {}})

ESX.RegisterCommand('noon', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        print(_U('use_time'))
        return
    end
    ShiftToMinute(0)
    ShiftToHour(12)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('noon_time'))
    TriggerEvent('esx_vSync:requestSync')
end, true, {help = _U('noon_help'), validate = false, arguments = {}})

ESX.RegisterCommand('evening', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        print(_U('use_time'))
        return
    end
    ShiftToMinute(0)
    ShiftToHour(18)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('evening_time'))
    TriggerEvent('esx_vSync:requestSync')
end, true, {help = _U('evening_help'), validate = false, arguments = {}})

ESX.RegisterCommand('night', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        print(_U('use_time'))
        return
    end
    ShiftToMinute(0)
    ShiftToHour(23)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('night_time'))
    TriggerEvent('esx_vSync:requestSync')
end, true, {help = _U('night_help'), validate = false, arguments = {}})

ESX.RegisterCommand('time', 'admin', function(xPlayer, args, showError)
    if xPlayer.source == 0 then
        if tonumber(args.hours) ~= nil and tonumber(args.minutes) ~= nil then
            local argh = tonumber(args.hours)
            local argm = tonumber(args.minutes)
            if argh < 24 then
                ShiftToHour(argh)
            else
                ShiftToHour(0)
            end
            if argm < 60 then
                ShiftToMinute(argm)
            else
                ShiftToMinute(0)
            end
            print(_U('time_changed', argh, argm))
            TriggerEvent('esx_vSync:requestSync')
        else
            print(_U('invalid_time_syntax'))
        end
    elseif xPlayer.source ~= 0 then
        if tonumber(args.hours) ~= nil and tonumber(args.minutes) ~= nil then
            local argh = tonumber(args.hours)
            local argm = tonumber(args.minutes)
            if argh < 24 then
                ShiftToHour(argh)
            else
                ShiftToHour(0)
            end
            if argm < 60 then
                ShiftToMinute(argm)
            else
                ShiftToMinute(0)
            end
            local newtime = math.floor(((baseTime+timeOffset)/60)%24)
            local minute = math.floor((baseTime+timeOffset)%60)
            if minute < 10 then
                newtime = newtime .. ":0" .. minute
            else
                newtime = newtime .. ":" .. minute
            end
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('time_changed_s', newtime))
            TriggerEvent('esx_vSync:requestSync')
        else
            TriggerClientEvent('chatMessage', xPlayer.source, '', {255,255,255}, _U('invalid_time_syntax_c'))
        end
    end 
end, true, {help = _U('time_help'), validate = true, arguments = {
    { name = "hours", help = _U('time_hours_help'), type = "number" },
    { name = "minutes", help = _U('time_minutes_help'), type = "number" }
}})