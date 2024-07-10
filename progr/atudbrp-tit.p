{/admcom/progr/admcab-batch.i}

def input parameter vlog as char.

disable triggers for load of fin.titulo.
disable triggers for load of findbrp.titulo.

def new shared temp-table tt-titulo like fin.titulo.
 
def temp-table tit-rec
    field rec as recid.
def buffer btit-rec for tit-rec.

def var vdragao as log.
    
def buffer btitulo for fin.titulo.

def var i as int.

def var cont as int.
def var serao as int.
def var vlocado as log.

def var cont-sel as int.
def var cont-atu as int.

output to value(vlog) append.
    put string(time,"HH:MM:SS") " " "atudbrp-tit.p - Ini atu Titulo "
        skip.
output close.

assign
    cont-sel = 0 cont-atu = 0.

def var vcobcod like findbrp.titulo.cobcod.

for each tt-titulo transaction: /* Loja para Matriz */

    cont-sel = cont-sel + 1.
        
    if tt-titulo.modcod <> "CHP"
    then do:
        if tt-titulo.titdtven = ? or
           tt-titulo.titdtemi = ?
        then do:
           delete tt-titulo. 
           next.
        end.    
    end.
    
    find findbrp.titulo where 
             findbrp.titulo.empcod  = tt-titulo.empcod and
             findbrp.titulo.titnat  = tt-titulo.titnat and
             findbrp.titulo.modcod  = tt-titulo.modcod and
             findbrp.titulo.etbcod  = tt-titulo.etbcod and
             findbrp.titulo.clifor  = tt-titulo.clifor and
             findbrp.titulo.titnum  = tt-titulo.titnum and
             findbrp.titulo.titpar  = tt-titulo.titpar  
            exclusive no-wait no-error.
    if not avail findbrp.titulo
    then do:
        if locked findbrp.titulo
        then.
        else do:
            vdragao = no.
            if tt-titulo.titpar >= 50
            then do:
                run cardrag.p(recid(tt-titulo)).
                vdragao = yes.
            end.
            else do:
                create findbrp.titulo.
                {tt-titulo.i findbrp.titulo tt-titulo}.
            end.
        end.
    end.
    else do:
        if findbrp.titulo.modcod <> "CHP"
        then do:
            if findbrp.titulo.titsit <> "PAG"
            then do:
                vcobcod = findbrp.titulo.cobcod.
                {tt-titulo.i findbrp.titulo tt-titulo}.
                if vcobcod <> 2
                then findbrp.titulo.cobcod = vcobcod.
                    
                if findbrp.titulo.etbcod = setbcod
                then findbrp.titulo.exportado = yes.
                else findbrp.titulo.exportado = no.
                    pause 0.
                    
                if tt-titulo.titpar >= 50
                then do:
                    find first d.titulo where 
                                   d.titulo.empcod = tt-titulo.empcod
                                and d.titulo.titnat = tt-titulo.titnat
                                and d.titulo.modcod = tt-titulo.modcod
                                and d.titulo.etbcod = tt-titulo.etbcod
                                and d.titulo.clifor = tt-titulo.clifor
                                and d.titulo.titnum = tt-titulo.titnum
                                and d.titulo.titpar = tt-titulo.titpar
                                no-error.
                    if avail d.titulo
                    then do:
                        if d.titulo.titsit <> "PAG" 
                        then do:
                            {tt-titulo.i d.titulo tt-titulo}.
                        end.
                    end.
                end.
            end.
        end.
        else do:
            if findbrp.titulo.titsit <> "PAG"
            then do:

                if findbrp.titulo.titdtven = ?
                then ASSIGN findbrp.titulo.titdtven  = tt-titulo.titdtven.

                if findbrp.titulo.titvlcob = 0
                then findbrp.titulo.titvlcob = tt-titulo.titvlcob.

                assign       
                           findbrp.titulo.titdtdes  = tt-titulo.titdtdes
                           findbrp.titulo.titvldes  = tt-titulo.titvldes
                           findbrp.titulo.titvljur  = tt-titulo.titvljur
                           /*findbrp.titulo.cobcod    = tt-titulo.cobcod*/
                           findbrp.titulo.bancod    = tt-titulo.bancod
                           findbrp.titulo.agecod    = tt-titulo.agecod
                           findbrp.titulo.titdtpag  = tt-titulo.titdtpag
                           findbrp.titulo.titdesc   = tt-titulo.titdesc
                           findbrp.titulo.titjuro   = tt-titulo.titjuro
                           findbrp.titulo.titvlpag  = tt-titulo.titvlpag.

                    ASSIGN  findbrp.titulo.titbanpag = tt-titulo.titbanpag
                            findbrp.titulo.titagepag = tt-titulo.titagepag
                            findbrp.titulo.titchepag = tt-titulo.titchepag.
                            
                    if findbrp.titulo.titobs[1] = ""
                    then findbrp.titulo.titobs[1] = tt-titulo.titobs[1].

                    if findbrp.titulo.titobs[2] = ""
                    then findbrp.titulo.titobs[2] = tt-titulo.titobs[2].

                    assign        
                            findbrp.titulo.titsit    = tt-titulo.titsit
                            findbrp.titulo.titnumger = tt-titulo.titnumger
                            findbrp.titulo.titparger = tt-titulo.titparger
                            findbrp.titulo.cxacod    = tt-titulo.cxacod
                            findbrp.titulo.evecod    = tt-titulo.evecod
                            findbrp.titulo.cxmdata   = tt-titulo.cxmdata
                            findbrp.titulo.cxmhora   = tt-titulo.cxmhora
                            findbrp.titulo.vencod    = tt-titulo.vencod
                            findbrp.titulo.etbCobra  = tt-titulo.etbCobra
                            findbrp.titulo.datexp    = tt-titulo.datexp
                            findbrp.titulo.moecod    = tt-titulo.moecod
                            
                            findbrp.titulo.exportado = yes.
                    
                    pause 0.
            end.
        end.
    end.        
    if avail findbrp.titulo
    then do : 

        if findbrp.titulo.etbcod = setbcod
        then findbrp.titulo.exportado = yes.
        else findbrp.titulo.exportado = no.
            
        if findbrp.titulo.modcod = "CHP"
        then findbrp.titulo.exportado = yes.
            
    end.
    
    delete tt-titulo.
    cont-atu = cont-atu + 1.
    
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") " " "atudbrp-tit.p - FIM atu Titulo " 
        "(" cont-sel ")-(" cont-atu  ")"  skip
        .
output close. 
        
assign cont-sel = 0 cont-atu = 0.





