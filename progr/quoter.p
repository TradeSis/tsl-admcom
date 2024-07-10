def input parameter par-in   as char.
def output parameter par-out  as char.

def var vcomando   as char.



assign vcomando = "/usr/dlc/bin/quoter " + par-in + " > "
                      + par-in + ".2".

unix silent value(vcomando).

assign par-out = par-in + ".2".

return par-out.
