/*#1*/ /* 15.03.2017 - Helio - Somente atualizar a tabela CADAS */
/** #3 **/ /** 27.02.2018 Versionamento **/
/*  #4  */ /* Atualiza Percentuais de Pagamento */

def input param p-today as date.

def var vok as log.
def var ve_situacao as char extent 6 init
    ["ENVIAR","ATUALIZAR","PAGAR","BAIXAR","ARRASTAR","CADASATUALIZAR"].

def var ve_tipo     as char extent 7 init
    ["CADAS","CONTR","FINAN","PARCE","MERCA","PAGTO","BAIXA"].

def var ve_programa as char extent 7 init
    ["cyb/man_cadastro_v3.p", /* #4 */
     "cyb/carga_contrato_v3.p",
     "cyb/man_finan.p",
     "cyb/parcela.p",
     "cyb/mercadorias.p",
     "cyb/pagamentos_v41.p",
     "cyb/baixas.p"].
    
def var vti as int.
def var vi as int.

def new shared var v-today as date.
def new shared var v-time  as int.
def new shared var v-etbcod as int.

v-today = p-today.
v-time  = time.

def new shared temp-table c_contrato no-undo
    field contnum like cyber_controle.contnum
    index c is unique primary contnum asc.
def new shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.
def new shared temp-table t_interface no-undo
    field tipo as char
    field qtd  as int
    index t is unique primary tipo asc.
        
for each c_contrato.
    delete c_contrato.
end.
for each t_contrato.
    delete t_contrato.
end.
for each t_interface.
    delete t_interface.
end.
    
do vti = 1 to 6:
    message string(time, "hh:mm:ss") "Pesquisando" ve_situacao[vti].
    for each cyber_controle where cyber_controle.situacao = ve_situacao[vti]
        no-lock.

        find contrato of cyber_controle no-lock no-error.

        find clien where clien.clicod = cyber_controle.cliente no-lock no-error.
        if not avail clien then next.         

        create c_contrato.
        c_contrato.contnum = cyber_controle.contnum.

        do vi = 1 to 7.
            vok = no. 
            if ve_situacao[vti] = "ENVIAR" or
               ve_situacao[vti] = "ARRASTAR"
            then do:
                if ve_tipo[vi] = "CADAS" or
                   ve_tipo[vi] = "CONTR" or
                   ve_tipo[vi] = "PARCE" or
                   ve_tipo[vi] = "MERCA"
                then vok = yes.
            end.
            if ve_situacao[vti] = "ATUALIZAR" 
            then do:
                if ve_tipo[vi] = "CADAS" or
                   ve_tipo[vi] = "CONTR" or
                   ve_tipo[vi] = "PARCE" 
                then vok = yes.
            end.
            if ve_situacao[vti] = "PAGAR" 
            then do:
                if ve_tipo[vi] = "PAGTO" or
                   ve_tipo[vi] = "FINAN" or
                   /**ve_tipo[vi] = "CONTR" or**/
                   ve_tipo[vi] = "PARCE" 
                then vok = yes.
            end.
            if ve_situacao[vti] = "BAIXAR" 
            then do:
                if ve_tipo[vi] = "PAGTO" or
                   ve_tipo[vi] = "FINAN" or
                   ve_tipo[vi] = "BAIXA" or
                   /**ve_tipo[vi] = "CONTR" or**/
                   ve_tipo[vi] = "PARCE"
                then vok = yes.
            end.
            if ve_situacao[vti] = "CADASATUALIZAR" /*#1*/
            then do:
                if ve_tipo[vi] = "CADAS" 
                then vok = yes.
            end.
            
            if vok = no then next.
            create t_contrato.
            t_contrato.contnum = cyber_controle.contnum.
            t_contrato.tipo = ve_tipo[vi].
        end.
    end.        
end.    

message string(time, "hh:mm:ss") "Criando interface".
for each c_contrato.
    for each t_contrato of c_contrato.
        find first t_interface where
            t_interface.tipo = t_contrato.tipo
            no-error.
        if not avail t_interface then do: 
            create t_interface.
            t_interface.tipo = t_contrato.tipo.
        end.
        t_interface.qtd = t_interface.qtd + 1.
    end.
end.            

do vi = 7 to 1 by -1 .
    message string(time, "hh:mm:ss") "Gerando Arquivo" ve_tipo[vi].
    for each t_interface where t_interface.tipo = ve_tipo[vi].
        disp t_interface.
        if ve_programa[vi] = "" 
        then next.
        
        run value(ve_programa[vi]) .
        for each t_contrato where t_contrato.tipo = ve_tipo[vi].
            delete t_contrato.
        end.            
    end.
end.

message string(time, "hh:mm:ss") "AJUSTE".
run cyb/ajuste.p (input p-today).

message "|".
message string(time, "hh:mm:ss") "VAI GERAR PGTO BOLETO (v1702)" today.
run cyb/enviapgtoboleto_v1702.p.
message string(time, "hh:mm:ss") "VAI GERAR NEXT        (v1702)" today.
run cyb/envianextboleto_v1702.p.

message string(time, "hh:mm:ss") "FIM LOTE" today.

