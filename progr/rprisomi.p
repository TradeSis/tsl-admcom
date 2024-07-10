{admcab.i}

def var vnext as log.
def var vl-vend like titulo.titvlcob.
def var vl-ger like titulo.titvlcob.
              
def buffer bplani for plani.
def buffer bmoeda for moeda.

def var tot_premio like plani.platot.
def var tot_premio_ger like plani.platot.

def var qtd-17    as int.
def var qtd-89    as int.
def var qtd-15    as int.
def var qtd-19    as int.
def var qtd-23    as int.

def var premio-89 like plani.platot.
def var premio-17 like plani.platot.
def var premio-15 like plani.platot.
def var premio-23 like plani.platot. 
def var premio-19 like plani.platot.

def temp-table tt-ven
    field vencod like plani.vencod
    field valpre like plani.platot
    field valger like plani.platot
    field mov    like plani.platot
    field con    like plani.platot
    field val89  like plani.platot
    field val17  like plani.platot.
    
def var val_cheque_devolvido   like cheque.cheval.
def var data_cheque_devolvido  like cheque.chepag.
def var caixa_cheque_devolvido like caixa.cxacod.
def var total_cheque_devolvido like cheque.cheval.
def var conta_cheque_devolvido as   int.

disable triggers               for  load of plani.
disable triggers               for  load of movim.
def var totpre      like chq.valor.
def var totdia      like chq.valor.
def var totban      like depban.valdep.
def var vetbcod     like estab.etbcod.
def var vlnov       like plani.platot.
def var ct-nov      as int.
def var varquivo    as char.
def var vok         as log.

def var vdeposito   like plani.seguro.  /** plani.seguro    **/
def var vchedia     like plani.platot.  /** plani.iss       **/
def var vpredre     like plani.platot.  /** plani.notpis    **/
def var vpag        like plani.platot.  /** plani.notcofins **/
def var totglo      like plani.platot.
def var gloqtd      like globa.gloval.
def var vlpres      like plani.platot.
def var vlpagcartao like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".

def var vdata1       like titulo.titdtemi.
def var vdata2       like titulo.titdtemi.

def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var vl-pagar like titluc.titvlpag.
def var qtd-pagar as int.

def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var qtd-cart as int.
def var vl-cart like plani.platot.

def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vldev       like plani.platot.
def var vdevolucao    like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var vnumtra     like plani.platot.
def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-pagcartao as int.
def var ct-juro     as   int.
def var ct-desc     as   int.
def var ct-dev      as   int.
def var ct-devolucao   as   int.
def var vdtexp      as   date.
def var vdtimp      as   date.
def stream tela.

def workfile wf-atu
    field imp       as date
    field exporta   as date.

def buffer bimporta for importa.
def buffer bexporta for exporta.

def var vcxi as int.


repeat:


    update vetbcod colon 20 
           with 1 down side-label width 80 row 4 color blue/white.

    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao cadastrada.".
        undo.
    end.
    
    display estab.etbnom no-label.
    
    update vdata1 colon 20 label "Data Inicial"
           vdata2 label "Data Final".

        
    /**Promocao som e imagem - Dinheiro na mao do vendedor**/

    vl-pagar = 0.
    qtd-pagar = 0.  
    
    vl-vend = 0. 
    vl-ger = 0.
            
    for each tt-ven: delete tt-ven. end.  
    
    /***for each caixa where caixa.etbcod = estab.etbcod no-lock:  ***/
    
      do vcxi = 1 to 10:
    
        for each plani use-index pladat  
                         where plani.movtdc = 5       
                           and plani.etbcod = estab.etbcod 
                           and plani.pladat >= vdata1
                           and plani.pladat <= vdata2 no-lock:
                           
            if  plani.cxacod = vcxi /***caixa.cxacod***/ and 
               (plani.pedcod = 15 or plani.pedcod = 17 or  
                plani.pedcod = 43 or plani.pedcod = 42) 
            then do:   
                vnext = no. 

                for each movim where movim.etbcod = plani.etbcod 
                                 and movim.placod = plani.placod 
                                 and movim.movtdc = plani.movtdc
                                 and movim.movdat = plani.pladat no-lock:

                    find produ where 
                         produ.procod = movim.procod no-lock no-error.
                    
                    if not avail produ 
                    then next.
                            
                    if produ.clacod >= 131 and 
                       produ.clacod <= 139 
                    then. 
                    else do: 
                        if produ.clacod = 81 
                        then. 
                        else vnext = yes. 
                    end. 
                end.
                
                if vnext then next.

                find first contnf where contnf.etbcod = plani.etbcod 
                                    and contnf.placod = plani.placod 
                                    no-lock no-error. 
                if avail contnf  
                then do: 
                    find last titulo where titulo.empcod = wempre.empcod
                                      and titulo.titnat = no 
                                      and titulo.modcod = "CRE" 
                                      and titulo.etbcod = estab.etbcod
                                      and titulo.clifor = plani.desti
                                      and titulo.titnum = string(contnf.contnum)
                                      no-lock no-error.
                    if avail titulo 
                    then do:

                        vl-pagar = vl-pagar + (titulo.titvlcob * 0.10).
                        qtd-pagar = qtd-pagar + 1. 

                        find first tt-ven where 
                                   tt-ven.vencod = plani.vencod no-error.
                        if not avail tt-ven 
                        then do:
                            create tt-ven.
                            assign tt-ven.vencod = plani.vencod.
                        end.
    
                        tt-ven.valpre = tt-ven.valpre + 
                                            (titulo.titvlcob * 0.10).
                        
                    end.
                end.
            end.
                    
        end.
    end.
    
    find first tt-ven no-error.
    if avail tt-ven
    then do:
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/preven" + string(time).
        else varquivo = "l:\relat\preven" + string(time).

        {mdadmcab.i 
                &Saida = "value(varquivo)"
                &Page-Size = "64" 
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""respla"" 
                &Nom-Sis   = """SISTEMA CREDIARIO""" 
                &Tit-Rel   = """ PROMOCAO SOM E IMAGEM "" +
                             string(estab.etbnom) + "" PERIODO DE "" 
                             + string(vdata1) + "" ATE "" + string(vdata2) "
                &Width     = "80"
                &Form      = "frame f-cabc2"}

                    
        display " PREMIO P/ VENDEDOR " 
                with frame f-premio2 centered.
                
        put skip(1).
        

        tot_premio = 0.        
        tot_premio_ger = 0.
         
        for each tt-ven by tt-ven.vencod:
            

            find func where func.funcod = tt-ven.vencod and
                            func.etbcod = estab.etbcod no-lock no-error.
            
            tot_premio = tot_premio + tt-ven.valpre.
            
            put tt-ven.vencod at 1 "  " 
                func.funnom format "x(20)"
                "     R$"
                tt-ven.valpre
                "      ______________________" skip.
                
        end.                      
        put skip(3).
        
        tot_premio_ger = 0.
        tot_premio_ger = tot_premio * 0.10.
        
        put "PREMIO VEND.   R$" at 20 tot_premio skip(1)
            "PREMIO GERENTE R$" at 20 (tot_premio_ger) skip(1)
            "TOTAL GERAL    R$" at 20 (tot_premio_ger + tot_premio).

        output close. 
        
        if opsys = "UNIX"
        then run visurel.p (input varquivo, input "").
        else {mrod.i}.
    
    end.
end.                       
