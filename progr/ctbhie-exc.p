{admcab.i}

def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vano    as int format "9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
repeat:

    update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f-etb centered color blue/cyan side-labels
                    width 80.
        
    if vetbi = 0 or vetbf = 0 or
       vetbi > vetbf
    then undo.

    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.
    
    find first ctbhie where
               ctbhie.etbcod >= vetbi and
               ctbhie.etbcod <= vetbf and
               ctbhie.ctbmes = vmes and
               ctbhie.ctbano = vano
               no-lock no-error.
    if not avail ctbhie
    then do:
        bell.
        message color red/with
         "Inventario não encontrado." 
         view-as alert-box
         .
        undo. 
    end. 
    
    message "Confirma excluir registros ?" update sresp.
    if not sresp
    then next.
    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf
                         no-lock:
        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                              ctbhie.ctbmes = vmes         and
                              ctbhie.ctbano = vano:
            disp estab.etbcod
                 ctbhie.procod with frame f2 side-label centered.
            pause 0.
            delete ctbhie.
        end.            
    end.
    message color red/with
    "Registros excluidos da base de saldo."
    view-as alert-box. 
    leave.
end.         
   
