{admcab.i}

def var vetbcod like estab.etbcod.
def var varquivo as char init "/admcom/import/".
update  vetbcod label "Filial"
        varquivo at 1 label "Arquivo" format "x(60)"
        with frame f1 side-label width 80.
if search(varquivo) = ?
then do:
    bell.
    message color red/with
        "Arquivo nao encontrado."
        view-as alert-box.
    return.
end.
        
sresp = no.
message "Confirma importar arquivo?" update sresp.
if not sresp then return.

def temp-table tt-arq no-undo
    field linha as int
    field campos as char extent 50
    index i1 linha
    .

def temp-table tt-problema no-undo
    field codigo as int
    field motivo as char
    field clicod like clien.clicod
    field cpf like clien.ciccgc
    field nome like clien.clinom
    field fone like clien.fone
    field celular like clien.fax
    field email like clien.zona
    index i1 codigo nome.
    
def var v-i as int.
def var vlinha as char.
def var varq-ok as log init yes.

disp "VALIDANDO ARQUIVO" at 1 WITH FRAME FL NO-LABEL.
pause 0.

def var vli as int.

input from value(varquivo).
repeat:
    import unformatted vlinha.
    if num-entries(vlinha,";") <> 23
    then do:
        varq-ok = no.
        leave.
    end. 
    vli = vli + 1.   
end.
input close.
if not varq-ok
then do:
    bell.
    message color red/with
    "Arquivo com problema de layout." skip
    "Impossivel continuar."
    view-as alert-box.
    return.
end.    

disp "IMPORTANDO ARQUIVO" at 1 WITH FRAME FL.
PAUSE 0.

input from value(varquivo).
repeat:
    create tt-arq.
    import delimiter ";" tt-arq.campos.
    v-i = v-i + 1.
    tt-arq.linha = v-i.
end.
input close.

if vli <> v-i
then do:
    disp  "Problema registros validados e imprtados" skip
          "     Registros validados  " vli skip
          "     Registros importados " v-i
          .
    sresp = no.
    message "Deseja continuar?" update sresp.         
    if not sresp then return.
end.
def var vcliaux like clien.clicod.
def var vcliout like clien.clicod.
def var vclicod like cliout.clicod.
find last cliout no-lock no-error.
if avail cliout
then vclicod = cliout.clicod.
else vclicod = 888000000.

vcliaux = vclicod.
vcliout = 888999999.

def var vfone as char format "x(15)".
def var vcpf as char  format "x(15)".
def var vnome as char format "x(15)".
def var vsexo as char.
def var vrua as char  format "x(15)".
def var vnumero as char.
def var vcompl as char.
def var vbairro as char format "x(15)".
def var vmunic as char format "x(15)".
def var vuf as char.
def var vcep as char.
def var vfone1 as char format "x(15)".
def var vfone2 as char format "x(15)".
def var vfone3 as char format "x(15)".
def var vcel as char format "x(15)".
def var vemail as char format "x(15)".
def var vrg as char format "x(15)".

def var vqt as int.

def buffer bcliout for cliout.

disp "GRAVANDO REGISTROS NO ADMCOM" at 1 WITH FRAME FL.
PAUSE 0. 

for each tt-arq.
    
    if linha > 1
    then do:
    vqt = vqt + 1.
    assign
        vfone = if num-entries(campo[2],")") >= 2 and
                   int(substr(entry(2,campo[2],")"),1,1)) > 7 and
                   length(entry(2,campo[2],")")) = 8
                then entry(1,campo[2],")") + ") 9" + entry(2,campo[2],")")
                else campo[2]
        vcpf  = campo[3]
        vnome = campo[4]
        vsexo = campo[6]
        vrua  = campo[7]
        vnumero = campo[8]
        vcompl  = campo[9]
        vbairro = campo[10]
        vmunic  = campo[11]
        vuf     = campo[12]
        vcep    = campo[13]
        vfone1  = if campo[15] <> "" and
                     int(substr(campo[15],1,1)) > 7 and
                     length(campo[15]) = 8
                  then "(" + campo[14] + ") 9" + campo[15]
                  else if campo[15] <> ""
                      then "(" + campo[14] + ")" + campo[15] 
                      else "" 
        vfone2  = if campo[17] <> ""
                  then if int(substr(campo[17],1,1)) > 7 and
                       length(campo[17]) = 8
                    then "(" + campo[16] + ") 9" + campo[17]
                    else "(" + campo[16] + ")" + campo[17]
                  else ""
        vfone3  = if campo[19] <> ""
                  then if int(substr(campo[19],1,1)) > 7 and
                       length(campo[19]) = 8
                    then "(" + campo[18] + ") 9" + campo[19]
                    else "(" + campo[18] + ")" + campo[19]
                  else ""
        vcel    = if campo[21] <> ""
                  then if int(substr(campo[21],1,1)) > 7 and
                       length(campo[21]) = 8
                    then "(" + campo[20] + ") 9" + campo[21]
                    else "(" + campo[20] + ")" + campo[21]
                  else ""
        vemail  = campo[22]
        vrg     = campo[23]
        .

    disp vnome vcpf with frame ff no-label 1 down.
    pause 0.
    
    if vnome <> "" and
       not can-find(first cliout where cliout.clinom = vnome) and
       not can-find(first cliout where cliout.ciccgc = vcpf)
    then do transaction:
    
        vclicod = vclicod + 1.
        if vclicod > vcliout
        then leave.
        
        create cliout.
        assign 
            cliout.etbcad = vetbcod
            cliout.clicod = vclicod
            cliout.fone   = vfone
            cliout.ciccgc = vcpf
            cliout.clinom = vnome
            cliout.sexo   = if vsexo begins "MAS" then yes else no
            cliout.endereco[1] = vrua
            cliout.numero[1]   = int(vnumero)
            cliout.compl[1]    = vcompl
            cliout.bairro[1]   = vbairro
            cliout.cidade[1]   = vmunic
            cliout.ufecod[1]   = vuf
            cliout.cep[1]      = vcep
            cliout.refctel[1]   = vfone1
            cliout.refctel[2]   = vfone2
            cliout.refctel[3]   = vfone3
            cliout.fax    = vcel
            cliout.zona   = vemail
            cliout.ciinsc = vrg
            cliout.dtcad  = today
            cliout.datexp = 01/01/1970   
            .
    end.
    else do transaction:
        create tt-problema.
        assign
            tt-problema.cpf = vcpf
            tt-problema.nome = vnome
            tt-problema.fone = vfone
            tt-problema.celular = vcel
            tt-problema.email = vemail
            .
        if vnome <> ""
        then assign
                tt-problema.codigo = 3000
                tt-problema.motivo = "Falta nome do cliente".
        if can-find(first cliout where cliout.ciccgc = vcpf)
        then assign
                tt-problema.codigo = 4000 
                tt-problema.motivo = "Ja importado anteriormente"
                .
    end.

    assign vfone = ""
           vcpf  = ""
           vnome = ""
           vsexo = ""
           vrua  = ""
           vnumero = ""
           vcompl  = ""
           vbairro = ""
           vmunic  = ""
           vuf     = ""
           vcep    = ""
           vfone1  = ""
           vfone2  = ""
           vfone3  = ""
           vcel    = ""
           vemail  = ""
           vrg     = ""
           .
    end.
end.
    
for each cliout where cliout.dtcad = today and
                      cliout.clicod > vcliaux no-lock:
        find first clien where clien.ciccgc = cliout.ciccgc no-lock no-error.
        if not avail clien
        then do transaction:
            create clien.
            assign
                clien.etbcad = cliout.etbcad
                clien.clicod = cliout.clicod
                clien.fone   = cliout.fone
                clien.ciccgc = cliout.ciccgc
                clien.clinom = cliout.clinom 
                clien.sexo   = cliout.sexo 
                clien.endereco[1] = cliout.endereco[1]
                clien.numero[1]   = cliout.numero[1]
                clien.compl[1]    = cliout.compl[1]
                clien.bairro[1]   = cliout.bairro[1]
                clien.cidade[1]   = cliout.cidade[1] 
                clien.ufecod[1]   = cliout.ufecod[1]
                clien.cep[1]      = cliout.cep[1]
                clien.refctel[1]  = cliout.refctel[1]
                clien.refctel[2]  = cliout.refctel[2]
                clien.refctel[3]  = cliout.refctel[3]
                clien.fax         = cliout.fax
                clien.zona        = cliout.zona
                clien.ciinsc      = cliout.ciinsc 
                clien.dtcad       = cliout.dtcad 
                clien.datexp      = cliout.datexp
                .

            create tt-problema.
            assign
                tt-problema.clicod = clien.clicod
                tt-problema.cpf    = clien.ciccgc
                tt-problema.nome   = clien.clinom
                tt-problema.fone   = clien.fone
                tt-problema.celular = clien.fax
                tt-problema.email   = clien.zona
                tt-problema.codigo = 1000 
                tt-problema.motivo = "Cliente incluido na base do Admcom"
                .

        end.  
        else do transaction:
            create tt-problema.
            assign
                tt-problema.clicod = cliout.clicod
                tt-problema.cpf  = cliout.ciccgc
                tt-problema.nome = cliout.clinom
                tt-problema.fone = cliout.fone
                tt-problema.celular = cliout.fax
                tt-problema.email   = cliout.zona
                tt-problema.codigo = 2000
                tt-problema.motivo = "CPF ja existe na base do Admcom" 
                .
            tt-problema.motivo = "CPF ja existe na base do Admcom".
        end.
end.

for each tt-problema where tt-problema.codigo = 1000 no-lock:
    find first bcliout where bcliout.clicod = tt-problema.clicod no-error.
    assign
        bcliout.cli_status = tt-problema.codigo
        bcliout.des_status = tt-problema.motivo
        .
end.
for each tt-problema where tt-problema.codigo = 2000 no-lock:
    find first bcliout where bcliout.clicod = tt-problema.clicod no-error.
    assign
        bcliout.cli_status = tt-problema.codigo
        bcliout.des_status = tt-problema.motivo
        .
end.

hide frame ff no-pause.

disp "GERANDO RELATORIOS" at 1 with frame fl.
pause 0.

def var varq1000 as char.
def var vreg1000 as int.
def var varq2000 as char.
def var vreg2000 as int.
def var varq3000 as char.
def var vreg3000 as int.
def var varq4000 as char.
def var vreg4000 as int.

varq1000 = "/admcom/relat/cdl-incluidos-" + 
            string(today,"99999999") + ".csv".
varq2000 = "/admcom/relat/cdl-cpfexiste-" + 
            string(today,"99999999") + ".csv".
varq3000 = "/admcom/relat/cdl-faltanome-" + 
            string(today,"99999999") + ".csv".
varq4000 = "/admcom/relat/cdl-jaenviado-" + 
            string(today,"99999999") + ".csv".
          
output to value(varq1000).
put "CPF;Nome;Telefone;Celular;Email" skip.             
for each tt-problema where 
         tt-problema.codigo = 1000 no-lock:
    put unformatted tt-problema.cpf ";"
                    tt-problema.nome ";"
                    tt-problema.fone ";"
                    tt-problema.celular ";"
                    tt-problema.email
                    skip.
    vreg1000 = vreg1000 + 1.                
end.
output close.   

output to value(varq2000).
put "CPF;Nome;Telefone;Celular;Email" skip.             
for each tt-problema where 
         tt-problema.codigo = 2000 no-lock:
    put unformatted tt-problema.cpf ";"
                    tt-problema.nome ";"
                    tt-problema.fone ";"
                    tt-problema.celular ";"
                    tt-problema.email
                    skip.
    vreg2000 = vreg2000 + 1.
end.
output close.    
          
output to value(varq3000).
put "CPF;Nome;Telefone;Celular;Email" skip.             
for each tt-problema where 
         tt-problema.codigo = 3000 no-lock:
    put unformatted tt-problema.cpf ";"
                    tt-problema.nome ";"
                    tt-problema.fone ";"
                    tt-problema.celular ";"
                    tt-problema.email
                    skip.
    vreg3000 = vreg3000 + 1.
end.
output close.    

output to value(varq4000).
put "CPF;Nome;Telefone;Celular;Email" skip.             
for each tt-problema where 
         tt-problema.codigo = 4000 no-lock:
    put unformatted tt-problema.cpf ";"
                    tt-problema.nome ";"
                    tt-problema.fone ";"
                    tt-problema.celular ";"
                    tt-problema.email
                    skip.
    vreg4000 = vreg4000 + 1.
end.
output close.    

disp "FIM" at 1 with frame fl.
pause 0.

message color red/with
"Arquivos gerados" skip
varq1000 "(" vreg1000  "registros)" skip
varq2000 "(" vreg2000  "registros)" skip
varq3000 "(" vreg3000  "registros)" skip
varq4000 "(" vreg4000  "registros)" skip
view-as alert-box.



