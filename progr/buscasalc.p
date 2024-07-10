{admcab.i}

def var vpago like fin.titulo.titvlpag.
def var vdesc like fin.titulo.titvlpag.
def var vjuro like fin.titulo.titvlpag.
 
def var vtotcomp    like fin.titulo.titvlcob.
def var ventrada    like fin.titulo.titvlcob.
def var vdata       like fin.titulo.titdtemi.

def input parameter vetbcod like estab.etbcod.
def input parameter vdti like fin.titulo.titdtemi.
def input parameter vdtf like fin.titulo.titdtemi.

def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .

def shared temp-table tt-saldo 
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field pra    like plani.platot
    field pre    like plani.platot
    field ent    like plani.platot.

def temp-table tt-tit 
    field empcod like fin.titulo.empcod
    field titnat like fin.titulo.titnat
    field modcod like fin.titulo.modcod
    field etbcod like fin.titulo.etbcod
    field clifor like fin.titulo.clifor
    field titnum like fin.titulo.titnum
    field titpar like fin.titulo.titpar.


    for each tt-tit:
        delete tt-tit.
    end.
    
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock.
    
        
        assign ventrada = 0
               vtotcomp = 0
               vpago = 0
               vdesc = 0
               vjuro = 0.
        
        do vdata = vdti to vdtf:
            
            assign ventrada = 0
                   vtotcomp = 0
                   vpago = 0
                   vdesc = 0
                   vjuro = 0.
        
    


            for each fin.contrato where fin.contrato.etbcod = estab.etbcod and
                                        fin.contrato.dtinicial = vdata .
                assign ventrada = ventrada + contrato.vlentra
                       vtotcomp = vtotcomp + contrato.vltotal .
            end.


            for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                      fin.titulo.titnat = no and
                                      fin.titulo.modcod = "CAR" and
                                      fin.titulo.titdtpag = vdata and
                                      fin.titulo.etbcobra = estab.etbcod
                                            no-lock use-index etbcod:
                if fin.titulo.titpar = 0
                then next.
                if fin.titulo.etbcobra <> estab.etbcod or fin.titulo.clifor = 1
                then next.

                create tt-tit.
                assign tt-tit.empcod = fin.titulo.empcod
                       tt-tit.titnat = fin.titulo.titnat
                       tt-tit.modcod = fin.titulo.modcod
                       tt-tit.etbcod = fin.titulo.etbcod
                       tt-tit.modcod = fin.titulo.modcod
                       tt-tit.clifor = fin.titulo.clifor
                       tt-tit.titnum = fin.titulo.titnum
                       tt-tit.titpar = fin.titulo.titpar.
                
                assign vpago = vpago + fin.titulo.titvlcob
/*                              - fin.titulo.titjuro + fin.titulo.titdesc */
                       vjuro = vjuro + if fin.titulo.titjuro = 
                                          fin.titulo.titdesc
                                       then 0
                                       else fin.titulo.titjuro
                       vdesc = vdesc + if fin.titulo.titjuro = 
                                          fin.titulo.titdesc
                                       then 0
                                       else fin.titulo.titdesc .
        
            end.
        
            for each d.titulo where d.titulo.empcod = wempre.empcod and
                                    d.titulo.titnat = no      and
                                    d.titulo.modcod = "CAR"   and
                                    d.titulo.titdtpag = vdata and
                                    d.titulo.etbcobra = estab.etbcod
                                                no-lock use-index etbcod:
                if d.titulo.titpar = 0
                then next.
                if d.titulo.etbcobra <> estab.etbcod or d.titulo.clifor = 1
                then next.
                find tt-tit where tt-tit.empcod = d.titulo.empcod and
                                  tt-tit.titnat = d.titulo.titnat and
                                  tt-tit.modcod = d.titulo.modcod and
                                  tt-tit.etbcod = d.titulo.etbcod and
                                  tt-tit.clifor = d.titulo.clifor and
                                  tt-tit.titnum = d.titulo.titnum and
                                  tt-tit.titpar = d.titulo.titpar no-error.
                if avail tt-tit
                then next.
                              
            
                assign vpago = vpago + d.titulo.titvlcob /*
                              - d.titulo.titjuro + d.titulo.titdesc */
                       vjuro = vjuro + if d.titulo.titjuro = d.titulo.titdesc
                                       then 0
                                       else d.titulo.titjuro
                       vdesc = vdesc + if d.titulo.titjuro = d.titulo.titdesc
                                       then 0
                                       else d.titulo.titdesc.
            end.
        

                    
            find first tt-saldo where tt-saldo.etbcod = estab.etbcod and
                                      tt-saldo.data   = vdata no-error.
            if not avail tt-saldo
            then do:
            
                create tt-saldo.
                assign tt-saldo.etbcod = estab.etbcod
                       tt-saldo.data   = vdata
                       tt-saldo.pra    = vtotcomp
                       tt-saldo.pre    = vpago
                       tt-saldo.ent    = ventrada.
            
            end.
            

        end.

    end.
