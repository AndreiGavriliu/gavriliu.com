+++
title = "Waste Collection Schedule in HomeAssistant"
date = "2025-03-14T22:19:55+01:00"
#dateFormat = "2006-01-02" # This value can be configured for per-post date formatting
author = ""
authorTwitter = "" #do not include @
cover = ""
tags = ["homeassistant", "waste-collection"]
keywords = ["", ""]
description = ""
showFullContent = false
readingTime = false
hideComments = false
+++

Sometimes, I *totally* forget to take out the garbage bins. And around here, the rule is simple: if your bins aren’t on the sidewalk, the garbage truck just cruises by like a VIP limo ignoring peasants.

When we first moved in, I forgot to take out the recycling bags (Gelber Sack) three times in a row. This resulted in a majestic mountain of 25 bags filled with plastic, empty cat food cans, and my dignity.

To avoid turning my house into a landfill, I’m using the [Waste Collection Schedule](https://github.com/mampfes/hacs_waste_collection_schedule) via [HACS](https://hacs.xyz/). Since I like keeping my data and my trash collection local, I downloaded the ICS file from the city’s waste management service and share it through a [filebrowser](https://github.com/filebrowser/filebrowser) container so Home Assistant can grab it.

Now, I have three trusty `sensor` entities keeping me on track:
* `sensor.restabfall`
* `sensor.gelber_sack`
* `sensor.papier`

## configuration.yaml

```yaml
waste_collection_schedule:
  sources:
    - name: ics
      args:
        url: !secret waste_collection_ics_url
        offset: 0
      calendar_title: Waste Collection
```

## sensors.yaml

```yaml
- platform: waste_collection_schedule
  name: Restabfall
  value_template: "{% if value.daysTo == 0 %}Today{% elif value.daysTo == 1 %}Tomorrow{% else %}in {{value.daysTo}} days{% endif %}"
  types:
    - Restabfall
- platform: waste_collection_schedule
  name: Gelber Sack
  value_template: "{% if value.daysTo == 0 %}Today{% elif value.daysTo == 1 %}Tomorrow{% else %}in {{value.daysTo}} days{% endif %}"
  types:
    - Gelber Sack
- platform: waste_collection_schedule
  name: Papier
  value_template: "{% if value.daysTo == 0 %}Today{% elif value.daysTo == 1 %}Tomorrow{% else %}in {{value.daysTo}} days{% endif %}"
  types:
    - Papier
```

## Cards

Armed with the mystical powers of [card-mod](https://github.com/thomasloven/lovelace-card-mod), the sorcery of [mushroom-entity-card](https://github.com/piitaya/lovelace-mushroom), and the sheer chaos of a well-placed grid, I conjured up the following magical creation:

```yaml
square: false
columns: 3
type: grid
cards:
  - type: custom:mushroom-entity-card
    entity: sensor.restabfall
    tap_action:
      action: none
    hold_action:
      action: none
    double_tap_action:
      action: none
    icon_type: none
    fill_container: false
    layout: vertical
    card_mod:
      style: |
        ha-card { 
          background-color:
            {% if is_state('sensor.restabfall', 'in 2 days') %}
              #FFE4B5
            {% elif is_state('sensor.restabfall', 'Tomorrow') %}
              #FA8072
            {% else %}
              #FFFFFF
            {% endif %}
        }
  - type: custom:mushroom-entity-card
    entity: sensor.gelber_sack
    tap_action:
      action: none
    icon_type: none
    layout: vertical
    hold_action:
      action: none
    double_tap_action:
      action: none
    card_mod:
      style: |
        ha-card { 
          background-color:
            {% if is_state('sensor.gelber_sack', 'in 2 days') %}
              #FFE4B5
            {% elif is_state('sensor.gelber_sack', 'Tomorrow') %}
              #FA8072
            {% else %}
              #FFFFFF
            {% endif %}
        }
  - type: custom:mushroom-entity-card
    entity: sensor.papier
    tap_action:
      action: none
    icon_type: none
    layout: vertical
    hold_action:
      action: none
    double_tap_action:
      action: none
    card_mod:
      style: |
        ha-card { 
          background-color:
            {% if is_state('sensor.papier', 'in 2 days') %}
              #FFE4B5
            {% elif is_state('sensor.papier', 'Tomorrow') %}
              #FA8072
            {% else %}
              #FFFFFF
            {% endif %}
        }
grid_options:
  columns: 12
  rows: auto
```
