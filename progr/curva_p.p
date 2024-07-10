{admcab.i}

def var vlog    as log format "Sim/Nao" initial no.
def var vcopias as int.
def var visu as log format "Sim/Nao".

def temp-table tt-curpro
  field pos     like curpro.pos
  field cod     like curpro.cod
  field valven  like curpro.valven
  field qtdven  like curpro.qtdven
  field valcus  like curpro.valcus
  field qtdest  like curpro.qtdest
  field estcus  like curpro.estcus
  field estven  like curpro.estven
  field giro    like curpro.giro.

def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer btt-curpro for tt-curpro.
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
def stream stela.
def var vcomcod     like compr.comcod.

def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    update vdti  no-label
           "a"
           vdtf  no-label
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label format ">>9" 
           "a"
           vetbf no-label format ">>9" 
                    with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".

    update vcomcod label "Comprador" format ">>>9"
                with frame f-compr centered color blue/cyan row 15 side-labels.

    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                           
    if avail compr then display compr.comnom format "x(27)" no-label
                              with frame f-compr.                 
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                               with frame f-compr.
    else do:
                            
         message "Comprador não encontrado!" view-as alert-box.
         undo, retry.
         
    end.
             
                                    
    for each tt-curpro:
        delete tt-curpro.
    end.
    totcusto = 0.
    totvenda = 0.
    for each produ where (produ.catcod = vcatcod or
                         produ.catcod = vcatcod2)
                         no-lock:
                         
        if vcomcod > 0
        then do:
            release liped.
            release pedid.
            find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                  no-lock use-index liped2 no-error.

            find first pedid of liped no-lock no-error.
    
            if (avail pedid and pedid.comcod <> vcomcod)
                or not avail pedid
            then next.
                    
        end.
                    
        output stream stela to terminal.
        disp stream stela produ.procod produ.fabcod
                    with frame ffff centered
                                       color white/red 1 down.
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
        
        find first tt-curpro where tt-curpro.cod = produ.procod no-error.
        if not avail tt-curpro
        then do:
            create tt-curpro.
            find last btt-curpro no-error.
            if not avail btt-curpro
            then tt-curpro.pos = 1000000.
            else tt-curpro.pos = btt-curpro.pos + 1.
            tt-curpro.cod = produ.procod.
        end.

        vestven = 0.
        vcusto  = 0.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if not avail bestoq
            then next.
            
            vestven = vestven + (bestoq.estatual * bestoq.estvenda).
            vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
            tt-curpro.qtdest = tt-curpro.qtdest + bestoq.estatual.

            
        end.
        assign tt-curpro.estven = tt-curpro.estven + vestven
               tt-curpro.estcus = tt-curpro.estcus + vcusto.
               
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                            no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                for each contnf where contnf.etbcod = plani.etbcod and
                                      contnf.placod = plani.placod no-lock.
                    find contrato where contrato.contnum = contnf.contnum and
                                contrato.dtinicial >= plani.pladat
                                no-lock no-error.
                    if avail contrato
                    then do:
                        if contrato.vltotal > (plani.platot - plani.vlserv)
                        then v-ac = contrato.vltotal /
                                              (plani.platot - plani.vlserv).
                        if contrato.vltotal < (plani.platot - plani.vlserv)
                        then v-de = (plani.platot - plani.vlserv)
                                              / contrato.vltotal.
                    end.
                end.

                if (plani.platot - plani.vlserv) < 1
                then assign v-de = 0
                            v-ac = 0.
                end.


                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.


                tt-curpro.qtdven = tt-curpro.qtdven + movim.movqtm.
                if v-ac = 0 and v-de = 0
                then tt-curpro.valven = tt-curpro.valven +
                                    (movim.movqtm * movim.movpc).
                if v-ac > 0
                then tt-curpro.valven = tt-curpro.valven +
                                    ((movim.movqtm * movim.movpc) * v-ac).
                if v-de > 0
                then tt-curpro.valven = tt-curpro.valven +
                                    ((movim.movqtm * movim.movpc) / v-de).
                tt-curpro.valcus = 
                        tt-curpro.valcus + (movim.movqtm * estoq.estcusto).        
                v-ac = 0.
                v-de = 0.
            end.
        end.

    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curpro by tt-curpro.valven descending:
    
        tt-curpro.pos = i.
        tot-v = tot-v + tt-curpro.valven.
        tot-c = tot-c + (tt-curpro.valven - tt-curpro.valcus).
        i = i + 1.
    
    end.

    message "Imprimir todos produtos com estoque" update vlog.
    
    if opsys = "UNIX"
    then
        varquivo = "/admcom/relat/p" + string(time) +  STRING(day(today)) +
                              STRING(month(today)) +
                              string(categoria.catcod,"99").
    else
        varquivo = "l:\relat\p" + string(time) + STRING(day(today)) +
                              STRING(month(today)) +
                              string(categoria.catcod,"99").

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""curva_p""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CURVA ABC PRODUTOS EM GERAL - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    
    vacum = 0.

    for each tt-curpro by tt-curpro.pos:

        if vlog 
        then do:
            if tt-curpro.qtdest = 0
            then next.
        end.
        else do:
        
            if tt-curpro.estcus = 0 and
               tt-curpro.estven = 0 and
               tt-curpro.qtdven = 0 and 
               tt-curpro.qtdest = 0
            then next.
        
        end.
        
        vacum = vacum + ((tt-curpro.valven / tot-v) * 100).
        find produ where produ.procod = tt-curpro.cod no-lock no-error.

        tt-curpro.giro = (tt-curpro.estven / tt-curpro.valven).

        disp tt-curpro.pos format "99999" column-label "Pos."
             tt-curpro.cod format ">>>>>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(14)" column-label "Nome"
             tt-curpro.qtdven(total) format "->>>>>9"  column-label "Qtd.Ven"
             tt-curpro.valcus(total) format "->>,>>>,>>9.99" 
                                column-label "Vl.Custo"
             tt-curpro.valven(total) format ">>,>>>,>>9.99" 
                        column-label "Venda(6)"
             ((tt-curpro.valven / tot-v) * 100)(total)
                                 format "->>9.99" column-label "%S/VEN"
             vacum               format "->>9.99" column-label "% ACUM"
             (tt-curpro.valven - tt-curpro.valcus)(total) format "->>>>,>>9"
                                                      column-label "LUCRO"
             (((tt-curpro.valven - tt-curpro.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             tt-curpro.qtdest(total) format "->>>>,>>9"
                 column-label "Qtd.Est"
             tt-curpro.estcus(total) format "->,>>>,>>9" column-label "Est.Cus"
             tt-curpro.estven(total) format "->>,>>>,>>9" 
                                        column-label "Est.Ven"
             tt-curpro.giro when tt-curpro.giro > 0
                                 format ">>>>>9.99" column-label "Giro(1)"
             ((tt-curpro.valven / tt-curpro.valcus) - 1) * 100
                                format "->>>>9.99" column-label "Margem(2)"
                     with frame f-imp width 200 down.
    end.
    
    output close.
    
    message "Arquivo gerado em " varquivo " visualizar?" update visu.
    if visu
    then do:
        if opsys = "UNIX"
        then
            run visurel.p (input varquivo, input "").
        else
            {mrod.i}. 
    end.    
    
    /*
    output close.
    dos silent value("type " + varquivo + " > prn").
    */
    
end.
