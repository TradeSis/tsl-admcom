/********************************************************
 Programa: leb-exp-funcionarios.p
 Autor: Rafael A (Kbase IT)
 Descricao: Extrator de dados dos funcionarios
 Uso: run leb-exp-funcionarios.p (output <nome-arq>).
 Historico: 29/04/2015 - Rafael A (Kbase IT) - Criacao
********************************************************/

def output param varq     as char no-undo.

def temp-table tt-cargoFunc
    field id    as int
    field nome  as char
    field sel   as log
    field ativo as log.

def input param table for tt-cargoFunc.

def input param vdtini as date no-undo.
def input param vdtfin as date no-undo.

def var vdt as date no-undo.

def var vcnpj as char no-undo.
def var vcpf  as char no-undo.
def var vddd  as char no-undo.
def var vtel  as char no-undo.

def temp-table tt-exp-func
    field rede      as char
    field cnpj      as char
    field bandeira  as char
    field num       as char
    field cargo     as char
    field cpf-part  as char
    field nome-part as char
    field email     as char
    field ddd       as char
    field tel       as char
    index idx01 num asc.

def temp-table tt-pre-func like tt-exp-func
    field etbcod like func.etbcod
    field funcod like func.funcod
    index idx02 is primary unique 
        etbcod funcod asc.

for each tbclube where tbclube.nomclube = "ClubeBis" no-lock:

    find first clien where clien.clicod = tbclube.clicod no-lock no-error.

    assign vcnpj = ""
           vcpf  = ""
           vddd  = ""
           vtel  = "".

    if avail clien and
       not can-find(first tt-exp-func 
                    where tt-exp-func.cpf-part = clien.ciccgc) then do:
        
        find first func where func.etbcod = tbclube.etbcod
                          and func.funcod = tbclube.funcod
                              no-lock no-error.
          
        find first estab where estab.etbcod = tbclube.etbcod no-lock no-error.
        
        if avail estab then
            vcnpj = replace(
                        replace(
                            replace(estab.etbcgc,"/",""),
                        "-",""),
                    ".","").
        else
            vcnpj = "".
            
        vcpf = replace(clien.ciccgc,"-","").
        
        if (length(tbclube.char1) > 9) then do:
            assign vddd = substr(tbclube.char1,1,2)
                   vtel = replace(substr(tbclube.char1,3),"-","").
        end.
        else
            assign vddd = ""
                   vtel = replace(tbclube.char1,"-","").
                
        if can-find(first tt-pre-func 
                    where tt-pre-func.etbcod = tbclube.etbcod
                      and tt-pre-func.funcod = tbclube.funcod) then next.
        
        create tt-pre-func.
        
        assign tt-pre-func.etbcod = tbclube.etbcod
               tt-pre-func.funcod = tbclube.funcod.
        
        assign tt-pre-func.rede      = ""
               tt-pre-func.cnpj      = vcnpj
               tt-pre-func.bandeira  = ""
               tt-pre-func.num       = string(tbclube.etbcod)
               tt-pre-func.cargo     = ""
               tt-pre-func.cpf-part  = vcpf
               tt-pre-func.nome-part = clien.clinom
               tt-pre-func.email     = tbclube.email
               tt-pre-func.ddd       = vddd
               tt-pre-func.tel       = vtel.
    end.
end.

/* Gerente */
if can-find(first tt-cargoFunc where tt-cargoFunc.nome= "Gerente"
                                 and tt-cargoFunc.sel = yes) then do:
    for each tt-pre-func where tt-pre-func.funcod = 99 exclusive-lock:
        
        tt-pre-func.cargo = "Gerente".
        
        create tt-exp-func.
        buffer-copy tt-pre-func to tt-exp-func no-error.
        
        delete tt-pre-func.
    end.
end.

/* identifica vendedores */
if can-find(first tt-cargoFunc where tt-cargoFunc.nome <> "Gerente"
                                 and tt-cargoFunc.sel = yes) then do:                                
    for each tt-pre-func where tt-pre-func.funcod <> 99 exclusive-lock:
        do vdt = vdtini to vdtfin:
            if tt-pre-func.cargo <> "" then
                next.
        
            for each plani where plani.etbcod = tt-pre-func.etbcod
                             and plani.movtdc = 5
                             and plani.pladat = vdt
                             and plani.vencod = tt-pre-func.funcod
                                 no-lock
                                 by plani.platot:
                if tt-pre-func.cargo <> "" then
                    leave.
                else do:                
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod 
                                         no-lock
                                         by (movim.movpc * movim.movqtm):
                        find first produ 
                             where produ.procod = movim.procod 
                             no-lock no-error.
                     
                        if not avail produ then do:
                            next.
                        end.
                        else do:
                            if produ.catcod = 31 then do:
                                tt-pre-func.cargo = "Vend. Moveis".
                                leave.
                            end.
                            else if produ.catcod = 41 then do:
                                tt-pre-func.cargo = "Vend. Moda".
                                leave.
                            end.                    
                        end.
                    end.                                              
                end.
            end.
        end.
    end.
end.

/* Moda = 41 */
if can-find(first tt-cargoFunc where tt-cargoFunc.nome= "Vend. Moda"
                                 and tt-cargoFunc.sel = yes) then do:
    for each tt-pre-func where tt-pre-func.cargo = "Vend. Moda"
                               exclusive-lock:
        
        tt-pre-func.cargo = "Vendedor".
        
        create tt-exp-func.
        buffer-copy tt-pre-func to tt-exp-func no-error.

        delete tt-pre-func.
    end.
end.

/* Moveis = 31 */
if can-find(first tt-cargoFunc where tt-cargoFunc.nome= "Vend. Moveis"
                                 and tt-cargoFunc.sel = yes) then do:
    for each tt-pre-func where tt-pre-func.cargo = "Vend. Moveis"
                               exclusive-lock:
        
        tt-pre-func.cargo = "Vendedor".
        
        create tt-exp-func.
        buffer-copy tt-pre-func to tt-exp-func no-error.
                
        delete tt-pre-func.
    end.
end.

varq = "/admcom/export_clubes/leb-ext-funcionario-" + string(time) + ".csv".

output to value (varq).

/* cabecalho */
put "Rede; CNPJ Loja; Bandeira; Número Filial; Cargo; CPF Participante;"
    "Nome do Participante; Email; DDD; Telefone" skip.

for each tt-exp-func no-lock:
    export delimiter ";" tt-exp-func.
end.

output close.
