{admcab.i}          

def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
def var valtotal as dec. 

def var val-venda-cart as dec.
def var qtd-venda-cart as int.
def var val-origem as dec.
def var val-outros as dec.
def var val-acrescimo as dec.

def var ii as int.
def var vok as log.
def var vcatcod like produ.catcod.
def var i as i.
def var varquivo as char format "x(20)".
def var wtotal     like plani.platot.
def var vdata      like plani.pladat.
def var vdtini     like plani.pladat         initial today.
def var vdtfim     like plani.pladat         initial today.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def stream stela.
def var v-vencar as dec.
def var vfinnom like finan.finnom.

def temp-table ttcli
    field clicod like plani.desti
    field crecod like contrato.crecod
    field totcli as int
    index i1 clicod crecod.

def var venda-cartao as dec format ">>>,>>>,>>9.99".

def temp-table tt-titcar like titulo.
             
def temp-table wplano
             field clicod   like clien.clicod
             field fincod   like finan.fincod
             field contra   as integer
             field valor    as dec format ">>,>>>,>>9.99"
             field acrescimo as dec format ">>>,>>9.99".

repeat:
    wtotal = 0.
    I = 0.
    for each wplano:
        delete wplano.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp side-label row 15 centered.
        pause 0.
    end.
    hide frame f-disp no-pause.
    for each ttcli:
        delete ttcli.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp2 side-label row 15 centered.
        pause 0.
    end.
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

    venda-cartao = 0.
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        do vdata = vdtini to vdtfim:

            run titcar.
            
            for each plani where plani.movtdc = 5            and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = vdata no-lock:
                vok = no.
                /*
                for each movim where movim.placod = plani.placod and
                                     movim.etbcod = plani.etbcod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                    find produ where produ.procod = movim.procod 
                                                no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod = vcatcod 
                    then vok = yes.
                end.
                */
                
                valtotal = 0.
                for each com.movim where 
                         com.movim.placod = com.plani.placod
                     and com.movim.etbcod = com.plani.etbcod
                     and com.movim.movtdc = com.plani.movtdc
                     and com.movim.movdat = com.plani.pladat no-lock:
                                
                   find com.produ where
                        com.produ.procod = com.movim.procod
                                                        no-lock no-error.
                   if not avail com.produ
                   then next.
                   if com.produ.catcod = vcatcod 
                   then vok = yes.
                   else next.
                   
                   assign val_fin = 0 
                       val_des = 0
                       val_dev = 0
                       val_acr = 0
                       val_com = 0.
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                        - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) 
                        - val_dev - val_des + val_acr + val_fin. 
                if val_com = ?
                then val_com = 0.
                
                valtotal = valtotal + val_com.
                   
               end.
               if valtotal <= 0
               then next.

               if vok = no 
               then next.

               val_acr  = com.plani.acfprod.
               if com.plani.biss > (com.plani.platot - com.plani.vlserv)  
               then val_acr  = com.plani.biss  - 
                               (com.plani.platot - com.plani.vlserv).
                                      
               

                if vok = no
                then next.
                output stream stela to terminal.
                    display stream stela
                            plani.etbcod
                            plani.pladat with frame f-stream row 10
                                                    centered side-label.
                    pause 0.
                output stream stela close.
                
                v-vencar = 0.
                val-acrescimo = 0.
                if plani.crecod = 2
                then do:
                    run calcula-valor-origem-contrato.p(input recid(plani),
                                                    input ?,
                                                  output val-origem,
                                                  output val-outros).
                                                  
                    val-acrescimo = plani.biss - val-origem.
                    if val-acrescimo < 0 then val-acrescimo = 0.
                    
                    find contnf where contnf.etbcod = plani.etbcod and
                                  contnf.placod = plani.placod
                                  no-lock no-error.
                    if avail contnf
                    then do:
                    v-vencar = 0.
                    for each tt-titcar where
                             tt-titcar.titnum = string(contnf.contnum)
                             no-lock:
                        venda-cartao = venda-cartao + tt-titcar.titvlpag.
                        /*
                        v-vencar = v-vencar + tt-titcar.titvlpag.
                        */
                    end.
                    if v-vencar <> 0 and
                       v-vencar <> ?
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
                    if plani.biss <> ?
                    then
                    assign wplano.contra = wplano.contra + 1
                            /*
                           wplano.valor  = wplano.valor + plani.biss.
                           */
                           wplano.valor  = wplano.valor
                                  + if com.plani.biss <> ?
                                          then com.plani.biss else 0
                           wplano.acrescimo = wplano.acrescimo 
                                    + val-acrescimo
                                          .
                                          
                    if v-vencar <> 0 and
                       v-vencar <> ?
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
                             tt-titcar.titnum = 
                             string(plani.serie) + string(plani.numero)
                             no-lock:
                        venda-cartao = venda-cartao + tt-titcar.titvlpag.
                        /*
                        v-vencar = v-vencar + tt-titcar.titvlpag.
                        */
                    end.
                    
                    if v-vencar <> 0 and
                       v-vencar <> ?
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
                    if plani.platot <> ? and
                       plani.vlserv <> ? and
                       plani.descprod <> ? and
                       plani.acfprod <> ?
                    then   
                    assign wplano.clicod = wplano.clicod + 1
                           wplano.contra = wplano.contra + 1
                           wplano.valor  = wplano.valor + plani.platot /**/ -
                                           plani.vlserv - plani.descprod +
                                           plani.acfprod /**/.
                                           
                   if v-vencar <> 0 and
                      v-vencar <> ?
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
  
    if opsys = "UNIX"
    then varquivo = "../relat/relcpgl" + string(month(today)) + string(time) + ".txt"     .
    else varquivo = "..\relat\relcpgw" +  STRING(month(today)) + string(time) + ".txt".

    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "130"
                &Page-Line = "66"
                &Nom-Rel   = ""relcpg""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ANALISE DE PLANOS NO PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfim) +
                                ""  "" + string(vcatcod) + ""  FILIAL "" +
                                string(vetbi,"">>9"") + "" A "" +
                                string(vetbf,"">>9"")"
                &Width     = "130"
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
                wplano.valor    column-label "Venda(3)"  (total)
                ((wplano.valor / wtotal) * 100)(total) label "Vlr%" 
                                                    format ">>9.99 %"
                wplano.acrescimo column-label "Acrescimo" (total)
                        with color white/red width 120 row 8 centered down.
    end.


    put skip(3)
         "TOTAL VENDA COM CARTAO:" venda-cartao  "  " 
         ((venda-cartao / wtotal) * 100) format ">>9.99 %"        
         skip 
         .

    output close.
    
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

    /* 
    message "Imprime Relatorio ?" update sresp.
    if not sresp
    then return.
    dos silent value("type " + varquivo + " > prn"). 
    */
    
end.

procedure titcar:

        def var vcar as log.
        def var valcar as dec.
        
        for each tt-titcar : delete tt-titcar. end.
        
        for each titulo use-index etbcod
                        where titulo.etbcobra = estab.etbcod
                          and titulo.titdtpag = vdata no-lock:
    
            if titulo.modcod <> "VVI"
            then next.
            valcar = 0.
            if titulo.titsit <> "PAG" then next. 
            if titulo.titdtemi <> titulo.titdtpag then next.
            /*
            if substr(string(titulo.titnum),1,1) <> "V"
            then next.
            */

            /*
            if titulo.titsit <> "PAG" then next.
            if titulo.moecod <> "CAR" then next.
            if titulo.moecod <> "PDM" then next.
            if not titulo.moecod begins "TC" then next.
            if not titulo.moecod begins "TD" then next.
            if titulo.titdtemi <> titulo.titdtpag then next.
            */
            /*
            disp titulo.moecod format "x(10)" titulo.titvlpag. pause.
            */
            vcar = no.
            if titulo.moecod = "PDM"
            then for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar
                        no-lock:
                    if  titpag.moecod = "CAR" or
                        titpag.moecod begins "TC" or
                        titpag.moecod begins "TD"
                    then do:
                        vcar = yes.
                        valcar = valcar + titpag.titvlpag.
                    end.
                end.

            else if  titulo.moecod = "CAR" or
                        titulo.moecod begins "TC" or
                        titulo.moecod begins "TD"
                then do:
                    vcar = yes.
                    valcar = valcar + titulo.titvlpag.
                end.         
        
            if vcar 
            then do:
                create tt-titcar.
                buffer-copy titulo to tt-titcar.
                tt-titcar.titvlpag = valcar.
            end.
            
        end.
end procedure.



 
