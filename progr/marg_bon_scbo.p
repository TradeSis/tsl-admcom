{admcab.i}

def new shared temp-table aux-plani like plani.
def new shared temp-table aux-movim like movim.

def input parameter p-tipo as int.

def var vsel2 as char format "x(30)" extent 3
    init ["Com Bonus - NF","Com Bonus - Dia",
          "Com Bonus - Mes"].

def var vtotalvlcus like plani.platot.
def var vtotal-liq like plani.platot.
def var tot-ven  like plani.platot.
def var tot-mar  like plani.platot.
def var tot-acr  like plani.platot.
def var vvlmarg like plani.platot.
def var vvlperc like plani.platot.
def var dev-m like plani.platot.
def var dev-c like plani.platot.
def var cus-m like plani.platot.
def var cus-c like plani.platot.
def var ven-c like plani.platot.
def var des-c like plani.platot.
def var acr-c like plani.platot.
def var ven-m like plani.platot.
def var des-m like plani.platot.
def var acr-m like plani.platot.
def var varquivo as char format "x(30)".
def var aa-c like plani.platot.
def var aa-m like plani.platot.
def var mm-c like plani.platot.
def var mm-m like plani.platot.
def buffer bplani for plani.
def var xx as i format "99".
def var vfer as int.
def var ii as i.
def var vv as date.
def var vdtimp      as date.
def var totmeta like plani.platot.
def var totvend like plani.platot.

def var vcomcod     as integer.

def temp-table wplani
    field   wetbcod  like estab.etbcod
    field   wmeta    as char format "X"
    field   wetbcon  like estab.etbcon format ">>,>>>,>>9.99"
    field   wetbmov  like estab.etbmov format ">>,>>>,>>9.99"
    field   wdia     as int format "99"
    field   wmeta-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wacum-m  like plani.platot
    field   wcus-c   like plani.platot
    field   wven-c   like plani.platot format ">>,>>>,>>9.99"
    field   wdes-c   like plani.platot format ">>,>>9.99"
    field   wacr-c   like plani.platot 
    field   wdev-c   like plani.platot
    field   wcus-m   like plani.platot format ">>>>>,>>9.99"
    field   wven-m   like plani.platot format ">>,>>>,>>9.99"
    field   wdes-m   like plani.platot format ">>,>>9.99"
    field   wacr-m   like plani.platot 
    field   wdev-m   like plani.platot.

def var dt     like plani.pladat.
def var acum-c like plani.platot.
def var acum-m like plani.platot.
def var vdia as int format ">9".
def var meta-c like plani.platot.
def var meta-m like plani.platot.
def var vcon like plani.platot.
def var vmov like plani.platot.
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var lfin as log.
def var lcod as i.
def var vok as l.

def var vldev like plani.vlserv.
def buffer bmovim for movim.
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
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def stream stela.
def var vcatcod like produ.catcod.
def buffer bcontnf for contnf.
     
def var va as int.

def var p-bonus as dec.

def temp-table tt-categ like categoria.

def temp-table ttcli
    field clifor like titulo.clifor
    index i1 clifor.

def var vforcod like forne.forcod.

form vcatcod
     categoria.catnom no-label
     vforcod
     vcomcod
     compr.comnom no-label
     vetbi at 1 label "      Filial"
     vetbf label "Ate"
     vdti at 1 label "  Periodo de"
     vdtf label "Ate"
     with frame f-dep centered side-label color blue/cyan row 4
     width 80.

repeat:
    for each wplani:
        delete wplani.
    end.
    for each tt-categ: delete tt-categ. end.
    
    update vcatcod label "Departamento"
                with frame f-dep.
    if vcatcod > 0
    then do:
        find categoria where categoria.catcod = vcatcod no-lock.
        disp categoria.catnom no-label with frame f-dep.
        create tt-categ.
        tt-categ.catcod = categoria.catcod.
    end.
    else do:
        run selcateg.p.
        disp sretorno @ categoria.catnom with frame f-dep.
        if sretorno <> ""
        then do:
            va = 1.
            repeat:
                if substr(string(sretorno),va,3) = "" or
                   substr(string(sretorno),va,3) = ";"
                then leave.
                else do:
                    create tt-categ.
                    tt-categ.catcod = int(substr(string(sretorno),va,3)).
                end.
                va = va + 6.   
            end.
            for each tt-categ.
            disp tt-categ.
            end.
        end.

    end.
    update vforcod at 3 label "Fornecedor" with frame f-dep.
    if vforcod <> 0
    then do:
        find fabri where fabri.fabcod = vforcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante/Fornecedor nao Cadastrado".
            undo.
        end.    
        display fabri.fabnom no-label with frame f-dep.
    end.
    else disp "Geral" @ fabri.fabnom  with frame f-dep.

    update vcomcod at 4 label "Comprador" format ">>>9"
                with frame f-dep.
        
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                           
    if avail compr then display compr.comnom format "x(27)" no-label
                          with frame f-dep.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                                with frame f-dep.
    else do:
                            
        message "Comprador não encontrado!" view-as alert-box.
        undo, retry.
     
    end.

    update vetbi 
           vetbf with frame f-dep.

    update vdti  vdtf with frame f-dep.

    assign vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               acum-m   = 0
               acum-c   = 0
               mm-c     = 0
               mm-m     = 0
               aa-c     = 0
               aa-m     = 0
               vtotal-liq = 0.

    for each ttcli:
        delete ttcli.
    end.    
    
    do dt = vdti to vdtf:
    
        disp dt with 1 down centered. pause 0.

        for each titulo use-index titdtpag 
           where titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = "BON" and
                 titulo.titdtpag = dt no-lock.
         
            find first ttcli where ttcli.clifor = titulo.clifor no-error.
            if not avail ttcli
            then do:
                
                create ttcli.
                assign ttcli.clifor = titulo.clifor.         
                     
            end.         
         end.
    end.
    
    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0
               cus-m   = 0
               cus-c   = 0
               ven-c   = 0
               des-c   = 0
               acr-c   = 0
               ven-m   = 0
               des-m   = 0
               acr-m   = 0
               dev-m   = 0
               dev-c   = 0.

        do dt = vdti to vdtf:

            
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                
                if not can-find (first movim
                                 where movim.etbcod = plani.etbcod and
                                       movim.placod = plani.placod and
                                       movim.movtdc = plani.movtdc and
                                       movim.movdat = plani.pladat)
                then next.                       

                
                output stream stela to terminal.
                disp stream stela plani.etbcod
                                  plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.
                if p-tipo = 1
                then do:
                    sresp = no.
                    run p-lebonusnf.
                    if sresp = no then next.
                end.
                else if p-tipo = 2
                    then do:
                        sresp = no.
                        run p-lebonusdia.
                        if sresp = no then next.   
                    end.
                    else if p-tipo = 3
                        then do:
                            sresp = no.
                            run p-lebonusmes.
                            if sresp = no then next.
                        end.
                        
                for each aux-plani: delete aux-plani. end.
                for each aux-movim: delete aux-movim. end.
                create aux-plani.
                buffer-copy plani to aux-plani.
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat 
                                      no-lock:
                    create aux-movim.
                    buffer-copy movim to aux-movim.
                    find movteste where 
                         movteste.etbcod = aux-plani.etbcod and
                         movteste.serie  = aux-plani.serie  and
                         movteste.numero = aux-plani.numero and
                         movteste.procod = movim.procod
                         no-lock no-error.
                    if avail movteste
                    then do:    
                        aux-plani.platot = aux-plani.platot +
                            ((movteste.movpc - movim.movpc) * 
                            movim.movqtm).
                        aux-movim.movpc = movteste.movpc.    
                    end.
                end.         
                        
                assign
                    vvldesc = 0
                    vvlacre = 0.

                for each aux-movim where aux-movim.etbcod = aux-plani.etbcod and
                                     aux-movim.placod = aux-plani.placod and
                                     aux-movim.movtdc = aux-plani.movtdc and
                                     aux-movim.movdat = aux-plani.pladat
                                      no-lock:
                    find produ where produ.procod = aux-movim.procod
                                                        no-lock no-error.
                    if not avail produ  then next.
                    
                    if vforcod > 0 and
                       produ.fabcod <> vforcod 
                    then next.
                
                    if vcomcod > 0
                    then do:
                        release liped.
                        release pedid.
                        find last liped where liped.procod = aux-movim.procod
                                          and liped.pedtdc = 1
                                           no-lock use-index liped2 no-error.
      
                        find first pedid of liped no-lock no-error.
                       
                        if (avail pedid and
                            pedid.peddat < 11/17/2011) or
                            not avail pedid
                        then do:
                        
                            find first proclasse where
                               proclasse.procod = produ.procod
                               no-lock no-error.
                            if avail proclasse 
                            then do:
                                find compr where 
                                    compr.comnom = proclasse.comprador
                                no-lock no-error.
                                if (avail compr and compr.comcod <> vcomcod) or
                                    not avail compr
                                then next. 
                            end.
                            else next.
                        end. 
                        else if (avail pedid and pedid.comcod <> vcomcod)
                            or not avail pedid
                        then do:
                            /* Nede - 16/01/2012 */
                            find last probrick where
                            probrick.codbrick = aux-movim.procod no-lock no-error.
                             
                            if avail probrick
                            then do:
                            
                                find last liped where 
                                liped.procod = probrick.procod and
                                liped.pedtdc = 1
                                no-lock use-index liped2 no-error.
 
                                find first pedid of liped no-lock no-error.
                                
                                if not avail pedid then next.
                             
                            end. 
                            else next.
                            /*****/
                        end.
                    end.
                                                                        
                    find first tt-categ where
                               tt-categ.catcod = produ.catcod no-error.
                    if not avail tt-categ
                    then next.           
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                        find estoq where estoq.etbcod = aux-plani.etbcod and
                                         estoq.procod = produ.procod
                                                no-lock no-error.
                        if not avail estoq
                        then next.

                        if (vcat = 31 or
                            vcat = 35 or
                            vcat = 50)
                        then cus-m = cus-m + (aux-movim.movqtm * estoq.estcusto).
                        else cus-c = cus-c + (aux-movim.movqtm * estoq.estcusto).
                    end.
                end.
                /**
                output stream stela to terminal.
                disp stream stela aux-plani.etbcod
                                  aux-plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.
                **/
                /************* Calculo do acrescimo *****************/

                vvlcont = 0.
                wacr = 0.
                if aux-plani.crecod > 1
                then do:
                    if aux-plani.biss > (aux-plani.platot - aux-plani.vlserv)
                    then assign wacr = aux-plani.biss - 
                                      (aux-plani.platot - aux-plani.vlserv).
                    else wacr = aux-plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvlacre  = vvlacre  + wacr.
                end.

                vvldesc = vvldesc + aux-plani.descprod.


                if (vcat = 31 or
                    vcat = 35 or
                    vcat = 50)
                then assign acum-m = acum-m + (aux-plani.platot - aux-plani.vlserv -
                                               vvldesc + vvlacre)
                            ven-m  = ven-m + aux-plani.platot
                            des-m  = des-m + vvldesc
                            acr-m  = acr-m + vvlacre
                            dev-m  = dev-m + aux-plani.vlserv.

                else if vcat <> 88
                     then assign
                            acum-c = acum-c + (aux-plani.platot - aux-plani.vlserv -
                                     vvldesc + vvlacre)
                            ven-c  = ven-c + aux-plani.platot
                            des-c  = des-c + vvldesc
                            acr-c  = acr-c + vvlacre
                            dev-c  = dev-c + aux-plani.vlserv.

            end.
        end.
        create wplani.
        assign       
               wplani.wetbcod = estab.etbcod
               wplani.wacum-c  = acum-c
               wplani.wacum-m  = acum-m
               wplani.wcus-c   = cus-c
               wplani.wven-c   = ven-c
               wplani.wdes-c   = des-c
               wplani.wacr-c   = acr-c
               wplani.wdev-c   = dev-c
               wplani.wcus-m   = cus-m
               wplani.wven-m   = ven-m
               wplani.wdes-m   = des-m
               wplani.wacr-m   = acr-m
               wplani.wdev-m   = dev-m.
    end.

    if opsys = "UNIX"
    then varquivo = "../relat/geral" + string(time).
    else varquivo = "..\relat\geral" + string(time).

    {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "180"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE""  + ""       DEPARTAMENTO ""
                            + string(categoria.catcod,""99"")"
            &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") +
                                  ""  Dep. "" + string(vcatcod,""99"")"
            &Width     = "180"
            &Form      = "frame f-cabcab"}

    put vsel2[p-tipo] skip.
    if categoria.catcod = 41
    then do:
        for each wplani by wplani.wetbcod:

            vvlmarg = (wplani.wven-c - wplani.wdes-c - wplani.wcus-c).
            vvlperc = (vvlmarg * 100) / wplani.wven-c.
            if vvlperc = ?
            then vvlperc = 0.

            if wplani.wven-c = 0
            then next.

            find estab where estab.etbcod = wplani.wetbcod no-lock no-error.

            disp estab.etbcod column-label "Filial"
                 wplani.wcus-c(total) column-label "Vl.Custo(1)"
                 wplani.wdes-c(total) 
                                column-label "Desc(2)" format ">>>,>>9.99"
                 wplani.wven-c(total) column-label "VlVenda(3)"
                 (wplani.wven-c - wplani.wdes-c - wplani.wcus-c)(total)                  column-label "Margem(4)" format "->,>>>,>>9"
                 vvlperc      /*  when vvlperc >= 0 */ format "->>9.99%"
                                column-label "(5)"
                 wplani.wacr-c(total) column-label "Acres(6)"
                 (wplani.wven-c - wplani.wdes-c + wplani.wacr-c) (total)
                                    format "->,>>>,>>9.99"
                       column-label "Vl.Bruta(7)"
                 ((wplani.wacr-c / wplani.wven-c) * 100)
                          column-label "M %(8)" format ">>9.99"
                 wplani.wdev-c(total) column-label "Devol(9)"
                        
                 (wplani.wven-c - wplani.wdes-c + wplani.wacr-c
                  - wplani.wdev-c)(total)
                        column-label "Vl.Liq.(10)"
                                    format "->,>>>,>>9.99"
                                            with frame f-imp width 190 down.

                tot-ven = tot-ven + wplani.wven-c.
                tot-mar = tot-mar + vvlmarg.
                tot-acr = tot-acr  + wplani.wacr-c.
                vtotalvlcus = vtotalvlcus + wplani.wcus-c.
                vtotal-liq = vtotal-liq + 
                        (wplani.wven-c - wplani.wdes-c + wplani.wacr-c
                  - wplani.wdev-c).
        end.
        display ((tot-mar / tot-ven) * 100) no-label format "->>9.99%" at 57
                ((tot-acr / tot-ven) * 100) no-label format "->>9.99%" at 91
                              with frame f-tot width 190 no-label no-box.
        
        run p-final.
        
        assign tot-ven = 0.
               tot-mar = 0.
               tot-acr = 0.
               vtotal-liq = 0.
               vtotalvlcus = 0.
               
    end.
    else do:
        for each wplani by wplani.wetbcod:

            vvlmarg = (wplani.wven-m - wplani.wdes-m - wplani.wcus-m).
            vvlperc = (vvlmarg * 100) / wplani.wven-m.
            if vvlperc = ?
            then vvlperc = 0.
            if wplani.wven-m = 0
            then next.


            find estab where estab.etbcod = wplani.wetbcod no-lock no-error.


            disp estab.etbcod column-label "Filial"
                 wplani.wcus-m(total) column-label "Vl.Custo(1)"
                 wplani.wdes-m(total) column-label "Desc(2)"
                         format ">>>,>>9.99"
                 wplani.wven-m(total) column-label "Vl.Venda(3)"
                 (wplani.wven-m - wplani.wdes-m - wplani.wcus-m)(total)                  column-label "Margem(4)" format "->,>>>,>>9"
                 vvlperc      /*  when vvlperc >= 0 */ format "->>9.99%"
                                column-label "(5)"
                 wplani.wacr-m(total) column-label "Acres(6)"
                 (wplani.wven-m - wplani.wdes-m + wplani.wacr-m) (total)
                                    format "->,>>>,>>9.99"
                                        column-label "Vl.Bruta(7)"
                 ((wplani.wacr-m / wplani.wven-m) * 100)
                             column-label "M %(8)" format ">>9.99"
                 wplani.wdev-m(total) column-label "Devol(9)"
                 (wplani.wven-m - wplani.wdes-m + wplani.wacr-m
                  - wplani.wdev-m)(total) 
                                column-label "Vl.Liq.(10)"
                                    format "->,>>>,>>9.99"
                                            with frame f-imp1 width 190 down.

                tot-ven = tot-ven + wplani.wven-m.
                tot-mar = tot-mar + vvlmarg.
                tot-acr = tot-acr  + wplani.wacr-m.
                vtotal-liq = vtotal-liq + (wplani.wven-m - wplani.wdes-m + wplani.wacr-m
                  - wplani.wdev-m).
                vtotalvlcus = vtotalvlcus + wplani.wcus-m.
        end.

        display ((tot-mar / tot-ven) * 100) no-label format "->>9.99%" at 56
                ((tot-acr / tot-ven) * 100) no-label format "->>9.99%" at 90
                              with frame f-tot width 190 no-label no-box.
        run p-final.
        
        assign tot-ven = 0.
               tot-mar = 0.
               tot-acr = 0.
               vtotal-liq = 0.
               vtotalvlcus = 0.
    end.

   
    
    output close.
    /*
    dos silent value("type " + varquivo + "  > prn").
    */
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
end.

procedure p-final:
    put skip(2).
    
    put "MARGEM MES...(11):" space(2)
          ((  (((tot-acr / tot-ven) * 100) + 100) / 
                      (100 - ((tot-mar / tot-ven) * 100)) - 1) * 100)
                      format "->>9.99 %".
    
    put skip(1).
    
    put "VERBA GERADA.(12):" (vtotal-liq * (if vcatcod = 31
                                        then 0.65
                                        else 0.54)) format "->>>,>>>,>>9.99".

    put skip.
    
    put "VERBA EFETIVA(13):" vtotalvlcus format "->>>,>>>,>>9.99".

    put skip.
    
    put "SALDO........(14):" ((vtotal-liq * (if vcatcod = 31 
                                         then 0.65  
                                         else 0.54)) - vtotalvlcus)
                                         format "->>>,>>>,>>9.99".
    
    put skip(2).
    put skip(1)
        "Glossario" skip
        "(1) - Somatorio da Quantidade Vendida multiplicado pelo Pc.Custo" skip
        "(2) - Somatorio dos Descontos de cada Venda" skip
        "(3) - Somatorio do Total de cada Venda" skip
        "(4) - Diferenca entre (3) - (2) - (1)" skip
        "(5) - Percentual de (3) e (1) - Vl.Venda pelo VlCusto" skip
        "(6) - Somatorio dos Acrescimos de cada Venda" skip
        "(7) - Resultado de (3) - (2) + (6)" skip
        "(8) - percentual de (6) / (3)" skip
        "(9) - Somatorio das Devolucoes de Venda" skip
        "(10)- Resultado de (3) - (2) + (6) - (9)"      skip

        
        "(11)- ((  ((((6) / (3)) * 100) + 100) / "
                      "(100 - (((4) / (3)) * 100)) - 1) * 100)" skip
        "(12)- ((10) * (se MOVEIS * 0,65 se nao * 0,54)) " skip
        "(13)- (1)" skip
        "(14)- (12) - (13) " skip
                               
                   skip.
 
 
 
end procedure.

procedure p-lebonusnf:
    
    find first titulo where titulo.empcod   = 19
                        and titulo.titnat   = yes
                        and titulo.clifor   = plani.desti 
                        and titulo.modcod   = "BON" 
                        and titulo.titdtpag = plani.pladat 
                        and titulo.titvlpag = plani.descprod no-lock no-error.
    if avail titulo
    then sresp = yes.

end procedure.

procedure p-lebonusdia:

    find first titulo where titulo.empcod = 19 and
                            titulo.titnat = yes and
                            titulo.modcod = "BON" and
                            titulo.titdtpag = plani.pladat and
                            titulo.clifor = plani.desti
                            no-lock no-error.
    if avail titulo
    then sresp = yes.                            

end procedure.

procedure p-lebonusmes:

    find first ttcli where ttcli.clifor = plani.desti no-error.
    if avail ttcli
    then sresp = yes.

end procedure.
