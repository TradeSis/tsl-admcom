/* helio 082023 - CESSÃO BARU - ORQUESTRA 536437 */
/* helio 15052023 - Melhoria - IOF na base diária da Carteira */
/* helio 20122021 - Melhorias contas a receber fase II  */
/* helio 07122021 id 97063 */

{admcab.i}
def buffer btitulo for titulo.

def var vcontnum as dec.
def var pfiltro as char.
def input param poperacao   like sicred_contrato.operacao.
def input param poldcobcod     like sicred_contrato.cobcod.
def input param poldctmcod     like sicred_contrato.ctmcod.
def input param poldmodcod     like contrato.modcod.
def input param poldtpcontrato like contrato.tpcontrato.
def input param poldetbcod  as int.

def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<parcelas>","<Operacao>"," "," "," "].
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

if poperacao = "NOVACAO"
then esqcom1[3] = "<Novacao>".
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


def  temp-table ttcontrato no-undo
    field contnum like contrato.contnum
    field precid   as recid
    index idx is unique primary 
        precid asc.
        
def buffer bttcontrato for ttcontrato.
        
def var vfiltro as char.

    vfiltro = caps(poperacao).
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        contrato.clicod 
        contrato.vlentra       column-label "entrada"
                                     format ">>>9.99"
        contrato.vlf_principal column-label "principal"
                                     format ">>>>>9.99"
        
        contrato.vlf_acrescimo column-label "acrescimo"
                                     format "->>>>>9.99"
        
        contrato.vlseguro      column-label " seguro"
                                     format ">>>9.99"
        
        contrato.vltotal       column-label "total" 
                                     format ">>>>>9.99"
        
        contrato.nro_parcela   column-label "par"
                                  format    ">>9"

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



/**disp 
    space(32)
    vtitvlcob    no-label          format   "-zzzzzzz9.99"
    vjuros       no-label           format     "-zzzzz9.99"
    vdescontos   no-label        format     "-zzzzz9.99"
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.
**/


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
            if esqcom1[esqpos1] = "<operacao>"
            then do:
                find first pdvmov where recid(pdvmov) = ttcontrato.precid no-lock no-error.

                if avail  pdvmov
                then run dpdv/pdvcope.p (recid(pdvmov)).
            end.
            /**
            if esqcom1[esqpos1] = "<novacao>"
            then do:
                find sicred_contrato where recid(sicred_contrato) = ttcontrato.psicred
                    no-lock.
                find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock .
                    hide frame f-com1 no-pause.
                    find pdvtmov where pdvtmov.ctmcod = pdvmov.ctmcod no-lock.
                    if pdvtmov.novacao
                    then run fin/fqnovmov.p (recid(pdvmov)).

            end.
            **/
            
                
             
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
    find contrato where contrato.contnum =  ttcontrato.contnum no-lock.    
    display  
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
        contrato.vlentra
        contrato.vlseguro
        contrato.vltotal
        contrato.nro_parcela

        with frame frame-a.


end procedure.

procedure color-message.
color disp         message
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
        contrato.vlentra
        contrato.vlseguro
        
        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
                contrato.vlentra
        contrato.vlseguro

        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
                contrato.vlentra
        contrato.vlseguro

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
def var vconta as int.
def var vtime as int.
vtime = time.


vtotal = 0.
vqtdtotal =0.
for each ttcontrato.
    delete ttcontrato.
end.
 
def var pmodcod   like pdvdoc.modcod.
def var pctmcod like pdvdoc.ctmcod.
def var petbcod   like pdvdoc.etbcod.
def var pcobcod   like titulo.cobcod.

def var ptpcontrato like titulo.tpcontrato.


 
for each estab 
    where if vetbcod = 0
          then true
          else estab.etbcod = vetbcod
    no-lock.
        /*if not poldfiltro = "geral"
        then */
        if poldetbcod <> ?
             then if estab.etbcod <> poldetbcod
                  then next.

for each pdvtmov where pdvtmov.pagamento = no no-lock.

            if poldctmcod <> "" and poldctmcod <> ?
            then if pdvtmov.ctmcod <> poldctmcod
                 then next.
       
        
        hide message no-pause.
        message color normal "fazendo calculos... aguarde..." estab.etbcod
            pdvtmov.ctmnom "  processando:" string(time - vtime, "HH:MM:SS").
.
        
        for each pdvdoc use-index pagamentos where 
                pdvdoc.ctmcod = pdvtmov.ctmcod and
                pdvdoc.pstatus = yes and
                pdvdoc.etbcod = estab.etbcod and 
                pdvdoc.datamov >= vdtini and
                pdvdoc.datamov <= vdtfin no-lock.
            if pdvdoc.valor <> 0 and pdvdoc.placod <> 0
            then.
            else next.
           vconta = vconta +  1. 
            if vconta mod 10000 = 0 or vconta < 10
            then do: 
            hide message no-pause.
            message color normal "fazendo calculos... aguarde..." estab.etbcod
                pdvtmov.ctmnom vconta "  processando:" string(time - vtime, "HH:MM:SS").
            end.      
            
                      
            find pdvmov of pdvdoc no-lock. 
            vcontnum = dec(pdvdoc.contnum) no-error.
            if vcontnum > 99999999999 or vcontnum = ? or vcontnum = 0 
            then do:
                /*message pdvdoc.contnum.*/
                /* teste colocado em 04/05/2022 helio */
                next.
            end.
            if vcontnum = ? or vcontnum = 0 then next.
                
                release contrato.
            
                find contrato where contrato.contnum = int(vcontnum) no-lock no-error.
                if not avail contrato
                then next.

            find first titulo where titulo.contnum = contrato.contnum and
                                    titulo.titpar = 1
                    no-lock no-error.
            if not avail titulo
            then next.
            
            if pfiltro = "geral"
            then do:
                
                petbcod     = ?.
                pctmcod     = ?.
                pmodcod     = ?.
                ptpcontrato = ?.
                pcobcod     = ?.
            end.                 
            else do:
                pctmcod   = poldctmcod. 
                pmodcod   = poldmodcod.
                petbcod   = poldetbcod.
                ptpcontrato = poldtpcontrato.
                pcobcod     = poldcobcod.
            end.
            /**
            if pfiltro = "carteira" 
            then do:
                pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.
            end. 
            else do:
                if poldcarteira = yes
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N")) 
                               or not avail titulo
                     then.
                     else next.
                if poldcarteira = no
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                     then next.
            end.
            **/
            
            if pfiltro = "tpcontrato"
            then do:
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                /*pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.**/
            end.                
            else do:
                    /*
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                */
                if poldtpcontrato <> ?
                then if ( if avail titulo then titulo.tpcontrato else "") <> poldtpcontrato
                     then next.
            end.
            
            if pfiltro = "modalidade"
            then pmodcod = if avail titulo then titulo.modcod else "".
            else do:
                if poldmodcod <> ?
                then if avail titulo and titulo.modcod <> poldmodcod
                     then next.
            end.
            
            if pfiltro = "Filial"
            then petbcod = pdvdoc.etbcod.
            else do:
                if poldetbcod <> ?
                then if pdvdoc.etbcod <> poldetbcod
                     then next.
            end.
            if pfiltro = "Propriedade"
            then pcobcod = if avail titulo then titulo.cobcod else 0.
            else do:
                if poldcobcod <> ?
                then if (if avail titulo then titulo.cobcod else 0) <> poldcobcod
                     then next.
            end.
            if pfiltro = "Operacao"
            then pctmcod = pdvdoc.ctmcod.
            else do:
                if poldctmcod <> ?
                then if pdvdoc.ctmcod <> poldctmcod
                     then next.
            end.
            
            
            /*if pfiltro = "vencimento"
            then do:
                pdtvenc = poscart.dtvenc.
            end.  
            else do:
                if polddtvenc <> ?
                then if poscart.dtvenc <> polddtvenc
                     then next.
            end.
            **/     

            find ttcontrato where ttcontrato.contnum = contrato.contnum no-lock no-error.
            if not avail ttcontrato
            then do: 
                create ttcontrato.
                ttcontrato.contnum = contrato.contnum.
                ttcontrato.precid   = recid(pdvmov).
                                        vqtdtotal = vqtdtotal + 1.
            
           end.     
        end.        
        end.
        if vfiltro = "vendas site"
        then
        for each contrsite where contrsite.etbcod = estab.etbcod and
                                 contrsite.datatransacao >= vdtini and
                                 contrsite.datatransacao <= vdtfin
                                 no-lock.
            find contrato where contrato.contnum = contrsite.contnum no-lock no-error.
            if not avail contrato then next.
            find ttcontrato where ttcontrato.contnum = contrato.contnum no-lock no-error.
            if not avail ttcontrato
            then do: 
                create ttcontrato.
                ttcontrato.contnum = contrato.contnum.
                ttcontrato.precid  = ?.
                                        vqtdtotal = vqtdtotal + 1.
            end.
        end.
        if vfiltro = "vendas APP" and estab.etbcod = 200 /* helio 07122021 id 97063 */
        then
            for each contrato where contrato.etbcod = estab.etbcod and
                                    contrato.dtinicial >= vdtini and
                                    contrato.dtinicial <= vdtfin and
                                    contrato.modcod = "CP1"
                                    no-lock.
            find first ttcontrato where ttcontrato.contnum = contrato.contnum no-lock no-error.
            if not avail ttcontrato
            then do: 
                create ttcontrato.
                ttcontrato.contnum = contrato.contnum.
                ttcontrato.precid  = ?. 
                vqtdtotal = vqtdtotal + 1.
            end.
        end.
        
end.            
hide message no-pause.
            
end procedure.




procedure geracsv.

    def var ccarteira as char.
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
def var vbaru as log.
    
   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/ctb/conciliacao" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_emissao" + string(vdtini,"99999999") + "_" + string(vdtfin,"99999999") + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
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

   
            output to value(varq).    
                put unformatted 
                    vfiltro skip.
                put unformatted
                "Codigo" vcp
                "Nome"   vcp
                "CPF"    vcp 
                "Contrato" vcp    
                "Carteira" vcp    
                "Valor"   vcp
                "Entrada" vcp /* helio 15122021 Melhorias CR II */
                "Vlr Crediario" vcp /* helio 15122021 Melhorias CR II */
                "Principal" vcp
                "Acrescimo" vcp
                "Seguro"    vcp
                
                "Emissão" vcp
                "Modalidade"  vcp
                "Filial"  vcp
                "Tipo de cobrança" vcp
                "Data Referencia" vcp
                "codigoPedido-Ecom" vcp
                "IOF" vcp
                "Baru" vcp
                skip.

    for each ttcontrato.
        
        find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
            if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        

        find titulo where /* helio 07122021 id 97063 */
                        titulo.empcod = 19 and titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                        titulo.clifor = contrato.clicod and
                          titulo.titnum = string(contrato.contnum) and
                          titulo.titpar = 1
                             no-lock no-error.
                             
        find cobra where cobra.cobcod = titulo.cobcod no-lock no-error.
        find modal where modal.modcod = contrato.modcod no-lock no-error.
        ccarteira = (if titulo.cobcod <> ? 
                 then string(titulo.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").

        ctpcontrato = if titulo.tpcontrato <> ? 
                then if titulo.tpcontrato = "F"
                     then "FEIRAO"
                     else if titulo.tpcontrato = "N"
                          then "NOVACAO"
                          else if titulo.tpcontrato = "L"
                               then "LP "
                               else "normal "
                else     "-".

        cmodnom = if contrato.modcod <> ? 
                then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                else "-".

        find first btitulo where 
                        btitulo.empcod = 19 and 
                        btitulo.titnat = no and
                        btitulo.etbcod = contrato.etbcod and 
                        btitulo.modcod = contrato.modcod and
                        btitulo.clifor = contrato.clicod and
                        btitulo.titnum = string(contrato.contnum) and
                        btitulo.cessaobaru = yes
                             no-lock no-error.
        vbaru = avail btitulo.
                
        find first contrsite where contrsite.contnum = contrato.contnum  no-lock no-error.
        
        put unformatted
            
            contrato.clicod     vcp
            if avail clien then clien.clinom else "-"       vcp
            if avail clien then clien.ciccgc else "-"       vcp
            contrato.contnum    vcp
            ccarteira           vcp
            trim(string(contrato.vltotal,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp /* helio 15122021 Melhorias CR II */
            trim(string(contrato.vlentra,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp /* helio 15122021 Melhorias CR II */
            trim(string(contrato.vltotal - contrato.vlentra,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp                   /* helio 15122021 Melhorias CR II */            

            trim(string(contrato.vlf_principal,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(contrato.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(contrato.vlseguro,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            
            contrato.dtinicial  vcp
            cmodnom             vcp
            contrato.etbcod     vcp
            ctpcontrato         vcp
            vdtfin              vcp
            (if avail contrsite
             then contrsite.codigoPedido
             else "" ) vcp
            trim(string(contrato.vliof,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp /* helio 15052023 */
            string(vbaru,"Sim/Nao") vcp 
               skip.
    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.




