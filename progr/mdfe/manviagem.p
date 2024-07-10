
{cabec.i}

def input-output parameter par-rec-mdfviagem as recid.

def var vopcao as char extent 3.
def var copcao as int.
def var vi as int.
def var vmensagem as char.
def buffer bmdfviagem    for mdfviagem.
def buffer for-clifor for forne.
def buffer bfrete for frete.

def var vhora as char label "Hora" format "x(5)".

def var esqpos2 as int .
def var esqcom2         as char format "x(10)" extent 6
            initial ["NFe",
                     "Rota",
                     "MDFe",
                     "Manutencao",
                     "Romaneio",
                     "Operacoes"].

form
    esqcom2                        
    with frame f-com2 row screen-lines no-labels no-box column 2 overlay.


find estab where estab.etbcod = setbcod no-lock.
if estab.etbnom begins "DREBES-FIL"
then do.
    esqcom2[2] = "".
end.

form
    with    frame frame-seg
     overlay row 10 width 80 side-labels
         title " Informacoes Seguro " .

form
    with    frame frame-mot
     overlay row 10 width 80 side-labels
         title " Informacoes Motorista " .

form
    with    frame frame-ciot
     overlay row 10 width 80 side-labels
         title " Informacoes CIOT " .
      
form
    mdfviagem.frecod colon 12 label "Transp"
    frete.frenom no-label 
    frete.fretpcod
    tpfrete.fretpemit label "TpE" 
    frete.rntrc  

    forne.forcgc colon 12 
    space(0) " Codigo: (" space(0) forne.forcod no-label space(0) ")"
    forne.forfone colon 60
 
    mdfviagem.etbcod colon 12 label "Filial"
    mdfviagem.placa  
    mdfviagem.dtviagem 
    vhora
    
   
    mdfviagem.viaobs  colon 12 label "Obs"
    tpfrete.mdfe      colon 12
    mdfviagem.dtemiss label "Dt Emissao" colon 35
    mdfviagem.dtencer colon 60 label "Encerramento"

    with frame frame-cab overlay row 3 width 80 side-labels
         title " Manifesto Documentos Fiscais - VIAGEM".

if par-rec-mdfviagem = ? /* Inclusao */
then do on error undo.
    find estab where estab.etbcod = setbcod no-lock.

    if estab.etbnom begins "DREBES-FIL"
    then do.
        message "Realizar a inclusao no acesso remoto" view-as alert-box.
        leave.
    end.

    if estab.etbnom begins "DREBES-FIL"
    then run inclui-os-loja.
    else run inclui-os-matriz.

end.


if par-rec-mdfviagem <> ?
then do with frame frame-cab on error undo.

    find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
    if mdfviagem.dtencer <> ?
    then assign
            esqcom2[2] = ""
            esqcom2[4] = ""
            esqcom2[6] = "".

    repeat:
        run fetiq.    
        run mostra-nfe.
        

    find first mdfe of mdfviagem where
            mdfe.situacao = "A" or
            mdfe.situacao = "F"
            no-lock no-error.
    if avail mdfe
    then esqcom2[6] = "".
    else do:
        find first mdfnfe of mdfviagem
            no-lock no-error.
        if avail mdfnfe
        then esqcom2[6] = "".
        else esqcom2[6] = "Operacoes".
    end.    

        
        disp esqcom2 with frame f-com2.
        choose field esqcom2 
            with frame f-com2. 


        esqpos2 = frame-index.


        if esqcom2[esqpos2] = "Operacoes"
        then run operacoes.
        
        if esqcom2[esqpos2] = "Manutencao"
        then run manutencao.
        
        hide frame f-com2  no-pause.

        if esqcom2[esqpos2] = "MDFe"
        then run mdfe/manviagmdf.p (par-rec-mdfviagem).  

 
        if esqcom2[esqpos2] = "Romaneio"
        then run mdfe/rromaneio.p (par-rec-mdfviagem).  
 
        if esqcom2[esqpos2] = "Nfe"
        then run mdfe/manmdfnfe.p (par-rec-mdfviagem).  
        
        if esqcom2[esqpos2] = "Rota " 
        then do. 
            run mdfe/manviagrota.p (input recid(mdfviagem)). 
            run mostra-nfe.
        end.
        
        else if esqcom2[esqpos2] = "Altera"
        then run altera.
        else if esqcom2[esqpos2] = "Dados Adic"
        then run not_etiqestdad.p (recid(mdfviagem)).
        else if esqcom2[esqpos2] = "Imprime OS"
        then run not_etiqestrel.p (par-rec-mdfviagem).
        
        else if esqcom2[esqpos2]= "Reg.Troca"
        then run reg-troca.p (mdfviagem.placa).
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.

procedure fetiq.

    find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
    find veiculo of mdfviagem no-lock. 
    find frete   of mdfviagem no-lock.
    find tpfrete of frete     no-lock.
    find forne   of frete     no-lock.
    vhora = string(mdfviagem.hrviagem,"HH:MM").


    disp
    mdfviagem.etbcod 
    mdfviagem.placa  
    mdfviagem.dtviagem 
    vhora
    
    mdfviagem.frecod 
    frete.frenom 
    frete.fretpcod
    tpfrete.fretpemit
    frete.rntrc 

    forne.forcgc 
    forne.forcod 
    forne.forfone 
    
    mdfviagem.viaobs  
    tpfrete.mdfe  
    mdfviagem.dtemiss 
    mdfviagem.dtencer 

    with frame frame-cab.

    color disp messages
                mdfviagem.placa
                mdfviagem.dtviagem
                vhora
                with frame frame-cab.

    
end procedure.
 

procedure operacoes.

def var vmotivo   as char.
def var esqpos    as int init 1.
def var esqmenu   as char format "x(12)" extent 7
    init ["Encerra", "", ""].


find first mdfe of mdfviagem where
    mdfe.situacao = "A" or
    mdfe.situacao = "F"
    no-lock no-error.
if avail mdfe
then do.
    message "Existem MDFe Abertas".
    pause 1.
    return.
end.    

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
        find current mdfviagem exclusive.
        assign
            mdfviagem.dtencer  = today.
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

    
    find current mdfviagem no-lock.
end.

end procedure.

procedure seguro.

do  with frame frame-seg     on error undo      .
    
    find current mdfviagem exclusive.
    
    update
        mdfviagem.segresp colon 20.
    if mdfviagem.segresp = no /*2*/
    then
    update        
        mdfviagem.segrespcnpjcpf colon 20.
    update
        mdfviagem.seguradora colon 20 format "x(20)".
    update
        mdfviagem.segcnpj colon 20.
    update
        mdfviagem.segnapol colon 20.
    update
        mdfviagem.segnaver colon 20.
            
                
end.

hide frame frame-seg no-pause.

find current mdfviagem no-lock.

end procedure.



procedure motorista.

do  with frame frame-mot     on error undo      .
    
    find current mdfviagem exclusive.
    disp 
        mdfviagem.motoristacpf[1] colon 20
        mdfviagem.motoristanome[1] label "Nome" format "x(35)" 
        mdfviagem.motoristacpf[2] colon 20
        mdfviagem.motoristanome[2] label "Nome" format "x(35)" 
        mdfviagem.motoristacpf[3] colon 20
        mdfviagem.motoristanome[3] label "Nome" format "x(35)" .
    
    update
        mdfviagem.motoristacpf[1].
    update    
        mdfviagem.motoristanome[1].

    update
        mdfviagem.motoristacpf[2].
    if mdfviagem.motoristacpf[2] = ""
    then leave.
    update        
        mdfviagem.motoristanome[2].
     
    update
        mdfviagem.motoristacpf[3].
    if mdfviagem.motoristacpf[3] = ""
    then leave.
        
    update        
        mdfviagem.motoristanome[3].
 
                
end.

hide frame frame-mot no-pause.

find current mdfviagem no-lock.

end procedure.


procedure ciot.

do  with frame frame-ciot    on error undo      .
    
    find current mdfviagem exclusive.
    disp 
        mdfviagem.ciot colon 20.
    
    update
        mdfviagem.ciot.
    update
        mdfviagem.ciotcnpj.
  
                
end.

hide frame frame-mot no-pause.

find current mdfviagem no-lock.

end procedure.




procedure inclui-os-matriz.

    /**
    run versenha.p ("ManViagemDEP", "", 
                    "Senha para INCLUIR VIAGEM no DEP",
                    output sresp).

    if not sresp
    then return.
    **/
    
repeat with frame frame-cab on error undo:
    
    display
        setbcod @ mdfviagem.etbcod.

    if setbcod <> 900
    then do:
        hide message no-pause.
        message "Login em Estabelecimento Invalido para MDFe" setbcod.
        message "Entre pelo 900".
        pause.
        return.
    end.
    prompt-for mdfviagem.frecod.
    
    message input mdfviagem.frecod <> "".
    
    if input mdfviagem.frecod <> ""
    then do:
        find frete where frete.frecod = input mdfviagem.frecod no-lock no-error.
        if not avail frete 
        then do:
            hide message no-pause.
            message "Transportadora nao cadastrada...".
            run frete.p.
            next.  
        end.
        if avail frete
        then do:
            find tpfrete of frete no-lock.
            find forne   of frete no-lock.
            disp
                frete.frenom 
                frete.fretpcod
                tpfrete.fretpemit
                frete.rntrc 
                forne.forcgc 
                forne.forcod 
                forne.forfone 
                tpfrete.mdfe  
    
                with frame frame-cab.    
        end.
    end.
    
    prompt-for mdfviagem.placa.
    
    find veiculo where veiculo.placa = input mdfviagem.placa no-lock no-error.
    if not avail veiculo 
    then do.
        hide message no-pause.
        message "Veiculo nao cadastrado...".
        run veiculo.p (input if avail frete then frete.frecod else 0).
        next.
    end.
    
    if avail frete
    then do.
        if frete.frecod <> veiculo.frecod
        then do:
            find bfrete where bfrete.frecod = veiculo.frecod no-lock.
            hide message no-pause.
            vmensagem = 
            "Veiculo associado a outra Transportadora = " +
            string(veiculo.frecod) + " " +  bfrete.frenom.
            message vmensagem.
            
            vopcao[1] = "Trocar para Transportadora do Veiculo". 
            vopcao[2] = "Entrar no cadastro de transportadoras".
            vopcao[3] = "Voltar".
            
            disp    skip(1)
                    vopcao[1] format "x(60)" 
                 vopcao[2] format "x(60)"
                 vopcao[3] format "x(60)"
                    skip(1)
                 with frame fopcaofreveiculo
                    centered
                    no-labels
                    row 11
                    overlay
                    1 down
                    title vmensagem.
            choose field vopcao
                    with frame fopcaofreveiculo.
            hide frame fopcaofreveiculo no-pause.
            hide message no-pause.
            copcao = frame-index.
            if copcao = 1
            then.
            else
            if copcao = 2
            then do:
                run frete.p.
                next.
            end.     
            if copcao = 3
            then undo.
                        
        end.
    
    end.

    find frete of veiculo no-lock. 
    find tpfrete of frete no-lock. 
    find forne   of frete no-lock. 

    disp 
        frete.frecod @ mdfviagem.frecod
        frete.frenom  
        frete.fretpcod 
        tpfrete.fretpemit
        frete.rntrc  
        forne.forcgc  
        forne.forcod  
        forne.forfone  
        tpfrete.mdfe  
    
         with frame frame-cab.    
    
    find first mdfviagem where
        mdfviagem.placa = input mdfviagem.placa and
        mdfviagem.dtencer = ?
        no-lock no-error.
    if avail mdfviagem 
    then do:
        hide message no-pause.
        message "Veiculo com viagem em andamento " mdfviagem.dtviagem.
        pause.
        return.
    end.

    
    do on error undo.
        disp today @ mdfviagem.dtviagem.
        prompt-for mdfviagem.dtviagem.  
        if avail mdfviagem and input mdfviagem.dtviagem <= mdfviagem.dtviagem
        then do:
            hide message no-pause.
            message "Veiculo em Viagem desde" mdfviagem.dtviagem.
            message "Data tem que ser superior".
            undo, retry.
        end.
        if input mdfviage.dtviagem = ?
        then do:
            message "digite uma data".
            undo.
        end.
    end.
    update     vhora.
    

    prompt-for mdfviagem.viaobs.
       
                do transaction:

                    create mdfviagem.  
                    assign mdfviagem.etbcod   = setbcod
                           mdfviagem.mdfvcod  = next-value(mdfviagemseq)
                           mdfviagem.frecod   = frete.frecod
                           mdfviagem.placa    = input mdfviagem.placa
                           mdfviagem.dtviagem = input mdfviagem.dtviagem.
                           mdfviagem.hrviagem = 0. /* vhrviagem */
                           mdfviagem.viaobs   = input mdfviagem.viaobs.
                    vi = 0.
                    for each motorista of frete 
                        where motorista.situacao = yes
                        no-lock.
                        vi = vi + 1.
                        if vi > 10 then leave.
                        mdfviagem.motoristacpf[vi]  = motorista.cpf.
                        mdfviagem.motoristanome[vi] = motorista.nome.
                    end.
               end.     
            par-rec-mdfviagem = recid(mdfviagem).

        leave.
                    
    end.

end procedure.


procedure inclui-os-loja:

    message 
        "A inclusão de OS agora deve ser feita na retaguarda de venda, menu "
        "ASSISTENCIA TECNICA. Neste menu do caixa deve ser feita apenas a "
        "movimentação da OS (dar sequência para emitir as NFe's)"
        view-as alert-box.


    
end procedure.

procedure altera.

    do on error undo with frame frame-cab.
        find current mdfviagem exclusive.
        find current mdfviagem no-lock.
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
    
    if tabaux.dtviagem < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha a Auditoria"
                view-as alert-box.
        return.
    end.
    **/
    
    assign p-resp = yes.

end procedure.


procedure mostra-nfe.


def var vemitpro      as log format " /T" label "*". 
def var vserie       like plani.serie.
def var vnumero      like plani.numero.
def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom format "x(12)".


def var vi as int.
vi = 0.
    
    form
        mdfnfe.rotaseq column-label "Sq" 
        vemitpro
        mdfnfe.nfeId    format "xxxxxxxxxxxx..."
        vserie column-label "Ser"
        vnumero
        "EMITE"
        mdfnfe.tabemite no-label format  "x(3)"
        mdfnfe.emite    no-label format ">>>>>>99"
        vufemi          no-label
        vmunicemi       no-label
        mdfe.mdfenumero column-label "MDFe"
        
        skip
        space(33)
        "DESTI"
        mdfnfe.tabdesti no-label format  "x(3)"
        mdfnfe.desti    no-label format ">>>>>>99"
        vufdes          no-label
        vmunicdes       no-label 


        with frame frame-a 3 down centered color white/red row 10
        title " NFEs " no-underline width 80.

clear frame frame-a no-pause.
for each mdfnfe of mdfviagem no-lock
    by mdfnfe.rotaseq.

    find mdfe of mdfnfe no-lock no-error.
    
    vi = vi + 1.
    if vi > 3 then leave. /* tamanho down da tela **/
    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        

    find first a01_infnfe where
        a01_infnfe.chave = mdfnfe.infnfechave
        no-lock  no-error.

    vserie  = mdfnfe.serie.
    vnumero = mdfnfe.numero.

    vemitpro = avail a01_infnfe.
    
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie = plani.serie.
            vnumero = plani.numero.
            
        end.
                                             
    end.    
    
    display 
        mdfnfe.rotaseq 
        vemitpro
        mdfnfe.nfeid  
        vserie
        vnumero
        mdfnfe.tabemite 
        mdfnfe.emite   
        vufemi     
        vmunicemi
        mdfe.mdfenumero when avail mdfe
        
        mdfnfe.tabdesti 
        mdfnfe.desti   
        vufdes   
        vmunicdes

        with frame frame-a.
     down with frame     frame-a.
end.

end procedure.
