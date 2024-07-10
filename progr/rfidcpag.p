/***
    Projeto FIDC: junho/2019
***/
{admcab.i}
{filtro-estab.def}
{fidc-exporta.i}
def stream stela.

def var vdata     as date.
def var vdtini    as date.
def var vdtfin    as date.
def var vtipodestino as log  format "Arquivo/Relatorio".
def var varquivo  as char.

form
    vEstab    colon 30 label "Todos Estabelecimentos.."
    cestab    no-label
    vdtini    colon 30 label "Periodo Pagamento"
    vdtfin    label "ate"
    vmodcod   colon 30
    vtipodestino colon 30 label "Destino" help "[A]rquivo CSV / [R]elatório"
    with frame fopcoes row 3 side-label width 80.

run le_tabini.p (0, 0, "FIDC - PASTA", output vpasta).
varquivo = "cobranca_fidc" + string(today,"99999999") + ".csv".

do on error undo with frame fopcoes.
    disp
        vmodcod.

    vestab  = yes.
    {filtro-estab.i}
    update
        vdtini
        vdtfin.
    if vdtini > vdtfin or vdtini = ? or vdtfin = ?
    then do:
        message "Periodo inválido" view-as alert-box.
        undo.
    end.

    update vtipodestino.

    if vtipodestino
    then disp skip(1)
              vpasta   label "Diretorio" colon 30 format "x(35)"
              varquivo label "Arquivo"   colon 30 format "x(35)".
end.

if vtipodestino
then do.
    output to value(varquivo).
end.
else do.
    varquivo = "/admcom/import/fidc/rfidcpag." + string(mtime).
    
    {mdadmcab.i
            &Saida     = "value(varquivo)"   
            &Page-Size = "64"  
            &Cond-Var  = "150" 
            &Page-Line = "66" 
            &Nom-Rel   = ""RFIDCPAG"" 
            &Nom-Sis   = """SISTEMA FINANCEIRO""" 
            &Tit-Rel   = """FDIC TITULOS LIQUIDADOS - DE "" +
                          string(vdtini) + "" ATE "" + string(vdtfin)" 
            &Width     = "150"
            &Form      = "frame f-cabcab"}
    if not vestab
    then disp
            vEstab  colon 30 label "Todos Estabelecimentos.."
            cestab  no-label
            with frame fparaopcoes side-label width 80.
end.

/***
for each estab no-lock.
***/
    if not vEstab
    then do:
        find wfEstab where wfEstab.Etbcod = Estab.Etbcod no-lock no-error.
        if not avail wfEstab
        then next.
    end.

    do vdata = vdtini to vdtfin.
        if not vtipodestino
        then do.
            output stream stela to terminal.
            disp stream stela vdata with frame f-proc side-label.
            pause 0.
            output stream stela close.
        end.
        for each titulo where titulo.titnat = no
                          and titulo.titdtpag = vdata
                        /*  and titulo.etbcod = estab.etbcod */
                          and titulo.modcod = vmodcod
                        no-lock.

    if not vEstab
    then do:
        find wfEstab where wfEstab.Etbcod = titulo.Etbcod no-lock no-error.
        if not avail wfEstab
        then next.
    end.



            /*FIDC*/
            find first envfidc where 
                           envfidc.empcod = titulo.empcod and 
                           envfidc.titnat = titulo.titnat and 
                           envfidc.modcod = titulo.modcod and 
                           envfidc.etbcod = titulo.etbcod and 
                           envfidc.clifor = titulo.clifor and 
                           envfidc.titnum = titulo.titnum and 
                           envfidc.titpar = titulo.titpar and 
                           envfidc.lottip = "IMPORTA"
                       no-lock no-error. 
            if not avail envfidc 
            then next.

            find clien where clien.clicod = titulo.clifor no-lock.

            run moedas.

            if vtipodestino
            then
                for each tt-moeda.
                    put unformatted
                        titulo.etbcod
                        ";" titulo.titnum
                        ";" titulo.titpar
                        ";" titulo.clifor
                        ";" clien.clinom
                        ";" clien.ciccgc
                        ";" titulo.titvlcob
                        ";" titulo.titdtven
                        ";" titulo.titdtpag
                        ";" titulo.titvlpag
                        ";" tt-moeda.moecod
                        ";" tt-moeda.titvlpag
                        skip.
                end.
            else do.
                disp
                    titulo.etbcod
                    {titnum.i}
                    titulo.clifor
                    clien.clinom
                    clien.ciccgc    format "x(14)"
                    titulo.titvlcob format ">>,>>9.99"
                                    column-label "Vl.Parc"
                    titulo.titdtven
                    titulo.titdtpag
                    titulo.titvlpag format ">>,>>9.99"
                                    column-label "Vl.Pago"
                    with frame f-rel.
                for each tt-moeda.
                    disp
                        tt-moeda.moecod
                        tt-moeda.titvlpag
                        with frame f-rel width 160 down.
                end.
            end.
        end.
    end.
/***
end.
***/

output close.
if vtipodestino
then unix silent unix2dos -q value(varquivo).
else run visurel.p(varquivo,"").

