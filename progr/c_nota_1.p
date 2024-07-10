def var vetbcod             as integer.
def var vnumero             as integer.
def var vmovtdc             as integer.
def var vpladat             as date.

def var vprocod             as integer.

def temp-table tt-nota
    field etbcod      as integer
    field numero      as integer
    field pladat      as date
    field movtdc      as integer
    field procod      as integer.


repeat on error undo, leave:

    create tt-nota.
    update tt-nota.etbcod format ">>>9" label "Filial"
           tt-nota.numero format ">>>>>>9"  label "Nota"
           tt-nota.pladat format "99/99/9999" label "Data"
           tt-nota.movtdc format ">>>>9"    label "Tipo de movconento"
           tt-nota.procod format ">>>>>>>>>9"  label "Produto"
                        with frame f01 .
end.

if not can-find (tt-nota where tt-nota.etbcod > 0)
then do:
    message "Nenhuma Nota será criada..." view-as alert-box.
    undo, return.                      
end.

for each tt-nota no-lock.

    create placon.

    assign placon.numero = tt-nota.numero.

    assign placon.etbcod = tt-nota.etbcod
           placon.emite =  tt-nota.etbcod
           placon.movtdc = tt-nota.movtdc
           placon.serie = "1"
           placon.placod = integer("55" + string(tt-nota.numero,"9999999"))
           placon.pladat = tt-nota.pladat.
       
    create movcon.
                          
    assign movcon.etbcod = placon.etbcod
           movcon.placod = placon.placod                    
           movcon.movdat = placon.pladat
           movcon.movtdc = placon.movtdc
           movcon.procod = tt-nota.procod.

end.

