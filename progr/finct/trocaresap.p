/* 09022023 helio ID 155965 */
/* helio 20122021 - Melhorias contas a receber fase II  */

{admcab.i}

def input param vdtini as date format "99/99/9999" label "De".
def input param vdtfin as date format "99/99/9999" label "Ate".              

def var vtotal  as dec.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(09)" extent 7
    initial [" csv",""].

form
    esqcom1
    with frame f-com1 row 8 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def temp-table tttrocactr no-undo
    field dtenvsap         like ctbtrocart.dtenvsap
    field dtrefSAIDA    like ctbtrocart.dtrefsaida
    field cobcodSAIDA   like ctbtrocart.cobcodSAIDA
    field cobcodENTRADA like ctbtrocart.cobcodENTRADA

    field valor     like pdvdoc.valor format       "->>>>>>>9.99" column-label "total"

    index idx is unique primary 
        dtenvsap   asc
        dtrefsaida asc
        cobcodSAIDA asc
        cobcodENTRADA asc.

def temp-table ttcontrato no-undo
    field contnum           like contrato.contnum
    field dtenvsap             like tttrocactr.dtenvsap
    field dtrefSAIDA        like tttrocactr.dtrefSAIDA
    field cobcodSAIDA       like tttrocactr.cobcodSAIDA 
    field cobcodENTRADA     like tttrocactr.cobcodENTRADA
    field vlf_principal     like contrato.vlf_principal
    field vlf_acrescimo     like contrato.vlf_acrescimo
    field vlseguro          like contrato.vlseguro
    field vltotal           like contrato.vltotal
    field titvlabe          as dec
    field titvlpag          as dec
    field vlrpago           as dec
    field desagio           as dec
    field motivo            like ctbtrocart.motivo
    index x is unique primary contnum asc dtenvsap asc dtrefsaida asc cobcodSAIDA asc cobcodENTRADA asc.
    

def buffer btttrocactr for tttrocactr.
def buffer ocobra for cobra.
def buffer dcobra for cobra.
        
    form  
        tttrocactr.dtenvsap      format "99/99/9999" column-label "Dt!Oper"
        tttrocactr.dtrefsaida format "99/99/9999" column-label "Dt!Ctb"
        tttrocactr.cobcodSAIDA column-label "Car!Orig"
        ocobra.cobnom          no-label 
        tttrocactr.cobcodENTRADA column-label "Car!Dest"
        dcobra.cobnom          no-label 
        tttrocactr.valor        
        with frame frame-a 6 down centered row 9
        no-box.
        
run montatt .


disp 
    space(62)
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.



bl-princ:
repeat:
    
    for each btttrocactr.
        vtotal = vtotal + btttrocactr.valor.
    end.
    
disp
    vtotal   

        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tttrocactr where recid(tttrocactr) = recatu1 no-lock.
    if not available tttrocactr
    then do.
            return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tttrocactr).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tttrocactr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tttrocactr where recid(tttrocactr) = recatu1 no-lock.

        status default "".
            
        
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 7.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 7.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field tttrocactr.dtenvsap

                help  "escolha opcao"

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
                      
                       run color-normal.
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
                    if not avail tttrocactr
                    then leave.
                    recatu1 = recid(tttrocactr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tttrocactr
                    then leave.
                    recatu1 = recid(tttrocactr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tttrocactr
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tttrocactr
                then next.
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
                run outcontratos.
            end.
            
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tttrocactr).
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

    find ocobra where ocobra.cobcod = tttrocactr.cobcodSAIDA no-lock.
    find dcobra where dcobra.cobcod = tttrocactr.cobcodENTRADA no-lock.

    display  
        tttrocactr.dtenvsap
        tttrocactr.dtrefsaida 
        tttrocactr.cobcodSAIDA 
        ocobra.cobnom     
        tttrocactr.cobcodENTRADA 
        dcobra.cobnom   
        tttrocactr.valor        
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        tttrocactr.dtenvsap                    
        tttrocactr.dtrefsaida 
        tttrocactr.cobcodSAIDA 
        ocobra.cobnom     
        tttrocactr.cobcodENTRADA 
        dcobra.cobnom   
        tttrocactr.valor        

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
    tttrocactr.dtenvsap
        tttrocactr.dtrefsaida 
        tttrocactr.cobcodSAIDA 
        ocobra.cobnom     
        tttrocactr.cobcodENTRADA 
        dcobra.cobnom   
        tttrocactr.valor        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first tttrocactr  where
                no-lock no-error.
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next tttrocactr  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev tttrocactr  where
                no-lock no-error.

end.    
        
end procedure.


procedure montatt.

def var vconta as int init 0.
def var vtime as int.
vtime = time. 
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each tttrocactr.
    delete tttrocactr.
end.

for each ctbtrocart where (ctbtrocart.dtenvsap >= vdtini and ctbtrocart.dtenvsap <= vdtfin) or ctbtrocart.dtenvsap = ? no-lock.

    find contrato of ctbtrocart no-lock.
    find first tttrocactr where         
        tttrocactr.dtenvsap        = ctbtrocart.dtenvsap and
        tttrocactr.dtrefsaida   = ctbtrocart.dtrefSAIDA and
        tttrocactr.cobcodSAIDA  = ctbtrocart.cobcodSAIDA and
        tttrocactr.cobcodENTRADA = ctbtrocart.cobcodENTRADA
        no-error. 
    if not avail tttrocactr 
    then do:
        create tttrocactr.  
        tttrocactr.dtenvsap        = ctbtrocart.dtenvsap.
        tttrocactr.dtrefsaida   = ctbtrocart.dtrefSAIDA.
        tttrocactr.cobcodSAIDA  = ctbtrocart.cobcodSAIDA.
        tttrocactr.cobcodENTRADA = ctbtrocart.cobcodENTRADA.
    end. 
    tttrocactr.valor = tttrocactr.valor + ctbtrocart.valor.

    find first ttcontrato where
        ttcontrato.contnum = ctbtrocart.contnum and
        ttcontrato.dtenvsap        = ctbtrocart.dtenvsap and
        ttcontrato.dtrefsaida   = ctbtrocart.dtrefSAIDA and
        ttcontrato.cobcodSAIDA  = ctbtrocart.cobcodSAIDA and
        ttcontrato.cobcodENTRADA = ctbtrocart.cobcodENTRADA
        
        no-error.
    if not avail ttcontrato
    then do:
        create ttcontrato.
        ttcontrato.contnum = ctbtrocart.contnum.
        ttcontrato.dtenvsap        = ctbtrocart.dtenvsap.
        ttcontrato.dtrefsaida   = ctbtrocart.dtrefSAIDA.
        ttcontrato.cobcodSAIDA  = ctbtrocart.cobcodSAIDA.
        ttcontrato.cobcodENTRADA = ctbtrocart.cobcodENTRADA.
        ttcontrato.motivo = ctbtrocart.motivo.
    end. 
    find first titulo where
            titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum) and
            titulo.titpar = ctbtrocart.titpar
            no-lock no-error.
    if avail titulo
    then do:
        ttcontrato.vlf_principal = ttcontrato.vlf_principal + titulo.vlf_principal.
        ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + titulo.vlf_acrescimo.
        ttcontrato.vlseguro      = ttcontrato.vlseguro      + titulo.titdes.
        ttcontrato.vltotal       = ttcontrato.vltotal       + titulo.titvlcob.
        if titulo.titsit = "LIB"
        then do:
            ttcontrato.titvlabe = ttcontrato.titvlabe + titulo.titvlcob.
        end.   
        if titulo.titsit = "PAG" 
        then do:
            if titulo.titdtpag > ctbtrocart.dtrefsaida
            then do: /* estava em aberto */
                ttcontrato.titvlabe = ttcontrato.titvlabe + titulo.titvlcob.
            end.
            else do:      
                ttcontrato.titvlpag = ttcontrato.titvlpag + titulo.titvlpag.
                ttcontrato.vlrpago  = ttcontrato.vlrpago  + titulo.titvlcob.
            end.
        end.    

            find first titulolog where
                titulolog.empcod = titulo.empcod and
                titulolog.titnat = titulo.titnat and
                titulolog.modcod = titulo.modcod and
                titulolog.etbcod = titulo.etbcod and
                titulolog.clifor = titulo.clifor and
                titulolog.titnum = titulo.titnum and
                titulolog.titpar = titulo.titpar and
                titulolog.campo   = "Desagio"
                no-lock no-error.
            if avail titulolog
            then do:
                ttcontrato.desagio = ttcontrato.desagio + titulo.titvlcob - dec(titulolog.valor).
            end.
                                  

    end.
    
end.

hide message no-pause.
            
end procedure.




procedure outcontratos.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varqout  as char format "x(65)".

def var vtitvlpag as dec.
def var vvlrpago  as dec.        
def var vtitvlabe as dec.
   def var vcp  as char init ";".

    
    varqout = "/admcom/tmp/ctb/" + "contratoscart" + "_" +
                                   string(tttrocactr.cobcodsaida) + "_" +
                                   string(tttrocactr.cobcodENTRADA) + "_" +
                                   string(tttrocactr.dtrefsaida,"99999999") + "_" +
                     string(today,"999999")  + string(time) + "_.csv".
    
    update  
            skip(2) varqout label "Saida"   colon 10 skip(2)
                   with
        centered 
        overlay
        side-labels
        color messages
       row 7 title " ARQUIVO SAIDA PARA CONTABILIDADE ".

 
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
        "Vlr Aberto" vcp
        "Desagio" vcp 
        "Motivo" vcp
        skip.
                                                

    
    for each ttcontrato of tttrocactr.

       find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.

            find cobra where cobra.cobcod   = ttcontrato.cobcodSAIDA no-lock no-error.
            find dcobra where dcobra.cobcod = ttcontrato.cobcodENTRADA no-lock.
        
            find modal where modal.modcod = contrato.modcod no-lock no-error.
            ccarteira = (if ttcontrato.cobcodSAIDA <> ? 
                     then string(ttcontrato.cobcodSAIDA) + if avail cobra 
                                               then ("-" + cobra.cobnom)
                                               else ""
                     else "-").
            dcarteira = (if ttcontrato.cobcodENTRADA <> ? 
                     then string(ttcontrato.cobcodENTRADA) + if avail dcobra 
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
                ttcontrato.dtrefSAIDA             format "99/99/9999"  vcp
                dcarteira           vcp
                cmodnom             vcp
                contrato.etbcod     vcp
                ctpcontrato         vcp
                trim(string(contrato.vlentra,">>>>>9.99")) vcp
                trim(string(ttcontrato.vlf_principal,">>>>>9.99")) vcp
                trim(string(ttcontrato.vlf_acrescimo,">>>>>9.99")) vcp
                trim(string(ttcontrato.vlseguro,">>>>>9.99")) vcp
                trim(string(ttcontrato.vltotal,">>>>>9.99")) vcp .
        
        put unformatted 
            trim(string(ttcontrato.vlrpago,">>>>>9.99")) vcp
            trim(string(ttcontrato.titvlpag - ttcontrato.vlrpago,">>>>>9.99")) vcp
            trim(string(ttcontrato.titvlpag,">>>>>9.99")) vcp
            trim(string(ttcontrato.titvlabe,">>>>>9.99")) vcp
            trim(string(ttcontrato.desagio,">>>>>9.99")) vcp
                
            ttcontrato.motivo vcp
            skip.
                
    end.
    output close.
end procedure.    




