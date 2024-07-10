{admcab.i}
def var totecf like plani.platot.
def var i as i.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var totvis like titold.titvlcob.
def var totpra like titold.titvlcob.
def var totent like titold.titvlcob.
def var totjur like titold.titjuro.
def var totpre like titold.titvlcob.
def new shared var vtotrec  like titulo.titvlcob format "zzz,zzz,zz9.99".
def new shared var vtotjur  like titulo.titvlcob format "zzz,zzz,zz9.99".


def var x as i.
def var vcx as int.
def var vlpres      like plani.platot.
def var vdata       like titold.titdtemi.
def var vpago       like titold.titvlpag.
def var vdesc       like titold.titdesc.
def var vjuro       like titold.titjuro.
def var wpar        as int format ">>9" .
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vtot        like plani.platot.
def var vdtexp      as   date format "99/99/9999".
def var vdtimp      as   date  format "99/99/9999".
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".

def new shared temp-table tt-totais
    field etbcod like estab.etbcod
    field totpra like titulo.titvlcob
    field totent like titulo.titvlcob
    field totpre like titulo.titvlcob
    field totrec like titulo.titvlcob
    field altrec like titulo.titvlcob
    field altjur like titulo.titvlcob
    field totjur like titulo.titvlcob
    field totger like titulo.titvlcob
    field perrec as dec format "->>9.99"
    field perjur as dec format "->>9.99".
    

def stream tela.



output stream tela to terminal.


repeat with 1 down side-label width 80 color blue/white:
    
    for each tt-totais:
        delete tt-totais.
    end.
    
    update vetbi label "Filial" 
           vetbf label "Filial".
    x = 0.

    totvis = 0.
    totpra = 0.
    totjur = 0.
    totpre = 0.
    totent = 0.
    
    vdt1 = today.
    vdt2 = today.
    
    update vdt1 label "Periodo" 
           vdt2 no-label.
        

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        vlpres = 0.
        vljuro = 0.
        vlentr = 0.
        totpra = 0.

        do vdata = vdt1 to vdt2:
            for each titold where titold.etbcobra = estab.etbcod and
                                  titold.titdtpag = vdata        no-lock.
                if titold.clifor = 1
                then next.
                if titold.titnat = yes
                then next.
                if titold.modcod <> "CRE"
                then next.
                find first tt-totais where tt-totais.etbcod = titold.etbcobra
                                                no-error.
                if not avail tt-totais
                then do:
                    
                    create tt-totais.
                    assign tt-totais.etbcod = titold.etbcobra.
                    
                end.
                                                
                
                if titold.etbcod = estab.etbcod and
                   titold.titpar = 0
                then tt-totais.totent = tt-totais.totent + titold.titvlcob.
                else do:
                    assign
                        tt-totais.totpre = tt-totais.totpre + titold.titvlcob
                        tt-totais.totjur = tt-totais.totjur + titold.titjuro.
                        
                end.
            
            end.
            /*
            for each plaold use-index pladat 
                                where plaold.movtdc = 5 and
                                      plaold.etbcod = estab.etbcod and
                                      plaold.pladat = vdata no-lock.

                find first tt-totais where tt-totais.etbcod = plaold.etbcod
                                                no-error.
                if not avail tt-totais
                then do:
                    create tt-totais.
                    assign tt-totais.etbcod = plaold.etbcod.
                end.
                
                assign tt-totais.totpra = tt-totais.totpra + plaold.platot.
                
            end.    
            */
            
        end.
        
        
    end.

    
    vtotrec = 0.
    vtotjur = 0.
    for each tt-totais:
        
        tt-totais.totger = tt-totais.totent + 
                           tt-totais.totpre +
                           tt-totais.totjur.
                           
        tt-totais.totrec = (tt-totais.totent + tt-totais.totpre).
        
        vtotrec = vtotrec + (tt-totais.totent + tt-totais.totpre).
        
        vtotjur = vtotjur + tt-totais.totjur. 
    
    end.                       
    
    for each tt-totais:

        tt-totais.perrec =
                ((tt-totais.totent + tt-totais.totpre) / vtotrec) * 100.
        
        
        tt-totais.perjur = (tt-totais.totjur / vtotjur) * 100.                 
         
    end.
        
    run tt-totais.p(input vdt1,
                    input vdt2).

end.
