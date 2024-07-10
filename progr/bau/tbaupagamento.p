/* medico na tela 042022 - helio */

{admcab.i}

def input param psituacao   as char.
def input param ptipoPagamento as char.
def input param ctitle      as char.

def var pcpf        as dec format "99999999999".             
def var vdias as int.

def buffer bestab for estab.
 
def temp-table ttpagamento no-undo
    field rec as recid.
    
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcelas","dados"," csv",""].

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
    baupagamento.tipoPagamento
        baupagamento.etbcod column-label "fil" format ">>9"
        baupagamento.cpf                         column-label "cpf" format "99999999999"
        vclinom  format "x(15)" column-label "cliente"
        baupagamento.idpagamento  column-label "id" format ">>>>9"
        baupagamento.valorServico  column-label "vlr" format ">>>>9.99"
        baupagamento.dataTransacao column-label "dt venda" format "99999999"
        baupagamento.contnum   format ">>>>>>>>9"
/*        baupagamento.dtcanc      column-label "dt canc"   format "99999999" */
 
        
        with frame frame-a 9 down centered row 7
        no-box.


if true
then do:

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

    vdtini = date(month(today),01,year(today)).
    vdtfim = today.

    update
        vdtini
        vdtfim
        with frame fperiodo
        centered row 5
        side-labels.
        
   ctitle = ctitle + " / periodo: " + string(vdtini,"99/99/9999") + " a " + string(vdtfim,"99/99/9999").

end.    
else do:
    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



      update pcpf label "cpf"
            with frame fremessa
            row 9 centered side-labels overlay.

    ctitle = ctitle + " / Cliente: " + string(pcpf).
end.
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

empty temp-table ttpagamento.
run montatt.

bl-princ:
repeat:
    
   vtotservico = 0.
    for each ttpagamento.

        find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock. 
        vtotservico = vtotservico + baupagamento.valorServico.
    end.
           
    disp
        vtotservico
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttpagamento where recid(ttpagamento) = recatu1 no-lock.
    if not available ttpagamento
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttpagamento).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttpagamento
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttpagamento where recid(ttpagamento) = recatu1 no-lock.
        find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock.

        esqcom1[3] = if psituacao = "Conciliacao" then "arquivo" else if psituacao = "repasse" then "Repasse" else "csv". 

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
    if baupagamento.titdescjur <> 0
    then do:
        if baupagamento.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" baupagamento.dtinc "de R$" trim(string(baupagamento.titvljur + baupagamento.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(baupagamento.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" baupagamento.dtinc "de R$" trim(string(baupagamento.titvljur + baupagamento.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(baupagamento.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field baupagamento.idpagamento
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
                    if not avail ttpagamento
                    then leave.
                    recatu1 = recid(ttpagamento).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttpagamento
                    then leave.
                    recatu1 = recid(ttpagamento).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttpagamento
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttpagamento
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             /*if esqcom1[esqpos1] = "cancela"
             then do: 
                hide message no-pause.
                sresp = no.
                message "Confirma cancelamento adesao numero " baupagamento.idpagamento "?"
                    update sresp.
                if sresp
                then do:
                    run api/medcancelaadesao.p (recid(baupagamento)).
                    leave.
                end.
            end.
            */
            
             if esqcom1[esqpos1] = " csv "
             then do: 
                sresp = yes.
                message "confirma gerar arquivo csv?" update sresp.
                if sresp
                then run geraCSV.
            end.
             if esqcom1[esqpos1] = "arquivo"
             then do: 
                sresp = yes.
                message "confirma gerar arquivo conciliacao?" update sresp.
                if sresp
                then run geraARQUIVO.
             end.
             if esqcom1[esqpos1] = "repasse"
             then do: 
                 run prepasse.
             end.
             
            
            if esqcom1[esqpos1] = "dados"
            then do:
                pause 0.
                run bau/tbaupagdados.p (recid(baupagamento)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
            if esqcom1[esqpos1] = "parcelas"
            then do:
                pause 0.
                run bau/tbaupagparcelas.p (recid(baupagamento)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.

            if esqcom1[esqpos1] = "historico"
            then do:
                pause 0.
                run  med/tmedadecanc.p (recid(baupagamento)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttpagamento).
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
    find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock.
    find first baupagdados of baupagamento where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vclinom = if avail baupagdados then baupagdados.conteudo else "-".
    display  
    baupagamento.tipoPagamento
        vclinom
        baupagamento.cpf  

        baupagamento.idpagamento
        baupagamento.valorServico 
        baupagamento.dataTransacao
        baupagamento.contnum        when contnum <> 0
/*        baupagamento.dtcanc   */
        baupagamento.etbcod


        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    baupagamento.tipoPagamento
        vclinom
        baupagamento.cpf  

        baupagamento.idpagamento
        baupagamento.valorServico 
        baupagamento.dataTransacao
        
/*        baupagamento.dtcanc  */
        baupagamento.etbcod
        baupagamento.contnum        


                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    baupagamento.tipoPagamento
        vclinom
        baupagamento.cpf  

        baupagamento.idpagamento
        baupagamento.valorServico 
        baupagamento.dataTransacao
        
/*        baupagamento.dtcanc  */
        baupagamento.etbcod
        baupagamento.contnum        

                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    baupagamento.tipoPagamento
        vclinom
        baupagamento.cpf  

        baupagamento.idpagamento
        baupagamento.valorServico 
        baupagamento.dataTransacao
        
/*        baupagamento.dtcanc  */
        baupagamento.etbcod

        baupagamento.contnum        
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttpagamento 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttpagamento 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttpagamento
            no-lock no-error.

    end.  
        
end procedure.







procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/baupagamento_" + lc(psituacao) + "_" + 
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
        "DATA CANCELAMENTO;CERTIFICADO;LOJA;VALOR VENDA;VALOR REPASSE;VENDEDOR;PDV;NSU;"
        skip.
    for each ttpagamento.
        find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock.
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

    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if baupagamento.clicod <> 0 and baupagamento.clicod <> ?
    then do:
        find clien where clien.clicod = baupagamento.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if baupagamento.dtcanc = ? then "ATIVA" else if baupagamento.dtcanc - baupagamento.datatransacao <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.etbcod = baupagamento.etbcod and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of baupagamento no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(baupagamento.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(baupagamento.dataTransacao,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        baupagamento.fincod         vcp
        vstatus         vcp
        if baupagamento.dtcanc = ? then "" else string(baupagamento.dtcanc,"99/99/9999") vcp
        baupagamento.idpagamento vcp
        baupagamento.etbcod            vcp
        
        trim(replace(string(baupagamento.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        baupagamento.nsuTransacao      vcp
        skip.
            

end procedure.
 



procedure montatt.
    message psituacao ptipoPagamento vdtini vdtfim .
    
    if psituacao = "VENDAS"
    then do:
        for each baupagamento where  baupagamento.tipoPagamento = ptipoPagamento and
                                  baupagamento.dataTransacao >= vdtini and
                                  baupagamento.dataTransacao <= vdtfim
            no-lock.
            create ttpagamento.
            ttpagamento.rec = recid(baupagamento).
        end.    
    end.
    
    if psituacao = "CONCILIACAO" or  psituacao = "REPASSE"
    then do:
        for each baupagamento where 
                                  baupagamento.dtcanc        = ? and
                                  baupagamento.dataTransacao >= vdtini and
                                  baupagamento.dataTransacao <= vdtfim
            no-lock.
            create ttpagamento.
            ttpagamento.rec = recid(baupagamento).
        end.    
    end.
    
    if psituacao = "CANCELAMENTOS"
    then do:
       for each baupagamento where  baupagamento.dtcanc >= vdtini and
                                 baupagamento.dtcanc<= vdtfim
                no-lock.
                create ttpagamento.
                ttpagamento.rec = recid(baupagamento).
        end.                                                    
    end.    
    if psituacao = "CLIENTE"
    then do:    
        for each baupagamento where baupagamento.cpf   = pcpf       
            no-lock. 
            create ttpagamento. 
            ttpagamento.rec = recid(baupagamento).
        end.    
    end.    

end procedure.



procedure geraARQUIVO.
def var pordem as int.
def var tqtd as int.
def var tvlr as dec.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/baupahamento_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + "_LEBES.csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.

def var vtipolancamento as char.
message "Aguarde...". 
pause 1 no-message.
def var vdtrepasse as date.
output to value(varqcsv).

    tqtd = 0.
    tvlr = 0.
    for each ttpagamento.
        find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock.
        
        vtipolancamento = if baupagamento.tipoPagamento = "VENDAOUTROS" or 
                             baupagamento.tipoPagamento = "PAGAMENTO"
                          then "02"
                          else "01".   
        for each baupagparcelas of baupagamento no-lock.                             
            
            /* #06102022 helio - somente parcela 1 eh venda */
            if baupagparcelas.adepar > 1
            then vtipolancamento = "02".

/*
Operação(ões) realizada(s) na Seg repassa na Qui
Operação(ões) realizada(s) na Ter repassa na Sex
Operação(ões) realizada(s) na Qua repassa na Seg
Operação(ões) realizada(s) na Qui repassa na Ter
Operação(ões) realizada(s) na Sex, Sáb e Dom repassa na Qua

*/
            if weekday(baupagamento.dataTransacao) = 2 /* segunda */
            then vdias = 3.
            if weekday(baupagamento.dataTransacao) = 3 
            then vdias = 3.
            if weekday(baupagamento.dataTransacao) = 4 
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 5 
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 6  
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 7  
            then vdias = 4.
            if weekday(baupagamento.dataTransacao) = 1  
            then vdias = 3.

            vdtrepasse = baupagamento.dataTransacao + vdias.
            
            put unformatted 
                vtipolancamento format "x(2)"
                string(baupagamento.dataTransacao,"99999999")
                string(vdtrepasse,"99999999")
                string(baupagparcelas.valor * 100,">>>>>>9")
                string(int(baupagparcelas.codeLocalPagamento),"999")
                baupagparcelas.codigoBarrasParcela format "x(48)"                
                "" format "x(10)" /*Id da Parcela do Carnê*/
                /* helio 10102022 - alterado o campo de idpagamento para numeroTransacao */
                baupagparcelas.numeroTransacao format "x(30)"
                (if baupagamento.cpf = 0 then "" else string(baupagamento.cpf,"99999999999")) format "x(14)"
                "" format "x(50)" /*Nome Cliente*/
                "" format "x(11)" /* Telefone Cliente*/
                "" format "x(50)" 
                "" format "x(10)" 
                "" format "x(35)" 
                "" format "x(40)" 
                "" format "x(35)"
                "" format "x(2)" 
                "" format "x(8)" 
                "" format "x(10)"
                skip.
            tqtd = tqtd + 1.
            tvlr = tvlr + baupagparcelas.valor.
                                
        end.
    end.
    put unformatted
        "04" format "x(2)"
        string(today,"99999999")
        string(tqtd,">>>>>>>>>>>>>>9")
        string(tvlr  * 100,"99999999999999999999999999999999999999999999999999")
        skip.
        
    output close.

                        
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    


end procedure.


procedure geraCsvImpx.
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

    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if baupagamento.clicod <> 0 and baupagamento.clicod <> ?
    then do:
        find clien where clien.clicod = baupagamento.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if baupagamento.dtcanc = ? then "ATIVA" else if baupagamento.dtcanc - baupagamento.datatransacao <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of baupagamento where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.etbcod = baupagamento.etbcod and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of baupagamento no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(baupagamento.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(baupagamento.dataTransacao,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        baupagamento.fincod         vcp
        vstatus         vcp
        if baupagamento.dtcanc = ? then "" else string(baupagamento.dtcanc,"99/99/9999") vcp
        baupagamento.idpagamento vcp
        baupagamento.etbcod            vcp
        
        trim(replace(string(baupagamento.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        baupagamento.nsuTransacao      vcp
        skip.
            

end procedure.
 




procedure prepasse.

def var vcp as char format "x" init ";".
def var vcomissao as dec.
def var vrepasse  as dec.

def var pordem as int.
def var tqtd as int.
def var tvlr as dec.
def var vdtrepasse as date.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/bau_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + "_LEBES.csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.

def var vtipolancamento as char.
message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted 
"DAT_PAGAMENTO;DAT_REPASSE;"
"NUM_SERIE;NUM_CARNE;NUM_DIGITO;COD_BARRAS_CARNE;OPERACAO;NUM_PARCELA;VAL_PARCELA;COD_LOJA;NOM_LOJA;VAL_COMISSAO_LEBES;VAL_REPASSE_JEQUITI;PROTOCOLO;"
skip.

    tqtd = 0.
    tvlr = 0.
    for each ttpagamento.
        find baupagamento where recid(baupagamento) = ttpagamento.rec no-lock.
        
        vtipolancamento = if baupagamento.tipoPagamento = "VENDAOUTROS" or 
                             baupagamento.tipoPagamento = "PAGAMENTO"
                          then "02"
                          else "01".   
        for each baupagparcelas of baupagamento no-lock.                             
            
            /* #06102022 helio - somente parcela 1 eh venda */
            if baupagparcelas.adepar > 1
            then vtipolancamento = "02".

/*
Segue:   
    VAL_COMISSAO_LEBES  
    Recebimento: R$ 1,40  
    Venda: R$ 9,00    
    VAL_REPASSE_JEQUITI  
    São os valores líquidos.
                  
*/                    
            vcomissao = if  vtipolancamento = "02" then 1.4 else 9.
            vrepasse  = baupagparcelas.valor - vcomissao.
            find bestab where bestab.etbcod = baupagamento.etbcod no-lock.
            
            if weekday(baupagamento.dataTransacao) = 2 /* segunda */
            then vdias = 3.
            if weekday(baupagamento.dataTransacao) = 3 
            then vdias = 3.
            if weekday(baupagamento.dataTransacao) = 4 
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 5 
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 6  
            then vdias = 5.
            if weekday(baupagamento.dataTransacao) = 7  
            then vdias = 4.
            if weekday(baupagamento.dataTransacao) = 1  
            then vdias = 3.

            vdtrepasse = baupagamento.dataTransacao + vdias.
                           
                                                      
            put unformatted 
            
                string(baupagamento.dataTransacao,"99/99/9999") vcp
                string(vdtrepasse,"99/99/9999") vcp
                
                substring(baupagparcelas.codigobarras,1,3)   vcp
                substring(baupagparcelas.codigobarras,4,6)   vcp
                substring(baupagparcelas.codigobarras,10,1)   vcp
                baupagparcelas.codigoBarrasParcela vcp
                if vtipolancamento = "02" then "PAGAMENTO" else "VENDA" vcp
                baupagparcelas.adepar      vcp
                trim(string(baupagparcelas.valor,">>>>>>9.99")) vcp
                baupagamento.etbcod vcp                
                bestab.etbnom   vcp
                trim(string(vcomissao,">>>>>>9.99")) vcp
                trim(string(vrepasse,">>>>>>9.99")) vcp
                baupagparcelas.numeroTransacao vcp                
                /*
                string(baupagamento.dataTransacao + 3,"99999999")
                string(baupagparcelas.valor * 100,">>>>>>9")
                string(int(baupagparcelas.codeLocalPagamento),"999")
                baupagparcelas.numeroTransacao format "x(30)"
                */
                
                skip.
            tqtd = tqtd + 1.
            tvlr = tvlr + baupagparcelas.valor.
                                
        end.
    end.
    /*
    put unformatted
        "04" format "x(2)"
        string(today,"99999999")
        string(tqtd,">>>>>>>>>>>>>>9")
        string(tvlr  * 100,"99999999999999999999999999999999999999999999999999")
        skip.
    */
        
    output close.

                        
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    


end procedure.


 




