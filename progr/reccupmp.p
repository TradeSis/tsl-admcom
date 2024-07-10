{admcab.i}
def input parameter p-etbcod like estab.etbcod.
def input parameter p-datmov like mapctb.datmov.
def input parameter p-equipa like tabecf.equipa. 
def input parameter p-serial like tabecf.serie.

def SHARED temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(25)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    .

def shared temp-table tt-plani like plani.

/*
for each tt-plani.
disp tt-plani.movtdc 
     tt-plani.etbcod 
     tt-plani.pladat 
     tt-plani.serie 
     tt-plani.cxacod 
     tt-plani.notped
     .
end.     
*/                                
{setbrw.i}
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .

form    tt-plani.numero format ">>>>>>>>9"
        tt-plani.pladat format "99/99/99" column-label "Data"
        tt-plani.platot format ">>>,>>9.99" column-label "Total"
        tt-plani.movtdc format ">9"       column-label "TM"
        tt-plani.serie  format "x"        column-label "S"
        tt-plani.notped format "x(15)"  column-label "Coo"
        tt-plani.ufemi format "x(25)" column-label "Serial ECF"
        with frame f-linha down width 80.

/*
for each tt-plani.
disp tt-plani.etbcod tt-plani.notped 
tt-plani.ufemi format "x(20)" tt-plani.platot
tt-plani.cxacod.
end.
*/
l1: repeat:
    {sklcls.i
        &file = tt-plani
        &cfield = tt-plani.numero
        &noncharacter = /*
        &ofield = "
            tt-plani.pladat
            tt-plani.platot
            tt-plani.movtdc
            tt-plani.serie
            tt-plani.notped
            tt-plani.ufemi 
            "
        &where = "    
                (tt-plani.movtdc = 5 or tt-plani.movtdc = 45) and
                tt-plani.etbcod = p-etbcod and 
                tt-plani.pladat = p-datmov and 
                (tt-plani.serie = ""V"" or tt-plani.serie = ""V1"") and
                tt-plani.cxacod = p-equipa and
                (tt-plani.notped = """" or
                 tt-plani.ufemi  = """")
                
                "
        &naoexiste1 = " leave l1. "
        &aftselect1 = " update tt-plani.notped with frame f-linha.
                        if substr(string(tt-plani.notped),1,1) = ""C""
                        then tt-plani.ufemi = p-serial.
                        if tt-plani.notsit = yes
                        then tt-plani.notsit = no.
                        update tt-plani.ufemi with frame f-linha.
                         
                        "
        &form = " frame f-linha overlay "
    }
    if keyfunction(lastkey) = "end-error"
    then do:
        sresp = no.
        message "Confirma alteracao?" update sresp.
        if sresp
        then do:
            for each tt-plani where
                     tt-plani.etbcod = p-etbcod and
                     tt-plani.pladat = p-datmov and
                     substr(tt-plani.notped,1,1) = "C":
                find first plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.movtdc = tt-plani.movtdc
                                 no-error.
                if avail plani
                then buffer-copy tt-plani to plani.
            end.                     
        end.
        hide frame f-linha no-pause.
        leave l1.
    end.
end.      
        
