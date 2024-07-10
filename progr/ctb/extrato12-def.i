def {1} shared var vdata1 as date.
def {1} shared var vdata2 as date.
def {1} shared var vetbcod like estab.etbcod.
def {1} shared var vprocod like produ.procod.
def {1} shared var sal-ant as dec.
def {1} shared var sal-atu as dec.
def {1} shared var t-sai as dec.
def {1} shared var t-ent as dec.
def var v-ent as dec.
def var v-sai as dec.

def var vdata as date.
def var vmes as int.
def var vano as int.
def var vemit as log.
def var vdest as log.
def var vdestaj as log.
def var p-retorna as log.
def var vnumero as char format "x(9)".
def var vmovtnom like tipmov.movtnom.
def var vmovqtm like movim.movqtm.
def var datasai as date.
def var vdesti like movim.desti.
def {1} shared var vdt as date.
def {1} shared var vdisp as log.

def {1} shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field hora as int
    field movtdc like tipmov.movtdc
    field movtnom as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field opfcod like movim.opfcod
    index i1 procod data hora
    .
     
def {1} shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    field mes-cto as int
    field cus-ent as dec
    field cus-med as dec
    index i1 ano-cto mes-cto etbcod procod
    .

def temp-table extrato-movim no-undo
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field hora as int
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc 
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    field seq as int
    index i1 seq.

form extrato-movim.data    column-label "Data Saida" format "99/99/9999" 
     help "d=PgDn  u=PgUp  f=Ultimo  p=primeiro  n=NFiscal  o=+opções"
     extrato-movim.tipmov  column-label "Operacao"   format "x(12)"
     extrato-movim.numero  column-label "Documento"  format "x(9)"
     extrato-movim.serie   column-label "SE"         format "x(02)"
     extrato-movim.emite   column-label "Emite"      format ">>>>>>>>>"
     extrato-movim.desti   column-label "Desti"      format ">>>>>>>>>>"
     extrato-movim.movqtm  column-label "Quant"      format "->>>9" 
     extrato-movim.movpc   column-label "Valor"      format ">>>9.99" 
     extrato-movim.sal-atu column-label "Saldo"      format "->>>>9" 
     with frame frame-a  12 down overlay
                                 ROW 5 CENTERED color white/gray width 80.

form tt-saldo.sal-ant label "Saldo Anterior" format "->>>>9"
     tt-saldo.qtd-ent   label "Ent" format ">>>>>9"
     tt-saldo.qtd-sai   label "Sai" format ">>>>>9"
     tt-saldo.sal-atu label "Saldo no periodo" format "->>>>9"
     with frame f-sal centered row 21 side-label no-box
                                        color white/red overlay.

