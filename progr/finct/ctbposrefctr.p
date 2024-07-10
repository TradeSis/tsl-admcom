/*11062021 helio*/

{admcab.i}

def var pfiltro as char.

def input param pmodcod   as char.
def input param ptpcontrato as char.
def input param petbcod  as int. 
def input param pcobcod  as int.

def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
def shared temp-table tt-modalidade-selec 
    field modcod as char.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<Parcelas>","<Contrato>"," "," "," "].
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/**if poperacao = "NOVACAO"
then esqcom1[3] = "<Novacao>".
**/

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


def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    index idx is unique primary tipo desc contnum asc.


def  temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field contnum   like contrato.contnum
    field cobcod    like ctbposhiscart.cobcod
    field tpcontrato like ctbposhiscart.tpcontrato
    field saldo     like contrato.vltotal
    field qtdtit    like ctbposhiscart.qtd
    field vencini   like titulo.titdtven
    field vencfim   like titulo.titdtven
    index contnum   is unique primary
        contnum asc cobcod asc.
        
def buffer bttcontrato for ttcontrato.
        
def var vfiltro as char.

    vfiltro = "-". /*caps(poperacao) + "/" + caps(pstatus).*/
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        ttcontrato.marca format "*/ " column-label "*"
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        contrato.modcod
        ttcontrato.tpcontrato column-label "Tp" format "x"
        ttcontrato.cobcod 
        contrato.clicod 
        contrato.vlentra       column-label "entrada"
                                     format ">>>9.99"
        
        
        contrato.vltotal       column-label "total" 
                                     format ">>>>>9.99"
        
        contrato.nro_parcela   column-label "par"
                                  format    ">>9"
        ttcontrato.saldo column-label "saldo" format ">>>>>9.99" 
        ttcontrato.qtdtit column-label "par!sal" format ">>9"

        with frame frame-a 9 down centered row 7
        no-box.

def var vtotal    as dec init 0.
def var vqtdtotal as int init 0.
def var vqtdarq   as dec.  


        
run montatt.

def var vqtdarqint as int.
vqtdarq = vqtdtotal / 1048570.
vqtdarqint = int(round(vqtdarq,0)).
vqtdarq = vqtdarq - vqtdarqint.
if vqtdarq > 0
then vqtdarqint = vqtdarqint + 1.

disp 
    vqtdtotal label "Qtd Contratos" format ">>>>>>>>9" at 14 
    vqtdarqint label "Arquivos" format ">>9"
    vtotal    label "   Total" format "->>>>,>>>,>>9.99" at 52

        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.




bl-princ:
repeat:


disp
    vqtdtotal vtotal   

        with frame ftot.

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
        
                        
        /**                        
        esqcom1[1] = if ttcontrato.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttcontrato.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttcontrato.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttcontrato.carteira = ? or
                        ttcontrato.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttcontrato.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttcontrato.cobcod = ?
                     then "Propriedade"
                     else "".
        **/
                     
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
            
            if esqcom1[esqpos1] = "<contrato>"
            then do:
                run conco_v1701.p (ttcontrato.contnum).
            end.
            if esqcom1[esqpos1] = "<parcelas>"
            then do:
                run finct/ctbposrefctrpar.p (ttcontrato.contnum, ttcontrato.cobcod).
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
    find contrato where contrato.contnum = ttcontrato.contnum no-lock.    
    display  
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.modcod
        ttcontrato.tpcontrato
        ttcontrato.cobcod
        
        contrato.vltotal
        contrato.nro_parcela
        ttcontrato.saldo
        ttcontrato.qtdtit
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlentra        
        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
                contrato.vlentra

        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
                contrato.vlentra

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


procedure montatt.
def var vtpcontrato like contrato.tpcontrato.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".
def var vtp as int.
def var ctp as char extent 4 init ["F","N","L"," "].
def var vdtvenc as date.
def var vtime as int.
def var vconta as int.
def var vcontac as int. 
vtime = time.
vtotal = 0.
vqtdtotal =0.
for each ttcontrato.
    delete ttcontrato.
end.
                                            
for each cobra 
    where if pcobcod <> ?
          then cobra.cobcod = pcobcod
          else true
    no-lock.
    for each tt-modalidade-selec where
        if pmodcod <> ?
        then tt-modalidade-selec.modcod = pmodcod 
        else true
        no-lock.    
        do vtp = 1 to 4:
            if ptpcontrato <> ?
            then if ctp[vtp] = ptpcontrato
                 then.
                 else next.
            for each estab where
                if petbcod <> ?
                then estab.etbcod = petbcod
                else true
              no-lock.
              if vetbcod <> 0 
              then if estab.etbcod <> vetbcod
                   then next.
                for each ctbposhiscart where
                        ctbposhiscart.cobcod = cobra.cobcod and
                        ctbposhiscart.modcod = tt-modalidade-selec.modcod and
                        ctbposhiscart.tpcontrato = ctp[vtp] and
                        ctbposhiscart.etbcod = estab.etbcod and
                        (ctbposhiscart.dtrefSAIDA > vdtfin )   and
                        ctbposhiscart.dtref      <= vdtini
                        no-lock .

                    if ctbposhiscart.dtrefSAIDA = ctbposhiscart.dtref
                    then next.
                    find contrato where contrato.contnum = ctbposhiscart.contnum no-lock no-error.
                    if not avail contrato then next.
                    find first titulo where titulo.empcod = 19 and titulo.titnat = no and
                            titulo.etbcod = contrato.etbcod and
                            titulo.modcod = contrato.modcod and
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titpar = ctbposhiscart.titpar
                            and recid(titulo) = ctbposhiscart.trecid
                            no-lock no-error.

                    find first ttcontrato where ttcontrato.contnum = ctbposhiscart.contnum and
                                                ttcontrato.cobcod  = cobra.cobcod
                                        no-error.
                    if not avail ttcontrato
                    then do:                        
                        create ttcontrato.
                        ttcontrato.contnum = ctbposhiscart.contnum.
                        ttcontrato.cobcod  = cobra.cobcod.
                        vqtdtotal = vqtdtotal + 1.
                    end.
                    vconta = vconta + 1.
                    if vconta mod 1000 = 0 or vconta = 1
                    then do:
                        hide message no-pause.
                        message color normal "fazendo calculos... aguarde..." vconta "Parcelas" vqtdtotal "Contratos" string(time - vtime,"HH:MM:SS").
                    end.                
                    
                    vdtvenc =   if avail titulo
                                then titulo.titdtven 
                                else contrato.dtinicial.
                                
                    ttcontrato.vencini    = if ttcontrato.vencini = ?
                                              then vdtvenc
                                              else min(ttcontrato.vencini,vdtvenc).
                    ttcontrato.vencfim    = if ttcontrato.vencfim = ?
                                              then vdtvenc
                                              else max(ttcontrato.vencfim,vdtvenc).
                    
                    
                    ttcontrato.tpcontrato = ctbposhiscart.tpcontrato.
                    ttcontrato.saldo = ttcontrato.saldo + ctbposhiscart.valor.
                    ttcontrato.qtdtit = ttcontrato.qtdtit + 1.     
                    vtotal = vtotal + ctbposhiscart.valor.
                end.
            end.
        end.
    end.
                                        
end.

hide message no-pause.
           
end procedure.



procedure geracsv.

def var varquivos as char.
    def var ccarteira as char.
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/ctb/carteira" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_posicao" + string(vdtfin,"99999999") + 
                             "_analitico"   + string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
   
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title string(vqtdarqint) + " arquivo de saida".

def var vregistros as int.     
   
    for each ttcontrato.
        if vregistros = 0
        then do:
            vi = vi + 1.
            varquivos = varq + string(vi) + ".csv".
            output to value(varquivos).    
                put unformatted 
                    vfiltro skip.
                vregistros = vregistros + 1.    
                put unformatted
                "Codigo" vcp
                "Nome"   vcp
                "CPF"    vcp 
                "Contrato" vcp    
                "Carteira" vcp    
                "Valor"   vcp
                "Emissão" vcp
                "Vencimento_inicial"  vcp
                "Vencimento_final"    vcp
                "Modalidade"  vcp
                "Filial"  vcp
                "Tipo de cobrança" vcp
                "Data Referencia" vcp
                skip.
                vregistros = vregistros + 1.    
        end.
        
        find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
            if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        
        
        find cobra where cobra.cobcod = ttcontrato.cobcod no-lock no-error.
        find modal where modal.modcod = contrato.modcod no-lock no-error.
        ccarteira = (if ttcontrato.cobcod <> ? 
                 then string(ttcontrato.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").

        ctpcontrato = if ttcontrato.tpcontrato <> ? 
                then if ttcontrato.tpcontrato = "F"
                     then "FEIRAO"
                     else if ttcontrato.tpcontrato = "N"
                          then "NOVACAO"
                          else if ttcontrato.tpcontrato = "L"
                               then "LP "
                               else "normal "
                else     "-".

        cmodnom = if contrato.modcod <> ? 
                then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                else "-".
        
        put unformatted
            
            contrato.clicod     vcp
            if avail clien then clien.clinom else "-"       vcp
            if avail clien then clien.ciccgc else "-"       vcp
            contrato.contnum    vcp
            ccarteira           vcp
            ttcontrato.saldo    vcp
            contrato.dtinicial  vcp
            ttcontrato.vencini            vcp
            ttcontrato.vencfim            vcp    
            cmodnom             vcp
            contrato.etbcod     vcp
            ctpcontrato         vcp
            vdtfin              vcp
               skip.
        vregistros = vregistros + 1.
        if vregistros = 1048570
        then do:
            output close.
            vregistros = 0.
        end.
    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.



