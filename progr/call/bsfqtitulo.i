def var vextenso                    as char extent 2.
def var extenso as char extent 10.

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

form
/*    skip */
    clien.clicod
    vlabel         /*at 2*/ no-label
    clien.ciccgc        no-label format "x(14)"
    /*"Nome:"*/
    clien.clinom  format "x(40)" no-label
    skip
    with
        frame fclien row 3 side-label
                    overlay no-box width 81.
               /*
form titulo.titobs[1]
                        label "Obs." format "x(70)"
    with
        frame ffinal row screen-lines side-label overlay
                    no-box color message width 81.
                 */
form
    "Contas a" at 1
    titulo.titnat   no-label skip
    estab.etbcod label "Filial" colon 30
    estab.etbnom no-label
    titulo.titsit format "x(15)" no-label
    skip(1)
    titulo.titnum   colon 15 format "x(15)"
    titulo.titdtemi colon 41
    titulo.titdtven colon 66
    titulo.titvlcob colon 66 label "Vl.Nominal" format ">>>>,>>9.99"
    skip
    titulo.modcod     colon 12
    modal.modnom      no-label
    skip
    titulo.cobcod colon 15
    cobra.cobnom    no-label format "x(40)"
    vbanco          no-label format "x(31)"
    vnumport        no-label format "x(47)"
    skip /*(1)*/
    vsaldo          colon 15 label "Saldo" format ">>>>,>>9.99"
    vdiasatraso     label "Dias Atraso"
    vjuros          label "Juros Hoje"
    vpercjur        no-label
    skip
    vvalormulta     colon 15 label "Multa Hoje"
    vpercmulta      no-label
    vsaldojur       colon 57 label "Saldo C/Juros+Multa"
    skip
    titulo.titvldes colon 32 label "Desconto Antecipacao Pagto" 
                    format ">,>>9.99"
    titulo.titdtdes no-label
    titulo.titvljur format ">,>>9.99"
    skip /*(1)*/
    titulo.titdtpag colon 66
    titulo.titjuro  colon 15
    titulo.titdesc
    titulo.titvlpag colon 66 format ">>>>,>>9.99"
    skip(1)
    titulo.titobs[1] label "Obs." format "x(70)" at 4
    titulo.titobs[2] label "    " format "x(70)" at 4
/*    skip(1) */
    with frame ftitulo side-label
                overlay row 4 width 81 no-box .

extenso = fill("*",80).

/*find uo where uo.empcod = wempre.empcod and
*              uo.uocod  = titulo.uocod no-lock.*/
find first estab where estab.etbcod = titulo.etbcod no-lock.
find cobra of titulo no-lock.
find modal of titulo    no-lock no-error.
find banco of titulo no-lock no-error.

find clien where /*clien.empcod = sempcod   and*/
                 clien.clicod  = titulo.clifor    no-lock.
pause 0.
clear frame ftitulo all no-pause.
clear frame ftitulo all no-pause.
clear frame ftitope all no-pause.
clear frame fclien  all no-pause.
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

if clien.tippes
then
    vlabel = "CPF".
else
    vlabel = "CNPJ".
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
~                           input titulo.titvlcob ,  
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
  /*
run extenso.p (input  2,
               input  70,
               input  70,
               input  70,
               input  vsaldojur,
               output extenso[01],
               output extenso[02],
               output extenso[03],
               output extenso[04],
               output extenso[05],
               output extenso[06],
               output extenso[07],
               output extenso[08],
               output extenso[09],
               output extenso[10]).             
  */
vextenso[1] = extenso[1].
vextenso[2] = extenso[2].


display
        vlabel
        clien.clicod label "Codigo"
        clien.ciccgc
        clien.clinom
        with frame fclien.
color display message   vlabel
                        clien.clicod
                        clien.ciccgc
                        clien.clinom
                        with frame fclien.

display
        estab.etbcod
        estab.etbnom
        titulo.titdtemi
        {titnum.i}
        titulo.titnat
        titulo.titdtven
        vdiasatraso when vdiasatraso > 0
        vjuros when vjuros <> 0
        vvalormulta when vvalormulta <> 0
        vsaldojur when vsaldojur > 0
        vpercjur  when vpercjur > 0
        /*vextenso[1]
        vextenso[2]*/
        titulo.titvlcob
        titulo.titdtpag
        titulo.titvlpag when titulo.titvlpag > 0
        titulo.modcod
        vsaldo
        modal.modnom when avail modal
        trim(cobra.cobnom) @ cobra.cobnom
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
        with frame ftitulo.

/*display titulo.titobs[1] with frame ffinal.*/

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
