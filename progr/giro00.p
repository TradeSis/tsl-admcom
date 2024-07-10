{admcab.i}
def buffer bclase for clase.
def var vclasup like clase.clasup.
def var vclacod like clase.clacod.

def temp-table tt-giro
   field procod   like produ.procod
   field gqtdven  like plani.platot
   field gvalcus  like plani.platot
   field gvalven  like plani.platot
   field gqtdest  like plani.platot
   field gvestcus like plani.platot
   field gvestven like plani.platot
   field giro     like plani.platot.


def var vdia as int.
def var ii as i.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vestcus  like estoq.estcusto.
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
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
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

def var vcontnotas as int. 

def var valven like plani.platot. 
def var qtdven like plani.platot.
def var valcus like plani.platot.
def var qtdest like plani.platot.
def var estcus like plani.platot.
def var estven like plani.platot.
def var giro   like plani.platot.

def temp-table tt-catcod
    field catcod like produ.catcod.

repeat:
    for each tt-giro:
        delete tt-giro.
    end.
    for each tt-catcod:
        delete tt-catcod.
    end.
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

        
    update vclasup at 01 with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.

    update vclacod at 01 label "Classe Inferior" with frame f-dat side-label.
    if vclacod = 0
    then display "GERAL" @ bclase.clanom with frame f-dat.
    else do:
        find bclase where bclase.clacod = vclacod no-lock.
        display bclase.clanom no-label with frame f-dat.
    end.


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
                               
    update vdti label "Periodo        " at 01
           "a"
           vdtf no-label 
           vdia label "Dias de compras" at 01
                with frame f-dat centered color blue/cyan row 8 side-label.

    
    vetbi = 1.
    vetbf = 999.
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
        
    totcusto = 0.
    totvenda = 0.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/giro" + STRING(day(today)) +
                                      STRING(month(today)) +
                                      string(categoria.catcod,"99") +
                                      "." + string(time).
    else varquivo = "l:\relat\giro" + STRING(day(today)) +
                              STRING(month(today)) +
                string(categoria.catcod,"99") + "." + string(time).

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""giro00""
            &Nom-Sis   = """SISTEMA DE COMPRAS"""
            &Tit-Rel   = """GIRO DE MERCADORIAS VENDIDAS - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    
    disp categoria.catcod label "Departamento"
         categoria.catnom no-label 
         vdia label "Dias de Compras" with frame f-dep2 side-label.


    for each tt-catcod no-lock,
        each clase where (if vclasup = 0
                          then true 
                          else clase.clasup = vclasup) and
                         (if vclacod = 0
                          then true
                          else clase.clacod = vclacod),
        each produ where produ.clacod = clase.clacod and
                         produ.catcod = tt-catcod.catcod no-lock.
        
        assign valven = 0
               qtdven = 0
               valcus = 0
               qtdest = 0
               vestcus  = 0
               vestven  = 0
               giro    = 0.


         output stream stela to terminal.
            disp stream stela 
                        produ.catcod
                        produ.pronom
                        produ.procod 
                        produ.fabcod
                           with frame ffff centered
                                            color white/red 1 down.
            pause 0.
        output stream stela close.

        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 4            and
                                bmovim.movdat >= vdti - vdia and
                                bmovim.movdat <= vdti no-error.
        if not avail bmovim
        then do:
            find first bmovim where bmovim.procod = produ.procod and
                                    bmovim.movtdc = 1            and
                                    bmovim.movdat >= vdti - vdia and
                                    bmovim.movdat <= vdti no-error.
            if not avail bmovim
            then next.
        end.

        vestven = 0.
        vestcus = 0.
        ii = 0.
        do ii = vetbi to vetbf:
            find estoq where estoq.etbcod = ii and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then assign vestven = vestven + (estoq.estatual * estoq.estvenda) 
                        vestcus = vestcus + (estoq.estatual * estoq.estcusto)
                        qtdest = qtdest + estoq.estatual.
        end.

        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
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
                then do:
                    vtotal_platot = 0.
                    find first bcontnf 
                        where bcontnf.etbcod = plani.etbcod and
                              bcontnf.placod = plani.placod no-lock no-error.
                    if available bcontnf
                    then do:
                        find contrato 
                                where contrato.contnum = bcontnf.contnum 
                                no-lock no-error.
                        if available contrato
                        then vlcontrato = contrato.vltotal.
                        else vlcontrato = plani.platot.
                    end.
                end.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    assign qtdven = qtdven + movim.movqtm
                           valven = valven + 
                                    ( ( movim.movqtm * movim.movpc ) * 
                                      ( vlcontrato / plani.platot ) ).
                    
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod 
                                            no-lock no-error.
                    if avail estoq
                    then assign
                        valcus = valcus + (movim.movqtm * estoq.estcusto). 
                end.
            end.
        end.
        

        create tt-giro.
        assign tt-giro.procod  = produ.procod
               tt-giro.gqtdven = qtdven
               tt-giro.gvalcus = valcus
               tt-giro.gvalven = valven
               tt-giro.gqtdest = qtdest
               tt-giro.gvestcus = vestcus
               tt-giro.gvestven = vestven
               tt-giro.giro     = (vestven / valven).

    end.
    for each tt-giro by tt-giro.giro:

        find produ where produ.procod = tt-giro.procod no-lock.
        
        
        disp produ.procod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(30)" column-label "Nome"
             tt-giro.gqtdven(total) 
                        format "->>>,>>9" column-label "Qtd.Ven"
             tt-giro.giro when tt-giro.giro > 0
                                 format ">>,>>9.99" column-label "Giro"
             tt-giro.gqtdest(total) 
                        format "->>>,>>9"    column-label "Qtd.Est"
             tt-giro.gvalcus(total) 
                        format "->>>,>>9" column-label "Val.Cus"
             tt-giro.gvalven(total) 
                        format "->>>,>>9" column-label "Val.Ven"
             (tt-giro.gvalven - tt-giro.gvalcus)(total) 
                        format "->>>,>>9" column-label "LUCRO"
             tt-giro.gvestcus(total) 
                        format "->,>>>,>>9" column-label "Est.Cus"
             tt-giro.gvestven(total) format "->>>,>>>,>>9" 
                                                column-label "Est.Ven"
             ((tt-giro.gvalven / tt-giro.gvalcus) - 1) * 100
                                 format "->>9.99 %" column-label "Margem"
                                   with frame f-imp width 200 down.
    end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
        {mrod.i}
    end.
end.


