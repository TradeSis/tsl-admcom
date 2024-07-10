/* helio 02032022 - iepro */
def input  parameter par-etbcod     as int.
def input  parameter par-titdtven   as date.
def input  parameter par-titvlcob   as dec.
def input  param     PTODAY         as date. /* helio 28022022 - iepro */
def output parameter par-juros      as dec init 0.

def var vtottit-jur as dec decimals 2.
def var ljuros      as log.
def var vnumdia     as int.
def var varred      as dec decimals 2.
def var vv          as dec decimals 2.
def var vdias as int. 
def var vct   as int. 

def var vabatedtesp as log.

vabatedtesp = yes.


{juro_titulo.i}

