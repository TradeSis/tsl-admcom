/* helio 28022022 - iepro */

def var vp as char init ";".

def var varquivo as char.

def var xok         as log format "/Nok" label "Sit".



def var vsituacao like banboleto.situacao.
def var vdtvencimento like banboleto.dtvencimento.
def var vdtpagamento  like banboleto.dtpagamento.
def var vclifor      like banboleto.clifor.
def var vorigem      like banbolorigem.dadosorigem.

def  shared temp-table tt-resumo no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".

def  shared temp-table tt-bolteds no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field rec     as recid
    field Chave   as char format "x(20)"
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".

def buffer btt-bolteds for tt-bolteds.
{cabec.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Contratos "," Relatorio"," Arquivo"," Divergentes",""].
def var vdivergentes as log init no.

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input-output parameter par-rec as recid.

recatu1 = ?.


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
with frame frame-a
                     row 8 10  down
                     no-box.


form
        tt-resumo.boltedforma column-label "Forma"
        tt-resumo.bancart     column-label "Cart"
        banco.numban          column-label "Banc"
        banco.bandesc         format "x(5)" column-label "Banco"  
        tt-resumo.vlcobrado   column-label "Vlr!Cobrado"
            format ">>>>>>>>>9.99"
        tt-resumo.vlpagamento column-label "Vlr!Pago"                          
            format ">>>>>>>>>9.99"
        tt-resumo.vltitpag    column-label "Vlr!Baixa" 
            format ">>>>>>>>>9.99"
        tt-resumo.vltaxa      column-label "Dif"
        
        xok format "   /NOK" column-label "Sit"
 
    with frame frame-cab overlay row 3 centered 1 down no-box.

if par-rec = ? /* Inclusao */
then do on error undo.
    return.
end.


    find tt-resumo where recid(tt-resumo) = par-rec no-lock.
    run fcab.
    

 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-bolteds where recid(tt-bolteds) = recatu1 no-lock.
    if not available tt-bolteds
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

    recatu1 = recid(tt-bolteds).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-bolteds
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
            find tt-bolteds where recid(tt-bolteds) = recatu1 no-lock.
            
            disp esqcom1 with frame f-com1.
        color disp messages
        tt-bolteds.chave.
            
            choose field tt-bolteds.chave help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        tt-bolteds.chave.
 
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
                    if not avail tt-bolteds
                    then leave.
                    recatu1 = recid(tt-bolteds).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-bolteds
                    then leave.
                    recatu1 = recid(tt-bolteds).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-bolteds
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-bolteds
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
                if esqcom1[esqpos1] = " Boleto "
                then do .
                    hide frame f-com1 no-pause.
                    def var recatu2 as recid.
                    recatu2 = tt-bolteds.rec.
                    run bol/banboletoman_v1701.p (input-output recatu2).
                    view frame f-com1.
                end. 
                if esqcom1[esqpos1] = " Relatorio "
                then do .
                    run relatorio.
                end. 
                if esqcom1[esqpos1] = " Arquivo "
                then do .
                    run arquivocsv.
                end. 
                if esqcom1[esqpos1] = " Divergentes"
                then do:
                    esqcom1[esqpos1] = " Todos ".
                    vdivergentes = yes.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Todos"
                then do:
                    esqcom1[esqpos1] = " Divergentes ".
                    vdivergentes = no.
                    recatu1 = ?.
                    leave.
                end.

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-bolteds).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

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
                        with frame frame-a.
 
end procedure.

procedure leitura.
def input parameter par-tipo as char.


if par-tipo = "pri" 
then find first  tt-bolteds where 
        tt-bolteds.boltedforma = tt-resumo.boltedforma and
        tt-bolteds.bancod      = tt-resumo.bancod and
        tt-bolteds.bancart     = tt-resumo.bancart
        and 
        (if vdivergentes 
        then (tt-bolteds.vlpagamento <> tt-bolteds.vltitpag)
        else true)
        no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-bolteds where
        tt-bolteds.boltedforma = tt-resumo.boltedforma and
        tt-bolteds.bancod      = tt-resumo.bancod and
        tt-bolteds.bancart     = tt-resumo.bancart
        and 
        (if vdivergentes 
        then (tt-bolteds.vlpagamento <> tt-bolteds.vltitpag)
        else true)

        no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-bolteds where 
        tt-bolteds.boltedforma = tt-resumo.boltedforma and
        tt-bolteds.bancod      = tt-resumo.bancod and
        tt-bolteds.bancart     = tt-resumo.bancart
        and 
        (if vdivergentes 
        then (tt-bolteds.vlpagamento <> tt-bolteds.vltitpag)
        else true)
        
    no-lock no-error.

end procedure.

procedure fcab.

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
        tt-resumo.vlpagamento - tt-resumo.vltitpag @ tt-resumo.vltaxa
        xok format "   /NOK" column-label "Sit"
        with frame frame-cab.
end procedure.
 


procedure relatorio.



    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relconbol" + 
                                string(today,"999999") + "_" +
                                string(time) + ".txt".
    else varquivo = "..~\relat~\relconbol" + 
                                string(today,"999999") + "_" +
                                string(time) + ".txt".

    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "0"  
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RELCONBOL"" 
                &Nom-Sis   = """PORTAL DE PAGAMENTOS""" 
        &Tit-Rel   = """ CONCILIACAO PAGAMENTOS  """ 
                &Width     = "150"
                &Form      = "frame f-cabcab"}

    /**
    disp
        vEstab   colon 31 label "Todos Estabelecimentos.."
        cestab   no-label
        vmoeda  colon 31  label "Todos as Moedas........."
        cmoeda  no-label skip 
        par-tipodata 
            colon 31 label "Tipo de Relatorio"
        skip
        vdata1   colon 31 label "Periodo"
        vdata2   label "ate"  skip
        par-operacao[frame-index]  no-label  format "x(20)" at 10
        
        with frame fparaopcoes side-label width 80.
    **/

    for each btt-bolteds where 
        btt-bolteds.boltedforma = tt-resumo.boltedforma and
        btt-bolteds.bancod      = tt-resumo.bancod and
        btt-bolteds.bancart     = tt-resumo.bancart
        with frame frame-r:


form  
         btt-bolteds.chave
         vclifor format ">>>>>>>>>9" column-label "Cliente"
         clien.clinom format "x(17)" column-label "Nome"
         btt-bolteds.vlcobrado column-label "Cobrado"
                format ">>>>>9.99"
         vdtpagamento   column-label "Pagto"
         btt-bolteds.vlpagamento column-label "Extrato"
                format ">>>>>9.99"
         btt-bolteds.vltitpag column-label "Baixa"
                format ">>>>>9.99"
         btt-bolteds.vltaxa column-label "Taxa"
         vsituacao format "x" column-label "S"
         vorigem format "x(30)" column-label "Origem"
with frame frame-r
down                  
                     width 140.


        vsituacao = "".
        vdtvencimento = ?.
        vdtpagamento  = ?.
        vclifor       = ?. 
        vorigem = "".
        if btt-bolteds.boltedforma = "BOL"
        then do:
            find banboleto where recid(banboleto) = btt-bolteds.rec no-lock.
            vsituacao       = banboleto.situacao.
            vdtvencimento   = banboleto.dtvencimento.
            vdtpagamento    = banboleto.dtpagamento.
            vclifor         = banboleto.clifor.
            find first banbolorigem of banboleto where 
                 banbolorigem.tabelaorigem = "TITULO"
                 no-lock no-error.
            if avail banbolorigem
            then vorigem = banbolorigem.dadosorigem.
        end.     
        if btt-bolteds.boltedforma = "TED"
        then do:
            find banavisopag where recid(banavisopag) = btt-bolteds.rec no-lock.
            vsituacao       = banavisopag.situacao.
            vdtvencimento   = banavisopag.dtvencimento.
            vdtpagamento    = banavisopag.dtpagamento.
            vclifor         = banavisopag.clifor.
            find first banaviorigem of banavisopag where
                    banaviorigem.tabelaorigem = "TITULO"
                    no-lock no-error.
            if avail banaviorigem
            then vorigem = banaviorigem.dadosorigem.
        end. 
    
        vorigem = replace(vorigem,",","/").
        
        find clien where clien.clicod = vclifor no-lock no-error. 
        disp 
         btt-bolteds.chave
         vclifor
         clien.clinom  when avail clien
         btt-bolteds.vlcobrado   (total)
         vdtpagamento
         btt-bolteds.vlpagamento (total)
         btt-bolteds.vltitpag    (total)
         btt-bolteds.vltaxa (total)
         vsituacao
         vorigem 
                        with frame frame-r.
        down with frame frame-r.                        
    end.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

end procedure.


procedure arquivocsv.


    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relconbol" + 
                                string(today,"999999") + "_" +
                                string(time) + ".csv".
    else varquivo = "..~\relat~\relconbol" + 
                                string(today,"999999") + "_" +
                                string(time) + ".csv".
    
    hide message no-pause.
 
    output to value(varquivo).
     
    put unformatted
         "CHAVE" vp
         "CLIENTE" vp
         "NOME" vp
         "VLR COBRADO" vp
         "DT PAGTO" vp
         "VLR EXTRATO" vp
         "VLR BAIXA" vp
         "SITUACAO"  vp
         "ORIGEM"    vp
         "VLR CUSTAS"
         skip.
    for each btt-bolteds where 
        btt-bolteds.boltedforma = tt-resumo.boltedforma and
        btt-bolteds.bancod      = tt-resumo.bancod and
        btt-bolteds.bancart     = tt-resumo.bancart:


        vsituacao = "".
        vdtvencimento = ?.
        vdtpagamento  = ?.
        vclifor       = ?. 
        vorigem = "".
        if btt-bolteds.boltedforma = "BOL"
        then do:
            find banboleto where recid(banboleto) = btt-bolteds.rec no-lock.
            vsituacao       = banboleto.situacao.
            vdtvencimento   = banboleto.dtvencimento.
            vdtpagamento    = banboleto.dtpagamento.
            vclifor         = banboleto.clifor.
            find first banbolorigem of banboleto where 
                 banbolorigem.tabelaorigem = "TITULO"
                 no-lock no-error.
            if avail banbolorigem
            then vorigem = banbolorigem.dadosorigem.
        end. 
        if btt-bolteds.boltedforma = "TED"
        then do:
            find banavisopag where recid(banavisopag) = btt-bolteds.rec no-lock.
            vsituacao       = banavisopag.situacao.
            vdtvencimento   = banavisopag.dtvencimento.
            vdtpagamento    = banavisopag.dtpagamento.
            vclifor         = banavisopag.clifor.
            find first banaviorigem of banavisopag where
                    banaviorigem.tabelaorigem = "TITULO"
                    no-lock no-error.
            if avail banaviorigem
            then vorigem = banaviorigem.dadosorigem.
        end. 
        vorigem = replace(vorigem,",","/").
        find clien where clien.clicod = vclifor no-lock no-error. 
        put unformatted
         btt-bolteds.chave VP 
         vclifor VP   
         clien.clinom   VP
         btt-bolteds.vlcobrado VP
         vdtpagamento VP
         btt-bolteds.vlpagamento VP
         btt-bolteds.vltitpag VP
         vsituacao VP
         vorigem vp
         btt-bolteds.titvlrcustas VP
         skip.
    end.
    
    output close.
    
    message "Gerado arquivo " varquivo.
    pause 2.
    

end.


