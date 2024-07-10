/*
*                                 R
*
*/


{admcab.i}
def var vnome as char. 
def input param vtitle     as char.
def input param poldfiltro as char.
def input param pfiltro    as char.
def input param poldcarteira as log.
def input param poldmodcod   as char.
def input param poldtpcontrato as char.
def input param poldetbcod  as int. 
def input param poldcobcod  as int.
def input param polddtref   as date.
def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
def shared var vreferencia as log format "Referencia/Periodo".
def shared temp-table tt-modalidade-selec 
    field modcod as char.
def shared var vmod-sel as char.
def shared var vquarter  as log format "Sim/Nao".

def var panoref as int format "9999".
def var pmesref as int format "99".

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [""].

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def temp-table ttposcart no-undo
    field filtro     as char
    field quarter    as char
    field dtvenc    like poscart.dtvenc
    
    field carteira  as log
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field etbcod    like poscart.etbcod
    field cobcod    like poscart.cobcod
    field dtref as date
    
    field emissao   like poscart.emissao format "->>>>>>>>9.99"
    field pagamento like poscart.pagamento format "->>>>>>>>9.99"
    field saldo  like poscart.saldo format "->>>>>>>>9.99"
    
    index idx is unique primary filtro asc dtvenc asc carteira asc
        modcod asc
        tpcontrato asc 
        etbcod asc
        cobcod asc
        dtref  asc.
def buffer bttposcart for ttposcart.
        
def var vfiltro as char.
    vfiltro = if poldcarteira <> ?
            then string(poldcarteira,"CART/OUTR")
            else "".
    vfiltro = vfiltro + " " +
            if poldmodcod <> ?
            then poldmodcod
            else "".
    vfiltro = vfiltro + " " +
            if poldtpcontrato <> ?
            then if poldtpcontrato = "F"
                 then "FEI"
                 else if poldtpcontrato = "N"
                      then "NOV"
                      else if poldtpcontrato = "L"
                           then "LP "
                           else "   "
            else "".

    find cobra where cobra.cobcod = poldcobcod no-lock no-error.
    vfiltro = vfiltro + " " +
            (if poldcobcod <> ?
             then string(poldcobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").


disp
    vfiltro no-label format "x(50)"
        poldetbcod when poldetbcod <> ?
            label "Fil" format ">>>>"
        polddtref when polddtref <> ? no-label

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        vnome format "x(24)" column-label ""
        ttposcart.etbcod  column-label "Fil" format ">>>"
        pmesref format "99 " column-label "Mes" space(0) 
            panoref column-label "Ano"
        ttposcart.emissao
        ttposcart.pagamento    
        ttposcart.saldo                                            
        with frame frame-a 8 down centered row 7
        title vtitle.

def var vemissao as dec init 0.
def var vpagamento   as dec init 0.
def var vtotal    as dec init 0.

        
run gravaposicao (poldfiltro,
                  poldcarteira,
                  poldmodcod,
                  poldtpcontrato,
                  poldetbcod,
                  poldcobcod,
                  polddtref).


disp 
    vemissao     label "Emissoes" format "->>,>>>,>>9.99"
    vpagamento   label "Pagamentos" format "->>,>>>,>>9.99"
    vtotal       label "Saldo" format "->>,>>>,>>9.99"

        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.



bl-princ:
repeat:


disp 
    vemissao
    vpagamento
    vtotal  

        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttposcart where recid(ttposcart) = recatu1 no-lock.
    if not available ttposcart
    then do.
        if pfiltro = ""
        then do: 
            pfiltro = "geral".
            run pfiltro ("",?,?,?).
            find first ttposcart no-lock no-error.
            if not avail ttposcart
            then  leave.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttposcart).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttposcart
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttposcart where recid(ttposcart) = recatu1 no-lock.

        status default "".

        esqcom1[1] = if pfiltro = "TpContrato"
                     then ""
                     else if ttposcart.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[2] = if ttposcart.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[3] = if ttposcart.carteira = ? or
                        ttposcart.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[4] = if ttposcart.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[5] = if ttposcart.cobcod = ?
                     then "Propriedade"
                     else "".
                     
        esqcom1[6] = if ttposcart.dtref = ?
                     then "Referencia"
                     else "".
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

        choose field vnome 
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
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
                    if not avail ttposcart
                    then leave.
                    recatu1 = recid(ttposcart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttposcart
                    then leave.
                    recatu1 = recid(ttposcart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttposcart
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttposcart
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:

                pfiltro = esqcom1[esqpos1].
                hide frame fcab no-pause.
                hide frame frame-a no-pause.                
                poldfiltro = ttposcart.filtro.
                run fin/telaposcartper.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttposcart.carteira,
                            ttposcart.modcod,
                            ttposcart.tpcontrato,
                            ttposcart.etbcod,
                            ttposcart.cobcod,
                            ttposcart.dtref).
                pfiltro = poldfiltro.            
                hide frame frame-a no-pause.
                view frame fcab.
                recatu1 = ?.
                leave.

             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttposcart).
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
    vnome = if vquarter
            then ttposcart.quarter
            else "".
    vnome = vnome + "" + 
            if ttposcart.carteira <> ?
            then string(ttposcart.carteira,"CART/OUTR")
            else "".
    vnome = vnome + " " +
            if ttposcart.modcod <> ?
            then ttposcart.modcod
            else "".
    vnome = vnome + " " +
            if ttposcart.tpcontrato <> ?
            then if ttposcart.tpcontrato = "F"
                 then "FEI"
                 else if ttposcart.tpcontrato = "N"
                      then "NOV"
                      else if ttposcart.tpcontrato = "L"
                           then "LP "
                           else "   "
            else "".
    find cobra where cobra.cobcod = ttposcart.cobcod no-lock no-error.
    vnome = vnome + " " +
            (if ttposcart.cobcod <> ?
             then string(ttposcart.cobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").

    panoref = year(ttposcart.dtref).
    pmesref = month(ttposcart.dtref).             
    display  
        vnome 
        ttposcart.etbcod when ttposcart.etbcod <> ?
        pmesref when pmesref <> ?
        panoref when panoref <> ?
        ttposcart.emissao
        ttposcart.pagamento
        ttposcart.saldo 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
                    vnome 
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal

                    
                    vnome 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttposcart where
            no-lock no-error.
    end.
    else do:
        find first ttposcart
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttposcart where
            no-lock no-error.
    end.
    else do:
        find next ttposcart
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttposcart where
            no-lock no-error.
    end.
    else do:
        find prev ttposcart
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure gravaposicao.
def input param poldfiltro as char.
def input param poldcarteira like ttposcart.carteira.
def input param poldmodcod   like ttposcart.modcod.
def input param poldtpcontrato like ttposcart.tpcontrato.
def input param poldetbcod   like ttposcart.etbcod.
def input param poldcobcod   like ttposcart.cobcod.
def input param polddtref   like ttposcart.dtref.



def var iquarter as int.
def var cquarter as char.
def var xquarter as char extent 4
    init ["M3 ","M2 ","M1 ","P0 "].

def var pmodcod   like ttposcart.modcod.
def var petbcod   like ttposcart.etbcod.
def var pcobcod   like ttposcart.cobcod.

def var ptpcontrato like ttposcart.tpcontrato.
def var pcarteira like ttposcart.carteira.

def var vdtref  as date.
vdtref = vdtini. 

def var pdtref   like poscart.dtref.
def var vdt as date.
for each ttposcart.
    delete ttposcart.
end.
    
    
for each estab 
    where if vetbcod = 0
          then true
          else estab.etbcod = vetbcod
    no-lock.
        if not poldfiltro = "geral"
        then if poldetbcod <> ?
             then if estab.etbcod <> poldetbcod
                  then next.

    for each tt-modalidade-selec.
        if not poldfiltro = "geral"
        then if poldmodcod <> ?
             then if tt-modalidade-selec.modcod <> poldmodcod
                  then next.
        iquarter = 0.   
        do vdt = vdtini to vdtfin. 
        if day(vdt) <> 01 then next.    
        iquarter  = iquarter + 1.
        cquarter = xquarter[iquarter].
        for each poscart where 
            poscart.dtvenc = vdt and
            poscart.etbcod = estab.etbcod and
            poscart.modcod = tt-modalidade-selec.modcod 
            no-lock.
            
            if pfiltro = "geral"
            then do:
                petbcod     = ?.
                pmodcod     = ?.
                pcarteira   = ?.
                ptpcontrato = ?.
                pdtref      = ?.
                pcobcod     = ?.
            end.                 
            else do:
                pcarteira = poldcarteira.
                pmodcod   = poldmodcod.
                petbcod   = poldetbcod.
                ptpcontrato = poldtpcontrato.
                pcobcod     = poldcobcod.
                pdtref      = polddtref.
            end.
            if pfiltro = "carteira" 
            then do:
                pcarteira   = poscart.tpcontrato = "" or
                              poscart.tpcontrato = "N".
            end. 
            else do:
                if poldcarteira = yes
                then if  poscart.tpcontrato = "" or
                         poscart.tpcontrato = "N"
                     then.
                     else next.
                if poldcarteira = no
                then if  poscart.tpcontrato = "" or
                         poscart.tpcontrato = "N"
                     then next.
            end.
            
            if pfiltro = "tpcontrato"
            then do:
                ptpcontrato = poscart.tpcontrato.
                pcarteira   = poscart.tpcontrato = "" or
                              poscart.tpcontrato = "N".
            end.                
            else do:
                if poldtpcontrato <> ?
                then if poscart.tpcontrato <> poldtpcontrato
                     then next.
            end.
            
            if pfiltro = "modalidade"
            then pmodcod = poscart.modcod.
            else do:
                if poldmodcod <> ?
                then if poscart.modcod <> poldmodcod
                     then next.
            end.
            if pfiltro = "Filial"
            then petbcod = poscart.etbcod.
            else do:
                if poldetbcod <> ?
                then if poscart.etbcod <> poldetbcod
                     then next.
            end.
            if pfiltro = "Propriedade"
            then pcobcod = if poscart.cobcod = ? then 999 else poscart.cobcod.
            else do:
                if poldcobcod <> ?
                then if poscart.cobcod <> poldcobcod
                     then next.
            end.
            
            if pfiltro = "referencia"
            then do:
                pdtref = poscart.dtref.
            end.  
            else do:
                if polddtref <> ?
                then if poscart.dtref <> polddtref
                     then next.
            end.
                        
                        
                        
                find first ttposcart where
                    ttposcart.filtro   = pfiltro and
                    ttposcart.dtvenc   = poscart.dtvenc and
                    ttposcart.carteira = pcarteira and
                    ttposcart.modcod   = pmodcod  and
                    ttposcart.etbcod   = petbcod and
                    ttposcart.tpcontrato = ptpcontrato and
                    ttposcart.cobcod   = pcobcod and
                    ttposcart.dtref    = pdtref 
                    no-error.
                if not avail ttposcart
                then do:
                    create ttposcart.
                    ttposcart.filtro = pfiltro.
                    ttposcart.quarter = cquarter.
                    ttposcart.dtvenc = poscart.dtvenc.
                    ttposcart.carteira = pcarteira.
                    ttposcart.modcod   = pmodcod.
                    ttposcart.etbcod   = petbcod.
                    ttposcart.tpcontrato = ptpcontrato.
                    ttposcart.cobcod   = pcobcod.
                    ttposcart.dtref    = pdtref.
                end.

                ttposcart.emissao  = ttposcart.emissao + 
                            (poscart.emissao). /* + poscart.entrada). */
                ttposcart.pagamento = ttposcart.pagamento + 
                            (poscart.pagamento). /* + poscart.saida). */
          
                ttposcart.saldo = ttposcart.saldo + 
                            poscart.emissao - poscart.pagamento.
                      /*poscart.saldo. */
          
                    vemissao     = vemissao   + poscart.emissao.
                    vpagamento   = vpagamento + poscart.pagamento.
                vtotal = vemissao - vpagamento.
      
                
        end.
        end. /* Quarter */
    end.
end.            
           
end procedure.

