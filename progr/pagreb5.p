/*** KPMG ****/
/*
#1 17.05.19 - Sala Guerra Tesouraria/Financeiro
*/
{admcab.i}

def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

def var vdtini     as date.
def var vdtfin     as date.
def var vdata      like titulo.titdtpag.
def var vdesc      like titulo.titvldes.
def var vjuro      like titulo.titjuro.
def var vresumo    as   log format "Resumo/Geral".
def var vetbcod    like estab.etbcod.
def var vtitrel    as char.
def var vselmodal  like sresp.
def var varquivo   as char.
def var vparcial   as dec.
def var par-origem as char.
def var vtipocxa   as char.
def var vseltipocxa as char.
def buffer bestab  for estab.
def buffer btitulo for titulo.

def temp-table tt-resumo
    field etbcod   like titulo.etbcod
    field titdtpag like titulo.titdtpag
    field titvlpag like titulo.titvlpag
    field titjuro  like titulo.titjuro
    field titdesc  like titulo.titdesc
    index resumo is primary unique etbcod titdtpag.

do on error undo with frame f-filtro row 3 side-label width 80.
    empty temp-table tt-modalidade-selec.

    update vresumo label "Imprimir Resumo ou Geral?" colon 30.

    update vetbcod colon 30.
    if vetbcod = 0 and not vresumo
    then do.
        message "Estab deve ser informado" view-as alert-box.
        undo.
    end.
    if vetbcod > 0
    then do.
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label.
    end.
    update vdtini colon 30 label "Pagamento inicial" validate(vdtini <> ?, "").
    update vdtfin label "Ate" validate(vdtfin >= vdtini, "").

    assign vselmodal = no.
    update vselmodal label "Seleciona Modalidades?" colon 30
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades".
    if vselmodal
    then run selec-modal.p ("REC"). /* #1 */
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.

    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + " ".
    end.
      
    display vmod-sel format "x(40)" no-label.

    vseltipocxa = "T".
    update vseltipocxa label "Tipo de Caixa" colon 30 format "x(1)"
                help "T=Todos  A=Admcom  P=P2K".
end.

if vresumo
then vtitrel = "LISTAGEM GERAL DE PAGAMENTOS".
else vtitrel = "LISTAGEM DE PAGAMENTOS - ESTAB.: " + string(vetbcod) + " - " +
               estab.etbnom.

if vresumo
then
    for each estab no-lock.
        do vdata = vdtini to vdtfin.
            disp estab.etbcod vdata
                        with frame f-proc side-label with 1 down centered.
            pause 0.
            for each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdata and
                                  titulo.clifor > 1 and
                                  titulo.titpar > 0
                                no-lock.
                find first tt-modalidade-selec where
                             tt-modalidade-selec.modcod = titulo.modcod
                             no-lock no-error.
                if not avail tt-modalidade-selec
                then next.

                find cmon where cmon.etbcod = titulo.etbcobra
                        and cmon.cxacod = titulo.cxacod
                      no-lock no-error.
                if avail cmon
                then vtipocxa = "P2K".
                else vtipocxa = "Adm".
 
                if (vseltipocxa = "A" and vtipocxa <> "Adm") or
                   (vseltipocxa = "P" and vtipocxa <> "P2K")
                then next.

                vdesc = max(titulo.titvlcob - titulo.titvlpag, 0).
                if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                then vdesc = 0.

                find tt-resumo where tt-resumo.etbcod   = titulo.etbcobra
                                 and tt-resumo.titdtpag = titulo.titdtpag
                               no-error.
                if not avail tt-resumo
                then do.
                    create tt-resumo.
                    assign
                        tt-resumo.etbcod   = titulo.etbcobra
                        tt-resumo.titdtpag = titulo.titdtpag.
                end.
                assign
                    tt-resumo.titvlpag = tt-resumo.titvlpag +
                                 titulo.titvlpag - titulo.titjuro + vdesc
                    tt-resumo.titjuro  = tt-resumo.titjuro + titulo.titjuro
                    tt-resumo.titdesc  = tt-resumo.titdesc + vdesc.
            end.
        end.
    end.

    varquivo = "../relat/pagreb5." + string(mtime).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "156"
        &Page-Line = "66"
        &Nom-Rel   = """PAGREB5"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = " vtitrel "
        &Width     = "156"
        &Form      = "frame f-cab"}

if vresumo
then
    for each tt-resumo no-lock
            break by tt-resumo.etbcod
                  by tt-resumo.titdtpag.
        disp
            tt-resumo.etbcod
            tt-resumo.titdtpag
            tt-resumo.titvlpag (total by tt-resumo.etbcod)
            tt-resumo.titjuro  (total by tt-resumo.etbcod)
            tt-resumo.titdesc  (total by tt-resumo.etbcod)
            with frame f-resumo width 96 down no-box.
    end.
else do.
    do vdata = vdtini to vdtfin.
        for each titulo where titulo.etbcobra = vetbcod and
                              titulo.titdtpag = vdata and
                              titulo.clifor > 1 and
                              titulo.titpar > 0 use-index etbcod
                        no-lock by titulo.titnum.
            find first tt-modalidade-selec where
                             tt-modalidade-selec.modcod = titulo.modcod
                             no-lock no-error.
            if not avail tt-modalidade-selec
            then next.
            
            find clien where clien.clicod = titulo.clifor NO-LOCK no-error.
            
            /*
            if titulo.etbcobra <> bestab.etbcod or
               titulo.clifor = 1
            then next.
            */
            
            /*#1
            vjuro = if titulo.titjuro = titulo.titdesc or
                        (titulo.modcod begins "CP" and
                        titulo.cxacod < 30)
                    then 0
                    else titulo.titjuro.
            vdesc = if titulo.titjuro = titulo.titdesc
                    then 0
                    else titulo.titvldes.
            */
            vdesc = max(titulo.titvlcob - titulo.titvlpag, 0).
            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then vdesc = 0.

            if acha("PARCIAL",titulo.titobs[1]) <> ?
            then par-origem = string(titulo.titparger).
            else par-origem = "". 

            find cmon where cmon.etbcod = titulo.etbcobra
                        and cmon.cxacod = titulo.cxacod
                      no-lock no-error.
            if avail cmon
            then vtipocxa = "P2K".
            else vtipocxa = "Adm".
            if (vseltipocxa = "A" and vtipocxa <> "Adm") or
               (vseltipocxa = "P" and vtipocxa <> "P2K")
            then next.

            display
                titulo.etbcod   column-label "Fil."
                titulo.etbcobra column-label "Cob."
                titulo.titnum   column-label "Contrato"
                titulo.titpar   column-label "Pr."
                titulo.modcod
                par-origem      column-label "Ori"  format "xx"
                titulo.clifor   column-label "Cliente"
                clien.clinom    column-label "Nome" format "x(33)"
                                        when avail clien
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlcob format ">>>,>>9.99"
                titulo.cxacod   column-label "Cxa"
                vtipocxa no-label format "x(3)"
                titulo.titvlpag - titulo.titjuro + vdesc
                         column-label "Valor Pago" format ">>>,>>9.99" (TOTAL)
                titulo.titjuro                format ">>>,>>9.99"  (TOTAL)
                vdesc column-label "Desconto" format ">>,>>9.99"  (TOTAL)
                with no-box width 166 frame flin2 down.
            end.
        end.
    end.

output close.
if opsys = "UNIX"
then do.
    run visurel.p (input varquivo, input "").
end.
else do:
    {mrod.i}.
end.
