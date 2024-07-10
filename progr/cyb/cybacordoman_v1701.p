/*
#1 TP 28872041 16.01.19 - Etbcod e modcod na origem
*/
{cabec.i}

def input-output parameter par-rec-cybacordo as recid.

def var vopcao as char extent 3.
def var copcao as int.
def var vi as int.
def var vmensagem as char.

def var vhora as char label "Hora" format "x(5)".

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
    cybacordo.idacordo
    cybacordo.etbcod
    cybacordo.clifor
    cybacordo.Situacao 
    cybacordo.dtacordo 
    vhora
    cybacordo.dtefetiva 
    cybacordo.hrefetiva
    cybacordo.modcod
    cybacordo.tpcontrato
    cybacordo.vloriginal
    cybacordo.vlacordo
    cybacordo.dtvinculo
    with frame frame-cab overlay row 3 width 80 side-labels
         title " Acordo de Cobranca - Via CYBER ".
if par-rec-cybacordo = ? /* Inclusao */
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

if par-rec-cybacordo <> ?
then do with frame frame-cab on error undo.
    find cybacordo where recid(cybacordo) = par-rec-cybacordo no-lock.
    if cybacordo.dtefetiva <> ?
    then assign
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

        hide frame f-com2  no-pause.

        if esqcom2[esqpos2] = "Origem"
        then do:
            hide frame frame-a no-pause.
            hide frame frame-b no-pause.
            clear frame frame-a all no-pause.
            run cyb/cybacorigem_v1701.p (par-rec-cybacordo).  
        end.            

        if esqcom2[esqpos2] = "parcelas"
        then do:
            hide frame frame-a no-pause.
            hide frame frame-b no-pause.
            clear frame frame-a all no-pause.
            clear frame frame-b all no-pause.
            run csl/cybacparcela_v2001.p (par-rec-cybacordo).  
        end.            
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.

procedure fcab.

    find cybacordo where recid(cybacordo) = par-rec-cybacordo no-lock.
    vhora = string(cybacordo.hracordo,"HH:MM").
    disp
        cybacordo.idacordo
    cybacordo.etbcod
    cybacordo.clifor
    cybacordo.Situacao 
    cybacordo.dtacordo 
    vhora
    cybacordo.dtefetiva 
    cybacordo.hrefetiva
    cybacordo.modcod
    cybacordo.tpcontrato
    cybacordo.vloriginal
    cybacordo.vlacordo
    cybacordo.dtvinculo
    with frame frame-cab.

    color disp messages
                cybacordo.dtacordo
                vhora
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
        find current cybacordo exclusive.
        assign
            cybacordo.dtefetiva  = today.
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

    
    find current cybacordo no-lock.
end.

end procedure.

procedure altera.

    do on error undo with frame frame-cab.
        find current cybacordo exclusive.
        find current cybacordo no-lock.
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
    
    if tabaux.dtacordo < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha a Auditoria"
                view-as alert-box.
        return.
    end.
    **/
    
    assign p-resp = yes.

end procedure.


procedure mostra-origem.

def var vparcelas as char format "x(22)".

def var vtela as int.
def var vi as int.
def var vret as log.
   
    form
        cybacorigem.contnum
        CybAcOrigem.etbcod /* #1 */
        vparcelas column-label "Parcelas" format "x(50)"
        cybacorigem.vlOriginal
        with frame frame-a 3 down centered row 09
        title " Contratos Origem " no-underline width 80.

clear frame frame-a all no-pause.
clear frame frame-b all no-pause.

for each cybacorigem of cybacordo no-lock
    by cybacorigem.contnum.

    vtela = vtela + 1.
    if vtela > 3 then leave. /* tamanho down da tela **/

    vret = no.
    vparcelas = "".    
    do vi = 1 to num-entries(cybacorigem.ParcelasLista).
        if vi <=8 
        then vparcelas = vparcelas + 
                if vparcelas = "" 
                then string(int(entry(vi,parcelasLista)),"99") 
                else "," + string(int(entry(vi,parcelasLista)),"99").
        if vi >= num-entries(parcelasLista) - 7 and
           vi > 8
        then do:
            vparcelas = vparcelas +  
                    if vparcelas = "" 
                    then  string(int(entry(vi,parcelasLista)),"99") 
                    else "," + string(int(entry(vi,parcelasLista)),"99").
        end.   
        else do:
            if vi > 8
            then do:
                if vret = no
                then do:
                    vparcelas = vparcelas + ",...".
                    vret = yes.
                end.
            end.
        end.
    end.                                     
 
    display 
        cybacorigem.contnum
        CybAcOrigem.etbcod  /* #1 */
        vparcelas
        cybacorigem.vlOriginal
        with frame frame-a.
     down with frame     frame-a.
end.

end procedure.


procedure mostra-parcelas.

def var vparcelas as char format "x(22)".

def var vtela as int.
def var vi as int.
def var vret as log.
   

form    cybacparcela.parcela 
        cybacparcela.dtvencimento
        cybacparcela.vlcobrado
        cybacparcela.contnum
        cybacparcela.dtbaixa
        cybacparcela.situacao format "x(03)" column-label "Sit"
        " | "
        with frame frame-b 3 down centered row 15
        title " Parcelas Acordo " no-underline width 80.

clear frame frame-b all no-pause.
for each cybacparcela of cybacordo no-lock
    by cybacparcela.parcela.

    vtela = vtela + 1.
    if vtela > 3 then leave. /* tamanho down da tela **/


    if cybacordo.situacao <> "A"
    then do:
        find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "cybacparcela" and
            banbolorigem.chaveOrigem  = "idacordo,parcela" and
            banbolorigem.dadosOrigem  = string(cybacordo.idacordo) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
        if avail banbolorigem
        then do:
            find banboleto of banbolorigem no-lock no-error.
        end.                    
        else do:
        find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "promessa" and
            banbolorigem.chaveOrigem  = "idacordo,contnum,parcela" and
            banbolorigem.dadosOrigem  = string(cybacordo.idacordo) + "," + string(cybacparcela.contnum) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
        if avail banbolorigem
        then do:
            find banboleto of banbolorigem no-lock no-error.
        end.                    
        end.
        
    end.
    display 
        cybacparcela.parcela 
        cybacparcela.dtvencimento
        cybacparcela.vlcobrado
        cybacparcela.contnum
        cybacparcela.dtbaixa
        cybacparcela.situacao 
        banbolorigem.nossonumero column-label "Boleto" when avail banbolorigem
        banboleto.dtenvio  when avail banboleto
        banboleto.situacao when avail banboleto
        with frame frame-b.
     down with frame     frame-b.
     release banboleto.
end.

end procedure.

