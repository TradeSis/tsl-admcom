{admcab.i}

def var fila as char.
def var recimp as recid.
def var vcontinua as log.
def var vopimp as log format "Tela/Impressora".

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var tt-ven10 as dec.
def var tt-est10 as dec.
def var tt-ven99 as dec.
def var tt-est99 as dec.
def var vetbcod like estab.etbcod.
vetbcod = 98. 
def var ii as i.
def var vano as i.
def var vmes as i.
def temp-table tt
    field etbcod    like estab.etbcod
    field procod    like produ.procod format ">>>>>>>>>".
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot decimals 10.
def var v-de like plani.platot decimals 10.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vlcontrato  like contrato.vltotal.
def var vtotal_platot as dec.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

def var vdias as int.

def temp-table tt-curva
    field pos    like curfab.pos
    field cod    like curfab.cod
    field estven as dec
    field estcus as dec
    field qtdest as dec
    field ven10  as dec
    field cus10  as dec
    field qtd10  as dec
    field ven90  as dec
    field cus90  as dec
    field qtd90  as dec        
    field qtd-os as dec
    field est-os as dec
    index i1 cod.

def var val-est-os as dec.
def var vqtd-pro-os as int.
def temp-table tt-catcod
    field catcod like produ.catcod.

def buffer btt-curva for tt-curva.

def temp-table tt-asstec like asstec
    index i1 procod.
    
repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    update vcatcod at 2 label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4
                width 80.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then do:
        create tt-catcod.
        assign tt-catcod.catcod = 31.
        create tt-catcod.
        assign tt-catcod.catcod = 35.
        create tt-catcod.
        assign tt-catcod.catcod = 50.
    end.
    else do:
        create tt-catcod.
        assign tt-catcod.catcod = 41.
        create tt-catcod.
        assign tt-catcod.catcod = 45.
    end.
    vetbi = vetbcod.
    update vetbi at 9 label "Filial"
           /*vetbf label "Ate"*/ with frame f-dep.
    update vdti at 5 label  "Periodo de"
           vdtf label  "Ate"  with frame f-dep.
    update vdias at 1 label "Numero de Dias" with frame f-dep.
    vetbcod = vetbi.
    for each tt-curva:
        delete tt-curva.
    end.
    totcusto = 0.
    totvenda = 0.
    message "   POR FAVOR AGUARDE!   ".
    run sel-os.
    HIDE MESSAGE NO-PAUSE.
    
    for each tt-catcod no-lock,
        each produ use-index catpro
            where produ.catcod = tt-catcod.catcod no-lock:
        output stream stela to terminal.
            disp stream stela 
                        produ.catcod
                        produ.pronom
                        produ.procod    format ">>>>>>>9" 
                        produ.fabcod
                           with frame ffff centered
                           color message 1 down no-box
                           row 10.
            pause 0.
        output stream stela close.
        /*
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5            and
                                bmovim.movdat >= vdti        and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.
        */
      /*
        if produ.fabcod = 2
        then next. 
        */
        
        find first tt-curva where tt-curva.cod = produ.fabcod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last btt-curva no-error.
            if not avail btt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = btt-curva.pos + 1.
            tt-curva.cod = produ.fabcod.
        end.

        vestven = 0.
        vcusto  = 0.
        find estoq where estoq.etbcod = vetbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if avail estoq
        then do:
                vestven = vestven + (estoq.estatual * estoq.estvenda).
                vcusto  = vcusto  + (estoq.estatual * estoq.estcusto).
                tt-curva.qtdest = tt-curva.qtdest + estoq.estatual.
                
        end.
        if not avail estoq
        then do.
            find first tt where tt.etbcod = vetbcod and         
                                tt.procod = produ.procod
                                no-error.
            if not avail tt
            then create tt.
            tt.etbcod = vetbcod.
            tt.procod = produ.procod.
        end.
        
        assign tt-curva.estven = tt-curva.estven + vestven
               tt-curva.estcus = if vcusto <> ?
                                 then tt-curva.estcus + vcusto
                                 else tt-curva.estcus.
               
        for each tt-asstec where 
                 tt-asstec.procod = produ.procod:
            
            if  tt-asstec.dtenvass <> ? and
                tt-asstec.dtenvass < vdtf and
                tt-asstec.dtretass = ?
            then next.
            if  tt-asstec.dtenvfil <> ? and
                tt-asstec.dtenvfil < vdtf
            then next.

            tt-curva.qtd-os = tt-curva.qtd-os + 1.
            tt-curva.est-os = tt-curva.est-os + if avail estoq
                                                then estoq.estcusto
                                                else 0 .
            if vdias > 0
            then do:
                if tt-asstec.dtentdep > vdtf - vdias   or
                   tt-asstec.dtretass > vdtf - vdias
                then assign
                    tt-curva.cus10 = tt-curva.cus10 + if avail estoq 
                                                      then estoq.estcusto
                                                      else 0
                    tt-curva.qtd10 = tt-curva.qtd10 + 1
                    .
            end.

        end.
        /**
        for each movim where 
                 movim.procod = produ.procod and
                 movim.movtdc = 15 and
                 movim.movdat > vdtf - vdias no-lock.
            if movim.movdat > vdtf then next.     
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat
                             no-lock no-error.
            if avail plani and plani.desti = 98
            then do:
            tt-curva.cus10 = tt-curva.cus10 + estoq.estcusto * movim.movqtm).
            tt-curva.qtd10 = tt-curva.qtd10 + movim.movqtm.
            end.
        end. 
        **/   
    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    
    for each tt-curva by tt-curva.estcus descending:
        tt-curva.cus90 = tt-curva.estcus - tt-curva.cus10.
        tt-curva.pos = i.
        i = i + 1.
    end.
    
    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    if opsys = "UNIX"
    then do:
        varquivo = "../relat/a" + STRING(day(today)) 
                                 + STRING(month(today)) 
                                 + string(categoria.catcod,"99")
                                 + "." + string(time).

        message "Saida do Relatorio [T]ela / [I]mpressora " update vopimp.
        if vopimp /*yes tela*/
        then do:
        
        end.
        else do:

            find first impress where impress.codimp = setbcod no-lock no-error. 
            if avail impress
            then do: 
                run acha_imp.p (input recid(impress),  
                                output recimp). 
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp).
            end.    
        
        end.
    
    end.                                 
    else varquivo = "..\relat\a" + STRING(day(today)) 
                                 + STRING(month(today)) 
                                 + string(categoria.catcod,"99").

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""curva1""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """RELATORIO DE ESTOQUE DA FILIAL "" +
                                  string(vetbCOD,"">>9"") "
            &Width     = "100"
            &Form      = "frame f-cabcab"}

    DISP WITH FRAME F-DEP.
    put "CODIGO   NOME                              "
      "EST.CUSTO       " string(vdias) +  " DIAS" 
      "    + " + trim(string(vdias,">>9")) + " DIAS" FORMAT "X(15)" SKIP
      fill("-",80) format "x(80)"
      skip.
    
    def var tt1 as dec init 0.
    def var tt2 as dec init 0.
    def var tt3 as dec init 0.
    for each tt-curva by tt-curva.pos:
    
        if tt-curva.estcus = 0  or
           tt-curva.estcus = ?
        then next.

        find fabri where fabri.fabcod = tt-curva.cod no-lock no-error.


         put tt-curva.cod    format ">>>>>>>9"      space(1)
             fabri.fabnom    format "x(29)"         space(1)
             tt-curva.estcus format "->,>>>,>>9.99" space(1)
             tt-curva.cus10  format "->,>>>,>>9.99" space(1)
             tt-curva.cus90  format "->,>>>,>>9.99" 
             skip.
         assign
            tt1 = tt1 + tt-curva.estcus
            tt2 = tt2 + tt-curva.cus10
            tt3 = tt3 + tt-curva.cus90
            .
    end.
    put fill("-",80) format "x(80)"
        skip
        space(20) "T O T A L"  space(10)
        tt1 format "->,>>>,>>9.99" space(1)
        tt2 format "->,>>>,>>9.99" space(1)
        tt3 format "->,>>>,>>9.99" 
             skip.

     find first tt no-error.
     if avail tt
     then do.
         put skip(2)
             "=========================================================" skip
             " Produtos sem registro na tabela estoq. Verificar com TI" skip 
             "=========================================================" skip
             .
         for each tt.   
             find produ of tt no-lock.
             disp tt.
             disp produ.pronom.
         end.
         put skip
             "=========================================================" skip.
     end.
     output close.

    if opsys = "UNIX"
    then do:
    
        if vopimp
        then run visurel.p (input varquivo, input "").
        else os-command silent lpr value(fila + " " + varquivo).
    
    end.
    else do:
        {mrod.i}
    end.        
    
end.

procedure sel-os:
    
    for each tt-asstec:
        delete tt-asstec.
    end.    
    for each estab no-lock:
        for each asstec where asstec.etbcod = estab.etbcod no-lock.
        
            
            create tt-asstec.
            buffer-copy asstec to tt-asstec.
        
        end.    
    end. 
end procedure
