/* helio 03102022 - melhoria - Chamado 149970 - Entender limite zerado. */ 
/* HUBSEG 19/10/2021 */

{admcab.i}
def input param par-clicod like contrato.clicod.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" consulta "," props"," "].
form
    esqcom1
    with frame f-com1 row 9 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var par-dtini as date.

def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

       
def temp-table ttcontrato no-undo
    field contnum       like contrato.contnum
    field tpcontrato    like contrato.tpcontrato
    field vlr_aberto    as dec
    field vlr_abertoEP  as dec
    field vlr_abprinc   as dec
    field vlr_abprincEP  as dec
    field vlr_abertoCDC  as dec
    field vlr_abprincCDC  as dec
    
    index idx is unique primary  contnum asc.

    def var vvlr_aberto    as dec.
    def var vvlr_abprinc   as dec.
    def var vvlr_abertoEP  as dec.
    def var vvlr_abprincEP  as dec.
    def var vvlr_abertoCDC as dec.
    def var vvlr_abprincCDC as dec.

    def var vvlr_abertoNOV    as dec.
    def var vvlr_abprincNOV    as dec.
    def var vvlr_abertoEPNOV    as dec.
    def var vvlr_abprincEPNOV    as dec.
    def var vvlr_abertoCDCNOV as dec.
    def var vvlr_abprincCDCNOV as dec.

    def var vvlr_abertoNORM    as dec.
    def var vvlr_abprincNORM    as dec.
    def var vvlr_abertoEPNORM    as dec.
    def var vvlr_abprincEPNORM    as dec.
    def var vvlr_abertoCDCNORM as dec.
    def var vvlr_abprincCDCNORM as dec.

    
    

    form  
        contrato.contnum format ">>>>>>>>>9" column-label "contrato"
        contrato.modcod        column-label "mod" 
        ttcontrato.tpcontrato    column-label "tp"
        
        ttcontrato.vlr_aberto  column-label "Global!aberto"       format ">>>>>9.99"
        ttcontrato.vlr_abprinc column-label "!princ"       format ">>>>>9.99"

        ttcontrato.vlr_abertoEP column-label "EP!aberto"       format ">>>>>9.99"
        ttcontrato.vlr_abprincEP column-label "!princ"       format ">>>>>9.99"

        ttcontrato.vlr_abertoCDC column-label "CDC!aberto"    format ">>>>>9.99"
        ttcontrato.vlr_abprincCDC column-label "!princ"       format ">>>>>9.99"
        
        
        with frame frame-a 5 down centered row 10 no-box.


run montatt.

disp
    skip(1)
    space(11)
    "  TOTAL" vvlr_aberto   format ">>>>>9.99"
    vvlr_abprinc            format ">>>>>9.99"
    vvlr_abertoEP           format ">>>>>9.99"
    vvlr_abprincEP          format ">>>>>9.99"
    vvlr_abertoCDC          format ">>>>>9.99"
    vvlr_abprincCDC         format ">>>>>9.99"

    skip
    space(11)
    " NORMAL" vvlr_abertoNORM   format ">>>>>9.99"
    vvlr_abprincNORM            format ">>>>>9.99"
    vvlr_abertoEPNORM           format ">>>>>9.99"
    vvlr_abprincEPNORM          format ">>>>>9.99"
    vvlr_abertoCDCNORM          format ">>>>>9.99"
    vvlr_abprincCDCNORM         format ">>>>>9.99"

    skip
    space(11)
    "NOVACAO" vvlr_abertoNOV   format ">>>>>9.99"
    vvlr_abprincNOV            format ">>>>>9.99"
    vvlr_abertoEPNOV           format ">>>>>9.99"
    vvlr_abprincEPNOV          format ">>>>>9.99"
    vvlr_abertoCDCNOV          format ">>>>>9.99"
    vvlr_abprincCDCNOV         format ">>>>>9.99"
    
    with frame ftot row 18 centered   no-labels width 81 no-box.



bl-princ:
repeat:



    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
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
        
                        
        find first neuclien where neuclien.clicod = par-clicod no-lock no-error.
        esqcom1[2] = if avail neuclien then " props" else "".
                     
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

        choose field contrato.contnum
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                /**if ttcontrato.marca = no
                then**/  run color-normal.
                /**                else run color-input. **/
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
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = " consulta"
            then do:
                run conco_v1701.p (string(ttcontrato.contnum)).
                
            end.
            if esqcom1[esqpos1] = " props"
            then do:
                
                run neuro/mostra_comportamento.p (input recid(neuclien)).            
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

procedure frame-a.
    find contrato of ttcontrato no-lock.    
    display  
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato
        ttcontrato.vlr_aberto
        ttcontrato.vlr_abprinc

        ttcontrato.vlr_abertoEP
        ttcontrato.vlr_abprincEP

        ttcontrato.vlr_abertoCDC
        ttcontrato.vlr_abprincCDC
        

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato
        ttcontrato.vlr_aberto
        ttcontrato.vlr_abprinc

        ttcontrato.vlr_abertoEP
        ttcontrato.vlr_abprincEP
 ttcontrato.vlr_abertoCDC
        ttcontrato.vlr_abprincCDC
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato
        ttcontrato.vlr_aberto
        ttcontrato.vlr_abprinc

        ttcontrato.vlr_abertoEP
        ttcontrato.vlr_abprincEP

 ttcontrato.vlr_abertoCDC
        ttcontrato.vlr_abprincCDC
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato
        ttcontrato.vlr_aberto
        ttcontrato.vlr_abprinc

        ttcontrato.vlr_abertoEP
        ttcontrato.vlr_abprincEP
 ttcontrato.vlr_abertoCDC
        ttcontrato.vlr_abprincCDC

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttcontrato 
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttcontrato 
                no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ttcontrato 
                no-lock no-error.

end.    
        
end procedure.





procedure montatt.
def var vtitdes as dec.
for each contrato where contrato.clicod = par-clicod no-lock.
    for each titulo where titulo.empcod = 19        and
                           titulo.titnat = no        and
                           titulo.modcod = contrato.modcod and
                           titulo.etbcod = contrato.etbcod and
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum)
                           no-lock:
        
        if titulo.modcod = "CHQ" or
           titulo.modcod = "DEV" or
           titulo.modcod = "BON" or
           titulo.modcod = "VVI" or   /* #5 Sujeira de banco */
           length(titulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/
                vtitdes = 0.
                if contrato.vlseguro > 0 and
                   titulo.titdes = 0
                then vtitdes = contrato.vlseguro / contrato.nro_parcela.  
                if titulo.titdes > 0
                then vtitdes = titulo.titdes.
                
                if titulo.titsit = "LIB"
                then.
                else next.
                
                find first ttcontrato where ttcontrato.contnum = contrato.contnum no-error.
                if not avail ttcontrato
                then do:
                    create ttcontrato.
                    ttcontrato.contnum     = contrato.contnum.
                    ttcontrato.tpcontrato  = if titulo.modcod = "CPN" then "N" else titulo.tpcontrato.
                    if titulo.vlf_hubseg > 0
                    then ttcontrato.tpcontrato = "H".
                end.
                ttcontrato.vlr_aberto   = ttcontrato.vlr_aberto + titulo.titvlcob.
                
                ttcontrato.vlr_abertoEP = ttcontrato.vlr_abertoEP + if titulo.modcod begins "CP"
                                                                    then titulo.titvlcob
                                                                    else 0. 
                ttcontrato.vlr_abertoCDC = ttcontrato.vlr_abertoCDC + if titulo.modcod begins "CP"
                                                                      then 0
                                                                      else titulo.titvlcob.
                                                                    
                if titulo.vlf_principal > 0 
                then do:
                        ttcontrato.vlr_abprinc   = ttcontrato.vlr_abprinc + titulo.vlf_principal.
                        if titulo.vlf_hubseg > 0
                        then do:
                            ttcontrato.vlr_abprinc   = ttcontrato.vlr_abprinc - titulo.vlf_hubseg.
                        end.

                        if titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */
                        then ttcontrato.vlr_abprinc   = ttcontrato.vlr_abprinc - vtitdes . /* retira o seguro */
                        
                        if titulo.modcod begins "CP"
                        then do:
                            ttcontrato.vlr_abprincEP = ttcontrato.vlr_abprincEP + titulo.vlf_principal.
                            if titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */
                            then ttcontrato.vlr_abprincEP = ttcontrato.vlr_abprincEP - vtitdes . /* retira o seguro */
                        end.        
                        else do:
                            ttcontrato.vlr_abprincCDC   = ttcontrato.vlr_abprincCDC + titulo.vlf_principal.
                            if titulo.vlf_hubseg > 0
                            then do:
                                ttcontrato.vlr_abprincCDC   = ttcontrato.vlr_abprincCDC - titulo.vlf_hubseg.
                            end.
        
                            if titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */
                            then ttcontrato.vlr_abprincCDC   = ttcontrato.vlr_abprincCDC - vtitdes . /* retira o seguro */
                        
                        end.
                          
                                  
                end.
                else do:
                        ttcontrato.vlr_abprinc   = ttcontrato.vlr_abprinc  + titulo.titvlcob.
                        if titulo.modcod begins "CP"
                        then do:
                            ttcontrato.vlr_abprincEP = ttcontrato.vlr_abprincEP + titulo.titvlcob.
                        end. 
                        else do: 
                            ttcontrato.vlr_abprincCDC   = ttcontrato.vlr_abprincCDC  + titulo.titvlcob.
                        end.    

                end.    

    end.
end.


    vvlr_aberto    = 0.
    vvlr_abprinc   = 0.
    vvlr_abertoEP  = 0.
    vvlr_abprincEP  = 0.
    vvlr_abertoCDC = 0.
    vvlr_abprincCDC = 0.

    vvlr_abertoNOV    = 0.
    vvlr_abprincNOV    = 0.
    vvlr_abertoEPNOV    = 0.
    vvlr_abprincEPNOV    = 0.
    vvlr_abertoCDCNOV = 0.
    vvlr_abprincCDCNOV = 0.

    vvlr_abertoNORM    = 0.
    vvlr_abprincNORM    = 0.
    vvlr_abertoEPNORM    = 0.
    vvlr_abprincEPNORM    = 0.
    vvlr_abertoCDCNORM = 0.
    vvlr_abprincCDCNORM = 0.


 
for each ttcontrato.
    find contrato of ttcontrato no-lock.


    vvlr_aberto   = vvlr_aberto + ttcontrato.vlr_aberto.
    vvlr_abprinc   = vvlr_abprinc + ttcontrato.vlr_abprinc.


    if ttcontrato.tpcontrato = "N"
    then do: 
        vvlr_abertoNOV    = vvlr_abertoNOV + ttcontrato.vlr_aberto. 
        vvlr_abprincNOV   = vvlr_abprincNOV + ttcontrato.vlr_abprinc.
    end.
    else do: 
        vvlr_abertoNORM   = vvlr_abertoNORM + ttcontrato.vlr_aberto. 
        vvlr_abprincNORM  = vvlr_abprincNORM + ttcontrato.vlr_abprinc.
    end.

    if contrato.modcod BEGINS "CP"
    then do:
    
        if ttcontrato.tpcontrato = "N"
        then do: 
            vvlr_abertoEPNOV   = vvlr_abertoEPNOV + ttcontrato.vlr_abertoEP.
            vvlr_abprincEPNOV   = vvlr_abprincEPNOV + ttcontrato.vlr_abprincEP.
        end.        
        else do: 
            vvlr_abertoEPNORM  = vvlr_abertoEPNORM + ttcontrato.vlr_abertoEP.
            vvlr_abprincEPNORM  = vvlr_abprincEPNORM + ttcontrato.vlr_abprincEP.
        end.     

        vvlr_abertoEP   = vvlr_abertoEP + ttcontrato.vlr_abertoEP.
        vvlr_abprincEP  = vvlr_abprincEP + ttcontrato.vlr_abprincEP.

    end.
    else do:
        if ttcontrato.tpcontrato = "N"
        then do: 
            vvlr_abertoCDCNOV   = vvlr_abertoCDCNOV + ttcontrato.vlr_abertoCDC.
            vvlr_abprincCDCNOV   = vvlr_abprincCDCNOV + ttcontrato.vlr_abprincCDC.
        end.            
        else do: 
            vvlr_abertoCDCNORM   = vvlr_abertoCDCNORM + ttcontrato.vlr_abertoCDC.
            vvlr_abprincCDCNORM   = vvlr_abprincCDCNORM + ttcontrato.vlr_abprincCDC.
        end.            

        vvlr_abertoCDC   = vvlr_abertoCDC + ttcontrato.vlr_abertoCDC.
        vvlr_abprincCDC   = vvlr_abprincCDC + ttcontrato.vlr_abprincCDC.
        
    end.
    
end.
    
end procedure.    

