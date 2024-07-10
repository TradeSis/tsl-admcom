{admcab.i.ssh}

def input parameter p-tipo as char.

def var varquivo as char.

def var vmail as char init "inventario-ssh@lebes.com.br".

def var vestilo as char.
def var vestacao like estac.etcnom.
def var vetbcod like setbcod.
def var varq-log    as char.
def var vassunto    as char.

if p-tipo = "MENU-E"
then update vetbcod label "Filial" with frame f-1 side-label width 80.
else vetbcod = setbcod.
find estab where estab.etbcod = vetbcod no-lock .
disp vetbcod estab.etbnom no-label with frame f-1.
sresp = no.
IF p-tipo = "ESTOQUES" or
   p-tipo = "MENU-E"
THEN DO:
message "CONFIRMA GERAR ARQUIVO DA BASE DE ESTOQUES ? " UPDATE SRESP.
if not sresp then return.
disp "GERANDO ARQUIVO DA BASE DE ESTOQUES... AGUARDE!"
    WITH ROW 10 1 down centered no-box color message.
varquivo = "/admcom/inventario/estcontr_" + string(vetbcod,"999") + "_" +
                string(time) + ".txt".
output to value(varquivo).
for each estoq where estoq.etbcod = vetbcod no-lock:

    find first produ where produ.procod = estoq.procod no-lock no-error.
    if not avail produ
    then next.
        
    if produ.catcod <> 31 and
       produ.catcod <> 41
    then next.
     
    
    put estoq.etbcod format ">>>9" ";"
        estoq.procod format ">>>>>>>>>9" ";"
        estoq.estatual format "->>>>>>>9" ";"
        produ.catcod format ">>9" skip.

end.

output close.
output to ./inv.log.

/* unix value("zip " + varquivo + ".z " + varquivo).

varquivo = varquivo + ".z".
*/
def var vlog as char.
vlog = "/admcom/logs/inventario/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time).

output close.
unix silent value("/admcom/progr/mail_anexo.sh "
                             + "~"ARQUIVO_ESTOQUE_FILIAL~""
                             + string(vetbcod,"999")
                             + " ~""
                             + varquivo
                             + "~" "
                             + vmail
                             + " "
                             + "inventario@lebes.com.br"
                             + " "
                             + "~"zipar~""
                             + " > "
                             + "/admcom/logs/inventario/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time)                                                  + " 2>&1 ").   

    message "E-MAIL ENVIADO PARA " vmail "!". pause 3.
    message "ZIPANDO E ENVIANDO ARQUIVO POR RCP...".
    
    unix silent value("zip " + varquivo + ".z " + varquivo + ";chmod 777 " + varquivo).


    unix silent value("sudo scp -p " + varquivo + ".z" +
                        " filial" + string(vetbcod,"999") +
                        ":/usr/admcom/inventario").

    
    message "PROCESSO TOTAL FINALIZADO! PRESSIONE QUALQUER TECLA P SAIR.". PAUSE.

END.

IF p-tipo = "PRODU"
THEN DO:
message "CONFIRMA GERAR ARQUIVO DA BASE DE PRODUTOS ?  " UPDATE SRESP.
if not sresp then return.
disp "GERANDO ARQUIVO DA BASE DE PRODUTOS... AGUARDE!"
    WITH ROW 10 1 down centered no-box color message.

varquivo = "/admcom/inventario/bascontr_" + string(time) + ".txt".
output to value(varquivo).

for each produ no-lock by produ.procod:

    find first categoria where categoria.catcod = produ.catcod 
                         no-lock no-error.
    if not avail categoria 
    then next.

    if produ.catcod <> 31 and
       produ.catcod <> 41
    then next.
       
    
    find first clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase
    then next.
    
    find first fabri where fabri.fabcod = produ.fabcod no-lock no-error.
    if not avail fabri
    then next.

    find first estoq where estoq.procod = produ.procod no-lock no-error.
    if not avail estoq
    then next.

    vestacao = "".
    find estac where
         estac.etccod = produ.etccod no-lock no-error.
    if avail estac
    then vestacao = estac.etcnom.
    else vestacao = "".
    vestilo = "".
    find first procaract where procaract.procod = produ.procod 
        no-lock no-error.
    if avail procaract
    then do:
        find first subcaract where
                   subcaract.carcod = 2 and
                   subcaract.subcar = procaract.subcod
                   no-lock no-error.
        if avail subcaract
        then vestilo = subcaract.subdes.            
    end.
         
    put produ.procod        format ">>>>>>>>>>>9" ";"
        ""                  format "x(13)" ";"
        produ.pronom        format "x(40)" ";"
        produ.prorefter     format "x(15)" ";"
        categoria.catnom    format "x(20)" ";"
        clase.clacod        format ">>>>>>>>>9" ";"
        clase.clanom        format "x(30)" ";"
        fabri.fabfant       format "x(30)" ";"
        vestacao            format "x(15)" ";"
        vestilo             format "x(15)" ";" 
        (estoq.estvenda * 100) format ">>>>>>>>>9" ";"
        (estoq.estcusto * 100) format ">>>>>>>>>9" ";"
        produ.catcod        format ">>9"  skip.
end.

output close.

output to ./inv.log.

/*
unix silent value("zip " + varquivo + ".z " + varquivo).
varquivo = varquivo + ".z".
*/

output close.

/**************
unix silent value("/admcom/progr/mail_anexo.sh "
                             + "~"ARQUIVO_BASE_PRODUTOS~""
                             + string(vetbcod,"999")
                             + " ~""
                             + varquivo
                             + "~" "
                             + vmail
                             + " "
                             + "informativo@lebes.com.br"
                             + " " 
                             + "~"zipar~""
                             + " > " 
                             + "/admcom/logs/inventario/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time)
                             + " 2>&1 "). 

*********************/

assign varq-log = "/admcom/logs/inventario/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
                        string(year(today),"9999") + "." + string(time).

assign vassunto = "ARQUIVO_BASE_PRODUTOS".
                
unix silent value("/admcom/progr/mail.sh "
                             + "~"" + vassunto + "~" "
                             + varquivo
                             + " "
                             + vmail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + varq-log
                             + " 2>&1 ").
                                                                 
                
message "PROCESSO FINALIZADO. E-MAIL ENVIADO PARA " vmail. PAUSE.
END.

