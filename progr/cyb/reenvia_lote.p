def var p-today as date.
def var vpropath as char.


def new shared temp-table t_cliente no-undo
    field clicod like cyber_controle.cliente
    field vperc-15 as dec
    field vperc-45 as dec
    field vperc-46 as dec
    index c is unique primary clicod asc.

p-today = date(SESSION:PARAMETER) no-error.
if p-today = ?
then p-today = if time <= 25000 /** 07:00 **/
               then today - 1
               else today.
message today "p-today" p-today.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.
propath = vpropath + ",\dlc".


def new global shared var vmudasequenciais as char .
pause 0 before-hide.

p-today = date(SESSION:PARAMETER) no-error.
if p-today = ?
then do:
    message "sem parametro data".
    return.
end.

message today "p-today" p-today.

message "REENVIO Integracao " today p-today
        "INICIO:" string(time,"HH:MM:SS").



vmudasequenciais = "NAO".


def var vok as log.
def var ve_situacao as char extent 5 init
    ["ENVIAR","ATUALIZAR","PAGAR","BAIXAR","ARRASTAR"].

def var ve_tipo     as char extent 7 init
    ["CADAS","CONTR","FINAN","PARCE","MERCA","PAGTO","BAIXA"].

def var ve_programa as char extent 7 init
    ["cyb/man_cadastro.p",
     "cyb/carga_contrato.p",
     "cyb/man_finan.p",
     "cyb/parcela.p",
     "cyb/mercadorias.p",
     "cyb/pagamentos.p",
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
    

do vti = 1 to 5:
    message "Pesquisando "
        ve_situacao[vti].
    for each cyber_controle
        where   situacao    = "ENVIADO" and
                dtenvio     = p-today and
                cybsituacao = ve_situacao[vti]
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
                   ve_tipo[vi] = "MERCA" or
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
            if vok = no then next.
            create t_contrato.
            t_contrato.contnum = cyber_controle.contnum.
            t_contrato.tipo = ve_tipo[vi].
        end.
    end.        
    for each cyber_controle
        where   situacao    = "ACOMPANHADO" and
                dtenvio     = p-today and
                cybsituacao = ve_situacao[vti]
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
                   ve_tipo[vi] = "MERCA" or
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
            if vok = no then next.
            create t_contrato.
            t_contrato.contnum = cyber_controle.contnum.
            t_contrato.tipo = ve_tipo[vi].
        end.
    end.        
    
end.    

message "Criando interface".

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

message "VAI GERAR ARQUIVOS".


do vi = 7 to 1 by -1 .
    message "Gerando Arquivo " ve_tipo[vi].
    for each t_interface where
        t_interface.tipo = ve_tipo[vi].
        disp t_interface.
        if ve_programa[vi] = "" 
        then next.
        
        run value(ve_programa[vi]) .
        for each t_contrato where t_contrato.tipo = ve_tipo[vi].
            delete t_contrato.
        end.
            
    end.
end.

vmudasequenciais = "".

message "FIM REENVIO" time.

