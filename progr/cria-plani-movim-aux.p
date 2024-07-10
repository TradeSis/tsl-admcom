{admcab.i new}

def var vnumero    as integer.
def var vetbcod    as integer.
def var vdata      as date.
def var vmovtdc    as integer.

form
    vetbcod format ">>>>>>9"      label ""     skip
    vnumero format ">>>>>>>>>>9"      skip
    vdata format "99/99/9999"         skip
    vmovtdc format ">>>>>9" with frame f01 side-labels.


update vmovtdc with frame f01.







