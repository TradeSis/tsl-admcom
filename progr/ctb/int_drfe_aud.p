def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vdata as date.
def var vetb as char.
def var varq as char.
def var varq1 as char.
def var varq2 as char.
def var vsep as char.
def var vparticipante as char.
def var vnumecf as char.
def var vcodcpl as char.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
 /*
sparam = "AniTA".
 */ 
if opsys = "unix" and sparam <> "AniTA"
then do:
    /*input from /admcom/audit/param_ref.
    */
    input from /file_server/param_nfe.
    repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
    end.
    input close.

    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").

    varq2 = "/file_server/drenf_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    varq1 = "/file_server/drecf_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    varq = "/file_server/dreoc_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

end.
else do:
    
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 16
               vdtf label "Data Final" with frame f1 side-label width 80.
    
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").

    varq2 = "/admcom/decision/drenf_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    varq1 = "/admcom/decision/drecf_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    varq = "/admcom/decision/dreoc_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
end.

def temp-table tt-dreoc no-undo
    field CodCiaNat as char
    field CodEstabelecimentoNat as char
    field TipoOperacaoNat as char
    field CodigoModeloNat as char
    field NumeroDocumentoDocFiscNat as char
    field NumeroSerieNat as char
    field CodParceiroNat as char 
    field DataEmissaoNotaFiscalNat as char
    field DataESNotaFiscalNat as char
    field CodInfoComplementarNat as char
    field Descricao as char format "x(255)"
    field OrigemInfo as char
    field SequencialERP as char
    field modelo_ori as char
    .

def temp-table tt-drecf no-undo
    field CodCiaNat as char
    field CodEstabelecimentoNat as char
    field CodigoModeloNat as char
    field CodigoModeloReferenciado as char
    field CodInfoComplementarNat as char
    field CodParceiroNat as char
    field DataEmissao as char
    field DataEmissaoNotaFiscalNat as char
    field DataESNotaFiscalNat as char
    field NumeroCaixaECF as char
    field NumeroDocReferenciado as char
    field NumeroDocumentoDocFiscNat as char
    field NumeroSerieNat as char
    field OrigemInfo as char
    field SequencialERP as char
    field SerieFabricacaoECF as char
    field TipoOperacaoNat as char
    field modelo_ori as char
    .

def temp-table tt-drenf no-undo
    field CodCiaNat                   as char
    field CodEstabelecimentoNat       as char
    field EmitenteTitulo              as char
    field TipoOperacao                as char
    field CodigoModeloReferenciado    as char
    field NumeroDocReferenciado       as char
    field NumeroSerieReferenciado     as char
    field NumeroSubserieReferenciado  as char
    field CodParceiroInfoCompNat      as char
    field DataEmissao                 as char
    field CodInfoComplementarNat      as char
    field TipoOperacaoNat             as char
    field CodigoModeloNat             as char
    field NumeroDocumentoDocFiscNat   as char
    field NumeroSerieNat              as char
    field CodParceiroNat              as char
    field DataEmissaoNotaFiscalNat    as char
    field DataESNotaFiscalNat         as char
    field OrigemInfo                  as char
    field SequencialERP               as char
    field ChaveDocEletronico          as char
    .

def var vserfab as char format "x(20)".

for each estab where
         (if vetbcod > 0 then estab.etbcod = vetbcod
                         else true) no-lock:
    do vdata = vdti to vdtf:
    
        for each plani where plani.movtdc = 12 and
                    plani.etbcod = estab.etbcod and
                    plani.pladat = vdata
                    no-lock,
            each docrefer where
                     docrefer.etbcod = plani.etbcod and
                     docrefer.codrefer = string(plani.emite) and
                     docrefer.serierefer = plani.serie and
                     docrefer.numerodr = plani.numero 
                     no-lock.            

            if docrefer.serieori = "2D"
            then do:
                vparticipante = "E" + string(plani.etbcod,"9999999999").
                vcodcpl = "CF" + string(plani.movtdc,"9999").
            
                create tt-dreoc.
                assign
                    tt-dreoc.CodCiaNat = "001"
                    tt-dreoc.CodEstabelecimentoNat = string(estab.etbcod,"999")
                    tt-dreoc.TipoOperacaoNat = "0"
                    tt-dreoc.CodigoModeloNat = "55"
                    tt-dreoc.NumeroDocumentoDocFiscNat = string(plani.numero)
                    tt-dreoc.NumeroSerieNat = plani.serie
                    tt-dreoc.CodParceiroNat = vparticipante
                    tt-dreoc.DataEmissaoNotaFiscalNat = 
                        string(year(plani.pladat),"9999") +
                        string(month(plani.pladat),"99")  +
                        string(day(plani.pladat),"99")  
                    tt-dreoc.DataESNotaFiscalNat = 
                        string(year(plani.pladat),"9999") +
                        string(month(plani.pladat),"99")  +
                        string(day(plani.pladat),"99")  
                    tt-dreoc.CodInfoComplementarNat = vcodcpl
                    tt-dreoc.Descricao = plani.notobs[1] + " " +
                                     plani.notobs[2] + " " +
                                     plani.notobs[3]
                    tt-dreoc.OrigemInfo = "ADMCOM"
                    tt-dreoc.SequencialERP = ""
                    .

                find tabecf where tabecf.etbcod = docrefer.etbcod and
                          tabecf.equipa = docrefer.numecf and
                          tabecf.datini <= docrefer.dtemiori and
                          tabecf.datfin >= docrefer.dtemiori
                          no-lock no-error.
                if avail tabecf 
                then vserfab = tabecf.serie.
                vnumecf = string(docrefer.numecf).
                create tt-drecf.
                assign
                    tt-drecf.CodCiaNat = "001"
                    tt-drecf.CodEstabelecimentoNat = string(estab.etbcod,"999")
                    tt-drecf.CodigoModeloNat = docrefer.modelorefer
                    tt-drecf.CodigoModeloReferenciado = docrefer.serieori
                    tt-drecf.CodInfoComplementarNat   = vcodcpl
                    tt-drecf.CodParceiroNat   = vparticipante
                    tt-drecf.DataEmissao      = 
                                    string(year(docrefer.dtemicupom),"9999") +
                                    string(month(docrefer.dtemicupom),"99")  +
                                    string(day(docrefer.dtemicupom),"99")                          tt-drecf.DataEmissaoNotaFiscalNat =
                                    string(year(plani.pladat),"9999") +
                                    string(month(plani.pladat),"99")  +
                                    string(day(plani.pladat),"99") 
                    tt-drecf.DataESNotaFiscalNat =
                                    string(year(plani.pladat),"9999") +
                                    string(month(plani.pladat),"99")  +
                                    string(day(plani.pladat),"99") 
                    tt-drecf.NumeroCaixaECF = vnumecf
                    tt-drecf.NumeroDocReferenciado = string(docrefer.coo)
                    tt-drecf.NumeroDocumentoDocFiscNat = 
                                        string(int(docrefer.numerodr))
                    tt-drecf.NumeroSerieNat = docrefer.serierefer
                    tt-drecf.OrigemInfo     = "ADMCOM"
                    tt-drecf.SequencialERP  = ""
                    tt-drecf.SerieFabricacaoECF = vserfab
                    tt-drecf.TipoOperacaoNat = "0"
                    tt-drecf.modelo_ori = docrefer.serieori
                    tt-dreoc.modelo_ori = docrefer.serieori    
                    .
            end.
            else do:
                vparticipante = "E" + string(plani.etbcod,"9999999999").
                vcodcpl = "NF" + string(plani.movtdc,"9999").
            
                create tt-dreoc.
                assign
                    tt-dreoc.CodCiaNat = "001"
                    tt-dreoc.CodEstabelecimentoNat = string(estab.etbcod,"999")
                    tt-dreoc.TipoOperacaoNat = "0"
                    tt-dreoc.CodigoModeloNat = "55"
                    tt-dreoc.NumeroDocumentoDocFiscNat = string(plani.numero)
                    tt-dreoc.NumeroSerieNat = plani.serie
                    tt-dreoc.CodParceiroNat = vparticipante
                    tt-dreoc.DataEmissaoNotaFiscalNat = 
                        string(year(plani.pladat),"9999") +
                        string(month(plani.pladat),"99")  +
                        string(day(plani.pladat),"99")  
                    tt-dreoc.DataESNotaFiscalNat = 
                        string(year(plani.pladat),"9999") +
                        string(month(plani.pladat),"99")  +
                        string(day(plani.pladat),"99")  
                    tt-dreoc.CodInfoComplementarNat = vcodcpl
                    tt-dreoc.Descricao = plani.notobs[1] + " " +
                                     plani.notobs[2] + " " +
                                     plani.notobs[3]
                    tt-dreoc.OrigemInfo = "ADMCOM"
                    tt-dreoc.SequencialERP = ""
                    tt-dreoc.modelo_ori = docrefer.serieori
                                        
                    .

                create tt-drenf.
                assign
                    tt-drenf.CodCiaNat = "001" 
                    tt-drenf.CodEstabelecimentoNat = string(estab.etbcod,"999")
                    tt-drenf.EmitenteTitulo  = "0"
                    tt-drenf.TipoOperacao    = "1"
                    tt-drenf.CodigoModeloReferenciado = docrefer.serieori
                    tt-drenf.NumeroDocReferenciado    = string(docrefer.coo)
                    tt-drenf.NumeroSerieReferenciado  = docrefer.serierefer
                    tt-drenf.NumeroSubserieReferenciado = ""
                    tt-drenf.CodParceiroInfoCompNat     = vparticipante
                    tt-drenf.DataEmissao = 
                                    string(year(docrefer.dtemicupom),"9999") +
                                    string(month(docrefer.dtemicupom),"99")  +
                                    string(day(docrefer.dtemicupom),"99")
                    tt-drenf.CodInfoComplementarNat = vcodcpl
                    tt-drenf.TipoOperacaoNat        = "0"
                    tt-drenf.CodigoModeloNat  = docrefer.modelorefer
                    tt-drenf.NumeroDocumentoDocFiscNat =                                         string(int(docrefer.numerodr))
                    tt-drenf.NumeroSerieNat = docrefer.serierefer
                    tt-drenf.CodParceiroNat = vparticipante
                    tt-drenf.DataEmissaoNotaFiscalNat =
                                    string(year(plani.pladat),"9999") +
                                    string(month(plani.pladat),"99")  +
                                    string(day(plani.pladat),"99") 
                    tt-drenf.DataESNotaFiscalNat =
                                    string(year(plani.pladat),"9999") +
                                    string(month(plani.pladat),"99")  +
                                    string(day(plani.pladat),"99") 
                    tt-drenf.OrigemInfo = "ADMCOM"
                    tt-drenf.SequencialERP = ""
                    tt-drenf.ChaveDocEletronico = plani.ufdes.
                    .
 
            end.
        end.        
    end.
end.    

vsep = "|".
output to value(varq).

for each tt-dreoc where tt-dreoc.CodCiaNat = "001" /*and
                        tt-dreoc.modelo_ori = "2D"*/ no-lock:
    put unformatted
        tt-dreoc.CodCiaNat
        vsep
        tt-dreoc.CodEstabelecimentoNat
        vsep
        tt-dreoc.TipoOperacaoNat
        vsep
        tt-dreoc.CodigoModeloNat
        vsep
        tt-dreoc.NumeroDocumentoDocFiscNat
        vsep
        tt-dreoc.NumeroSerieNat
        vsep
        tt-dreoc.CodParceiroNat
        vsep
        tt-dreoc.DataEmissaoNotaFiscalNat
        vsep
        tt-dreoc.DataESNotaFiscalNat
        vsep
        tt-dreoc.CodInfoComplementarNat
        vsep
        tt-dreoc.Descricao
        vsep
        tt-dreoc.OrigemInfo
        vsep
        tt-dreoc.SequencialERP
        skip.
end.
output close.

output to value(varq1).
for each tt-drecf where tt-drecf.CodCiaNat = "001" and
                        tt-drecf.modelo_ori = "2D" no-lock.
        put unformatted
            tt-drecf.CodCiaNat
            vsep
            tt-drecf.CodEstabelecimentoNat
            vsep 
            tt-drecf.CodigoModeloNat
            vsep
            tt-drecf.CodigoModeloReferenciado 
            vsep
            tt-drecf.CodInfoComplementarNat
            vsep
            tt-drecf.CodParceiroNat
            vsep
            tt-drecf.DataEmissao
            vsep      
            tt-drecf.DataEmissaoNotaFiscalNat
            vsep 
            tt-drecf.DataESNotaFiscalNat
            vsep 
            tt-drecf.NumeroCaixaECF
            vsep 
            tt-drecf.NumeroDocReferenciado
            vsep 
            tt-drecf.NumeroDocumentoDocFiscNat
            vsep 
            tt-drecf.NumeroSerieNat
            vsep 
            tt-drecf.OrigemInfo
            vsep     
            tt-drecf.SequencialERP
            vsep  
            tt-drecf.SerieFabricacaoECF
            vsep 
            tt-drecf.TipoOperacaoNat
            skip.
end.    
output close.

output to value(varq2).
for each tt-drenf where tt-drenf.CodCiaNat = "001":
    put unformatted
        tt-drenf.CodCiaNat
        vsep 
        tt-drenf.CodEstabelecimentoNat
        vsep 
        tt-drenf.EmitenteTitulo
        vsep
        tt-drenf.TipoOperacao
        vsep
        tt-drenf.CodigoModeloReferenciado
        vsep
        tt-drenf.NumeroDocReferenciado
        vsep
        tt-drenf.NumeroSerieReferenciado
        vsep
        tt-drenf.NumeroSubserieReferenciado
        vsep
        tt-drenf.CodParceiroInfoCompNat
        vsep
        tt-drenf.DataEmissao 
        vsep
        tt-drenf.CodInfoComplementarNat
        vsep
        tt-drenf.TipoOperacaoNat
        vsep
        tt-drenf.CodigoModeloNat
        vsep
        tt-drenf.NumeroDocumentoDocFiscNat
        vsep
        tt-drenf.DataEmissaoNotaFiscalNat
        vsep
        tt-drenf.DataESNotaFiscalNat 
        vsep
        tt-drenf.OrigemInfo
        vsep
        tt-drenf.SequencialERP
        vsep
        tt-drenf.ChaveDocEletronico 
        skip
        .
end.
output close.
