/* 17/09/2021 helio*/

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


def temp-table ttctbposcart no-undo
    field filtro     as char
    field dtref as date
    field Cobranca  as log
    field modcod    like ctbposcart.modcod
    field tpcontrato    like ctbposcart.tpcontrato
    field etbcod    like ctbposcart.etbcod
    field cobcod    like ctbposcart.cobcod
    field emissao   like ctbposcart.emissao   format ">>>>>>>>9.99"
    field pagamento like ctbposcart.pagamento format ">>>>>>>>9.99"
     field troca like ctbposcart.pagamento    format  "->>>>>>>>9.99" column-label "troca"
     
    field saldo  like ctbposcart.saldo format "->>>>>>>>9.99"
    
    index idx is unique primary filtro asc dtref asc Cobranca asc
        modcod asc
        tpcontrato asc 
        etbcod asc
        cobcod asc.
def buffer bttctbposcart for ttctbposcart.
        
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
        ttctbposcart.etbcod  column-label "Fil" format ">>>"
        ttctbposcart.emissao
        ttctbposcart.pagamento    
        ttctbposcart.troca 
        ttctbposcart.saldo                                            
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
    else find ttctbposcart where recid(ttctbposcart) = recatu1 no-lock.
    if not available ttctbposcart
    then do.
        if pfiltro = ""
        then do: 
            if vetbcod = 0 and vmodal = no /*and vdtini < date(month(today),01,year(today))*/
            then do:
                pfiltro = "geral".
                        find first ctbprzmprod where 
                                ctbprzmprod.pparametros = pparametros and
                                ctbprzmprod.dtiniper = vdtini and
                                ctbprzmprod.dtfimper = vdtfin and
                                ctbprzmprod.campo = "TOTAL" and 
                                ctbprzmprod.valor = "" no-lock no-error. 
                if avail ctbprzmprod
                then do:
                    pause 0.
                    run finct/telactbposparam.p.
                end.
                else do:
                    message 
                    "Posicao da Carteira " string(month(vdtfin),"99") + "/" string(year(vdtfin),"9999") "nao gerada. Deseja Executar?"
                    update sresp.
                    if sresp
                    then do on error undo:
                  
                        /*run  finct/frsalcart_rodaresumo.p (input vdtfin).*/
                        
                        
                        find first ctbprzmprod where 
                                ctbprzmprod.pparametros = "CARTEIRA" and
                                ctbprzmprod.dtiniper = vdtini and
                                ctbprzmprod.dtfimper = vdtfin and
                                ctbprzmprod.campo = "TOTAL" and 
                                ctbprzmprod.valor = "" no-error. 
                        if not avail ctbprzmprod
                        then do:
                            create ctbprzmprod.
                            ctbprzmprod.pparametros = "CARTEIRA".
                            ctbprzmprod.dtiniper = vdtini.
                            ctbprzmprod.dtfimper = vdtfin.
                            ctbprzmprod.campo = "TOTAL".
                            ctbprzmprod.valorcampo = "".
                        end.    
                        ctbprzmprod.dtrefSAIDA = ?.
                        ctbprzmprod.vlrPago    = 0.
                        ctbprzmprod.qtdPC      = 0.
                        ctbprzmprod.PrzMedio   = 0.
                        ctbprzmprod.pstatus    = "PROCESSAR".
                        ctbprzmprod.dtiniproc  = ?.
                        ctbprzmprod.hriniproc  = ?.
                        ctbprzmprod.dtfimproc  = ?.
                        ctbprzmprod.hrfimproc  = ?.
                    end.
                    release ctbprzmprod.
                    run finct/telactbposparam.p.
                end.
            end.
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttctbposcart).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttctbposcart
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttctbposcart where recid(ttctbposcart) = recatu1 no-lock.

        status default "".
        esqcom1[1] = if ttctbposcart.cobcod = ?
                     then "Propriedade"
                     else "".
        esqcom1[2] = if ttctbposcart.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".

        esqcom1[3] = if ttctbposcart.modcod = ?
                     then "Modalidade"
                     else "".

        esqcom1[4] = if ttctbposcart.Cobranca = ? or
                        ttctbposcart.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if pfiltro = "TpContrato"
                     then ""
                     else if ttctbposcart.Cobranca = ?
                            then "Cobranca"
                            else "".
         esqcom1[6] = "Produto".                        
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
                              help "digite [E]xporta para Arquivo csv    -  [P]rocessos"
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up C E  p P
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 
        
            if keyfunction(lastkey) = "P"
            then do:
                run finct/telactbposparam.p.
                leave.
            end.
            
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
                    if not avail ttctbposcart
                    then leave.
                    recatu1 = recid(ttctbposcart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttctbposcart
                    then leave.
                    recatu1 = recid(ttctbposcart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttctbposcart
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttctbposcart
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
                if pfiltro = "Produto"
                then do:
                    run
                        finct/telactbposprodu.p
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttctbposcart.Cobranca,
                            ttctbposcart.modcod,
                            ttctbposcart.tpcontrato,
                            ttctbposcart.etbcod,
                            ttctbposcart.cobcod).
                                            
                end.
                else do:
                    hide frame fcab no-pause.
                    hide frame frame-a no-pause.                
                    poldfiltro = ttctbposcart.filtro.
                    run finct/telactbposcartref.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttctbposcart.Cobranca,
                            ttctbposcart.modcod,
                            ttctbposcart.tpcontrato,
                            ttctbposcart.etbcod,
                            ttctbposcart.cobcod),
                
                    pfiltro = poldfiltro.            
                    hide frame frame-a no-pause.
                    view frame fcab.
                    recatu1 = ?.
                    leave.
                end.
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttctbposcart).
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
    vnome = if ttctbposcart.Cobranca <> ? and poldCobranca = ?
            then string(ttctbposcart.Cobranca,"Cobranca/Fora Cobranca")
            else "".
    vnome = vnome + if vnome <> "" then " " else "".
    if ttctbposcart.modcod <> ? and poldmodcod = ?
    then do:
        find modal where modal.modcod = ttctbposcart.modcod no-lock no-error.
    end.
        
    vnome = vnome + if ttctbposcart.modcod <> ? and poldmodcod = ?
            then ttctbposcart.modcod + if avail modal then "-" + modal.modnom else ""
            else "".
    vnome = vnome + if vnome <> "" then " " else "".

    vnome = vnome + if ttctbposcart.tpcontrato <> ? and poldtpcontrato = ?
            then if ttctbposcart.tpcontrato = "F"
                 then "FEIRAO"
                 else if ttctbposcart.tpcontrato = "N"
                      then "NOVACAO"
                      else if ttctbposcart.tpcontrato = "L"
                           then "LP "
                           else "normal "
            else "".
    vnome = vnome + if vnome <> "" then " " else "".

    find cobra where cobra.cobcod = ttctbposcart.cobcod no-lock no-error.
    vnome = vnome +  (if ttctbposcart.cobcod <> ? and poldcobcod = ?
             then string(ttctbposcart.cobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").

    display  
        vnome 
        ttctbposcart.etbcod when ttctbposcart.etbcod <> ?
        ttctbposcart.emissao    when vdtfin > 12/31/2019
        ttctbposcart.pagamento  when vdtfin > 12/31/2019
        ttctbposcart.troca   
        ttctbposcart.saldo
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
        find first ttctbposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttctbposcart where
            no-lock no-error.
    end.
    else do:
        find first ttctbposcart
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttctbposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttctbposcart where
            no-lock no-error.
    end.
    else do:
        find next ttctbposcart
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttctbposcart  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttctbposcart where
            no-lock no-error.
    end.
    else do:
        find prev ttctbposcart
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure gravaposicao.
def input param poldfiltro as char.
def input param poldCobranca like ttctbposcart.Cobranca.
def input param poldmodcod   like ttctbposcart.modcod.
def input param poldtpcontrato like ttctbposcart.tpcontrato.
def input param poldetbcod   like ttctbposcart.etbcod.
def input param poldcobcod   like ttctbposcart.cobcod.





def var pmodcod   like ttctbposcart.modcod.
def var petbcod   like ttctbposcart.etbcod.
def var pcobcod   like ttctbposcart.cobcod.

def var ptpcontrato like ttctbposcart.tpcontrato.
def var pCobranca like ttctbposcart.Cobranca.

def var vdtref  as date.
vdtref = vdtini. 


hide message no-pause.
message color normal "fazendo calculos... aguarde...".

for each ttctbposcart.
    delete ttctbposcart.
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
        for each ctbposcart where 
            ctbposcart.dtref  = vdtref and
            ctbposcart.etbcod = estab.etbcod and
            ctbposcart.modcod = tt-modalidade-selec.modcod 
            no-lock.
            
            if pfiltro = "geral"
            then do:
                petbcod     = ?.
                pmodcod     = ?.
                pCobranca   = ?.
                ptpcontrato = ?.
                pcobcod     = ?.
            end.                 
            else do:
                pCobranca = poldCobranca.
                pmodcod   = poldmodcod.
                petbcod   = poldetbcod.
                ptpcontrato = poldtpcontrato.
                pcobcod     = poldcobcod.
            end.
            if pfiltro = "Cobranca" 
            then do:
                pCobranca   = ctbposcart.tpcontrato = "" or
                              ctbposcart.tpcontrato = "N".
            end. 
            else do:
                if poldCobranca = yes
                then if  ctbposcart.tpcontrato = "" or
                         ctbposcart.tpcontrato = "N"
                     then.
                     else next.
                if poldCobranca = no
                then if  ctbposcart.tpcontrato = "" or
                         ctbposcart.tpcontrato = "N"
                     then next.
            end.
            
            if pfiltro = "tpcontrato"
            then do:
                ptpcontrato = ctbposcart.tpcontrato.
                pCobranca   = ctbposcart.tpcontrato = "" or
                              ctbposcart.tpcontrato = "N".
            end.                
            else do:
                if poldtpcontrato <> ?
                then if ctbposcart.tpcontrato <> poldtpcontrato
                     then next.
            end.
            
            if pfiltro = "modalidade"
            then pmodcod = ctbposcart.modcod.
            else do:
                if poldmodcod <> ?
                then if ctbposcart.modcod <> poldmodcod
                     then next.
            end.
            if pfiltro = "Filial"
            then petbcod = ctbposcart.etbcod.
            else do:
                if poldetbcod <> ?
                then if ctbposcart.etbcod <> poldetbcod
                     then next.
            end.
            if pfiltro = "Propriedade"
            then pcobcod = if ctbposcart.cobcod = ? then 999 else ctbposcart.cobcod.
            else do:
                if poldcobcod <> ?
                then if ctbposcart.cobcod <> poldcobcod
                     then next.
            end.
            
                        
                        
                find first ttctbposcart where
                    ttctbposcart.filtro   = pfiltro and
                    ttctbposcart.dtref    = ctbposcart.dtref and
                    ttctbposcart.Cobranca = pCobranca and
                    ttctbposcart.modcod   = pmodcod  and
                    ttctbposcart.etbcod   = petbcod and
                    ttctbposcart.tpcontrato = ptpcontrato and
                    ttctbposcart.cobcod   = pcobcod
                    no-error.
                if not avail ttctbposcart
                then do:
                    create ttctbposcart.
                    ttctbposcart.filtro = pfiltro.
                    ttctbposcart.dtref = ctbposcart.dtref.
                    ttctbposcart.Cobranca = pCobranca.
                    ttctbposcart.modcod   = pmodcod.
                    ttctbposcart.etbcod   = petbcod.
                    ttctbposcart.tpcontrato = ptpcontrato.
                    ttctbposcart.cobcod   = pcobcod.
                end.

                ttctbposcart.emissao  = ttctbposcart.emissao + 
                            (ctbposcart.emissao). /* + ctbposcart.entrada). */
                ttctbposcart.pagamento = ttctbposcart.pagamento + 
                            (ctbposcart.pagamento). /* + ctbposcart.saida). */
                ttctbposcart.troca = ttctbposcart.troca + ctbposcart.entrada - ctbposcart.saida.
                ttctbposcart.saldo = ttctbposcart.saldo + ctbposcart.saldo. 
          
                vtotal = vtotal + ctbposcart.saldo.
      
                
        end.
    end.
end.            
           
hide message no-pause.
end procedure.



procedure geracsv.

   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/ctb/carteira" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_posicao" + string(vdtfin,"99999999") + 
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
        "Operacao"   vcp
        "Filial" vcp
        "Emissoes"      vcp
        "Pagamentos"  vcp
        "Saldo" vcp
        
            skip.        
    
    for each ttctbposcart.

        vnome = if ttctbposcart.Cobranca <> ? and poldCobranca = ?
                then string(ttctbposcart.Cobranca,"Cobranca/Fora Cobranca")
                else "".
        vnome = vnome + if vnome <> "" then " " else "".
        if ttctbposcart.modcod <> ? and poldmodcod = ?
        then do:
            find modal where modal.modcod = ttctbposcart.modcod no-lock no-error.
        end.
        
        vnome = vnome + if ttctbposcart.modcod <> ? and poldmodcod = ?
                then ttctbposcart.modcod + if avail modal then "-" + modal.modnom else ""
                else "".
        vnome = vnome + if vnome <> "" then " " else "".

        vnome = vnome + if ttctbposcart.tpcontrato <> ? and poldtpcontrato = ?
                then if ttctbposcart.tpcontrato = "F"
                     then "FEIRAO"
                     else if ttctbposcart.tpcontrato = "N"
                          then "NOVACAO"
                          else if ttctbposcart.tpcontrato = "L"
                               then "LP "
                               else "normal "
                else     "".
        vnome = vnome + if vnome <> "" then " " else "".

        find cobra where cobra.cobcod = ttctbposcart.cobcod no-lock no-error.
        vnome = vnome +  (if ttctbposcart.cobcod <> ? and poldcobcod = ?
                 then string(ttctbposcart.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "").

        put unformatted
            vdtfin vcp
            vnome vcp
            if  ttctbposcart.etbcod <> ? then ttctbposcart.etbcod else "" vcp
            if vdtfin > 12/31/2019 then ttctbposcart.emissao    else 0 vcp
            if vdtfin > 12/31/2019 then ttctbposcart.pagamento  else 0 vcp
            ttctbposcart.saldo vcp
            skip.

    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.


