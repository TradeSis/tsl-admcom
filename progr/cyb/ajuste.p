 
/*#2 13.03.17 Helio */ /* Atualizar cliente quando alterar o cadastro */

def input param p-today as date.
/**
def input param par-etbcod as int. 
def input param vprocessa_normal as log.
def input param vprocessa_novacao as log.
def input param vprocessa_lp as log.
def input param vdias as int.
def input param vdias_novacao as int.
def input param vdias_lp as int.
**/


def shared temp-table c_contrato no-undo
    field contnum like cyber_controle.contnum
    index c is unique primary contnum asc.

def var vprocessa as log.

def var vi as int.
pause 0 before-hide.
vi = 0.
message "      AJUSTAR" string(time,"HH:MM:SS").

for each c_contrato.
    find cyber_controle where 
        cyber_controle.contnum = c_contrato.contnum
        no-error.
    if not avail cyber_controle
    then next.

    assign
        cyber_controle.cybsituacao   = cyber_controle.situacao.
        cyber_controle.cybaberto     = cyber_controle.vlraberto.
        cyber_controle.cybatrasado   = cyber_controle.vlratrasado.
        cyber_controle.cybultdtpag   = cyber_controle.ultdtpag.
        cyber_controle.cybultvlrpag  = cyber_controle.ultvlrpag.
        cyber_controle.cybultvenab   = cyber_controle.ultvenab.
        cyber_controle.cybparab      = cyber_controle.ParAb.
        cyber_controle.cybparPg      = cyber_controle.ParPg.
        
    if cyber_controle.situacao = "BAIXAR"
    then do:
        cyber_controle.situacao = "ACOMPANHADO".
        cyber_controle.vlraberto = ?.
        cyber_controle.vlratrasado = ?.

            find cyber_contrato where
                cyber_contrato.contnum = cyber_controle.contnum
                exclusive no-error.    
            if avail cyber_contrato
            then do:            
                cyber_contrato.Situacao  = no.                    
            end.

        
    end.    
    if cyber_controle.situacao = "BAIXAR" or
       cyber_controle.situacao = "ATUALIZAR" or
       cyber_controle.situacao = "CADASATUALIZAR" or
       cyber_controle.situacao = "ENVIAR" or
       cyber_controle.situacao = "ARRASTAR" or
       cyber_controle.situacao = "PAGAR"
    then do:
        cyber_controle.situacao = "ENVIADO". /**"PAGO".**/
    end.    

    cyber_controle.dtenvio = p-today.

    find first cyber_chistorico where
        cyber_chistorico.contnum = cyber_controle.contnum and
        cyber_chistorico.dtenvio = cyber_controle.dtenvio
        exclusive no-error.
    if not avail cyber_chistorico then create cyber_chistorico.
    ASSIGN
    cyber_chistorico.Cliente     = cyber_controle.Cliente
    cyber_chistorico.contnum     = cyber_controle.contnum
    cyber_chistorico.Loja        = cyber_controle.Loja
    cyber_chistorico.DtEnvio     = cyber_controle.DtEnvio
    cyber_chistorico.CybSituacao = cyber_controle.CybSituacao.
    
    delete c_contrato.
    vi = vi + 1.    
end.
message "      " vi "Ajustado" string(time,"HH:MM:SS").
message "      ELIMINAR" .
vi = 0.
for each cyber_controle
    where cyber_controle.situacao = "ELIMINAR".
    cyber_controle.situacao = "ELIMINADO".
    cyber_controle.dtenvio  = p-today.

    find first cyber_chistorico where
        cyber_chistorico.contnum = cyber_controle.contnum and
        cyber_chistorico.dtenvio = cyber_controle.dtenvio
        exclusive no-error.
    if not avail cyber_chistorico then create cyber_chistorico.
    ASSIGN
    cyber_chistorico.Cliente     = cyber_controle.Cliente
    cyber_chistorico.contnum     = cyber_controle.contnum
    cyber_chistorico.Loja        = cyber_controle.Loja
    cyber_chistorico.DtEnvio     = cyber_controle.DtEnvio
    cyber_chistorico.CybSituacao = "ELIMINAR".
 
    vi = vi + 1.
    
            find cyber_contrato where
                cyber_contrato.contnum = cyber_controle.contnum
                exclusive no-error.    
            if avail cyber_contrato
            then do:            
                cyber_contrato.Situacao  = no.                    
            end.

    
end.
message "      " vi "Eliminado".
message "      N_ACOMPANHAR" .
vi = 0.

for each cyber_controle
    where cyber_controle.situacao = "N_ACOMPANHADO".
    cyber_controle.situacao = "ACOMPANHADO".
    vi = vi + 1.
end.

message "      " vi "N_Acompanhado".

def var vaberto as log.

for each cyber_clien.
    
    find clien where clien.clicod = cyber_clien.clicod no-lock
        no-error.

    if not avail clien then next.
    
    vaberto = no.
    
    for first cyber_contrato where
        cyber_contrato.clicod = cyber_clien.clicod and
        cyber_contrato.situacao = yes.
        vaberto = yes.
    end.        

    if cyber_clien.situacao <> vaberto
    then do:
        cyber_clien.situacao = vaberto.
        cyber_clien.dturen   = 01/01/1901.
    end.        

    cyber_clien.dturen = clien.datexp. /*#2*/
    
    
end.




