{admcab.i }

def var vok as log.
def var vcatcod like produ.catcod.
def var i as i.
def var varquivo as char format "x(20)".
def var wtotal     like plani.platot.
def var wtotal-filial like plani.platot.
def var vdata      like plani.pladat.
def var vdtini     like plani.pladat         initial today.
def var vdtfim     like plani.pladat         initial today.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.

def var quebra-fil   as log format "Sim/Nao".
def var vfincod like finan.fincod.
def var vgeral-fin   as log format "Sim/Nao".

def stream stela.

def var vtot as dec extent 99.

def temp-table wplano
             field clicod   like clien.clicod
             field fincod   like finan.fincod
             field contra   as integer
             field valor    as dec format ">>,>>>,>>9.99".

def temp-table wplano-filial
             field etbcod   like estab.etbcod
             field clicod   like clien.clicod
             field fincod   like finan.fincod
             field contra   as integer
             field valor    as dec format ">>,>>>,>>9.99"
             field totalf   as dec format ">>,>>>,>>9.99".

def temp-table tt-clipar-fil
    field etbcod like estab.etbcod
    field fincod like finan.fincod
    field clicod like clien.clicod.

def buffer bwplano-filial for wplano-filial.

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
    for each clipar:
        delete clipar.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp2 side-label row 15 centered.
        pause 0.
    end.
    hide frame f-disp2 no-pause.

    for each wplano-filial:
        delete wplano-filial.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp-fil side-label row 15 centered.
        pause 0.
    end.
    hide frame f-disp-fil no-pause.
    
    for each tt-clipar-fil:
        delete tt-clipar-fil.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-clipar-fil side-label row 15 centered.
        pause 0.
    end.
    hide frame f-clipar-fil no-pause.
    
    do I = 1 to 99:
        vtot[I] = 0.
    end.
        
    update vcatcod label "Departamento....."
                    with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.
    
    do on error undo:
        vgeral-fin = yes.
        update skip vgeral-fin label "Todos os Planos.."
                    with frame f1.
        if not vgeral-fin
        then do:
            update " Codigo:" vfincod no-label with frame f1.
            
            find finan where finan.fincod = vfincod no-lock no-error.
            if not avail finan
            then do:
                message "Plano nao cadastrado.".
                undo.
            end.
            else disp finan.finnom no-label with frame f1.
        end.
    end.

    update skip
           vetbi label "Filial Inicial..."
           vetbf label "Filial Final"
            with frame f1 side-label width 80 color white/cyan.

    update skip
           quebra-fil label "Quebra por Filial"
           with frame f1.


    update vdtini    label "Data Inicial"
           vdtfim    label "Data Final" with frame f2
                        side-label width 80 color white/cyan.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        do vdata = vdtini to vdtfim:

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
                    if produ.catcod = vcatcod 
                    then vok = yes.
                end.
                if vok = no
                then next.
                output stream stela to terminal.
                    display stream stela
                            plani.etbcod
                            plani.pladat with frame f-stream row 10
                                                    centered side-label.
                    pause 0.
                output stream stela close.
                if plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod
                                                no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                no-lock no-error.
                        if not avail contrato
                        then next.

                        if not vgeral-fin
                        then if contrato.crecod <> vfincod
                             then next.

                        if quebra-fil
                        then do:
                            find first wplano-filial where
                                       wplano-filial.etbcod = plani.etbcod
                                   and wplano-filial.fincod = contrato.crecod
                                       no-error.
                            if not avail wplano-filial
                            then do:
                                create wplano-filial.
                                assign wplano-filial.fincod = contrato.crecod
                                       wplano-filial.etbcod = plani.etbcod.
                            end.
                            assign 
                                   wplano-filial.contra = 
                                   wplano-filial.contra + 1
                                   wplano-filial.valor  = 
                                   wplano-filial.valor + contrato.vltotal.
                        end.
                        else do:
                        find first wplano where wplano.fincod = contrato.crecod
                                                no-error.
                        if not avail wplano
                        then do:
                            create wplano.
                            assign wplano.fincod = contrato.crecod.
                        end.

                        assign wplano.contra = wplano.contra + 1
                               wplano.valor  = wplano.valor + contrato.vltotal.

                        end.
                        
                        if not quebra-fil
                        then do:
                        find clipar where clipar.clicod = contrato.clicod and
                                          clipar.parini = contrato.crecod
                                                no-error.
                        if not avail clipar
                        then do:
                            create clipar.
                            assign clipar.clicod = contrato.clicod
                                   clipar.parini = contrato.crecod.
                        end.
                        assign clipar.parfin = clipar.parfin + 1.
                        end.
                        else do:
                        
                        find tt-clipar-fil
                            where tt-clipar-fil.etbcod = plani.etbcod
                              and tt-clipar-fil.fincod = contrato.crecod
                              and tt-clipar-fil.clicod = contrato.clicod
                                                no-error.
                        if not avail tt-clipar-fil
                        then do:
                            create tt-clipar-fil.
                            assign tt-clipar-fil.clicod = contrato.clicod
                                   tt-clipar-fil.fincod = contrato.crecod
                                   tt-clipar-fil.etbcod = plani.etbcod.
                        end.
                        
                        
                        end.
                        
                    end.
                end.
                else do:

                    if not vgeral-fin
                    then if vfincod <> 0
                         then next.

                    if quebra-fil
                    then do:
                            find first wplano-filial where
                                       wplano-filial.etbcod = plani.etbcod
                                   and wplano-filial.fincod = 0
                                       no-error.
                            if not avail wplano-filial
                            then do:
                                create wplano-filial.
                                assign wplano-filial.fincod = 0
                                       wplano-filial.etbcod = plani.etbcod.
                            end.
                    assign wplano-filial.clicod = wplano-filial.clicod + 1
                           wplano-filial.contra = wplano-filial.contra + 1
                           wplano-filial.valor  = wplano-filial.valor + plani.platot -
                                           plani.vlserv - plani.descprod +
                                           plani.acfprod.

                    
                    end.
                    else do:
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
                    end.                                           
                end.
            end.
        end.
    end.

    for each wplano:
        wtotal = wtotal + wplano.valor.
    end.

    for each wplano-filial:
    
        vtot[wplano-filial.etbcod] = vtot[wplano-filial.etbcod]
                                   + wplano-filial.valor.
    end.
    
    if opsys = "UNIX"
    then varquivo = "../relat/anapla" +  STRING(month(today)).
    else varquivo = "..\relat\anapla" +  STRING(month(today)).

    {mdad.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""anapla""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ANALISE DE PLANOS NO PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfim) +
                                ""  "" + string(vcatcod) + ""  FILIAL "" +
                                string(vetbi,"">>9"") + "" A "" +
                                string(vetbf,"">>9"")"
                &Width     = "160"
                &Form      = "frame f-cabcab"}

    if not quebra-fil
    then run rel-sem-quebra.
    else run rel-quebra-filial.    
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
    
end. 


procedure rel-sem-quebra:

    for each wplano break by wplano.fincod.
        for each clipar where clipar.parini = wplano.fincod no-lock:
            wplano.clicod = wplano.clicod + 1.
        end.

        find finan where finan.fincod = wplano.fincod no-lock no-error.
        
        display wplano.fincod        label "Condicao"  format ">99"
                finan.finnom when avail finan
                wplano.clicod   column-label "N.Clientes."   (total)
                wplano.contra   column-label "N.Contratos."  (total)
                wplano.valor    column-label "Valor Total"  (total)
            ((wplano.valor / wtotal) * 100)(total) label " % " format ">>9.99 %"
            with color white/red width 200 row 8 centered down.
    end.

end procedure.


procedure rel-quebra-filial:

    for each wplano-filial break by wplano-filial.etbcod
                                 by wplano-filial.fincod:

        
        for each tt-clipar-fil where
                 tt-clipar-fil.etbcod = wplano-filial.etbcod and
                 tt-clipar-fil.fincod = wplano-filial.fincod no-lock:
            wplano-filial.clicod = wplano-filial.clicod + 1.
        end.

        find finan where finan.fincod = wplano-filial.fincod no-lock no-error.

        if first-of(wplano-filial.etbcod)
        then do:
            find estab where 
                 estab.etbcod = wplano-filial.etbcod no-lock no-error.

            disp wplano-filial.etbcod label "Filial"
                 estab.etbnom when avail estab no-label
                 with frame f-estabx side-labels.
            
        end.        
        
        
        display 
                wplano-filial.fincod        label "Condicao"  format ">99"
                finan.finnom when avail finan
                wplano-filial.clicod   column-label "N.Clientes."
                    (total by wplano-filial.etbcod)
                wplano-filial.contra   column-label "N.Contratos." 
                    (total by wplano-filial.etbcod) 
                wplano-filial.valor    column-label "Valor Total"  
                    (total by wplano-filial.etbcod)
            ((wplano-filial.valor / vtot[wplano-filial.etbcod]) * 100) (total)
                column-label " % " format ">>9.99 %"
            with color white/red width 200 row 8 centered down.
    end.


end procedure.
