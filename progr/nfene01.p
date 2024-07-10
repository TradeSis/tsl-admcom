{admcab.i}
def input  parameter vetbcod like estab.etbcod.
def input  parameter vtot    like com.plani.platot.
def input  parameter vdtf    like com.plani.pladat.
def output parameter vrec    as recid.
def output parameter vnum    like com.plani.numero.
def var vnumero              like com.plani.numero.
def buffer bplani for comloja.plani.
disable triggers for load of comloja.plani.
disable triggers for load of com.plani.
find comloja.tipmov where comloja.tipmov.movtdc = 11 no-lock no-error.
if not avail comloja.tipmov
then do:
    message "Tipo de movimento nao cadastrado na filial".
    pause.
    return.
end.    

vnumero = 0.
do transaction:
    for each comloja.tipmov no-lock:
        find last comloja.plani use-index nota
                  where comloja.plani.movtdc = comloja.tipmov.movtdc and
                        comloja.plani.etbcod = vetbcod               and
                        comloja.plani.emite  = vetbcod               and
                        comloja.plani.serie  = "U" exclusive-lock no-error.
        if not avail comloja.plani
        then next.
        if vnumero < comloja.plani.numero
        then vnumero = comloja.plani.numero.
    end. 

    if vnumero = 0
    then vnumero = 1.
    else vnumero = vnumero + 1.


    create comloja.plani.
    assign comloja.plani.etbcod = vetbcod
           comloja.plani.placod = int(string("210") + 
                                  string(vnumero,"9999999"))
           comloja.plani.movtdc = 11
           comloja.plani.serie  = "U"
           comloja.plani.numero = vnumero
           comloja.plani.emite  = vetbcod 
           comloja.plani.desti  = vetbcod
           comloja.plani.pladat = today
           comloja.plani.datexp = vdtf
           comloja.plani.dtinclu = today
           comloja.plani.modcod  = "DUP"
           comloja.plani.horincl = time
           comloja.plani.hiccod  = 1949
           comloja.plani.icms    = (0.50 * (0.30 * vtot))
           comloja.plani.notobs[1] = "".


    create com.plani.
    assign com.plani.etbcod = vetbcod
           com.plani.placod = int(string("210") + 
                                  string(vnumero,"9999999"))
           com.plani.movtdc = 11
           com.plani.serie  = "U"
           com.plani.numero = vnumero
           com.plani.emite  = vetbcod 
           com.plani.desti  = vetbcod
           com.plani.pladat = today
           com.plani.datexp = vdtf
           com.plani.dtinclu = today
           com.plani.modcod  = "DUP"
           com.plani.horincl = time
           com.plani.hiccod  = 1949
           com.plani.icms    = (0.50 * (0.30 * vtot))
           com.plani.notobs[1] = ""
           com.plani.notobs[3] = string(vtot).



    vrec = recid(com.plani).
    vnum = com.plani.numero.
    
end.

                           
                

    
     