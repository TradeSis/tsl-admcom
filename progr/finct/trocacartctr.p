/** programa nao utilizado */


/* helio 20122021 - Melhorias contas a receber fase II - Data de Troca é a Emissão do Contrato */
{admcab.i}

def input param varqout as char.

return.
/*****
def var pfiltro as char.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<parcelas>","","  <marca>","  <todos> ",""].
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var par-dtini as date.

def shared temp-table ttcontrato no-undo
    field marca     as log 
    field contnum   like titulo.titnum
    field titpar    like titulo.titpar  init ? 
    field cobcod    like titulo.cobcod
    index contnum   is unique primary
        contnum asc titpar asc.
        
def buffer bttcontrato for ttcontrato.


    pause 0.
          
    form  
        ttcontrato.marca format "*/ " column-label "*"

        cobra.cobnom format "x(07)" column-label "prop"
        contrato.dtinicial format "999999" column-label "data"
        
        contrato.etbcod column-label "Fil"
        contrato.modcod  format "x(03)" column-label "mod"
        contrato.tpcontrato format "x" column-label "tp"
        
        contrato.contnum format ">>>>>>>>>9"
        contrato.clicod 
        
        contrato.vltotal       column-label "total" 
                                     format ">>>>>9.99"
        
        contrato.nro_parcela   column-label "par"
                                  format    ">>9"
         skip space(12) "-->>" sicred_contrato.descerro no-label
         skip(1)
        with frame frame-a 5 down centered row 5
        no-box no-underline.



bl-princ:
repeat:


/**disp
    vtitvlcob
    vjuros
    vdescontos
    vtotal   

        with frame ftot.
**/

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

        if ttcontrato.marca
        then esqcom1[5] = "<cancela>"        .
        else esqcom1[5] = "". 
        esqcom1[1] = "<parcelas>".
        esqcom1[3] = "  <marca>".
        esqcom1[4] = "  <todos> ".
                        
                     
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
                      help "[E]xporta para Arquivo csv"

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      E e
                      tab PF4 F4 ESC return).

                if ttcontrato.marca = no
                then run color-normal.
                else run color-input. 
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
            if esqcom1[esqpos1] = "<parcelas>"
            then do:
                run conco_v1701.p (string(ttcontrato.contnum)).
            end.
            if esqcom1[esqpos1] = "<cancela>"
            then do:
                message "Confirma cancelamento do Envio para Financeira?" update sresp.
                if not sresp then leave.
                
                def var voutcobcod as int.            
                for each bttcontrato where bttcontrato.marca = yes.

                    /* helio 15122021 - Melhorias contas a receber fase II - Data de Troca é a Emissão do Contrato */                
                    find contrato where contrato.contnum =  int(bttcontrato.contnum) no-lock.                    
                    run finct/trocacart.p (1,contrato.dtinicial, YES /* ate os pagos */ , contrato.contnum,? /*todos*/).
                    
                end.

                run outcontratos. 
                return.
            end.
                        
            if esqcom1[esqpos1] = "  <marca>"
            then do:
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
hide frame fcab no-pause.

procedure frame-a.

    find contrato where contrato.contnum = int(ttcontrato.contnum) no-lock no-error.    
    find first titulo where titulo.titnat = no and titulo.empcod = 19 and titulo.etbcod = contrato.etbcod
            and titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum) and
            titulo.titsit = "LIB"
            no-lock no-error.
    release cobra.
    if avail titulo
    then do:
        find cobra of titulo no-lock.
    end.    

    display  
        ttcontrato.marca
        cobra.cobnom        when avail cobra
        contrato.dtinicial
        contrato.etbcod  when avail contrato
        contrato.modcod when avail contrato

        contrato.tpcontrato  when avail contrato
        contrato.contnum 
        contrato.clicod   when avail contrato

        contrato.vltotal  when avail contrato

        contrato.nro_parcela  when avail contrato

        with frame frame-a.

end procedure.

procedure color-message.
    color display message
        ttcontrato.marca

        cobra.cobnom        
        
        contrato.etbcod 
        contrato.modcod
        contrato.tpcontrato
        
        contrato.contnum 
        contrato.clicod 
        contrato.vltotal
        contrato.nro_parcela
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.marca
        cobra.cobnom        
        
        contrato.etbcod 
        contrato.modcod
        contrato.tpcontrato
        
        contrato.contnum 
        contrato.clicod 
        contrato.vltotal
        contrato.nro_parcela
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.marca

        cobra.cobnom        
        
        contrato.etbcod 
        contrato.modcod
        contrato.tpcontrato
        
        contrato.contnum 
        contrato.clicod 
        contrato.vltotal
        contrato.nro_parcela
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





procedure outcontratos.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var vdtout  as date format "99/99/9999" label "Data" init today. 
   def var varqin  as char format "x(65)".

def var vtitvlpag as dec.
def var vvlrpago  as dec.        
   def var vcp  as char init ";".

    
    disp  
            skip(2) varqout label "Saida"   colon 10 skip(2)
                   with
        centered 
        overlay
        side-labels
        color messages
       row 5.
 
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
                                                
                                                
    for each ttcontrato where ttcontrato.marca = yes.
        
        find contrato where contrato.contnum = int(ttcontrato.contnum) no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.

            find cobra where cobra.cobcod = sicred_contrato.cobcod no-lock no-error.
            find dcobra where dcobra.cobcod = 1 no-lock.
        
            find modal where modal.modcod = contrato.modcod no-lock no-error.
            ccarteira = (if sicred_contrato.cobcod <> ? 
                     then string(sicred_contrato.cobcod) + if avail cobra 
                                               then ("-" + cobra.cobnom)
                                               else ""
                     else "-").
            dcarteira = (if 1 <> ? 
                     then string(1) + if avail dcobra 
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
                /*
                titulo.titpar       vcp
                */
                ccarteira      vcp 
                vdtout             format "99/99/9999"  vcp
                dcarteira           vcp
                cmodnom             vcp
                contrato.etbcod     vcp
                ctpcontrato         vcp
                /*
                titulo.titdtven      vcp
                */
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
end procedure.    

***/

