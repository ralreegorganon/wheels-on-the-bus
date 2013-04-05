# THE WHEELS ON THE BUS

Awful code to scrape transit data on the [Anchorage People Mover website](http://bustracker.muni.org/InfoPoint/) into something useful.

## Use it

    bundle install
    ./wheels.rb > awesome.json

## What's in it

    routes
        id
        name
        stops
            id
            name
            lat
            lng
        geometry
            lat
            lng
        vehicles
            id
            lat
            lng
            status
            last_stop
            direction
    stop_schedules
        stop_id
        departures
            route
            destination
            sdt
            edt

## Other thoughts

The vehicles and stop schedule information are "live" so if you run this code when the buses aren't running you won't get any data. I don't do anything to account for this...the code probably explodes.

This code sucks.

Pull requests welcome.
