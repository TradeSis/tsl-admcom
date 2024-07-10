/* 04082021 helio - novo PRZMED */


{admcab.i}

def input param prectotal as recid.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [""].

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer bctbprzmprodtotal  for ctbprzmprod.

find bctbprzmprodtotal where recid(bctbprzmprodtotal) = prectotal no-lock. 

    disp  
        bctbprzmprodtotal.pstatus column-label "Status"
        bctbprzmprodtotal.dtiniper column-label "Periodo!De"
        bctbprzmprodtotal.dtfimper column-label " !Ate"
        bctbprzmprodtotal.dtiniproc column-label "Proces!Inicio"
        bctbprzmprodtotal.hriniproc format "99999" column-label "Hr"
        bctbprzmprodtotal.hrfimproc format "99999" column-label "Tempo"
        bctbprzmprodtotal.qtdPC column-label "Qtd Reg"
        with frame frame-t 1 down centered row 3 color messages no-box no-underline.


    form  
        ctbprzmprod.campo      column-label ""
        ctbprzmprod.valorcampo column-label ""
        ctbprzmprod.vlrPago    column-label "Total!Pago"
        ctbprzmprod.przMedio   column-label "Prazo!Medio"
        ctbprzmprod.qtdPC column-label "Qtd!Pc"
        with frame frame-a 9 down centered row 7
        title bctbprzmprodtotal.pparametros.

bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.
    if not available ctbprzmprod
    then do.
            return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ctbprzmprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ctbprzmprod
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.

        status default "".

            esqcom1[1] = " Csv".

        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 5.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 5.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field ctbprzmprod.campo

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
                      
                       run color-normal.
        pause 0. 

                                                                
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
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
            

        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = " csv"
            then do:
                run geracsv.
            end.
            
        
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ctbprzmprod).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    
        disp 
        ctbprzmprod.campo      
        ctbprzmprod.valorcampo 
        ctbprzmprod.vlrPago  
        ctbprzmprod.przMedio  
        ctbprzmprod.qtdpc  

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ctbprzmprod.campo      
        ctbprzmprod.valorcampo 
        ctbprzmprod.vlrPago  
        ctbprzmprod.przMedio  
        ctbprzmprod.qtdpc  
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
                ctbprzmprod.campo      
        ctbprzmprod.valorcampo 
        ctbprzmprod.vlrPago  
        ctbprzmprod.przMedio  
                ctbprzmprod.qtdpc  

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ctbprzmprod where 
                ctbprzmprod.dtiniper = bctbprzmprodtotal.dtiniper and
                ctbprzmprod.dtfimper = bctbprzmprodtotal.dtfimper
            no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ctbprzmprod where  
                ctbprzmprod.dtiniper = bctbprzmprodtotal.dtiniper and
                ctbprzmprod.dtfimper = bctbprzmprodtotal.dtfimper
            no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ctbprzmprod where  
                ctbprzmprod.dtiniper = bctbprzmprodtotal.dtiniper and
                ctbprzmprod.dtfimper = bctbprzmprodtotal.dtfimper
            no-lock no-error.
end.    
        
end procedure.




procedure geracsv.
   def var varq as char format "x(76)".
   def var vcp  as char init ";".
def var pdtrefsaida as date.
def var pdtrefini   as date.
def var vmodcod as char.
def var vproduto as char.

   varq = "/admcom/tmp/ctb/przmed" + lc(replace(ctbprzmprod.campo," ","")) +
                             "_" + lc(replace(ctbprzmprod.valorcampo," ","")) + 
                                   string(ctbprzmprod.dtiniper,"99999999") + "_" + 
                                   string(ctbprzmprod.dtfimper,"99999999")  + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM"),":","") +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".

    message "Aguarde... gerando arquivo".
    output to value(varq).    
            
        put unformatted
        "Fililal"   vcp
        "DataMov"  vcp
        "Contrato" vcp
        "Emissao" vcp
        "Parcela" vcp
        "Vencimento" vcp
        "codProp" vcp
        "propriedade" vcp
        "Vlr Nominal" vcp
        "Vlr Juros" vcp
        "Vlr Desconto" vcp
        "Vlr Movimento" vcp                       
        "cliente" vcp 
        "codigoPedido-Ecom" vcp
        
            skip.        
    
    pdtrefsaida    = date(month(ctbprzmprod.dtfimper),01,year(ctbprzmprod.dtfimper)).
    pdtrefini      = date(month(ctbprzmprod.dtiniper),01,year(ctbprzmprod.dtiniper)).

    for each ctbposhiscart where ctbposhiscart.dtrefsaida >= pdtrefini and ctbposhiscart.dtrefsaida <=  pdtrefSAIDA no-lock.
        if operacaoSAIDA = "pagamento" then. else next.
         
        find titulo where recid(titulo) = ctbposhiscart.trecid no-lock no-error.
        if avail titulo
        then do:
            if titulo.titdtpag <> ?
            then do:
                if titulo.titdtpag >= ctbprzmprod.dtiniper and
                   titulo.titdtpag <= ctbprzmprod.dtfimper
                then.
                else do:
                    next.
                end.    
            end.
            else do:
                next.
            end.    
        end.
        else do:
            next.
        end.    

        if ctbprzmprod.campo = "PRODUTO"
        then do:
            if ctbposhiscart.produto = ""
            then do:
                find ctbpostitprod where ctbpostitprod.contnum = ctbposhiscart.contnum no-lock no-error.
                vproduto = if avail ctbpostitprod then ctbpostitprod.produto else "NAO CONHECIDO".
                if vproduto = "DESCONHECIDO" and ctbposhiscart.tpcontrato <> "" then vproduto = ctbposhiscart.tpcontrato + "OVACAO".
            end.
            else do:
                vproduto = ctbposhiscart.produto.
                if vproduto = "DESCONHECIDO" and ctbposhiscart.tpcontrato <> "" then vproduto = ctbposhiscart.tpcontrato + "OVACAO".
            end. 
            if vproduto <> ctbprzmprod.valorcampo
            then next.
        end.
  
        if ctbprzmprod.campo = "MODALIDADE"
        then do:
            vmodcod = if ctbposhiscart.tpcontrato <> "" and ctbposhiscart.modcod = "CRE"  then "CR" + ctbposhiscart.tpcontrato else ctbposhiscart.modcod.    
            if vmodcod <> ctbprzmprod.valorcampo
            then next.
        end.

        if ctbprzmprod.campo = "FILIAL"
        then do: 
            if ctbposhiscart.etbcod <> int(ctbprzmprod.valorcampo)
            then next.          
        end.
        if ctbprzmprod.campo = "PROPRIEDADE"
        then do:
            find cobra where cobra.cobcod = ctbposhiscart.cobcod no-lock. 
            if ctbprzmprod.valorCampo <> string(ctbposhiscart.cobcod,"99") + "-" + caps(cobra.cobnom)  
            then next.
        end.
                      
              
        find contrato where contrato.contnum  = int(titulo.titnum) no-lock no-error.
        if not avail contrato
        then next.
        find cobra of titulo no-lock.

        find first contrsite where contrsite.contnum = int(titulo.titnum)  no-lock no-error.
    
        put unformatted
        contrato.etbcod   vcp
        titulo.titdtpag format "99/99/9999" vcp
        titulo.titnum vcp
        contrato.dtinicial vcp
        titulo.titpar vcp
        titulo.titdtven  vcp
        if avail titulo then titulo.cobcod else ""  vcp
        if avail cobra then cobra.cobnom else "" vcp
                
        titulo.titvlcob vcp
        if titulo.titvlpag > titulo.titvlcob then titulo.titvlpag - titulo.titvlcob else 0   vcp
        0         vcp
        titulo.titvlpag            vcp
        titulo.clifor  vcp
            (if avail contrsite
             then contrsite.codigoPedido
             else "" ) vcp
        
            skip.        
    end.
    
    output close.
    message "gerado com sucesso.".
    pause 1 no-message.
    hide message no-pause.

end procedure.



