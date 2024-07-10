/* 05012022 helio iepro */

{admcab.i}
def input param poperacao as char.

def var vsel as int.
def var vabe as dec.

def buffer btitulo for titulo.
{iep/tfilsel.i}


find first ttfiltros.

do with frame fcab.
update ttfiltros.clicod     label "cliente" colon 60
    with frame fcab.
if ttfiltros.clicod = 0
then do:
    update
    ttfiltros.qtdsel        label "qtd parcelas selecionadas -> Max"    colon 60
    ttfiltros.vlrctrmin     label "Valor Contrato     -> Min" colon 35     ttfiltros.vlrctrmax label "Max" colon 60
    ttfiltros.vlrabemin     label "Valor Aberto       -> Min" colon 35     ttfiltros.vlrabemax label "Max"  colon 60
    ttfiltros.vlrparcmin    label "Valor Parcela      -> Min" colon 35     ttfiltros.vlrparcmax label "Max"  colon 60
    
    ttfiltros.diasatrasmin  label "Dias Atraso        -> Min" colon 35     ttfiltros.diasatrasmax label "Max"  colon 60
    ttfiltros.dtemiini      label "Dt Emissao         -> Min" colon 35     ttfiltros.dtemimax label "Max" colon 60
        
        with frame fcab
        row 4 centered
        side-labels
        title " FILTRO ".

    update ttfiltros.modcod colon 35 label "modalidades"
        help "informe modalidades separadas por virgula"
        with frame fcab.
    if lookup ("CRE",ttfiltros.modcod) > 0
    then update ttfiltros.tpcontrato colon 35 label "tp"
                help "C - CDC NORMAL, N - NOVACAO"  /* , FA - FEIRAO ANTIGO, F - FEIRAO , L - L&P*/
                with frame fcab.
    else ttfiltros.tpcontrato = "".
    update
        ttfiltros.comarca label "comarca" colon 35.
        
end.

end.

            
            
run iep/pselecionaparcelas.p (input poperacao, input-output vsel , input-output vabe, yes).

hide message no-pause.
message "filtrados contratos..." vsel "max: " ttfiltros.qtdsel  " - valor:" vabe.

hide frame fcab no-pause.


