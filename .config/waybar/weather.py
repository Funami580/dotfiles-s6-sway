#!/usr/bin/env python
# Original: https://gist.github.com/bjesus/f8db49e1434433f78e5200dc403d58a3

import os
import os.path
import time
import json
import re
import requests
import locale
from datetime import datetime, timedelta
from bs4 import BeautifulSoup  # needed if DISABLE_TIDES is False
from typing import List

LOCATION = "Put your city here"
DISABLE_TIDES = True
NATIVE_LOCALE = "de_DE.UTF-8"
EMOJI_FONT = "Noto Color Emoji"

WEATHER_CODE_TO_EMOJI = {
    '113': '☀️',
    '116': '⛅️',
    '119': '☁️',
    '122': '☁️',
    '143': '🌫',
    '176': '🌦',
    '179': '🌧',
    '182': '🌧',
    '185': '🌧',
    '200': '⛈',
    '227': '🌨',
    '230': '❄️',
    '248': '🌫',
    '260': '🌫',
    '263': '🌦',
    '266': '🌦',
    '281': '🌧',
    '284': '🌧',
    '293': '🌦',
    '296': '🌦',
    '299': '🌧',
    '302': '🌧',
    '305': '🌧',
    '308': '🌧',
    '311': '🌧',
    '314': '🌧',
    '317': '🌧',
    '320': '🌨',
    '323': '🌨',
    '326': '🌨',
    '329': '❄️',
    '332': '❄️',
    '335': '❄️',
    '338': '❄️',
    '350': '🌧',
    '353': '🌦',
    '356': '🌧',
    '359': '🌧',
    '362': '🌧',
    '365': '🌧',
    '368': '🌨',
    '371': '❄️',
    '374': '🌧',
    '377': '🌧',
    '386': '⛈',
    '389': '🌩',
    '392': '⛈',
    '395': '❄️'
}

def get_cache_file(id: str) -> str:
    return f"/tmp/{os.getuid()}-waybar-{id}"

def get_website_with_cache(id: str, url: str, reload_secs: int, reload_new_day: bool) -> str:
    CACHE_FILE = get_cache_file(id)

    try:
        curr_time = time.time()
        last_mtime = os.path.getmtime(CACHE_FILE)
        new_day_time = datetime.now().replace(hour=0, minute=1, second=0, microsecond=0).timestamp()

        if not (curr_time >= new_day_time and last_mtime < new_day_time) and curr_time - last_mtime < reload_secs:
            # return cache, if not info from last day and accessed within reload_secs seconds after last update
            with open(CACHE_FILE, "r") as f:
                return f.read()
    except Exception:
        # no file exists, ignore
        pass

    # otherwise try to get new information
    try:
        response = requests.get(url).text
        with open(CACHE_FILE, "w") as f:
            f.write(response)
        return response
    except Exception:
        # we seem to have no internet connection, ignore
        pass

    # it might be that the file exists, but is pretty old.
    # but try to read it anyway
    try:
        with open(CACHE_FILE, "r") as f:
            return f.read()
    except Exception:
        # no file exists, ignore
        pass

    # we are not able to return anything
    return None

def get_weather() -> dict | None:
    id = "weather-cache"
    CACHE_FILE = get_cache_file(id)
    contents = get_website_with_cache(id, url=f"https://wttr.in/{LOCATION}?format=j1", reload_secs=3 * 60, reload_new_day=False)
    if contents is None:
        return None
    try:
        return json.loads(contents)
    except json.decoder.JSONDecodeError:
        os.remove(CACHE_FILE)
        return None

def get_zenith() -> str | None:
    contents = get_website_with_cache(id="zenith-cache", url=f"https://wttr.in/{LOCATION}?format=%z", reload_secs=60 * 60, reload_new_day=True)
    if contents is None:
        return None
    return contents

def get_tides() -> dict | None:
    if DISABLE_TIDES:
        return None
    contents = get_website_with_cache(id="tides-cache", url=f"https://www.meerestemperatur.de/europa/deutschland/{LOCATION.lower()}/tides.html", reload_secs=60 * 60 * 24, reload_new_day=False)
    if contents is None:
        return None
    soup = BeautifulSoup(contents, "html.parser")
    selection = soup.select("#forecast ~ h3, #forecast ~ .row tbody")
    def chunker(seq, size):
        # https://stackoverflow.com/questions/434287/how-to-iterate-over-a-list-in-chunks
        return (seq[pos:pos + size] for pos in range(0, len(seq), size))
    data = {}
    for day, info in chunker(selection, 2):
        day_of_month = int(re.search(r'\d+', day.getText()).group())
        flood_times = []
        for flood in info.select(".label-danger"):
            flood_time = flood.findNext("td").getText()
            flood_times.append(flood_time)
        assert day_of_month not in data
        data[day_of_month] = flood_times
    return data

def parse_date(date: str) -> datetime:
    return datetime.strptime(date, "%Y-%m-%d")

def hex_to_raw_emoji(hex: int) -> str:
    return f"&#{hex};"

def hex_to_emoji(hex: int) -> str:
    return format_raw_emoji(hex_to_raw_emoji(hex))

def format_raw_emoji(emoji: str) -> str:
    return f'<span font_family="{EMOJI_FONT}">{emoji}</span>'

def format_weekday(date: datetime) -> str:
    locale.setlocale(locale.LC_TIME, NATIVE_LOCALE)
    res = date.strftime("%a")
    locale.setlocale(locale.LC_TIME, "en_US.UTF-8")
    return res

def format_time(time: str) -> str:
    return time.removesuffix("00").zfill(2)

def format_time_12_to_24(time: str) -> str | None:
    # https://stackoverflow.com/questions/19229190/how-to-convert-am-pm-timestmap-into-24hs-format-in-python
    try:
        in_time = datetime.strptime(time, "%I:%M %p")
        out_time = datetime.strftime(in_time, "%H:%M")
        return out_time
    except Exception:
        return None

def format_temperature(temp: str | int | float) -> str:
    return f"{temp}°C"

def format_wind_speed(kmph: str | int) -> str:
    beaufort_scale = wind_kmph_to_beaufort_scale(int(kmph))
    desc = beaufort_scale_to_description(beaufort_scale)
    return f"{kmph}km/h, {beaufort_scale} Bft ({desc})"

def format_wind_direction(direction: str) -> str:
    return direction.strip()

def format_wind_short(kmph: str | int | float, direction: str) -> str:
    return f"{hex_to_emoji(0x1F32C)} {kmph}km/h {direction}"

def format_humidity(humidity: str | int | float) -> str:
    return f"{humidity}%"

def format_humidity_with_emoji(humidity: str | int | float) -> str:
    return f"{hex_to_emoji(0x1F4A7)} {format_humidity(humidity)}"

def format_chances(hour) -> str:
    chances = {
        "chanceoffog": "Fog",
        "chanceoffrost": "Frost",
        "chanceofovercast": "Overcast",
        "chanceofrain": "Rain",
        "chanceofsnow": "Snow",
        "chanceofsunshine": "Sunshine",
        "chanceofthunder": "Thunder",
        "chanceofwindy": "Wind"
    }

    conditions = []
    for condition, condition_name in chances.items():
        condition_probability = hour[condition]
        if int(condition_probability) > 0:
            conditions.append((condition_name, condition_probability))

    result_strs = []
    for condition_name, condition_probability in sorted(conditions, key=lambda x: x[1], reverse=True):
        result_strs.append(f"{condition_name} {condition_probability}%")

    return ", ".join(result_strs)

def format_max_temp(temp: str | int | float) -> str:
    return f"{hex_to_emoji(0x2B06)} {format_temperature(temp)}"

def format_min_temp(temp: str | int | float) -> str:
    return f"{hex_to_emoji(0x2B07)} {format_temperature(temp)}"

def format_sunrise(time: str) -> str:
    return f"{hex_to_emoji(0x1F305)} {format_time_12_to_24(time)}"

def format_sunset(time: str) -> str:
    return f"{hex_to_emoji(0x1F307)} {format_time_12_to_24(time)}"

def format_moonrise(time: str) -> str | None:
    moon_time = format_time_12_to_24(time)
    if moon_time is None:
        return None
    return f"{hex_to_emoji(0x2B06)} {moon_time}"

def format_moonset(time: str) -> str | None:
    moon_time = format_time_12_to_24(time)
    if moon_time is None:
        return None
    return f"{hex_to_emoji(0x2B07)} {moon_time}"

def format_moon_illumination(illumination: str | int | float) -> str:
    return f"{illumination}%"

def format_moon_phase(moon_phase: str, is_southern_hemisphere: bool) -> str:
    # https://github.com/chubin/wttr.in/blob/e0cc061a64ba86cda1380f0409203a0fb8ae889c/lib/metno.py#L417-L426
    # https://www.unicode.org/L2/L2017/17304-moon-var.pdf
    moon_phase_to_unicode_emoji = {
        # emoji for (northern hemisphere, southern hemisphere)
        "New Moon": (0x1F311, 0x1F311),
        "Waxing Crescent": (0x1F312, 0x1F318),
        "First Quarter": (0x1F313, 0x1F317),
        "Waxing Gibbous": (0x1F314, 0x1F316),
        "Full Moon": (0x1F315, 0x1F315),
        "Waning Gibbous": (0x1F316, 0x1F314),
        "Last Quarter": (0x1F317, 0x1F313),
        "Waning Crescent": (0x1F318, 0x1F312),
    }

    moon_phase = moon_phase.strip()

    try:
        index = 1 if is_southern_hemisphere else 0
        return hex_to_emoji(moon_phase_to_unicode_emoji[moon_phase][index])
    except Exception:
        return moon_phase

def format_tides(tides: List[str]) -> str:
    return f"{hex_to_emoji(0x1F30A)} {' '.join(tides)}"

def format_zenith(zenith: str) -> str:
    zenith_time = ":".join(zenith.split(":")[:2])
    return f'{hex_to_emoji(0x2600)} {zenith_time}' # Font hack

def wind_kmph_to_beaufort_scale(kmph: int) -> int | None:
    # https://www.britannica.com/science/Beaufort-scale
    # https://www.rmets.org/metmatters/beaufort-wind-scale
    if 0 <= kmph < 1:
        return 0
    elif 1 <= kmph <= 5:
        return 1
    elif 6 <= kmph <= 11:
        return 2
    elif 12 <= kmph <= 19:
        return 3
    elif 20 <= kmph <= 28:
        return 4
    elif 29 <= kmph <= 38:
        return 5
    elif 39 <= kmph <= 49:
        return 6
    elif 50 <= kmph <= 61:
        return 7
    elif 62 <= kmph <= 74:
        return 8
    elif 75 <= kmph <= 88:
        return 9
    elif 89 <= kmph <= 102:
        return 10
    elif 103 <= kmph <= 117:
        return 11
    elif kmph >= 118:
        return 12
    else:
        return None

def beaufort_scale_to_description(beaufort_scale: int) -> str | None:
    # https://www.rmets.org/metmatters/beaufort-wind-scale
    scale_to_desc = {
        0: "Calm",
        1: "Light air",
        2: "Light breeze",
        3: "Gentle breeze",
        4: "Moderate breeze",
        5: "Fresh breeze",
        6: "Strong breeze",
        7: "Near gale",
        8: "Gale",
        9: "Strong gale",
        10: "Storm",
        11: "Violent storm",
        12: "Hurricane",
    }
    return scale_to_desc.get(beaufort_scale)

def wind_kmph_to_beaufort_description(kmph: int) -> str | None:
    return beaufort_scale_to_description(wind_kmph_to_beaufort_scale(kmph))

def output_json():
    now = datetime.now()

    data = {}
    data['text'] = format_weekday(now)

    weather = get_weather()

    if weather is None:
        data['tooltip'] = "Failed to retrieve weather"
        return data

    tides = get_tides()
    todays_zenith = get_zenith()
    is_southern_hemisphere = re.search(r'Lat (-?\d+(?:\.\d+)?)', weather['request'][0]['query']).groups()[0].startswith("-")

    # Current weather
    current_weather_condition = weather['current_condition'][0]['weatherDesc'][0]['value']
    current_temp = format_temperature(weather['current_condition'][0]['temp_C'])
    current_temp_feels_like = format_temperature(weather['current_condition'][0]['FeelsLikeC'])
    current_wind_speed = format_wind_speed(weather['current_condition'][0]['windspeedKmph'])
    current_wind_direction = format_wind_direction(weather['current_condition'][0]['winddir16Point'])
    current_humidity = format_humidity(weather['current_condition'][0]['humidity'])

    data['tooltip'] = f"<b>{current_weather_condition} {current_temp}</b>\n"
    data['tooltip'] += f"Feels like: {current_temp_feels_like}\n"
    data['tooltip'] += f"Wind: {current_wind_speed} {current_wind_direction}\n"
    data['tooltip'] += f"Humidity: {current_humidity}\n"

    # Weather for next days
    for day in weather['weather']:
        day_date = day['date']
        day_parsed_date = parse_date(day_date)
        day_is_too_old = day_parsed_date < now.replace(hour=0, minute=0, second=0, microsecond=0)

        if day_is_too_old:
            continue

        day_of_month = day_parsed_date.day
        day_is_today = day_of_month == now.day
        day_is_tomorrow = day_of_month == (now + timedelta(days=1)).day

        data['tooltip'] += f"\n<b>"
        if day_is_today:
            data['tooltip'] += "Today, "
        if day_is_tomorrow:
            data['tooltip'] += "Tomorrow, "

        day_max_temp = format_max_temp(day['maxtempC'])
        day_min_temp = format_min_temp(day['mintempC'])
        day_sunrise = format_sunrise(day['astronomy'][0]['sunrise'])
        day_sunset = format_sunset(day['astronomy'][0]['sunset'])
        day_moon_phase = format_moon_phase(day['astronomy'][0]['moon_phase'], is_southern_hemisphere)
        day_moon_illumination = format_moon_illumination(day['astronomy'][0]['moon_illumination'])
        day_moonrise_unformatted = day['astronomy'][0]['moonrise']
        day_moonset_unformatted = day['astronomy'][0]['moonset']
        day_moonrise = format_moonrise(day_moonrise_unformatted)
        day_moonset = format_moonset(day_moonset_unformatted)
        day_moon = [day_moonrise, day_moonset]

        if day_moonrise is not None and day_moonset is not None:
            def to_minutes(time):
                split = format_time_12_to_24(time).split(":")
                return 60*int(split[0]) + int(split[1])
            if to_minutes(day_moonset_unformatted) < to_minutes(day_moonrise_unformatted):
                day_moon[0], day_moon[1] = day_moon[1], day_moon[0]
        day_moon = [item for item in day_moon if item is not None]

        data['tooltip'] += f"{day_date}</b>\n"

        # https://docs.gtk.org/Pango/pango_markup.html
        data['tooltip'] += '<span allow_breaks="false">'
        data['tooltip'] += f"{day_max_temp} {day_min_temp} "
        data['tooltip'] += f"{day_sunrise} {day_sunset} {day_moon_phase} "
        data['tooltip'] += f"{' '.join(day_moon)} ({day_moon_illumination})"
        if tides is not None:
            day_tides = tides.get(day_of_month)
            if day_tides is not None:
                data['tooltip'] += f" {format_tides(day_tides)}"
        if day_is_today and todays_zenith is not None:
            data['tooltip'] += f" {format_zenith(todays_zenith)}"
        data['tooltip'] += "</span>\n"

        for hour in day['hourly']:
            hour_time = format_time(hour['time'])

            if day_is_today:
                if int(hour_time) < now.hour - 2:
                    continue

            hour_weather_emoji = format_raw_emoji(WEATHER_CODE_TO_EMOJI[hour['weatherCode']])
            hour_temp = format_temperature(hour['tempC'].rjust(2))
            hour_humidity = format_humidity_with_emoji(hour['humidity'].rjust(2))
            hour_wind = format_wind_short(hour['windspeedKmph'].rjust(2), hour['winddir16Point'].ljust(3))
            hour_weather_condition = hour['weatherDesc'][0]['value']
            hour_wind_description = wind_kmph_to_beaufort_description(int(hour['windspeedKmph']))
            hour_chances = format_chances(hour)

            data['tooltip'] += '<span allow_breaks="false">'
            data['tooltip'] += f"{hour_time} {hour_weather_emoji} {hour_temp} {hour_humidity} {hour_wind} "
            data['tooltip'] += f"{hour_weather_condition}, {hour_wind_description}, {hour_chances}"
            data['tooltip'] += "</span>\n"

    data['tooltip'] = data['tooltip'].strip()
    return data

if __name__ == "__main__":
    print(json.dumps(output_json()))
