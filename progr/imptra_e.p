{admcab.i}
def var vtofcod as char format "x(05)".
def var varquivo as char.
def var vdata like plani.pladat.
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
def temp-table wmovim
    field placod like plani.placod
    field etbcod like plani.etbcod
    field pronom like produ.pronom
    field procod like produ.procod.

def input parameter  par-rec as recid.

DEF VAR vlinha      AS INT FORMAT "99" INITIAL 0.
DEF VAR vimp_cab    AS LOG INITIAL YES.
def var i as i.
def var vsub-total  like plani.platot no-undo.
def var recatu2             as recid.
def var vserviss            as dec format "zz,z99.99".
def var vrespfre            as int format "9".
def var vtitnum             as char extent 4 initial 0.
def var vtitpar             as int format "99" extent 4 initial 0.
def var vtitdtven           like plani.pladat extent 4.
def var vtitvlcob           like plani.platot extent 4 initial 0.
def var vplaca              as char label "Placa".
def var c                   as int.
def buffer bplani for plani.
def buffer bestab for estab.
if opsys = "unix"
   then do:
   find first impress where impress.codimp = setbcod no-lock no-error.
   if avail impress
      then assign fila = string(impress.dfimp). 
   end.                    
     else assign fila = "". 
  
/*put control chr(15).*/

find plani where recid(plani) = par-rec.
find estab where estab.etbcod = plani.desti no-lock no-error.

find first opcom where opcom.movtdc = 11 no-lock no-error.
vtofcod = string(opcom.opccod).


ASSIGN vlinha   = 0
  vimp_cab = YES.

vcont = 0.
vpag  = 0.

vnota = 0.
vcont = 0.
vtot = 0.
vqtd = 0.

vnome = "DREBES & CIA LTDA".

hide frame fdata no-pause.

if opsys = "unix"
then varquivo = "/admcom/relat/nftra" + string(time).
else varquivo = "l:\relat\nftra" + string(time).

output to value(varquivo) page-size 66.
put unformatted chr(27) + "M" + chr(15).


if int(vcont / 24) <> (vcont / 24)
then vtot = truncate((vcont / 24),0) + 1.
else vtot = (vcont / 24).


    put unformatted
        plani.numero    at 145 skip(8)
        "X"             at 101
        plani.numero    at 145 skip
        estab.endereco at 50 
        estab.munic    at 50 space(2)
        estab.ufecod   
        "   Filial- " 
        estab.etbcod   
        estab.etbcgc   at 102 skip(1)
        opcom.opcnom   at 2
        vtofcod        at 59
        estab.etbinsc  at 102 skip(1)
        "DREBES E CIA LTDA - " at 2 estab.etbcod
        estab.etbcgc    at 108
        plani.pladat    at 145 skip(1)
        estab.endereco  at 2 skip
        estab.munic     at 2
        ""              at 75
        estab.ufecod    at 96
        estab.etbinsc   at 108
        skip(2).

  put unformatted
      "Credito de 50% de Energia Eletrica - Referente ao Mes "  at 20 
       string(month(plani.datexp),"99") skip(25).

  put unformatted 
      plani.bicms         at 20 format "zzz,zz9.99"
      plani.icms          at 45 format "zz,zz9.99" 
      plani.bsubst        at 85 format "zz,zz9.99" 
      plani.icmssubst     at 115 format "zz,zz9.99" 
      plani.protot        at 140 format "zzz,zz9.99" skip(1) 
      plani.frete         at 20 format "zz,zz9.99" 
      plani.seguro        at 50 format "zz,zz9.99" 
      plani.ipi           at 115 format "zz,zz9.99" 
      plani.platot        at 140 format "zzz,zz9.99" skip(1)
      vnome               at 4 
      vfre                at 99 
      vplaca              at 106 
      vuf                 at 120 skip(2) 
      vesp                at 35 SKIP(2)
      "LIVRO I, art.32, XLVI do Decreto no. 37.699/97 - RICMS" AT 4.
output close.
if opsys = "unix"
then os-command silent lpr value(fila + " " + varquivo).
else os-command silent type value(varquivo) > prn.

 