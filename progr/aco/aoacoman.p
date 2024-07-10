/*
#1 TP 28872041 16.01.19 - Etbcod e modcod na origem
*/
{cabec.i}

def input-output parameter par-rec-aoacordo as recid.

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
    aoacordo.idacordo
    aoacordo.etbcod
    aoacordo.clifor
    aoacordo.Situacao 
    aoacordo.dtacordo 
    vhora
    aoacordo.dtefetiva 
    aoacordo.hrefetiva
    aoacordo.vloriginal
    aoacordo.vlacordo
    aoacordo.dtvinculo
    with frame frame-cab overlay row 3 width 80 side-labels
         title " Acordo de Cobranca - Via Acordo Online ".
if par-rec-aoacordo = ? /* Inclusao */
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

if par-rec-aoacordo <> ?
then do with frame frame-cab on error undo.
    find aoacordo where recid(aoacordo) = par-rec-aoacordo no-lock.
    if aoacordo.dtefetiva <> ?
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
            run aco/aoacoorigem.p (par-rec-aoacordo).   
        end.            

        if esqcom2[esqpos2] = "parcelas"
        then do:
            hide frame frame-a no-pause.
            hide frame frame-b no-pause.
            clear frame frame-a all no-pause.
            clear frame frame-b all no-pause.
            run aco/aoacparcela.p (par-rec-aoacordo).  
        end.            
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.

procedure fcab.

    find aoacordo where recid(aoacordo) = par-rec-aoacordo no-lock.
    vhora = string(aoacordo.hracordo,"HH:MM").
    disp
    aoacordo.tipo
        aoacordo.idacordo
    aoacordo.etbcod
    aoacordo.clifor
    aoacordo.Situacao 
    aoacordo.dtacordo 
    vhora
    aoacordo.dtefetiva 
    aoacordo.hrefetiva
    aoacordo.vloriginal
    aoacordo.vlacordo
    aoacordo.dtvinculo
    with frame frame-cab.

    color disp messages
                aoacordo.dtacordo
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
        find current aoacordo exclusive.
        assign
            aoacordo.dtefetiva  = today.
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

    
    find current aoacordo no-lock.
end.

end procedure.

procedure altera.

    do on error undo with frame frame-cab.
        find current aoacordo exclusive.
        find current aoacordo no-lock.
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


def var vtela as int.
def var vi as int.
def var vret as log.
   
    form
        aoacorigem.contnum
        aoacorigem.titpar
        aoacorigem.vlcob
        aoacorigem.vljur
        aoacorigem.vltot

        with frame frame-a 3 down centered row 09
        title " Contratos Origem " no-underline width 80.

clear frame frame-a all no-pause.
clear frame frame-b all no-pause.

for each aoacorigem of aoacordo no-lock
    by aoacorigem.contnum by aoacorigem.titpar.

    vtela = vtela + 1.
    if vtela > 3 then leave. /* tamanho down da tela **/

    /*
    vret = no.
    vparcelas = "".    
    do vi = 1 to num-entries(aoacorigem.ParcelasLista).
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
    */
        release banboleto.
            find first banbolOrigem  where 
                banbolorigem.tabelaOrigem = "api/acordo,parcelasboleto" and
                banbolorigem.chaveOrigem  = "idacordo,contnum,titpar" and
                banbolorigem.dadosOrigem  = string(aoacordo.idacordo) + "," + 
                           string(aoacorigem.contnum) + "," +
                           string(aoacorigem.titpar)
                no-lock no-error.
            if avail banbolorigem
            then do:
                find banboleto of banbolorigem no-lock no-error.
            end.

    display 
        aoacorigem.contnum
        aoacorigem.titpar
        aoacorigem.vlcob column-label "vlr ori"
        aoacorigem.vljur column-label "juros"  
        aoacorigem.vltot column-label "divida"
        banbolorigem.nossonumero column-label "Boleto" when avail banbolorigem
        banboleto.dtenvio  when avail banboleto
        banboleto.situacao when avail banboleto

        with frame frame-a.
     down with frame     frame-a.
end.

end procedure.


procedure mostra-parcelas.

def var vparcelas as char format "x(22)".

def var vtela as int.
def var vi as int.
def var vret as log.
   

form    aoacparcela.parcela 
        aoacparcela.dtvencimento
        aoacparcela.vlcobrado
        aoacparcela.contnum
        aoacparcela.dtbaixa
        aoacparcela.situacao format "x(03)" column-label "Sit"
        " | "
        with frame frame-b 3 down centered row 15
        title " Parcelas Acordo " no-underline width 80.

clear frame frame-b all no-pause.
for each aoacparcela of aoacordo no-lock
    by aoacparcela.parcela.

    vtela = vtela + 1.
    if vtela > 3 then leave. /* tamanho down da tela **/

    
    if true /*aoacordo.situacao <> "A"*/
    then do:
        find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "aoacparcela" and
            banbolorigem.chaveOrigem  = "idacordo,parcela" and
            banbolorigem.dadosOrigem  = string(aoacordo.idacordo) + "," +
                           string(aoacparcela.parcela)
            no-lock no-error.
        if avail banbolorigem
        then do:
            find banboleto of banbolorigem no-lock no-error.
        end.                    
        else do:
            find first banbolOrigem  where 
                banbolorigem.tabelaOrigem = "promessa" and
                banbolorigem.chaveOrigem  = "idacordo,contnum,parcela" and
                banbolorigem.dadosOrigem  = string(aoacordo.idacordo) + "," + string(aoacparcela.contnum) + "," +
                           string(aoacparcela.parcela)
                no-lock no-error.
            if avail banbolorigem
            then do:
                find banboleto of banbolorigem no-lock no-error.
            end.                    
        end.
        if not avail banboleto
        then do:
            find first banbolOrigem  where 
                banbolorigem.tabelaOrigem = "api/acordo,negociacaoboleto" and
                banbolorigem.chaveOrigem  = "idacordo,parcela" and
                banbolorigem.dadosOrigem  = string(aoacordo.idacordo) + "," + 
                           string(aoacparcela.parcela)
                no-lock no-error.
            if avail banbolorigem
            then do:
                find banboleto of banbolorigem no-lock no-error.
            end.
        end.

    end.
    display 
        aoacparcela.parcela 
        aoacparcela.dtvencimento
        aoacparcela.vlcobrado
        aoacparcela.contnum
        aoacparcela.dtbaixa
        aoacparcela.situacao 
        banbolorigem.nossonumero column-label "Boleto" when avail banbolorigem
        banboleto.dtenvio  when avail banboleto
        banboleto.situacao when avail banboleto
        with frame frame-b.
     down with frame     frame-b.
     release banboleto.
end.

end procedure.

