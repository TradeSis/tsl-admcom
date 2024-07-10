/* medico na tela 042022 - helio */

{admcab.i}

def input param ctitle      as char.

def var vano as int format "9999" label "ano".
def var vmes as int format "99" label "mes".
def var vauxmes as int.
def var vauxano as int. 
def temp-table ttrepasse no-undo
    field dtvenc    like medaderepasse.dtvenc
    field rec as recid
    field qtdrepasses   as int format ">9" 
    index dt is unique primary dtvenc asc rec asc .
    
def buffer b-medaderepasse for medaderepasse.
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["conteudo"," csv",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.

def var vtotservico   as dec.
def var vclinom       as char.        

def var vdtini as date format "99/99/9999" label "de".
def var vdtfim as date format "99/99/9999" label "ate".

    form  
        medadesao.dataTransacao column-label "dt venda" format "99999999"

        medaderepasse.dtvenc column-label "dt repasse" format "99999999"
        medadesao.etbcod column-label "fil" format ">>9"
        medadesao.cpf                         column-label "cpf" format "99999999999"
        vclinom  format "x(15)" column-label "cliente"
        medadesao.idAdesao  column-label "id" format ">>>>9"
        medaderepasse.vlrepasse column-label "vlr!repas " format ">>9.99"
        medadesao.dtcanc    column-label "dtcanc" format "99999999" 
        
        with frame frame-a 9 down centered row 7
        no-box.

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

    vmes = month(today). vano = year(today).
    
    update vmes vano
        with frame fperiodo
        centered row 5
        side-labels.

        
    vdtini = date(vmes,01,vano). 
    vauxmes = vmes + 1. 
    vauxano = vano.   
    if vauxmes = 13 
    then do: 
        vauxmes = 1. 
        vauxano = vauxano + 1. 
    end.    
    vdtfim = date(vauxmes,01,vauxano) - 1.
                 /*
    disp
        vdtini
        vdtfim
                   */
   ctitle = ctitle + " / periodo: " + string(vdtini,"99/99/9999") + " a " + string(vdtfim,"99/99/9999").

disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.


disp 
    vtotservico    label "Filtrado"      format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.

empty temp-table ttrepasse.
run montatt.

bl-princ:
repeat:
    
   vtotservico = 0.
    for each ttrepasse.

        find medaderepasse where recid(medaderepasse) = ttrepasse.rec no-lock. 
        vtotservico = vtotservico + medaderepasse.vlrepasse.
    end.
           
    disp
        vtotservico
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttrepasse where recid(ttrepasse) = recatu1 no-lock.
    if not available ttrepasse
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttrepasse).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttrepasse
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttrepasse where recid(ttrepasse) = recatu1 no-lock.
        find medaderepasse where recid(medaderepasse) = ttrepasse.rec no-lock.
        find medadesao of medaderepasse no-lock.

        status default "".
        
                        
        /*             
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.
    /*    
    if medadesao.titdescjur <> 0
    then do:
        if medadesao.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" medadesao.dtinc "de R$" trim(string(medadesao.titvljur + medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" medadesao.dtinc "de R$" trim(string(medadesao.titvljur + medadesao.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(medadesao.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field medadesao.idAdesao
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail ttrepasse
                    then leave.
                    recatu1 = recid(ttrepasse).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttrepasse
                    then leave.
                    recatu1 = recid(ttrepasse).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttrepasse
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttrepasse
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             if esqcom1[esqpos1] = "cancela"
             then do: 
                hide message no-pause.
                sresp = no.
                message "Confirma cancelamento adesao numero " medadesao.idadesao "?"
                    update sresp.
                if sresp
                then do:
                    run api/medcancelaadesao.p (recid(medadesao)).
                    leave.
                end.
            end.
             if esqcom1[esqpos1] = " csv "
             then do: 
                run geraCSV.
            end.
            
            if esqcom1[esqpos1] = "conteudo"
            then do:
                pause 0.
                run med/tmedadedados.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
            if esqcom1[esqpos1] = "repasses"
            then do:
                pause 0.
                run med/tmedaderepasse.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.

            if esqcom1[esqpos1] = "historico"
            then do:
                pause 0.
                run  med/tmedadecanc.p (recid(medadesao)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttrepasse).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
    find medaderepasse where recid(medaderepasse) = ttrepasse.rec no-lock.
    find medadesao of medaderepasse no-lock.
    find first medadedados of medadesao where medadedados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vclinom = if avail medadedados then medadedados.conteudo else "-".
    display  
        vclinom
        medadesao.dataTransacao 
        medaderepasse.dtvenc 
        medadesao.etbcod 
        medadesao.cpf    
        vclinom  
        medadesao.idAdesao  
        medaderepasse.vlrepasse 
        medadesao.dtcanc 
        ttrepasse.qtdrepasse column-label "qt"

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        vclinom
        medadesao.dataTransacao 
        medaderepasse.dtvenc 
        medadesao.etbcod 
        medadesao.cpf    
        vclinom  
        medadesao.idAdesao  
        medaderepasse.vlrepasse 
        medadesao.dtcanc 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        vclinom
        medadesao.dataTransacao 
        medaderepasse.dtvenc 
        medadesao.etbcod 
        medadesao.cpf    
        vclinom  
        medadesao.idAdesao  
        medaderepasse.vlrepasse 
        medadesao.dtcanc 
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        vclinom
        medadesao.dataTransacao 
        medaderepasse.dtvenc 
        medadesao.etbcod 
        medadesao.cpf    
        vclinom  
        medadesao.idAdesao  
        medaderepasse.vlrepasse 
        medadesao.dtcanc 
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttrepasse 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttrepasse 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttrepasse
            no-lock no-error.

    end.  
        
end procedure.







procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/medrepasses_MES_" + string(vmes,"99") + string(vano,"9999") + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted 
        "CPF ADESAO;NOME CLIENTE LEBES;NOME PACIENTE;DATA VENDA;DATA INICIO VIGENCIA;DATA FIM VIGENCIA;PLANO PGTO;STATUS VENDA;"   
        "DATA CANCELAMENTO;CERTIFICADO;LOJA;VALOR VENDA;MES/ANO REPASSE;VALOR REPASSE;VENDEDOR;PDV;NSU;QTD REP"
        skip.
    for each ttrepasse.
        find medaderepasse where recid(medaderepasse) = ttrepasse.rec no-lock.
        run geraCsvImp.
    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    
end procedure.

procedure geraCsvImp.
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".

        
def var vnomecliente    as char.        
def var vnomepaciente   as char.
def var vstatus         as char.
def var vvlrrepasse     as dec.
def var vvendedor       as char.
def var vcxacod         as int.
def var vdtinivig       as date.
def var vdtfimvig       as date.

    find medadesao of medaderepasse no-lock.
    find medadedados of medadesao where medadedados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.
    find medadedados of medadesao where medadedados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail medadedados 
        then date(int(entry(2,medadedados.conteudo,"-")), int(entry(3,medadedados.conteudo,"-")),int(entry(1,medadedados.conteudo,"-")))
        else ?.

    find medadedados of medadesao where medadedados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail medadedados then medadedados.conteudo else "".

    release clien.
    if medadesao.clicod <> 0 and medadesao.clicod <> ?
    then do:
        find clien where clien.clicod = medadesao.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    
    vstatus = if medadesao.dtcanc = ? then "ATIVA" else if medadesao.dtcanc - medadesao.datatransacao <= 8 then "ANULADO" else "CANCELADA". 
    
    find medadedados of medadesao where medadedados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = if avail medadedados
                then medadedados.conteudo + "-" 
                else "".
    find func where func.etbcod = medadesao.etbcod and func.funcod = int(medadedados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of medadesao no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(medadesao.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(medadesao.dataTransacao,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        medadesao.fincod         vcp
        vstatus         vcp
        if medadesao.dtcanc = ? then "" else string(medadesao.dtcanc,"99/99/9999") vcp
        medadesao.idAdesao vcp
        medadesao.etbcod            vcp
        trim(replace(string(medadesao.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        string(vmes,"99") + "/" + string(vano,"9999") vcp 
        trim(replace(string(medaderepasse.vlrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        vvendedor                   vcp
        vcxacod                    vcp
        medadesao.nsuTransacao      vcp
        ttrepasse.qtdrepasse vcp
        skip.
            

end procedure.
 



procedure montatt.

        for each medaderepasse where  
                    medaderepasse.rstatus = yes and 
                    medaderepasse.dtvenc >= vdtini and 
                    medaderepasse.dtvenc <= vdtfim
            no-lock.
            create ttrepasse.
            ttrepasse.dtvenc    = medaderepasse.dtvenc.
            ttrepasse.rec = recid(medaderepasse).
            ttrepasse.qtdrepasse = 0.
            for each b-medaderepasse where b-medaderepasse.idadesao = medaderepasse.idadesao and
                                           b-medaderepasse.dtvenc > vdtfim
                                           no-lock.
                ttrepasse.qtdrepasse = ttrepasse.qtdrepasse + 1.            
            end.                                           
            
        end.    

end procedure.
