/*
    Motor de Credito: julho/2017
#1 ago/2018 - Novo log
#2 jun/2019
*/
def input parameter p-etbcod   as int.
def input parameter p-cxacod   as int.
def input parameter p-PROPS    as char.
def input parameter p_politica as char.
def input parameter p-time     as int.
def input parameter p-recid-neuclien as recid.
def input-output parameter p-ori-operacao as char.  /* #1 */
def input parameter p-valorcompra as dec.    /* #1 */
def output parameter p_vlrlimite  as dec.
def output parameter p_vctolimite as date.
def output parameter p-neuro-sit  as char.
def output parameter p-neuro-mens as char.
def output parameter p-status     as char.
def output parameter p-mensagem_erro as char.

def var par-recid-neuproposta as recid.
def var vvlrlimitecompl as dec.
def var r-status as char.
def var r-mensagem_erro as char.        
def var varquivo as char. 
def var p-ret-PROPS as char.
def var p-neuro-operacao as char.
 
/* TEMP DE RETORNO */
def NEW SHARED temp-table tt-retorno no-undo
    field PARAMETRO as char format "x(30)"
    field RESPOSTA  as char format "x(40)"
    index par  PARAMETRO asc.    

varquivo = "/ws/log/Neurotech_" +
           string(today, "99999999") + "_" +
           string(p-etbcod) + "_" + string(p-cxacod).

run log("Politica=" + p_politica + " Id=" + p-ori-operacao +
        " Vlr.Compra=" + string(p-valorcompra)).

assign
    p-status = "S"
    p-mensagem_erro = "". 

find neuclien where recid(neuclien) = p-recid-neuclien no-lock no-error.
if not avail neuclien
then do:
    p-status  = "E".
    p-mensagem_erro = "ERRO no cadastramento Cliente".
    run log(p-mensagem_erro).
    return.
end.         
    
/* Cria NeuClienLog */ 
run log("gravaneuclilog sit_credito=" + neuclien.sit_credito).
run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj,
                     p_politica,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     neuclien.sit_credito,
                     p-mensagem_erro). 
    
/** Cria NeuProposta **/
run log("gravaneuproposta").
run neuro/gravaneuproposta_v1802.p
              (string(neuclien.cpfcnpj),
               p_politica,
               p-props,
               "" /* #1 */,
               p-etbcod,
               p-cxacod,
               input p-ori-operacao /* #1 */,
               input ?,
               input "",
               input "",
               input 0,
               input 0,
               input ?,
               input p-recid-neuclien,
               input p-valorcompra /* #1 */,
               input-output par-recid-neuproposta,
               output p-status,
               output p-mensagem_erro).
if p-status = "E"
then do.
    run log("ERRO: gravaneuproposta = E").
    return.
end.

if p-PROPS = ? or p-PROPS = "?"
then do:
    run log("ERRO: props nula").
    p-status = "E".
    return.
end.

run neuro/wssoap.p (p-props, varquivo). /*#2*/

p-ret-PROPS = "".
for each tt-retorno.
    p-ret-PROPS = p-ret-PROPS + 
                  (if p-ret-PROPS = "" then "" else "&") +
                   tt-retorno.PARAMETRO + "=" + tt-retorno.RESPOSTA.
end.
    
assign
    p-neuro-sit  = ""
    p-neuro-mens = ""
    p_vlrlimite  = neuclien.vlrlimite
    p_vctolimite = neuclien.vctolimite
    vvlrlimitecompl = 0.
    
find first tt-retorno where tt-retorno.parametro = "Resultado" no-error.
if avail tt-retorno
then do:
    if tt-retorno.resposta = "APROVADO" or
       tt-retorno.resposta = "A"
    then p-neuro-sit = "A".

    else if tt-retorno.resposta = "PENDENTE" or
            tt-retorno.resposta = "P" 
    then p-neuro-sit = "P".

    else /* #2 */ if tt-retorno.resposta = "REPROVADO" or
         /* #2 */    tt-retorno.resposta = "R"
    then p-neuro-sit = "R".

    /* #1 */
    if p-neuro-sit = ""
    then p-neuro-sit = "P".
end.
else assign
        p-neuro-sit = "R"
        p-status    = "P"
        p-mensagem_erro = "".  
        
find first tt-retorno where tt-retorno.parametro = "DsMensagem" no-error.
if avail tt-retorno
then
    if tt-retorno.resposta <> "OK"
    then p-neuro-mens = tt-retorno.resposta.

find first tt-retorno where tt-retorno.parametro = "RET_MOTIVOS" no-error.
if avail tt-retorno
then
    if tt-retorno.resposta <> ""
    then p-neuro-mens = p-neuro-mens + 
                       (if p-neuro-mens = ""
                        then ""
                        else "/ ") + tt-retorno.resposta.

find first tt-retorno where tt-retorno.parametro = "CdOperacao" no-error.
if avail tt-retorno
then do:  
    p-neuro-operacao = tt-retorno.resposta.
    /* #1 */
    if p-ori-operacao = ""
    then p-ori-operacao = p-neuro-operacao.
        /**    
        if p-mensagem_erro = ""
        then p-mensagem_erro = "cdOperacao=" + p-neuro-operacao.
        **/
end.        
else assign
        p-status = "E"
        p-mensagem_Erro = ""
        p-neuro-sit = "P".
   
find first tt-retorno where tt-retorno.parametro = "RET_NOVOLIMITE" no-error.
if avail tt-retorno
then
    if tt-retorno.resposta <> ""
    then p_vlrlimite = if dec(tt-retorno.resposta) <> 0
                       then dec(tt-retorno.resposta)
                       else neuclien.vlrlimite.

find first tt-retorno where tt-retorno.parametro = "RET_LIMITECOMPL" no-error.
if avail tt-retorno
then
    if tt-retorno.resposta <> ""
    then vvlrlimitecompl = if dec(tt-retorno.resposta) <> 0
                           then dec(tt-retorno.resposta)
                           else 0.
    
find first tt-retorno where tt-retorno.parametro = "RET_DTLIMITEVAL" no-error.
if avail tt-retorno
then
    if tt-retorno.resposta <> ""
    then p_vctolimite = if date(tt-retorno.resposta) <> ?
                        then date(tt-retorno.resposta)
                        else neuclien.vctolimite.
           
/** Atualiza NeuProposta **/
run log("gravaneuproposta Sit=" + p-neuro-sit + " Id=" + p-ori-operacao).
run neuro/gravaneuproposta_v1802.p 
              (string(neuclien.cpfcnpj), 
               p_politica,
               p-props /* #1 */,
               p-ret-PROPS, 
               p-etbcod,
               p-cxacod,
               input p-ori-operacao /* #1 */,
               input p-neuro-operacao,
               input p-neuro-sit,
               input p-neuro-mens,
               input p_vlrlimite,
               input vvlrlimitecompl,
               input p_vctolimite,
               input p-recid-neuclien,
               input p-valorcompra /* #1 */,
               input-output par-recid-neuproposta,
               output r-status,
               output r-mensagem_erro).
        /**
        if r-status = "E"
        then do:
            p-status = "E".
            p-mensagem_erro = r-mensagem_erro.
        end.
        **/

if p-status = "S"
then do:
    run log("gravaneuclihist").
    run neuro/gravaneuclihist.p 
                (p-recid-neuclien,  
                 p_politica,
                 p-etbcod, 
                 neuclien.clicod, 
                 p_vctolimite, 
                 p_vlrlimite, 
                 vvlrlimitecompl,
                 p-neuro-sit).
end. 

/* Atualiza NeuClienLog */
run log("gravaneuclilog " + p-mensagem_erro).
run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj,
                     p_politica,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     p-neuro-sit,
                     p-mensagem_erro + "_" + "OP=" + p-neuro-operacao).

p_vlrlimite = p_vlrlimite + vvlrlimitecompl.
if vvlrlimitecompl <> 0 and (p_vctolimite < today or p_vctolimite = ?)
then p_vctolimite = today.

run log("FIM vlrlimite=" + string(p_vlrlimite) +
        " vctolimite=" + (if p_vctolimite <> ? 
                          then string(p_vctolimite, "99/99/9999") else "") +
        " neuro-sit=" + p-neuro-sit +
        " neuro-mens=" + p-neuro-mens +
        " status=" + p-status +
        " mens.erro=" + p-mensagem_erro).


procedure log.

    def input parameter par-texto as char.

    output to value(varquivo + ".log") append.
    put unformatted string(time,"HH:MM:SS") " wcneuro " par-texto skip.
    output close.

end procedure.

