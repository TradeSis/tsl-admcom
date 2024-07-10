
def var vdiasatraso as int format ">>>9".
def var vjuros      as dec format ">>>,>>9.99".
def var vvalormulta as dec format ">>>,>>9.99".
def var vpercjur    as dec format ">>9.99% am".
def var vpercmulta  as dec format ">>9.99%".
def var vsaldojur   as dec format ">>>>,>>9.99".
def var vsaldo  like titulo.titvlcob.
def var vlabel                      as   char format "x(5)".
/*
def var ccgccpf           as char format "x(18)".
def var vcgccpf as dec.
*/
def var vbanco          as char.
def var vnumport    as char.
def var vclfnom           as char.
def var vcgccpf           as char.
def var vhora             as char.

form
/*    skip */
    titulo.clifor
    vlabel         /*at 2*/ no-label
    vcgccpf              no-label format "x(14)"
    /*"Nome:"*/
    vclfnom       format "x(40)" no-label
    skip
    with frame fclifor row 3 side-label overlay no-box width 81.

def var vpar-ori as char.
form
    "Contas a" at 1
    titulo.titnat   no-label skip
    estab.etbcod label "Filial" colon 30
    estab.etbnom no-label
    titulo.titsit format "x(5)" no-label
    skip(1)
    titulo.titnum   colon 13 format "x(18)"
    titulo.titdtemi colon 41
    titulo.titdtven colon 66
    vpar-ori        colon 13 label "Origem"
    titulo.tpcontrato colon 41
    
    titulo.titvlcob colon 66 label "Vl.Nominal" format ">>>>,>>9.99"
    skip
    titulo.modcod   colon 13
    modal.modnom    no-label
    titulo.moecod   colon 41 label "Moeda"
    moeda.moenom    no-label
    skip
    titulo.cobcod   colon 13
    cobra.cobnom    no-label format "x(30)"
    vbanco          no-label format "x(25)"
    vnumport        no-label format "x(47)"
    skip /*(1)*/
    vsaldo          colon 13 label "Saldo" format ">>>>,>>9.99"
    vdiasatraso     label "Dias Atraso"
    vjuros          label "Juros Hoje"
    vpercjur        no-label
    skip
    vvalormulta     colon 13 label "Multa Hoje"
    vpercmulta      no-label
    vsaldojur       colon 57 label "Saldo C/Juros+Multa"
    skip
    titulo.titvldes colon 32 label "Desconto Antecipacao Pagto" 
                    format ">,>>9.99"
    titulo.titdtdes no-label
    titulo.titvljur format ">,>>9.99"
    skip
    titulo.etbcobra colon 20
    titulo.titdtpag colon 66
    titulo.titjuro  colon 13
    titulo.titdesc  label "Seguro"
    titulo.cxacod   colon 13    label "Caixa" format ">>9"
    titulo.cxmdata      /*colon 20*/    label "Data"
    vhora no-label
    titulo.titvlpag colon 66 format ">>>>,>>9.99"
    titulo.vlf_principal label "Vl.Principal" format ">>>>,>>9.99"
    titulo.vlf_acrescimo label "Vl.Acrescimo" format ">>>>,>>9.99"
    skip
    titulo.titobs[1] label "Obs." format "x(70)" at 4
    titulo.titobs[2] label "    " format "x(70)" at 4
    with frame ftitulo side-label overlay row 4 width 81 no-box .

find estab where estab.etbcod = titulo.etbcod no-lock.
find cobra of titulo no-lock no-error.
find modal of titulo no-lock no-error.
find banco of titulo no-lock no-error.
find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
find moeda of titulo no-lock no-error.

run clifor.
/***
find clien where /*clien.empcod = sempcod   and*/
                 clien.clicod  = titulo.clifor    no-lock.
***/
pause 0.
clear frame ftitulo all no-pause.
clear frame ftitulo all no-pause.
clear frame ftitope all no-pause.
clear frame fclifor  all no-pause.
/*
run retcgc.p (input recid(clien),
              output vlabel,
              output ccgccpf).
*/

/*
if clien.tippes
then do:
    vcgccpf = 100000000000.00 + clien.clicod.
    ccgccpf = substr(string(vcgccpf),2,3) + "." +
              substr(string(vcgccpf),5,3) + "." +
              substr(string(vcgccpf),8,3) + "-" +
              substr(string(vcgccpf),11,2) .
end.
else do:
    vcgccpf = 100000000000000.00 + clien.clicod.
    ccgccpf = substr(string(vcgccpf),2,2)  + "." +
              substr(string(vcgccpf),4,3)  + "." +
              substr(string(vcgccpf),7,3)  + "/" +
              substr(string(vcgccpf),10,4) + "-" +
              substr(string(vcgccpf),14,2).
end.
*/

/***
if clien.tippes
then
    vlabel = "CPF".
else
    vlabel = "CNPJ".
***/
vlabel = vlabel + ".:".

vdiasatraso = 0.
vjuros = 0.
vvalormulta = 0.
vsaldo = titulo.titvlcob - titulo.titvlpag.
/*
if titulo.titdesc > 0
then vsaldo = vsaldo - titulo.titdesc.
*/
if vsaldo < 0 then vsaldo = 0.

vpercjur = 0.

if titulo.titdtpag = ?
then do:
    vdiasatraso = today - titulo.titdtven.
    /*
    if titulo.titvljur > 0
    then
        assign
           vjuros = titulo.titvljur
           vsaldojur = titulo.titvljur + 
                       (titulo.titvlcob - titulo.titvlpag).
    else do.
        if vdiasatraso <= 0
        then vdiasatraso = 0.
        else do:
            run fbjuro.p ( input titulo.cobcod,
                           input titulo.carcod,
                           input titulo.titnat,
                           input titulo.titvlcob - titulo.titvlpag,
                           input titulo.titdtven,
                           input today,
                           output vsaldojur,
                           output vpercjur).

            run fbmulta.p (input titulo.cobcod,  
                           input titulo.carcod,  
                           input titulo.titnat,  
                           input titulo.titvlcob ,  
                           input titulo.titdtven,  
                           input today,  
                           output vvalormulta) .
        
            vjuros = vsaldojur - (titulo.titvlcob - titulo.titvlpag).
            vsaldojur = vsaldojur + vvalormulta.
        end.
    end.
    ****/
end.
if vjuros = 0
then vpercjur = 0.

if not xestab.etbnom begins "DREBES-FIL"
then run bstitjuro.p (input  recid(titulo),
                 input  today,
                 output vjuros,
                 output vsaldojur).
  
if avail contrato and contrato.banco = 10
then vbanco = "Imprimiu contrato SICREDI".

display
        vlabel
        titulo.clifor label "Codigo"
        vcgccpf
        vclfnom
        with frame fclifor.
color display message   vlabel
                        titulo.clifor
                        vcgccpf
                        vclfnom
                        with frame fclifor.
if titulo.titparger > 0
then vpar-ori = string(titulo.titparger).
else vpar-ori = "".

if titulo.cxmhora <> ""
then vhora = string( int(titulo.cxmhora), "hh:mm:ss").

display estab.etbcod
        estab.etbnom
        titulo.titdtemi
        {titnum.i}
        vpar-ori
        titulo.titnat
        titulo.titdtven
        vdiasatraso when vdiasatraso > 0
        vjuros when vjuros <> 0
        vvalormulta when vvalormulta <> 0
        vsaldojur when vsaldojur > 0
        vpercjur  when vpercjur > 0
        titulo.titvlcob
        titulo.titdtpag
        titulo.titvlpag when titulo.titvlpag > 0
        titulo.modcod
        vsaldo
        modal.modnom when avail modal
        titulo.moecod
        moeda.moenom when avail moeda
        titulo.tpcontrato
        cobra.cobnom when avail cobra
        vbanco
        vnumport
        titulo.cobcod
        titulo.titjuro  when titulo.titjuro > 0
        titulo.titdesc  when titulo.titdesc > 0
        titulo.titdtdes when titulo.titdtdes <> ?
        titulo.titvldes when titulo.titvldes > 0
        titulo.titobs[1]
        titulo.titobs[2]
        titulo.titsit 
        titulo.cxacod   when titulo.titsit = "PAG"
        titulo.cxmdata  when titulo.titsit = "PAG"
        vhora           when titulo.titsit = "PAG"
        titulo.etbcobra
        titulo.vlf_principal when titulo.vlf_principal > 0
        titulo.vlf_acrescimo when titulo.vlf_principal > 0
        with frame ftitulo.

do with frame ftitulo.
    color display message 
                          titulo.titnum
                          titulo.titvlcob.
    if vdiasatraso > 0
                then color disp message vdiasatraso.
    if vjuros      > 0
                then color disp message vjuros.
    if vsaldojur   > 0
                then color disp message vsaldojur.
    if vsaldojur   = titulo.titvlcob - titulo.titvlpag
                then color disp message titulo.titvlcob.
    if titulo.titdtpag = ?
                then color disp message titulo.titdtven.
    if titulo.titdtpag <> ?
                then color disp message titulo.titdtpag
                                        titulo.titvlpag.
    if titulo.titdtpag <> ? and
       titulo.titjuro   > 0
                then color disp message titulo.titjuro.
    if titulo.titdtpag <> ? and
       titulo.titdesc   > 0
                then color disp message titulo.titdesc.

end.

procedure clifor.
    if titulo.titnat
    then do.
        find forne where forne.forcod = titulo.clifor no-lock.
        assign
            vcgccpf = forne.forcgc
            vclfnom = forne.fornom
            vlabel  = "CNPJ".
    end.
    else do.
        find clien where clien.clicod = titulo.clifor no-lock.
        assign
            vcgccpf = clien.ciinsc
            vclfnom = clien.clinom.

        if clien.tippes
        then vlabel = "CPF".
        else vlabel = "CNPJ".
    end.
end.

