{admcab.i}

def input param par-rec as recid.
def var vclicod like clien.clicod.
def var vcobcod like  cobfil.cobcod.
def var vdias as int.
def var data-ven as date format "99/99/9999".

    find cobdata where recid(cobdata) = par-rec no-lock.
    
    
   
    vclicod = 0.
    update vclicod label "Cliente" colon 15 
                with frame f1 side-label width 80.
    find clien where clien.clicod = vclicod no-lock.
    display clien.clinom no-label with frame f1.
    
    find cobranca where cobranca.clicod = vclicod no-lock no-error.
    if avail cobranca
    then do:
        find cobfil of cobranca no-lock.
        message "Cliente em Cobranca com " cobfil.cobnom "Filial"
            cobfil.etbcod "desde" cobranca.cobgera
            view-as alert-box.
        return.
    end.
    
    data-ven = today.
    
    for each fin.titulo where fin.titulo.empcod = 19    and
                          fin.titulo.titnat = no    and
                          fin.titulo.modcod = "CRE" and
                          fin.titulo.etbcod = setbcod and
                          fin.titulo.clifor = clien.clicod and
                          fin.titulo.titdtpag = ?   no-lock:

        if fin.titulo.titdtven < data-ven
        then data-ven = fin.titulo.titdtven.

            
    end.
    
    if (today - data-ven) < 60 
    then do:
        vclicod = clien.clicod.

        for each titulo where titulo.empcod = 19    and
                          titulo.titnat = no    and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = setbcod and
                          titulo.clifor = clien.clicod and
                          titulo.titdtpag = ?   no-lock:

            if titulo.titdtven < data-ven
            then data-ven = titulo.titdtven.

            
        end.
        if (today - data-ven) < 60 
        then do:
            message "Cliente nao pode entrar em cobranca".
           undo,  retry.
        end.
    end.
             
    
    update vdias label "Dias de Atraso" colon 15 with frame f1.
    message "Deseja Gerar cobranca? " update sresp.
    if sresp
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = setbcod
               cobranca.cobcod  = cobdata.cobcod
               cobranca.clicod  = clien.clicod
               cobranca.cobgera = today
               cobranca.cobatr  = vdias.
        
        if vdias >= 45 and
           vdias <= 90
        then cobranca.cobeta = 1.
        if vdias >= 91 and
           vdias <= 150
        then cobranca.cobeta = 2.
            
        if vdias >= 151
        then cobranca.cobeta = 3.
        find current cobdata exclusive.
        cobdata.cobqtd = cobdata.cobqtd + 1.
    end.
