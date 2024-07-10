def var xok         as log format "/Nok" label "Sit".

def var vsituacao like banboleto.situacao.
def var vdtvencimento like banboleto.dtvencimento.
def var vdtpagamento  like banboleto.dtpagamento.
def var vclifor      like banboleto.clifor.


def shared temp-table tt-resumo no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field vlcobrado     as dec label "Vlr Documento" format ">>>>>>9.99" 
    field vlpagamento   as dec label "Vlr Extrato"   format ">>>>>>9.99" 
    field vltitpag      as dec label "Vlr Baixa" format ">>>>>>9.99"  .

def shared temp-table tt-bolteds no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field rec     as recid
    field Chave   as char format "x(20)"
    field vlcobrado     as dec label "Vlr Documento" 
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa".

def temp-table tt-contratos no-undo
    field contnum like contrato.contnum  format ">>>>>>>>>9"
    field etbcod  like contrato.etbcod
    field modcod  like contrato.modcod
    field CLICOD  like contrato.clicod
    field titpar    as int format ">9" label "PC"
    field titdtven  like titulo.titdtven column-label "Dt Venc"
                        format "99/99/99"
    field titvlcob  as dec format ">>>>>>9.99" label "Valor"
    field titdtpag  like titulo.titdtpag column-label "Dt Pag"
                        format "99/99/99"
    field titvlpag  as dec format ">>>>>>9.99" label "Vlr Pg".
    
    

def buffer btt-contratos for tt-contratos.
def var vconectada as log.
def var vexistente as log.
{cabec.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Titulo "," "," "," ",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input parameter par-rec as recid.

recatu1 = ?.

form
        tt-resumo.boltedforma column-label "Forma"
        tt-resumo.bancart     column-label "Cart"
        banco.numban          column-label "Banc"
        banco.bandesc         format "x(20)" column-label "Banco"  
        tt-resumo.vlcobrado   column-label "Vlr!Cobrado"
        tt-resumo.vlpagamento column-label "Vlr!Pago"                           
        tt-resumo.vltitpag    column-label "Vlr!Baixa" 
        /*xok format "   /NOK" column-label "Sit"*/
 
    with frame frame-cab0 overlay row 3 centered 1 down no-box.



form 
                    tt-contratos.clicod
                    tt-contratos.etbcod
                    tt-contratos.contnum
                    tt-contratos.modcod
                    tt-contratos.titpar
                    tt-contratos.titdtven
                    tt-contratos.titvlcob
                    tt-contratos.titdtpag
                    tt-contratos.titvlpag
                    titulo.titsit

with frame frame-a
                     row 11 5 down
                     no-box centered.


form
         tt-bolteds.chave
         clien.clinom format "x(17)" column-label "Nome"
         tt-bolteds.vlcobrado column-label "Cobrado"
                format ">>>>>9.99"
         vdtpagamento   column-label "Pagto"
         tt-bolteds.vlpagamento column-label "Extrato"
                format ">>>>>9.99"
         tt-bolteds.vltitpag column-label "Baixa"
                format ">>>>>9.99"
         vsituacao format "x" column-label "S"

    with frame frame-cab overlay row 8 width 80 1 down no-box
    no-underline.

if par-rec = ? /* Inclusao */
then do on error undo.
    return.
end.


    find tt-bolteds where recid(tt-bolteds) = par-rec no-lock.
    find tt-resumo  where 
        tt-bolteds.boltedforma = tt-resumo.boltedforma and
        tt-bolteds.bancod      = tt-resumo.bancod and
        tt-bolteds.bancart     = tt-resumo.bancart
    no-lock.
    run fcab0.
    run fcab.
    
    find first tt-contratos no-error.
    if not avail tt-contratos
    then run pega-contratos.


 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-contratos where recid(tt-contratos) = recatu1 no-lock.
    if not available tt-contratos
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
          recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-contratos).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-contratos
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-contratos where recid(tt-contratos) = recatu1 no-lock.
            
            esqcom1[1] = " Titulo".
            disp esqcom1 with frame f-com1.
        color disp messages
        tt-contratos.clicod.
            find titulo where
                titulo.empcod = 19 and titulo.titnat = no and
                titulo.etbcod = tt-contratos.etbcod and
                titulo.modcod = tt-contratos.modcod and
                titulo.clifor = tt-contratos.clicod and
                titulo.titnum = string(tt-contratos.contnum) and
                titulo.titpar = tt-contratos.titpar
                no-lock no-error.
                
            choose field tt-contratos.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            
            status default "".
 
        color disp normal
        tt-contratos.clicod.
 
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-contratos
                    then leave.
                    recatu1 = recid(tt-contratos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-contratos
                    then leave.
                    recatu1 = recid(tt-contratos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-contratos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-contratos
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                
                if esqcom1[esqpos1] = " Titulo "
                then do . 
            find titulo where
                titulo.empcod = 19 and titulo.titnat = no and
                titulo.etbcod = tt-contratos.etbcod and
                titulo.modcod = tt-contratos.modcod and
                titulo.clifor = tt-contratos.clicod and
                titulo.titnum = string(tt-contratos.contnum) and
                titulo.titpar = tt-contratos.titpar
                no-lock no-error.
                if avail titulo then do:                
                    run bsfqtitulo.p (input recid(titulo)).
                end.    
                end. 

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-contratos).
    end.
end.

    if connected ("finloja")
    then disconnect finloja.
    if connected ("comloja")
    then disconnect comloja.

hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

                
                find clien where clien.clicod = tt-contratos.clicod no-lock.
            find titulo where
                titulo.empcod = 19 and titulo.titnat = no and
                titulo.etbcod = tt-contratos.etbcod and
                titulo.modcod = tt-contratos.modcod and
                titulo.clifor = tt-contratos.clicod and
                titulo.titnum = string(tt-contratos.contnum) and
                titulo.titpar = tt-contratos.titpar
                no-lock no-error.
        
                disp 
                    tt-contratos.clicod
                    tt-contratos.etbcod
                    tt-contratos.contnum
                    tt-contratos.modcod
                    tt-contratos.titpar
                    tt-contratos.titdtven
                    tt-contratos.titvlcob
                    tt-contratos.titdtpag
                    tt-contratos.titvlpag
                    titulo.titsit when avail titulo
                        with frame frame-a.
 
end procedure.

procedure leitura.
def input parameter par-tipo as char.


if par-tipo = "pri" 
then find first  tt-contratos
        no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-contratos
        no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-contratos
    no-lock no-error.

end procedure.

procedure fcab.

    vsituacao = "".
    vdtvencimento = ?.
    vdtpagamento  = ?.
    vclifor       = ?. 
    if tt-bolteds.boltedforma = "BOL"
    then do:
        find banboleto where recid(banboleto) = tt-bolteds.rec no-lock.
        vsituacao       = banboleto.situacao.
        vdtvencimento   = banboleto.dtvencimento.
        vdtpagamento    = banboleto.dtpagamento.
        vclifor         = banboleto.clifor.
    end. 
    if tt-bolteds.boltedforma = "TED"
    then do:
        find banavisopag where recid(banavisopag) = tt-bolteds.rec no-lock.
        vsituacao       = banavisopag.situacao.
        vdtvencimento   = banavisopag.dtvencimento.
        vdtpagamento    = banavisopag.dtpagamento.
        vclifor         = banavisopag.clifor.
    end. 
    
    find clien where clien.clicod = vclifor no-lock no-error. 
    disp 
         tt-bolteds.chave
         clien.clinom 
                when avail clien
         tt-bolteds.vlcobrado
         vdtpagamento
         tt-bolteds.vlpagamento
         tt-bolteds.vltitpag
         vsituacao
 
    with frame frame-cab.

    
end procedure.
 


procedure fcab0.


    find banco where banco.bancod = tt-resumo.bancod no-lock no-error.
    xok = tt-resumo.vltitpag = tt-resumo.vlpagamento.
    disp 
        tt-resumo.boltedforma
        tt-resumo.bancart
        banco.numban when avail banco
        banco.bandesc when avail banco
        tt-resumo.vlcobrado
        tt-resumo.vlpagamento
        tt-resumo.vltitpag
        xok format "   /NOK" column-label "Sit"
 
    with frame frame-cab0.

    
end procedure.
  

procedure pega-contratos.
 
    vclifor       = ?. 
    if tt-bolteds.boltedforma = "BOL"
    then do:
        find banboleto where recid(banboleto) = tt-bolteds.rec no-lock.
        vclifor         = banboleto.clifor.
        for each banbolorigem of banboleto no-lock.
            if banbolorigem.tabelaorigem = "CYBACPARCELA"
            then do:
                find cybacparcela where 
                        cybacparcela.idacordo =                                                                    int(entry(1,banbolorigem.dadosOrigem)) and
                        cybacparcela.parcela  = 
                                int(entry(2,banbolorigem.dadosOrigem))
                     no-lock.
                find cybacordo of cybacparcela no-lock.
                run cria-contrato (cybacordo.clifor,
                                   cybacparcela.contnum,
                                   cybacparcela.parcela).
            end.
            if banbolorigem.tabelaorigem = "TITULO"
            then do:
                run cria-contrato (banboleto.clifor,
                                   int(entry(1,banbolorigem.dadosorigem)),
                                   int(entry(2,banbolorigem.dadosorigem))).
            end. 
        end.
    end. 
    if tt-bolteds.boltedforma = "TED"
    then do:
        find banavisopag where recid(banavisopag) = tt-bolteds.rec no-lock.
        vclifor         = banavisopag.clifor.
        for each banaviorigem of banavisopag no-lock.
        
            if banaviorigem.tabelaorigem = "TITULO"
            then do:
                run cria-contrato (banavisopag.clifor,
                                   int(entry(1,banaviorigem.dadosorigem)),
                                   int(entry(2,banaviorigem.dadosorigem))).
            end. 
        
        end.
    end. 

end procedure.
 
procedure cria-contrato. 
def input param vclicod  as int.
def input param vcontnum as int.
def input param vtitpar  as int.
find contrato where contrato.contnum = vcontnum no-lock.
for each titulo where 
        titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and
        titulo.modcod = contrato.modcod and
        titulo.clifor = vcLICOD and
        titulo.titnum = string(contrato.contnum) and
        titulo.titpar = vtitpar
        no-lock.
    
        create tt-contratos.
            tt-contratos.etbcod  = titulo.etbcod.
            tt-contratos.contnum = int(titulo.titnum).
            tt-contratos.modcod  = titulo.modcod.
            tt-contratos.clicod  = titulo.clifor.

    tt-contratos.titpar    = titulo.titpar.
    tt-contratos.titvlcob  = titulo.titvlcob.
    tt-contratos.titdtven  = titulo.titdtven.
    tt-contratos.titdtpag  = titulo.titdtpag.
    tt-contratos.titvlpag   = titulo.titvlpag.                
end.

end procedure.


