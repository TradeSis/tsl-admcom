{admcab.i}
def var i as i.
def var vmovtdc like tipmov.movtdc.
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
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
def var vtipo as log format "OUTRAS/ICMS" initial yes.
repeat:

    update vmovtdc colon 16 label "Tipo Movimento"
                        with frame f1.
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    display movtnom no-label with frame f1.
    
    update vetbcod colon 16 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    if vmovtdc <> 13
    then do:
        update vtipo label "Consulta" with frame f1.
        if vtipo
        then run manfis1.p(input vetbcod,
                           input vmovtdc,
                           input vdti,
                           input vdtf).
        
        else run manfis3.p(input vetbcod,
                           input vmovtdc,
                           input vdti,
                           input vdtf).
                    
    end.
    else
    run manfis2.p(input vetbcod,
                  input vmovtdc,
                  input vdti,
                  input vdtf).
               
end.
