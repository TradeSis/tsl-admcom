{admcab.i}
    
def var varquivo as char.
if opsys = "UNIX"
then.
else do:
    varquivo = sel-arq01().
end.
update varquivo label "Arquivo" format "x(69)"
            with frame f-arquivo 1 down
             side-label.

if search(varquivo) = ?
then do:
    message color red/with
    "Arquivo nao encontrado."
    view-as alert-box.
    undo.
end.
def var sconf as log format "Sim/Nao".
sconf = no.
message "Confirma importar arquivo ? "  update sconf.
if not sconf then undo.

def var varquivo1 as char.
varquivo1 = varquivo + string(time).
if opsys = "UNIX"
then unix silent value("quoter -d % " +  varquivo  + " > " + varquivo1).
else dos   value("c:\dlc\bin\quoter -d % " +  varquivo  + " > " + varquivo1).

def var vlinha as char.
def var vi as int.
def var vj as int.
def var vcoluna as char extent 20.
def var vordem as int.
input from value(varquivo1).
repeat:
    import vlinha.
    do vi = 1 to num-entries(vlinha,";"):
    end.
    vj = 0.
    vcoluna = "".
    do vj = 1 to vi - 1.
        vcoluna[vj] = trim(entry(vj,vlinha,";")).
        /**
        vcoluna[vj] = entry(1,vcoluna[vj],"~"").    
        if vcoluna[vj] = ""
        then vcoluna[vj] = entry(2,vcoluna[vj],"~""). 
        **/
        if substr(vcoluna[vj],1,1) = "~""
        then vcoluna[vj] = substr(vcoluna[vj],2,length(vcoluna[vj]) - 1).
        if substr(vcoluna[vj],length(vcoluna[vj]),1) = "~""
        then vcoluna[vj] = substr(vcoluna[vj],1,length(vcoluna[vj]) - 1).

    end.
    vordem = vordem + 1.
    create ordemcep.
    assign
        ordemcep.sequencia = vordem
        ordemcep.ufecod = vcoluna[1]
        ordemcep.inicial = int(vcoluna[2])
        ordemcep.final = int(vcoluna[3])
        ordemcep.amarrado = vcoluna[4]
        ordemcep.caixeta = vcoluna[5]
        .
    
end.
input close.


