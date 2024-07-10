def var varq_log as char format "x(40)".
def var vdata as date format "99/99/9999".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vstatus as char.
def var vip as char.

vdata = today - 2.
varq_log = "/admcom/logs/valZcup.log".

vdti = today - 2.
vdtf = vdti.
vetbi = 1.
vetbf = 200.

disp vetbi at 1 label "Filial inicio"
     vetbf label "Filial fim"
     vdti at 1 label "Data inicio"
     vdtf      label "Data fim"
     with frame f1 1 down width 80 side-label.
     
update vetbi with frame f1.
find estab where estab.etbcod = vetbi no-lock no-error.
if not avail estab then undo.
update vetbf with frame f1.
find estab where estab.etbcod = vetbf no-lock no-error.
if not avail estab then undo.
if vetbf < vetbi
then undo.

update vdti vdtf with frame f1.
if vdti = ? or vdtf = ? or vdtf < vdti 
then undo.

def NEW SHARED temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(20)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    .

if connected ("admloja")
then disconnect admloja.    

run valredZ1.p (vetbi, vetbf, vdti, vdtf).

pause.
       