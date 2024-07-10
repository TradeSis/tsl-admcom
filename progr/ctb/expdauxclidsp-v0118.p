message "/ctb/expdauxclidsp-v0118.p". pause.

def shared var vdti as date.
def shared var vdtf as date.

def var vnum-lanca as int.

def var vetbcod like estab.etbcod.

def temp-table tt-estab like estab.

def temp-table tt-resumo
    field data as date
    field tipo as char
    field debito as dec
    field credito as dec
    index i1 data
    .
    
update vetbcod with frame f-estab side-label width 80 1 down.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-estab.
    create tt-estab.
    buffer-copy estab to tt-estab.
end.
else do:
    for each estab no-lock:
        create tt-estab.
        buffer-copy estab to tt-estab.
    end.
end.            

update vdti label "Data Inicio" format "99/99/9999"
     vdtf label "Data Fim"      format "99/99/9999"
     with frame ff1 1 down width 80 side-label
     no-box color message.
/*
if vdti >= 01/01/15 or
   vdtf >= 01/01/15
then do:
    message color red/with
    "Pereiodo bloqueado."
     view-as alert-box.
     return.
end.
*/

def var vmes as int.
def var vano as int.
vmes = month(vdti).
vano = year(vdti).

def var vreg as int format ">>>>>>>>9".
def stream sdisp.    
def var varqexp as char.
def var varqres as char.
def var vnomarq as char.
vnomarq = "tit".
        
varqexp = "/admcom/decision/" + vnomarq + "_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

varqres = "/admcom/decision/" + vnomarq + "_RESUMO_" + 
                string(month(vdtf),"99") + "_" +
                string(year(vdtf),"9999") + ".csv".

output stream sdisp to terminal.
output to value(varqexp).

def var vdata as date.
def var vhistorico as char.
form with frame f-disp  row 12 1 down side-label.

do vdata = vdti to vdtf:
    disp stream sdisp vdata label "Data" with frame f-disp.
    pause 0.
    for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                          else true) no-lock:
        
        disp stream sdisp estab.etbcod label "Filial"
        with frame f-disp. pause 0.

        
        for each diauxcli18 where
                 diauxcli18.data = vdata and
                 diauxcli18.etbcod = estab.etbcod and
                 diauxcli18.situacao
                 no-lock:
            if diauxcli18.tipo = "EMISSAO"
            then run diauxcli-emissao.
            if diauxcli18.tipo = "RECEBIMENTO"
            then run diauxcli-recebimento.
        end.         
                 
    end.
end.    


output stream sdisp close.
output close.
def var vdebito as char.
def var vcredito as char.
output to value(varqres).
put "Data;Debito;Credito" skip.
for each tt-resumo use-index i1:

    assign
        vdebito = string(tt-resumo.debito,">>>>>>>>>>>9.99")
        vdebito = replace(vdebito,".",",")
        vcredito = string(tt-resumo.credito,">>>>>>>>>>>9.99")
        vcredito = replace(vcredito,".",",")
        .
    
    put unformatted 
        tt-resumo.data ";"
        tt-resumo.tipo ";"
        vdebito format "x(16)" ";"
        vcredito format "x(16)" ";"
        skip.

end.
output close.    
output to ./xdac.
unix silent unix2dos value(varqexp).
output close.

message color red/with
    "Arquivos gerados" skip 
    varqexp skip
    /*varqres */
    view-as alert-box.
      
procedure diauxcli-emissao.


    run resumo(input diauxcli18.data, 
               input "EMISSAO",
               input diauxcli18.valor,
               input 0).
               
    put unformat
     diauxcli18.etbcod format ">>9"           /* 01-16 */
     "C" + string(diauxcli18.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(diauxcli18.numero) format "999999999999"  /* 32-43 */
     year(diauxcli18.data) format "9999"          /* 44-51 */
     month(diauxcli18.data) format "99"          
     day(diauxcli18.data)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     diauxcli18.valor    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(diauxcli18.data)  format "9999" /* 72-79 */
     month(diauxcli18.data) format "99"  
     day(diauxcli18.data)   format "99"
     diauxcli18.valor format "9999999999999.99"  /* 80-95 */
     year(diauxcli18.data) format "9999"  /* 96-103 */
     month(diauxcli18.data) format "99"  
     day(diauxcli18.data) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "EMISSAO "  format "x(250)"      /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure diauxcli-recebimento:
    
    run resumo(input diauxcli18.data, 
               input "RECEBIMENTO",  
               input 0,
               input diauxcli18.valor).

    put unformat skip
     diauxcli18.etbcod format ">>9"           /* 01-03 */
     "C" + string(diauxcli18.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(diauxcli18.numero) format "999999999999"  /* 32-43 */
     year(diauxcli18.data) format "9999"          /* 44-51 */
     month(diauxcli18.data) format "99"          
     day(diauxcli18.data)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     diauxcli18.valor        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(diauxcli18.data)  format "9999" /* 72-79 */
     month(diauxcli18.data) format "99"  
     day(diauxcli18.data)   format "99"
     diauxcli18.valor format "9999999999999.99"  /* 80-95 */
     year(diauxcli18.data) format "9999"  /* 96-103 */
     month(diauxcli18.data) format "99"  
     day(diauxcli18.data) format "99"
     " "   format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"    /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-emissao.


    run resumo(input opctbval.datref, 
               input "EMISSAO",
               input opctbval.valor,
               input 0).
               
    put unformat
     estab.etbcod format ">>9"           /* 01-16 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     opctbval.valor    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "EMISSAO"  format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-estorno:

    run resumo(input opctbval.datref, 
               input "ESTORNO", 
               input opctbval.valor,
               input 0).
    
    put unformat
        opctbval.etbcod format ">>9"           /* 01-03 */
        "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
        "EST"  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        dec(opctbval.t9) format "999999999999"  /* 32-43 */
        year(opctbval.datref) format "9999"          /* 44-51 */
        month(opctbval.datref) format "99"          
        day(opctbval.datref)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        opctbval.valor    format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(opctbval.datref)  format "9999" /* 72-79 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref)   format "99"
        opctbval.valor format "9999999999999.99"  /* 80-95 */
        year(opctbval.datref) format "9999"  /* 96-103 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        "ESTORNO" format "x(250)"               /* 144-393  Histórico */ 
        skip
        .
end procedure.
procedure put-acrescimo:

    run resumo(input opctbval.datref, 
               input "ACRESCIMO", 
               input opctbval.valor,
               input 0).

    put unformat
        opctbval.etbcod format ">>9"           /* 01-03 */
        "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
        "ACR "  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        dec(opctbval.t9) format "999999999999"  /* 32-43 */
        year(opctbval.datref) format "9999"          /* 44-51 */
        month(opctbval.datref) format "99"          
        day(opctbval.datref)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        opctbval.valor    format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(opctbval.datref)  format "9999" /* 72-79 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref)   format "99"
        opctbval.valor format "9999999999999.99"  /* 80-95 */
        year(opctbval.datref) format "9999"  /* 96-103 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        "ACRESCIMO" format "x(250)"               /* 144-393  Histórico */
        skip 
         .
end procedure.
procedure put-devolucao:

    run resumo(input opctbval.datref, 
               input "DEVOLUCAO", 
               input 0,
               input opctbval.valor).
    
    put unformat
     opctbval.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     opctbval.valor    format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "DEVOLUCAO" format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-recebimento:
    
    run resumo(input opctbval.datref, 
               input "RECEBIMENTO",  
               input 0,
               input opctbval.valor).

    put unformat skip
     opctbval.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     opctbval.valor        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     " "   format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"    /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure resumo:
    
    def input parameter p-data as date.
    def input parameter p-tipo as char.
    def input parameter p-debito as dec.
    def input parameter p-credito as dec.

    find first tt-resumo where
               tt-resumo.data = p-data and
               tt-resumo.tipo = p-tipo  no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.data = p-data.
        tt-resumo.tipo = p-tipo.
    end.
    assign
        tt-resumo.debito = tt-resumo.debito + p-debito
        tt-resumo.credito = tt-resumo.credito + p-credito.        
end procedure.

procedure message-reg:
    def input parameter p-tipo as char format "x(20)".
    vreg = vreg + 1.
    if vreg mod 1000 = 0
    then do:
        disp stream sdisp  "Aguarde processamento " p-tipo no-label 
        vreg no-label
                "registros processados"
                with frame f-disp1 1 down no-box color message row 15
                 width 80 .
                pause 0.      
       end. 
end.            
