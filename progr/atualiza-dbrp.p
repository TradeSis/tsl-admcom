{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.


def var vetbcod like estab.etbcod.

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/audit/" +
                "tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
else varquivo = "l:~\audit~\" +
                "tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +
                string(month(vdti),"99") +
                string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") +
                string(month(vdtf),"99") +
                string(year(vdtf),"9999") + ".txt".
                
update varquivo format "x(70)".

if search(varquivo) = ?
then return.

def var sresp as log format "Sim/Nao".
message "Confirma processamernto? " update sresp.
if not sresp then return.

message "Executando quoter...".

if opsys = "UNIX"
then do:
os-command silent value("/usr/dlc/bin/quoter -c 1-3,4-21,22-26,27-31,32-43,44-51,52-54,55-70,71-71,72-79,80-95,96-103,104-115,11
6-143,144-393 " + varquivo + " > " + varquivo + ".quo").
end.
else do:
os-command silent value("c:\dlc\bin\quoter -c 1-3,4-21,22-26,27-31,32-43,44-5~1,52-54,55-70,71-71,72-79,80-95,96-103,104-115,11
6-143,144-393 " + varquivo + " > " + varquivo + ".quo").
end.

message "Importando arquivo...".

input from value(varquivo + ".quo") .
repeat:
    create arqclien.
    import campo1 campo2 campo3 campo4 campo5 campo6 campo7 campo8 campo9
           campo10 campo11 campo12 campo13 campo14 campo15
           .
    assign       
        mes = month(vdti)
        ano = year(vdti) 
        tipo = campo15
        arqclien.etbcod = int(campo1)
        arqclien.data = date(int(substr(string(campo6),5,2)),
                             int(substr(string(campo6),7,2)),
                             int(substr(string(campo6),1,4)))
        .       
end.
input close.           
           
if opsys = "UNIX"
then do:
    unix silent rm value(varquivo + ".quo").
end.
else do:
    dos silent del value(varquivo + ".quo").
end.     

message "Atualizando DBRP....".

run atualiza1-dbrp.p.




