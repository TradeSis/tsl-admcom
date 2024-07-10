{admcab.i}

def var vcobnom as char format "x(12)".
def temp-table tt-titulo no-undo like titulo 
    field certificado as char
    index i1 certificado
    .

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date.

update vdti label "Data inicial"
       vdtf label "Data final"
       with frame f1 1 down side-label width 80.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.


/*******
do vdata = vdti to vdtf:
    for each titulo where
             titulo.titnat = no and
             titulo.titdtpag = vdata and
             titulo.etbcobra = 992
             no-lock:
        if titulo.moecod <> "SEG" 
        then next.
            
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
        tt-titulo.certificado = acha("BAIXA-SINISTRO",titulo.titobs[2]).
    end.
end.

for each tt-titulo where tt-titulo.certificado <> "" no-lock
            break by tt-titulo.certificado:
    if first-off(tt-titulo.certificado)
    then do:
        find first tbsegpag where
                   tbsegpag.certificado = tt-titulo.certificado
                   no-lock no-error.
        if avail tbsegpag
        then do:
        
        end.           
    end.
    disp tt-titulo.certificado format "x(21)"
         tt-titulo.clifor
         tt-titulo.titnum
         tt-titulo.titpar
         tt-titulo.titdtpag
         tt-titulo.titvlpag
         .
end.         
******/

def var varquivo as char.
varquivo = "/admcom/relat/relsinsegpago." + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "180" 
                &Page-Line = "66" 
                &Nom-Rel   = """" 
                &Nom-Sis   = """FINANCEIRO""" 
                &Tit-Rel   = """BAIXAS SINISTRO DE SEGURO""" 
                &Width     = "165"
                &Form      = "frame f-cabcab"}

disp with frame f1.

form with frame fdisp.
do vdata = vdti to vdtf:
    for each fin.tbsegpag where tbsegpag.data_programado = vdata no-lock:
        find clien where clien.clicod = int(tbsegpag.cliente) no-lock.
        
        vcobnom = "".    
        find contrato where contrato.contnum = tbsegpag.contrato no-lock no-error.
        if avail contrato
        then do:
            find cobra where cobra.cobcod = contrato.banco no-lock.
            vcobnom = cobra.cobnom.
            find titulo where titulo.contnum = contrato.contnum and
                              titulo.titpar  = 1
                              no-lock no-error.
            if avail titulo
            then do:
                find cobra of titulo no-lock.
                vcobnom = cobra.cobnom.
            end.
                                          
        end.
        
        disp tbsegpag.data_programado column-label "Data!Programado"
             tbsegpag.valor_pagar     column-label "Valor!Pagar"
             Clien.clinom        column-label "Segurado"
                                    format "x(30)"
             tbsegpag.CPF             column-label "CPF"  format "x(14)"
             tbsegpag.cliente         column-label "Conta!Cliente"
             tbsegpag.contrato        column-label "Contrato"
             vcobnom                   column-label "Carteria"
             tbsegpag.saldo_devedor_contrato column-label "Saldo!Devedor"
             tbsegpag.valor_baixa_contrato column-label "Valor!Baixa"
             tbsegpag.valor_sobra            column-label "Valor!Sobra"
             tbsegpag.valor_baixa_sobra        column-label "Baixa!Sobra"
             tbsegpag.valor_indenizar_cliente  column-label "Valor!Indenizar"
             tbsegpag.certificado format "x(21)"
             with frame fdisp width 190 down.
        down with frame fdisp.     
             
        for each tbsegpagsobra where
                 tbsegpagsobra.certificado = tbsegpag.certificado and
                 tbsegpagsobra.cliente     = tbsegpag.cliente 
                 no-lock:
            disp tbsegpagsobra.contrato @ tbsegpag.contrato
                 tbsegpagsobra.valor_baixa_contrato @                                     tbsegpag.valor_baixa_sobra
                 with frame fdisp.
                 down with frame fdisp.
        end.         
    end.
end.
    
output close.
run visurel.p(varquivo,"").    
