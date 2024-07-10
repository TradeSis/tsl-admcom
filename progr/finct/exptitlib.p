/* helio 08082022 - ID 142002 - Criar relatório ADM  
    https://trello.com/c/TlZWe8BY/28-thalis-id-142002-criar-relat%C3%B3rio-adm*/


{admcab.i}

def buffer xtitulo for titulo.
def var vt as int.
def var vdtini  as date label "data inicial" format "99/99/9999" initial today.
def var vdtfin  as date label "data final"   format "99/99/9999" initial today.

def var vmodais as char.
def var vmodcod as char.
def var v-cont as int.

def temp-table tt-modalidade-selec no-undo
    field modcod as char.
def var vmod-sel as char.

        run le_tabini.p (0, 0, "Filtro-Modal-REC", OUTPUT vmodais).
        do v-cont = 1 to num-entries(vmodais).
            vmodcod = entry(v-cont, vmodais).
            create tt-modalidade-selec.
            assign tt-modalidade-selec.modcod = vmodcod.
        end.

assign vmod-sel = "".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel  + 
        (if vmod-sel = ""
         then ""
         else "/") + trim(tt-modalidade-selec.modcod).
end.

def var vnro_parcela as int.
def var vvlseguro as dec.
def var vvliof  as dec.

update vdtini colon 20
       vdtfin
        skip
       
       with frame fcab centered
       row 4 side-labels title "EXPORTA TITULOS LIB".

display vmod-sel format "x(24)" no-label
    with frame fcab.

   def var varq as char format "x(60)".
   def var vcp  as char init ";".

   varq = "/admcom/tmp/" + "tituloslib_" +
                             string(vdtini,"99999999") + string(vdtfin,"99999999") + 
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


def var vtitvltot as dec.
def var vcobnom as char.

message "Gerando arquivo" varq.

output to value(varq).
put unformatted  
    "Nome;"
    "CPF;"
    "Loja;"
    "dt emissao;"
    "Contrato;"
    "Parcela;"
    "modalidade;"
    "Data de Vencimento;"
    "Valor de PMT;"
    "Saldo;"
    "Principal;"
    "Acréscimo;"
    "Seguro;"
    "IOF;" 
    "Carteira;"
    "Hoje;"
     skip.

for each tt-modalidade-selec,
    each titulo use-index Por-Mod-emi
        where   titulo.titnat = no and 
                titulo.titdtpag = ? and 
                titulo.modcod = tt-modalidade-selec.modcod and 
                titulo.titsit = "LIB" and 
                titulo.titdtemi >= vdtini and 
                titulo.titdtemi <= vdtfin no-lock
        by titulo.titnum 
        by titulo.titpar .
    
    find cobra of titulo no-lock.
    
    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien then next.
    vtitvltot = if titulo.titvltot <> 0 then titulo.titvltot else titulo.titvlcob.
    vcobnom   = string(titulo.cobcod,"99") + "-" + cobra.cobnom.

    vnro_parcela = 0.
    vvlseguro   = 0.
    vvliof      = 0.
    
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        vnro_parcela = contrato.nro_parcela.
        if vnro_parcela = 0
        then do: 
            for each  xtitulo where
                        xtitulo.empcod = 19 and
                        xtitulo.titnat = no and
                        xtitulo.etbcod = contrato.etbcod and
                        xtitulo.clifor = contrato.clicod and
                        xtitulo.modcod = contrato.modcod and
                        xtitulo.titnum = string(contrato.contnum) and
                        xtitulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
            end.                        
        end.

        vvlseguro = if contrato.vlseguro > 0
                    then contrato.vlseguro / vnro_parcela
                    else 0.  
        vvliof = if contrato.vliof > 0
                 then contrato.vliof / vnro_parcela
                 else 0.
    end.
    
    put unformatted
        clien.clinom ";"
        clien.ciccgc ";"
        titulo.etbcod ";"
        titulo.titdtemi format "99/99/9999" ";"
        titulo.titnum ";"
        titulo.titpar ";"
        titulo.modcod ";"
        titulo.titdtven format "99/99/9999" ";"
        trim(string(vtitvltot,"->>>>>>>>>>>>>>9.99")) ";"
        trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>9.99")) ";"
        trim(string(titulo.vlf_principal,"->>>>>>>>>>>>>>9.99")) ";"  
        trim(string(titulo.vlf_acrescimo,"->>>>>>>>>>>>>>9.99")) ";"  
        trim(string(vvlseguro,"->>>>>>>>>>>>>>9.99")) ";"  
        trim(string(vvliof,"->>>>>>>>>>>>>>9.99")) ";"  
        vcobnom ";"
        today format "99/99/9999" ";"
        skip.
    vt = vt + 1.
end.

output close.

hide message no-pause.
message "Exportados " vt "titulos lib ->" varq.
pause.
