
{cabec.i}

def input-output parameter par-rec-banBoleto as recid.

def var vopcao as char extent 3.
def var copcao as int.
def var vi as int.
def var vmensagem as char.

def var esqpos2 as int .
def var esqcom2         as char format "x(10)" extent 6
            initial ["Origem",
                     "Parcelas",
                     "",
                     "",
                     "",
                     ""].

form
    esqcom2                        
    with frame f-com2 row screen-lines no-labels no-box column 2 overlay.



form
    banboleto.banco
    banboleto.agencia 
    banboleto.conta format ">>>>>>>"
    banboleto.bancart
    banBoleto.nossonumero
    banboleto.dvnossonumero
    banBoleto.Situacao 
    banBoleto.dtemissao
    banboleto.dtvencimento
    banboleto.vlcobrado
    banboleto.dtenvio
    banboleto.dtbaixa
    banBoleto.dtpagamento 
    banboleto.vlpagamento
    banBoleto.tipoIntegracao
    banboleto.linhadigitavel
    banboleto.codigobarras
    with frame frame-cab overlay row 3 width 80 side-labels
         title " Boleto ".
if par-rec-banBoleto = ? /* Inclusao */
then do on error undo.
    return.
end.


if par-rec-banBoleto <> ?
then do with frame frame-cab on error undo.

    find banBoleto where recid(banBoleto) = par-rec-banBoleto no-lock.
    if banBoleto.dtpagamento <> ?
    then assign
            esqcom2[2] = ""
            esqcom2[4] = ""
            esqcom2[6] = "".

    repeat:
        run fcab.    
        run mostra-origem.
        run mostra-parcelas.

        disp esqcom2 with frame f-com2.
        choose field esqcom2 
            with frame f-com2. 


        esqpos2 = frame-index.

        leave.
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.
hide frame frame-a no-pause.

procedure fcab.

    find banBoleto where recid(banBoleto) = par-rec-banBoleto no-lock.
    disp
    
       banboleto.banco
    banboleto.agencia
    banboleto.conta
    banboleto.bancart
    banBoleto.nossonumero
    banboleto.dvnossonumero
    banBoleto.Situacao 
    banBoleto.dtemissao
    banboleto.dtvencimento
    banboleto.vlcobrado
    banboleto.dtenvio
    banboleto.dtbaixa
    banBoleto.dtpagamento 
    banboleto.vlpagamento
    banBoleto.tipoIntegracao
    banboleto.linhadigitavel
    banboleto.codigobarras
    with frame frame-cab.

    color disp messages
                banBoleto.dtemissao
                with frame frame-cab.

end procedure.
 

procedure operacoes.

def var vmotivo   as char.
def var esqpos    as int init 1.
def var esqmenu   as char format "x(12)" extent 7
    init ["Encerra", "", ""].


form
    esqmenu
    with frame f-menu
         row screen-lines - 9 no-labels side-labels column 55 overlay 1 col.

hide message no-pause.

princ:
repeat:
    disp esqmenu with frame f-menu.
    choose field esqmenu 

        go-on( cursor-left cursor-right)
        with frame f-menu.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                leave.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                leave.
            end.                


    
    esqpos = frame-index.

    if esqmenu[esqpos] = ""
    then next.

    /**
    run versenha.p ("ManutSSC", "", 
                    "Senha para " + caps(esqmenu[esqpos]) + "R OS no SSC",
                    output sresp). 
    if not sresp
    then next.
    **/
    
    do on error undo with frame f-cancela side-label.
        update vmotivo label "Motivo" format "x(20)"
               validate (vmotivo <> "", "").
    end.

    if esqmenu[esqpos] = "Encerra" or
       esqmenu[esqpos] = "Cancela"
    then do on error undo.
        find current banBoleto exclusive.
        assign
            banBoleto.dtpagamento  = today.
/***
        vfuncod = int(acha("FUNCOD",return-value)).
***/
    end.
end.

end procedure.


procedure manutencao.

def var vmotivo   as char.
def var esqpos    as int init 1.
def var esqmenu   as char format "x(12)" extent 7
    init ["Motorista", "Seguro", "Ciot",""].

form
    esqmenu
    with frame f-menu
         row screen-lines - 9 
            no-labels side-labels column 33 overlay 1 col.

hide message no-pause.

princ:
repeat:
    hide frame frame-seg no-pause.
    hide frame frame-mot no-pause.
    hide frame frame-ciot no-pause.
     
    disp esqmenu with frame f-menu.
    choose field esqmenu 

        go-on( cursor-left cursor-right)
        with frame f-menu.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                leave.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                leave.
            end.                


    esqpos = frame-index.

    if esqmenu[esqpos] = ""
    then next.

    if esqmenu[esqpos] = "Motorista" 
    then run motorista.

    if esqmenu[esqpos] = "Seguro" 
    then  run seguro.

    if esqmenu[esqpos] = "Ciot" 
    then run ciot.

    
    find current banBoleto no-lock.
end.

end procedure.

procedure altera.

    do on error undo with frame frame-cab.
        find current banBoleto exclusive.
        find current banBoleto no-lock.
    end.

end procedure.


procedure p-verifica-senha:

    def input  parameter p-senha  as character.
    def input  parameter p-placa as integer.
    def output parameter p-resp   as logical.
    
    /**
    assign p-resp = no.
    
    find first tabaux where tabaux.Tabela = string(setbcod) + string(p-placa)
                            no-lock no-error.
    if not avail tabaux
    then do:
        message "Senha inválida."
                "Entre em contato com a Auditoria e solicite uma senha"
                view-as alert-box.
        return.
    end.
    
    if tabaux.Valor_Campo <> p-senha
    then do:
        message "Senha incorreta, digite novamente.".
        return.
    end.
    
    if tabaux.dtemissao < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha a Auditoria"
                view-as alert-box.
        return.
    end.
    **/
    
    assign p-resp = yes.

end procedure.


procedure mostra-origem.

def var vtela as int.
def var vi as int.
def var vtabela as char.
def var vdados  as char.   

    form
        vtabela column-label "Origem" format "x(12)"
        vdados  column-label  "Chave"  format "x(50)"
        banbolorigem.valorOrigem column-label "Valor"
        with frame frame-a 6 down centered row 11
        title "  Origem " no-underline width 80.

clear frame frame-a no-pause.

for each banbolorigem where banbolorigem.bancod = banboleto.bancod and banbolorigem.nossonumero = banboleto.nossonumero
    no-lock.

    vtela = vtela + 1.
    if vtela > 6 then leave. /* tamanho down da tela **/
    
    if banbolOrigem.tabelaOrigem = "cybAcParcela"
    then do:
        find cybacparcela where
            cybacparcela.idacordo = int(entry(1,banbolorigem.dadosorigem)) and
            cybacparcela.parcela  = int(entry(2,banbolorigem.dadosorigem)) 
         no-lock no-error.    
        vtabela = "Acordo Cyber".
        vdados  = "ID="      + entry(1,banbolorigem.dadosorigem)
                + " " +
                  "Parcela=" + entry(2,banbolorigem.dadosorigem).
        if avail cybacparcela
        then do:
            vdados = vdados +  
                    " Venc=" + string(cybacparcela.dtvencimento,"99/99/99").
            find cybacordo of cybacparcela
                no-lock no-error.
            if avail cybacordo
            then do:
                vdados = vdados +
                    " " + caps(cybacparcela.situacao) +
                    " " + 
                        if cybacparcela.dtbaixa <> ?
                        then string(cybacparcela.dtbaixa,"999999")
                        else "".
            end.      
        end.
    end.
    
    else if banbolOrigem.tabelaOrigem = "titulo" or
           banbolOrigem.tabelaOrigem = ?
    then do:
        vtabela = "".
        vdados  = "Contrato "      + entry(1,banbolorigem.dadosorigem)
                + "/" +
                  "" + entry(2,banbolorigem.dadosorigem).

        find contrato where
            contrato.contnum = int(entry(1,banbolorigem.dadosorigem)) 
         no-lock no-error.    
        if avail contrato
        then do: 
            find first  titulo where   
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = contrato.modcod and 
                titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and 
                titulo.titpar =  int(entry(2,banbolorigem.dadosorigem)) 
                no-lock no-error.
                                
            if avail titulo
            then do:
                vdados = vdados +  
                    " Venc=" + string(titulo.titdtven,"99/99/99").
                if titulo.titsit = "PAG" and
                   titulo.titdtpag <> ?
                then do:
                    vdados = vdados +  
                        " Pago " + string(titulo.titdtpag,"99/99/99").
                    
                end.    
            end.      
        end.
    end.
    else assign
        vtabela = banbolOrigem.tabelaOrigem
        vdados  = banbolorigem.dadosorigem.

    display 
        vtabela
        vdados
        banbolorigem.valororigem
        with frame frame-a.
     down with frame     frame-a.
end.

end procedure.

procedure mostra-parcelas.
end procedure.


