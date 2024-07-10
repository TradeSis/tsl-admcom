 
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

/**
def shared temp-table c_contrato no-undo
    field contnum like cslog_controle.contnum
    index c is unique primary contnum asc.
**/

def var ve_situacao as char extent 6 init
    ["ENVIAR","ATUALIZAR","PAGAR","BAIXAR","ARRASTAR","CADASATUALIZAR"].

def var vprocessa as log.

def var vti as int.

def var vi as int.
pause 0 before-hide.
vi = 0.
message "      AJUSTAR" string(time,"HH:MM:SS").

do vti = 1 to 6:
    message string(time, "hh:mm:ss") "Ajustando" ve_situacao[vti].
    for each cslog_controle where cslog_controle.situacao = ve_situacao[vti]
        exclusive-lock.

    assign
        cslog_controle.cybsituacao   = cslog_controle.situacao.
        cslog_controle.cybaberto     = cslog_controle.vlraberto.
        cslog_controle.cybatrasado   = cslog_controle.vlratrasado.
        cslog_controle.cybultdtpag   = cslog_controle.ultdtpag.
        cslog_controle.cybultvlrpag  = cslog_controle.ultvlrpag.
        cslog_controle.cybultvenab   = cslog_controle.ultvenab.
        cslog_controle.cybparab      = cslog_controle.ParAb.
        cslog_controle.cybparPg      = cslog_controle.ParPg.
        
    if cslog_controle.situacao = "BAIXAR"
    then do:
        cslog_controle.situacao = "ACOMPANHADO".
        cslog_controle.vlraberto = ?.
        cslog_controle.vlratrasado = ?.
    end.    
    if cslog_controle.situacao = "BAIXAR" or
       cslog_controle.situacao = "ATUALIZAR" or
       cslog_controle.situacao = "CADASATUALIZAR" or
       cslog_controle.situacao = "ENVIAR" or
       cslog_controle.situacao = "ARRASTAR" or
       cslog_controle.situacao = "PAGAR"
    then do:
        cslog_controle.situacao = "ENVIADO". /**"PAGO".**/
    end.    

    cslog_controle.dtenvio = p-today.

    /***find first cslog_chistorico where
        cslog_chistorico.contnum = cslog_controle.contnum and
        cslog_chistorico.dtenvio = cslog_controle.dtenvio
        exclusive no-error.
    if not avail cslog_chistorico then create cslog_chistorico.
    ASSIGN
    cslog_chistorico.Cliente     = cslog_controle.Cliente
    cslog_chistorico.contnum     = cslog_controle.contnum
    cslog_chistorico.Loja        = cslog_controle.Loja
    cslog_chistorico.DtEnvio     = cslog_controle.DtEnvio
    cslog_chistorico.CybSituacao = cslog_controle.CybSituacao.
    ***/
    
    vi = vi + 1.    
end.
end.

message "      " vi "Ajustado" string(time,"HH:MM:SS").
message "      ELIMINAR" .
vi = 0.
for each cslog_controle
    where cslog_controle.situacao = "ELIMINAR".
    cslog_controle.situacao = "ELIMINADO".

    /*
    find first cslog_chistorico where
        cslog_chistorico.contnum = cslog_controle.contnum and
        cslog_chistorico.dtenvio = cslog_controle.dtenvio
        exclusive no-error.
    if not avail cslog_chistorico then create cslog_chistorico.
    ASSIGN
    cslog_chistorico.Cliente     = cslog_controle.Cliente
    cslog_chistorico.contnum     = cslog_controle.contnum
    cslog_chistorico.Loja        = cslog_controle.Loja
    cslog_chistorico.DtEnvio     = cslog_controle.DtEnvio
    cslog_chistorico.CybSituacao = "ELIMINAR".
    ***/
    
    vi = vi + 1.
    /***
            find cslog_contrato where
                cslog_contrato.contnum = cslog_controle.contnum
                exclusive no-error.    
            if avail cslog_contrato
            then do:            
                cslog_contrato.Situacao  = no.                    
            end.
    ***/
    
end.
message "      " vi "Eliminado".
message "      N_ACOMPANHAR" .
vi = 0.

for each cslog_controle
    where cslog_controle.situacao = "N_ACOMPANHADO".
    cslog_controle.situacao = "ACOMPANHADO".
    vi = vi + 1.
end.

message "      " vi "N_Acompanhado".

def var vaberto as log.


for each cyber_clien.
    
    find clien where clien.clicod = cyber_clien.clicod no-lock
        no-error.

    if not avail clien then next.
    
    vaberto = no.
    
    /**for first cslog_contrato where
        cslog_contrato.clicod = cyber_clien.clicod and
        cslog_contrato.situacao = yes.
        vaberto = yes.
    end.        

    if cyber_clien.situacao <> vaberto
    then do:
        cyber_clien.situacao = vaberto.
        cyber_clien.dturen   = 01/01/1901.
    end.**/        

    cyber_clien.dturen = clien.datexp. /*#2*/
    
    
end.



