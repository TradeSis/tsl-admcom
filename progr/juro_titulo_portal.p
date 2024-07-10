/*#2 260620 https://trello.com/c/VOhtoe02/113-cr%C3%A9dito-e-cobran%C3%A7a-cobran%C3%A7a-de-taxa-de-juros-e-taxa-de-boleto */

def input  parameter par-etbcod     as int.
def input  parameter par-titdtven   as date.
def input  parameter par-titvlcob   as dec.
def output parameter par-juros      as dec init 0.

def var vtottit-jur as dec decimals 2.
def var ljuros      as log.
def var vnumdia     as int.
def var varred      as dec decimals 2.
def var vv          as dec decimals 2.
def var vdias as int. /*#2*/
def var vct   as int. /*#2*/


def var vabatedtesp as log.

vabatedtesp = no. /* 25.05.2020 nao abate dtesp no portal */ 

vabatedtesp = yes. /*#2 26.06.2020 abate dtesp no portal -  */ 

/* helio 28022022 - iepro */
def var PTODAY as date. 
pTODAY = today.

{juro_titulo.i}




