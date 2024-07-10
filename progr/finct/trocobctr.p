/* helio 11072023 - 527008 ARQUIVO CESSÃO FIDC */
/* 26112021 helio venda carteira */
{admcab.i}

def input param vcobcodori  as int.
def input param vcobcoddes  as int.
def input param copcao      as char.
def var vpercdesagio as dec.

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
    initial ["<filtrar>","<parcelas>","  <marca>","  <todos>"," <enviar>","<digitar>"].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def new shared temp-table ttfiltros no-undo
    field percdesagio   as dec
    field valormax      as dec format ">>>>,>>>,>>9.99" init 9999999999.99
    field vlf_acrescimo as dec
    field txjuroini     as dec
    field txjurofim     as dec
    field dtemiini      as date format "99/99/9999"
    field dtemifim      as date format "99/99/9999"
    field modcod        as char format "x(25)"
    field tpcontrato    as char format "x(12)"
    field qtdparcpag    as int format "99" init 99
    field diasatraso    as int format "999"
    field somentenfe    as log format "Sim/Nao" init yes
    /* helio 11072023 */
    field vendacnpj     as log format "Sim/Nao" init no
    field valormincompra  as dec init 10
    field cpfzerado     as log format "Sim/Nao" init no .



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
def var vtitvlcob   like ttcontrato.vlabe.
def var vvlmar      like ttcontrato.vlabe.
def var vdesagio    like ttcontrato.vlabe.
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



find  cobra where  cobra.cobcod = vcobcodori no-lock.
find dcobra where dcobra.cobcod = vcobcoddes no-lock.

vtitle =  string(cobra.cobcod,"99")  + "-" +  cobra.cobnom + " -> " + 
         string(dcobra.cobcod,"99") + "-" + dcobra.cobnom + " - Enviar Contratos".


disp 
    vtitle format "x(60)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



if copcao = "Filtro"
then do:
    esqcom1[1] = "<filtrar>".
    create ttfiltros.
    run finct/trocobsel.p (input vcobcodori,
                           input vcobcoddes).
end.
if copcao = "arquivo csv"
then do:
    esqcom1[1] = "".
    run finct/trocobcsv.p (input vcobcodori,
                           input vcobcoddes).
end.
if copcao = "digitar"
then do:
    esqcom1[1] = "".
    run digitaContrato.
end.



disp 
    vtitvlcob    label "Filtrado"      format "zzzzzzzz9.99" colon 65
    vdesagio     label "Valor Presente Desagio" format "zzzzzzzz9.99" colon 25   
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
            vdesagio    = vdesagio + ttcontrato.vlpre.
        end.    

   end.
    disp
        vtitvlcob
        vvlmar
        vdesagio
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
            
            if esqcom1[esqpos1] = "<filtrar>"
            then do:
                run finct/trocobsel.p (input vcobcodori,
                                       input vcobcoddes).
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
                    vdesagio = vdesagio - ttcontrato.vlpre.
                end.    
                else do:
                    vvlmar = vvlmar + ttcontrato.vlabe.
                    vdesagio = vdesagio + ttcontrato.vlpre.
                end.    
                disp vdesagio vvlmar with frame ftot.
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
            
            if esqcom1[esqpos1] = " <enviar>"
            then do: 
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1] with frame f-com1.

                if vcobcoddes = 14 or vcobcoddes = 16 /* FIDC */
                then do:
                    message "confirma gerar arquivo para FIDC?" update sresp.
                    if sresp
                    then  run finct/trocobfidcenvia.p. 
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
        else if btitulo.cobcod <> vcobcodori
             then ttcontrato.marca = no. 
             
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
            
    if ttcontrato.vlabe > 0 and
       ttcontrato.marca = ? 
    then ttcontrato.marca = yes.   

    
    if ttcontrato.marca = no or
       ttcontrato.marca = ?
    then ttcontrato.marca = no.

end.

end procedure.


