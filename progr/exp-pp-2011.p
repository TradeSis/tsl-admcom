{admcab.i new}

define stream str-regiao.
define stream ajus-estoq.
define stream estoq-neg.

define stream arquivo-loja.
define stream estrut-merc.
define stream est-ab-zero.

def var vsp as char.

def var v-ult-saida as date.


def buffer setor    for clase.
def buffer grupo    for clase.
def buffer subclase for clase.

def buffer bmovim for movim.

assign vsp = ";".

def buffer bestoq for estoq.

def temp-table tt-produ like movim
     field pronom     as char
     field depcod     as integer
     field depdes     as char
     field setcod     as integer
     field setdes     as char
     field grucod     as integer
     field grudes     as char
     field clacod     as integer
     field clades     as char
     field subcod     as integer
     field subdes     as char
     field loja       as char
     field tipo1      as char
     field tipo2      as char
        index idx_aux_01 etbcod depcod setcod grucod clacod subcod pronom.
/*
output stream str-regiao to value("/admcom/custom/laureano/pp/regiao.csv").

    put stream str-regiao unformatted
    "Cod.Regiao"
    vsp
    "Regiao"
    vsp
    "CodLoja"
    vsp
    "Loja"
    vsp  skip.
    
    for each regiao no-lock.
     
        for each estab where estab.regcod = regiao.regcod.

            put stream str-regiao unformatted
                regiao.regcod
                vsp
                regiao.regnom
                vsp
                estab.etbcod
                vsp
                estab.etbnom
                vsp skip.
        
        
        end.

    end.

output stream str-regiao close.
*/
message "Iniciando... ".
pause .

for each tipmov where (tipmov.movtdc = 7 or tipmov.movtdc = 8) no-lock:
    
    for each estab no-lock,
              
        last coletor where coletor.etbcod = estab.etbcod no-lock,
                
        each movim where movim.etbcod = estab.etbcod
                     and movim.movtdc = tipmov.movtdc
                     and movim.movdat = coletor.coldat no-lock,
                     
        first produ where produ.procod = movim.procod no-lock,
        
        first bestoq where bestoq.etbcod = estab.etbcod
                      and bestoq.procod = produ.procod no-lock:  

        find first subclase where subclase.clacod = produ.clacod
                                             no-lock no-error.
        
        find first clase where clase.clacod = subclase.clasup
                                             no-lock no-error.

        find first grupo where grupo.clacod = clase.clasup
                                             no-lock no-error.
                                             
        find first setor where setor.clacod = grupo.clasup
                                             no-lock no-error.
        
        find first categoria where categoria.catcod = produ.catcod
                                             no-lock no-error.

        create tt-produ.
        buffer-copy movim to tt-produ.
        
        assign tt-produ.movpc = bestoq.estvenda.
        
        assign tt-produ.pronom = produ.pronom
               tt-produ.depcod = produ.catcod
               tt-produ.loja   = estab.etbnom.
               
        if avail categoria
        then assign       
               tt-produ.depdes = categoria.catnom.
               
        if avail setor
        then assign       
               tt-produ.setcod = setor.clacod
               tt-produ.setdes = setor.clanom.
               
        if avail grupo
        then assign       
               tt-produ.grucod = grupo.clacod
               tt-produ.grudes = grupo.clanom.
               
        if avail clase
        then assign       
               tt-produ.clacod = clase.clacod
               tt-produ.clades = clase.clanom.
               
        if avail subclase
        then assign       
               tt-produ.subcod = subclase.clacod
               tt-produ.subdes = subclase.clanom.
               
        assign tt-produ.tipo1  = ""
               tt-produ.tipo2  = tipmov.movtnom.
        
        
    end.
    
end.

message "Parte 2".
pause .

output stream ajus-estoq to value("/admcom/custom/laureano/pp/aj-estoque.csv").

put stream ajus-estoq unformatted
    "CodLoja;Loja;CodDepto;Depto;SetCod;Setor;GrupCod;Grupo;Clacod;Classe;"
    "SubCod;SubClasse;"
    "CodProd;Produto;Qtd;ValorUnit;ValorTotal;DataultSaida;Tipo;" skip.

for each tt-produ no-lock by tt-produ.etbcod
                          by tt-produ.depcod
                          by tt-produ.setcod
                          by tt-produ.grucod
                          by tt-produ.clacod
                          by tt-produ.subcod
                          by tt-produ.pronom:
    
    message "Produto parte 1 -" tt-produ.procod.
    pause 0.
    
    
    message "Produto parte 2 -" tt-produ.procod.
    pause 0.

    release bmovim.
    find last bmovim where bmovim.etbcod = tt-produ.etbcod
                       and bmovim.procod = tt-produ.procod
                       and can-find (first tipmov
                                     where tipmov.movtdc = bmovim.movtdc 
                                       and tipmov.MovtNom matches("*saida*"))
                                               no-lock no-error.

    if avail bmovim
    then assign v-ult-saida = bmovim.movdat.

    message "Produto parte 3 -" tt-produ.procod.
    pause 0.
        

    put stream ajus-estoq unformatted
        tt-produ.etbcod
        vsp
        tt-produ.loja
        vsp
        tt-produ.depcod
        vsp
        tt-produ.depdes
        vsp
        tt-produ.setcod
        vsp
        tt-produ.setdes
        vsp
        tt-produ.grucod
        vsp
        tt-produ.grudes
        vsp
        tt-produ.clacod
        vsp
        tt-produ.clades
        vsp
        tt-produ.subcod
        vsp
        tt-produ.subdes
        vsp
        tt-produ.procod
        vsp
        tt-produ.pronom
        vsp
        tt-produ.movqtm
        vsp
        tt-produ.movpc
        vsp
        (tt-produ.movpc * tt-produ.movqtm)
        vsp
        v-ult-saida
        vsp
        tt-produ.tipo2
        skip.

end.

output stream ajus-estoq close.



















































/*
empty temp-table tt-produ.


for each estab no-lock,
              
    each estoq where estoq.etbcod = estab.etbcod 
                 and estoq.estatual < 0    no-lock,
                     
    first produ where produ.procod = estoq.procod no-lock:  

    find first subclase where subclase.clacod = produ.clacod
                                             no-lock no-error.
        
    find first clase where clase.clacod = subclase.clasup
                                             no-lock no-error.

    find first grupo where grupo.clacod = clase.clasup
                                             no-lock no-error.
                                             
    find first setor where setor.clacod = grupo.clasup
                                             no-lock no-error.
        
    find first categoria where categoria.catcod = produ.catcod
                                             no-lock no-error.
                                             
    create tt-produ.
        
        assign tt-produ.etbcod = estab.etbcod
               tt-produ.pronom = produ.pronom
               tt-produ.depcod = produ.catcod
               tt-produ.loja   = estab.etbnom
               tt-produ.movqtm = estoq.estatual
               tt-produ.movpc = estoq.estcusto
               tt-produ.procod = estoq.procod.
               
        if avail categoria
        then assign       
               tt-produ.depdes = categoria.catnom.
               
        if avail setor
        then assign       
               tt-produ.setcod = setor.clacod
               tt-produ.setdes = setor.clanom.
               
        if avail grupo
        then assign       
               tt-produ.grucod = grupo.clacod
               tt-produ.grudes = grupo.clanom.
               
        if avail clase
        then assign       
               tt-produ.clacod = clase.clacod
               tt-produ.clades = clase.clanom.
               
        if avail subclase
        then assign       
               tt-produ.subcod = subclase.clacod
               tt-produ.subdes = subclase.clanom.
        
        
end.
    

message "Parte 2".
pause .

output stream estoq-neg to value("/admcom/custom/laureano/pp/estoque-neg.csv").

put stream estoq-neg unformatted
    "CodLoja;Loja;CodDepto;Depto;SetCod;Setor;GrupCod;Grupo;Clacod;Classe;"
    "SubCod;SubClasse;"
    "CodProd;Produto;Qtd;ValorUnit;ValorTotal;DataultSaida;Tipo;" skip.

for each tt-produ no-lock by tt-produ.etbcod
                          by tt-produ.depcod
                          by tt-produ.setcod
                          by tt-produ.grucod
                          by tt-produ.clacod
                          by tt-produ.subcod
                          by tt-produ.pronom:
    
    
    put stream estoq-neg unformatted
        tt-produ.etbcod
        vsp
        tt-produ.loja
        vsp
        tt-produ.depcod
        vsp
        tt-produ.depdes
        vsp
        tt-produ.setcod
        vsp
        tt-produ.setdes
        vsp
        tt-produ.grucod
        vsp
        tt-produ.grudes
        vsp
        tt-produ.clacod
        vsp
        tt-produ.clades
        vsp
        tt-produ.subcod
        vsp
        tt-produ.subdes
        vsp
        tt-produ.procod
        vsp
        tt-produ.pronom
        vsp
        tt-produ.movqtm
        vsp
        tt-produ.movpc
        vsp
        (tt-produ.movpc * tt-produ.movqtm)
        vsp
        vsp
        skip.

end.

output stream estoq-neg close.



*/



