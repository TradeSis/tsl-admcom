{admcab.i}


def input param vcatcod like produ.catcod.
def input param vdt     as   date format "99/99/9999".
def input param vetb    like estab.etbcod.

def var vpos as i.
def var vqtd as i.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var i as i.

def stream stela.
def buffer bprodu for produ.
def temp-table wf-ger
        field pos  as int
        field cod  like produ.procod
        field valor like plani.platot.

def temp-table wf-fil
        field pos  as int
        field cod  like produ.procod
        field valor like plani.platot
        field qtd   as i.

/*repeat:*/
    for each wf-ger:
        delete wf-ger.
    end.
    for each wf-fil:
        delete wf-fil.
    end.

    /*update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.*/
    
    find categoria where categoria.catcod = vcatcod no-lock.
    /*disp categoria.catnom no-label with frame f-dep.*/

/*    update vdt label "Data Final"
           with frame f-dep.*/

/*    update vetb with frame f-dep.*/

    i = 0.
    for each impor where impor.desti = vcatcod and
                         impor.data  = vdt no-lock by numnot desc:
        i = i + 1.
        create wf-ger.
        assign wf-ger.pos   = i
               wf-ger.cod   = impor.emite
               wf-ger.valor = numnot.
        if i = 50
        then leave.
    end.
    i = 0.
    for each ctti where ctti.etbcod   = vetb    and
                        ctti.controle = vcatcod and
                        ctti.funcao   = string(month(vdt)) +
                                        string(year(vdt))
                                            no-lock by ctti.preco desc.
        if ctti.quantid = 0
        then next.
        i = i + 1.
        create wf-fil.
        assign wf-fil.pos = i
               wf-fil.cod = ctti.procod
               wf-fil.valor = ctti.preco
               wf-fil.qtd   = ctti.quantid.
        if i = 500
        then leave.
    end.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat-auto/Encerra/" +  
                    STRING(month(today)) + "-" + string(vetb,"999")  + ".txt".
    else varquivo = "l:~\relat-auto~\Encerra~\" +
                              STRING(month(today)) + 
                              string(vetb,"999") + ".txt".

    
    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""rel-ote""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """ABC PRODUTOS EM GERAL - DA FILIAL "" +
                                  string(vetb,"">>9"") +
                          "" PERIODO DE "" + string(vdt,""99/99/9999"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    put "      C U R V A  G E R A L            " TO 57
        "      C U R V A   F I L I A L " TO 119 vetb SKIP(1).
    do i = 1 to 50:
        find first wf-ger where wf-ger.pos = i no-lock no-error.
        if not avail wf-ger
        then next.
        find produ where produ.procod = wf-ger.cod no-lock no-error.
        if not avail produ then next.
        
        find first wf-fil where wf-fil.cod = produ.procod no-lock no-error.
        if avail wf-fil
        then assign vpos = wf-fil.pos
                    vqtd = wf-fil.qtd.
        else assign vqtd = 0
                    vpos = 0.

        find first wf-fil where wf-fil.pos = i no-lock no-error.
        if avail wf-fil
        then find bprodu where bprodu.procod = wf-fil.cod no-lock no-error.

        disp wf-ger.pos format "99" column-label "Pos.Geral"
            when avail wf-ger
             vpos  format "999" column-label "Pos.Fil."
             vqtd  column-label "Qtd" format ">>,>>9" space(3)
             produ.procod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ column-label "Nome"
             space(6)
             wf-fil.pos
                when avail wf-fil format "999" column-label "Pos." space(3)
             bprodu.procod when avail wf-fil
                    format ">>>>>9" column-label "Codigo"
             bprodu.pronom when avail wf-fil column-label "Nome"
                     with frame f-imp width 200 down.
        down with frame f-imp.
    end.
    output close.
    
    if opsys = "UNIX"
    then do:
    /*    run visurel.p(varquivo,"").   */
    end.
    else do:
        {mrod.i} 
    end.

    /*    
    dos silent value("type " + varquivo + " > prn").
     */
/*end.*/
