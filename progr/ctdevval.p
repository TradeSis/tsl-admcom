/*
#1 18.10.17 - P2K
#2 03.04.19 - TP 30127261
#3 16.05.19 - Sala Guerra Tesouraria/Financeiro
*/
{admcab.i}

def var vetbcod like estab.etbcod.
def var vdatini as date.
def var vdatfin as date.
def buffer ctitulo for titulo.

/*#2*/
def var vtitrel as char.
def var vcategoria as int.
def var mcatcod as int extent 2 init [31,41].
def var mcatnom as char format "x(15)" extent 2 init ["MOVEIS", "MODA"].

disp mcatnom with frame f-categoria no-label centered title " Categoria ".
choose field mcatnom with frame f-categoria.
vcategoria = frame-index.
vtitrel    = " DEVOLUCAO DE " + mcatnom[vcategoria].
/*#2*/

form vetbcod label "Filial"
    help "Informe a Filial ou 0 para todas"
    estab.etbnom no-label
    vdatini at 1  label "Periodo de" format "99/99/9999"
    vdatfin label "Ate" format "99/99/9999"
    with frame f-p1 side-label width 80 1 down color with/cyan.
     
do on error undo with frame f-p1:
    update vetbcod.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada." view-as alert-box.
            undo.    
        end.
        disp estab.etbnom.
    end.
    else disp "Geral" @ estab.etbnom.
    update vdatini validate(vdatini <> ?,"").
    update vdatfin validate(vdatfin <> ? and vdatfin >= vdatini,"").
end.

def temp-table tt-filial
    field etbcod   like estab.etbcod
    field etbnom   like estab.etbnom
    field valvista as dec
    field valprazo as dec
    field valpago  as dec
    field valdevol as dec
    field qtd-plani as int
    field valdevolvido_av as dec /*#3 */
    index i1 etbcod.

def temp-table tt-datap
    field pladat as date
    field conta  as int
    field contrato as dec
    field nfvenda as int
    field dtvenda as date
    field nfdevol as int
    field valquitado as dec
    field valdevolvido as dec
    field valdevolvido_av as dec  /*#3 */.
    
def var ventrada as dec.
def var vsaida as dec.
def var vorigem as dec.
def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.
def var vtitdev as dec.
def var vtitpag as dec.
def var vvista as dec.
def var vprazo as dec.
def var vvaldevolvido_av as dec.
def var vclifor as int.
def var vcontrato like contnf.contnum.
def var vconta-plani as integer.
def var vok-categoria as log.

def temp-table tt-plaqtd
    field placod like plani.placod.
    
format "Processando ........>>>  "
    with frame f-processa 1 down no-box
    centered row 10 no-label.    

for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true) no-lock:
    disp estab.etbcod with frame f-processa.
    pause 0.
    assign
        ventrada = 0
        vsaida  = 0
        vorigem = 0
        vvista  = 0
        vprazo  = 0
        vtitdev = 0
        vtitpag = 0
        vconta-plani = 0
        vvaldevolvido_av = 0.

    for each tt-plaqtd: delete tt-plaqtd. end.
    
    for each ctdevven where ctdevven.etbcod = estab.etbcod and
                            ctdevven.pladat >= vdatini and
                            ctdevven.pladat <= vdatfin and
                            ctdevven.placod-ven = 0
                      no-lock break by ctdevven.placod :
        disp ctdevven.pladat with frame f-processa.
        pause 0.
        vok-categoria = no.
        if first-of(ctdevven.placod)
        then do: 
            find first plani where plani.movtdc = ctdevven.movtdc and
                                   plani.etbcod = ctdevven.etbcod and
                                   plani.placod = ctdevven.placod
                          no-lock no-error.
            if not avail plani
            then next.
            disp plani.numero with frame f-processa.
            pause 0.
            vok-categoria = no.
            for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                vclifor = movim.ocnum[7].
                ventrada = ventrada + (movim.movpc * movim.movqtm).
                find produ where produ.procod = movim.procod no-lock no-error.
                if avail produ and produ.catcod = mcatcod[vcategoria] /*#2 31*/
                then vok-categoria = yes.    
            end.
        end.
        if not vok-categoria
        then next.
        
        find first tt-plaqtd where tt-plaqtd.placod = ctdevven.placod
                   no-lock no-error.
        if not avail tt-plaqtd
        then do:
            create tt-plaqtd.
            tt-plaqtd.placod = ctdevven.placod.
            vconta-plani = vconta-plani + 1.
        end. 
        
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                                bplani.etbcod = ctdevven.etbcod-ven and
                                bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.        
        if avail bplani
        then
            for each bmovim where bmovim.movtdc = bplani.movtdc and
                                  bmovim.etbcod = bplani.etbcod and
                                  bmovim.placod = bplani.placod
                             no-lock:
                vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
            end.

        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                                cplani.etbcod = ctdevven.etbcod-ori and
                                cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
        if avail cplani
        then do:
            for each cmovim where cmovim.movtdc = cplani.movtdc and
                                  cmovim.etbcod = cplani.etbcod and
                                  cmovim.placod = cplani.placod
                             no-lock:
                vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
            end.              
            find first contnf where contnf.etbcod = cplani.etbcod and
                                    contnf.placod = cplani.placod
                              no-lock no-error.
            vclifor = cplani.desti.
            if avail contnf
            then vcontrato = contnf.contnum.
            else vcontrato = cplani.numero.

            find first tt-datap where 
                   tt-datap.pladat   = ctdevven.pladat and
                   tt-datap.nfdevol  = ctdevven.numero and
                   tt-datap.conta    = vclifor and
                   tt-datap.contrato = vcontrato
                    no-error.
            if not avail tt-datap
            then do:
                create tt-datap.
                assign
                    tt-datap.pladat   = ctdevven.pladat
                    tt-datap.nfdevol  = ctdevven.numero
                    tt-datap.conta    = vclifor
                    tt-datap.contrato = vcontrato.
            end. 
            tt-datap.nfvenda = cplani.numero.
            tt-datap.dtvenda = cplani.pladat.
            
            if avail contnf
            then                    
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                if titulo.titdtemi = cplani.pladat and
                   titulo.moecod = "DEV" and
                   titulo.etbcob = ?
                then assign
                   vtitpag = vtitpag + titulo.titvlcob
                   tt-datap.valquitado = tt-datap.valquitado + titulo.titvlcob.
                else if titulo.etbcob = cplani.etbcod and
                        titulo.moecod <> "DEV" and
                        (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                then assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlpag
                 vtitdev = vtitdev + titulo.titvlpag.
            end.
            else do:
                find first ctitulo where ctitulo.empcod = 19 and
                                         ctitulo.titnat = yes and
                                         ctitulo.modcod = "DEV" and
                                         ctitulo.etbcod = cplani.etbcod and
                                         ctitulo.clifor = cplani.desti  and
                                         ctitulo.titnum = string(vcontrato) and
                                  /*#2*/ ctitulo.titdtemi = cplani.pladat
                                        no-lock no-error.
                if avail ctitulo
                then do:
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
 
                    end.
                end.
                else do:
                    find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock no-error.
                    if avail titulo
                    then do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                    end.
                    else do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(ctdevven.numero) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                           assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                     end.
                end.
            end.
            if cplani.crecod = 1
            then do.
                vvista = vvista + cplani.platot.

                /* #2 Valor devolvido a vista */                
                for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = cplani.modcod
                      and titulo.etbcod = cplani.etbcod
                      and titulo.clifor = cplani.desti
                      and titulo.titnum = cplani.serie + string(cplani.numero)
                    no-lock.
                    if titulo.moecod = "REA"
                    then assign
                          tt-datap.valdevolvido_av = tt-datap.valdevolvido_av +
                                                    titulo.titvlcob
                          vvaldevolvido_av = vvaldevolvido_av + titulo.titvlcob.
                    else if titulo.moecod = "PDM"
                    then
                        for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar and
                          titpag.moecod = "REA"
                        no-lock:
                          tt-datap.valdevolvido_av = tt-datap.valdevolvido_av +
                                titpag.titvlpag.
                          vvaldevolvido_av = vvaldevolvido_av + titpag.titvlpag.
                        end.
                end.
            end.
            else vprazo = vprazo + cplani.platot. 
        end.
    end.

    find first tt-filial where tt-filial.etbcod = estab.etbcod no-error.
    if not avail tt-filial
    then do:
        create tt-filial.
        assign
            tt-filial.etbcod = estab.etbcod
            tt-filial.etbnom = estab.etbnom.
    end.
    assign    
        tt-filial.valvista  = tt-filial.valvista + vvista
        tt-filial.valprazo  = tt-filial.valprazo + vprazo
        tt-filial.valpago   = tt-filial.valpago  + vtitpag
        tt-filial.valdevol  = tt-filial.valdevol + vtitdev
        tt-filial.qtd-plani = tt-filial.qtd-plani + vconta-plani
        tt-filial.valdevolvido_av = tt-filial.valdevolvido_av +
                             vvaldevolvido_av.
end.
hide frame f-processa.


def var varquivo as char.

if opsys = "UNIX"
then varquivo = "../relat/ctdevval" + string(vetbcod,"999") + 
                "." + string(time).
else varquivo = "l:~\relat~\ctdevval" + string(vetbcod,"999").

{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""ctdevval""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = "vtitrel"
            &Width     = "130"
            &Form      = "frame f-cabcab"}

DISP WITH FRAME F-P1.

if vetbcod = 0
then
    for each tt-filial where tt-filial.qtd-plani > 0 by tt-filial.etbcod:
        disp
            tt-filial.etbcod no-label
            tt-filial.etbnom    column-label "Filial"    format "x(20)"
            tt-filial.valvista  column-label "A Vista"   format ">>,>>>,>>9.99"
            tt-filial.valprazo  column-label "A Prazo"   format ">>,>>>,>>9.99"
            tt-filial.valpago   column-label "Quitado"   format ">>,>>>,>>9.99"
            (total)
            tt-filial.valdevol  column-label "Devolvido!Prazo"
                             format ">>,>>>,>>9.99" (total)
            tt-filial.qtd-plani column-label "QTD Devol" format ">>>>>9"
            tt-filial.valdevolvido_av column-label "Devolvido!Vista"
                             format ">>,>>>,>>9.99" (total)
            with frame f-filial down width 130.
    end.
else
    for each tt-datap break by tt-datap.pladat 
                            by tt-datap.conta
                            by tt-datap.contrato:

        disp
            tt-datap.pladat    column-label "Emissao"  format "99/99/9999"
                when first-of(tt-datap.pladat)
            tt-datap.contrato  column-label "Contrato" format ">>>>>>>>>9"
            tt-datap.conta     column-label "Conta"    format ">>>>>>>>>9"
            tt-datap.nfvenda   column-label "NFVenda"  format ">>>>>>>>9"
            tt-datap.dtvenda   column-label "DtVenda"  format "99/99/9999"
            tt-datap.nfdevol   column-label "NFEntrada" format ">>>>>>>>9"
            tt-datap.valquitado column-label "Quitado" format ">>,>>>,>>9.99"
                (total)
            tt-datap.valdevolvido column-label "Devolvido!Prazo"
                format ">>,>>>,>>9.99" (total)
            tt-datap.valdevolvido_av column-label "Devolvido!Vista"
                        format ">>,>>>,>>9.99" (total)
                with frame f-datap down width 130.
    end.

output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}
end.

