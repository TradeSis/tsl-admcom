def input parameter par-caixa as int.


def buffer bpdvmov for pdvmov.
def var vseq as int.                                                            
def shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod    
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.

def  shared temp-table tt-titdev
    field marca as char format "x(1)"
    field empcod like titulo.empcod
    field titnat like titulo.titnat
    field modcod like titulo.modcod
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titsit   like titulo.titsit
    field titdtemi like titulo.titdtemi
    field tipdev     as   char
    index i-tit is primary unique empcod 
                                  titnat 
                                  modcod 
                                  etbcod 
                                  clifor 
                                  titnum 
                                  titpar.


find first tt-titdev.
find first tt-devolver.

    
    find cmon where
                cmon.etbcod = tt-devolver.etbcod and 
                cmon.cxacod = par-caixa
                no-lock no-error. 
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = tt-devolver.etbcod
            cmon.cxacod = par-caixa
            cmon.cmocod = int(string(cmon.etbcod) + 
                              string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.

    find first plani where plani.etbcod = tt-devolver.etbcod and
                           plani.placod = tt-devolver.placod
                            no-lock.

    find first pdvdoc where pdvdoc.etbcod = plani.etbcod and
                            pdvdoc.placod = plani.placod
        no-lock no-error.
    
    if not avail pdvdoc
    then do:

        find last bpdvmov where
                bpdvmov.etbcod = cmon.etbcod and
                bpdvmov.cmocod = cmon.cmocod and
                bpdvmov.datamov = plani.pladat 
                no-lock no-error.
        vseq = if avail bpdvmov 
               then bpdvmov.sequencia + 1
               else 1.
                       
        create pdvmov.
        
        pdvmov.cmocod   = cmon.cmocod.
        pdvmov.codigo_operador = "100".
        pdvmov.COO      = plani.numero.
        pdvmov.ctmcod   = "10".
        pdvmov.DataMov  = plani.pladat.
        pdvmov.DtIncl   = plani.pladat.
        pdvmov.entsai   = yes.
        pdvmov.etbcod   = cmon.etbcod.
        pdvmov.HoraMov  = time.
        pdvmov.HrIncl   = time.
        pdvmov.Sequencia = vseq.
        pdvmov.statusoper = "FEC".
        pdvmov.ValorTot   = plani.platot.
        pdvmov.ValorTroco = 0.
        
        
        create pdvdoc.
        pdvdoc.etbcod = pdvmov.etbcod.
        pdvdoc.cmocod = pdvmov.cmocod.
        pdvdoc.DataMov = pdvmov.datamov.
        pdvdoc.Sequencia = pdvmov.sequencia.
        pdvdoc.ctmcod = pdvmov.ctmcod.
        pdvdoc.COO = pdvmov.coo.
        pdvdoc.seqreg = 1.
        pdvdoc.placod = plani.placod.
        pdvdoc.serie_nfe = plani.serie.
        pdvdoc.tipo_venda = 1.
        pdvdoc.Valor = plani.platot.
        
        pdvdoc.clifor = plani.desti.
            
end.    

