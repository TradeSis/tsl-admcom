/* #1 - 02.06.2017 - Voltou a testar pela acha do titobs[1] se é parcial */
/* #2 - 20.04.18 - Helio - Resumo por Caixa para Identificar diferencas */
/* #3 - 29.11.18 - Helio Neto - Alteracoes para Igualar Informacoes as do P2K */
/* #4 - 26.12.18 - Helio neto - Alteracoes em AGENDA */

{admcab.i}
{setbrw.i}

def var vcatcod like produ.catcod.
                def var vvndbruta as dec.
                def var vvndentrada as dec.
                def var vvndprop as dec.
                def var ventrada as dec.
def buffer btitulo for titulo.

def var vtaxa as dec.
def var vmodal like modal.modcod.
def var vtipocxa as char format "x(6)" column-label "CX".
def var vvlrvenda as dec.
def var vvlrvendatot as dec.

def var vvndrecarga as dec.
def var vvndCP as dec.
def var vvndPEDO as dec.
def var vvndencargos as dec.
def var vvndserv  as dec.
def var vvndgarantia as dec.



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
    field CATCOD    like produ.catcod
    field etbcod    like estab.etbcod       column-label "Loja"
    field tipocxa   like vtipocxa       column-label "Cx"
    field avista    as log format "VIS/PRZ" column-label "Ope"
    field modal     like modal.modcod
    field compra    like titulo.titvlcob    column-label "Tot.Compra" format "->>>>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field prazo    like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vndbruta   like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vndprodu    like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vndencar  like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vndserv  like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    
    field recarga   like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vndCP   like titulo.titvlcob    column-label "Tot. Vista" format "->>>>9.99"
    field vndPEDO  like titulo.titvlcob    column-label "Tot. Vista" format "->>>>9.99"
    field vndENTRADA  like titulo.titvlcob    column-label "Tot. Vista" format "->>>>9.99"
    field vndCARPROP  like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field garantia   like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field vendatot   like titulo.titvlcob    column-label "Tot. Vista" format "->>>>>9.99"
    field cntentrada   like titulo.titvlcob    column-label "Tot.Entrada" format "->>>>9.99"
    field pagentrada   like titulo.titvlcob    column-label "Tot.Entrada" format "->>>>9.99"
    field vlpagopag    like titulo.titvlpag    column-label "Valor Pago" format "->>>>>9.99"
    field vlpagocob    like titulo.titvlpag  format "->>>>>9.99"
    field vlpagocobra    like titulo.titvlpag  format "->>>>>9.99"
    field vlnovcob      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>9.99"
    field vlnovjur      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>9.99"
    field vlnovpag      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>9.99"
    field vlsemnovcob      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>>9.99"
    field vlsemnovjur      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>>9.99"
    field vlsemnovpag      like titulo.titvlpag    column-label "Valor Novacao" format "->>>>>9.99"

    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format "->>,>>>,>>9.99"
    field qtdcont   as   int column-label "Qtd.Cont" format ">>>,>>9"
    field juros     like titulo.titjuro     column-label "Juros"  format "->>>>>9.99"
    field qtdparcial as int      
    field valparcial as dec             
    index i1 catcod asc etbcod asc tipocxa asc avista asc modal asc.

def buffer bwfresumo for wfresumo.

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

create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".


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

                find first btitulo
                     where btitulo.empcod = 19
                       and btitulo.titnat = no
                       and btitulo.modcod = contrato.modcod
                       and btitulo.etbcod = contrato.etbcod
                       and btitulo.clifor = contrato.clicod
                       and btitulo.titnum = string(contrato.contnum)
                       and btitulo.titdtemi = contrato.dtinicial
                       and btitulo.titpar  = 0
                                        no-lock no-error.
                                        
                                              
                if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                
                ventrada = 0.
                
                if avail btitulo
                then ventrada = btitulo.titvlcob.
                /*
                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                */
                                                   
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
                    vtipocxa = "EMI".
                              /*
                              if titulo.tipocxa = ? or titulo.tipocxa = 0
                              then 99
                              else titulo.tipocxa .
                              */
                              
                end.    

                vmodal =  if contrato.modcod = "CP0" or
                             contrato.modcod = "CP1" or
                             contrato.modcod = "CP2"
                          then "CP" 
                          else if titulo.tpcontrato <> ""
                               then titulo.tpcontrato
                               else contrato.modcod.

                find first wfresumo where 
                    wfresumo.catcod  = 0 and
                    wfresumo.etbcod = contrato.etbcod and 
                    wfresumo.tipocxa = vtipocxa and 
                    wfresumo.avista  = no and
                    wfresumo.modal   = vmodal
                    no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign 
                    wfresumo.catcod  = 0.
                    wfresumo.etbcod  = contrato.etbcod.
                    wfresumo.tipocxa = vtipocxa.
                    wfresumo.avista  = no.
                    wfresumo.modal   = vmodal.
                end.    
 
                /**if contrato.banco = 999
                then assign wfresumo.repar   = wfresumo.repar  + contrato.vltotal
                            wfresumo.entrep  = wfresumo.entrep + contrato.vlentra.
                else 
                */
                wfresumo.compra  = wfresumo.compra  + contrato.vltotal.
                wfresumo.cntentrada = wfresumo.cntentrada + ventrada.
                wfresumo.qtdcont = wfresumo.qtdcont + 1.
            end.
            for each plani where 
                        plani.movtdc = 5 and
                        plani.pladat = vdt and
                        plani.etbcod = estab.etbcod no-lock.

                vcatcod = 111. /* Categoria Outros */
                for each movim where
                        movim.etbcod = plani.etbcod and
                        movim.placod = plani.placod
                        no-lock.
                    find produ of movim no-lock.
                    if produ.catcod = 31 or
                       produ.catcod = 41 or
                       produ.catcod = 71 
                    then do:
                        vcatcod = produ.catcod.
                        leave.
                    end.       
                end.
                                    
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if plani.cxacod = ? or plani.cxacod = 0
                              then "EMI"
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
                vvndbruta =   if plani.biss > 0  
                              then plani.biss
                              else plani.platot.
                
                vvndserv  = plani.vlserv.
                 
                   
                vvndrecarga = 0.
                vvndgarantia = 0.
                vvndCP = 0.
                vvndPEDO = 0.
                
                v-produto = yes.
                vtaxa = 0.
                vvndentrada = 0.
                vvndprop = 0.
                
                find first contnf where contnf.etbcod = plani.etbcod and
                            contnf.placod = plani.placod
                            no-lock no-error.
                if avail contnf
                then do:
                    find contrato where contrato.contnum = contnf.contnum
                        no-lock no-error.
                    if avail contrato
                    then do:
                        vtaxa = contrato.vltaxa.
                        
                   find first titulo
                     where titulo.empcod = 19
                       and titulo.titnat = no
                       and titulo.modcod = contrato.modcod
                       and titulo.etbcod = contrato.etbcod
                       and titulo.clifor = contrato.clicod
                       and titulo.titnum = string(contrato.contnum)
                       and titulo.titdtemi = contrato.dtinicial
                       and titulo.titpar   = 0
                                        no-lock no-error.
                                              
                    if avail titulo
                    then do:
                        vvndentrada = titulo.titvlcob.
                    end.
                    end.
                         
                end.                            

                                
                if true /*plani.seguro > 0*/
                then do:
                    
                    /*vvlrvenda  = vvlrvenda - plani.garantia.*/
                    vvndgarantia = 0.
                    
                    for each vndseguro where
                            vndseguro.etbcod = plani.etbcod and
                            vndseguro.placod = plani.placod and
                            vndseguro.tpseguro = 5
                             no-lock.
                            vvndgarantia = vvndgarantia + vndseguro.prseguro.
                    end.           
                    for each vndseguro where
                            vndseguro.etbcod = plani.etbcod and
                            vndseguro.placod = plani.placod and
                            vndseguro.tpseguro = 6
                             no-lock.
                            vvndgarantia = vvndgarantia + vndseguro.prseguro.
                    end.           
                    
                    v-produto = yes. 
                end.    
                vvlrvenda    =  plani.platot - vtaxa - vvndgarantia.
                
                vvndencargos =  vvndbruta - plani.platot + vtaxa.
                        
                if avail contrato
                then vvndprop = vvlrvenda - vvndentrada.
                
                if plani.vencod = 150
                then do:
                    v-produto = no.
                    vvndrecarga = vvlrvenda.
                    vvlrvenda = 0.
                end.    

                vmodal = if plani.modcod begins "CP"
                         then "CP"
                         else if plani.serie = "PEDO"
                              then "PED"
                              else "VEN". 
                if vmodal = "PED"
                then do:
                    vvndPEDO    = vvlrvenda.
                    vvlrvenda   = 0.
                end.
                if vmodal = "CP"
                then do:
                    vvndCP    = vvlrvenda.
                    vvlrvenda   = 0.
                end.
                
                                                  
                                  
                                  
                    find first wfresumo where 
                            wfresumo.catcod = vcatcod and
                            wfresumo.etbcod = plani.etbcod 
                        and wfresumo.tipocxa = vtipocxa    
                        and wfresumo.avista = (plani.crecod = 1)
                        and wfresumo.modal  = "VEN"
                            no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        wfresumo.catcod  = vcatcod.
                        wfresumo.etbcod = plani.etbcod.
                        wfresumo.tipocxa = vtipocxa.
                        wfresumo.avista = (plani.crecod = 1).
                        wfresumo.modal = "VEN".
                    end.    
                    /*if v-produto
                    then*/
                     do:
                    wfresumo.vndentrada = wfresumo.vndentrada + vvndentrada.
                    wfresumo.vndcarprop = wfresumo.vndcarprop + vvndprop.
                    
                    
                    wfresumo.vndbruta = wfresumo.vndbruta + vvndbruta.

                    wfresumo.vndencar = wfresumo.vndencar + vvndencargos.
                    wfresumo.vndserv  = wfresumo.vndserv  + vvndserv.

                    wfresumo.vndprodu = wfresumo.vndprodu + vvlrvenda.
                    wfresumo.vndCP    = wfresumo.vndCP + vvndCP.
                    wfresumo.vndPEDO  = wfresumo.vndPEDO + vvndPEDO.
                       
                    /*end.
                    else do:                                      
                    */
                    wfresumo.recarga    = wfresumo.recarga + vvndrecarga.
                    
                    wfresumo.garantia    = wfresumo.garantia + vvndgarantia.
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
                     
                    /* wfresumo.produtosvis = wfresumo.produtosvis - vvalor-cartpre. */
                    
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
                            wfresumo.catcod = vcatcod and    
                            wfresumo.etbcod = plani.etbcod and
                            wfresumo.tipocxa = vtipocxa and
                            wfresumo.avista  = (plani.crecod = 1)
                            no-error.
                        if not avail wfresumo
                        then do:
                            create wfresumo.
                            wfresumo.catcod = vcatcod.
                            wfresumo.etbcod = estab.etbcod.
                            wfresumo.tipocxa = vtipocxa.
                            wfresumo.avista  = (plani.crecod = 1).
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

                /*
                if v-consulta-parcelas-LP = no
                   and v-parcela-lp = yes
                then next.
                */
                                        
                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                /*
                if titulo.modcod <> "CRE"
                then next.

                {filtro-feiraonl.i}
                */
                
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if titulo.cxacod = ? or titulo.cxacod = 0
                              then "EMI"
                              else if titulo.cxacod >= 30
                                   then "P2K"
                                   else "ADM".
                end.    

                if titulo.titpar = 0
                then do:
                    vmodal = if titulo.modcod begins "CP"
                             then "CP"
                             else titulo.modcod.

                    find first wfresumo where 
                        wfresumo.catcod = 0 and
                                wfresumo.etbcod = estab.etbcod 
                      and wfresumo.tipocxa = vtipocxa          
                      and wfresumo.avista  = (titulo.titpar = 0)
                      and wfresumo.modal  = vmodal
                                no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        wfresumo.catcod = 0.
                        assign wfresumo.etbcod = estab.etbcod.
                        wfresumo.tipocxa = vtipocxa.
                        wfresumo.avista  = (titulo.titpar = 0).
                        wfresumo.modal = vmodal.
                    end.
    
                    if titulo.etbcod   = estab.etbcod 
                    then do:
                        wfresumo.pagentrada = wfresumo.pagentrada + titulo.titvlpag.
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
                    

            
        end.
    end.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/cre02l-" + string(time) + ".txt".
    else varquivo = "..\relat\cre02w." + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "0"
        &Nom-Rel   = """DREB031"""
        &Nom-Sis   = """SISTEMA CREDIARIO HN271218 """
        &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                        string(vdtini)  + "" A "" + string(vdtfin) "
        &Width     = "130"
        &Form      = "frame f-cab"}
    

    for each wfresumo use-index i1
            break by wfresumo.etbcod
                 by wfresumo.tipocxa:
    

        wfresumo.vendatot = wfresumo.vendatot +
                            (wfresumo.vndprodu 
                            -  wfresumo.vndserv 
                            + wfresumo.vndencar 
                            +  wfresumo.recarga 
                            +  wfresumo.garantia 
                            + wfresumo.vndCP 
                            + wfresumo.vndPEDO).
        if wfresumo.avista = yes
        then  wfresumo.vista = wfresumo.vista + (wfresumo.vndprodu + 
                                                 wfresumo.recarga + 
                                                 wfresumo.garantia +
                                                 wfresumo.vndCP +
                                                 wfresumo.vndPEDO +
                                                 wfresumo.vndencar
                                                 - wfresumo.vndserv).
        if wfresumo.avista = no
        then  wfresumo.prazo = wfresumo.prazo + (wfresumo.vndprodu + 
                                                 wfresumo.recarga + 
                                                 wfresumo.garantia +
                                                 wfresumo.vndCP +
                                                 wfresumo.vndPEDO +
                                                 wfresumo.vndencar 
                                                 - wfresumo.vndserv).

        wfresumo.vltotal = wfresumo.vlpagopag +
                           wfresumo.pagentrada +
                           wfresumo.vista .
     end.

    for each wfresumo where wfresumo.tipocxa <> "EMI" and
                           wfresumo.vltotal <> 0
            break by wfresumo.etbcod
                 by wfresumo.tipocxa:
    

                                      
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                /*
                wfresumo.avista
                */
                wfresumo.modal
                
                wfresumo.vlpagocob  column-label "Pagamentos!Cob!(1)"   (total by wfresumo.tipocxa)   
                wfresumo.juros      column-label "Juros!+!(2)"          (TOTAL by wfresumo.tipocxa)
                wfresumo.vlpagopag  column-label "Pagamentos!Cob+Juros!=(3)"   (total by wfresumo.tipocxa)

                wfresumo.pagentrada    column-label "Entradas!(4)"     (total by wfresumo.tipocxa)
                wfresumo.vista      column-label "V. Vista!(5)"     (total by wfresumo.tipocxa)
                wfresumo.vltotal    column-label "TOTAL!(3+4+5)"        (total by wfresumo.tipocxa)

                /**retirado 27.12.18
                **wfresumo.vlpagocobra  column-label "Pagamentos!Cob+Juros!Filial!(1)"   (total by wfresumo.tipocxa)
                **/

                    with frame flin width 130 down no-box.
    end.


  if vetbcod <> 0
  then do:

    
    put unformatted skip(2)
        "Pagamentos (1)"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.vlsemnovpag <> 0 or
                  wfresumo.vlnovpag      <> 0 or
                  wfresumo.vlpagopag      <> 0 or
                  wfresumo.vlpagopag     <> 0 or
                  wfresumo.juros <> 0
                  break by wfresumo.etbcod
                        by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                wfresumo.modal
                wfresumo.vlsemnovcob column-label "Carne!Cob" (total by wfresumo.tipocxa)
                wfresumo.vlsemnovjur column-label "Carne!Juros!+" (total by wfresumo.tipocxa)
                wfresumo.vlsemnovpag column-label "RECCD!Carne!Cob+Juros!=" (total by wfresumo.tipocxa)
                
                wfresumo.vlnovcob     column-label "Novacao!Cob"   (total by wfresumo.tipocxa)
                wfresumo.vlnovjur     column-label "Novacao!Juros!+"   (total by wfresumo.tipocxa)
                wfresumo.vlnovpag     column-label "RECNOVO!Novacao!Cob+Juros!="   (total by wfresumo.tipocxa)
                
                wfresumo.vlpagocob     column-label "Pagamentos!Cob!(1)"   (total by wfresumo.tipocxa)
                wfresumo.juros      column-label "Juros!+!(2)"          (TOTAL by wfresumo.tipocxa)
                wfresumo.vlpagopag  column-label "Pagamentos!Cob+juros!(1+2)="   (total by wfresumo.tipocxa)
                    with frame flin2 width 130 down no-box.
    end.

    put unformatted skip(2)
        "Emissoes (1)"
        skip(1).

    for each wfresumo use-index i1
            where wfresumo.tipocxa = "EMI" or
                  (wfresumo.vndencar <> 0 and
                   wfresumo.avista  = no  and
                   wfresumo.tipocxa = "P2K"):
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        display wfresumo.etbcod     column-label "Etb."
                /*
                wfresumo.tipocxa
                wfresumo.avista
                */
                
                wfresumo.modal
                wfresumo.qtdcont                                (total)
                wfresumo.compra     column-label "Contratos"    (total)
                wfresumo.cntentrada column-label "Entradas" (total)                
                wfresumo.vndencar column-label "Encargos" (total)
                
                wfresumo.compra - wfresumo.cntentrada - wfresumo.vndencar
                    column-label "CTPROP" (total) 
                                
                /*
                wfresumo.entrada    column-label "Entradas!(3)"     (total)
                wfresumo.vista      column-label "V. Vista!(4)"     (total)

                wfresumo.qtdparcial column-label "QtdParcial"   (total)
                wfresumo.valparcial column-label "ValParcial"   (total)
                */
                    with frame flin0 width 130 down no-box.
        
    end.

    put unformatted skip(2)
        "Vendas Moveis"
        skip.

    for each wfresumo use-index i1
            where   wfresumo.catcod = 31 and
                  (wfresumo.vndprodu <> 0 or
                  wfresumo.vndCP <> 0 or
                  wfresumo.vndPEDO <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0)
                   break by wfresumo.etbcod
                         by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display 
                    wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                /*wfresumo.modal
                */
                wfresumo.vndbruta column-label "Vnd!Bruta=" (total by wfresumo.tipocxa)
                wfresumo.vndprodu   column-label "VENPRD!Produtos!"      (total by wfresumo.tipocxa)
                wfresumo.vndCP   column-label "CECP!Cred Pes!"      (total by wfresumo.tipocxa)
                wfresumo.vndPEDO   column-label "VENPN!PED!"      (total by wfresumo.tipocxa)
                
                wfresumo.recarga    column-label "VENCC!Recarga!+"     (total by wfresumo.tipocxa)
                wfresumo.garantia    column-label "VENGR!Garantia/RFQ!+"     (total by wfresumo.tipocxa)

                wfresumo.vndserv column-label "Abate!-" (total by wfresumo.tipocxa)
                
                wfresumo.vndencar column-label "Vnd!Encargos!+" (total by wfresumo.tipocxa)
                wfresumo.vendatot    column-label "Vnd!Total!C/Entrada!="     (total by wfresumo.tipocxa)
                
                wfresumo.vndentrada   column-label "Vlr!Entrada"     (total by wfresumo.tipocxa)
               
                    with frame flin4 width 130 down no-box.
        
        find first bwfresumo where
                    bwfresumo.catcod    = 999 and
                    bwfresumo.etbcod    = wfresumo.etbcod and
                    bwfresumo.tipocxa   = wfresumo.tipocxa and
                    bwfresumo.avista    = wfresumo.avista and
                    bwfresumo.modal     = wfresumo.modal
                    no-error.
        if not avail bwfresumo
        then do:
            create bwfresumo.                     
            bwfresumo.catcod    = 999.
            bwfresumo.etbcod    = wfresumo.etbcod.
            bwfresumo.tipocxa   = wfresumo.tipocxa.
            bwfresumo.avista    = wfresumo.avista.
            bwfresumo.modal     = wfresumo.modal.
        end.
        assign 
            bwfresumo.vndbruta   = bwfresumo.vndbruta   + wfresumo.vndbruta   
            bwfresumo.vndprodu   = bwfresumo.vndprodu   + wfresumo.vndprodu 
            bwfresumo.vndCP      = bwfresumo.vndCP      + wfresumo.vndCP  
            bwfresumo.vndPEDO    = bwfresumo.vndPEDO    + wfresumo.vndPEDO  
            bwfresumo.recarga    = bwfresumo.recarga    + wfresumo.recarga  
            bwfresumo.garantia   = bwfresumo.garantia   + wfresumo.garantia   
            bwfresumo.vndserv    = bwfresumo.vndserv    + wfresumo.vndserv  
            bwfresumo.vndencar   = bwfresumo.vndencar   + wfresumo.vndencar  
            bwfresumo.vendatot   = bwfresumo.vendatot   + wfresumo.vendatot  
            bwfresumo.vndentrada = bwfresumo.vndentrada + wfresumo.vndentrada.
        
    end.


    put unformatted skip(2)
        "Vendas Moda"
        skip.

    for each wfresumo use-index i1
            where   wfresumo.catcod = 41 and
                   (wfresumo.vndprodu <> 0 or
                  wfresumo.vndCP <> 0 or
                  wfresumo.vndPEDO <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0)
                   break by wfresumo.etbcod
                         by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display 
                    wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                /*wfresumo.modal
                */
                wfresumo.vndbruta column-label "Vnd!Bruta=" (total by wfresumo.tipocxa)
                wfresumo.vndprodu   column-label "VENPRD!Produtos!"      (total by wfresumo.tipocxa)
                wfresumo.vndCP   column-label "CECP!Cred Pes!"      (total by wfresumo.tipocxa)
                wfresumo.vndPEDO   column-label "VENPN!PED!"      (total by wfresumo.tipocxa)
                
                wfresumo.recarga    column-label "VENCC!Recarga!+"     (total by wfresumo.tipocxa)
                wfresumo.garantia    column-label "VENGR!Garantia/RFQ!+"     (total by wfresumo.tipocxa)

                wfresumo.vndserv column-label "Abate!-" (total by wfresumo.tipocxa)
                
                wfresumo.vndencar column-label "Vnd!Encargos!+" (total by wfresumo.tipocxa)
                wfresumo.vendatot    column-label "Vnd!Total!C/Entrada!="     (total by wfresumo.tipocxa)
                
                wfresumo.vndentrada   column-label "Vlr!Entrada"     (total by wfresumo.tipocxa)
               
                    with frame flin5 width 130 down no-box.
        find first bwfresumo where
                    bwfresumo.catcod    = 999 and
                    bwfresumo.etbcod    = wfresumo.etbcod and
                    bwfresumo.tipocxa   = wfresumo.tipocxa and
                    bwfresumo.avista    = wfresumo.avista and
                    bwfresumo.modal     = wfresumo.modal
                    no-error.
        if not avail bwfresumo
        then do:
            create bwfresumo.                     
            bwfresumo.catcod    = 999.
            bwfresumo.etbcod    = wfresumo.etbcod.
            bwfresumo.tipocxa   = wfresumo.tipocxa.
            bwfresumo.avista    = wfresumo.avista.
            bwfresumo.modal     = wfresumo.modal.
        end.
        assign 
            bwfresumo.vndbruta   = bwfresumo.vndbruta   + wfresumo.vndbruta   
            bwfresumo.vndprodu   = bwfresumo.vndprodu   + wfresumo.vndprodu 
            bwfresumo.vndCP      = bwfresumo.vndCP      + wfresumo.vndCP  
            bwfresumo.vndPEDO    = bwfresumo.vndPEDO    + wfresumo.vndPEDO  
            bwfresumo.recarga    = bwfresumo.recarga    + wfresumo.recarga  
            bwfresumo.garantia   = bwfresumo.garantia   + wfresumo.garantia   
            bwfresumo.vndserv    = bwfresumo.vndserv    + wfresumo.vndserv  
            bwfresumo.vndencar   = bwfresumo.vndencar   + wfresumo.vndencar  
            bwfresumo.vendatot   = bwfresumo.vendatot   + wfresumo.vendatot  
            bwfresumo.vndentrada = bwfresumo.vndentrada + wfresumo.vndentrada.
                     
    end.

    put unformatted skip(2)
        "Vendas Emprestimos"
        skip.

    for each wfresumo use-index i1
            where   wfresumo.catcod = 71 and
                  (wfresumo.vndprodu <> 0 or
                  wfresumo.vndCP <> 0 or
                  wfresumo.vndPEDO <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0)
                   break by wfresumo.etbcod
                         by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display 
                    wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                /*wfresumo.modal
                */
                wfresumo.vndbruta column-label "Vnd!Bruta=" (total by wfresumo.tipocxa)
                wfresumo.vndprodu   column-label "VENPRD!Produtos!"      (total by wfresumo.tipocxa)
                wfresumo.vndCP   column-label "CECP!Cred Pes!"      (total by wfresumo.tipocxa)
                wfresumo.vndPEDO   column-label "VENPN!PED!"      (total by wfresumo.tipocxa)
                
                wfresumo.recarga    column-label "VENCC!Recarga!+"     (total by wfresumo.tipocxa)
                wfresumo.garantia    column-label "VENGR!Garantia/RFQ!+"     (total by wfresumo.tipocxa)

                wfresumo.vndserv column-label "Abate!-" (total by wfresumo.tipocxa)
                
                wfresumo.vndencar column-label "Vnd!Encargos!+" (total by wfresumo.tipocxa)
                wfresumo.vendatot    column-label "Vnd!Total!C/Entrada!="     (total by wfresumo.tipocxa)
                
                wfresumo.vndentrada   column-label "Vlr!Entrada"     (total by wfresumo.tipocxa)
               
                    with frame flin71 width 130 down no-box.
        
        find first bwfresumo where
                    bwfresumo.catcod    = 999 and
                    bwfresumo.etbcod    = wfresumo.etbcod and
                    bwfresumo.tipocxa   = wfresumo.tipocxa and
                    bwfresumo.avista    = wfresumo.avista and
                    bwfresumo.modal     = wfresumo.modal
                    no-error.
        if not avail bwfresumo
        then do:
            create bwfresumo.                     
            bwfresumo.catcod    = 999.
            bwfresumo.etbcod    = wfresumo.etbcod.
            bwfresumo.tipocxa   = wfresumo.tipocxa.
            bwfresumo.avista    = wfresumo.avista.
            bwfresumo.modal     = wfresumo.modal.
        end.
        assign 
            bwfresumo.vndbruta   = bwfresumo.vndbruta   + wfresumo.vndbruta   
            bwfresumo.vndprodu   = bwfresumo.vndprodu   + wfresumo.vndprodu 
            bwfresumo.vndCP      = bwfresumo.vndCP      + wfresumo.vndCP  
            bwfresumo.vndPEDO    = bwfresumo.vndPEDO    + wfresumo.vndPEDO  
            bwfresumo.recarga    = bwfresumo.recarga    + wfresumo.recarga  
            bwfresumo.garantia   = bwfresumo.garantia   + wfresumo.garantia   
            bwfresumo.vndserv    = bwfresumo.vndserv    + wfresumo.vndserv  
            bwfresumo.vndencar   = bwfresumo.vndencar   + wfresumo.vndencar  
            bwfresumo.vendatot   = bwfresumo.vendatot   + wfresumo.vendatot  
            bwfresumo.vndentrada = bwfresumo.vndentrada + wfresumo.vndentrada.
        
    end.


    put unformatted skip(2)
        "Vendas Outras Categorias"
        skip.

    for each wfresumo use-index i1
            where   wfresumo.catcod = 111 and
                  (wfresumo.vndprodu <> 0 or
                  wfresumo.vndCP <> 0 or
                  wfresumo.vndPEDO <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0)
                   break by wfresumo.etbcod
                         by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display 
                    wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                /*wfresumo.modal
                */
                wfresumo.vndbruta column-label "Vnd!Bruta=" (total by wfresumo.tipocxa)
                wfresumo.vndprodu   column-label "VENPRD!Produtos!"      (total by wfresumo.tipocxa)
                wfresumo.vndCP   column-label "CECP!Cred Pes!"      (total by wfresumo.tipocxa)
                wfresumo.vndPEDO   column-label "VENPN!PED!"      (total by wfresumo.tipocxa)
                
                wfresumo.recarga    column-label "VENCC!Recarga!+"     (total by wfresumo.tipocxa)
                wfresumo.garantia    column-label "VENGR!Garantia/RFQ!+"     (total by wfresumo.tipocxa)

                wfresumo.vndserv column-label "Abate!-" (total by wfresumo.tipocxa)
                
                wfresumo.vndencar column-label "Vnd!Encargos!+" (total by wfresumo.tipocxa)
                wfresumo.vendatot    column-label "Vnd!Total!C/Entrada!="     (total by wfresumo.tipocxa)
                
                wfresumo.vndentrada   column-label "Vlr!Entrada"     (total by wfresumo.tipocxa)
               
                    with frame flin111 width 130 down no-box.
        
        find first bwfresumo where
                    bwfresumo.catcod    = 999 and
                    bwfresumo.etbcod    = wfresumo.etbcod and
                    bwfresumo.tipocxa   = wfresumo.tipocxa and
                    bwfresumo.avista    = wfresumo.avista and
                    bwfresumo.modal     = wfresumo.modal
                    no-error.
        if not avail bwfresumo
        then do:
            create bwfresumo.                     
            bwfresumo.catcod    = 999.
            bwfresumo.etbcod    = wfresumo.etbcod.
            bwfresumo.tipocxa   = wfresumo.tipocxa.
            bwfresumo.avista    = wfresumo.avista.
            bwfresumo.modal     = wfresumo.modal.
        end.
        assign 
            bwfresumo.vndbruta   = bwfresumo.vndbruta   + wfresumo.vndbruta   
            bwfresumo.vndprodu   = bwfresumo.vndprodu   + wfresumo.vndprodu 
            bwfresumo.vndCP      = bwfresumo.vndCP      + wfresumo.vndCP  
            bwfresumo.vndPEDO    = bwfresumo.vndPEDO    + wfresumo.vndPEDO  
            bwfresumo.recarga    = bwfresumo.recarga    + wfresumo.recarga  
            bwfresumo.garantia   = bwfresumo.garantia   + wfresumo.garantia   
            bwfresumo.vndserv    = bwfresumo.vndserv    + wfresumo.vndserv  
            bwfresumo.vndencar   = bwfresumo.vndencar   + wfresumo.vndencar  
            bwfresumo.vendatot   = bwfresumo.vendatot   + wfresumo.vendatot  
            bwfresumo.vndentrada = bwfresumo.vndentrada + wfresumo.vndentrada.
        
    end.






    put unformatted skip(2)
        "Vendas TOTAL"
        skip.

    for each wfresumo use-index i1
            where   wfresumo.catcod = 999 and
                  (  wfresumo.vndprodu <> 0 or
                  wfresumo.vndCP <> 0 or
                  wfresumo.vndPEDO <> 0 or
                  wfresumo.recarga  <> 0 or
                  wfresumo.garantia  <> 0 or
                  wfresumo.vendatot  <> 0)
                   break by wfresumo.etbcod
                         by wfresumo.tipocxa:
    
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
                            
        
        display 
                    wfresumo.etbcod     column-label "Etb."
                wfresumo.tipocxa
                wfresumo.avista
                /*wfresumo.modal
                */
                wfresumo.vndbruta column-label "Vnd!Bruta=" (total by wfresumo.tipocxa)
                wfresumo.vndprodu   column-label "VENPRD!Produtos!"      (total by wfresumo.tipocxa)
                wfresumo.vndCP   column-label "CECP!Cred Pes!"      (total by wfresumo.tipocxa)
                wfresumo.vndPEDO   column-label "VENPN!PED!"      (total by wfresumo.tipocxa)
                
                wfresumo.recarga    column-label "VENCC!Recarga!+"     (total by wfresumo.tipocxa)
                wfresumo.garantia    column-label "VENGR!Garantia/RFQ!+"     (total by wfresumo.tipocxa)

                wfresumo.vndserv column-label "Abate!-" (total by wfresumo.tipocxa)
                
                wfresumo.vndencar column-label "Vnd!Encargos!+" (total by wfresumo.tipocxa)
                wfresumo.vendatot    column-label "Vnd!Total!C/Entrada!="     (total by wfresumo.tipocxa)
                
                wfresumo.vndentrada   column-label "Vlr!Entrada"     (total by wfresumo.tipocxa)
               
                    with frame flin6 width 130 down no-box.
    end.




    
  end.
    
    output close.
    hide message no-pause.
    message varquivo.
    pause 2 no-message.
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
            /*
            if titulo.clifor = 1 then next.
            */
            
            /*
            if titulo.moecod = "DEV" then next.
            */
            
            /*if titulo.modcod <> "CRE" then next.*/

            /*
            if titulo.etbcobra <> estab.etbcod
            then next.
            */
            
            /*
            if titulo.cxmdat <> vdata
                and titulo.cxmdat <> titulo.titdtemi
                and titulo.etbcobra <> 992
            then next.
            */
            
            /*
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
            */
            
            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            /*
            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            */
                                        
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
                else val-pago = titulo.titvlpag.
                
                vlpres = titulo.titvlcob.
                
                /* #1 */
                if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                then do:
                    vlpres = titulo.titvlpag.
                    val-pago = titulo.titvlpag.
                end.
                            
                /*
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
                vljuro = 
                    titulo.titvlpag - titulo.titvlcob.
                    /*
                    titulo.titjuro.    
                    */
                    */
                    
            end.
            
            vlnov = 0.
            if titulo.moecod = "NOV"
            then assign vlnov  = titulo.titvlpag .

            qtd-parcial = 0.
            val-parcial = 0.
            
            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then assign
                     qtd-parcial = 1
                     val-parcial = titulo.titvlpag.
             
                if vetbcod = 0 then vtipocxa = "".
                else do:
                    vtipocxa = if titulo.cxacod = ? or titulo.cxacod = 0
                              then "EMI"
                              else if titulo.cxacod >= 30
                                   then "P2K" 
                                   else "ADM".
                end.    

            vmodal = if titulo.modcod begins "CP"
                     then "CP"
                     else titulo.modcod.
                     
            find first wfresumo where 
                    wfresumo.catcod = 0 and
                                wfresumo.etbcod = estab.etbcod 
                and wfresumo.tipocxa = vtipocxa                                
                and wfresumo.modal   = vmodal
                and wfresumo.avista  = (titulo.titpar = 0)
                                no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    wfresumo.catcod = 0.
                    assign wfresumo.etbcod = estab.etbcod.
                    wfresumo.tipocxa = vtipocxa.
                    wfresumo.modal   = vmodal.
                    wfresumo.avista  = titulo.titpar = 0.
                end.
     
                wfresumo.vlpagocob  = wfresumo.vlpagocob + vlpres. /*titulo.titvlcob.  */
                wfresumo.vlpagopag  = wfresumo.vlpagopag + val-pago . /*titulo.titvlpag.*/
                wfresumo.juros      = wfresumo.juros     + 
                                                if val-pago > vlpres
                                                then (val-pago - vlpres)
                                                else 0.
                
                if titulo.moecod = "NOV"
                then do:
                    wfresumo.vlnovcob  = wfresumo.vlnovcob + titulo.titvlcob.  
                    wfresumo.vlnovpag  = wfresumo.vlnovpag + titulo.titvlpag.
                    wfresumo.vlnovjur   = wfresumo.vlnovjur + if titulo.titvlpag > titulo.titvlcob
                                                           then (titulo.titvlpag - titulo.titvlcob)
                                                           else 0.
                end.
                else do:
                    wfresumo.vlsemnovcob  = wfresumo.vlsemnovcob + titulo.titvlcob.  
                    wfresumo.vlsemnovpag  = wfresumo.vlsemnovpag + titulo.titvlpag.
                    wfresumo.vlsemnovjur = wfresumo.vlsemnovjur + if titulo.titvlpag > titulo.titvlcob
                                                           then (titulo.titvlpag - titulo.titvlcob)
                                                           else 0.
                end.
                                
                if titulo.etbcod = titulo.etbcobra
                then wfresumo.vlpagocobra = wfresumo.vlpagocobra + titulo.titvlpag.
                                
                        wfresumo.qtdparcial = wfresumo.qtdparcial
                                                + qtd-parcial.
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







