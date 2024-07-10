/* #1 - 02.06.2017 - Voltou a testar pela acha do titobs[1] se é parcial */
/* #2 - 20.04.18 - Helio - Resumo por Caixa para Identificar diferencas */

{admcab.i}
{setbrw.i}
def var vtipocxa as char format "x(3)" column-label "CX".
def var vvlrvenda as dec.
def var vvlrrecarga as dec.
def var vvlrrecargavis as dec.
def var vvlrrecargaprz as dec.

def var vvlrgarantia as dec.
def var vvlrgarantiavis as dec.
def var vvlrgarantiaprz as dec.



def var vdt  like plani.pladat.
def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def temp-table tt-cartpre  no-undo
    field seq    as int
    field numero as int
    field valor as dec.

def new shared var vqtdcart       as   int.
def new shared var vconta         as   int.
def new shared var vachatextonum  as char.
def new shared var vachatextoval  as char.
def new shared var vvalor-cartpre as int.

def var vcre as log format "Geral/Facil" initial yes.

def temp-table tt-cli
    field clicod like clien.clicod.

def temp-table wfresumo no-undo
    field etbcod    like estab.etbcod       column-label "Loja"
    field tipocxa   like vtipocxa       column-label "Cx"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format "->>,>>>,>>9.99"
    field repar    like titulo.titvlcob    column-label "Reparc."
                                                  format ">>,>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field prazo    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
                                                  
    field produtos    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field produtosvis   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field produtosprz   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"

    field recarga   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field recargavis   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field recargaprz   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field garantia   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field garantiavis   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field garantiaprz   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field vendatot   like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->>,>>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format "->>,>>>,>>9.99"
    field entrep    like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format "->>,>>>,>>9.99"
    field vlpago1    like titulo.titvlpag format "->>,>>>,>>9.99"
    field vlnov      like titulo.titvlpag    column-label "Valor Novacao"
                                                  format "->>,>>>,>>9.99"
    field vlpgsemnov      like titulo.titvlpag    column-label "Valor Novacao"
                                                  format "->>,>>>,>>9.99"

    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format "->>,>>>,>>9.99"
    field vlpagocomjuro   like titulo.titvlpag format "->>,>>>,>>9.99"
                                                  
    field qtdcont   as   int column-label "Qtd.Cont" format ">>>,>>9"
    field juros     like titulo.titjuro     column-label "Juros"
                                format "->>,>>>,>>9.99"
    field qtdparcial as int      
    field valparcial as dec             
    index i1 etbcod asc tipocxa asc.

def var vetbcod like estab.etbcod.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.

    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

def var v-produto as log.

repeat with 1 down side-label width 80 row 3:

    update vetbcod label "Filial" colon 25.
    update vcre label "Cliente" colon 25 with side-label.

    update vdtini colon 25
           vdtfin colon 25.
           
    for each tt-modalidade-selec: delete tt-modalidade-selec. end.
           
    update v-relatorio-geral as log format "Sim/Nao" label 
                    "Relatorio GERAL"
                    colon 25.
    if not v-relatorio-geral
    then do:
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label width 80.
              
    if sresp
    then do:
        bl_sel_filiais:
        repeat:
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then leave bl_sel_filiais.
        end.
    end.
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.

    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
        
    display vmod-sel format "x(40)" no-label.

    update v-consulta-parcelas-LP label " Considera apenas LP"
         help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"   ~       colon 25.
    
    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25.
    end.
    else do:
        for each tt-modalidade-padrao:
            create tt-modalidade-selec.
            buffer-copy tt-modalidade-padrao to tt-modalidade-selec.
        end.
        assign vmod-sel = "  ".
        for each tt-modalidade-selec.
            assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
        end.
        
        display vmod-sel format "x(40)" no-label.
    end.
    
    i = 0.
    for each wfresumo. delete wfresumo. end.

    sresp = no.
    message "Confirma relatorio?" update sresp.
    if not sresp then next.
    
    if vcre = no
    then do:
    
        for each tt-cli:
            delete tt-cli.
        end.

        for each clien where clien.classe = 1 no-lock:
    
            display clien.clicod
                    clien.clinom
                    clien.datexp format "99/99/9999" with 1 down. pause 0.
        
            create tt-cli.
            assign tt-cli.clicod = clien.clicod.
        end.
    
    end.
    for each estab no-lock:
        if vetbcod > 0 and
        estab.etbcod <> vetbcod then next.
        do vdt = vdtini to vdtfin:
            for each tt-modalidade-selec,
            
                each contrato where contrato.dtinicial = vdt and
                            contrato.etbcod = estab.etbcod and 
                            contrato.modcod = tt-modalidade-selec.modcod
                            no-lock.
    
                find first titulo
                     where titulo.empcod = 19
                       and titulo.titnat = no
                       and titulo.modcod = contrato.modcod
                       and titulo.etbcod = contrato.etbcod
                       and titulo.clifor = contrato.clicod
                       and titulo.titnum = string(contrato.contnum)
                       and titulo.titdtemi = contrato.dtinicial
                                        no-lock no-error.
                                              
                if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

                i = i  + 1.
                display contrato.dtinicial i
                        with frame f1 no-label 1 down
                            title " Contratos ". pause 0.

                if vcre = no
                then do:
                    find first tt-cli where 
                               tt-cli.clicod = contrato.clicod no-error.
                    if not avail tt-cli
                    then next.
                end.
                
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = "ZZZ".
                              /*
                              if titulo.tipocxa = ? or titulo.tipocxa = 0
                              then 99
                              else titulo.tipocxa .
                              */
                              
                end.    

                find first wfresumo where 
                    wfresumo.etbcod = contrato.etbcod 
                    and wfresumo.tipocxa = vtipocxa
                    no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign wfresumo.etbcod  = contrato.etbcod.
                    wfresumo.tipocxa = vtipocxa.
                end.    
 
                if contrato.banco = 999
                then assign wfresumo.repar   = 
                            wfresumo.repar  + contrato.vltotal
                    wfresumo.entrep  = wfresumo.entrep + contrato.vlentra.
                else wfresumo.compra  = wfresumo.compra  + contrato.vltotal.

                wfresumo.qtdcont = wfresumo.qtdcont + 1.
            end.
            for each plani where 
                        plani.movtdc = 5 and
                        plani.pladat = vdt and
                        plani.etbcod = estab.etbcod no-lock.
            
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if plani.cxacod = ? or plani.cxacod = 0
                              then "ZZZ"
                              else if plani.cxacod >= 30
                                   then "P2K"
                                   else "ADM".
                end.    
            
                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = plani.desti 
                    no-error.
                    if not avail tt-cli
                    then next.
                end.
                vvlrvenda =  (plani.protot /* + plani.frete */
                                + plani.acfprod - plani.descprod) - plani.vlserv.

        
                vvlrrecarga = 0.
                vvlrrecargavis = 0.
                vvlrrecargaprz = 0.
                vvlrgarantia = 0.
                vvlrgarantiavis = 0.
                vvlrgarantiaprz = 0.
                
                v-produto = yes.
                
                if plani.vencod = 150
                then do:
                    v-produto = no.
                    vvlrrecarga = vvlrvenda.
                    if plani.crecod = 1
                    then vvlrrecargavis = vvlrrecarga.
                    else vvlrrecargaprz = vvlrrecarga.
                end.    
                else vvlrrecarga = 0.

                
                if plani.seguro > 0
                then do:
                    v-produto = no.
                    /*vvlrvenda  = vvlrvenda - plani.garantia.*/
                    find first vndseguro where
                            vndseguro.etbcod = plani.etbcod and
                            vndseguro.placod = plani.placod
                             no-lock no-error.
                    if avail vndseguro and
                       vndseguro.tpseguro = 5
                    then do:
                        vvlrgarantia = plani.seguro.
                        if plani.crecod = 1
                        then vvlrgarantiavis = vvlrgarantia.
                        else vvlrgarantiaprz = vvlrgarantia.
                    end.                        
                end.    


                    find first wfresumo where 
                            wfresumo.etbcod = plani.etbcod 
                        and wfresumo.tipocxa = vtipocxa    
                            no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        wfresumo.etbcod = estab.etbcod.
                        wfresumo.tipocxa = vtipocxa.
                    end.    
                    if v-produto
                    then do:
                    wfresumo.produtos = wfresumo.produtos + if vvlrrecarga > 0 
                                                          then 0
                                                          else vvlrvenda.
                    wfresumo.produtosvis = wfresumo.produtosvis + if vvlrrecarga > 0 
                                                          then 0
                                                          else if plani.crecod = 1
                                                               then vvlrvenda
                                                               else 0.
                    wfresumo.produtosprz = wfresumo.produtosprz + if vvlrrecarga > 0 
                                                          then 0
                                                          else if plani.crecod <> 1
                                                               then vvlrvenda
                                                               else 0.
                    end.
                    else do:                                      
                    wfresumo.recarga    = wfresumo.recarga + vvlrrecarga.
                    wfresumo.recargavis = wfresumo.recargavis + vvlrrecargavis.
                    wfresumo.recargaprz = wfresumo.recargaprz + vvlrrecargaprz.
                    
                    wfresumo.garantia    = wfresumo.garantia + vvlrgarantia.
                    wfresumo.garantiavis = wfresumo.garantiavis + vvlrgarantiavis.
                    wfresumo.garantiaprz = wfresumo.garantiaprz + vvlrgarantiaprz.
                    end. 
                
                if plani.crecod = 1
                then do:

                    /**wfresumo.vista = wfresumo.vista + vvlrvenda.**/

                    for each tt-cartpre.
                        delete tt-cartpre.
                    end.    
                    assign vqtdcart = 0
                           vconta   = 0
                           vachatextonum = ""
                           vachatextoval = ""
                           vvalor-cartpre = 0.
                 
                    if plani.notobs[3] <> ""
                    then do:
                        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ? 
                        then vqtdcart =
                             int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
                        if vqtdcart > 0 
                        then do: 
                        
                            do vconta = 1 to vqtdcart:  
                                vachatextonum = "". 
                                vachatextonum = "NUMCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).
        
                                vachatextoval = "". 
                                vachatextoval = "VALCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).

                                if acha(vachatextonum,plani.notobs[3]) <> ? and
                                   acha(vachatextoval,plani.notobs[3]) <> ?
                                then do: 
                                    find tt-cartpre where tt-cartpre.numero = 
                                     int(acha(vachatextonum,plani.notobs[3]))
                                         no-error. 
                                    if not avail tt-cartpre 
                                    then do:  
                                        create tt-cartpre. 
                                        assign tt-cartpre.numero =
                                        int(acha(vachatextonum,plani.notobs[3]))
                                           tt-cartpre.valor  =
                                       dec(acha(vachatextoval,plani.notobs[3])).
                                    end.
                                end.
                            end.
                        end.
                    end.
                    vvalor-cartpre = 0.
                    find first tt-cartpre no-lock no-error.
                    if avail tt-cartpre 
                    then do:
                        for each tt-cartpre.
                            vvalor-cartpre = vvalor-cartpre + tt-cartpre.valor.
                        end.
                    end.
                     
                    wfresumo.produtosvis = wfresumo.produtosvis - vvalor-cartpre.
                    /*vlauxt = vlauxt - vvalor-cartpre.
                    run Pi-Cria-Anali(input "plani", input 2, 
                                       input plani.modcod, input vlauxt,
                                       input 1).
                    vlauxt = 0. */
                 end.
                 else do:
                    
                    if plani.vlserv > 0
                    then do:
                        find first wfresumo where
                            wfresumo.etbcod = plani.etbcod and
                            wfresumo.tipocxa = vtipocxa
                            no-error.
                        if not avail wfresumo
                        then do:
                            create wfresumo.
                            wfresumo.etbcod = estab.etbcod.
                            wfresumo.tipocxa = vtipocxa.
                        end.
                        
                        if (wfresumo.compra - plani.vlserv) > 0
                        then wfresumo.compra = wfresumo.compra - plani.vlserv.
                        else wfresumo.compra = 0.
                        
                        

                    end.
                 end.   
            end.
        
            for each tt-modalidade-selec,
            
                each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdt and 
                                  titulo.modcod = tt-modalidade-selec.modcod
                                   no-lock.
                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                   and v-parcela-lp = yes
                then next.
                                        
                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                
                if titulo.modcod <> "CRE"
                then next.

                {filtro-feiraonl.i}

                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if titulo.cxacod = ? or titulo.cxacod = 0
                              then "ZZZ"
                              else if titulo.cxacod >= 30
                                   then "P2K"
                                   else "ADM".
                end.    

                if titulo.titpar = 0
                then do:
                    find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod 
                      and wfresumo.tipocxa = vtipocxa          
                                no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        assign wfresumo.etbcod = estab.etbcod.
                        wfresumo.tipocxa = vtipocxa.
                    end.
    
                    if titulo.etbcod   = estab.etbcod 
                    then do:
                        wfresumo.entrada = wfresumo.entrada + titulo.titvlpag.
                    end.
                    next.
                end.

                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = titulo.clifor 
                                                                no-error.
                    if not avail tt-cli
                    then next.
                end.

            end.
            
            run pr-pagamento.
                    

            /**
            for each tt-modalidade-selec,
            
                each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = tt-modalidade-selec.modcod and
                                  titulo.titdtpag = vdt and
                                  titulo.etbcod = estab.etbcod no-lock:
                
                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                   and v-parcela-lp = yes
                then next.
                                        
                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                              
                if titulo.titpar = 0
                then next.

                {filtro-feiraonl.i}

                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = titulo.clifor
                                                                no-error.
                    if not avail tt-cli
                    then next.
                end.

                if vetbcod = 0 then vtipocxa = 0.
                else do:
                    vtipocxa = if titulo.tipocxa = ? or titulo.tipocxa = 0
                              then 99
                              else titulo.tipocxa .
                end.    

                find first wfresumo where 
                                    wfresumo.etbcod = estab.etbcod 
                    and wfresumo.tipocxa = vtipocxa                                    
                                    no-error.
                if not avail wfresumo
                then do: 
                    create wfresumo.
                    assign wfresumo.etbcod = estab.etbcod.
                    wfresumo.tipocxa = vtipocxa.
                end.
                
                if titulo.clifor > 1
                then wfresumo.vlpago1  = wfresumo.vlpago1 + titulo.titvlcob.
            end.
            **/
            
        end.
    end.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/cre02l." + string(time).
    else varquivo = "..\relat\cre02w." + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "1200"
        &Page-Line = "0"
        &Nom-Rel   = """DREB031"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                        string(vdtini)  + "" A "" + string(vdtfin) "
        &Width     = "180"
        &Form      = "frame f-cab"}
    
    for each wfresumo use-index i1:
    

        wfresumo.vendatot = wfresumo.vendatot +
                            (wfresumo.produtos + wfresumo.recarga + wfresumo.garantia).
        wfresumo.vista = wfresumo.vista +
                            (wfresumo.produtosvis + wfresumo.recargavis + wfresumo.garantiavis).
        wfresumo.prazo = wfresumo.prazo +
                            (wfresumo.produtosprz + wfresumo.recargaprz + wfresumo.garantiaprz).

        wfresumo.vltotal = wfresumo.vlpago +
                           wfresumo.juros +
                           wfresumo.entrada +
                           wfresumo.vista -
                           wfresumo.entrep.
                            
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.vlpago     column-label "Pagamentos!=!(1)"   (total)
                wfresumo.juros      column-label "Juros!+!(2)"          (TOTAL)
                wfresumo.vlpago1    column-label "Pgto.Orig."   (total)
                
                wfresumo.qtdcont                                (total)
                wfresumo.compra     column-label "Contratos"    (total)
                
                wfresumo.repar      column-label "Reparc."    (total)
                wfresumo.entrada    column-label "Entradas!(3)"     (total)
                
                wfresumo.vista      column-label "V. Vista!(4)"     (total)

                wfresumo.vltotal    column-label "TOTAL!(1+2+3+4)"        (total)
                wfresumo.qtdparcial column-label "QtdParcial"   (total)
                wfresumo.valparcial column-label "ValParcial"   (total)
                    with frame flin width 360 down no-box.
    end.


  if vetbcod <> 0
  then do:
    
    put unformatted skip(2)
        "Pagamentos (1)"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.vlpgsemnov <> 0 or
                  wfresumo.vlnov      <> 0 or
                  wfresumo.vlpago      <> 0 or
                  wfresumo.juros      <> 0 or
                  wfresumo.vlpagocomjuro <> 0:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.vlpgsemnov column-label "Pgto.!Carne" (total)
                wfresumo.vlnov     column-label "Pgto.!Novacao!+"   (total)
                wfresumo.vlpago     column-label "Pagamentos!=!(1)"   (total)
                wfresumo.juros      column-label "Juros!+!(2)"          (TOTAL)
                wfresumo.vlpagocomjuro  column-label "Pgto.Tot!="   (total)
                    with frame flin2 width 360 down no-box.
    end.

    put unformatted skip(2)
        "Vendas"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.produtos <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0 :
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.produtos   column-label "Vnd!Produtos!"      (total)
                wfresumo.recarga    column-label "Vnd!Recarga!+"     (total)
                wfresumo.garantia    column-label "Vnd!Garantia!+"     (total)
                wfresumo.vendatot    column-label "Vnd!Total!="     (total)
               
                    with frame flin4 width 360 down no-box.
    end.


    put unformatted skip(2)
        "V. Prazo"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.produtosprz <> 0 or
                  wfresumo.recargaprz  <> 0 or
                  wfresumo.garantiaprz  <> 0 or
                  wfresumo.prazo       <> 0 :
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa

                wfresumo.produtosprz    column-label "Vnd!Produtos!A Prazo"     (total)
                wfresumo.recargaprz    column-label "Vnd!Recarga!A Prazo"     (total)
                wfresumo.garantiaprz    column-label "Vnd!garantia!A Prazo"     (total)
                wfresumo.prazo    column-label "A Prazo"     (total)
                
                    with frame flin5 width 360 down no-box.
    end.
    
    put unformatted skip(2)
        "V. Vista (4)"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.produtosvis <> 0 or
                  wfresumo.recargavis  <> 0 or
                  wfresumo.garantiavis  <> 0 or
                  wfresumo.vista       <> 0 :
                  
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.produtosvis    column-label "Vnd!Produtos!A Vista"     (total)
                wfresumo.recargavis    column-label "Vnd Recarga!A Vista"     (total)
                wfresumo.garantiavis    column-label "Vnd Garantia!A Vista"     (total)
                wfresumo.vista      column-label "V. Vista!(4)"     (total)
 

                
               
                    with frame flin6 width 360 down no-box.
    end.
    
  end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.

procedure pr-pagamento:
    def var vlpres as dec.
    def var vljuro as dec.
    def var val-pago as dec.
    def var vdata as date.
    def var vljurpre as dec.
    def var vlnov as dec.
    def var qtd-parcial as int init 0.
    def var val-parcial as dec init 0.
    def buffer bmoeda for moeda.
    vdata = vdt.
    for each tt-modalidade-selec,
    
        each titulo where titulo.etbcobra = estab.etbcod and
                          titulo.titdtpag = vdata and
                          titulo.modcod = tt-modalidade-selec.modcod
                          no-lock        .

            if titulo.titnat = yes then next.

            if titulo.titpar = 0 then next.
            if titulo.clifor = 1 then next.
            if titulo.moecod = "DEV" then next.
            /*if titulo.modcod <> "CRE" then next.*/
            if titulo.titnat = yes then next.

            if titulo.etbcobra <> estab.etbcod
            then next.
            
            if titulo.cxmdat <> vdata
                and titulo.cxmdat <> titulo.titdtemi
                and titulo.etbcobra <> 992
            then next.
            
            if titulo.titdtpag = ?
            then next.
            if titulo.titsit = "LIB"
            then next.
            if titulo.titdtpag <> vdata
            then next.
            if titulo.titpar    = 0
            then next.
            if titulo.clifor = 1
            then next.
            if titulo.modcod = "LUZ"
            then next.
            if titulo.modcod = "VVI" or titulo.modcod = "CHQ" or
               titulo.modcod = "CHP" 
            then next.
            if titulo.modcod = "CRE" and titulo.moecod = "DEV" then next.
            
            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
                                        
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            /*if titulo.moecod = "PDM"
            then do:
                for each titpag where
                           titpag.empcod = titulo.empcod and
                           titpag.titnat = titulo.titnat and
                           titpag.modcod = titulo.modcod and
                           titpag.etbcod = titulo.etbcod and
                           titpag.clifor = titulo.clifor and
                           titpag.titnum = titulo.titnum and
                           titpag.titpar = titulo.titpar
                           no-lock:
                    find bmoeda where bmoeda.moecod = titpag.moecod
                                no-lock no-error.
                    if avail bmoeda
                    then do:
                        do:
                            vlpres = vlpres +  titpag.titvlpag.
                            
                        end.
                        if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                    else do:
                        vlpres = vlpres +  titpag.titvlpag.
                        
                        if titpag.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                end.
                vljuro = vljuro + titulo.titjuro.
            end.
            else*/ do:        
                
            vljuro = 0.
            
                if titulo.titvlcob > titulo.titvlpag
                then val-pago = titulo.titvlpag.
                else val-pago = titulo.titvlcob.

                /* #1 */
                if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                then val-pago = titulo.titvlpag.
                else val-pago = titulo.titvlcob.
                
                find bmoeda where 
                    bmoeda.moecod = titulo.moecod no-lock no-error.

                if avail bmoeda
                then do:
           
                    vlpres = vlpres + val-pago.
                    if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.
                else do:
                    vlpres = vlpres + val-pago.
                    if titulo.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.
                vljuro = titulo.titjuro.    
            end.
            
            vlnov = 0.
            if titulo.moecod = "NOV"
            then assign vlnov  = titulo.titvlcob .

            qtd-parcial = 0.
            val-parcial = 0.
            
            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then assign
                     qtd-parcial = 1
                     val-parcial = titulo.titvlpag.
             
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if titulo.cxacod = ? or titulo.cxacod = 0
                              then "ZZZ"
                              else if titulo.cxacod >= 30
                                   then "P2K"
                                   else "ADM".
                end.    

            find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod 
                and wfresumo.tipocxa = vtipocxa                                
                                no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign wfresumo.etbcod = estab.etbcod.
                    wfresumo.tipocxa = vtipocxa.
                end.
     
                wfresumo.vlpago1  = wfresumo.vlpago1 + titulo.titvlcob.
    
                assign 
                        wfresumo.vlpago  = wfresumo.vlpago + val-pago
                        wfresumo.vlnov   = wfresumo.vlnov  + vlnov
                        wfresumo.vlpgsemnov = wfresumo.vlpgsemnov +
                                        (if vlnov > 0 then 0 else val-pago)
                        wfresumo.juros   = wfresumo.juros + vljuro
                        wfresumo.vlpagocomjuro = wfresumo.vlpagocomjuro + (val-pago + vljuro)
                        wfresumo.qtdparcial = wfresumo.qtdparcial
                                                + qtd-parcial
                        wfresumo.valparcial = wfresumo.valparcial 
                                                + val-parcial .
        
        
        end. 
                   
end procedure.


procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.






