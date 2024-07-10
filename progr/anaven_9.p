/******************************************************************************
* Programa  - anaven.p                                                        *
*                                                                             *
* Funcao    - 
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
******************************************************************************/

{admcab.i}

def new shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    .
     
def new shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    field mes-cto as int
    field cus-ent as dec
    field cus-med as dec
    index i1 ano-cto mes-cto etbcod procod
    .

def new shared var vdt like plani.pladat.
def new shared var t-sai   like plani.platot.
def new shared var t-ent   like plani.platot.
def new shared var vetbcod like estab.etbcod.
def new shared var vprocod like produ.procod.
def new shared var vdata1 like plani.pladat label "Data".
def new shared var vdata2 like plani.pladat label "Data".
def new shared var sal-ant   like estoq.estatual.
def new shared var sal-atu   like estoq.estatual.
def new shared var vdisp as log.

def var csresp as log format "Impressora/Tela".
def var recimp as recid.
def var vmovtdc like tipmov.movtdc.    

def var vmovtnom like tipmov.movtnom.
def var vtot like plani.platot.
def var vtotal like plani.platot.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].
def var vv as char format "x".
def var fila as char.

def temp-table tt-movim 
    field procod like produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like plani.numero
    field movtdc like tipmov.movtdc
    field tipemite as log label "Estoque" format "Saida/Entrada"

    index i1 procod
    index i2 pronom
    index i3 numero procod
    index i4 prorec.

def var varquivo as char format "x(20)".
def stream stela.
def var vnomtipmov like tipmov.movtnom.
def var vcatcod like categoria.catcod.
def var vtotdia like plani.platot.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vdata  as date.
def var vtotpro like plani.platot.
              /**** Campo usado para guardar o no. da planilha ****/

form plani.pladat format "99/99/9999" 
     plani.numero format ">>>>>>9"
     plani.emite column-label "Emite"
     plani.desti column-label "Dest" format ">>>>>>>>>9"
     movim.procod
     produ.pronom format "x(40)"
     movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     movim.movpc  format ">,>>9.99"
     vtotpro column-label "Total"
     vnomtipmov column-label "Movimento" format "x(25)"
     sal-atu column-label "Saldo" format "->>>>9"
                        with frame f-val down no-box width 140.

/*** prototipo para orcamento 12/06/2014 ***/
def var vEstab     as log  format "Sim/Nao"  init yes.
def var cestab     as char format "x(40)".
def temp-table wfestab
    field etbcod        like estab.etbcod init 0.
def buffer bwfestab    for wfestab.

def var vtipmov    as log  format "Sim/Nao"  init yes.
def var ctipmov    as char format "x(40)".
def temp-table wftipmov
    field movtdc        like tipmov.movtdc init 0.
def buffer bwftipmov    for wftipmov.

def var vtiporel   as log  format "Analitico/Sintetico" init yes.

form
    vEstab   colon 31 label "Todos Estabelecimentos.."
    cestab   no-label
    vdata1   colon 31 label "Periodo"
    vdata2   label "ate"
    vtipmov  colon 31 label "Todos os Tipos de Movimentacao"
    ctipmov  no-label
    vtiporel colon 31 label "Tipo de relatorio" help "Analitico/Sintetico"
    with frame fopcoes row 3 side-label width 80.

if sfuncod = 0
then do on error undo with frame fopcoes.

    {filtro-estab.i}

    update
        vdata1
        vdata2.

    {filtro-tipmov.i}

    update
        vtiporel.
end.

/*** ***/

repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    
    for each tt-movim.
        delete tt-movim.
    end.
    
    update vetbcod label "Estabelecimento  " with frame f1.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao cadastrada".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.    

    update vdata1 label "Periodo          " at 1
           vdata2 no-label with frame f1 side-labe centered
               color blue/cyan  title "Periodo" row 4.
           
    vmovtdc = 0.
    update vmovtdc at 1 label "Tipo de Movimento"
                with frame f1.
    if vmovtdc = 0
    then display "GERAL" @ tipmov.movtnom no-label with frame f1.
    else do:
        find tipmov where tipmov.movtdc = vmovtdc no-lock.
        disp tipmov.movtnom no-label with frame f1.
    end. 
    
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered.
    if frame-index = 1
    then vv = "N".
    else if frame-index = 2
         then vv = "A".
         else vv = "F".
    
    if opsys = "unix"
    then do:   
       csresp = no.
       message "Deseja imprimir relatorio ou visualizar em tela" update csresp.
       if csresp
       then do:
           find first impress where impress.codimp = setbcod no-lock no-error. 
           if avail impress
           then do:
               run acha_imp.p (input recid(impress), 
                               output recimp).
               find impress where recid(impress) = recimp no-lock no-error.
               assign fila = string(impress.dfimp). 
           end.
       end.
       
       varquivo = "/admcom/relat/anaven" + string(time).
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "140" 
            &Page-Line = "66" 
            &Nom-Rel   = ""anaven"" 
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO""" 
            &Tit-Rel   = """CONFERENCIA DAS NOTAS NA FILIAL "" +
                          string(vetbcod) +
                          "" - Data: "" + string(vdata1) + "" A "" +
                          string(vdata2)"
            &Width     = "140"
            &Form      = "frame f-cabcab"} 
    end.                    
    else do:
        assign fila = "" 
               varquivo = "l:\relat\aud" + string(time).     
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "167"
            &Page-Line = "66"
            &Nom-Rel   = ""anaven""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """CONF. DAS NOTAS NA "" +
                        ""FILIAL "" + string(vetbcod) +
                        ""  - Data: "" + string(vdata1) + "" A "" +
                            string(vdata2)"
            &Width     = "140"
            &Form      = "frame f-cabcab1"}
    end.
    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    
    for each tipmov where (if vmovtdc = 0
                           then true
                           else tipmov.movtdc = vmovtdc) no-lock.
        if tipmov.movtdc = 05 or
           tipmov.movtdc = 12 or
           tipmov.movtdc = 16 or
           tipmov.movtdc = 22 or
           tipmov.movtdc = 30
        then next.

        do vdata = vdata1 to vdata2.
            for each plani use-index plasai where plani.movtdc = tipmov.movtdc
                             and plani.desti  = vetbcod
                             and plani.pladat = vdata
                           no-lock.
                for each movim where
                             movim.movtdc = plani.movtdc and
                             movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat no-lock:
                    find produ where produ.procod = movim.procod and produ.etccod = 2
                               no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod <> vcatcod and vcatcod > 0
                    then next.

        
                    find first tt-movim where tt-movim.prorec = recid(movim)
                                     no-error.
                    if not avail tt-movim
                    then do:            
                        create tt-movim.
                        assign tt-movim.procod = produ.procod
                           tt-movim.pronom = produ.pronom
                           tt-movim.prorec = recid(movim)
                           tt-movim.numero = plani.numero
                           tt-movim.movtdc = plani.movtdc
                           tt-movim.tipemite = plani.emite = vetbcod.
                    end.        
                end.
            end.
            if vetbcod = 981
            then do:
                for each plani use-index plasai 
                            where plani.movtdc = tipmov.movtdc
                             and (plani.desti  = 115198 or
                                  plani.desti  = 115815)
                             and plani.pladat = vdata
                           no-lock.
                    for each movim where
                             movim.movtdc = plani.movtdc and
                             movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat no-lock:
                        find produ where produ.procod = movim.procod and produ.etccod = 2
                               no-lock no-error.
                        if not avail produ
                        then next.
                        if produ.catcod <> vcatcod and vcatcod > 0
                        then next.

        
                        find first tt-movim where 
                            tt-movim.prorec = recid(movim)
                                     no-error.
                        if not avail tt-movim
                        then do:            
                            create tt-movim.
                            assign tt-movim.procod = produ.procod
                                tt-movim.pronom = produ.pronom
                                tt-movim.prorec = recid(movim)
                                tt-movim.numero = plani.numero
                                tt-movim.movtdc = plani.movtdc
                                tt-movim.tipemite = plani.emite = vetbcod.
                        end.        
                    end.
                end.
            end.
        end.
    end.

    for each tipmov where (if vmovtdc = 0
                           then true
                           else tipmov.movtdc = vmovtdc) no-lock,
        each plani where plani.pladat >= vdata1       and
                         plani.pladat <= vdata2       and
                         plani.movtdc = tipmov.movtdc and
                         plani.etbcod = vetbcod no-lock,
     
        each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
    
        if plani.movtdc = 30 or
           plani.movtdc = 22
        then next.
                        
        find produ where produ.procod = movim.procod and produ.etccod = 2 no-lock no-error.
        if not avail produ
        then next.
        if produ.catcod <> vcatcod and vcatcod > 0
        then next.
        
        find first tt-movim where tt-movim.prorec = recid(movim) no-error.
        if not avail tt-movim
        then do:
            create tt-movim.
            assign tt-movim.procod = produ.procod
                   tt-movim.pronom = produ.pronom
                   tt-movim.prorec = recid(movim)
                   tt-movim.numero = plani.numero
                   tt-movim.movtdc = plani.movtdc
                   tt-movim.tipemite = plani.emite = vetbcod.
        end.
    end.     
    
    if vv = "A"
    then do:
        for each tt-movim use-index i2:
            
            find movim where recid(movim) = tt-movim.prorec no-lock.
            
            find produ where produ.procod = movim.procod and produ.etccod = 2 no-lock no-error.
            
            assign
                sal-atu = 0
                vdisp = no
                vtotmovim = 0
                vtotgeral = 0
                sal-atu = 0
                sal-ant = 0
                vprocod = produ.procod.

            /*** criar uma tt-produ e colocar o run ao criar o registro.
                Fica muito lento aqui ***/
            if vetbcod = 981
            then run movest10-e.p.
            else run movest10.p.

            /*
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
            */
             
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.

            if not avail plani
            then next.
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod and
               vetbcod <> 981
            then next.
            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if tipmov.movttra
            then if plani.emite = vetbcod
                 then vnomtipmov = tipmov.movtnom + " DE SAIDA".
                 else vnomtipmov = tipmov.movtnom + " DE ENTRADA".
            else vnomtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = movim.movpc * movim.movqtm.
        
            display plani.pladat format "99/99/9999" 
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro  column-label "Total"
                    vnomtipmov column-label "Movimento" format "x(25)"
                    sal-atu column-label "saldo" format "->>>>>9"
                                with frame f-val1 down no-box width 140.
                    down with frame f-val1.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot1 side-label.
    end.
    
    if vv = "N"
    then do:
        for each tt-movim use-index i1:
            find movim where recid(movim) = tt-movim.prorec no-lock.
            
            find produ where produ.procod = movim.procod and produ.etccod = 2 no-lock no-error.
            
            assign
                sal-atu = 0
                vdisp = no
                vtotmovim = 0
                vtotgeral = 0
                sal-atu = 0
                sal-ant = 0
                vprocod = produ.procod.

    
            if vetbcod = 981
            then run movest10-e.p.
            else run movest10.p.

            /****
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
            ***/
            
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.
            if not avail plani
            then next.
           
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod and
               vetbcod <> 981
            then next.


            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if tipmov.movttra
            then if plani.emite = vetbcod
                 then vnomtipmov = tipmov.movtnom + " DE SAIDA".
                 else vnomtipmov = tipmov.movtnom + " DE ENTRADA".
            else vnomtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        

            display plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro  column-label "Total"
                    vnomtipmov column-label "Movimento" format "x(25)"
                    sal-atu column-label "Saldo" format "->>>>>9"
                    
                                with frame f-val2 down no-box width 140.
                    down with frame f-val2.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot2 side-label.
    end.

    
    if vv = "F"
    then do:
        for each tt-movim use-index i3:
            find movim where recid(movim) = tt-movim.prorec no-lock.
            
            find produ where produ.procod = movim.procod and produ.etccod = 2 no-lock no-error.
            
            assign
                sal-atu = 0
                vdisp = no
                vtotmovim = 0
                vtotgeral = 0
                sal-atu = 0
                sal-ant = 0
                vprocod = produ.procod.

            if vetbcod = 981
            then run movest10-e.p.
            else run movest10.p.

            /****
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
            ***/
            
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.
            if not avail plani
            then next.
           
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod and
               vetbcod <> 981
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            else vnomtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).        

            display plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro  column-label "Total"
                    vnomtipmov column-label "Movimento" format "x(25)"
                    sal-atu column-label "saldo" format "->>>>>9"
                    with frame f-val3 down no-box width 140.
            down with frame f-val3.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot3 side-label.
    end.

    output stream stela to terminal.
    display stream stela vtotmovim label "Total "
                        with frame fstream side-label centered.
    output stream stela close.

    for each tt-movim break by tt-movim.movtdc
                            by tt-movim.tipemite:
        find movim where recid(movim) = tt-movim.prorec no-lock.

        vmovtnom = "".
        find tipmov where tipmov.movtdc = tt-movim.movtdc no-lock no-error.
        if avail tipmov
        then vmovtnom = tipmov.movtnom.
        vtot = vtot + (movim.movpc * movim.movqtm).
        vtotal = vtotal + (movim.movpc * movim.movqtm).
        
        if last-of(tt-movim.tipemite)
        then do:
            display tt-movim.movtdc
                    vmovtnom format "x(29)"
                    tt-movim.tipemite format "SAIDA/ENTRADA"
                    vtot(total) format ">>>,>>>,>>9.99"
                    no-label with frame f-tot down.
            vtot = 0.
        end.
    end.    

    disp skip(5)
        "Quem fez:" space(30)
        "Quem conferiu:"
        skip(4)
        fill("-",30) format "x(30)"
        space(9)
        fill("-",30) format "x(30)"
         skip
        "Assinatura"         at 11
        "Assinatura Gerente" at 47
        
        with frame f-ass.
    output close.
                        
    if opsys = "unix"
    then do:
        output close.
                     
        if csresp
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}
    end.
end.
