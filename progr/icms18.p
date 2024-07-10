{admcab.i}

if (today >= 12/31/2015 and time > 64800 /* 18h */) or
   today >= 01/01/2016
then
    for each produ where produ.proipiper = 17.
        assign
            produ.proipiper = 18
            produ.datexp    = today.
    end.

