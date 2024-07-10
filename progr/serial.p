{admcab.i}
def var i as i.

def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
def temp-table warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
repeat:
    form vetbcod estab.etbnom with frame f1.
    disp "ENTER para verificar Transmissao das Seriais"            @ estab.etbnom
            with frame f1.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label 
            when avail estab
            with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    if vetbcod <> 0 and
       avail estab
    then  run ser.p(input vetbcod,
              input vdti,
              input vdtf).
    else do:
        for each estab where estab.etbcod < 900 and
                    {conv_difer.i estab.etbcod} no-lock.
            find first serial of estab where
                        serial.serdat >= vdti and
                        serial.serdat <= vdtf
                        no-lock no-error.
            disp
                estab.etbcod
                estab.etbnom
                avail serial format "Serial OK/ "
                with centered.
        end.
    end.
end.
