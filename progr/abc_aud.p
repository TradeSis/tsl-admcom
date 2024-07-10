{admcab.i}
def var vv as int.
def var xx as int.
def var vlog    as log format "Sim/Nao" initial no.
def var vcopias as int.

def temp-table tt-curpro
  field pos     like curpro.pos
  field pronom  like produ.pronom
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

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    for each tt-curpro:
        delete tt-curpro.
    end.
    totcusto = 0.
    totvenda = 0.
    for each produ where produ.catcod = vcatcod or
                         produ.catcod = vcatcod2
                         no-lock:
        output stream stela to terminal.
        disp stream stela produ.procod produ.fabcod
                    with frame ffff centered
                                       color white/red 1 down.
        pause 0.
        output stream stela close.
        
        
        find first tt-curpro where tt-curpro.cod = produ.procod no-error.
        if not avail tt-curpro
        then do:
            create tt-curpro.
            find last btt-curpro no-error.
            if not avail btt-curpro
            then tt-curpro.pos = 1000000.
            else tt-curpro.pos = btt-curpro.pos + 1.
            tt-curpro.cod = produ.procod.
            tt-curpro.pronom = produ.pronom.
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
            
            assign tt-curpro.estven = bestoq.estvenda
                   tt-curpro.estcus = bestoq.estcusto.


            
        end.
        
        /*
        assign tt-curpro.estven = tt-curpro.estven + vestven
               tt-curpro.estcus = tt-curpro.estcus + vcusto.
               
        */
        
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
                    if plani.biss > (plani.platot - plani.vlserv)
                    then v-ac = plani.biss / (plani.platot - plani.vlserv).

                    if plani.biss < (plani.platot - plani.vlserv)
                    then v-de = (plani.platot - plani.vlserv)
                                              / plani.biss.
                end.

                if plani.platot < 1
                then assign v-de = 0
                            v-ac = 0.


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
    
    

/*     message "Somente produtos com saldo ?" update vlog. */
    


    varquivo = "..\relat\abc" + string(day(today)) +
                                string(month(today)) +
                                string(categoria.catcod,"99").

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "140"
            &Page-Line = "0"
            &Nom-Rel   = ""abc_aud.p""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CURVA ABC PRODUTOS - FILIAL "" +
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

    xx = 0.
    vv = 0.
    vlog = no.
    for each tt-curpro by tt-curpro.pronom:

        
        if vlog 
        then do:
            if tt-curpro.qtdest = 0
            then next.
        end.
        else do:
        
            if tt-curpro.qtdven = 0  
            then next.
        
        end.
        
        
        vacum = vacum + ((tt-curpro.valven / tot-v) * 100).
        if vacum >= 80
        then do:
            vv = vv + 1.
            if vv mod 5 = 0
            then assign vv = 0
                        xx = xx + 1.
            else next.
        
        end.
        if xx > 30
        then leave.

        find produ where produ.procod = tt-curpro.cod no-lock no-error.

        tt-curpro.giro = (tt-curpro.estven / tt-curpro.valven).

        disp /* tt-curpro.pos format "9999" column-label "Pos." */
             tt-curpro.cod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(35)" column-label "Nome"
             tt-curpro.valven(total) format ">>,>>>,>>9.99"  
                    column-label "Val.Ven"
/*             vacum                            */
             tt-curpro.qtdest(total) format "->>>>>9"    
                    column-label "Qtd!Estoque"
             tt-curpro.estcus(total) format "->,>>9.99" 
                    column-label "Preco!Custo"
             tt-curpro.estven(total) format "->,>>9.99" 
                    column-label "Preco!Venda"
             "___________"                           
                     with frame f-imp width 200 down.
    end.
    
    {mrod.i}. 
    
    
end.
