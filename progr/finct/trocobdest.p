/* helio 12042023 - ID 155992 Orquestra 465412 - Troca de carteira */
/* 09022023 helio ID 155965 - motivo */
/* 20122021 helio troca carteira */
{admcab.i}

def input param vcobcodori  as int.
def input param vcobcoddes  as int.
def input param par-completo as log.

def var varqout as char format "x(65)".
def var vdtout as date format "99/99/9999".

def buffer dcobra for cobra.
def buffer btitulo for titulo.
def var xtime as int.
def var vconta as int.
def var pfiltro as char.
def var vtitle as char.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<parcelas>","  <marca>","  <todos>"," <trocar>","<digitar>",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def new shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field contnum   like contrato.contnum    format ">>>>>>>>9"
    field dtemi     like contrato.dtinicial
    field vlabe     as dec
    field vlatr     as dec
    field vlpag     as dec
    field cobcod    like titulo.cobcod
    field vlf_principal as dec
    field vlf_acrescimo as dec
    field vlpre         as dec
    field qtdpag        as int
    field diasatraso    as int format "999"
    index contnum is unique primary contnum asc.
def buffer bttcontrato for ttcontrato.

def temp-table ttctbctr no-undo
    field contnum   like contrato.contnum
    field cobcod    like titulo.cobcod
    index idx is unique primary contnum asc cobcod asc.

def var vtitvlcob   like ttcontrato.vlabe.
def var vvlmar      like ttcontrato.vlabe.
    form  
        ttcontrato.marca format "*/ " column-label "*" space(0)
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        contrato.clicod 
        
        ttcontrato.dtemi format "999999" column-label "data"
        contrato.modcod  format "x(03)" column-label "mod" space(0)
        contrato.tpcontrato format "x" column-label "t"
        ttcontrato.cobcod   format ">>" column-label "pr"      
        ttcontrato.vlf_principal column-label "principal" format ">>>>>9.99"
        ttcontrato.vlf_acrescimo column-label "acrescimo" format ">>>>>9.99"
        contrato.txjuros       column-label "tx"     format "->>9.99"
        
        ttcontrato.vlabe      column-label " aberto"    format ">>>>>9.99"
         
        with frame frame-a 9 down centered row 7
        no-box.



find dcobra where dcobra.cobcod = vcobcoddes no-lock.

vtitle =  "RETORNAR PARA CARTEIRA -> " + 
          string(dcobra.cobcod,"99") + "-" + dcobra.cobnom +
          "   (" +
          string(par-completo,"CONTRATO COMPLETO/PARCELAS ABERTAS") + ")".


disp 
    vtitle format "x(60)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

def var varqin as char init ?.

    run finct/trocobcsvarq.p (input par-completo, /* 09022023 helio ID 155965 - programa separado */
                            input vcobcodori,
                           input vcobcoddes,
                           output varqin).



disp 
    vtitvlcob    label "Filtrado"      format "zzzzzzzz9.99" colon 65
    vvlmar       label "Marcado"       format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    
   vtitvlcob = 0.
   vvlmar = 0.      
   for each ttcontrato .
        vtitvlcob = vtitvlcob + ttcontrato.vlabe.
        if ttcontrato.marca
        then do:
            vvlmar      = vvlmar + ttcontrato.vlabe.
        end.    

   end.
    disp
        vtitvlcob
        vvlmar
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then do.
        message "nenhum registro encontrato".
        pause.
        leave.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
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
            
        choose field ttcontrato.dtemi
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
                        (   vtitle + "/" + pfiltro,
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
            
            if esqcom1[esqpos1] = "<digitar>"
            then do:
                run digitaContrato.
                disp 
                    vtitle format "x(60)" no-label
                        with frame ftit.

                recatu1 = ?.
                leave.
            end.
            
            if esqcom1[esqpos1] = "<parcelas>"
            then do:
                run conco_v1701.p (string(ttcontrato.contnum)).
                disp 
                    vtitle format "x(60)" no-label
                        with frame ftit.
                
            end.

            if esqcom1[esqpos1] = "  <marca>"
            then do:
                if ttcontrato.marca
                then do:
                    vvlmar = vvlmar - ttcontrato.vlabe.
                end.    
                else do:
                    vvlmar = vvlmar + ttcontrato.vlabe.
                end.    
                disp  vvlmar with frame ftot.
                ttcontrato.marca = not ttcontrato.marca.
                disp ttcontrato.marca with frame frame-a. 
                
                next.
            end.
            if esqcom1[esqpos1] = "  <todos>"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttcontrato.marca.
                for each bttcontrato.
                    bttcontrato.marca = not vmarca.
                end.
                leave.
            end.
            
            if esqcom1[esqpos1] = " <trocar>"
            then do: 
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1] with frame f-com1.

                    message "confirma trocar a carteira dos contratos para " dcobra.cobcod dcobra.cobnom "?" update sresp.
                    if sresp
                    then do:
                        run trocaCarteira.
                        return.
                    end.
                recatu1 = ?. 
                leave.
                
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
        ttcontrato.dtemi
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        
        contrato.modcod
        contrato.tpcontrato
        ttcontrato.cobcod
        ttcontrato.vlf_principal 
        ttcontrato.vlf_acrescimo
        contrato.txjuros
        ttcontrato.vlabe
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttcontrato.dtemi
                contrato.etbcod 
        contrato.contnum 
        contrato.clicod 

        contrato.modcod 
        contrato.tpcontrato
        ttcontrato.cobcod

        ttcontrato.vlf_principal
        ttcontrato.vlf_acrescimo
        ttcontrato.vlabe
        contrato.txjuros
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.dtemi
                contrato.etbcod 
        contrato.contnum 
        contrato.clicod 

        contrato.modcod 
        contrato.tpcontrato
        ttcontrato.cobcod

        ttcontrato.vlf_principal
        ttcontrato.vlf_acrescimo
        ttcontrato.vlabe
        contrato.txjuros
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.dtemi
                contrato.etbcod 
        contrato.contnum 
        contrato.clicod 

        contrato.modcod 
        contrato.tpcontrato
        ttcontrato.cobcod

        ttcontrato.vlf_principal
        ttcontrato.vlf_acrescimo
        ttcontrato.vlabe
        contrato.txjuros

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
    
    create ttcontrato.
    update ttcontrato.contnum format ">>>>>>>>>>9"
        with frame fcontr
        centered row 10
        overlay side-labels.

    find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
    if not avail contrato
    then do:
        delete ttcontrato.
        message "Contrato nao Cadastrado.".
        undo.
    end.    

    run avaliaContrato.
        
end.

end procedure.


    
procedure avaliaContrato.

do on error undo:

    ttcontrato.dtemi    = contrato.dtinicial.
    ttcontrato.marca    = ?.

    for each btitulo where btitulo.empcod = 19 and btitulo.titnat = no and     
            btitulo.etbcod = contrato.etbcod and btitulo.modcod = contrato.modcod and
            btitulo.clifor = contrato.clicod and btitulo.titnum = string(contrato.contnum)
            no-lock.
        if btitulo.titpar = 0 then next.
        if vcobcodori = 1 
        then do:
            if btitulo.cobcod = 1 or btitulo.cobcod = 2
            then.
            else ttcontrato.marca = no.
        end. 
        else if vcobcodori <> ?
             then if btitulo.cobcod <> vcobcodori then ttcontrato.marca = no. 
             
        if btitulo.titsit = "PAG"
        then do:
            ttcontrato.vlpag = ttcontrato.vlpag + btitulo.titvlcob.
            ttcontrato.qtdpag = ttcontrato.qtdpag + 1.
        end.
        if btitulo.titsit = "LIB"
        then do:
            ttcontrato.vlf_principal = ttcontrato.vlf_principal + btitulo.vlf_principal.
            ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + btitulo.vlf_acrescimo.
            ttcontrato.vlabe = ttcontrato.vlabe + btitulo.titvlcob.
            /*
            ttcontrato.vlpre = ttcontrato.vlpre + (btitulo.titvlcob -
                                                    (btitulo.titvlcob * ttfiltros.percdesagio / 100)).
            */                                                    
            if btitulo.titdtven < today
            then do:
                ttcontrato.vlatr = ttcontrato.vlatr + btitulo.titvlcob.
                ttcontrato.diasatraso = max(ttcontrato.diasatraso,today - btitulo.titdtven) .
            end.    
        end.      
    end.
    if ((par-completo = no and ttcontrato.vlabe > 0) or 
         par-completo = yes) and
       ttcontrato.marca = ? 
    then ttcontrato.marca = yes.   

    
    if ttcontrato.marca = no or
       ttcontrato.marca = ?
    then ttcontrato.marca = no.

end.

end procedure.




procedure trocaCarteira.

    if par-completo = no
    then update skip(2) vdtout label "Data Retorno".

    varqout = "/admcom/tmp/ctb/" + "ctrretorno_" + string(dcobra.cobcod) + trim(dcobra.cobnom) + 
                   (if par-completo = no
                    then string(vdtout,"999999" )
                    else "")
                   + "_" +
                     string(today,"999999")  + string(time) + ".csv".
    
    update  
            skip(2) varqout label "Saida"   colon 10 skip(2)
                   with
     
        centered 
        overlay
        side-labels
        color messages
       row 7 title " ARQUIVO SAIDA PARA CONTABILIDADE ".

        
        
    for each ttcontrato where ttcontrato.marca = yes.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and     
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum)
            no-lock.
            
            if titulo.titpar = 0 then next.
            
            if not par-completo
            then if titulo.titsit = "LIB"
                 then.
                 else next. 
            
            if true /*titulo.cobcod <> vcobcoddes*/
            then do:
                find first ttctbctr where ttctbctr.contnum = int(titulo.titnum) and
                                            ttctbctr.cobcod  = titulo.cobcod
                                            no-error.
                if not avail ttctbctr
                then do:
                    create ttctbctr.
                    ttctbctr.contnum = int(titulo.titnum).
                    ttctbctr.cobcod = titulo.cobcod.
                end.
                do on error undo:
                    create titulolog    .
                    assign
                    titulolog.empcod = titulo.empcod
                    titulolog.titnat = titulo.titnat
                    titulolog.modcod = titulo.modcod
                    titulolog.etbcod = titulo.etbcod
                    titulolog.clifor = titulo.clifor
                    titulolog.titnum = titulo.titnum
                    titulolog.titpar = titulo.titpar
                    titulolog.data   = if vdtout <> ? then vdtout else titulo.titdtemi
                    titulolog.hora   = time
                    titulolog.funcod = sfuncod
                    titulolog.campo   = "CobOri,CobCod"
                    titulolog.valor   = string(titulo.cobcod) + "," + string(vcobcoddes).
                    titulolog.obs    = "Retorno Carteira - arquivo csv " + string(today,"99/99/9999").
                end.
                run p.

            end.        
        end.     
    end. 
    
    run outcontratos.

    if search(varqin) <> ?
    then unix silent value("mv " + varqin + " " + varqin + "OK" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","")).  

end procedure.


procedure p.

do on error undo:
    
    find current titulo. 
    
    /* helio 15122021 - melhorias cr fase ii - registra ctbtrocart */
    run finct/trocacart.p (vcobcoddes,  /* 09022023 helio ID 155965 - motivo */
                           if vdtout <> ? then vdtout else titulo.titdtemi, 
                           par-completo, 
                           int(titulo.titnum),
                           titulo.titpar,
                           "ARQUIVO: " + varqin  ). /* helio 09022023 */

end.
end procedure.

procedure outcontratos.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varqin  as char format "x(65)".

def var vtitvlpag as dec.
def var vvlrpago  as dec.        
   def var vcp  as char init ";".

 
    output to value(varqout). 
    put unformatted 
        "Codigo" vcp 
        "Nome"   vcp 
        "CPF"    vcp 
        "Emissão" vcp 
        "Contrato" vcp  
        /*
        "Parcela"  vcp
        */
        "Carteira original" vcp 
        "Data Realocacao" vcp
        "Carteira" vcp 
        "Modalidade"  vcp 
        "Filial"  vcp 
        "Tipo de cobrança" vcp 
        /*
        "Vencimento" vcp
        */
        "Entrada" vcp
        "Principal"  vcp
        "Acrescimo"  vcp
        "Seguro" vcp
        "Total" vcp
        
        /*
        "Dt Pag" vcp
        */
        "Vlr Pago" vcp
        "Vlr Juros Atr" vcp
        "Vlr Tot Pago" vcp
        skip.
                                                
                                                
    for each ttctbctr.
        
        find contrato where contrato.contnum = ttctbctr.contnum no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.

            find cobra where cobra.cobcod = ttctbctr.cobcod no-lock no-error.
            find dcobra where dcobra.cobcod = vcobcoddes no-lock.
        
            find modal where modal.modcod = contrato.modcod no-lock no-error.
            ccarteira = (if ttctbctr.cobcod <> ? 
                     then string(ttctbctr.cobcod) + if avail cobra 
                                               then ("-" + cobra.cobnom)
                                               else ""
                     else "-").
            dcarteira = (if vcobcoddes <> ? 
                     then string(vcobcoddes) + if avail dcobra 
                                               then ("-" + dcobra.cobnom)
                                               else ""
                     else "-").

            ctpcontrato = if contrato.tpcontrato <> ? 
                    then if contrato.tpcontrato = "F"
                         then "FEIRAO"
                         else if contrato.tpcontrato = "N"
                              then "NOVACAO"
                              else if contrato.tpcontrato = "L"
                                   then "LP "
                                   else "normal"
                    else     "-".

            cmodnom = if contrato.modcod <> ? 
                    then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                    else "-".
                    
            put unformatted
                contrato.clicod     vcp
                if avail clien then clien.clinom else "-"       vcp
                if avail clien then clien.ciccgc else "-"       vcp
                contrato.dtinicial  format "99/99/9999" vcp
                contrato.contnum    vcp
                ccarteira      vcp 
                if vdtout <> ? then vdtout else contrato.dtinicial           format "99/99/9999"  vcp
                dcarteira           vcp
                cmodnom             vcp
                contrato.etbcod     vcp
                ctpcontrato         vcp
                trim(string(contrato.vlentra,">>>>>9.99")) vcp
                trim(string(contrato.vlf_principal,">>>>>9.99")) vcp
                trim(string(contrato.vlf_acrescimo,">>>>>9.99")) vcp
                trim(string(contrato.vlseguro,">>>>>9.99")) vcp
                trim(string(contrato.vltotal,">>>>>9.99")) vcp .
        
        vtitvlpag = 0.
        vvlrpago  = 0.
        for each  titulo where
            titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum)

            no-lock.

            if titulo.titpar = 0 then next.
                      
            if titulo.titsit = "PAG"
            then do:
                vtitvlpag = vtitvlpag + titulo.titvlpag.
                vvlrpago  = vvlrpago  + titulo.titvlcob.
            end.    

        end.
        put unformatted 
            trim(string(vvlrpago,">>>>>9.99")) vcp
            trim(string(vtitvlpag - vvlrpago,">>>>>9.99")) vcp
            trim(string(vtitvlpag,">>>>>9.99")) vcp


            skip.
                
    end.
    output close.

    message "arquivo gerado" varqout
        view-as alert-box.
end procedure.    





