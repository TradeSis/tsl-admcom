{admcab.i}

def input parameter p-catcod like produ.catcod.
def output parameter varqsai as char.

def var val-venda-cart as dec.
def var qtd-venda-cart as int.
def var ii as int.
def var vok as log.
def var i as i.
def var varquivo as char format "x(20)".
def var wtotal     like plani.platot.
def var vdata      like plani.pladat.
def var vdtini     like plani.pladat         initial today.
def var vdtfim     like plani.pladat         initial today.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
/**** 
def stream stela. 
*****/
def var v-vencar as dec.
def var vfinnom like finan.finnom.

def temp-table ttcli
    field clicod like plani.desti
    field crecod like contrato.crecod
    field totcli as int
    index i1 clicod crecod.

def temp-table tt-titcar like titulo.
             
def temp-table wplano
             field clicod   like clien.clicod
             field fincod   like finan.fincod
             field contra   as integer
             field valor    as dec format ">>,>>>,>>9.99".
repeat:
    wtotal = 0.
    I = 0.
    for each wplano:
        delete wplano.
        I = I + 1.
        /*****************************************************
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp side-label row 15 centered.
        pause 0.
        *****************************************************/
    end.
    hide frame f-disp no-pause.
    for each ttcli:
        delete ttcli.
        I = I + 1.
        /******************************************************
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp2 side-label row 15 centered.
        pause 0.
        ******************************************************/
    end.
    
    /*********************************************************
    hide frame f-disp2 no-pause.
    update vcatcod label "Departamento"
                    with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.
    update vetbi colon 13 label "Filial"
           vetbf label "Filial"
            with frame f1 side-label width 80 color white/cyan.

    update vdtini    label "Data Inicial"
           vdtfim    label "Data Final" with frame f2
                        side-label width 80 color white/cyan.
    **********************************************************/
    assign vdtini = date(month(today - 1), 01, year(today - 1)) 
           vdtfim = date(month(today - 1), day(today - 1) , year(today - 1)).
    
     /**************************************************************
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
***************************************************************/
    find last estab 
            where estab.etbnom begins "DREBES-FIL" no-lock no-error.
    assign vetbf = estab.etbcod.
    
    find first estab 
            where estab.etbnom begins "DREBES-FIL" no-lock no-error.
    assign vetbi = estab.etbcod.
     
    for each estab where estab.etbnom begins "DREBES-FIL" no-lock:

        do vdata = vdtini to vdtfim:

            run titcar.
            
            for each plani where plani.movtdc = 5            and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = vdata no-lock:
                vok = no.
                for each movim where movim.placod = plani.placod and
                                     movim.etbcod = plani.etbcod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                    find produ where produ.procod = movim.procod 
                                                no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod = p-catcod 
                    then vok = yes.
                end.
                if vok = no
                then next.

                /**************************************** 
                output stream stela to terminal.
                    display stream stela
                            plani.etbcod
                            plani.pladat with frame f-stream row 10
                                                    centered side-label.
                    pause 0.
                output stream stela close.
                ****************************************/
                
                v-vencar = 0.
                if plani.crecod = 2
                then do:
                    find contnf where contnf.etbcod = plani.etbcod and
                                  contnf.placod = plani.placod
                                  no-lock no-error.
                    if avail contnf
                    then do:
                    v-vencar = 0.
                    for each tt-titcar where
                             tt-titcar.titnum = string(contnf.contnum)
                             no-lock:
                        v-vencar = v-vencar + tt-titcar.titvlpag.
                    end.
                    if v-vencar <> 0
                    then do:
                        find first wplano where
                                   wplano.fincod = - 1 no-error.
                        if not avail wplano
                        then do:
                            create wplano.
                            wplano.fincod = - 1.
                        end.
                        assign
                            wplano.contra = wplano.contra + 1
                            wplano.clicod = wplano.clicod + 1
                            wplano.valor = wplano.valor + v-vencar
                            .       
                    end.                
                    end.
                    /**
                    if v-vencar >= plani.biss
                    then next.
                    **/
                    find first wplano where wplano.fincod = plani.pedcod
                                                no-error.
                    if not avail wplano
                    then do:
                        create wplano.
                        assign wplano.fincod = plani.pedcod.
                    end.
                    assign wplano.contra = wplano.contra + 1
                           wplano.valor  = wplano.valor + plani.biss.
                    if v-vencar <> 0
                    then assign
                        wplano.contra = wplano.contra - 1
                        wplano.valor = wplano.valor - v-vencar.
                    
                    find ttcli use-index i1 
                               where ttcli.clicod = plani.desti and
                                     ttcli.crecod = plani.pedcod no-error.
                    if not avail ttcli
                    then do:
                        create ttcli.
                        assign ttcli.clicod = plani.desti
                               ttcli.crecod = plani.pedcod.
                    end.
                    assign ttcli.totcli = ttcli.totcli + 1.
                    if v-vencar <> 0
                    then ttcli.totcli = ttcli.totcli - 1.
                end.
                else do:
                    v-vencar = 0.
                    for each tt-titcar where
                             tt-titcar.titnum = "v" + string(plani.numero)
                             no-lock:
                        v-vencar = v-vencar + tt-titcar.titvlpag.
                    end.
                    if v-vencar <> 0
                    then do:
                        find first wplano where
                                   wplano.fincod = - 1 no-error.
                        if not avail wplano
                        then do:
                            create wplano.
                            wplano.fincod = - 1.
                        end.
                        assign
                            wplano.contra = wplano.contra + 1
                            wplano.clicod = wplano.clicod + 1
                            wplano.valor = wplano.valor + v-vencar
                            .       
                     end.
                     /**
                    if v-vencar >= plani.platot -
                                           plani.vlserv - plani.descprod +
                                           plani.acfprod
                    then next.
                    **/
                    find first wplano where wplano.fincod = 0 no-error.
                    if not avail wplano
                    then do:
                        create wplano.
                        assign wplano.fincod = 0.
                    end.
                    assign wplano.clicod = wplano.clicod + 1
                           wplano.contra = wplano.contra + 1
                           wplano.valor  = wplano.valor + plani.platot -
                                           plani.vlserv - plani.descprod +
                                           plani.acfprod.
                   if v-vencar <> 0
                   then assign
                        wplano.clicod = wplano.clicod - 1
                         wplano.contra = wplano.contra - 1
                        wplano.valor = wplano.valor - v-vencar.
                end.
                
            end.
        end.
    end.

    for each ttcli where totcli > 0 break by ttcli.crecod:
        ii = ii + 1.
        if last-of(ttcli.crecod)
        then do:
            find first wplano where wplano.fincod = ttcli.crecod no-error.
            if avail wplano
            then wplano.clicod = ii.
            ii = 0.
        end.
    end.
            

    for each wplano:
        wtotal = wtotal + wplano.valor.
    end.
  
    varquivo = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/relcpg-" + string(p-catcod) +
                         string(day(vdtfim),"99") +   
                         string(month(vdtfim),"99") + 
                         string(year(vdtfim),"9999") + "." + string(time).

    {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "135"
                &Page-Line = "66"
                &Nom-Rel   = ""relcpg-cron""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ANALISE DE PLANOS NO PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfim) +
                                ""  SETOR "" + string(p-catcod) + 
                                ""  FILIAL "" +
                                string(vetbi,"">>9"") + "" A "" +
                                string(vetbf,"">>9"")"
                &Width     = "135"
                &Form      = "frame f-cabcab"}


    for each wplano break by wplano.fincod.
        find finan where finan.fincod = wplano.fincod no-lock no-error.
        if not avail finan
        then do:
            if wplano.fincod < 0
            then vfinnom = "CARTAO".
            else vfinnom = "".
        end.
        else vfinnom = finan.finnom.
        
        display wplano.fincod   when wplano.fincod >= 0
                        label "Condicao"  format "->99"
                vfinnom 
                wplano.clicod   column-label "N.Clientes."   (total)
                wplano.contra   column-label "N.Contratos."  (total)
                wplano.valor    column-label "Vl.Liq"  (total)
                ((wplano.valor / wtotal) * 100)(total) label "Vlr%" 
                                                    format ">>9.99 %"
                        with color white/red width 135 row 8 centered down.
    end.

    val-venda-cart = 0. qtd-venda-cart = 0.

    /***
    for each estab where estab.etbcod >= vetbi 
                     and estab.etbcod <= vetbf no-lock.

        for each titulo use-index etbcod
                        where titulo.etbcobra = estab.etbcod
                          and titulo.titdtpag >= vdtini
                          and titulo.titdtpag <= vdtfim no-lock.
    
            if titulo.titsit <> "PAG" then next. 
            if titulo.moecod <> "CAR" then next.
            if titulo.titdtemi <> titulo.titdtpag then next.
        
            val-venda-cart = val-venda-cart + titulo.titvlpag.
            qtd-venda-cart = qtd-venda-cart + 1.
        
    end.
        
    end.
        put skip(3)
            "OBS: OS VALORES ABAIXO JA ESTAO INCLUIDOS NA TABELA ACIMA"
            skip(1)
            "TOTAL VENDA COM CARTAO:" val-venda-cart skip 
            "QTD VENDA COM CARTAO..:" qtd-venda-cart skip(1).
    **/                

    output close.
    varqsai = varquivo.
    leave.

    /****************************************************************
    if opsys = "UNIX"
    then do:
        message "Arquivo gerado: " varquivo.
        run visurel.p (input varquivo, "").
        pause.
    end.    
    else do:
        message "Arquivo gerado: " varquivo.
        /*sresp = yes.*/
        {mrod.i}.
    end.    
    ****************************************************************/
    
    /***************************************************************
     message "Imprime Relatorio ?" update sresp.
    if not sresp
    then return.
    dos silent value("type " + varquivo + " > prn"). 
    ****************************************************************/
    
end.

procedure titcar:
        
        for each tt-titcar : delete tt-titcar. end.
        
        for each titulo use-index etbcod
                        where titulo.etbcobra = estab.etbcod
                          and titulo.titdtpag = vdata no-lock:
    
            if titulo.titsit <> "PAG" then next. 
            if titulo.moecod <> "CAR" then next.
            if titulo.titdtemi <> titulo.titdtpag then next.
            create tt-titcar.
            buffer-copy titulo to tt-titcar.
        end.
end procedure.
