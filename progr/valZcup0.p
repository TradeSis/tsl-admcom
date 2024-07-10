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
    field t05 as dec  label "Reducao 18%"
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec  label "Cupom 18%  "
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec label "Dif 18%  "
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    field icms as dec 
    field cicms as dec
    field dicms as dec
    field idesc as dec
    field cdesc as dec
    field ddesc as dec
     .

/***
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
***/

if connected ("admloja")
then disconnect admloja.    

def var vescolha as char extent 3 FORMAT "X(30)"
    init["FECHAMENTO CUPOM X REDUÇÃO","FECHAMENTO DE REDUÇÃO",
    "FALTA DE REDUÇÃO"] 
    .
def var vindex as int.
disp vescolha with frame f-esc no-label 1 column.
choose field vescolha with frame f-esc.
vindex = frame-index.
hide frame f-esc no-pause.    

if vindex = 2
then do:
    run valredZ1.p (vetbi, vetbf, vdti, vdtf).
    return.
end.
else if vindex = 3
then do:
    run falta-redz.p(vetbi, vetbf, vdti, vdtf).
end. 
run valZcup3.p (vetbi, vetbf, vdti, vdtf).

def new shared temp-table tt-estab
    field etbcod like estab.etbcod
    index i1 etbcod.
    
for each tt-caixa where tt-caixa.difer:
    find tt-estab where tt-estab.etbcod = tt-caixa.etbcod no-error.
    if not avail tt-estab
    then do:
        create tt-estab.
        tt-estab.etbcod = tt-caixa.etbcod.
    end.
end.
for each tt-estab where tt-estab.etbcod = 0:
delete tt-estab.
end.

def var sresp as log.
find first tt-estab no-error.
if avail tt-estab
then do:
    sresp = no.
    message "Atualizar reducao Z" update sresp.
    if sresp
    then
    run valZcup2.p (vetbi, vetbf, vdti, vdtf).

end.
pause 0.

for each tt-caixa:
delete tt-caixa.
end.

run valZcup3.p (vetbi, vetbf, vdti, vdtf).

for each tt-estab:
delete tt-estab.
end.

for each tt-caixa where tt-caixa.difer:
    find tt-estab where tt-estab.etbcod = tt-caixa.etbcod no-error.
    if not avail tt-estab
    then do:
        create tt-estab.
        tt-estab.etbcod = tt-caixa.etbcod.
    end.
end.
for each tt-estab where tt-estab.etbcod = 0:
delete tt-estab.
end.



for each tt-estab,        
    first estab where 
                estab.etbcod = tt-estab.etbcod and
                estab.etbcod < 200 /*and
                estab.etbnom begins "DREBES-FIL"*/ no-lock:

    
    if estab.etbcod >= vetbi and
       estab.etbcod <= vetbf
    then. else next.
       
    if estab.etbcod = 10 or
       estab.etbcod = 22 or
       estab.etbcod = 189
    then next.

    vip = "filial" + string(estab.etbcod,"999").   

    if connected ("admloja")
    then disconnect admloja.    
    
    display estab.etbcod column-label "Filial"
            vip column-label "IP" format "x(15)"
            "Conectando" column-label "Estatus"
            with frame f-3 down width 80 color white/red
                    row 5.
    pause 0.

    output to value(varq_log) append.
    connect adm -H value(vip) -S sadm -N tcp -ld admloja
                no-error.
    output close.
    
    if not connected ("admloja")
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
        display vstatus  label "STATUS"
        with frame f-3.
        undo, retry.    
    end.

    run busca_admlj.

    display vstatus  no-label format "x(20)" with frame f-3.

    output to value(varq_log) append.
        put vip space(2) vstatus skip.
    output close.
    
    if connected ("admloja")
    then disconnect admloja.

end.

pause 1 .

find first tt-estab no-error.
if avail tt-estab
then run valZcup2.p (vetbi, vetbf, vdti, vdtf).
pause 0.

for each tt-estab :
    vetbi = tt-estab.etbcod.
    vetbf = vetbi.
    /*
    run valZcup2.p (vetbi, vetbf, vdti, vdtf).
    */
    run valZcup3.p (vetbi, vetbf, vdti, vdtf).
end.

procedure busca_admlj:
    run valZcup1.p ( estab.etbcod, vdti, vdtf, "MAPCXA", output vstatus ).
end procedure.
    
