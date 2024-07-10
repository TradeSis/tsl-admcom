{admcab.i}

def var vlcontrato like contrato.vltotal.
def var vtotal_platot  like plani.platot.
def var ii as int.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.

def var vetb as i.
def var vano as int.
def var vmes as int.
def var varquivo as char format "x(20)".

def temp-table tt-curva
  field pos    like curva.pos
  field cod    like curva.cod
  field valven like curva.valven
  field qtdven like curva.qtdven
  field valcus like curva.valcus
  field qtdest like curva.qtdest
  field estcus like curva.estcus
  field estven like curva.estven
  field giro   like curva.giro.

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
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vfabcod     like produ.fabcod.
def stream stela.
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

    update vfabcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan row 8.
    find fabri where fabri.fabcod = vfabcod no-lock.
    disp fabri.fabnom no-label with frame f-depf.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 12
                                    title " Periodo ".

    update vetbi label "Filial" 
           vetbf label "Filial" with frame f-etb side-label centered
                                            color blue/cyan.
    varquivo = "..\relat\fr" + STRING(vetb) +
                                  STRING(month(today)) +
                                  string(categoria.catcod,"99").

    
    do vetb = vetbi to vetbf:
        {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "150"
                &Page-Line = "66"
                &Nom-Rel   = ""tt-curvaFP""
                &Nom-Sis   = """SISTEMA DE ESTOQUE"""
             &Tit-Rel   = """tt-curva ABC PRODUTOS POR FORNECEDOR - FILIAL "" +
                                  string(vetb,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
                &Width     = "150"
                &Form      = "frame f-cabcab"}

         
        for each tt-curva:
            delete tt-curva.
        end.
        
        for each produ where (produ.catcod = vcatcod or
                              produ.catcod = vcatcod2) and
                              produ.fabcod = fabri.fabcod no-lock:
            
                
            find first bmovim where bmovim.etbcod = vetb and
                                    bmovim.procod = produ.procod and
                                    bmovim.movtdc = 5 and
                                    bmovim.movdat >= vdti and
                                    bmovim.movdat <= vdtf no-lock no-error.
            if not avail bmovim
            then next.

            output stream stela to terminal.
            disp stream stela produ.procod with frame ffff centered
                                           color white/red 1 down.
            pause 0.
            output stream stela close.

            find first tt-curva where tt-curva.cod = produ.procod no-error.
            if not avail tt-curva
            then do:
                create tt-curva.
                find last tt-curva no-error.
                if not avail tt-curva
                then tt-curva.pos = 1000000.
                else tt-curva.pos = tt-curva.pos + 1.
                tt-curva.cod = produ.procod.
            end.

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5 and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf and
                                 movim.etbcod = vetb no-lock:
                
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.

                vlcontrato = plani.platot - plani.vlserv - descprod.
                
                if avail plani and plani.crecod = 2
                then vlcontrato = plani.biss.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / (plani.platot - plani.vlserv) ) ) > 0
                then do:
                    assign
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm
                    tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) 
                                       - vlserv).
                                    /* *   ( vlcontrato / 
                                        (plani.platot - plani.vlserv)) ).
                                      */
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod no-lock
                                                no-error.
                    if avail estoq
                    then assign tt-curva.valcus = tt-curva.valcus + 
                                (movim.movqtm * estoq.estcusto).
                end.

                
            end.
            
            /* dev 

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 12 and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf and
                                 movim.etbcod = vetb no-lock:
                
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.

                vlcontrato = plani.platot - plani.vlserv.
                
                if avail plani and plani.crecod = 2
                then vlcontrato = plani.biss.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / (plani.platot - plani.vlserv) ) ) > 0
                then do:
                    assign
                    tt-curva.qtdven = tt-curva.qtdven - movim.movqtm
                    tt-curva.valven = tt-curva.valven - 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / 
                                        (plani.platot - plani.vlserv)) ).
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod no-lock
                                                no-error.
                    if avail estoq
                    then assign tt-curva.valcus = tt-curva.valcus - 
                                (movim.movqtm * estoq.estcusto).
                end.

                
            end.
            
            dev */
            
            do ii = vetbi to vetbf:
                find estoq where estoq.etbcod = ii and
                                 estoq.procod = produ.procod no-lock no-error.
                if avail estoq
                then assign
                tt-curva.qtdest = tt-curva.qtdest + estoq.estatual
                tt-curva.estcus = tt-curva.estcus +
                                  (estoq.estatual * estoq.estcusto)
                tt-curva.estven = tt-curva.estven +
                                  (estoq.estatual * estoq.estvenda).

            end.
        end.

        i = 1.
        tot-v = 0.
        tot-c = 0.
        for each tt-curva by tt-curva.valven descending:
            tt-curva.pos = i.
            tot-v = tot-v + tt-curva.valven.
            tot-c = tot-c + (tt-curva.valven - tt-curva.valcus).
            i = i + 1.
        end.

        disp categoria.catcod label "Departamento"
             categoria.catnom no-label with frame f-dep2 side-label.
        disp fabri.fabcod label "Fornecedor"
             fabri.fabnom no-label with frame f-dep22 side-label.
        vacum = 0.
        for each tt-curva by tt-curva.pos:
            if tt-curva.qtdven = 0 and
               tt-curva.estcus = 0 and
               tt-curva.estven = 0
            then next.
            vacum = vacum + ((tt-curva.valven / tot-v) * 100).
            find produ where produ.procod = tt-curva.cod no-lock no-error.
            tt-curva.giro = (tt-curva.estven / tt-curva.valven).

            disp tt-curva.pos format "9999" column-label "Pos."
                 tt-curva.cod format ">>>>>9" column-label "Codigo"
                 produ.pronom when avail produ format "x(35)" 
                                              column-label "Nome"
                 tt-curva.qtdven(total) format "->>>,>>9" column-label "Qtd.Ven"
                 tt-curva.valcus(total) format "->>>,>>9.99"
                                                        column-label "Val.Cus"
                 tt-curva.valven(total) format "->>>,>>9.99" 
                                            column-label "Val.Ven"             
                 ((tt-curva.valven / tot-v) * 100)(total) format "->>9.99"
                                        column-label "%S/VEN"                 
                 vacum   format "->>9.99" column-label "% ACUM"
                 (tt-curva.valven - tt-curva.valcus)(total) 
                            format "->>>,>>9.99" column-label "LUCRO"
                 (((tt-curva.valven - tt-curva.valcus) / tot-c) * 100)(total)
                            format "->>9.99"     column-label "%P/MAR"
                tt-curva.qtdest(total) 
                            format "->>>,>>9"    column-label "Qtd.Est"
                tt-curva.estcus(total) 
                            format "->>>,>>9.99" column-label "Est.Cus"
                tt-curva.estven(total) 
                            format "->>>,>>9.99" column-label "Est.Ven"
                tt-curva.giro when tt-curva.giro > 0
                            format "->>9.99" column-label "Giro"
                with frame f-imp width 200 down. 
        end.
        output close.
    
        {mrod.i} /*
        run visurel.p (input varquivo, input "").*/
        

    end.
      /*  dos silent value("type " + varquivo + " > prn"). */
end.
