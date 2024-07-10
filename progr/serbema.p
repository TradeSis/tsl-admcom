/*****************************************************************************
** Programa : Serbema.p

** Autor ...: Andre
** Data ....: 22/01/2002
** Descricao: Importacao do Arquivo Texto Serial da Impressora Bematech Linux
**************************************************************************/

def input parameter dtini AS DATE.
def input parameter dtfim AS DATE.
def input parameter j    as int.
def var vnome as char.
def var vredred as int.

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
def var vlinha as char format "x(25)".
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

DEF VAR petbcod AS INT.
DEF VAR pcaixa  AS INT.
DEF VAR pdia    AS INT.
DEF VAR pmes    AS INT.

def temp-table ttarquivos
    field nome as char.

i = j.

for each ttarquivos.
    delete ttarquivos.
end.

do dt-ecf = dtini to dtfim:    

    dos silent dir value("l:\import\" + string(i,"99") + "\????" + 
        substring(string(dt-ecf),1,2) + 
        substring(string(dt-ecf),4,2) + "*.cup") 
        /s/b > value("l:\import\" + string(i,"99") + "\arq").
         
    input from value("l:\import\" + string(i,"99") + "\arq").
    repeat:
        import warq.
        assign petbcod = int(substring(warq,14,2))
               pcaixa = int(substring(warq,16,2))
               pdia = int(substring(warq,18,2))
               pmes = int(substring(warq,20,2)).
        
        warq = "l:\import\" +  STRING(i,"99") + "\" + 
            string(petbcod,">>9") + string(pcaixa,">>9") + string(pdia,">>9") + 
            string(pmes,"99") + ".cup".

        create ttarquivos.
        ttarquivos.nome = warq.
    end.
    input close.
    
    for each ttarquivos where ttarquivos.nome <> "": 

        vnome = substring(ttarquivos.nome,1,
                         (length(ttarquivos.nome) - 1)) + "c". 

        dos silent ..\progr\trunca.bat value(ttarquivos.nome) value(vnome). 

        assign petbcod = int(substring(ttarquivos.nome,14,2))
               pcaixa = int(substring(ttarquivos.nome,16,2))
               pdia = int(substring(ttarquivos.nome,18,2))
               pmes = int(substring(ttarquivos.nome,20,2)).
        
        input from value(substring(ttarquivos.nome,1,
                    (length(ttarquivos.nome) - 1)) + "c").
                    
        vcont = 0.
        repeat:
            import  vlinha.
            vvalor = substr(string(vlinha,"x(747)"),12,18).
            v03 = substr(string(vlinha,"x(747)"),30,14).
            v04 = substr(string(vlinha,"x(747)"),44,14).
            a[1] = substr(string(vlinha,"x(747)"),58,4). /*1 Aliquota*/
            a[2] = substr(string(vlinha,"x(747)"),62,4).
            a[3] = substr(string(vlinha,"x(747)"),66,4).
            a[4] = substr(string(vlinha,"x(747)"),70,4).
            a[5] = substr(string(vlinha,"x(747)"),74,4).
            a[6] = substr(string(vlinha,"x(747)"),78,4).
            a[7] = substr(string(vlinha,"x(747)"),82,4).
            a[8] = substr(string(vlinha,"x(747)"),86,4).
            a[9] = substr(string(vlinha,"x(747)"),90,4).
            a[10] = substr(string(vlinha,"x(747)"),94,4).
            a[11] = substr(string(vlinha,"x(747)"),98,4).
            a[12] = substr(string(vlinha,"x(747)"),102,4).
            a[13] = substr(string(vlinha,"x(747)"),106,4).
            a[14] = substr(string(vlinha,"x(747)"),110,4).
            a[15] = substr(string(vlinha,"x(747)"),114,4).
            a[16] = substr(string(vlinha,"x(747)"),118,4). /*Ultima*/ 
    
            v[1] = substr(string(vlinha,"x(747)"),122,14).   
            v[2] = substr(string(vlinha,"x(747)"),136,14).    
            v[3] = substr(string(vlinha,"x(747)"),150,14).     
            v[4] = substr(string(vlinha,"x(747)"),164,14).      
            v[5] = substr(string(vlinha,"x(747)"),178,14).      
            v[6] = substr(string(vlinha,"x(747)"),192,14).        
            v[7] = substr(string(vlinha,"x(747)"),206,14).        
            v[8] = substr(string(vlinha,"x(747)"),220,14).          
            v[9] = substr(string(vlinha,"x(747)"),234,14).           
            v[10] = substr(string(vlinha,"x(747)"),248,14).            
            v[11] = substr(string(vlinha,"x(747)"),262,14).             
            v[12] = substr(string(vlinha,"x(747)"),276,14).              
            v[13] = substr(string(vlinha,"x(747)"),290,14).               
            v[14] = substr(string(vlinha,"x(747)"),304,14).
            v[15] = substr(string(vlinha,"x(747)"),318,14).               
            v[16] = substr(string(vlinha,"x(747)"),332,14).                 
            visenta = substr(string(vlinha,"x(747)"),346,14).              
            vnao = substr(string(vlinha,"x(747)"),360,14).                  
            vsubst = substr(string(vlinha,"x(747)"),374,14).                 
        end.
        input close.
            
        vvenda = 0.
        DO i = 1 TO 16 :
            IF a[i] = "1700" THEN
            vicms17 = dec(v[i]).
            IF a[i] = "1200" THEN
            vicms12 = dec(v[i]).
            vvenda = vvenda + dec(v[i]).
        END.
        vredred = int(string(pdia) + string(pmes) + string(year(today))).

        find first serial where serial.etbcod = petbcod and
                                serial.cxacod = pcaixa and
                                serial.redcod = vredred 
                   no-error.
        if not avail serial
        then do transaction:
            create serial.
            ASSIGN 
                serial.etbcod = petbcod
                serial.cxacod = pcaixa
                serial.redcod = vredred
                serial.icm12  = vicms12 / 100            
                serial.icm17  = vicms17 / 100            
                serial.sersub = dec(vsubst) / 100
                serial.serval = vvenda / 100            
                serial.serdat = date(pmes,pdia,year(today)). 
        end.
    END.
END.
