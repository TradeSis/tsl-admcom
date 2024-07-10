/* 26042021 helio*/


{admcab.i}
def var vnome as char. 
def input param vtitle     as char.
def input param poldfiltro as char.
def input param pfiltro    as char.
def input param poldCobranca as log.
def input param poldmodcod   as char.
def input param poldtpcontrato as char.
def input param poldetbcod  as int. 
def input param poldcobcod  as int.
def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
def shared temp-table tt-modalidade-selec 
    field modcod as char.
def shared var vmod-sel as char.
def shared var vmodal      as log format "Sim/Nao".


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def temp-table ttctbposprod no-undo
    field filtro     as char
    field dtref as date
    field Cobranca  as log
    field modcod    like ctbposprod.modcod
    field tpcontrato    like ctbposprod.tpcontrato
    field produto  like ctbposprod.produto
    field etbcod    like ctbposprod.etbcod
    field cobcod    like ctbposprod.cobcod
     
    field saldo  like ctbposprod.saldo format "->>>>>>>>9.99"
    
    index idx is unique primary filtro asc dtref asc Cobranca asc
        modcod asc
        tpcontrato asc 
        etbcod asc
        cobcod asc
        produto asc.
def buffer bttctbposprod for ttctbposprod.
        
def var vfiltro as char.
    vfiltro = if poldCobranca <> ?
            then string(poldCobranca,"Cobranca/Fora Cobranca")
            else "".
    if poldmodcod <> ?
    then do:
        vfiltro = vfiltro + if vfiltro <> "" then "/" else "".
        vfiltro = vfiltro +   if poldmodcod <> ? 
                              then poldmodcod 
                              else "".
    end.
    if poldtpcontrato <> ?
    then do:                          
        vfiltro = vfiltro + if vfiltro <> "" then "/" else "".
        vfiltro = vfiltro + 
            if poldtpcontrato <> ?
            then if poldtpcontrato = "F"
                 then "FEIRAO"
                 else if poldtpcontrato = "N"
                      then "NOVACAO"
                      else if poldtpcontrato = "L"
                           then "LP "
                           else "   "
            else "".
    end.
    
    find cobra where cobra.cobcod = poldcobcod no-lock no-error.
    if poldcobcod <> ?
    then do    :
       vfiltro = vfiltro + if vfiltro <> "" then "/" else "".
        vfiltro = vfiltro + 
            (if poldcobcod <> ?
             then string(poldcobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").
    end.


pause 0.
disp
    vfiltro no-label format "x(50)"
        poldetbcod when poldetbcod <> ?
            label "Fil" format ">>>>"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        vnome format "x(20)" column-label ""
        ttctbposprod.etbcod  column-label "Fil" format ">>>"
        ttctbposprod.saldo                                            
        with frame frame-a 10 down centered row 6
        title vtitle.

def var vtotal    as dec init 0.

        
run gravaposicao (poldfiltro,
                  poldCobranca,
                  poldmodcod,
                  poldtpcontrato,
                  poldetbcod,
                  poldcobcod).


disp 
    vtotal    label "   Total" format "->>>>,>>>,>>9.99" at 52

        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.



bl-princ:
repeat:


disp 
    vtotal    label "   Total" format "->>>,>>>,>>9.99"

        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttctbposprod where recid(ttctbposprod) = recatu1 no-lock.
    if not available ttctbposprod
    then do.
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttctbposprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttctbposprod
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttctbposprod where recid(ttctbposprod) = recatu1 no-lock.

        status default "".
        esqcom1 = "".
        /*
        esqcom1[1] = if ttctbposprod.cobcod = ?
                     then "Propriedade"
                     else "".
        esqcom1[2] = if ttctbposprod.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".

        esqcom1[3] = if ttctbposprod.modcod = ?
                     then "Modalidade"
                     else "".

        esqcom1[4] = if ttctbposprod.Cobranca = ? or
                        ttctbposprod.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if pfiltro = "TpContrato"
                     then ""
                     else if ttctbposprod.Cobranca = ?
                            then "Cobranca"
                            else "".
        */             
                     
        esqcom1[6] = "".
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
        
                              help "digite [E]xporta para Arquivo csv"     
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up E e
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 
        
            
            if keyfunction(lastkey) = "E"
            then do:
                run geracsv.
                leave.
            end.
            
                                                                
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
                    if not avail ttctbposprod
                    then leave.
                    recatu1 = recid(ttctbposprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttctbposprod
                    then leave.
                    recatu1 = recid(ttctbposprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttctbposprod
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttctbposprod
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttctbposprod).
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
    vnome = if ttctbposprod.Cobranca <> ? and poldCobranca = ?
            then string(ttctbposprod.Cobranca,"Cobranca/Fora Cobranca")
            else "".
    vnome = vnome + if vnome <> "" then " " else "".
    if ttctbposprod.modcod <> ? and poldmodcod = ?
    then do:
        find modal where modal.modcod = ttctbposprod.modcod no-lock no-error.
    end.
        
    vnome = vnome + if ttctbposprod.modcod <> ? and poldmodcod = ?
            then ttctbposprod.modcod + if avail modal then "-" + modal.modnom else ""
            else "".
    vnome = vnome + if vnome <> "" then " " else "".

    vnome = vnome + if ttctbposprod.tpcontrato <> ? and poldtpcontrato = ?
            then if ttctbposprod.tpcontrato = "F"
                 then "FEIRAO"
                 else if ttctbposprod.tpcontrato = "N"
                      then "NOVACAO"
                      else if ttctbposprod.tpcontrato = "L"
                           then "LP "
                           else "normal "
            else "".
    vnome = vnome + if vnome <> "" then " " else "".

    find cobra where cobra.cobcod = ttctbposprod.cobcod no-lock no-error.
    vnome = vnome +  (if ttctbposprod.cobcod <> ? and poldcobcod = ?
             then string(ttctbposprod.cobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").

    vnome = ttctbposprod.produto. 
    display  
        vnome 
        ttctbposprod.etbcod when ttctbposprod.etbcod <> ?
        ttctbposprod.saldo
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
        find first ttctbposprod  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttctbposprod where
            no-lock no-error.
    end.
    else do:
        find first ttctbposprod
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttctbposprod  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttctbposprod where
            no-lock no-error.
    end.
    else do:
        find next ttctbposprod
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttctbposprod  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttctbposprod where
            no-lock no-error.
    end.
    else do:
        find prev ttctbposprod
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure gravaposicao.
def input param poldfiltro as char.
def input param poldCobranca like ttctbposprod.Cobranca.
def input param poldmodcod   like ttctbposprod.modcod.
def input param poldtpcontrato like ttctbposprod.tpcontrato.
def input param poldetbcod   like ttctbposprod.etbcod.
def input param poldcobcod   like ttctbposprod.cobcod.


def var pmodcod   like ttctbposprod.modcod.
def var petbcod   like ttctbposprod.etbcod.
def var pcobcod   like ttctbposprod.cobcod.

def var ptpcontrato like ttctbposprod.tpcontrato.
def var pCobranca like ttctbposprod.Cobranca.

def var vdtref  as date.
vdtref = vdtini. 


hide message no-pause.
message color normal "fazendo calculos... aguarde...".

for each ttctbposprod.
    delete ttctbposprod.
end.

for each ctbposprod where
    ctbposprod.dtref = vdtref and
/*   (if poldCobranca <> ? then ctbposprod.cobcod = poldCobranca else true) an
d*/
   (if poldmodcod   <> ? then ctbposprod.modcod = poldmodcod   else true) and
   (if poldtpcontrato <> ? then ctbposprod.tpcontrato = poldtpcontrato else true) and
   (if poldetbcod <> ? then ctbposprod.etbcod = poldetbcod else true) and
   (if poldcobcod <> ? then ctbposprod.cobcod = poldcobcod else true)
    no-lock.
    if vetbcod <> 0 
        then if ctbposprod.etbcod <> vetbcod then next.
        
             find first ttctbposprod where
                    ttctbposprod.filtro   = pfiltro and
                    ttctbposprod.dtref    = ctbposprod.dtref and
                    ttctbposprod.Cobranca = pCobranca and
                    ttctbposprod.modcod   = pmodcod  and
                    ttctbposprod.etbcod   = petbcod and
                    ttctbposprod.tpcontrato = ptpcontrato and
                    ttctbposprod.cobcod   = pcobcod and
                    ttctbposprod.produto  = ctbposprod.produto
                    no-error.
                if not avail ttctbposprod
                then do:
                    create ttctbposprod.
                    ttctbposprod.filtro = pfiltro.
                    ttctbposprod.dtref = ctbposprod.dtref.
                    ttctbposprod.Cobranca = pCobranca.
                    ttctbposprod.modcod   = pmodcod.
                    ttctbposprod.etbcod   = petbcod.
                    ttctbposprod.tpcontrato = ptpcontrato.
                    ttctbposprod.cobcod   = pcobcod.
                    ttctbposprod.produto  = ctbposprod.produto.

                end.

                ttctbposprod.saldo = ttctbposprod.saldo + ctbposprod.saldo. 
          
                vtotal = vtotal + ctbposprod.saldo.
   


end.

    
           
hide message no-pause.
end procedure.
                        
                        
procedure geracsv.

   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/ctb/carteira" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_produto" + string(vdtfin,"99999999") + 
                             "_"   + string(today,"999999")  + replace(string(time,"HH:MM:SS"),":","") +
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
        
    output to value(varq).    
        put unformatted 
            vfiltro skip.
            
        put unformatted
        "Data_Referencia" vcp    
        "Produto" vcp
        
        "Operacao"   vcp
        "Filial" vcp
        "Saldo" vcp
        
            skip.        
    
    for each ttctbposprod.

        /*
        vnome = if ttctbposprod.Cobranca <> ? and poldCobranca = ?
                then string(ttctbposprod.Cobranca,"Cobranca/Fora Cobranca")
                else "".
        vnome = vnome + if vnome <> "" then " " else "".
        if ttctbposprod.modcod <> ? and poldmodcod = ?
        then do:
            find modal where modal.modcod = ttctbposprod.modcod no-lock no-error.
        end.
        
        vnome = vnome + if ttctbposprod.modcod <> ? and poldmodcod = ?
                then ttctbposprod.modcod + if avail modal then "-" + modal.modnom else ""
                else "".
        vnome = vnome + if vnome <> "" then " " else "".

        vnome = vnome + if ttctbposprod.tpcontrato <> ? and poldtpcontrato = ?
                then if ttctbposprod.tpcontrato = "F"
                     then "FEIRAO"
                     else if ttctbposprod.tpcontrato = "N"
                          then "NOVACAO"
                          else if ttctbposprod.tpcontrato = "L"
                               then "LP "
                               else "normal "
                else     "".
        vnome = vnome + if vnome <> "" then " " else "".

        find cobra where cobra.cobcod = ttctbposprod.cobcod no-lock no-error.
        vnome = vnome +  (if ttctbposprod.cobcod <> ? and poldcobcod = ?
                 then string(ttctbposprod.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "").
        */
        
        put unformatted
            vdtfin vcp
            ttctbposprod.produto vcp
            vfiltro vcp
            if  ttctbposprod.etbcod <> ? then ttctbposprod.etbcod else "" vcp
            ttctbposprod.saldo vcp
            skip.

    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure. 


