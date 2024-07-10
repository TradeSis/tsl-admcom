/*****************************************************************************
** Programa : Serbema.p
** Autor ...: Andre
** Data ....: 22/01/2002
** Descricao: Importacao do Arquivo Texto Serial da Impressora Bematech Linux
**************************************************************************/

DEF VAR petbcod LIKE estab.etbcod.
DEF VAR pcaixa LIKE caixa.cxacod.
DEF VAR pdia AS INT.
DEF VAR pmes AS INT.

petbcod = 60.
pcaixa = 1.
pdia = 23.
pmes = 1.
                
/*
def input parameter petbcod like estab.etbcod.
def input parameter pcaixa  like caixa.cxacod.
def input parameter pdia    as int.
def input parameter pmes    as int.
*/

def var dt-ecf as date.
def var cha11 as char format "x(21)".
def var cha12 as char format "x(21)".
def var cha15 as char format "x(21)".
def var cha18 as char format "x(21)".
def var cha19 as char format "x(21)".
def var cha21 as char format "x(21)".

def var val11 as dec.
def var val12 as dec.
def var val15 as dec.
def var val18 as dec.
def var val19 as dec.
def var val21 as dec.
def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(747)".
def  var vcont as int.
def var v01 as char format "x(2)".
def var v02 as char format "x(8)".
def var v03 as char format "x(10)".

DEF VAR a AS CHAR EXTENT 16 .
DEF VAR v AS CHAR EXTENT 16.

DEF VAR vvenda AS DEC.
DEF VAR vicms12 AS DEC.
DEF VAR vicms17 AS DEC.

def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
   
def var vdti as date.
def var vdtf as date.
    def var ii as int.

def var warq as char. 
DEF VAR vvalor AS CHAR.
DEF VAR v04 AS CHAR.
DEF VAR vnao AS CHAR.
DEF VAR vsubst AS CHAR.
DEF VAR visenta AS CHAR.
DEF VAR i AS INT.

warq = "l:\progr\dados.txt".

/*
warq = "/usr/admcom/export/" + 
       string(petbcod,">>9") + string(pcaixa,">>9") + string(pdia,">>9") + 
       string(pmes,"99") + ".cup".
*/

/*
os-command "C:\Arquivos de Programas\Progress\bin\quoter"  
  value(warq) > value(substring(warq,1,length(warq) - 1) + "c").
*/

input from value(warq).

vcont = 0.
repeat:
    import  vlinha.

    vvalor = substr(string(vlinha,"x(747)"),3,18).
    v03 = substr(string(vlinha,"x(747)"),21,14).
    v04 = substr(string(vlinha,"x(747)"),35,14).
    
    a[1] = substr(string(vlinha,"x(747)"),49,4). /*1 Aliquota*/
    a[2] = substr(string(vlinha,"x(747)"),53,4).
    a[3] = substr(string(vlinha,"x(747)"),57,4).
    a[4] = substr(string(vlinha,"x(747)"),61,4).
    a[5] = substr(string(vlinha,"x(747)"),65,4).
    a[6] = substr(string(vlinha,"x(747)"),69,4).
    a[7] = substr(string(vlinha,"x(747)"),73,4).
    a[8] = substr(string(vlinha,"x(747)"),77,4).
    a[9] = substr(string(vlinha,"x(747)"),81,4).
    a[10] = substr(string(vlinha,"x(747)"),85,4).
    a[11] = substr(string(vlinha,"x(747)"),89,4).
    a[12] = substr(string(vlinha,"x(747)"),93,4).
    a[13] = substr(string(vlinha,"x(747)"),97,4).
    a[14] = substr(string(vlinha,"x(747)"),101,4).
    a[15] = substr(string(vlinha,"x(747)"),105,4).
    a[16] = substr(string(vlinha,"x(747)"),109,4). /*Ultima*/ 
    
    v[1] = substr(string(vlinha,"x(747)"),113,14).   
    v[2] = substr(string(vlinha,"x(747)"),127,14).    
    v[3] = substr(string(vlinha,"x(747)"),141,14).     
    v[4] = substr(string(vlinha,"x(747)"),155,14).      
    v[5] = substr(string(vlinha,"x(747)"),169,14).      
    v[6] = substr(string(vlinha,"x(747)"),183,14).        
    v[7] = substr(string(vlinha,"x(747)"),197,14).        
    v[8] = substr(string(vlinha,"x(747)"),211,14).          
    v[9] = substr(string(vlinha,"x(747)"),225,14).           
    v[10] = substr(string(vlinha,"x(747)"),239,14).            
    v[11] = substr(string(vlinha,"x(747)"),253,14).             
    v[12] = substr(string(vlinha,"x(747)"),267,14).              
    v[13] = substr(string(vlinha,"x(747)"),281,14).               
    v[14] = substr(string(vlinha,"x(747)"),295,14).
    v[15] = substr(string(vlinha,"x(747)"),309,14).               
    v[16] = substr(string(vlinha,"x(747)"),323,14).                 
    
    visenta = substr(string(vlinha,"x(747)"),337,14).              
    vnao = substr(string(vlinha,"x(747)"),351,14).                  
    vsubst = substr(string(vlinha,"x(747)"),365,14).                 
    
end.
input close.

DO i = 1 TO 16 :
    IF a[i] = "1700" THEN
        vicms17 = dec(v[i]).
    IF a[i] = "1200" THEN
        vicms12 = dec(v[i]).
    vvenda = vvenda + dec(v[i]).
END.

find first serial where serial.etbcod = petbcod and
                        serial.cxacod = pcaixa and
                        serial.serdat = date(pmes,pdia,year(today)) 
                   no-error.
if not avail serial
then do transaction:
    create serial.
    ASSIGN 
        serial.etbcod = petbcod
        serial.cxacod = pcaixa
        serial.redcod = int(vred)         
        serial.icm12  = vicms12             
        serial.icm17  = vicms17             
        serial.sersub = 0 
        serial.serval = vvenda            
        serial.serdat = date(pmes,pdia,year(today)). 
end.        

