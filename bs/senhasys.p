    def output parameter senhasys as char.
    if day(today) <= 10
    then senhasys = "1S0" + string(day(today)).
    else if day(today) > 10 and
            day(today) <= 20
        then senhasys = "2C0" + string(day(today)).
        else if day(today)  > 20
            then senhasys = "3B0" + string(day(today)).
