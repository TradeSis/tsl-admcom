{admcab.i }
def var ii as int.
def var vv as int.
def var cgc-admcom like forne.forcgc.
def var v-rua   like forne.forrua.
def var v-mun   like forne.formunic.
def var v-ufe   like forne.ufecod.
def var v-cep   like forne.forcep.
def var v-bai   like forne.forbairro.

output to /admcom/work/sislan.txt.

/************************ HEADER ****************************/


put unformatted 
/* 01 */       " " format "x(15)" "fiscal"
/* 02 */       " " format "x(01)" 
/* 03 */       " " format "x(20)" "0131"
/* 04 */       " " format "x(01)" 
/* 05 */       " " format "x(30)" 
/* 06 */       " " format "x(01)" 
/* 07 */       " " format "x(15)" 
/* 08 */       " " format "x(01)" 
/* 09 */       " " format "x(10)" 
/* 10 */       " " format "x(01)" 
/* 11 */       " " format "x(10)" 
/* 12 */       " " format "x(01)" 
/* 13 */       " " format "x(06)" 
/* 14 */       " " format "x(01)" 
/* 15 */       " " format "x(08)" 
/* 16 */       " " format "x(01)" 
/* 17 */       " " format "x(18)" 
/* 18 */       " " format "x(01)" 
/* 19 */       " " format "x(18)" 
/* 20 */       " " format "x(01)" 
/* 21 */       " " format "x(08)" 
/* 22 */       " " format "x(01)" 
/* 23 */       " " format "x(721)" 
/* 24 */       " " format "x(01)" 
/* 25 */       " " format "x(06)" 
/* 26 */       " " format "x(01)" skip.


/*************************** LANCAMENTOS *************************/
    
    

    put unformatted
1       " " format "x(15)" 
        " " format "x(01)"
        " " format "x(20)"
        " " format "x(01)"
        " " format "x(30)"
        " " format "x(01)"
        " " format "x(15)"
        " " format "x(01)"
        " " format "x(10)"
10      " " format "x(01)"
        " " format "x(10)"
        " " format "x(01)"
        " " format "x(08)"
        " " format "x(01)"
        " " format "x(30)"
        " " format "x(01)"
        " " format "x(22)"
        " " format "x(01)"
        " " format "x(30)"
20      " " format "x(01)"
        " " format "x(22)"
        " " format "x(01)"
        " " format "x(20)"
        " " format "x(01)"
        " " format "x(20)"
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
30      " " format "x(01)" 
        " " format "x(06)" 
        " " format "x(01)" 
        " " format "x(15)" 
        " " format "x(01)" 
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
40      " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
50      " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
60      " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
70      " " format "x(01)"
        " " format "x(06)"
        " " format "x(01)"
        " " format "x(15)" 
        " " format "x(01)" 
        " " format "x(18)"
        " " format "x(01)"
        " " format "x(05)"
        " " format "x(01)"
        " " format "x(119)"
80      " " format "x(01)"
        " " format "x(15)"
        " " format "x(01)"
        " " format "x(120)"
        " " format "x(01)"
        " " format "x(05)"
        " " format "x(01)"
        " " format "x(01)"  
        " " format "x(01)"  
        " " format "x(03)"  
90      " " format "x(01)"  
        " " format "x(10)"  
        " " format "x(01)"  
        " " format "x(10)"  
        " " format "x(34)"  
        " " format "x(01)"  
        " " format "x(06)"  
97      " " format "x(01)"  skip.

   
/******************** TRAILLER ******************************/
    
    
put unformatted
01  " " format "x(15)" 
02  " " format "x(01)"
03  " " format "x(20)"
04  " " format "x(01)"
05  " " format "x(30)"
06  " " format "x(01)"
07  " " format "x(15)"
08  " " format "x(01)"
09  " " format "x(10)"
10  " " format "x(01)"
11  " " format "x(10)"
12  " " format "x(01)"
13  " " format "x(785)"
14  " " format "x(06)"
15  " " format "x(01)" skip.

output close.


                   