{admcab.i}

def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vdatai  as   date format "99/99/9999".
def var vdataf  as   date format "99/99/9999".

def temp-table tt-estab
    field etbcod like estab.etbcod.

def temp-table tt-notas
    field etbcod    like estab.etbcod
    field numero    like plani.numero
    field pladat    like plani.pladat
    field procod    like produ.procod
    field movqtm    like movim.movqtm
    field preco-ori like movim.movpc
    field preco-ven like movim.movpc
    field fincod like finan.fincod.
    
def var vpct-min as dec. 
def buffer bestab for estab.   

def var vcatcod like categoria.catcod.
def var vok as log.

repeat:

    for each tt-estab:
        delete tt-estab.
    end.
    
    do on error undo:
        /*
        vetbcod = 42.
        */
        update vetbcod
               with frame f-dados width 80 side-labels.
    
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.    
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                pause 1 no-message.
                undo.
            end.
            else do:
                find tt-estab where tt-estab.etbcod = estab.etbcod no-error.
                if not avail tt-estab
                then do:
                    create tt-estab.
                    assign tt-estab.etbcod = estab.etbcod.
                end.
                disp estab.etbnom no-label with frame f-dados.
            end.
        end.
        else do:
            for each estab no-lock:
                find tt-estab where tt-estab.etbcod = estab.etbcod no-error.
                if not avail tt-estab
                then do:
                    create tt-estab.
                    assign tt-estab.etbcod = estab.etbcod.
                end.
            end.
            disp "Todos" @ estab.etbnom with frame f-dados.
        end.

    end.
    
    vdatai = today - 2.
    vdataf = today - 1.
    
    update skip
           vdatai label "Data Inicial..."
           vdataf label "Data Final"
           with frame f-dados.

    update  vcatcod at 1 label "Categoria...."
                           with frame f-dados.
    if vcatcod = 0
    then display "Geral" @ categoria.catnom             no-label with frame f-dados.
    else do:
        find categoria where categoria.catcod = vcatcod no-lock.
            display categoria.catnom no-label with frame f-dados.
    end.
                        
    update vpct-min at 1 label "Percentual minimo" with frame f-dados.
    
    for each tt-estab no-lock:
        for each plani where plani.etbcod  = tt-estab.etbcod
                         and plani.movtdc  = 5 
                         and plani.pladat >= vdatai
                         and plani.pladat <= vdataf no-lock:

            disp plani.etbcod label "Filial"
                 plani.pladat label "Emissao"
                 with frame f-dis centered side-labels overlay
                        row 8 1 down. pause 0.
            vok = yes.
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                find first  produ where 
                            produ.procod = movim.procod
                            no-lock no-error.
                if not avail produ then next.
                vok = yes.
                if (produ.catcod = 31 and vcatcod = 41) or
                   (produ.catcod = 41 and vcatcod = 31)
                then do:
                    vok = no.
                    leave.
                end.      
            end.
            if vok = no then next.
                    
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                     
                /*
                if ocnum[5] <> 0 and ocnum[6] <> 0
                then.
                else next.
                */
                
                 release divpre.
                /**************************************************************
                 Solicitado pela Daniela Auditoria ao Rafael para que somente
                 aparecam as vendas liberadas com a senha do supervisor.
                                16/11/2010
                 *************************************************************/
                 find first divpre where divpre.etbcod = movim.etbcod
                                     and divpre.placod = movim.placod
                                     and divpre.procod = movim.procod
                                     and divpre.divjus = "DESC. SUPERVISOR"
                                        no-lock no-error.
                 
                 if not avail divpre
                 then next.
                
                find first tt-notas where 
                           tt-notas.etbcod = movim.etbcod and
                           tt-notas.numero = plani.numero and
                           tt-notas.pladat = plani.pladat and
                           tt-notas.procod = movim.procod no-error.
                if not avail tt-notas
                then do:
                    create tt-notas.
                    assign tt-notas.etbcod    = plani.etbcod
                           tt-notas.numero    = plani.numero
                           tt-notas.pladat    = plani.pladat
                           tt-notas.procod    = movim.procod
                           tt-notas.movqtm    = movim.movqtm
                       /*  tt-notas.preco-ori = (movim.ocnum[5] / 100) */
                           tt-notas.preco-ori = divpre.premat
                           tt-notas.preco-ven = movim.movpc
                           tt-notas.fincod = plani.pedcod.
                end.
            end.
        end.
    end.

    for each tt-notas:
        if
        ( 100 - ((tt-notas.preco-ven / tt-notas.preco-ori) * 100))
        < vpct-min
        then delete tt-notas.
    end.
    hide frame f-dis no-pause.
        
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rsenauto." + string(time).
    else varquivo = "l:\relat\rsenauto." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""RSENAUTO""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """RELATORIO DE AUTORIZACOES DE DESCONTO """
                &Width     = "130"
                &Form      = "frame f-cabcab"}
    
        disp with frame f-dados.
        
        for each tt-notas no-lock break by tt-notas.etbcod
                                        by tt-notas.pladat
                                        by tt-notas.numero
                                        by tt-notas.procod:

            find produ where 
                 produ.procod = tt-notas.procod no-lock no-error.
            if first-of(tt-notas.etbcod)
            then do:
                find bestab where bestab.etbcod = tt-notas.etbcod
                    no-lock no-error.
                    
                disp tt-notas.etbcod label "Filial"
                      bestab.etbnom    no-label
                      with frame f-notas-1 width 120 side-labels.
            end.
            disp tt-notas.numero               column-label "Numero NF"
                 format ">>>>>>>>9"
                 tt-notas.pladat 
                 tt-notas.procod               column-label "Produto"
                 format ">>>>>>>>9"
                 produ.pronom when avail produ column-label "Descricao"
                 tt-notas.movqtm               column-label "Qtd"
                 tt-notas.preco-ori            column-label "Preco!Correto"
                 (total)
                 tt-notas.preco-ven            column-label "Preco!Alterado"
                 (total)
                 (tt-notas.preco-ori - tt-notas.preco-ven)
                    format "->>,>>9.99" (total) column-label "Difer."
                 ( 100 - ((tt-notas.preco-ven / tt-notas.preco-ori) * 100))
                 (total)
                 column-label "Dif%" format "->>9.9"
                 tt-notas.fincod format ">>9" column-label "Pl" 
                 with frame f-notas-3 width 160 down.
            
            down with frame f-notas-3.
            
        end.

    
    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.
    
end.