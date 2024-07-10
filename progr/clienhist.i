/* helio 14082023 - M Histórico de alteração - Solicitação compliance */
/* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 - include clienhist.i */
    
def var trw-{&tabela}-1 as int.
def var trw-{&tabela}-c as char.
def var trw-{&tabela}-a as char.
def var trw-{&tabela}-d as char.
def new global shared var setbcod    like estab.etbcod.
def new global shared var scxacod    like estab.etbcod.
def new global shared var xfuncod    like func.funcod.

    do on error undo:
        create clienhist.
        clienhist.clicod = {&tabela}.clicod.
        clienhist.dtalt  = today.
        clienhist.hralt  = time.
        clienhist.etbcod = setbcod.
        clienhist.funcod = xfuncod.
        clienhist.cxacod = scxacod. /* helio 14082023 */
        clienhist.programa = program-name(2).
        if num-entries(clienhist.programa,"/") > 1 then clienhist.programa = entry(num-entries(clienhist.programa,"/"),clienhist.programa,"/").    
        BUFFER-COMPARE {&tabela} TO {&old} SAVE clienhist.camposdif. 
        
        clienhist.camposdif = replace(clienhist.camposdif,"zona","email").
        clienhist.camposdif = replace(clienhist.camposdif,"celular","fax").
        clienhist.camposdif = replace(clienhist.camposdif,"ciccgc","Cpf/CNPJ").
        
        do trw-{&tabela}-1 = 1 to num-entries(clienhist.camposdif).
            trw-{&tabela}-c = entry(trw-{&tabela}-1,clienhist.camposdif).
            trw-{&tabela}-a = "".
            trw-{&tabela}-d = "".
            
            CASE trw-{&tabela}-c: 
            WHEN "bairro" THEN do:
                trw-{&tabela}-a = string({&old}.bairro[1]).
                trw-{&tabela}-d = string({&tabela}.bairro[1]).
              end. 
            WHEN "cep" THEN do:
                trw-{&tabela}-a = string({&old}.cep[1]).
                trw-{&tabela}-d = string({&tabela}.cep[1]).
              end. 
            WHEN "cidade" THEN do:
                trw-{&tabela}-a = string({&old}.cidade[1]).
                trw-{&tabela}-d = string({&tabela}.cidade[1]).
              end. 
            WHEN "ciinsc" THEN do:
                trw-{&tabela}-a = string({&old}.ciinsc).
                trw-{&tabela}-d = string({&tabela}.ciinsc).
              end. 
            WHEN "clinom" THEN do:
                trw-{&tabela}-a = string({&old}.clinom).
                trw-{&tabela}-d = string({&tabela}.clinom).
              end. 
            WHEN "compl" THEN do:
                trw-{&tabela}-a = string({&old}.compl[1]).
                trw-{&tabela}-d = string({&tabela}.compl[1]).
              end. 
            WHEN "mae" THEN do:
                trw-{&tabela}-a = string({&old}.mae).
                trw-{&tabela}-d = string({&tabela}.mae).
              end. 

            WHEN "pai" THEN do:
                trw-{&tabela}-a = string({&old}.pai).
                trw-{&tabela}-d = string({&tabela}.pai).
              end. 
            WHEN "nacion" THEN do:
                trw-{&tabela}-a = string({&old}.nacion).
                trw-{&tabela}-d = string({&tabela}.nacion).
              end. 
            WHEN "ufecod" THEN do:
                trw-{&tabela}-a = string({&old}.ufecod[1]).
                trw-{&tabela}-d = string({&tabela}.ufecod[1]).
              end. 
            
            WHEN "dtnasc" THEN do:
                trw-{&tabela}-a = string({&old}.dtnasc,"99/99/9999").
                trw-{&tabela}-d = string({&tabela}.dtnasc,"99/99/9999").
              end. 
            WHEN "numero" THEN do:
                trw-{&tabela}-a = string({&old}.numero[1]).
                trw-{&tabela}-d = string({&tabela}.numero[1]).
              end. 
            WHEN "Cpf/CNPJ" THEN do:
                trw-{&tabela}-a = string({&old}.ciccgc).
                trw-{&tabela}-d = string({&tabela}.ciccgc).
              end. 
            WHEN "estciv" THEN do:
                trw-{&tabela}-a = string({&old}.estciv).
                trw-{&tabela}-d = string({&tabela}.estciv).
              end. 
            /* helio 14082023 */
            WHEN "email" THEN do:
                trw-{&tabela}-a = string({&old}.zona).
                trw-{&tabela}-d = string({&tabela}.zona).
              end. 
            WHEN "fone" THEN do:
                trw-{&tabela}-a = string({&old}.fone).
                trw-{&tabela}-d = string({&tabela}.fone).
              end. 
            WHEN "celular" THEN do:
                trw-{&tabela}-a = string({&old}.fax).
                trw-{&tabela}-d = string({&tabela}.fax).
              end. 
            WHEN "endereco" THEN do:
                trw-{&tabela}-a = string({&old}.endereco[1]).
                trw-{&tabela}-d = string({&tabela}.endereco[1]).
              end. 
            END CASE.
            
            if trw-{&tabela}-a <> trw-{&tabela}-d
            then do:
                clienhist.camposantes   = clienhist.camposantes     + if clienhist.camposantes  = "" then trw-{&tabela}-a else "," + trw-{&tabela}-a.
                clienhist.camposdepois  = clienhist.camposdepois    + if clienhist.camposdepois = "" then trw-{&tabela}-d else "," + trw-{&tabela}-d.
            end.
            else do:
                clienhist.camposantes   = clienhist.camposantes     + if clienhist.camposantes  = "" then "-" else "," + "-".
                clienhist.camposdepois  = clienhist.camposdepois    + if clienhist.camposdepois = "" then "-" else "," + "-".
            end.

        end.
    end.
