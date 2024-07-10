/* reversa 092022 - helio */

{admcab.i}

def input param psituacao   as char.
def input param ctitle      as char.

def var petbcod as int.
def temp-table ttreversa no-undo
    field rec as recid
    field codCaixa like reversalojas.codcaixa
    index x codcaixa asc.
    
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["conteudo",""," ",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.

def var vdtini as date format "99/99/9999" label "de".
def var vdtfim as date format "99/99/9999" label "ate".

    form  
        reversalojas.etbcod column-label "fil" format ">>9"
        reversalojas.codCaixa  column-label "caixa"
        reversalojas.etbdest  column-label "dest" format ">>9"
        reversalojas.dtalt column-label "dt digt " format "99999999"
        reversalojas.hralt column-label "hr digt " format "99999999"
        
        reversalojas.catcod    column-label "cat" format ">>9"
        reversalojas.dtfec  column-label "fecham" format "99999999"
        reversalojas.idPedidoGerado  format "x(14)"
        reversalojas.piduso format ">>>>>9"        
        with frame frame-a 9 down centered row 7
        no-box.


if psituacao = "ABERTAS" or psituacao = "FECHADAS"
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

    if setbcod = 999
    then do:
        update petbcod label "estab"
            with frame fperiodo.
    end.
    else do:
        petbcod = setbcod.
        disp petbcod with frame fperiodo.
    end.

    update
        vdtini
        vdtfim
        with frame fperiodo
        centered row 5
        side-labels.
        
   ctitle = ctitle + " / periodo: " + string(vdtini,"99/99/9999") + " a " + string(vdtfim,"99/99/9999").

end.    
disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



empty temp-table ttreversa.
run montatt.
recatu1 = ?.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttreversa where recid(ttreversa) = recatu1 no-lock.
    if not available ttreversa
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttreversa).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttreversa
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttreversa where recid(ttreversa) = recatu1 no-lock.
        find reversalojas where recid(reversalojas) = ttreversa.rec no-lock.

/*         esqcom1[2] = if reversalojas.dtcanc = ? then "cancela" else "". */
        esqcom1[5] = " ". 
        esqcom1[3] = "". 
/*        esqcom1[4] = "historico". */

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
    if reversalojas.titdescjur <> 0
    then do:
        if reversalojas.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" reversalojas.dtinc "de R$" trim(string(reversalojas.titvljur + reversalojas.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(reversalojas.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" reversalojas.dtinc "de R$" trim(string(reversalojas.titvljur + reversalojas.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(reversalojas.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field reversalojas.etbdest
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
                    if not avail ttreversa
                    then leave.
                    recatu1 = recid(ttreversa).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttreversa
                    then leave.
                    recatu1 = recid(ttreversa).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttreversa
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttreversa
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
                message "Confirma cancelamento adesao numero " reversalojas.etbdest "?"
                    update sresp.
                if sresp
                then do:
                    run api/medcancelaadesao.p (recid(reversalojas)).
                    leave.
                end.
            end.
            */
            
             if esqcom1[esqpos1] = " csv "
             then do: 
                run geraCSV.
            end.
            
            if esqcom1[esqpos1] = "conteudo"
            then do:
                pause 0.
                run loj/treversaprodu.p (recid(reversalojas)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.

            if esqcom1[esqpos1] = "historico"
            then do:
                pause 0.
                run  med/tmedadecanc.p (recid(reversalojas)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttreversa).
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
    find reversalojas where recid(reversalojas) = ttreversa.rec no-lock.
    display  
        reversalojas.etbcod
        reversalojas.codCaixa
        reversalojas.etbdest
        reversalojas.dtalt
        string(reversalojas.hralt,"HH:MM:SS") @ reversalojas.hralt
        reversalojas.catcod  
        reversalojas.dtfec 
        reversalojas.idPedidoGerado  
        reversalojas.piduso 

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        reversalojas.etbcod
        reversalojas.codCaixa
        reversalojas.etbdest
        reversalojas.dtalt
        reversalojas.catcod  
        reversalojas.dtfec 
        reversalojas.idPedidoGerado  
        reversalojas.piduso 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        reversalojas.etbcod
        reversalojas.codCaixa
        reversalojas.etbdest
        reversalojas.dtalt
        reversalojas.catcod  
        reversalojas.dtfec 
        reversalojas.idPedidoGerado  
        reversalojas.piduso 
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        reversalojas.etbcod
        reversalojas.codCaixa
        reversalojas.etbdest
        reversalojas.dtalt
        reversalojas.catcod  
        reversalojas.dtfec 
        reversalojas.idPedidoGerado  
        reversalojas.piduso 
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttreversa 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttreversa 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttreversa
            no-lock no-error.

    end.  
        
end procedure.





/**

procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/reversalojas_" + lc(psituacao) + "_" + 
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
    for each ttreversa.
        find reversalojas where recid(reversalojas) = ttreversa.rec no-lock.
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

    find baupagdados of reversalojas where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of reversalojas where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of reversalojas where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if reversalojas.clicod <> 0 and reversalojas.clicod <> ?
    then do:
        find clien where clien.clicod = reversalojas.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if reversalojas.dtcanc = ? then "ATIVA" else if reversalojas.dtcanc - reversalojas.dtalt <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of reversalojas where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.etbcod = reversalojas.etbcod and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of reversalojas no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(reversalojas.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(reversalojas.dtalt,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        reversalojas.fincod         vcp
        vstatus         vcp
        if reversalojas.dtcanc = ? then "" else string(reversalojas.dtcanc,"99/99/9999") vcp
        reversalojas.etbdest vcp
        reversalojas.etbcod            vcp
        
        trim(replace(string(reversalojas.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        reversalojas.nsuTransacao      vcp
        skip.
            

end procedure.
 

**/

procedure montatt.
    
    if psituacao = "ABERTAS"
    then do:
        for each reversalojas where  reversalojas.etbcod = petbcod and
                                     reversalojas.dtfec  = ? and
                                     reversalojas.dtalt >= vdtini and
                                     reversalojas.dtalt <= vdtfim
            no-lock.
            create ttreversa.
            ttreversa.rec = recid(reversalojas).
            ttreversa.codcaixa = reversalojas.codcaixa.
        end.    
    end.
    if psituacao = "FECHADAS"
    then do:
        for each reversalojas where  reversalojas.etbcod = petbcod and
                                     reversalojas.dtfec >= vdtini and
                                     reversalojas.dtfec <= vdtfim
            no-lock.
            create ttreversa.
            ttreversa.rec = recid(reversalojas).
            ttreversa.codcaixa = reversalojas.codcaixa.

        end.    

    end.    

end procedure.
