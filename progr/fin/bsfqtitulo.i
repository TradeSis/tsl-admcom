/* helio 082023 - CESSÃO BARU - ORQUESTRA 536437 */
/* HUBSEG 19/10/2021 */

def var vdiasatraso as int format "->>>>9".
def var vjuros      as dec format "->>>9.99".
def var vvalormulta as dec format ">>>>9.99".
def var vpercjur    as dec format ">>9%".
def var vpercmulta  as dec format ">>9%".
def var vsaldojur   as dec format ">>>>,>>9.99".
def var vsaldo  like titulo.titvlcob.
def var vlabel                      as   char format "x(5)".
def var vvliof  like contrato.vliof.
def var vvlcet  like contrato.cet.
def var vvlseguro  like contrato.vlseguro.
def var vvltfc  like contrato.vltaxa.
def var vnro_parcela as int.
def var vvlpresente as dec.
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
    vclfnom       format "x(41)" no-label
    skip
    with frame fclifor row 3 side-label overlay no-box width 81.

def var vpar-ori as char.

form
    "Contas a" at 1
    titulo.titnat   no-label 
    estab.etbcod label "Filial" colon 30
    estab.etbnom no-label

    skip(1)
    titulo.titnum   colon 13 format "x(18)"
    titulo.titdtemi colon 41
    titulo.titdtven colon 65
    titulo.modcod   label "Modal" colon 13
    modal.modnom    no-label format "x(10)"
    titulo.tpcontrato colon 41 label "TpContrato"
    vpar-ori        label "Origem" colon 65
    
    titulo.cobcod   colon 13

    cobra.cobnom    no-label format "x(15)" 
    titulo.cessaobaru colon 41 label "Baru"     /* helio 082023 */
    space(2)
    vbanco          no-label format "x(25)"
    vnumport        no-label format "x(47)"
        skip
    titulo.titvltot colon 13 label "Vl.Nominal" format "zzzz,zz9.99"

    vvlpresente    format ">>>9.99" colon 41 label "Vl Presente"
    
    titulo.titsit   colon 65 label  "Sit"    
    
    skip
    vsaldo         colon 13 label "Saldo" format "zzzz,zz9.99"
    titulo.dtultpgparcial label "Parcial" colon 65
    
    skip
    titulo.vlf_principal colon 13 label "Vl.Principal" format "zzzz,zz9.99"

    vjuros          colon 41 label "Juros Hoje"
    vpercjur        no-label 
    
                titulo.titdtpag colon 65 label "Dt Liquid"

    skip
    titulo.vlf_acrescimo label "Vl.Acrescimo" format "zzzz,zz9.99" colon 13

    vdiasatraso    colon 41 label "Dias Atraso"
    
                titulo.etbcobra colon 65 label "Etb.Pagam"

    skip
    vvliof    label "IOF"  colon 13 format "zzzz,zz9.99" 
        vsaldojur       colon 41 label "Saldo Juros"
    
        titulo.tittotpag colon 65 format ">>>>9.99" label "Pg Princ"
    vvlseguro label "Seguro" colon 13 format "zzzz,zz9.99" 

/*        titulo.titvldes colon 65 label "Desconto"  format ">,>>9.99" */
/*    titulo.titdtdes no-label */
        vvalormulta     colon 41 label "Multa Hoje"
        vpercmulta      no-label


    titulo.titjuro format "->,>>9.99" colon 65 label "Juro/Des"

    vvltfc   label "TFC"  colon 13 format "zzzz,zz9.99" 

/*    titulo.titvljur label "OO" */
/*    titulo.cxacod   colon 13    label "Caixa" format ">>9"
    titulo.cxmdata      /*colon 20*/    label "Data"
    vhora no-label */
    
    titulo.titpagdesc format ">,>>9.99" colon 65 label "Dispensa"
    
    vvlcet   label "CET"  colon 13 format "zzzz,zz9.99" 

        titulo.moecod   colon 41 label "Moeda"
    moeda.moenom    no-label format "x(8)"
        skip
    titulo.titvlpag format ">,>>9.99" colon 65 label "Total Pago"

    
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
vsaldo = if titulo.titdtpag = ?
         then titulo.titvlcob 
         else 0.
if vsaldo < 0 then vsaldo = 0.

vpercjur = 0.

if titulo.titdtpag = ?
then do:
    vdiasatraso = today - titulo.titdtven.
end.
if vjuros = 0
then vpercjur = 0.

/* helio 11012022 - IEPRO */
run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                   titulo.titdtven,
                   titulo.titvlcob,
                   output vjuros).
  
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
else vpar-ori = if titulo.vlf_hubseg > 0 then "HUBSEG" else "".

if titulo.cxmhora <> ""
then vhora = string( int(titulo.cxmhora), "hh:mm:ss").

vvliof = 0.
vvlcet = 0.
vvlseguro = 0.
vvltfc  = 0.
if avail contrato
then do:
    vnro_parcela = contrato.nro_parcela.
    if vnro_parcela = 0
    then do:
        def buffer xtitulo for titulo.
                for each  xtitulo where
                        xtitulo.empcod = 19 and
                        xtitulo.titnat = no and
                        xtitulo.etbcod = contrato.etbcod and
                        xtitulo.clifor = contrato.clicod and
                        xtitulo.modcod = contrato.modcod and
                        xtitulo.titnum = string(contrato.contnum) and
                        xtitulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
                end.                        
    
    end.
            if contrato.vliof > 0
            then vvliof = contrato.vliof / vnro_parcela.
            if contrato.cet > 0
            then vvlcet = contrato.cet / vnro_parcela.
            if contrato.vlseguro > 0 
            then vvlseguro = contrato.vlseguro / vnro_parcela.  
            if contrato.vltaxa > 0
            then vvltfc = contrato.vltaxa / vnro_parcela. 
            
end.

        vvlpresente = 0.
        if titulo.titdtpag = ? and
           titulo.titdtven > today
        then
            if contrato.txjuro > 0
            then do.
               vvlpresente = titulo.titvlcob / exp(1 + contrato.txjuro / 100,(titulo.titdtven - today) / 30).
            end.

display estab.etbcod
        estab.etbnom
        titulo.titdtemi
        {titnum.i}
        vpar-ori
        titulo.titnat
        titulo.titdtven
        vdiasatraso when vdiasatraso > 0
        vjuros when vjuros <> 0 and titulo.titdtpag = ?
        vvalormulta when vvalormulta <> 0 and titulo.titdtpag = ?
        vsaldojur when vsaldojur > 0 and titulo.titdtpag = ?
        vpercjur  when vpercjur > 0 and titulo.titdtpag = ?
        (if titulo.titvltot = 0 
         then titulo.titvlcob
         else titulo.titvltot) @ titulo.titvltot
        titulo.titdtpag
        titulo.tittotpag when titulo.tittotpag > 0
        titulo.titvlpag  when titulo.titvlpag <> 0
        titulo.modcod
        vsaldo
        modal.modnom when avail modal
        titulo.moecod
        moeda.moenom when avail moeda
        titulo.tpcontrato
        cobra.cobnom when avail cobra
        titulo.cessaobaru
        vbanco
        vnumport
        titulo.cobcod
        titulo.titjuro  
        vvlseguro when vvlseguro > 0
        vvlpresente
        titulo.titpagdesc  when titulo.titpagdesc > 0
        
        
/*        titulo.titdtdes when titulo.titdtdes <> ?*/
/*        titulo.titvldes when titulo.titvldes > 0*/
        titulo.titobs[1]
        titulo.titobs[2]
        titulo.titsit 
/*        titulo.cxacod   when titulo.titsit = "PAG"
        titulo.cxmdata  when titulo.titsit = "PAG"
        vhora           when titulo.titsit = "PAG"*/
        titulo.etbcobra when etbcobra <> ?
        titulo.vlf_principal - titulo.vlf_hubseg @ titulo.vlf_principal
        titulo.vlf_acrescimo 
        vvliof
        vvlcet
        vvltfc
        titulo.dtultpgparcial        
        with frame ftitulo.

do with frame ftitulo.
    color display message 
                          titulo.titnum
                          vsaldo.
    if vdiasatraso > 0
                then color disp message vdiasatraso.
    if vjuros      > 0
                then color disp message vjuros.
    if vsaldojur   > 0
                then color disp message vsaldojur.
    if vsaldojur   = titulo.titvlcob
                then color disp message titulo.titvltot.
    if titulo.titdtpag = ?
                then color disp message titulo.titdtven.
    if titulo.titdtpag <> ?
                then color disp message titulo.titdtpag
                                        titulo.titvlpag.
    if titulo.titdtpag <> ? and
       titulo.titjuro   > 0
                then color disp message titulo.titjuro.

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

