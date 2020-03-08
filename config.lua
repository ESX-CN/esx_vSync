Config = {}

Config.Locale = 'en'

-- Set this to false if you don't want the weather to change automatically every 10 minutes.
-- 如果您不希望天气每10分钟自动更改一次，请将其设置为false。
Config.DynamicWeather = true

-- don't touch this unless you know what you're doing or you're being asked by Vespura to turn this on.
-- 除非您知道自己在做什么或者Vespura要求您将其打开，否则请勿修改。
Config.debugprint = false

-- DON'T CHANGE THIS
-- 不要修改这个配置
Config.CurrentWeather = "EXTRASUNNY"

Config.AvailableWeatherTypes = {
    'EXTRASUNNY',
    'CLEAR',
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS',
    'HALLOWEEN'
}

