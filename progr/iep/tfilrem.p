/* 05012022 helio iepro */

{admcab.i}

def input param poperacao   as char.
def input param ctitle      as char.
def input param copcao      as char.
def output param pacao      as char.
def var xtime as int.
def var vconta as int.
def var pfiltro as char.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(9)" extent 7
    initial ["filtrar","contrato","parcelas","marca","todos","enviar","digitar"].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer btitulo for titulo.
def var vsel as int.
def var vabe as dec.

{iep/tfilsel.i new}
    
def buffer bttcontrato for ttcontrato.
def var vtitvlcob   like ttcontrato.vlrabe.
def var vvlmar      like ttcontrato.vlrabe.
def var vtitvljur   like ttcontrato.vlrabe.
def var vvlmarjur      like ttcontrato.vlrabe.
def var vtitvltot   like ttcontrato.vlrabe.
def var vvlmartot      like ttcontrato.vlrabe.

    form  
        ttcontrato.marca format "*/ "            column-label "*" space(0)
        contrato.etbcod                         column-label "fil"
        contrato.modcod  format "x(03)"           column-label "mod" space(0)
        contrato.tpcontrato format "x"            column-label "t"
        ttcontrato.clicod                         column-label "cliente"

        ttcontrato.nossonumero 
        ttcontrato.titdtemi format "999999"         column-label "dtemi"
        
        ttcontrato.titdtven format "999999"         column-label "venc"
        
        ttcontrato.diasatraso column-label "d atr"     format "-99999"
        ttcontrato.vlratr      column-label "vl atras"    format ">>>>9.99" 
/*        ttcontrato.vlrjur      column-label "vl juros"    format ">>>>9.99" */
        ttcontrato.vlrdiv      column-label "vl divid"    format ">>>>>9.99" 

        with frame frame-a 9 down centered row 7
        no-box.




disp 
    ctitle format "x(60)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.


create ttfiltros.

if copcao = "Filtro"
then do:
    esqcom1[1] = "filtrar".
    run iep/tfilsel.p (input poperacao).
    find first ttcontrato no-error.
    if not avail ttcontrato
    then return.
end.
if copcao = "arquivo csv"
then do:
    esqcom1[1] = "".
    run iep/tremarq.p (poperacao).
end.
if copcao = "digitar"
then do:
    esqcom1[1] = "".
    run digitaContrato.
end.



disp 
    vtitvlcob    label "filtrado"      format "zzzzzzzz9.99" colon 15
    vtitvljur    label "juros"      format "zzzzzzzz9.99" colon 35
    vtitvltot    label "total"      format "zzzzzzzz9.99" colon 65
    
    vvlmar       label "marcado"       format "zzzzzzzz9.99" colon 15
     vvlmarjur    label "juros"       format "zzzzzzzz9.99" colon 35
    vvlmartot    label "total"       format "zzzzzzzz9.99" colon 65
    
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    
   vtitvlcob = 0. vvlmar = 0.      
   vtitvljur = 0. vvlmarjur = 0.      
   vtitvltot = 0. vvlmartot = 0.      
   
   for each ttcontrato .
        vtitvlcob = vtitvlcob + ttcontrato.vlratr.
        vtitvljur = vtitvljur + ttcontrato.vlrjur.
        vtitvltot = vtitvltot + ttcontrato.vlrdiv.
        
        if ttcontrato.marca
        then do:
            vvlmar      = vvlmar    + ttcontrato.vlratr.
            vvlmarjur   = vvlmarjur + ttcontrato.vlrjur.
            vvlmartot   = vvlmartot + ttcontrato.vlrdiv.
        end.    

   end.
    disp
        vtitvlcob
        vtitvljur vtitvltot
        vvlmar
        vvlmarjur vvlmartot
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then do.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcontrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcontrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcontrato where recid(ttcontrato) = recatu1 no-lock.

        status default "".
        
                        
                     
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
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field ttcontrato.nossonumero
            help "Selecione a opcao" 

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 7 then 7 else esqpos1 + 1.
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
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcontrato
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
                /**
            if keyfunction(lastkey) = "L" or
               keyfunction(lastkey) = "l"
            then do:
                hide frame fcab no-pause.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.                
                run fin/fqanadoc.p 
                        (   ctitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttcontrato.ctmcod,
                            contrato.modcod,
                            contrato.tpcontrato,
                            ttcontrato.etbcod,
                            ttcontrato.cobcod).

                leave.
            end.

                **/
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = "digitar"
            then do:
                run digitaContrato.
                disp 
                    ctitle format "x(60)" no-label
                        with frame ftit.

                recatu1 = ?.
                leave.
            end.
            
            if esqcom1[esqpos1] = "filtrar"
            then do:
                run iep/tfilsel.p (input poperacao).
                
                disp 
                    ctitle format "x(60)" no-label
                        with frame ftit.
                
                recatu1 = ?. 
                leave.
            end.            

            if esqcom1[esqpos1] = "contrato"
            then do:
                run conco_v1701.p (string(ttcontrato.contnum)).
                disp 
                    ctitle format "x(60)" no-label
                        with frame ftit.
                
            end.
            if esqcom1[esqpos1] = "parcelas"
            then do:
                run iep/tfilremparc.p (recid(ttcontrato)).
                disp 
                    ctitle format "x(60)" no-label
                        with frame ftit.
                
            end.


            if esqcom1[esqpos1] = "marca"
            then do:
                if ttcontrato.marca
                then do:
                    vvlmar      = vvlmar    - ttcontrato.vlratr.
                    vvlmarjur   = vvlmarjur - ttcontrato.vlrjur.
                    vvlmartot   = vvlmartot - ttcontrato.vlrdiv.

                    
                end.    
                else do:
                    vvlmar      = vvlmar    + ttcontrato.vlratr.
                    vvlmarjur   = vvlmarjur + ttcontrato.vlrjur.
                    vvlmartot   = vvlmartot + ttcontrato.vlrdiv.

                    
                end.    
                disp vvlmar vvlmarjur vvlmartot with frame ftot.
                ttcontrato.marca = not ttcontrato.marca.
                disp ttcontrato.marca with frame frame-a. 
                
                next.
            end.
            if esqcom1[esqpos1] = "todos"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttcontrato.marca.
                for each bttcontrato.
                    bttcontrato.marca = not vmarca.
                end.
                leave.
            end.

            if esqcom1[esqpos1] = "enviar"
            then do: 
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1] with frame f-com1.

                do with frame fcab
                        row 6 centered
                    side-labels overlay
                    title " ENVIO ".

                    /*** retirado arrasto por enquanto
                    update  skip(1)
                            ttfiltros.arrastaparcelasvencidas        label "ARRASTO NO MESMO CONTRATO - todas as parcelas          ?"    colon 60.
                    if ttfiltros.arrastaparcelasvencidas = yes
                    then ttfiltros.arrastaparcelas = no.
                    else do:
                        update            
                            ttfiltros.arrastaparcelas                label "                          - todas as parcelas vencidas ?"    colon 60.
                    end.
                    update  skip(1)
                            ttfiltros.arrastacontratosvencidos        label "ARRASTO OUTROS CONTRATOS  - todos os contratos         ?"    colon 60.
                    if ttfiltros.arrastacontratosvencidos = yes
                    then ttfiltros.arrastacontratos = no.
                    else do:
                        update            
                            ttfiltros.arrastacontratos               label "                             todos os contratos vencidos?"    colon 60
                            skip(1).
                    end.
                    ***/
                    /*
                    message "confirma enviar registros macados para " poperacao "?" update sresp.*/
                            sresp = ?.
                    run sys/message.p (input-output sresp,
                           input "CONFIRMACAO" +
                                 " MODO DE ENVIO",
                                   input " !! selecione !! ",
                                   input "    API",
                                   input "    ARQUIVO").
                    pacao = "REMESSA".
                    if sresp
                    then run iep/ptitpenvia.p (input poperacao, pacao).
                    if sresp = no
                    then do:
                        pacao = "ARQUIVO".
                      run iep/ptitpenvia.p (input poperacao, pacao).
                    end.  
                    
                    
                    return.
                end.
            end.

                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcontrato).
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
    find contrato where contrato.contnum = ttcontrato.contnum no-lock.
    
    display  
        ttcontrato.marca 
        contrato.etbcod 
        contrato.modcod 
        contrato.tpcontrato 
        ttcontrato.nossonumero 
        ttcontrato.clicod 
        ttcontrato.titdtemi
        ttcontrato.titdtven 
        ttcontrato.diasatraso 
        
        ttcontrato.vlratr
/*        ttcontrato.vlrjur  */
        ttcontrato.vlrdiv  
        
        with frame frame-a.

end procedure.

procedure color-message.
    color display message

        ttcontrato.marca 
        contrato.etbcod 
        contrato.modcod 
        contrato.tpcontrato 
        ttcontrato.nossonumero 
        ttcontrato.clicod 
        ttcontrato.titdtemi
        ttcontrato.titdtven 
        ttcontrato.diasatraso 
        
        ttcontrato.vlratr
/*        ttcontrato.vlrjur  */
        ttcontrato.vlrdiv  
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.marca 
        contrato.etbcod 
        contrato.modcod 
        contrato.tpcontrato 
        ttcontrato.nossonumero 
        ttcontrato.clicod 
        ttcontrato.titdtemi
        ttcontrato.titdtven 
        ttcontrato.diasatraso 
        
        ttcontrato.vlratr
/*        ttcontrato.vlrjur  */
        ttcontrato.vlrdiv  
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.marca 
        contrato.etbcod 
        contrato.modcod 
        contrato.tpcontrato 
        ttcontrato.nossonumero 
        ttcontrato.clicod 
        ttcontrato.titdtemi        ttcontrato.titdtven 
        ttcontrato.diasatraso 
        
        ttcontrato.vlratr
/*        ttcontrato.vlrjur  */
        ttcontrato.vlrdiv  

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttcontrato where
            no-lock no-error.
    end.
    else do:
        find first ttcontrato
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttcontrato where
            no-lock no-error.
    end.
    else do:
        find next ttcontrato
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttcontrato where
            no-lock no-error.
    end.
    else do:
        find prev ttcontrato
            no-lock no-error.
    end.    

end.    
        
end procedure.



procedure digitaContrato.

do on error undo:
    
    prompt-for ttcontrato.contnum format ">>>>>>>>>>9" 
        with frame fcontr
        centered row 10
        overlay side-labels.

    find contrato where contrato.contnum = input ttcontrato.contnum no-lock no-error.
    if not avail contrato
    then do:
        message "Contrato nao Cadastrado.".
        undo.
    end.    

    run iep/pavalctrsel.p   (poperacao, contrato.contnum,yes,input-output vsel, input-output vabe).
    
end.

end procedure.



