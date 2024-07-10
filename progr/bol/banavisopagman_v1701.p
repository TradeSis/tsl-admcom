
{cabec.i}

def input-output parameter par-rec-banavisopag as recid.

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
    banavisopag.banco
    banavisopag.agencia
    banavisopag.conta
    banavisopag.bancart
    banavisopag.cdoperacao
    banavisopag.Situacao 
    banavisopag.dtemissao
    banavisopag.dtvencimento
    banavisopag.vlcobrado
    banavisopag.dtenvio
    banavisopag.dtbaixa
    banavisopag.dtpagamento 
    banavisopag.vlpagamento
    with frame frame-cab overlay row 3 width 80 side-labels
         title " avisopag ".
if par-rec-banavisopag = ? /* Inclusao */
then do on error undo.
    return.
    /**
    find estab where estab.etbcod = setbcod no-lock.

    if estab.etbnom begins "DREBES-FIL"
    then do.
        message "Realizar a inclusao no acesso remoto" view-as alert-box.
        leave.
    end.

    if estab.etbnom begins "DREBES-FIL"
    then run inclui-os-loja.
    else run inclui-os-matriz.
    **/
    
end.


if par-rec-banavisopag <> ?
then do with frame frame-cab on error undo.

    find banavisopag where recid(banavisopag) = par-rec-banavisopag no-lock.
    if banavisopag.dtpagamento <> ?
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


 
        if esqcom2[esqpos2] = "Romaneio"
        then run mdfe/rromaneio.p (par-rec-banavisopag).  
 
        if esqcom2[esqpos2] = "Nfe"
        then run mdfe/manbanaviorigem.p (par-rec-banavisopag).  
        
        if esqcom2[esqpos2] = "Rota " 
        then do. 
            run mdfe/manviagrota.p (input recid(banavisopag)). 
            run mostra-origem.
        end.
        
        else if esqcom2[esqpos2] = "Altera"
        then run altera.
        else if esqcom2[esqpos2] = "Dados Adic"
        then run not_etiqestdad.p (recid(banavisopag)).
        else if esqcom2[esqpos2] = "Imprime OS"
        then run not_etiqestrel.p (par-rec-banavisopag).
        
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.

procedure fcab.

    find banavisopag where recid(banavisopag) = par-rec-banavisopag no-lock.
    disp
    
       banavisopag.banco
    banavisopag.agencia
    banavisopag.conta
    banavisopag.bancart
    banavisopag.cdoperacao
    banavisopag.Situacao 
    banavisopag.dtemissao
    banavisopag.dtvencimento
    banavisopag.vlcobrado
    banavisopag.dtenvio
    banavisopag.dtbaixa
    banavisopag.dtpagamento 
    banavisopag.vlpagamento
 
    with frame frame-cab.

    color disp messages
                banavisopag.dtemissao
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
        find current banavisopag exclusive.
        assign
            banavisopag.dtpagamento  = today.
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

    
    find current banavisopag no-lock.
end.

end procedure.

procedure altera.

    do on error undo with frame frame-cab.
        find current banavisopag exclusive.
        find current banavisopag no-lock.
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
        banaviorigem.valorOrigem column-label "Valor"
        with frame frame-a 6 down centered row 11
        title "  Origem " no-underline width 80.

clear frame frame-a no-pause.

for each banaviorigem of banavisopag no-lock.

    vtela = vtela + 1.
    if vtela > 6 then leave. /* tamanho down da tela **/
    
    if banaviorigem.tabelaOrigem = "cybAcParcela"
    then do:
        find cybacparcela where
            cybacparcela.idacordo = int(entry(1,banaviorigem.dadosorigem)) and
            cybacparcela.parcela  = int(entry(2,banaviorigem.dadosorigem)) 
         no-lock no-error.    
        vtabela = "Acordo Cyber".
        vdados  = "ID="      + entry(1,banaviorigem.dadosorigem)
                + " " +
                  "Parcela=" + entry(2,banaviorigem.dadosorigem).
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
    
    if banaviorigem.tabelaOrigem = "titulo"
    then do:
        vtabela = "Contratos".
        vdados  = "Contrato "      + entry(1,banaviorigem.dadosorigem)
                + "/" +
                  "" + entry(2,banaviorigem.dadosorigem).

        find contrato where
            contrato.contnum = int(entry(1,banaviorigem.dadosorigem)) 
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
                titulo.titpar =  int(entry(2,banaviorigem.dadosorigem)) 
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


   display 
 
        vtabela
        vdados
        banaviorigem.valororigem

        
        with frame frame-a.
     down with frame     frame-a.
end.

end procedure.

procedure mostra-parcelas.
end procedure.


