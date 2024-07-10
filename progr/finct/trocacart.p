/* helio 12042023 - ID 155992 Orquestra 465412 - Troca de carteira */
/* 09022023 helio ID 155965 */
/* helio 20122021 - Melhorias contas a receber fase II */

def input param vdestino-cobcod as int.
def input param vdtref as date.
def input param pcontratocompleto  as log.

def input param pcontnum like contrato.contnum.
def input param ptitpar  like titulo.titpar.
def input param pmotivo like ctbtrocart.motivo.

def var psicred as recid.
def buffer bctbtrocart for ctbtrocart.

{/admcom/progr/acha.i}
    def var vtpcontrato as char.
    /****vdtref = date(month(vdtref),01,year(vdtref)). ***/
        

find contrato where contrato.contnum = pcontnum no-lock.


for each titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and 
        titulo.modcod = contrato.modcod and 
        titulo.clifor = contrato.clicod and 
        titulo.titnum = string(pcontnum) and 
        (if ptitpar = ? then true else titulo.titpar = ptitpar)
    no-lock
    by titulo.titpar.
    
    if titulo.modcod <> "CRE" and
       not titulo.modcod begins "CP"
    then next.   
    if titulo.titsit = "LIB"
    then.
    else do:
        if titulo.titsit = "PAG" and pcontratocompleto
        then.
        else next.
    end.    
    if titulo.cobcod = vdestino-cobcod 
    then next.
    
                      if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" and
                       titulo.tpcontrato <> "L"
                    then vtpcontrato = "F".
                    else vtpcontrato = titulo.tpcontrato.


        
    do with frame f2.
        
            run p.
            if vdestino-cobcod = 10 /* financeira */
            then do:
                run finct/sicrecontr_marca.p (input int(titulo.titnum), vdestino-cobcod,
                                              input "TRANSFERE", "TRANSFERIR",
                                              output psicred ).
                
            end.
    end.
end.

procedure p.
do on error undo.

                  
        find current titulo exclusive.

        /* helio 15122021 - Melhorias contas a receber fase II */
        find last bctbtrocart where 
                    bctbtrocart.contnum = int(titulo.contnum) and 
                    bctbtrocart.titpar  = titulo.titpar  and 
                    bctbtrocart.dtrefSAIDA   < vdtref
                     no-lock no-error.

        find first ctbtrocart where 
            ctbtrocart.contnum         = int(titulo.titnum) and
            ctbtrocart.titpar          = titulo.titpar  and
            ctbtrocart.dtrefSAIDA      = vdtref
            exclusive no-error.
        if not avail ctbtrocart
        then do:            
            create  ctbtrocart.
            assign
                ctbtrocart.contnum         = int(titulo.contnum)
                ctbtrocart.titpar          = titulo.titpar
                ctbtrocart.dtrefSAIDA      = vdtref.
                ctbtrocart.trecid          = recid(titulo).
        end.        
        ASSIGN
            ctbtrocart.dtref           = if avail bctbtrocart
                                            then bctbtrocart.dtrefsaida
                                            else titulo.titdtemi
            ctbtrocart.Valor           = titulo.titvlcob
            ctbtrocart.dtinc           = today
            ctbtrocart.hrinc           = time
            ctbtrocart.cobcodSAIDA     = titulo.cobcod
            ctbtrocart.cobcodENTRADA   = vdestino-cobcod
            ctbtrocart.ValorSAIDA      = titulo.titvlcob
            ctbtrocart.operacaoENTRADA = "TROCA"
            ctbtrocart.operacaoSAIDA   = "TROCA".
        /* helio 15122021 - Melhorias contas a receber fase II */

        ctbtrocart.motivo = pmotivo.     /* helio 09022023 - motivo */
        
        titulo.cobcod = vdestino-cobcod.
        
        

end.


end procedure.
