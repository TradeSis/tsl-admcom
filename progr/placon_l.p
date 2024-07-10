{admcab.i}
def var vtofcod as char format "x(05)".
def var varquivo as char.
def var vdata like placon.pladat.
def var vnome as char format "x(30)".
def var vqtd  as dec.
def var vesp  as char.
def var vfre  as int format "9" initial 1.
def var vuf   as char format "x(02)" initial "RS".
DEF VAR vtot as int.
DEF VAR vcont as int.
DEF VAR vpag as int extent 50.
def var fila as char.
def var vnota as int.
def temp-table wmovcon
    field placod like placon.placod
    field etbcod like placon.etbcod
    field pronom like produ.pronom
    field procod like produ.procod.

def input parameter  par-rec as recid.

DEF VAR vlinha      AS INT FORMAT "99" INITIAL 0.
DEF VAR vimp_cab    AS LOG INITIAL YES.
def var i as i.
def var vsub-total  like placon.platot no-undo.
def var recatu2             as recid.
def var vserviss            as dec format "zz,z99.99".
def var vrespfre            as int format "9".
def var vtitnum             as char extent 4 initial 0.
def var vtitpar             as int format "99" extent 4 initial 0.
def var vtitdtven           like placon.pladat extent 4.
def var vtitvlcob           like placon.platot extent 4 initial 0.
def var vplaca              as char label "Placa".
def var c                   as int.
def buffer bplacon for placon.
def buffer bestab for estab.
if opsys = "unix"
   then do:
   find first impress where impress.codimp = setbcod no-lock no-error.
   if avail impress
      then assign fila = string(impress.dfimp). 
   end.                    
     else assign fila = "". 
  
/*put control chr(15).*/

find placon where recid(placon) = par-rec no-lock.
find estab where estab.etbcod = placon.desti no-lock no-error.
find bestab where bestab.etbcod = placon.etbcod no-lock no-error.


find tofis where tofis.tofcod = 522 no-lock no-error.
vtofcod = string(tofis.tofcod).
if today >= 01/01/2003
then vtofcod = "5.152".



ASSIGN vlinha   = 0
  vimp_cab = YES.

for each wmovcon.
    delete wmovcon.
end.
vcont = 0.
vpag  = 0.

vnota = 0.
vcont = 0.
vtot = 0.
vqtd = 0.
FOR EACH movcon where movcon.etbcod = placon.etbcod and
                     movcon.placod = placon.placod and
                     movcon.movtdc = placon.movtdc and
                     movcon.movdat = placon.pladat no-lock:
    find produ where produ.procod = movcon.procod no-lock no-error.

    create wmovcon.
    assign wmovcon.etbcod = placon.etbcod
           wmovcon.placod = placon.placod
           wmovcon.pronom = produ.pronom
           wmovcon.procod = movcon.procod.
    vcont = vcont + 1.
    vqtd  = vqtd  + movcon.movqtm.
end.

vnome = "DREBES & CIA LTDA".
update  vnome label "Transportadora" colon 16
        vqtd  label "Volumes"        colon 16
        vesp  label "Especie"        colon 16
        vfre  label "Frete por Conta" colon 16
        vplaca                       colon 16
        vuf   label "UF"             colon 16
        with frame f-placa centered side-label color blue/cyan.

vdata = placon.pladat.

if weekday(placon.pladat) = 7 or  /* placon.pladat = 04/12/2001 */
   weekday(placon.pladat) = 6 or
   vdata = 09/19/2002
then 
update vdata label "Data Impressao" 
        with frame fdata side-label centered.

hide frame fdata no-pause.

if opsys = "unix"
then varquivo = "/admcom/relat/nftra" + string(time).
else varquivo = "l:\relat\nftra" + string(time).

output to value(varquivo) page-size 66.
put unformatted chr(27) + "M" + chr(15).


if int(vcont / 24) <> (vcont / 24)
then vtot = truncate((vcont / 24),0) + 1.
else vtot = (vcont / 24).


for each wmovcon break by wmovcon.pronom:
    find movcon where movcon.etbcod = placon.etbcod and
                     movcon.placod = placon.placod and
                     movcon.movtdc = placon.movtdc and
                     movcon.movdat = placon.pladat and
                     movcon.procod = wmovcon.procod no-lock.
  IF ( vlinha = 0 ) OR ( vlinha = 25 )
    THEN
  DO:
    ASSIGN vimp_cab = YES
      vlinha   = 1.
  END.

  IF vimp_cab
    THEN
  DO:
    vimp_cab = NO.
    put unformatted
        placon.numero    at 145 skip(8)
        "X"             at 101
        placon.numero    at 145 skip(1)
        bestab.endereco at 50 
        bestab.etbcgc   at 102 skip
        bestab.munic    at 50 space(2)
        bestab.ufecod   skip
        tofis.tofnom    at 2
        vtofcod    at 59
        bestab.etbinsc  at 102 skip(1)
        "DREBES E CIA LTDA - " at 2 estab.etbcod
        estab.etbcgc    at 108
        vdata    at 145 skip(1)
        estab.endereco  at 2
        /*clifor.cep      at 123*/
        /* placon.pladat    at 145 */ skip
        estab.munic     at 2
        estab.etbtofne  at 75
        estab.ufecod    at 94
        estab.etbinsc   at 108
        /* string(time,"hh:mm") format "x(5)" at 145 */ skip(2).
  END.

  find produ of movcon no-lock.
  vlinha = vlinha + 1.
  put unformatted
      produ.procod    at 4
      produ.pronom    at 20
      produ.prounven  at 92
      movcon.movqtm    at 104
      movcon.movpc     to 125   format ">>,>>9.99"
      movcon.movqtm * movcon.movpc  to 145 format "zzz,zz9.99"
      movcon.movalicms at 153 format ">9%" skip.

  IF ( vlinha = 25 ) AND ( NOT LAST( wmovcon.pronom ) )
  THEN DO:
    vnota = vnota + 1.
    put unformatted skip(2)
        "**************"       at 4
        "DIFERIDO"             at 45
        "**************"       at 140 skip(3)
        "PROPRIO"              at 2
        vfre                   at 97
        vplaca                 at 106
        vuf                    at 120 skip(2)
        vqtd                   at 4
        vesp                   at 35 SKIP(2)
        "ICMS DIFERIDO CFE. PREVISAO LEGAL LIVRO I." AT 2 SKIP
        "ART. 53, INC. 1 DO DECRETO N. 37.699/97"    AT 2 SKIP
        "LIVRO II, ART. 187. PARAGRAFO UNICO, DECRETO 37699/97" AT 2 SKIP.

        put string(string(vnota,"99") + "/" +
            string(vtot,"99") + " - Continua") format "x(24)" at 2 skip(1).

    page.

  END.

  IF LAST( wmovcon.pronom )
    THEN
  DO:
    IF vlinha <> 25
    THEN PUT SKIP( 25 - vlinha).
    put unformatted skip(2)
        placon.bicms         at 20 format "zzz,zz9.99"
        "DIFERIDO" /* placon.icms */         at 45 /* format "zz,zz9.99" */
        placon.bsubst        at 85 format "zz,zz9.99"
        placon.icmssubst     at 115 format "zz,zz9.99"
        placon.protot        at 140 format "zzz,zz9.99" skip(1)
        placon.frete         at 20 format "zz,zz9.99"
        placon.seguro        at 50 format "zz,zz9.99"
        placon.ipi           at 115 format "zz,zz9.99"
        placon.platot        at 140 format "zzz,zz9.99" skip(1)
        vnome               at 4
        vfre                at 97
        vplaca              at 106
        vuf                 at 120 skip(2)
        vqtd                at 4
        vesp                at 35 SKIP(1)
        "ICMS DIFERIDO CFE. PREVISAO LEGAL LIVRO I," AT 4
        "ART. 53, INC. 1 DO DECRETO N. 37.699/97" AT 4.
        if vnota > 0
        then do:
            vnota = vnota + 1.
            put
            "LIVRO II, ART. 187. PARAGRAFO UNICO, DECRETO 37699/97" AT 4 SKIP
            string(string(vtot,"99") + "/" +
            string(vtot,"99")) at 4.
        end.

    page.
  END.
END.
output close.
if opsys = "unix"
then os-command silent lpr value(fila + " " + varquivo).
else os-command silent type value(varquivo) > prn.

 