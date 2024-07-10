/* Exportacao Clube S */
{admcab.i}

def buffer bestab for estab.
def buffer aestab for estab.
def var vbairro as char.
def var vcep as char.
def var vcpffunc as char.
def var varq as char.


def temp-table tt-estab
       field etbcod as int.



def temp-table tt-loja
    field etbcod    like estab.etbcod
    field tipo      as char
    field cgc       like estab.etbcgc
    field nome      like estab.etbnom
    field rua       like estab.endereco
    field bairro    as char
    field cidade    like estab.munic
    field uf        like estab.ufecod
    field cep       as char
    field telefone  like estab.etbserie format "x(15)".
    
def temp-table tt-produ
    field procod    like produ.procod 
    field pronom    like produ.pronom.

def temp-table tt-vendas
    field tipo      as char format "x(1)"
    field cgc       as char format "x(14)"
    field cpffunc   as char format "x(14)"
    field procod    like produ.procod
    field movqtm    like movim.movqtm
    field sinal     as char
    field dtvenda   as char
    field numero    like plani.numero format "99999999".

def temp-table tt-func
    field tipo      as char
    field funcod    as int
    field cpf       as char format "x(14)"
    field cgc       as char
    field cargo     as char.
     
     
     
def var vetbcod like estab.etbcod.
def var vdtini as date.
def var vdtfin as date.
def var vforcod like fabri.fabcod.
def var vcatcod like categoria.catcod.

form vetbcod label "Filial" colon 25  
with frame f1 side-label width 80.    


for each tt-estab.
    delete tt-estab.
end.



{selestab.i vetbcod f1}.

    
do on error undo, retry:
    update vdtini to 34  label "Data Inicial"
           vdtfin label "Data Final" with frame f1.
    if  vdtini > vdtfin
    then do:
        message color red/with 
        "Data inválida" view-as alert-box.
        undo.
    end.
    if vdtini = ? or vdtfin = ?
    then do:
        message color red/with 
        "Informe a data" view-as alert-box.
        undo.
    end.

    
end.


    if vetbcod > 0
    then do:
        for each bestab where bestab.etbcod = vetbcod no-lock:
            create tt-estab.
            buffer-copy bestab to tt-estab.
        end.    
    end.
    else do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        if not avail tt-lj
        then  for each bestab no-lock:
                create tt-estab.
                buffer-copy bestab to tt-estab.
        end. 
        else for each tt-lj where tt-lj.etbcod > 0 no-lock:
                create tt-estab.
                buffer-copy tt-lj to tt-estab.
        end.
    end.

    

for each tt-estab  no-lock.
        
    disp "Estabelecimento :" tt-estab.etbcod no-label
    with frame f2 row 11 centered.
    pause 0.
 
    for each tipmov where tipmov.movtdc = 5   or
                      tipmov.movtdc = 12  no-lock.    
            
        for each plani where plani.etbcod = tt-estab.etbcod  and
                             plani.movtdc = tipmov.movtdc and
                             plani.pladat >= vdtini       and 
                             plani.pladat <= vdtfin      
                             no-lock.


            for each movim WHERE movim.etbcod = tt-estab.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:

                find aestab where aestab.etbcod = tt-estab.etbcod no-lock.

                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ then next.
                
                if produ.fabcod <> 2 and  produ.fabcod <> 103729 then next.
                
                find first tt-loja where tt-loja.etbcod = tt-estab.etbcod      ~                 no-error.

                if not avail tt-loja
                then do:

                    find bestab where bestab.etbcod = tt-estab.etbcod no-lock.
                    find tabaux where 
                    tabaux.tabela = "ESTAB-" + string(bestab.etbcod,"999") and
                    tabaux.nome_campo = "CEP" no-lock no-error.
                    
                    if avail tabaux
                    then vcep = tabaux.valor_campo.
                    else vcep = "0".
                    
                    find tabaux where 
                    tabaux.tabela = "ESTAB-" + string(bestab.etbcod,"999") and
                    tabaux.nome_campo = "BAIRRO" no-lock no-error.
                    
                    if avail tabaux
                    then vbairro = tabaux.valor_campo.
                    else vbairro = "".


                    create tt-loja.
                    assign tt-loja.etbcod = bestab.etbcod
                           tt-loja.tipo     = "2"
                           tt-loja.cgc      =                                  ~       replace(replace(replace
                                        (bestab.etbcgc,".",""),"/",""),"-","")
                           tt-loja.nome     = 
                                        replace(replace(replace
                                        (bestab.etbnom,".",""),"/",""),"-","")
                           tt-loja.rua      = 
                                        replace(replace(replace
                                        (bestab.endereco,".",""),"/",""),",","")
                           tt-loja.bairro   = vbairro
                           tt-loja.cidade   = 
                                        replace(replace(replace
                                        (bestab.munic,".",""),"/",""),"-","")

                           tt-loja.uf       = bestab.ufecod
                           tt-loja.cep      = vcep
                           tt-loja.telefone = "0" + bestab.etbserie.

                end.

                find first tt-produ where tt-produ.procod = produ.procod
                no-error.
                if not avail tt-produ
                then do:
                    create tt-produ.
                    assign tt-produ.procod = produ.procod
                           tt-produ.pronom = produ.pronom.
                
                end.
                
                find first tt-vendas where tt-vendas.numero = plani.numero and
                tt-vendas.procod = movim.procod no-error.
                
                if not avail tt-vendas 
                then do:

                    find first func where func.funCod = plani.vencod 
                    and func.etbcod = tt-estab.etbcod 
                    no-lock no-error.
                    
                    if not avail func then next.  
                    
                    if avail func 
                    then vcpffunc = func.cpf.
                    
                    
                    
                    create tt-vendas.
                    assign tt-vendas.tipo       = "2"
                           tt-vendas.cgc        = 
                                        replace(replace(replace
                                        (aestab.etbcgc,".",""),"/",""),"-","")
                           tt-vendas.cpffunc    = vcpffunc
                           tt-vendas.procod     = movim.procod
                           tt-vendas.movqtm     = movim.movqtm
                           tt-vendas.sinal      = if plani.movtdc = 5 then "-"
                                                  else "+"
                           tt-vendas.dtvenda    = string(plani.pladat,"999999")
                           tt-vendas.numero     = plani.numero.
                end.                           

                find first tt-func where tt-func.cpf = vcpffunc no-error.
                if not avail tt-func
                then do:
                    create tt-func.
                    assign tt-func.tipo     = "2"
                           tt-func.funcod   = func.funcod
                           tt-func.cpf      = vcpffunc
                           tt-func.cgc      = replace(replace(replace
                                        (aestab.etbcgc,".",""),"/",""),"-","")
                           tt-func.cargo    = if func.funmec then "1" else "2". 
                
                
                end.

            end.

        end.
     end.

end.


run exporta-arquivos.


procedure exporta-arquivos.

if opsys = "unix"
then 
varq = "/admcom/import/clube-s/GerLyLoc.txt". 

else
varq = "l:/import/clube-s/GerLyLoc.txt". 

    output to value(varq).
    for each tt-loja no-lock.
        put unformatted
            tt-loja.tipo      format "x(1)"
            tt-loja.cgc       format "x(14)"
            tt-loja.nome      format "x(30)"
            tt-loja.rua       format "x(30)"
            tt-loja.bairro    format "x(20)"
            tt-loja.cidade    format "x(20)"
            tt-loja.uf        format "x(2)"
            tt-loja.cep       format "x(8)"
            tt-loja.telefone  format "x(11)"

        
        skip.   
    end.
    
     output close.

    
    if opsys = "unix"
    then 
    varq = "/admcom/import/clube-s/GerLyProd.txt". 
    
    else
    varq = "l:/import/clube-s/GerLyProd.txt". 
    
    
 output to value(varq).
    for each tt-produ no-lock.
        put unformatted
            string(tt-produ.procod)     format "x(6)"
            tt-produ.pronom             format "x(40)"


        
        
        skip.   
    end.
    
    
     output close.
    
    
    
      
        if opsys = "unix"
              then
              varq = "/admcom/import/clube-s/GerLyVen.txt". 
              else
              varq = "l:/import/clube-s/GerLyVen.txt". 
          
     output to value(varq).
    for each tt-vendas no-lock.


        put unformatted
            tt-vendas.tipo      format "x(1)"
            tt-vendas.cgc       format "x(14)"
            dec(tt-vendas.cpffunc)   format "99999999999999"
            string(tt-vendas.procod)    format "x(6)"
            tt-vendas.movqtm    format "99999"
            tt-vendas.sinal     format "x(1)"
            tt-vendas.dtvenda   format "x(6)"
            tt-vendas.numero    format "99999999"

        skip.   
    end.
    
    
    
         output close.
    
    
    
            if opsys = "unix"
                  then 
                  varq = "/admcom/import/clube-s/GerLyFunc.txt". 
                  
                  else
                  varq = "l:/import/clube-s/GerLyFunc.txt". 
          
     output to value(varq).
    for each tt-func no-lock.
        put unformatted
            tt-func.tipo      format "x(1)"
            dec(tt-func.cpf)       format "99999999999999"
            tt-func.cgc       format "x(14)"
            tt-func.cargo     format "x(1)"

     
        
                                      
        skip.   
    end.
    
    output close.


if opsys = "unix"
then do.                      /*
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq). */
end.
message "Arquivo gerado: " + varq view-as alert-box.


end procedure.
                                                                  
