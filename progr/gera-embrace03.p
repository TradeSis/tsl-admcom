
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
   

def var vcont as int.
def var vcli as char.
def var vnum as int.
def var i as int.
def var vcep as char.
def var vcidcod as int.

def temp-table tt-cid
    field cidcod    as   char
    field cidnom    like estab.munic
    field bairro    as   char format "x(20)"
    field ufecod    like estab.ufecod
    index i-cid is primary unique cidnom bairro.
 
def temp-table tt-fabri
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom.
    
def temp-table tt-subclase
    field clacod like clase.clacod
    field clasup like clase.clasup
    field clanom like clase.clanom.

def temp-table tt-clase
    field clacod like clase.clacod
    field clasup like clase.clasup
    field clanom like clase.clanom.

def temp-table tt-grupo
    field clacod like clase.clacod
    field clasup like clase.clasup
    field clanom like clase.clanom.

def temp-table tt-setor
    field clacod like clase.clacod
    field clanom like clase.clanom.

def temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    field clacod like clase.clacod
    
    field clasup like clase.clacod
    field fabcod like produ.fabcod
    field estcusto like estoq.estcusto
    
    index iprodu is primary unique procod.

def temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    field dtnasc as   date format "99/99/9999"
    field depen  as char
    field tem-cel as char
    field sexo as char

    field spc    as char
    
    field estciv as int
    field cidade like estab.munic
    
    field prof   as   char
    field celular as char format "x(30)"
    
    field rua as char
    field num as char
    field cep as char
    field compl   as char
    field bairro  as char
    field ufecod      as char format "x(2)"

    
    field etbcod like estab.etbcod

    index iclicod is primary unique clicod.

def temp-table tt-ven
    field etbcod like plani.etbcod
    field vencod like plani.vencod
        index ivencod is primary unique etbcod vencod.
        


def temp-table tt-tipo-pag
    field cod-tip-pag as char format "x(4)"
    field cod-for-pag as char format "x"
    field nome        as char format "x(50)"
    field fincod      as int.


/********************
message "Gerando /gera-embrace/crm_tipo_pagamento.txt".

output to /gera-embrace/crm_tipo_pagamento.txt.


    put "1001"               format "x(10)" ";" 
        "1"                  format "x(10)" ";" 
        "DINHEIRO"           format "x(50)" skip
        
        "1002"               format "x(10)" ";"
        "1"                  format "x(10)" ";"
        "CARTAO DE DEBITO"   format "x(50)" skip
        
        "2001"               format "x(10)" ";"
        "2"                  format "x(10)" ";"
        "CARTAO DE CREDITO"  format "x(50)" skip.
           
    create tt-tipo-pag.
    assign tt-tipo-pag.cod-tip-pag = "1001"
           tt-tipo-pag.cod-for-pag = "1"
           tt-tipo-pag.nome        = "DINHEIRO"
           tt-tipo-pag.fincod = 0.
           
    create tt-tipo-pag.
    assign tt-tipo-pag.cod-tip-pag = "1002"
           tt-tipo-pag.cod-for-pag = "1"
           tt-tipo-pag.nome        = "CARTAO DE DEBITO".
    
    create tt-tipo-pag.
    assign tt-tipo-pag.cod-tip-pag = "2001"
           tt-tipo-pag.cod-for-pag = "2"
           tt-tipo-pag.nome        = "CARTAO DE CREDITO".
           
    
    for each finan no-lock by finan.fincod:
           
        if finan.fincod <= 1
        then next.
           
        find first tt-tipo-pag where 
                   tt-tipo-pag.cod-tip-pag = ("3" + string(finan.fincod,"999"))
                                            no-error.
        if not avail tt-tipo-pag
        then do:
            create tt-tipo-pag.
            assign tt-tipo-pag.cod-tip-pag = ("3" + string(finan.fincod,"999"))
                   tt-tipo-pag.cod-for-pag = "3"
                   tt-tipo-pag.nome        = finan.finnom
                   tt-tipo-pag.fincod      = finan.fincod.
        end.
        
        
        put "3"                         
            finan.fincod format "999"   ";"
            "3"          format "x(10)" ";"
            finan.finnom format "x(50)" 
            skip.
            
    end.    
        
output close.

hide message no-pause.

message "Gerando /gera-embrace/crm_empresas.txt".

output to /gera-embrace/crm_empresas.txt.
    put unformatted 
        "19" format "x(10)" ";"
        "DREBES E CIA LTDA" format "x(50)"
        skip.
output close.

hide message no-pause.

def var vfilial as char.

message "Gerando /gera-embrace/crm_filiais.txt". 

output to /gera-embrace/crm_filiais.txt.
    for each estab no-lock:
        if estab.etbcod >= 100 then next.

        vfilial = "".
        vfilial = "FILIAL " + string(estab.etbcod).
        
        put unformatted 
            string(estab.etbcod) format "x(10)" ";"
            estab.etbnom         format "x(50)"
            skip.
    end. 
output close.

hide message no-pause.

message "Gerando /gera-embrace/crm_movimento_notas_fiscais.txt".

output to /gera-embrace/crm_movimento_notas_fiscais.txt.
    for each estab no-lock:
      for each tipmov where tipmov.movtdc = 5 no-lock:
                            
        for each plani use-index pladat
                 where plani.movtdc  = tipmov.movtdc
                   and plani.etbcod  = estab.etbcod
                   and plani.pladat >= 01/01/2005
                   and plani.pladat <= today - 1 no-lock:
            
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            
            vcli = "".
            vcont = 0.
            do vcont = 1 to length(clien.clinom).

                if substring(clien.clinom,vcont,1) <> ";"
                then vcli = vcli + substring(clien.clinom,vcont,1).
        
            end.

            find tt-cli where tt-cli.clicod = plani.desti no-lock no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = vcli /*clien.clinom*/
                       tt-cli.etbcod = estab.etbcod
                       tt-cli.cidade = clien.cidade[1].

                if clien.dtnasc = ?
                then tt-cli.dtnasc = 01/01/1970.
                else tt-cli.dtnasc = clien.dtnasc.

                tt-cli.prof = (if clien.proprof[1] = ?
                               then " "
                               else clien.proprof[1]).
                
                if clien.fax begins "9" or
                   clien.fax begins "8" or
                   clien.fax begins "519" or
                   clien.fax begins "518" or
                   clien.fax begins "549" or 
                   clien.fax begins "548" 
                then do:
                    tt-cli.celular = "".
                                           

                    do i = 1 to length(clien.fax):   
                        if substring(clien.fax,i,1) = "0" or
                           substring(clien.fax,i,1) = "1" or
                           substring(clien.fax,i,1) = "2" or
                           substring(clien.fax,i,1) = "3" or
                           substring(clien.fax,i,1) = "4" or
                           substring(clien.fax,i,1) = "5" or
                           substring(clien.fax,i,1) = "6" or
                           substring(clien.fax,i,1) = "7" or
                           substring(clien.fax,i,1) = "8" or
                           substring(clien.fax,i,1) = "9" 
                        then tt-cli.celular = tt-cli.celular
                                            + substring(clien.fax,i,1).
                    end.
                end.
                else tt-cli.celular = "".
             
                if tt-cli.celular = ""
                then tt-cli.tem-cel = "N".
                else tt-cli.tem-cel = "S".
            
                tt-cli.bairro = clien.bairro[1].
            
                if clien.numdep <> 0
                then tt-cli.depen = "S".
                else tt-cli.depen = "N".
                
                tt-cli.sexo = if clien.sexo then "M" else "F".
                
                
                find first clispc where clispc.clicod = clien.clicod 
                                    and clispc.dtcanc = ? no-lock no-error. 
                if avail clispc 
                then tt-cli.spc = "S". 
                else tt-cli.spc = "N".

                tt-cli.ufecod = clien.ufecod[1].
                
                if clien.estciv <> 1 and
                   clien.estciv <> 2 and
                   clien.estciv <> 3 and
                   clien.estciv <> 4 and
                   clien.estciv <> 5 and 
                   clien.estciv <> 6
                then tt-cli.estciv = 6.
                else tt-cli.estciv = clien.estciv.
                   
                tt-cli.rua = if clien.endereco[1] <> ?
                             then clien.endereco[1]
                             else "".
                
                vnum = 0.
                
                vnum = (clien.numero[1]).
                
                if vnum = ?
                then vnum = 0.
                
                tt-cli.num = string(vnum).
            
                tt-cli.compl = if (string(clien.compl[1])) <> ? 
                               then (string(clien.compl[1])) 
                               else "".
            
                if  clien.cep[1] <> ?
                then do:
                
                    i = 0.
                    vcep = "".
                    do i = 1 to length(clien.cep[1]):   
                        if substring(clien.cep[1],i,1) = "0" or
                           substring(clien.cep[1],i,1) = "1" or
                           substring(clien.cep[1],i,1) = "2" or
                           substring(clien.cep[1],i,1) = "3" or
                           substring(clien.cep[1],i,1) = "4" or
                           substring(clien.cep[1],i,1) = "5" or
                           substring(clien.cep[1],i,1) = "6" or
                           substring(clien.cep[1],i,1) = "7" or
                           substring(clien.cep[1],i,1) = "8" or
                           substring(clien.cep[1],i,1) = "9" 
                        then vcep = vcep + substring(clien.cep[1],i,1).
                    end.
                    
                    tt-cli.cep = vcep.
                
                end.
                else tt-cli.cep = "".
            
            end.
            
            find tt-ven where tt-ven.etbcod = plani.etbcod
                          and tt-ven.vencod = plani.vencod no-lock no-error.
            if not avail tt-ven
            then do:
                create tt-ven.
                assign tt-ven.vencod = plani.vencod
                       tt-ven.etbcod = plani.etbcod.
            end.

            find first tt-cid where 
                 tt-cid.cidnom = clien.cidade[1] and
                 tt-cli.bairro = clien.bairro[1] no-lock no-error.
            
            /***** put *****/
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                
                find produ where 
                     produ.procod = movim.procod no-lock no-error.
                
                find  estoq where
                     estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod
                     no-lock no-error.

                find clase where 
                     clase.clacod = produ.clacod no-lock no-error.
                if not avail clase
                then next.
                                
                find fabri where
                     fabri.fabcod = produ.fabcod no-lock no-error.
                
                find tt-produ where 
                     tt-produ.procod = movim.procod no-error.
                if not avail tt-produ
                then do:
                    create tt-produ.
                    assign tt-produ.procod = produ.procod
                           tt-produ.pronom = produ.pronom
                           tt-produ.clacod = produ.clacod
                           
                           tt-produ.clasup = clase.clasup
                           tt-produ.fabcod = produ.fabcod
                           tt-produ.estcusto = estoq.estcusto.
                end.
            
                find tt-subclase where
                     tt-subclase.clacod = produ.clacod no-error.
                if not avail tt-subclase
                then do:
                    create tt-subclase.
                    assign tt-subclase.clacod = clase.clacod
                           tt-subclase.clanom = clase.clanom
                           tt-subclase.clasup = clase.clasup.
                end.
                
                find tt-fabri where
                     tt-fabri.fabcod = produ.fabcod no-error.
                if not avail tt-fabri
                then do:
                    create tt-fabri.
                    assign tt-fabri.fabcod = fabri.fabcod
                           tt-fabri.fabnom = (if fabri.fabfan <> ""
                                              then fabri.fabfan
                                              else fabri.fabnom).
                end.
                if plani.numero = ?
                then next.
            
            
                /*** Movimento NF ***/

                put unformatted
                    string(plani.etbcod)         format "x(10)"      ";"
                    string(plani.numero)         format "x(10)"      ";"
                    plani.pladat                 format "99/99/9999" ";"
                    string(plani.vencod)         format "x(10)"      ";".
                    
                if plani.crecod = 1
                then put "1001"                  format "x(10)"      ";".
                else do:
                    find first tt-tipo-pag where 
                               tt-tipo-pag.fincod = plani.pedcod no-error.
                    if avail tt-tipo-pag
                    then put tt-tipo-pag.cod-tip-pag format "x(10)"  ";".
                    else put "1001"                  format "x(10)"  ";".
                end.


                put string(plani.movtdc)         format "x(10)"      ";"
                    string(produ.procod)         format "x(20)"      ";"
                    string(produ.fabcod)         format "x(10)"      ";".

                put string(plani.desti)          format "x(20)"      ";"

                    (if movim.movtdc = 5
                     then (if movim.movqtm > 0
                           then movim.movqtm
                           else 0)
                     else 0)                  format "9999999999.99" ";"
                    
                    (if movim.movtdc = 5
                     then (if movim.movpc > 0
                           then movim.movpc
                           else 0)
                     else 0)                     format "9999999999.99" ";"

                    (if estoq.estcusto > 0
                     then estoq.estcusto
                     else 0)                     format "9999999999.99" ";"
                    
                    /*Acrescimo*/
                    
                    (if (plani.biss - plani.platot) > 0
                     then (if
                          (((movim.movqtm * movim.movpc) / plani.platot) *
                         (plani.biss - plani.platot)) > 0
                           then (((movim.movqtm * movim.movpc) / plani.platot) *
                         (plani.biss - plani.platot))
                           else 0)
                     else 0)                     format "9999999999.99"
                    
                    skip.
                
                
            end.
            
          end.    
      
      end.
    end.
output close.

hide message no-pause.
****************************************/
def var vendedor as char.
/*******************************
message "Gerando /gera-embrace/crm_vendedores.txt".

output to /gera-embrace/crm_vendedores.txt.
   for each func where func.funcod < 90 no-lock:
   
       put unformatted 
           string(func.funcod) format "x(10)" ";" 
           string(func.etbcod) format "x(10)" ";" 
           func.funnom format "x(50)" 
           skip.  
   end. 
output close.
                                                               
hide message no-pause.

message "Gerando /gera-embrace/crm_produtos.txt".

output to /gera-embrace/crm_produtos.txt.

    for each tt-produ:
        
        find first estoq where estoq.procod = tt-produ.procod no-lock no-error.
        
        put unformatted
            string(tt-produ.procod) format "x(20)" ";"
            string(tt-produ.clacod) format "x(20)" ";"

            string(tt-produ.clasup) format "x(20)" ";"
            string(tt-produ.fabcod) format "x(20)" ";"
            
            tt-produ.pronom         format "x(50)" ";"
            estoq.estcusto          format "9999999999.99" 
            
            skip.
    end.
    
output close.

hide message no-pause.

message "/gera-embrace/crm_sub-classes.txt".

output to /gera-embrace/crm_sub-classes.txt.
    for each tt-subclase:
        put unformatted
            string(tt-subclase.clacod) format "x(20)" ";"
            string(tt-subclase.clasup) format "x(20)" ";"
            string(tt-subclase.clanom) format "x(50)"
            skip.
    end.
output close.

hide message no-pause.

for each tt-subclase:
    find clase where clase.clacod = tt-subclase.clasup no-lock no-error.
    if not avail clase then next.
    find tt-clase where tt-clase.clacod = clase.clacod no-error.
    if not avail tt-clase
    then do:
        create tt-clase.
        assign tt-clase.clacod = clase.clacod
               tt-clase.clanom = clase.clanom
               tt-clase.clasup = clase.clasup.
    end.
end.

message "/gera-embrace/crm_classes.txt".

output to /gera-embrace/crm_classes.txt.
    for each tt-clase:
        put unformatted
            string(tt-clase.clacod) format "x(20)" ";"
            string(tt-clase.clasup) format "x(20)" ";"
            string(tt-clase.clanom) format "x(50)"
            skip.
    end.
output close.

hide message no-pause.

for each tt-clase:
    find clase where clase.clacod = tt-clase.clasup no-lock no-error.
    if not avail clase then next.
    
    find tt-grupo where tt-grupo.clacod = clase.clacod no-error.
    if not avail tt-grupo
    then do:
        create tt-grupo.
        assign tt-grupo.clacod = clase.clacod
               tt-grupo.clanom = clase.clanom
               tt-grupo.clasup = clase.clasup.
    end.
end.

message "/gera-embrace/crm_grupos.txt".

output to /gera-embrace/crm_grupos.txt.
    for each tt-grupo:
        put unformatted
            string(tt-grupo.clacod) format "x(20)" ";"
            string(tt-grupo.clasup) format "x(20)" ";"
            string(tt-grupo.clanom) format "x(50)"
            skip.
    end.
output close.

hide message no-pause.

for each tt-grupo:
    find clase where clase.clacod = tt-grupo.clasup no-lock no-error.
    if not avail clase then next.
    find tt-setor where tt-setor.clacod = clase.clacod no-error.
    if not avail tt-setor
    then do:
        create tt-setor.
        assign tt-setor.clacod = clase.clacod
               tt-setor.clanom = clase.clanom.
    end.
end.

message "/gera-embrace/crm_setor.txt".

output to /gera-embrace/crm_setor.txt.
    for each tt-setor:
        put unformatted
            string(tt-setor.clacod) format "x(20)" ";"
            string(tt-setor.clanom) format "x(50)"
            skip.
    end.
output close.

hide message no-pause.

message "/gera-embrace/crm_marcas.txt".

output to /gera-embrace/crm_marcas.txt.
    for each tt-fabri:
        put unformatted
            string(tt-fabri.fabcod) format "x(20)" ";"
            string(tt-fabri.fabnom) format "x(50)"
            skip.
    end.
output close.

hide message no-pause.

message "/gera-embrace/crm_tipo_movimento.txt".

output to /gera-embrace/crm_tipo_movimento.txt.
    for each tipmov no-lock:
        put unformatted
            string(tipmov.movtdc) format "x(10)" ";"
            tipmov.movtnom        format "x(20)"
            skip.
    end.
output close.

hide message no-pause.

message "/gera-embrace/crm_forma_pagamento.txt".

output to /gera-embrace/crm_forma_pagamento.txt.

    put "1" format "x(10)" ";" "A VISTA"   format "x(50)"  skip
        "2" format "x(10)" ";" "A PRAZO"   format "x(50)"  skip
        "3" format "x(10)" ";" "CREDIARIO" format "x(50)"  skip.
        
        
output close.
***************************************************/



for each clien no-lock:

            vcli = "".
            vcont = 0.
            do vcont = 1 to length(clien.clinom).

                if substring(clien.clinom,vcont,1) <> ";"
                then vcli = vcli + substring(clien.clinom,vcont,1).
        
            end.

            find tt-cli where tt-cli.clicod = clien.clicod no-lock no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = vcli /*clien.clinom*/
                       tt-cli.etbcod = estab.etbcod
                       tt-cli.cidade = clien.cidade[1].

                if clien.dtnasc = ?
                then tt-cli.dtnasc = 01/01/1970.
                else tt-cli.dtnasc = clien.dtnasc.

                tt-cli.prof = (if clien.proprof[1] = ?
                               then " "
                               else clien.proprof[1]).
                
                if clien.fax begins "9" or
                   clien.fax begins "8" or
                   clien.fax begins "519" or
                   clien.fax begins "518" or
                   clien.fax begins "549" or 
                   clien.fax begins "548" 
                then do:
                    tt-cli.celular = "".
                                           

                    do i = 1 to length(clien.fax):   
                        if substring(clien.fax,i,1) = "0" or
                           substring(clien.fax,i,1) = "1" or
                           substring(clien.fax,i,1) = "2" or
                           substring(clien.fax,i,1) = "3" or
                           substring(clien.fax,i,1) = "4" or
                           substring(clien.fax,i,1) = "5" or
                           substring(clien.fax,i,1) = "6" or
                           substring(clien.fax,i,1) = "7" or
                           substring(clien.fax,i,1) = "8" or
                           substring(clien.fax,i,1) = "9" 
                        then tt-cli.celular = tt-cli.celular
                                            + substring(clien.fax,i,1).
                    end.
                end.
                else tt-cli.celular = "".
             
                if tt-cli.celular = ""
                then tt-cli.tem-cel = "N".
                else tt-cli.tem-cel = "S".
            
                tt-cli.bairro = clien.bairro[1].
            
                if clien.numdep <> 0
                then tt-cli.depen = "S".
                else tt-cli.depen = "N".
                
                tt-cli.sexo = if clien.sexo then "M" else "F".
                
                
                find first clispc where clispc.clicod = clien.clicod 
                                    and clispc.dtcanc = ? no-lock no-error. 
                if avail clispc 
                then tt-cli.spc = "S". 
                else tt-cli.spc = "N".

                tt-cli.ufecod = clien.ufecod[1].
                
                if clien.estciv <> 1 and
                   clien.estciv <> 2 and
                   clien.estciv <> 3 and
                   clien.estciv <> 4 and
                   clien.estciv <> 5 and 
                   clien.estciv <> 6
                then tt-cli.estciv = 6.
                else tt-cli.estciv = clien.estciv.
                   
                tt-cli.rua = if clien.endereco[1] <> ?
                             then clien.endereco[1]
                             else "".
                
                vnum = 0.
                
                vnum = (clien.numero[1]).
                
                if vnum = ?
                then vnum = 0.
                
                tt-cli.num = string(vnum).
            
                tt-cli.compl = if (string(clien.compl[1])) <> ? 
                               then (string(clien.compl[1])) 
                               else "".
            
                if  clien.cep[1] <> ?
                then do:
                
                    i = 0.
                    vcep = "".
                    do i = 1 to length(clien.cep[1]):   
                        if substring(clien.cep[1],i,1) = "0" or
                           substring(clien.cep[1],i,1) = "1" or
                           substring(clien.cep[1],i,1) = "2" or
                           substring(clien.cep[1],i,1) = "3" or
                           substring(clien.cep[1],i,1) = "4" or
                           substring(clien.cep[1],i,1) = "5" or
                           substring(clien.cep[1],i,1) = "6" or
                           substring(clien.cep[1],i,1) = "7" or
                           substring(clien.cep[1],i,1) = "8" or
                           substring(clien.cep[1],i,1) = "9" 
                        then vcep = vcep + substring(clien.cep[1],i,1).
                    end.
                    
                    tt-cli.cep = vcep.
                
                end.
                else tt-cli.cep = "".
            
            end.
end.         







hide message no-pause.

message "/gera-embrace/crm_clientes.txt". 

output to /gera-embrace/crm_clientes.txt.
    
    for each tt-cli:  
    
        put string(tt-cli.clicod) format "x(20)"      ";"
            """" tt-cli.clinom         format "x(50)" """"     ";"
            tt-cli.dtnasc         format "99/99/9999" ";"
            tt-cli.depen          format "X"          ";"
            tt-cli.tem-cel        format "X"          ";"
            tt-cli.sexo           format "X"          ";"
            tt-cli.spc            format "X"          ";"
            tt-cli.estciv         format "9"          ";"
            """" tt-cli.cidade         format "x(50)" """"     ";"
            """" tt-cli.prof           format "x(50)" """"     ";"
            tt-cli.celular        format "x(30)"      ";"
            """" tt-cli.rua            format "x(50)" """"     ";"
            
            tt-cli.num            format "x(10)"      ";"
            
            """" tt-cli.compl          format "x(20)" """"     ";"
            """" tt-cli.bairro         format "x(50)" """"     ";"
            tt-cli.ufecod         format "XX"         ";"
            tt-cli.cep            format "x(20)"      ";"

            string(tt-cli.etbcod) format "x(10)".

            put skip.

    end. 
        
output close.

hide message no-pause.



output to /gera-embrace/crm_conjuges.txt.
    
    for each tt-cli no-lock:  
        
        find clien where clien.clicod = tt-cli.clicod no-lock.
        
        put string(clien.clicod) format "x(20)"      ";"
            clien.conjuge                            ";"
            clien.nascon            ";"
            clien.proemp[2]         ";"
            clien.protel[2]         ";"
            clien.prodta[2]         ";"
            clien.proprof[2]        ";"
            clien.prorenda[2]       ";"
            clien.endereco[3]       ";"
            clien.numero[3]         ";"
            clien.compl[3]          ";"
            clien.bairro[3]         ";"
            clien.cidade[3]         ";"
            clien.ufecod[3]         ";"
            clien.cep[3]            skip.
            
    end. 
        
output close.

/*********************************
message "/gera-embrace/crm_rfvcli.txt".

output to /gera-embrace/crm_rfvcli.txt.
    
    for each rfvcli no-lock:
      
        put rfvcli.etbcod     ";"
            string(rfvcli.clicod) format "x(20)"   ";"
            rfvcli.recencia   ";"
            rfvcli.frequencia ";"
            rfvcli.valor      ";"
            rfvcli.nota 
            skip.
    end.

output close.            

hide message no-pause.

message "/gera-embrace/crm_acao.txt".

output to /gera-embrace/crm_acao.txt.
    
    for each acao no-lock:
      
        put acao.acaocod   ";"
            acao.descricao ";"
            acao.dtini     ";"
            acao.dtfin     ";"
            acao.valor
            skip.
    end.

output close.            
         
hide message no-pause.

message "/gera-embrace/crm_acaocli.txt".

output to /gera-embrace/crm_acaocli.txt.
    
    for each acao-cli no-lock:
      
        put acao-cli.acaocod ";"
            string(acao-cli.clicod) format "x(20)"  
            skip.
    end.

output close.            
*********************************/
hide message no-pause.

message "Fim da Exportacao".
