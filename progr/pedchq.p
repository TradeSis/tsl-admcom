def input parameter p-recid     as recid.

def var vcomp           as char format "x(3)".
def var vbanco          like chq.banco.
def var vcontrole1      like chq.controle1.
def var vcontrole2      like chq.controle2.
def var vcontrole3      like chq.controle3.
def var vnumero         like chq.numero.
def var vagencia        as char format "x(6)".
def var vconta          as char format "x(12)".
def var vvalor          like chq.valor.
def var vdataven        as date format "99/99/9999" initial today.

def var vtexto          as char format "x(30)".
def var v-dig           as int.

form
    vcomp       column-label "Comp"
    vbanco      column-label "Banco"
    vagencia    column-label "Agencia"
    vcontrole1  column-label "C1" 
    vconta      column-label "Conta" 
    vcontrole2  column-label "C2" 
    vnumero     column-label "Cheque"
    vcontrole3  column-label "C3" 
    vdataven    column-label "Dt.Cheque" 
    vvalor      column-label "Valor" 
    with frame f-dadosch
        column 1 title "Dados do Cheque"
        1 down row 12 overlay color white/red.

repeat :
    update vcomp vbanco vagencia vcontrole1 with frame f-dadosch.
        
    vtexto = string(vcomp) + string(vbanco) + string(vagencia).
    run verif11.p ( input vtexto , output v-dig).

    if v-dig <> int(vcontrole1)
    then do :
        bell. bell.
        message "Controle C1 Digitado Errado" view-as alert-box.
        pause. next.
    end.

    update
        vconta vcontrole2 with frame f-dadosch.

    vtexto = string(vconta).
    run verif11.p ( input vtexto , output v-dig).

    if v-dig <> int(vcontrole2)
    then do :
        bell. bell.
        message "Controle C2 Digitado Errado" view-as alert-box.
        pause.
        next.
    end.
        
    update    
        vnumero
        vcontrole3 with frame f-dadosch.

    vtexto = string(vnumero).
    run verif11.p ( input vtexto , output v-dig).

    if v-dig <> int(vcontrole3)
    then do :
        bell. bell.
        message "Controle C3 Digitado Errado" view-as alert-box.
        pause.
    end.

    leave.
end.
        
        
/******** VERIFICANDO SE JA EXISTE O CHEQUE  *************/
find first chq where chq.banco = vbanco
                 and chq.agencia = int(vagencia)
                 and chq.conta = int(vconta)
                 and chq.numero = vnumero
               no-error.
if not avail chq
then do :
    create chq.
    chq.numero = vnumero.
    chq.banco = vbanco.
    chq.agencia = int(vagencia).
    chq.controle1 = vcontrole1.
    chq.controle2 = vcontrole2.
    chq.controle3 = vcontrole3 .
    chq.conta = int(vconta).
    chq.comp = int(vcomp).
    
    update vdataven vvalor with frame f-dadosch.
    if vvalor <> 0 
    then do :
        chq.valor = vvalor.
    end.
    if vdataven <> ? and 
       vdataven >= today
    then do :
        chq.data = vdataven.
    end.
end.

find first titulo where recid(titulo)  = p-recid no-lock no-error.
if avail titulo
then do :
    /****** VERIFICANDO SE JA TEM RELACAO TITULO COM CHEQUE ********/
    find first chqtit where chqtit.titnat = titulo.titnat
                        and chqtit.modcod = titulo.modcod
                        and chqtit.etbcod = titulo.etbcod
                        and chqtit.clifor = titulo.clifor
                        and chqtit.titnum = titulo.titnum
                        and chqtit.titpar = titulo.titpar
                        and chqtit.banco  = chq.banco
                        and chqtit.agencia = chq.agencia
                        and chqtit.conta = chq.conta
                        and chqtit.numero = chq.numero 
                    no-lock no-error.
    if not avail chqtit
    then do :
        create chqtit.
        chqtit.titnat = titulo.titnat.
        chqtit.modcod = titulo.modcod.
        chqtit.etbcod = titulo.etbcod.
        chqtit.clifor = titulo.clifor.
        chqtit.titpar = titulo.titpar.
        chqtit.titnum = titulo.titnum.
        chqtit.banco  = chq.banco.
        chqtit.agencia = chq.agencia.
        chqtit.conta = chq.conta.
        chqtit.numero = chq.numero.
    end.
end.

        
