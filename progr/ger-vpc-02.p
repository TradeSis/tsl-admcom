{admcab.i}

/******
01-CNPJ do Estabelecimento;
02-Numero Sequencial do Item;
03-Codigo do Item;
04-Descricao do Item produto;
05-NCM;
06-Chave NF-e/NFC-e;
07-Descricao Complementar do Item;
08-Quantidade do Item;
09-Unide do Item;
10-Descricao da Unidade de Medida;
11-Valor Total NF-e/NFC-e/CF;
12-Valor Total do em;
13-Valor do Desconto;
14-Codigo da Situacao Tributaria do ICMS;
15-CFOP;
16-Codigo da Natura Operacao;
17-Descricao da Natureza de Operacao;
18-Valor da BC do ICMS;
19-Aliquota do lor do ICMS;
20-Valor da BC ICMS-ST;
21-Aliquota da ICMS-ST;
22-Valor do ICMS-ST;
23-Codigo da Situacao Tributaria do IPI;
24-Cod. de Enquadramento Legal do IPI;
25-Valor da BC do IPI;
26-Aliquota do IPI;
27-Valor do IPI;
28-Codigo da Situacao Tributaria do PIS;
29-Valor da BC do PIS;
30-Aliquota do PIS (%);
31-Valor do PIS;
32-Codigo da Situacao Tributaria da COFINS;
33-Valor da BC daINS;
34-Aliquota da COFINS (%);
35-Valor da COFINS;
36-Valor Total do PIS Retido por ST;
37-Valor Ttal da COFINS Retido por ST;
38-Abatimento nao Tributado e nao Comercial;
39-Tipo do Fretealor do Frete;
40-Valor do Seguro;
41-Valor de Outras Despesas;
42-Codigo da Conta Analitica Contabil;
43-Tipo de Operacao;
44-Tipo de Pagamento;
45-Emitente;
46-Codigo Participante;
47-Nome do Paipante;
48-CNPJ do Participante;
49-Municipio;
50-UF;
51-Tipo Documento;
52-Modelo Documento;
53-Situacao documento;
54-Serie;
55-Numero documento fiscal;
56-Data da Emissao;
57-Data Entrada/Saida;
58-Filial;
59-Periodo
*******/

def var vcfop like com.movim.opfcod.
def var vmenos as dec.
def var vmais as dec.
def var vdata as date format "99/99/9999".

/**********
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
def var vind-venda as log format "Sim/Nao".
def var vind-devol as log format "Sim/Nao".

update vdti label "Data inicial"
       vdtf label "Data final"
       with 1 down side-label width 80.

def var vtipo as char format "x(20)" extent 2
    init["VENDA MERCADORIA","DEVOLUCAO VENDA"].
disp vtipo with frame ftp 1 down no-label centered.
choose field vtipo with frame ftp.

if frame-index = 1
then assign
        vind-venda = yes
        vind-devol = no.
else assign
         vind-devol = yes
         vind-venda = no.
**********/
            
def input parameter vdti as date.
def input parameter vdtf as date.
def input parameter vind-venda as log.
def input parameter vind-devol as log.

def buffer plani for mov.plani.
def buffer movim for mov.movim.

def var vciccgc as char format "x(20)".
def var vclinom  like clien.clinom.

def stream stela.
output stream stela to terminal.
def var varquivo as char.
def var vaq as int format ">>>9".
vaq = 1.
if vind-venda
then
varquivo = "/admcom/Contabilidade/relat/venda-" + string(vaq) + "-" 
            + string(vdti,"99999999") +
                                   string(vdtf,"99999999") + ".csv".
else 
varquivo = "/admcom/Contabilidade/relat/devolucao-" + string(vaq) + "-"
+ string(vdti,"99999999") + string(vdtf,"99999999") + ".csv".

output to value(varquivo).
          
put "CNPJ do Estabelecimento;Numero Sequencial do Item;Codigo do Item;"
    "Descricao do Item produto;NCM;Chave NF-e/NFC-e;"
    "Descricao Complementar do Item;Quantidade do Item;Unide do Item;"
    "Descricao da Unidade de Medida;Valor Total NF-e/NFC-e/CF;"
    "Valor Total do em;Valor do Desconto;Codigo da Situacao Tributaria ICMS;"
    "CFOP;Codigo da Natura Operacao;Descricao da Natureza de Operacao;"
    "Valor da BC do ICMS;Aliquota do ICMS;"
    "Valor do ICMS;Valor da BC ICMS-ST;"
    "Aliquota do ICMS-ST;Valor do ICMS-ST;Codigo da Situacao Tributaria IPI;"
    "Cod. de Enquadramento Legal do IPI;Valor da BC do IPI;Aliquota do IPI;"
    "Valor do IPI;Codigo da Situacao Tributaria do PIS;Valor da BC do PIS;"
    "Aliquota do PIS (%);Valor do PIS;Codigo da Situacao Tributaria COFINS;"
    "Valor da BC daINS;Aliquota da COFINS (%);Valor da COFINS;"
    "Valor Total do PIS Retido por ST;Valor Ttal da COFINS Retido por ST;"
    "Abatimento nao Tributado e nao Comercial;Tipo do Fretealor do Frete;"
    "Valor do Seguro;Valor de Outras Despesas;"
    "Codigo da Conta Analitica Contabil;Tipo de Operacao;Tipo de Pagamento;"
    "Emitente;Codigo Participante;Nome do Paipante;CNPJ do Participante;"
    "Municipio;UF;Tipo Documento;Modelo Documento;Situacao documento;"
    "Serie;Numero documento fiscal;Data da Emissao;"
    "Data Entrada/Saida;TipMov"
    skip.
         
def var vq as int.        
def var vchave as char format "x(44)".                 
def var vmodelo as char.
def var vtipo as char.
def var vsituacao as char.

def var vmovbicms like movim.movicms.
def var vmovicms  like movim.movicms.
            
for each estab no-lock:
    disp stream stela estab.etbcod label "Filial"
    with 1 down side-label row 10 centered
    color message no-box. pause 0.
    do vdata = vdti to vdtf:
        disp stream stela vdata label "Data". pause 0.
        if vind-venda then
        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat = vdata
                             no-lock:
            find clien where clien.clicod = plani.desti no-lock no-error.
            if avail clien 
            then do:
                vclinom = clien.clinom.
                vciccgc = clien.ciccgc.
            end.
            else assign
                    vclinom = ""
                    vciccgc = ""
                    .
            vmenos = 0.
            vmais = 0.

            if plani.ufdes <> "" and
               length(plani.ufdes) > 40
            then assign
                    vchave = plani.ufdes
                    vmodelo = "55"
                    vtipo = "Nota Fiscal"
                    .
            else if plani.ufemi <> ""
                    then assign
                            vchave = ""
                            vmodelo = ""
                            vtipo = "Cupom Fiscal"
                            .
            else assign
                    vchave = ""
                    vmodelo = ""
                    vtipo = "".
                    
            if plani.modcod = "CAN"
            then vsituacao = "Cancelada".
            else vsituacao = "Emitida".

            if length(vchave) < 10 
            then vchave = "".
            else vchave = "'" + vchave + "'".
            
            if entry(1,plani.notped,"|") = "C"
            then
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock,
                first produ where produ.procod = movim.procod
                            no-lock:
                vmovbicms = 0.
                vmovicms = 0.
                
                if produ.proipiper = 98 or 
                   produ.pronom matches "*recarga*"
                then do:
                    vmenos = vmenos + (movim.movqtm * movim.movpc).
                end.
                else do:
                    vmais = vmais + movim.movpc * movim.movqtm.
                
                    if movim.movalicms > 0
                    then do:
                        /*assign
                            vmovbicms = movim.movbicms
                            vmovicms  = movim.movicms. */
                        if vmovbicms = 0
                        then assign
                                vmovbicms = movim.movpc * movim.movqtm
                                vmovicms  = 
                                        vmovbicms * ( movim.movalicms / 100)
                                .
                    end.
                    else assign
                            vmovbicms = 0
                            vmovicms  = 0.

                vcfop = if plani.opccod <> ? and
                            length(string(plani.opccod)) = 4
                            then plani.opccod
                            else 5102.

                put  unformatted
                     "'" + estab.etbcgc + "'"           ";"
                     movim.movseq           ";"
                     movim.procod           ";"
                     produ.pronom           ";"
                     produ.codfis           ";"
                     vchave                 ";"
                     ""                     ";"
                     movim.movqtm           ";"
                     "UN"                   ";"
                     "UNIDADE"              ";"
                     ""                     ";"
                     movim.movpc            ";"
                     ""                     ";"
                     ""                     ";"
                     vcfop                  ";"
                     /*plani.opccod           ";"*/
                     ""                     ";"
                     ""                     ";"
                     vmovbicms  ";"
                     movim.movalicms        ";"
                     vmovicms          ";"
                     ""                     ";"
                     movim.movalicms        ";"
                     movim.movsubst         ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     estab.etbcod           ";"
                     plani.desti            ";"
                     vclinom                ";"
                     "'" + vciccgc + "'"    ";"
                     ""                     ";"
                     ""                     ";"
                     vtipo                  ";"
                     vmodelo                ";"
                     vsituacao              ";"
                     plani.serie            ";"
                     plani.numero           ";"
                     movim.movdat           ";"
                     movim.movdat           ";"
                     "VENDA" 
                     skip.
                    
                    vq = vq + 1.    
                end.
            end.
            
            if vq >= 600000
            then do:
                    output close.
                    vq = 0.
                    vaq = vaq + 1.
                    varquivo = "/admcom/Contabilidade/relat/venda-" + 
                                    string(vaq) + "-" 
                                + string(vdti,"99999999") +
                                  string(vdtf,"99999999") + ".csv".
                    output to value(varquivo).
    put "CNPJ do Estabelecimento;Numero Sequencial do Item;Codigo do Item;"
    "Descricao do Item produto;NCM;Chave NF-e/NFC-e;"
    "Descricao Complementar do Item;Quantidade do Item;Unide do Item;"
    "Descricao da Unidade de Medida;Valor Total NF-e/NFC-e/CF;"
    "Valor Total do em;Valor do Desconto;Codigo da Situacao Tributaria ICMS;"
    "CFOP;Codigo da Natura Operacao;Descricao da Natureza de Operacao;"
    "Valor da BC do ICMS;Aliquota do ICMS;"
    "Valor do ICMS;Valor da BC ICMS-ST;"
    "Aliquota do ICMS-ST;Valor do ICMS-ST;Codigo da Situacao Tributaria IPI;"
    "Cod. de Enquadramento Legal do IPI;Valor da BC do IPI;Aliquota do IPI;"
    "Valor do IPI;Codigo da Situacao Tributaria do PIS;Valor da BC do PIS;"
    "Aliquota do PIS (%);Valor do PIS;Codigo da Situacao Tributaria COFINS;"
    "Valor da BC daINS;Aliquota da COFINS (%);Valor da COFINS;"
    "Valor Total do PIS Retido por ST;Valor Ttal da COFINS Retido por ST;"
    "Abatimento nao Tributado e nao Comercial;Tipo do Fretealor do Frete;"
    "Valor do Seguro;Valor de Outras Despesas;"
    "Codigo da Conta Analitica Contabil;Tipo de Operacao;Tipo de Pagamento;"
    "Emitente;Codigo Participante;Nome do Paipante;CNPJ do Participante;"
    "Municipio;UF;Tipo Documento;Modelo Documento;Situacao documento;"
    "Serie;Numero documento fiscal;Data da Emissao;"
    "Data Entrada/Saida;TipMov"
    skip.
        end.                
/****
01-estab.etbcgc;
02-movim.movseq;
03-movim.procod;
04-produ.pronom;
05-produ.codfis;
06-produ.ufdes;
07-;
08-movim.movqtm;
09-Un;
10-Unidade;
11-plani.platot;
12-movim.movpc;
13-;
14-movim.movcsticms;
15-movim.opfcod;
16-;
17-;
18-movim.movbicms;
19-movim.movalicms;
20-movim.movbsubst;
21-movim.movalicms;
22-movim.movsubst;
23-;
24-;
25-;
26-;
27-;
28-movim.movcstpiscof;
29-movim.movbpiscof;
30-movim.movalipis;
31-movim.movpis;
32-movim.movcstpiscof;
33-movim.movbpiscof;
34-movim.movalicofins;
35-movim.movcofins;
36-;
37-;
38-;
39-;
40-;
41-;
42-;
43-;
44-;
45-;
46-;
47-;
48-;
49-;
50-;
51-;
52-;
53-;
54-;
55-;
56-plani.pladat;
57-plani.pladat;
58-estab.etbcod;
59-
*****/

        end.
        if vind-devol then
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 12 and
                             plani.pladat = vdata
                             no-lock:
            vmenos = 0.
            vmais = 0.

            find A01_infnfe where A01_infnfe.emite = plani.emite and
                                  A01_infnfe.serie = plani.serie and
                                  A01_infnfe.numero = plani.numero
                                  no-lock no-error.
            if avail A01_infnfe
            then assign
                     vchave = A01_infnfe.id  
                     vmodelo = "55"
                     vtipo = "Nota Fiscal"
                     .
            else assign
                     vchave = ""
                     vmodelo = ""
                     vtipo = "Nota Fiscal"
                     .            
            
            if vchave = "" and length(plani.ufdes) > 40
            then assign
                    vchave = plani.ufdes
                    vmodelo = "55"
                    .
                                         
            if plani.modcod = "CAN"
            then vsituacao = "CANCELADA".
            else vsituacao = "EMITIDA".

            if length(vchave) < 10 
            then vchave = "".
            else vchave = "'" + vchave + "'".
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock,
                first produ where produ.procod = movim.procod
                            no-lock:
                vmovbicms = 0.
                vmovicms = 0.
                if produ.proipiper = 98 or 
                   produ.pronom matches "*recarga*"
                then do:
                    vmenos = vmenos + (movim.movqtm * movim.movpc).
                end.
                else do:
                    vmais = vmais + movim.movpc * movim.movqtm.
                    if movim.movalicms > 0
                    then do:
                        /*
                        assign
                            vmovbicms = movim.movbicms
                            vmovicms  = movim.movicms.
                        */
                        if vmovbicms = 0
                        then assign
                                vmovbicms = movim.movpc * movim.movqtm
                                vmovicms  = 
                                        vmovbicms * ( movim.movalicms / 100)
                                .
                    end.
                    else assign
                            vmovbicms = 0
                            vmovicms  = 0.
 
                vcfop = if plani.opccod <> ? and
                            length(string(plani.opccod)) = 4
                            then plani.opccod
                            else 1202.

                put  unformatted
                     "'" + estab.etbcgc + "'"           ";"
                     movim.movseq           ";"
                     movim.procod           ";"
                     produ.pronom           ";"
                     produ.codfis           ";"
                     vchave                 ";"
                     ""                     ";"
                     movim.movqtm           ";"
                     "UN"                   ";"
                     "UNIDADE"              ";"
                     ""                     ";"
                     movim.movpc            ";"
                     ""                     ";"
                     ""       ";"
                     vcfop                  ";"
                     /*plani.opccod           ";"*/
                     ""                     ";"
                     ""                     ";"
                     vmovbicms  ";"
                     movim.movalicms        ";"
                     vmovicms          ";"
                     ""        ";"
                     movim.movalicms        ";"
                     movim.movsubst         ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     estab.etbcod           ";"
                     plani.desti            ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     ""                     ";"
                     vtipo                  ";"
                     vmodelo                ";"
                     vsituacao              ";"
                     plani.serie            ";"
                     plani.numero           ";"
                     movim.movdat           ";"
                     movim.movdat           ";"
                     "DEVOLUCAO" 
                     skip.
                    
                    vq = vq + 1.    
                end.
            end.
            
            if vq >= 600000
            then do:
                    output close.
                    vq = 0.
                    vaq = vaq + 1.
                    varquivo = "/admcom/Contabilidade/relat/devolucao-" 
                                    + string(vaq) + "-" 
                                + string(vdti,"99999999") +
                                  string(vdtf,"99999999") + ".csv".
                    output to value(varquivo).
    put "CNPJ do Estabelecimento;Numero Sequencial do Item;Codigo do Item;"
    "Descricao do Item produto;NCM;Chave NF-e/NFC-e;"
    "Descricao Complementar do Item;Quantidade do Item;Unide do Item;"
    "Descricao da Unidade de Medida;Valor Total NF-e/NFC-e/CF;"
    "Valor Total do em;Valor do Desconto;Codigo da Situacao Tributaria ICMS;"
    "CFOP;Codigo da Natura Operacao;Descricao da Natureza de Operacao;"
    "Valor da BC do ICMS;Aliquota do ICMS;"
    "Valor do ICMS:Valor da BC ICMS-ST;"
    "Aliquota do ICMS-ST;Valor do ICMS-ST;Codigo da Situacao Tributaria IPI;"
    "Cod. de Enquadramento Legal do IPI;Valor da BC do IPI;Aliquota do IPI;"
    "Valor do IPI;Codigo da Situacao Tributaria do PIS;Valor da BC do PIS;"
    "Aliquota do PIS (%);Valor do PIS;Codigo da Situacao Tributaria COFINS;"
    "Valor da BC daINS;Aliquota da COFINS (%);Valor da COFINS;"
    "Valor Total do PIS Retido por ST;Valor Ttal da COFINS Retido por ST;"
    "Abatimento nao Tributado e nao Comercial;Tipo do Fretealor do Frete;"
    "Valor do Seguro;Valor de Outras Despesas;"
    "Codigo da Conta Analitica Contabil;Tipo de Operacao;Tipo de Pagamento;"
    "Emitente;Codigo Participante;Nome do Paipante;CNPJ do Participante;"
    "Municipio;UF;Tipo Documento;Modelo Documento;Situacao documento;"
    "Serie;Numero documento fiscal;Data da Emissao;"
    "Data Entrada/Saida;TipMov"
    skip.
        end.                
/****
01-estab.etbcgc;
02-movim.movseq;
03-movim.procod;
04-produ.pronom;
05-produ.codfis;
06-produ.ufdes;
07-;
08-movim.movqtm;
09-Un;
10-Unidade;
11-plani.platot;
12-movim.movpc;
13-;
14-movim.movcsticms;
15-movim.opfcod;
16-;
17-;
18-movim.movbicms;
19-movim.movalicms;
20-movim.movbsubst;
21-movim.movalicms;
22-movim.movsubst;
23-;
24-;
25-;
26-;
27-;
28-movim.movcstpiscof;
29-movim.movbpiscof;
30-movim.movalipis;
31-movim.movpis;
32-movim.movcstpiscof;
33-movim.movbpiscof;
34-movim.movalicofins;
35-movim.movcofins;
36-;
37-;
38-;
39-;
40-;
41-;
42-;
43-;
44-;
45-;
46-;
47-;
48-;
49-;
50-;
51-;
52-;
53-;
54-;
55-;
56-plani.pladat;
57-plani.pladat;
58-estab.etbcod;
59-
*****/

        end.
                     
    end.
end.

output close.

varquivo = replace(varquivo,"/admcom","l:").

message "Arquivo gerado"
    varquivo
    view-as alert-box.
    
