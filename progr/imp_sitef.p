{admcab.i}
disable triggers for load of reccar.
def input parameter p-rede as char.
def input parameter vdti as date.
def input parameter vdtf as date.
def output parameter varquivo as char.
def output parameter vok as log.

def shared temp-table tt-cartao
    field moecod like cartao.moecod
    field rede   as char
    .

def var vcartao as char.
vcartao = trim(p-rede).
find first tt-cartao where
           tt-cartao.rede = p-rede no-error.

def var varq1 as char.
if opsys = "UNIX"
then varquivo = "/admcom/contab-sitef/rec" + 
           string(day(vdti),"99") +
           string(month(vdti),"99") +
           string(year(vdti),"9999") +
           "a" +
           string(day(vdtf),"99") +
           string(month(vdtf),"99") +
           string(year(vdtf),"9999") +
           lc(trim(vcartao)) + ".txt".
else varquivo = "l:\contab-sitef\rec" + 
           string(day(vdti),"99") +
           string(month(vdti),"99") +
           string(year(vdti),"9999") +
           "a" +
           string(day(vdtf),"99") +
           string(month(vdtf),"99") +
           string(year(vdtf),"9999") +
           lc(trim(vcartao)) + ".txt".

/*
varquivo = "/admcom/contab-sitef/rec0104a3004visa.txt".
*/
update varquivo label "Arquivo"  format "x(60)"
    with frame f-arq 1 down width 80
           row 10 side-label.
vok = yes.
if search(varquivo) = ?
then do:
    vok = no.
    return.
end.
sresp = no.
message varquivo "." skip
    "Confirma importar arquivo ? " 
    view-as alert-box buttons yes-no update sresp.
if not sresp
then do:
    vok = no.
    return.
end.

varq1 = varquivo + string(time) + "w.quo".

if opsys = "UNIX"
then unix silent value("/usr/dlc/bin/quoter -d % " + varquivo + " > " + varq1).
else dos  value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varq1).

def temp-table tt-impcar
    field loja      as int
    field datrec    as date
    field datemi    as date
    field valor-b as dec
    field valor-l as dec
    index i1 loja datrec
    . 
    
def var vliq as dec.
def var vbru as dec.
       
def var vi as int.
def var vj as int.
def var vj1 as int.
def var vl as char.       
def var vlinha as int.

def var v as char.
def var va as int.
def var vcampo as int.

disp "Carregando arquivo..>> "  + string(varquivo) format "x(70)"
    with frame f 1 down no-box centered row 10.
pause 0.    
def var d-campo as char extent 100.    
def var c-campo as char.

input from value(varq1).
repeat:
    import v .
    vlinha = vlinha + 1.
    if vlinha <= 4
    then next.
    vcampo = 1.
    vj1 = 1.
    do vi = 1 to num-entries(v,";"):
       d-campo[vi] = trim(entry(vi,v,";")).
       d-campo[vi] = replace(d-campo[vi],'"','').
       d-campo[vi] = replace(d-campo[vi],".","").
       d-campo[vi] = replace(d-campo[vi],",","").

      vcampo = vi.
   end.    
       
    
    /*
    do vi = 1 to 200:
        vl = substr(v,vi,1).
        if vl = ""
        then leave.

        if vl = ";" and substr(v,vi + 1,1) = "~"" or substr(v,vi + 1,1) = ""
        then do:
            vj = vi - 1 - vj1.
            d-campo[vcampo] = substr(v,vj1,vj).
            vcampo = vcampo + 1.
            vj1 = vj1 + vj + 3.
            
        end.
        
    end.
     */
    vliq = 0 . vbru = 0.
 /*
 disp d-campo[1] format "x(8)"   
 d-campo[2] format "x(8)"   
d-campo[3] format "x(8)"   
d-campo[4] format "x(8)"   
d-campo[5] format "x(8)"   
d-campo[6] format "x(8)" with frame f-x.  pause .
      
   */
    vliq = 0. vbru = 0.  
    do vi = 1 to vcampo:
        if vi > 3 and
            d-campo[vi] <> ""
        then do:
            c-campo = "".
         /*   do va = 1 to length(d-campo[vi]):
                if substr(d-campo[vi],va,1) = "."
                then.
                else c-campo = c-campo + substr(d-campo[vi],va,1).
            end.
            if vbru = 0
            then vbru = dec(c-campo) / 100.
            else if vliq = 0
                 then vliq = dec(c-campo) / 100.
                */
    
            if vbru = 0
            then vbru = dec(d-campo[vi]) / 100.
            else if vliq = 0
                then vliq = dec(d-campo[vi]) / 100.
                
        end.    
    end.
    
    create tt-impcar.
    assign
        tt-impcar.loja = 0
        tt-impcar.datrec = date(d-campo[1])
        tt-impcar.datemi = date(d-campo[3])
        tt-impcar.valor-b = vbru
        tt-impcar.valor-l = vliq        .
    disp tt-impcar.datrec
         tt-impcar.datemi
         tt-impcar.valor-b
         tt-impcar.valor-l
         with frame fdd  down centered row 9 no-label.
end.
input close.
/* unix silent value("rm " + varq1) */. 
hide frame f no-pause.
def buffer btt-impcar for tt-impcar.
def var vrede as char.
def var vmoeda as char.
if vcartao = "VISA"
then vmoeda = "RCV".
else if vcartao = "MASTER"
    then vmoeda = "RCM".
    else if vcartao = "BANRI"
        then vmoeda = "RCB".
        else vmoeda = "".
        
def var ind-alfa as char  init "a=1|b=2|c=3|d=4|e=5|f=6|g=7|h=8|i=9|j=10|k=11|l=12|m=13|n=14|o=15|p=16|q=17|r=18|
s=19|t=20|u=21|v=22|x=23|y=24|z=25".


do va = 1 to length(vmoeda):
    vrede = vrede + acha(substr(vmoeda,va,1),ind-alfa).
end. 

for each tt-impcar where datrec <> ? and datemi <> ?:

    find reccar where reccar.etbcod = 0
         and reccar.rede   = int(vrede)
         and reccar.lote   = int(string(month(tt-impcar.datemi),"99") +
                                string(month(tt-impcar.datrec),"99") +
                                string(year(tt-impcar.datrec),"9999"))
         and reccar.numres = "REC"
         and reccar.numpar = int(string(day(tt-impcar.datemi),"99") +
                                string(day(tt-impcar.datrec),"99"))
        no-lock  no-error.
    if not avail reccar
    then do:             
        create reccar.
    
        assign
            reccar.etbcod = 0
            reccar.rede   = int(vrede)
            reccar.numpar = int(string(day(tt-impcar.datemi),"99") +
                                string(day(tt-impcar.datrec),"99"))
            reccar.lote   = int(string(month(tt-impcar.datemi),"99") +
                                string(month(tt-impcar.datrec),"99") +
                                string(year(tt-impcar.datrec),"9999"))    
            reccar.numres = "REC"
            reccar.datrec = tt-impcar.datemi
            reccar.titdtven = tt-impcar.datrec
            reccar.titvlcob = tt-impcar.valor-b
            reccar.titvldes = tt-impcar.valor-b - tt-impcar.valor-l
            reccar.titvlpag = tt-impcar.valor-l.
    end.
    
end.

