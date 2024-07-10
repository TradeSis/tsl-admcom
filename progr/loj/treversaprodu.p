/* reversa 092022 - helio */

{admcab.i}

def input param precCaixa   as recid.


def var ctitle as char.



def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["","","","",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

form
        reversaprodu.seq format ">>>9" column-label "seq"
        reversaprodu.procod column-label "codigo" format ">>>>>>>>9"
        produ.pronom column-label "nome produto" format "x(20)"
        reversaprodu.qtd format ">>>9" column-label "qtd"

        with frame frame-a 7 down centered row 10
        no-box.

find reversalojas where recid(reversalojas) = preccaixa no-lock.

ctitle = "caixas " + string(reversalojas.codCaixa) + "    - REVERSA".

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



recatu1 = ?.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find reversaprodu where recid(reversaprodu) = recatu1 no-lock.
    if not available reversaprodu
    then do.
         return.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(reversaprodu).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available reversaprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find reversaprodu where recid(reversaprodu) = recatu1 no-lock.


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
    if reversaprodu.titdescjur <> 0
    then do:
        if reversaprodu.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" reversaprodu.dtinc "de R$" trim(string(reversaprodu.titvljur + reversaprodu.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(reversaprodu.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" reversaprodu.dtinc "de R$" trim(string(reversaprodu.titvljur + reversaprodu.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(reversaprodu.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field reversaprodu.seq
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
                    if not avail reversaprodu
                    then leave.
                    recatu1 = recid(reversaprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail reversaprodu
                    then leave.
                    recatu1 = recid(reversaprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail reversaprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail reversaprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
            
            
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(reversaprodu).
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
    find produ where produ.procod = reversaprodu.procod no-lock no-error.
    display  
        reversaprodu.seq
        produ.pronom when avail produ
        reversaprodu.procod
        reversaprodu.qtd
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        reversaprodu.seq
        produ.pronom 
        reversaprodu.procod
        reversaprodu.qtd
    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        reversaprodu.seq
        produ.pronom 
        reversaprodu.procod
        reversaprodu.qtd
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        reversaprodu.seq
        produ.pronom 
        reversaprodu.procod
        reversaprodu.qtd
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last reversaprodu of reversalojas
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev reversaprodu of reversalojas

            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next reversaprodu of reversalojas

            no-lock no-error.

    end.  
        
end procedure.





/**

procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/reversaprodu_" + lc(psituacao) + "_" + 
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
    for each reversaprodu.
        find reversaprodu where recid(reversaprodu) = reversaprodu.rec no-lock.
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

    find baupagdados of reversaprodu where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of reversaprodu where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of reversaprodu where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if reversaprodu.clicod <> 0 and reversaprodu.clicod <> ?
    then do:
        find clien where clien.clicod = reversaprodu.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if reversaprodu.dtcanc = ? then "ATIVA" else if reversaprodu.dtcanc - reversaprodu.dtalt <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of reversaprodu where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.estabOrigem = reversaprodu.estabOrigem and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of reversaprodu no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(reversaprodu.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(reversaprodu.dtalt,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        reversaprodu.fincod         vcp
        vstatus         vcp
        if reversaprodu.dtcanc = ? then "" else string(reversaprodu.dtcanc,"99/99/9999") vcp
        reversaprodu.etbdest vcp
        reversaprodu.estabOrigem            vcp
        
        trim(replace(string(reversaprodu.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        reversaprodu.nsuTransacao      vcp
        skip.
            

end procedure.
 

**/




