/*****************************************************************************
** Programa         : fin003.p
** Objetivo         : Planilha para Conferencia
** Autor            : Custom Business Solutions
** Data             : 21/10/96
****************************************************************************/

{ADMcab.i}

def temp-table wnota
    field crecod    like plani.crecod
    field sequen    as   int    format ">>>9"
    field serie     like plani.serie
    field numini    like plani.numero
    field numfin    like plani.numero
    field frete     like plani.frete     format ">,>>9.99"
    field acfprod   like plani.acfprod
    field produto   like plani.protot
    field valor     like plani.platot.
def var valortot like plani.platot.
def var vtot like wnota.valor.
def var vtotcre like wnota.valor.
def var d-dtini     as   date format "99/99/9999" init today no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var wacr like plani.acfprod.
def var vvltotal like plani.platot.
def var vvlcont like plani.platot.
def var wper as dec decimals 10.
def var vetbcod like estab.etbcod.

def buffer bcontnf for contnf.
def buffer bplani for plani.

form with down frame f2.

form vetbcod d-dtini label "Data Conferencia"
     with centered color white/cyan row 4 side-labels frame fsele.

    update vetbcod d-dtini with frame fsele.

    {confir.i 1 "Listagem para Conferencia"}
    for each plani where plani.movtdc = 5       and
                         plani.etbcod = vetbcod and
                         plani.pladat = d-dtini and
                         plani.notsit = no     no-lock
             break by plani.crecod
                   by plani.numero:

        if  plani.numero <> i-nota + 1
        then assign i-seq = i-seq  + 1.

        find first wnota where
                   wnota.crecod = plani.crecod and
                   wnota.sequen = i-seq no-lock no-error.

        if  not avail wnota then do:
            create wnota.
            assign wnota.crecod = plani.crecod
                   wnota.sequen = i-seq
                   wnota.serie  = plani.serie
                   wnota.numini = plani.numero.
        end.

        vvltotal = 0.
        vvlcont = 0.
        wacr = 0.
        if plani.crecod > 1
        then do:
            find first contnf where contnf.etbcod = plani.etbcod and
                                    contnf.placod = plani.placod no-lock.
            for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
                                   bcontnf.contnum = contnf.contnum no-lock:
                find bplani where bplani.etbcod = bcontnf.etbcod and
                                  bplani.placod = bcontnf.placod no-lock.
                if bplani.outras > 0
                then vvltotal = vvltotal + (bplani.outras - bplani.vlserv).
                else vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
            end.
            find contrato where contrato.contnum = contnf.contnum
                                            no-lock no-error.

            if avail contrato
            then do:
                vvlcont = contrato.vltotal.
                valortot = contrato.vltotal.
            end.

            wacr = vvlcont  - vvltotal.  /*plani.platot.*/

            if plani.outras > 0
            then wper = plani.outras / vvltotal.
            else wper = plani.platot / vvltotal.

            wacr = wacr * wper.

        end.
        else do:
            wacr = plani.acfprod.

            if plani.outras > 0
            then valortot = plani.outras.
            else valortot = plani.platot.
        end.

        if plani.outras > 0
        then valortot = plani.outras - plani.vlserv.
        else valortot = plani.platot - plani.vlserv.
        valortot = valortot + wacr.

        if wacr < 0
        then wacr = 0.

        assign wnota.frete   = wnota.frete   + plani.frete
               wnota.acfprod = wnota.acfprod + wacr
               wnota.produto = wnota.produto + (plani.protot - plani.descprod)
               wnota.valor   = wnota.valor + valortot
               wnota.numfin  = plani.numero
               i-nota        = plani.numero.
    end.



    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "60"
        &Page-Line = "66"
        &Cond-Var  = "80"
        &Width     = "80"
        &Nom-Rel   = ""FIN003""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   =
           """Planilha para Conferencia: "" +
                     string(d-dtini) "
        &Form      = "frame f-cabcab"}

    form with frame f2.
    for each wnota
        break by wnota.crecod with frame f2:

        if  first-of(wnota.crecod)
        then do:
            find crepl where
                 crepl.crecod = wnota.crecod no-lock no-error.
            put skip(2)
                crepl.crenom
                skip(1).
        end.
        disp wnota.serie            column-label "Serie" space(4)
             wnota.numini           column-label "Inicial"
             wnota.numfin           column-label "Final"
             wnota.frete  (total by wnota.crecod) column-label "Frete"
             wnota.acfprod(total by wnota.crecod)   column-label "Ac.Financ"
             wnota.produto(total by wnota.crecod)   column-label "Produto"
             wnota.valor  (total by wnota.crecod)   column-label "Total"
             with frame f2 down width 80 no-box.
        down with frame f2.
    end.
