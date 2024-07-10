/*  cadcredscore.p    - Manutencao dos Parametros para Score de Credito       */
{admcab.i}

def var rlimmaximo      as recid.
def var rlimmaximoc     as recid.
def var rnumparcpg      as recid.
def var rvalparcpg      as recid.
def var rlimmatraso     as recid.
def var rpercrenda      as recid.
def var rfoneconv       as recid.
def var rdescalug       as recid.
def var remail          as recid.
def var rcarro          as recid. 
def var rcriic          as recid.
def var rcriic1         as recid.
def var rcriic2         as recid.
def var rpsaude         as recid.
def var depen-recid     as recid extent 7.
def var idade-recid     as recid extent 7.
def var sexo-recid      as recid extent 2.
def var ecivil-recid    as recid extent 6.
def var grinstru-recid  as recid extent 5.
def var seguros-recid   as recid extent 5.
def var tempores-recid  as recid extent 3.
def var anocarro-recid  as recid extent 3.
def var tempotrab-recid as recid extent 3.
def var cartoes-recid   as recid extent 4.
def var refban-recid    as recid extent 3.
def var tipconta-recid  as recid extent 2.
def var rsalariominimo  as recid.
def var renda-recid     as recid.
def var rrefer          as recid.
def var rrefnp          as recid.
def var rreferc         as recid.
def var rrefnpc         as recid.

def var vlimmaximo      as dec initial 0.
def var vlimmaximoc     as dec initial 0.
def var vnumparcpg      as int initial 0.
def var vvalparcpg      as dec initial 0.
def var vlimmatraso     as int initial 0.
def var vpercrenda      as dec initial 0.
def var vfoneconv       as log initial yes format "Sim/Nao".
def var vemail          as log initial yes format "Sim/Nao".
def var vcarro          as log initial yes format "Sim/Nao" .
def var vcriic          like credscore.valor format ">>>9".
def var vcriic1         like credscore.valor format ">>>9".
def var vcriic2         like credscore.valor format ">>>9".
def var vpsaude         as log initial yes format "Sim/Nao".
def var vdescalug       as log initial yes format "Sim/Nao".    
def var vrensalmin      as dec init 0.
def var vsalariominimo  as dec init 0.

def var fone-tipo        as log init yes. /* Fone Conv. - Tipo de Valor */
def var fone-operacao    as log init yes. /* Diminui ou Soma */
def var fone-valor       as dec. /* Valor ou Percentual */
def var fone-consparc    as log init yes. /* Fone Conv. - Cons. Num Parcelas */

def var vlalug-tipo        as log init yes. /* Aluguel - Tipo de Valor */
def var vlalug-operacao    as log init yes. /* Diminui ou Soma */
def var vlalug-valor       as dec. /* Valor ou Percentual */
def var vlalug-consparc    as log init yes. /* Aluguel - Cons. Num Parcelas */

def var email-tipo        as log init yes. /* E-mail - Tipo de Valor */
def var email-operacao    as log init yes. /* Diminui ou Soma */
def var email-valor       as dec. /* Valor ou Percentual */
def var email-consparc    as log init yes. /* E-mail - Cons. Num Parcelas */

def var carro-tipo        as log init yes. /* E-mail - Tipo de Valor */
def var carro-operacao    as log init yes. /* Diminui ou Soma */
def var carro-valor       as dec. /* Valor ou Percentual */
def var carro-consparc    as log init yes. /* E-mail - Cons. Num Parcelas */

def var psaude-tipo        as log init yes. /* Plano Saude - Tipo de Valor */
def var psaude-operacao    as log init yes. /* Diminui ou Soma */
def var psaude-valor       as dec. /* Valor ou Percentual */
def var psaude-consparc    as log init yes. /* Plano Saude - Cons. Num Parcelas */

/*
def var alug-consparc    as log init yes. /* Aluguel - Cons. Num Parcelas */
*/

def var renda-tipo        as log init yes. /* Renda - Tipo de Valor */
def var renda-qtd         as dec. /* Valor da Renda em SM */
def var renda-operacao    as log init yes. /* Diminui ou Soma */
def var renda-valor       as dec. /* Valor ou Percentual */
def var renda-consparc    as log init yes. /* Renda  - Cons. Num Parcelas */

def var depen-tipo     as log init yes extent 7. /* Dependentes - Tipo de Valor */
def var depen-qtd      as int         extent 7. /* Quantidade de dependentes */
def var depen-operacao as log init yes extent 7. /* Diminui ou Soma */
def var depen-valor    as dec         extent 7. /* Valor ou Percentual */
def var depen-consparc as log init yes extent 7. /* Dependentes - Cons. Num Parcelas */

def var idade-tipo  as log init yes extent  7   format "Perc/Val".  
def var idade-ini   as int  extent  7   format ">9".    
def var idade-fin   as int  extent  7 format ">9".  
def var idade-operacao as log init yes extent   7 format "Dim/Som". 
def var idade-valor as dec  extent  7.  
def var idade-consparc as log init no extent    7 format "Sim/Nao". 
def var idade-obs   as char extent  7 format "x(15)".

def var sexo-tipo        as log init yes extent 2. /* Sexo - Tipo de Valor */
def var sexo-desc        as char         extent 2. /* Sexo */
def var sexo-operacao    as log init yes extent 2. /* Diminui ou Soma */
def var sexo-valor       as dec extent 2. /* Valor ou Percentual */
def var sexo-consparc    as log init yes extent 2. /* Sexo - Cons. Num Parcelas */

def var ecivil-tipo      as log init yes extent 6. /* E.Civil - Tipo de Valor */
def var ecivil-desc      as char extent 6. /* Estado Civil */
def var ecivil-operacao  as log init yes extent 6. /* Diminui ou Soma */
def var ecivil-valor     as dec         extent 6. /* Valor ou Percentual */
def var ecivil-consparc  as log init yes extent 6. /* E. Civil - Cons. Num Parcelas */

def var grinstru-tipo      as log init yes extent 5. /* Tipo de Valor */
def var grinstru-desc      as char extent 5. /* Grau de Instrucao */
def var grinstru-operacao  as log init yes extent 5. /* Diminui ou Soma */
def var grinstru-valor     as dec         extent 5. /* Valor ou Percentual */
def var grinstru-consparc  as log init yes extent 5. /* Num Parc~elas */

def var seguros-tipo      as log init yes extent 5. /* Tipo de Valor */
def var seguros-desc      as char extent 5. /* Grau de Instrucao */
def var seguros-operacao  as log init yes extent 5. /* Diminui ou Soma */
def var seguros-valor     as dec         extent 5. /* Valor ou Percentual */
def var seguros-consparc  as log init yes extent 5. /*  Cons. Num Parc~elas */

def var tempores-tipo      as log init yes extent 3. /* Tipo de Valor */
def var tempores-ini   as int  extent  3   format ">>9".    
def var tempores-fin   as int  extent  3 format ">>>>9".
def var tempores-desc      as char extent 3. /* Grau de Instrucao */
def var tempores-operacao  as log init yes extent 3. /* Diminui ou Soma */
def var tempores-valor     as dec         extent 3. /* Valor ou Percentual */
def var tempores-consparc  as log init yes extent 3. /*  Cons. Num Parc~elas */

def var anocarro-ini       as int extent 3.
def var anocarro-fin       as int extent 3.
def var anocarro-tipo      as log init yes extent 3. /* Tipo de Valor */
def var anocarro-desc      as char extent 3. /* Grau de Instrucao */
def var anocarro-operacao  as log init yes extent 3. /* Diminui ou Soma */
def var anocarro-valor     as dec         extent 3. /* Valor ou Percentual */
def var anocarro-consparc  as log init yes extent 3. /*  Cons. Num Parc~elas */

def var tempotrab-tipo      as log init yes extent 3. /* Tipo de Valor */
def var tempotrab-ini   as int  extent  3   format ">>9".    
def var tempotrab-fin   as int  extent  3 format ">>>>9".
def var tempotrab-desc      as char extent 3. /* Grau de Instrucao */
def var tempotrab-operacao  as log init yes extent 3. /* Diminui ou Soma */
def var tempotrab-valor     as dec         extent 3. /* Valor ou Percentual */
def var tempotrab-consparc  as log init yes extent 3. /*  Cons. Num Parc~elas */

def var cartoes-tipo      as log init yes extent 4. /* Tipo de Valor */
def var cartoes-desc      as char extent 4. /* Grau de Instrucao */
def var cartoes-operacao  as log init yes extent 4. /* Diminui ou Soma */
def var cartoes-valor     as dec         extent 4. /* Valor ou Percentual */
def var cartoes-consparc  as log init yes extent 4. /*  Cons. Num Parc~elas */ 

def var refban-tipo      as log init yes extent 3. /* Tipo de Valor */
def var refban-ini       as int  extent  3   format ">9".    
def var refban-fin       as int  extent  3 format ">9".
def var refban-desc      as char extent 3. /* Grau de Instrucao */
def var refban-operacao  as log init yes extent 3. /* Diminui ou Soma */
def var refban-valor     as dec         extent 3. /* Valor ou Percentual */
def var refban-consparc  as log init yes extent 3. /*  Cons. Num Parc~elas */ 

def var tipconta-tipo      as log init yes extent 2. /* Tipo de Valor */
def var tipconta-desc      as char extent 2. /* Grau de Instrucao */
def var tipconta-operacao  as log init yes extent 2. /* Diminui ou Soma */
def var tipconta-valor     as dec         extent 2. /* Valor ou Percentual */
def var tipconta-consparc  as log init yes extent 2. /*  Cons. Num Parc~elas */
 
def var refer-tipo        as log init yes. /* Renda - Tipo de Valor */
def var refer-qtd         as int. /* Valor da Renda em SM */
def var refer-operacao    as log init yes. /* Diminui ou Soma */
def var refer-valor       as dec. /* Valor ou Percentual */
def var refer-consparc    as log init yes. /* Renda  - Cons. Num Parcelas */

def var refnp-tipo        as log init yes. /* Renda - Tipo de Valor */
def var refnp-log         as log init yes. /* Valor da Renda em SM */
def var refnp-operacao    as log init yes. /* Diminui ou Soma */
def var refnp-valor       as dec. /* Valor ou Percentual */
def var refnp-consparc    as log init yes. /* Renda  - Cons. Num Parcelas */

def var referc-tipo        as log init yes. /* Renda - Tipo de Valor */
def var referc-qtd         as int. /* Valor da Renda em SM */
def var referc-operacao    as log init yes. /* Diminui ou Soma */
def var referc-valor       as dec. /* Valor ou Percentual */
def var referc-consparc    as log init yes. /* Renda  - Cons. Num Parcelas */

def var refnpc-tipo        as log init yes. /* Renda - Tipo de Valor */
def var refnpc-log         as log init yes. /* Valor da Renda em SM */
def var refnpc-operacao    as log init yes. /* Diminui ou Soma */
def var refnpc-valor       as dec. /* Valor ou Percentual */
def var refnpc-consparc    as log init yes. /* Renda  - Cons. Num Parcelas */

def var esqpos1           as int.
def var esqpos2           as int.
def var pos               as int.
def var qtdpos            as int.

def var vcobranca         as log.
def var vpessoais         as log.
def var vbasicas          as log.

def var vopcao            as char.
def var recatu2 as recid.

def var vpes-pessoal as log.
def var vpes-conjuge as log.
def var vpes-refer   as log.
def var vpes-patrim  as log.

/* Guarda conteudo das variaveis para comparar depois */
def var ant-campo           like credscore.campo.
def var ant-desc-campo      like credscore.desc-campo.
def var ant-vl-ini          like credscore.vl-ini.
def var ant-vl-fin          like credscore.vl-fin.
def var ant-vl-char         like credscore.vl-char.
def var ant-vl-log          like credscore.vl-log.
def var ant-tipo-vl         like credscore.tipo-vl.
def var ant-operacao        like credscore.operacao.
def var ant-valor           like credscore.valor.
def var ant-consnumparc     like credscore.consnumparc.
def var ant-observacoes     like credscore.observacoes.

def var dep-campo           like credscore.campo.
def var dep-desc-campo      like credscore.desc-campo.
def var dep-vl-ini          like credscore.vl-ini.
def var dep-vl-fin          like credscore.vl-fin.
def var dep-vl-char         like credscore.vl-char.
def var dep-vl-log          like credscore.vl-log.
def var dep-tipo-vl         like credscore.tipo-vl.
def var dep-operacao        like credscore.operacao.
def var dep-valor           like credscore.valor.
def var dep-consnumparc     like credscore.consnumparc.
def var dep-observacoes     like credscore.observacoes.

def var recatu1 as recid.
def var vtipoalt as char.
def var recatu  as recid.
           
def var esqcom1         as char format "x(14)" extent 11
            initial ["Basicas","Pessoais","Profissionais",
            "Ref. Pessoais","Ref. Comer.", "Inf. Adicionais","Dados 1","Dados 2","Dados 3","Dados 4","Dados 5"].

            /*
def var esqcom2         as char format "x(14)" extent 5
            initial ["Dados 1","Dados 2","Dados 3","Dados 4","Dados 5"].
*/

form
      esqcom1[1] format "x(10)"
      esqcom1[2] format "x(10)"
      esqcom1[3] format "x(13)"
      esqcom1[4]
      esqcom1[5]
      esqcom1[6]
      skip
      esqcom1[7]
      esqcom1[8]
      esqcom1[9]
      esqcom1[10]
      esqcom1[11]
      with frame f-com1 centered
                 row 7 no-box no-labels side-labels overlay.

/*
form esqcom2 with frame f-com2 centered
    row 22 no-box no-labels side-labels overlay.
*/    
    
run mostra.

pause 0.
disp "PARAMETROS DE SCORE DE CREDITO " at 25 with frame f-cabec
    row 4 size 80 by 14 overlay no-box.
pause 0.

esqpos1 = 1.    
esqpos2 = 1.
disp  esqcom1 with frame f-com1.
color display message esqcom1[esqpos1] with frame f-com1.
/*disp esqcom2 with frame f-com2.*/

pause 0.

/* Limite Maximo - Behavior */
find first credscore where credscore.campo = "LIMMAXIMO"
    no-lock no-error.
if avail credscore
then vlimmaximo = credscore.vl-ini.
else vlimmaximo = 0.

/* Limite Maximo - Credscore */
find first credscore where credscore.campo = "LIMMAXIMOC"
    no-lock no-error.
if avail credscore
then vlimmaximoc = credscore.vl-ini.
else vlimmaximoc = 0.

/* Quantidade de Parcelas Pagas */
find first credscore where credscore.campo = "NUMPARCPG"
    no-lock no-error.
if avail credscore
then vnumparcpg = credscore.vl-ini.
else vnumparcpg = 0.

/* Valor das Parcelas Pagas */
find first credscore where credscore.campo = "VALPARCPG"
    no-lock no-error.
if avail credscore
then vvalparcpg = credscore.vl-ini.
else vvalparcpg = 0.

/* Limite de Media de Atraso */
find first credscore where credscore.campo = "LIMMATRASO"
    no-lock no-error.
if avail credscore
then vlimmatraso = credscore.vl-ini.
else vlimmatraso = 0.

/* Percentual sobre a Renda p/ Calculo de Limite */
find first credscore where credscore.campo = "PERCRENDA"
    no-lock no-error.
if avail credscore
then vpercrenda = credscore.vl-ini.
else vpercrenda = 0.

/* Dependentes */
qtdpos = 0.
for each credscore where credscore.campo = "depen" no-lock
    by credscore.vl-ini.
    qtdpos = qtdpos + 1.
    depen-tipo[qtdpos]     = credscore.tipo-vl.
    depen-qtd[qtdpos]      = credscore.vl-ini.
    depen-valor[qtdpos]    = credscore.valor.
    depen-consparc[qtdpos] = credscore.consnumparc.
    depen-operacao[qtdpos] = credscore.operacao.
end.

/* Idade */
qtdpos = 0.
for each credscore where credscore.campo = "idade" no-lock
    by credscore.vl-ini.
    qtdpos = qtdpos + 1.
    idade-tipo[qtdpos]     = credscore.tipo-vl.
    idade-ini[qtdpos]      = credscore.vl-ini.
    idade-fin[qtdpos]      = credscore.vl-fin.
    idade-valor[qtdpos]    = credscore.valor.
    idade-consparc[qtdpos] = credscore.consnumparc.
    idade-operacao[qtdpos] = credscore.operacao.
    idade-obs[qtdpos]      = credscore.observacoes.
end.

form
    "Planos de Saude" 
     vpsaude at 20
     help "Possui Planos de Saude ?" 
     psaude-tipo                      format "Perc/Val"   at 26
     psaude-operacao                  format "Dim/Som"    at 36
     psaude-valor
     psaude-consparc                  format "Sim/Nao"    at 60
             skip(1)
        "   Idade   Perc/Val    Dim/Som Valor   Cons.Num.Parc.Pg"
        skip
/*idade-obs[1]  format "x(18)"*/
        idade-ini[1] format "99"
        idade-fin[1] format "99"
        idade-tipo[1]   at  20 format "Perc/Val"
        idade-operacao[1]   at  31 format "Dim/Som"
        idade-valor[1]
        idade-consparc[1]   at  54 format "Sim/Nao"
        skip    
        /*   idade-obs[2]    format "x(18)"*/
        idade-ini[2] format "99"
        idade-fin[2] format "99"
        idade-tipo[2]   at  20 format "Perc/Val"
        idade-operacao[2]   at  31 format "Dim/Som"
        idade-valor[2]
        idade-consparc[2]   at  54 format "Sim/Nao" 
skip    
        /*  idade-obs[3]    format "x(18)"*/
        idade-ini[3] format "99"
        idade-fin[3] format "99"
        idade-tipo[3]   at  20 format "Perc/Val"
        idade-operacao[3]   at  31 format "Dim/Som"
        idade-valor[3]
        idade-consparc[3]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[4]    format "x(18)"*/
        idade-ini[4] format "99"
        idade-fin[4] format "99"
        idade-tipo[4]   at  20 format "Perc/Val"
        idade-operacao[4]   at  31 format "Dim/Som"
        idade-valor[4]
        idade-consparc[4]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[5]    format "x(18)"*/
        idade-ini[5] format "99"    
idade-fin[5] format "99"
        idade-tipo[5]   at  20 format "Perc/Val"
        idade-operacao[5]   at  31 format "Dim/Som"
        idade-valor[5]
        idade-consparc[5]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[6]    format "x(18)"*/
        idade-ini[6] format "99"
        idade-fin[6] format "99"
        idade-tipo[6]   at  20 format "Perc/Val"
        idade-operacao[6]   at  31 format "Dim/Som"
        idade-valor[6]
        idade-consparc[6]   at  54 format "Sim/Nao"
        with frame fadic no-label
        row 9 size  80 by   14 overlay no-box.
        
/* Possui Fone Convencional */
find first credscore where credscore.campo = "foneconv"
    no-lock no-error.
if avail credscore
then assign vfoneconv = credscore.vl-log
            fone-tipo = credscore.tipo
            fone-operacao = credscore.operacao
            fone-valor = credscore.valor
            fone-consparc = credscore.consnumparc.
else vfoneconv = no.

/* Desconta Valor do Aluguel */
find first credscore where credscore.campo = "descalug"
    no-lock no-error.
if avail credscore
then assign vdescalug = credscore.vl-log
            vlalug-tipo = credscore.tipo
            vlalug-operacao = credscore.operacao
            vlalug-valor = credscore.valor
            vlalug-consparc = credscore.consnumparc.
else vdescalug = no.
 
disp "Qtde Parcelas Pagas a Considerar" 
     vnumparcpg
     "Valor"
     vvalparcpg
     skip
     "Limites: Behavior"
     vlimmaximo
     "Credscore"
     vlimmaximoc
     "Lim Media Atraso"
     vlimmatraso
     skip
     "Percentual para Calculo de Limite"
     vpercrenda colon 40
     skip
     "Dependentes -> Qtde   Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
     skip
     depen-qtd[1]                     at 10
     depen-tipo[1]                    at 26 format "Perc/Val"
     depen-operacao[1]                at 36 format "Dim/Som"
     depen-valor[1]                   
     depen-consparc[1]                at 60 format "Sim/Nao"
     depen-qtd[2]                     at 10
     depen-tipo[2]                    at 26 format "Perc/Val"
     depen-operacao[2]                at 36 format "Dim/Som"
     depen-valor[2]                   
     depen-consparc[2]                at 60 format "Sim/Nao"
     depen-qtd[3]                     at 10
     depen-tipo[3]                    at 26 format "Perc/Val"
     depen-operacao[3]                at 36 format "Dim/Som"
     depen-valor[3]                   
     depen-consparc[3]                at 60 format "Sim/Nao"
     depen-qtd[4]                     at 10
     depen-tipo[4]                    at 26 format "Perc/Val"
     depen-operacao[4]                at 36 format "Dim/Som"
     depen-valor[4]                   
     depen-consparc[4]                at 60 format "Sim/Nao"
     depen-qtd[5]                     at 10
     depen-tipo[5]                    at 26 format "Perc/Val"
     depen-operacao[5]                at 36 format "Dim/Som"
     depen-valor[5]                   
     depen-consparc[5]                at 60 format "Sim/Nao"
     depen-qtd[6]                     at 10
     depen-tipo[6]                    at 26 format "Perc/Val"
     depen-operacao[6]                at 36 format "Dim/Som"
     depen-valor[6]                   
     depen-consparc[6]                at 60 format "Sim/Nao"
     depen-qtd[7]                     at 10
     depen-tipo[7]                    at 26 format "Perc/Val"
     depen-operacao[7]                at 36 format "Dim/Som"
     depen-valor[7]                   
     depen-consparc[7]                at 60 format "Sim/Nao"
     skip
     "Fone Convencional" 
     vfoneconv at 20
     help "Possui Telefone Convencional ?" 
     fone-tipo                      format "Perc/Val"   at 26
     fone-operacao                  format "Dim/Som"    at 36
     fone-valor
     fone-consparc                  format "Sim/Nao"    at 60
     skip
     "Paga Aluguel"
     vdescalug at 20
     help "Paga Aluguel ?"
     vlalug-tipo                      format "Perc/Val"   at 26
     vlalug-operacao                  format "Dim/Som"    at 36
     vlalug-valor
     vlalug-consparc                  format "Sim/Nao"    at 60
     with frame fbasicas no-label 
        row 8 size 80 by 14 overlay no-box.

         
esqcom1[esqpos1]  = "Basicas".
vbasicas = yes.

repeat:
    readkey.
    pause 0.

    if keyfunction(lastkey) = "5" and vcobranca = yes
    then do: 
        vcobranca = no. 
        run resid ("consulta").
        next. 
    end.

    if keyfunction(lastkey) = "End-Error"
    then leave.
    if keyfunction(lastkey) = "cursor-right"
    then do:
        color display normal esqcom1[esqpos1] with frame f-com1.
        esqpos1 = if esqpos1 = 11 then 11 else esqpos1 + 1.
        color display messages esqcom1[esqpos1] with frame f-com1.
    end.
    if keyfunction(lastkey) = "cursor-left"
    then do:
        color display normal esqcom1[esqpos1] with frame f-com1.
        esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
        color display messages esqcom1[esqpos1] with frame f-com1.
    end.
    assign vpessoais = no
           vbasicas  = no.
    if esqcom1[esqpos1]  = "Basicas"
    then assign vbasicas = yes
                vpes-pessoal = no
                vpes-conjuge = no
                vpes-refer   = no
                vpes-patrim  = no .
    if esqcom1[esqpos1]  = "Pessoais"
    then assign vpessoais = yes
                vcobranca = no.
    if esqcom1[esqpos1]  = "Basicas" or vbasicas
    then do:
        vbasicas = yes.
        pause 0.
        
        vopcao = keyfunction(lastkey).

        if keyfunction(lastkey) = "RETURN"
        then do: /* MANUTENCAO */
        
                find first credscore where credscore.campo = "NUMPARCPG"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rnumparcpg = recatu1.
                
                update 
                    vnumparcpg
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Quantidade de Parcelas Pagas */
                find first credscore where credscore.campo = "NUMPARCPG"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "NUMPARCPG".
                    credscore.desc-campo = "Numero de Parcelas Pagas".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vnumparcpg.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "numparcpg",
                               input recatu1).
                               
                find first credscore where credscore.campo = "VALPARCPG"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rvalparcpg = recatu1.
                
                update 
                    vvalparcpg
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Valor das Parcelas Pagas */
                find first credscore where credscore.campo = "VALPARCPG"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "VALPARCPG".
                    credscore.desc-campo = "Valor das Parcelas Pagas".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vvalparcpg.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "valparcpg",
                               input recatu1).

                find first credscore where credscore.campo = "LIMMAXIMO"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rlimmaximo = recatu1.
                
                update 
                    vlimmaximo
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Limite Maximo */
                find first credscore where credscore.campo = "LIMMAXIMO"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "LIMMAXIMO".
                    credscore.desc-campo = "Limite Maximo".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vlimmaximo.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "limmaximo",
                               input recatu1).
                               
                find first credscore where credscore.campo = "LIMMAXIMOC"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rlimmaximoc = recatu1.
                
                update 
                    vlimmaximoc
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Limite Maximo */
                find first credscore where credscore.campo = "LIMMAXIMOC"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "LIMMAXIMOC".
                    credscore.desc-campo = "Limite Credsc".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vlimmaximoc.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "limmaximoc",
                               input recatu1).                               
                
                find first credscore where credscore.campo = "LIMMATRASO"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rlimmatraso = recatu1.
                
                update 
                    vlimmatraso
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Limitador de Media de Atraso */
                find first credscore where credscore.campo = "LIMMATRASO"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "LIMMATRASO".
                    credscore.desc-campo = "Limite de Media de Atraso".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vlimmatraso.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "limmatraso",
                               input recatu1).

                find first credscore where credscore.campo = "PERCRENDA"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval (input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval (input "Inclusao").
                end.    
                rpercrenda = recatu1.
                
                update 
                    vpercrenda colon 40
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.
                        
                /* Percentual para Calculo de Limite */
                find first credscore where credscore.campo = "PERCRENDA"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "PERCRENDA".
                    credscore.desc-campo = "Numero de Parcelas Pagas".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-ini = vpercrenda.
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "percrenda",
                               input recatu1).
                               
                do qtdpos = 1 to 7:
                   find first credscore where credscore.campo = "depen"
                                        and credscore.vl-ini = depen-qtd[qtdpos]
                                           no-lock no-error.
                    if avail credscore
                    then do:
                        recatu1 = recid(credscore).
                        run p-guardaval (input "Alteracao").
                    end.    
                    else do:
                        recatu1 = ?.
                        run p-guardaval (input "Inclusao").
                    end.    
                    depen-recid[qtdpos] = recatu1.
                    
                    update     
                        depen-qtd[qtdpos]             at 10
                        depen-tipo[qtdpos]            at 26 format "Perc/Val"
                        depen-operacao[qtdpos]        at 36 format "Dim/Som"
                        depen-valor[qtdpos]           
                        depen-consparc[qtdpos]        at 60 format "Sim/Nao"
                        with frame fbasicas no-label 
                            row 9 size 80 by 14 overlay no-box.
                            
                find first credscore
                    where recid(credscore) = depen-recid[qtdpos]
                        exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo         = "depen".
                    credscore.desc-campo    = "Dependentes".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.tipo-vl       = depen-tipo[qtdpos].
                credscore.vl-ini        = depen-qtd[qtdpos].
                credscore.valor         = depen-valor[qtdpos].
                credscore.consnumparc   = depen-consparc[qtdpos].
                credscore.operacao      = depen-operacao[qtdpos].
                
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "depen",
                               input recatu1).
                end. /* do qtdpos */                 

                find first credscore where credscore.campo = "foneconv"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rfoneconv = recatu1.
                
                update skip
                    vfoneconv at 20
                    help "Possui Telefone Convencional ?" 
                    fone-tipo                      format "Perc/Val" at 26
                    fone-operacao                  format "Dim/Som"  at 36
                    fone-valor
                    fone-consparc                  format "Sim/Nao"  at 60
                    skip
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.

                /* Possui Fone Convencional */
                find first credscore where credscore.campo = "foneconv"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "foneconv".
                    credscore.desc-campo = "Possui Fone Convencional".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-log        = vfoneconv.
                credscore.tipo-vl       = fone-tipo.
                credscore.valor         = fone-valor.
                credscore.consnumparc   = fone-consparc.
                credscore.operacao      = fone-operacao.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "foneconv",
                               input recatu1).


                find first credscore where credscore.campo = "descalug"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rdescalug = recatu1.
                
                update 
                    vdescalug at 20
                    help "Paga Aluguel ?" 
                    vlalug-tipo                      format "Perc/Val" at 26
                    vlalug-operacao                  format "Dim/Som"  at 36
                    vlalug-valor
                    vlalug-consparc                  format "Sim/Nao"  at 60
                    skip
                    with frame fbasicas no-label 
                        row 9 size 80 by 14 overlay no-box.

                /* Paga Aluguel */
                find first credscore where credscore.campo = "descalug"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "descalug".
                    credscore.desc-campo = "Paga Aluguel".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-log        = vdescalug.
                credscore.tipo-vl       = vlalug-tipo.
                credscore.valor         = vlalug-valor.
                credscore.consnumparc   = vlalug-consparc.
                credscore.operacao      = vlalug-operacao.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "descalug",
                               input recatu1).           
           
        end.
        else do: /* CONSULTA */
        
            /* BASICAS */
        
            /* Quantidade de Parcelas Pagas */
            find first credscore where credscore.campo = "NUMPARCPG"
                no-lock no-error.
            if avail credscore
            then vnumparcpg = credscore.vl-ini.
            else vnumparcpg = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "numparcpg",
                           input recatu1).

            /* Valor das Parcelas Pagas */
            find first credscore where credscore.campo = "VALPARCPG"
                no-lock no-error.
            if avail credscore
            then vvalparcpg = credscore.vl-ini.
            else vvalparcpg = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "valparcpg",
                           input recatu1).

            /* Limite Maximo */
            find first credscore where credscore.campo = "LIMMAXIMO"
                no-lock no-error.
            if avail credscore
            then vlimmaximo = credscore.vl-ini.
            else vlimmaximo = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "limmaximo",
                           input recatu1).

            /* Limite Maximo - Credscore */
            find first credscore where credscore.campo = "LIMMAXIMOC"
                no-lock no-error.
            if avail credscore
            then vlimmaximoc = credscore.vl-ini.
            else vlimmaximoc = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "limmaximoc",
                           input recatu1).                           
                           
            /* Limite de Media de Atraso */
            find first credscore where credscore.campo = "LIMMATRASO"
                no-lock no-error.
            if avail credscore
            then vlimmatraso = credscore.vl-ini.
            else vlimmatraso = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "limmatraso",
                           input recatu1).
                           
            /* Percentual para Calculo de Limite */                           
            find first credscore where credscore.campo = "PERCRENDA"
                no-lock no-error.
            if avail credscore
            then vpercrenda = credscore.vl-ini.
            else vpercrenda = 0.
            recatu1 = recid(credscore).
            run p-compval (input vtipoalt,
                           input "percrenda",
                           input recatu1).
 
            /* Dependentes */
            qtdpos = 0.
            for each credscore where credscore.campo = "depen" no-lock
                by credscore.vl-ini.
                qtdpos = qtdpos + 1.
                depen-tipo[qtdpos]     = credscore.tipo-vl.
                depen-qtd[qtdpos]      = credscore.vl-ini.
                depen-valor[qtdpos]    = credscore.valor.
                depen-consparc[qtdpos] = credscore.consnumparc.
                depen-operacao[qtdpos] = credscore.operacao.
            end.
        
            /* Possui Fone Convencional */
            find first credscore where credscore.campo = "foneconv"
                no-lock no-error.
            if avail credscore
            then vfoneconv = credscore.vl-log.
            else vfoneconv = no.

            /* Possui Fone Convencional */
            find first credscore where credscore.campo = "descalug"
                no-lock no-error.
            if avail credscore
            then vdescalug = credscore.vl-log.
            else vdescalug = no.
 
            disp /***
            "Quantidade de Parcelas Pagas a Considerar" ***/
                vnumparcpg
                vvalparcpg
                vlimmaximo
                vlimmaximoc
                vlimmatraso
                vpercrenda colon 40
                /***
                skip(1)
                "Dependentes -> Qtde   Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
                skip
                ***/
                depen-qtd[1]                     at 10
                depen-tipo[1]                    at 26 format "Perc/Val"
                depen-operacao[1]                at 36 format "Dim/Som"
                depen-valor[1]                   
                depen-consparc[1]                at 60 format "Sim/Nao"
                depen-qtd[2]                     at 10
                depen-tipo[2]                    at 26 format "Perc/Val"
                depen-operacao[2]                at 36 format "Dim/Som"
                depen-valor[2]                   
                depen-consparc[2]                at 60 format "Sim/Nao"
                depen-qtd[3]                     at 10
                depen-tipo[3]                    at 26 format "Perc/Val"
                depen-operacao[3]                at 36 format "Dim/Som"
                depen-valor[3]                   
                depen-consparc[3]                at 60 format "Sim/Nao"
                depen-qtd[4]                     at 10
                depen-tipo[4]                    at 26 format "Perc/Val"
                depen-operacao[4]                at 36 format "Dim/Som"
                depen-valor[4]                   
                depen-consparc[4]                at 60 format "Sim/Nao"
                depen-qtd[5]                     at 10
                depen-tipo[5]                    at 26 format "Perc/Val"
                depen-operacao[5]                at 36 format "Dim/Som"
                depen-valor[5]                   
                depen-consparc[5]                at 60 format "Sim/Nao"
                depen-qtd[6]                     at 10
                depen-tipo[6]                    at 26 format "Perc/Val"
                depen-operacao[6]                at 36 format "Dim/Som"
                depen-valor[6]                   
                depen-consparc[6]                at 60 format "Sim/Nao"
                depen-qtd[7]                     at 10
                depen-tipo[7]                    at 26 format "Perc/Val"
                depen-operacao[7]                at 36 format "Dim/Som"
                depen-valor[7]                   
                depen-consparc[7]                at 60 format "Sim/Nao"
                skip
/***                "Fone Convencional" ***/
                vfoneconv at 20
                help "Possui Telefone Convencional ?" 
                fone-tipo                      format "Perc/Val"   at 26
                fone-operacao                  format "Dim/Som"    at 36
                fone-valor
                fone-consparc                  format "Sim/Nao"    at 60
                skip
/***                "Desc. Vl Aluguel"***/
                vdescalug at 20
                help "Desconta Valor do Aluguel ?"
                vlalug-tipo                      format "Perc/Val"   at 26
                vlalug-operacao                  format "Dim/Som"    at 36
                vlalug-valor
                vlalug-consparc                  format "Sim/Nao"    at 60                         with frame fbasicas no-label 
                    row 9 size 80 by 14 overlay no-box.
         
        end.
    end.
    if esqcom1[esqpos1]  = "Pessoais"
    then do:
        run pess (if keyfunction(lastkey) = "Return"
                  then "Manutencao"
                  else "Consulta").
    end.
    if esqcom1[esqpos1]  = "Profissionais"
    then do:
       run prof (if keyfunction(lastkey) = "Return"
                     then "Manutencao"
                     else "Consulta").
    end.
    if esqcom1[esqpos1]  = "Inf. Adicionais"
    then do:
       hide frame fbasicas.
       hide frame fpessoais.
       hide frame fprof.
       hide frame frefpess.
       run adic(if keyfunction(lastkey) = "Return"
                then "Manutencao"
                else "Consulta").
    end.
    if esqcom1[esqpos1]  = "Ref. Pessoais"  
    then do:
       run refpess (if keyfunction(lastkey) = "Return"
                    then "Manutencao"
                    else "Consulta").
    end.
    if esqcom1[esqpos1]  = "Ref. Comer."
    then do:
       hide frame fbasicas.
       hide frame fpessoais.
       hide frame fprof.
       hide frame frefpess.
       run refcomer (if keyfunction(lastkey) = "Return"
                     then "Manutencao"
                     else "Consulta").
    end.
    if esqcom1[esqpos1]  = "Dados 1"  
    then do:
       run dados1 (if keyfunction(lastkey) = "Return"
                    then "Manutencao"
                    else "Consulta").
    end.    
    if esqcom1[esqpos1] = "Dados 2"
    then do:
        run dados2(if keyfunction(lastkey) = "Return"
                    then "Manutencao"  
                    else "Consulta").
    end.
    if esqcom1[esqpos1] = "Dados 3"
    then do:
        run dados3(if keyfunction(lastkey) = "Return"
                    then "Manutencao"  
                    else "Consulta").
    end.    
    if esqcom1[esqpos1] = "Dados 4"
    then do:
        run dados4(if keyfunction(lastkey) = "Return"
                    then "Manutencao"  
                    else "Consulta").
    end.    
    if esqcom1[esqpos1] = "Dados 5"
    then do:
        run dados5(if keyfunction(lastkey) = "Return"
                    then "Manutencao"  
                    else "Consulta").    
    end.
 
end.    
               
hide frame f-cli no-pause.

procedure pess.         /*  informacoes pessoais  */
def input parameter par-acao as char.

     do:
     
        /* Possui E-mail */
        find first credscore where credscore.campo = "email" 
            no-lock no-error.
        if avail credscore
        then assign vemail = credscore.vl-log
                    email-tipo = credscore.tipo
                    email-operacao = credscore.operacao
                    email-valor = credscore.valor
                    email-consparc = credscore.consnumparc.
        else vemail = no.
     
                /* Sexo */
                qtdpos = 0.
                for each credscore where credscore.campo = "sexo" no-lock.
                    qtdpos = qtdpos + 1.
                    sexo-tipo[qtdpos]     = credscore.tipo-vl.
                    sexo-desc[qtdpos]     = credscore.vl-char.
                    sexo-valor[qtdpos]    = credscore.valor.
                    sexo-consparc[qtdpos] = credscore.consnumparc.
                    sexo-operacao[qtdpos] = credscore.operacao.
                end.

                /* Estado Civil */
                qtdpos = 0.
                for each credscore where credscore.campo = "estcivil" no-lock
                    by credscore.vl-ini.
                    qtdpos = qtdpos + 1.
                    ecivil-tipo[qtdpos]     = credscore.tipo-vl.
                    ecivil-desc[qtdpos]     = credscore.vl-char.
                    ecivil-valor[qtdpos]    = credscore.valor.
                    ecivil-consparc[qtdpos] = credscore.consnumparc.
                    ecivil-operacao[qtdpos] = credscore.operacao.
                end.

                disp 
      "Sexo -> Sexo           Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
                    skip
                    sexo-desc[1]                    at 10 format "x(9)"
                    sexo-tipo[1]                    at 26 format "Perc/Val"
                    sexo-operacao[1]                at 36 format "Dim/Som"
                    sexo-valor[1]                   
                    sexo-consparc[1]                at 60 format "Sim/Nao"
                    sexo-desc[2]                    at 10 format "x(9)"
                    sexo-tipo[2]                    at 26 format "Perc/Val"
                    sexo-operacao[2]                at 36 format "Dim/Som"
                    sexo-valor[2]                   
                    sexo-consparc[2]                at 60 format "Sim/Nao"
                    skip(1)
   "      Estado Civil     Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
                    skip
                    ecivil-desc[1]                    at 10 format "x(9)"
                    ecivil-tipo[1]                    at 26 format "Perc/Val"
                    ecivil-operacao[1]                at 36 format "Dim/Som"
                    ecivil-valor[1]                   
                    ecivil-consparc[1]                at 60 format "Sim/Nao"
                    ecivil-desc[2]                     at 10 format "x(9)"
                    ecivil-tipo[2]                    at 26 format "Perc/Val"
                    ecivil-operacao[2]                at 36 format "Dim/Som"
                    ecivil-valor[2]                   
                    ecivil-consparc[2]                at 60 format "Sim/Nao"
                    ecivil-desc[3]                     at 10 format "x(9)"
                    ecivil-tipo[3]                    at 26 format "Perc/Val"
                    ecivil-operacao[3]                at 36 format "Dim/Som"
                    ecivil-valor[3]                   
                    ecivil-consparc[3]                at 60 format "Sim/Nao"
                    ecivil-desc[4]                     at 10 format "x(9)"
                    ecivil-tipo[4]                    at 26 format "Perc/Val"
                    ecivil-operacao[4]                at 36 format "Dim/Som"
                    ecivil-valor[4]                   
                    ecivil-consparc[4]                at 60 format "Sim/Nao"
                    ecivil-desc[5]                     at 10 format "x(9)"
                    ecivil-tipo[5]                    at 26 format "Perc/Val"
                    ecivil-operacao[5]                at 36 format "Dim/Som"
                    ecivil-valor[5]                   
                    ecivil-consparc[5]                at 60 format "Sim/Nao"
                    ecivil-desc[6]                     at 10 format "x(9)"
                    ecivil-tipo[6]                    at 26 format "Perc/Val"
                    ecivil-operacao[6]                at 36 format "Dim/Som"
                    ecivil-valor[6]                  
                    ecivil-consparc[6]                at 60 format "Sim/Nao"   
                     skip(1)
                    "Possui E-mail" 
                     vemail at 20
                     help "Possui E-mail ?" 
                     email-tipo                      format "Perc/Val"   at 26
                     email-operacao                  format "Dim/Som"    at 36
                     email-valor
                     email-consparc                  format "Sim/Nao"    at 60
                    skip(1)
                    with frame fpessoais no-label 
                        row 9 size 80 by 14 overlay no-box.

     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame fpess:
    
    /* Sexo */
    do qtdpos = 1 to 2:
        find first credscore where credscore.campo = "sexo"
                               and credscore.vl-char = sexo-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        sexo-recid[qtdpos] = recatu1.
                    
        update sexo-desc[qtdpos]            at 10
               sexo-tipo[qtdpos]            at 26 format "Perc/Val"
               sexo-operacao[qtdpos]        at 36 format "Dim/Som"
               sexo-valor[qtdpos]           
               sexo-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fpessoais no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = sexo-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "sexo".
            credscore.desc-campo    = "Sexo".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".

        credscore.tipo-vl       = sexo-tipo[qtdpos].
        credscore.vl-char       = sexo-desc[qtdpos].
        credscore.valor         = sexo-valor[qtdpos].
        credscore.consnumparc   = sexo-consparc[qtdpos].
        credscore.operacao      = sexo-operacao[qtdpos].

        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "sexo",
                       input recatu1).
    end. /* do qtdpos */                 


    /* Estado Civil */
    do qtdpos = 1 to 6:
        find first credscore where credscore.campo = "estcivil"
                               and credscore.vl-char = ecivil-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        ecivil-recid[qtdpos] = recatu1.
                    
        update ecivil-desc[qtdpos]            at 10
               ecivil-tipo[qtdpos]            at 26 format "Perc/Val"
               ecivil-operacao[qtdpos]        at 36 format "Dim/Som"
               ecivil-valor[qtdpos]           
               ecivil-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fpessoais no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = ecivil-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "estcivil".
            credscore.desc-campo    = "Estado Civil".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = ecivil-tipo[qtdpos].
        credscore.vl-char       = ecivil-desc[qtdpos].
        credscore.valor         = ecivil-valor[qtdpos].
        credscore.consnumparc   = ecivil-consparc[qtdpos].
        credscore.operacao      = ecivil-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "estcivil",
                       input recatu1).
                       
    end. /* do qtdpos */

        find first credscore where credscore.campo = "email"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                remail = recatu1.
                
                update skip
                    vemail at 20
                    help "Possui E-mail ?" 
                    email-tipo                      format "Perc/Val" at 26
                    email-operacao                  format "Dim/Som"  at 36
                    email-valor
                    email-consparc                  format "Sim/Nao"  at 60
                    skip
                    with frame fpessoais no-label 
                        row 9 size 80 by 14 overlay no-box.

                /* Possui E-mail */
                find first credscore where credscore.campo = "email"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "email".
                    credscore.desc-campo = "Possui E-mail".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-log        = vemail.
                credscore.tipo-vl       = email-tipo.
                credscore.valor         = email-valor.
                credscore.consnumparc   = email-consparc.
                credscore.operacao      = email-operacao.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "email",
                               input recatu1).                       
                       

     end.

end procedure.

procedure resid.   /*    informacoes basicas */

def input parameter par-acao as char.

case par-acao:
when "CONSULTA"
    then do:
    end.
when "MANUTENCAO"
    then do on error undo with frame fresid.
        run altera-clifor.
    end.
end case.

end procedure.

procedure pessoal.    /*   informacoes pessoais */
def input parameter par-acao as char.
    do:
    end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame fpessoal.
    end.

end procedure.

procedure prof.         /*  informacoes profissionais */
    def input parameter par-acao as char.

     do:
        /* Valor do Salario Minimo */
        find first credscore where credscore.campo = "salariominimo"
            no-lock no-error.
        if avail credscore
        then vsalariominimo = credscore.vl-ini.
        else vsalariominimo = 0.
        
        /* Renda em Salarios Minimos */
        find first credscore where credscore.campo = "rensalmin"
            no-lock no-error.
        if avail credscore
        then do:
            renda-tipo     = credscore.tipo-vl.
            renda-qtd      = credscore.vl-ini.
            renda-valor    = credscore.valor.
            renda-consparc = credscore.consnumparc.
            renda-operacao = credscore.operacao.
        end.
        
        disp "Valor do Salario Minimo" 
             vsalariominimo colon 40
             skip(1)
    "Renda em Sal.Minimos  Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
             renda-qtd                     at 1
             renda-tipo                    at 26 format "Perc/Val"
             renda-operacao                at 36 format "Dim/Som"
             renda-valor                   
             renda-consparc                at 60 format "Sim/Nao"
             skip(1)
           with frame fprof no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame fprof:
    

        pause 0.

        /* Valor do Salario Minimo */
        find first credscore where credscore.campo = "salariominimo"
            no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        rsalariominimo = recatu1.
                
        update vsalariominimo colon 40
            with frame fprof no-label 
                row 9 size 80 by 14 overlay no-box.
                        
        find first credscore where credscore.campo = "salariominimo"
            exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo = "salariominimo".
            credscore.desc-campo = "Valor do Salario Minimo".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        credscore.vl-ini = vsalariominimo.
                
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "salariominimo",
                       input recatu1).

    
        /* Renda em Salarios Minimos */
        find first credscore where credscore.campo  = "rensalmin"
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        renda-recid = recatu1.
                    
        update renda-qtd             at 10
               renda-tipo            at 26 format "Perc/Val"
               renda-operacao        at 36 format "Dim/Som"
               renda-valor           
               renda-consparc        at 60 format "Sim/Nao"
            with frame fprof no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = renda-recid
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "rensalmin".
            credscore.desc-campo    = "Renda em Salarios Minimos".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = renda-tipo.
        credscore.vl-ini        = renda-qtd.
        credscore.valor         = renda-valor.
        credscore.consnumparc   = renda-consparc.
        credscore.operacao      = renda-operacao.
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "rensalmin",
                       input recatu1).

    end.

end procedure.

procedure conjuge.          /*  informacoes conjuge */
def input parameter par-acao as char.
    do:
    
    end.
if par-acao =  "MANUTENCAO"
    then do on error undo:
    end.

end procedure.


procedure pessoal-referencia.          /*  informacoes conjuge */
def input parameter par-acao as char.

    do:
    end.
if par-acao = "MANUTENCAO"
    then do on error undo:
    end.
end procedure.

procedure pessoal-patrimonio.          /*  informacoes conjuge */
def input parameter par-acao as char.
                     
case par-acao:
when "CONSULTA"
    then do:
    end.
when "MANUTENCAO"
    then do on error undo:
    end.
end case.
end procedure.

procedure refcomer.      /*    referencias  comerciais e bancarias */
    def input parameter par-acao as char.

    do:
        /* Quantidade de Referencias */
        find first credscore where credscore.campo = "qtdreferc"
            no-lock no-error.
        if avail credscore
        then do:
            referc-tipo     = credscore.tipo-vl.
            referc-qtd      = credscore.vl-ini.
            referc-valor    = credscore.valor.
            referc-consparc = credscore.consnumparc.
            referc-operacao = credscore.operacao.
        end.
         
        /* Nao preenchimento dos campos da Referencia */
        find first credscore where credscore.campo = "refernaopreenchc"
            no-lock no-error.
        if avail credscore
        then do:
            refnpc-tipo     = credscore.tipo-vl.
            refnpc-log      = credscore.vl-log.
            refnpc-valor    = credscore.valor.
            refnpc-consparc = credscore.consnumparc.
            refnpc-operacao = credscore.operacao.
        end.
              
        disp
    "Qtde. Ref. Considerar  Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
             referc-qtd                     at 1
             referc-tipo                    at 26 format "Perc/Val"
             referc-operacao                at 36 format "Dim/Som"
             referc-valor                   
             referc-consparc                at 60 format "Sim/Nao"
             skip
    "Campos Preenchidos"             
             refnpc-log                     at 1  format "Sim/Nao"
             refnpc-tipo                    at 26 format "Perc/Val"
             refnpc-operacao                at 36 format "Dim/Som"
             refnpc-valor                   
             refnpc-consparc                at 60 format "Sim/Nao"
             skip 
           with frame frefcomer no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame frefcomer:
        pause 0.
        
        /* Quantidade de Referencias */
        find first credscore where credscore.campo  = "qtdreferc"
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
   
        rreferc = recatu1.
                    
        update referc-qtd             at 10
               referc-tipo            at 26 format "Perc/Val"
               referc-operacao        at 36 format "Dim/Som"
               referc-valor           
               referc-consparc        at 60 format "Sim/Nao"
            with frame frefcomer no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = rreferc
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "qtdreferc".
            credscore.desc-campo    = "Quantidade de Referencias Comerciais a Considerar".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = referc-tipo.
        credscore.vl-ini        = referc-qtd.
        credscore.valor         = referc-valor.
        credscore.consnumparc   = referc-consparc.
        credscore.operacao      = referc-operacao.
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "qtdreferc",
                       input recatu1).
                       
        /* Nao Preenchimento dos Campos da Referencia */
        find first credscore where credscore.campo  = "refernaopreenchc"
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        rrefnpc = recatu1.
                    
        update refnpc-log             at 10
               refnpc-tipo            at 26 format "Perc/Val"
               refnpc-operacao        at 36 format "Dim/Som"
               refnpc-valor           
               refnpc-consparc        at 60 format "Sim/Nao"
            with frame frefcomer no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = rrefnpc
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "refernaopreenchc".
         credscore.desc-campo    = "Nao Preenchimento dos Campos da Referencia Comercial ".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = refnpc-tipo.
        credscore.vl-log        = refnpc-log.
        credscore.valor         = refnpc-valor.
        credscore.consnumparc   = refnpc-consparc.
        credscore.operacao      = refnpc-operacao.
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "refernaopreenchc",
                       input recatu1).
                       
    end.

end procedure.

procedure refpess.      /*    Referencias Pessoais */
    def input parameter par-acao as char.

    do:
        /* Quantidade de Referencias */
        find first credscore where credscore.campo = "qtdrefer"
            no-lock no-error.
        if avail credscore
        then do:
            refer-tipo     = credscore.tipo-vl.
            refer-qtd      = credscore.vl-ini.
            refer-valor    = credscore.valor.
            refer-consparc = credscore.consnumparc.
            refer-operacao = credscore.operacao.
        end.
         
        /* Nao preenchimento dos campos da Referencia */
        find first credscore where credscore.campo = "refernaopreench"
            no-lock no-error.
        if avail credscore
        then do:
            refnp-tipo     = credscore.tipo-vl.
            refnp-log      = credscore.vl-log.
            refnp-valor    = credscore.valor.
            refnp-consparc = credscore.consnumparc.
            refnp-operacao = credscore.operacao.
        end.
              
        disp
    "Qtde. Ref. Considerar  Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
             refer-qtd                     at 1
             refer-tipo                    at 26 format "Perc/Val"
             refer-operacao                at 36 format "Dim/Som"
             refer-valor                   
             refer-consparc                at 60 format "Sim/Nao"
             skip
    "Campos Preenchidos"             
             refnp-log                     at 1  format "Sim/Nao"
             refnp-tipo                    at 26 format "Perc/Val"
             refnp-operacao                at 36 format "Dim/Som"
             refnp-valor                   
             refnp-consparc                at 60 format "Sim/Nao"
             skip
           with frame frefpess no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame frefpess:
        pause 0.
        
        /* Quantidade de Referencias */
        find first credscore where credscore.campo  = "qtdrefer"
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
   
        rrefer = recatu1.
                    
        update refer-qtd             at 10
               refer-tipo            at 26 format "Perc/Val"
               refer-operacao        at 36 format "Dim/Som"
               refer-valor           
               refer-consparc        at 60 format "Sim/Nao"
            with frame frefpess no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = rrefer
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "qtdrefer".
            credscore.desc-campo    = "Quantidade de Referencias a Considerar".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = refer-tipo.
        credscore.vl-ini        = refer-qtd.
        credscore.valor         = refer-valor.
        credscore.consnumparc   = refer-consparc.
        credscore.operacao      = refer-operacao.
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "qtdrefer",
                       input recatu1).
                       
        /* Nao Preenchimento dos Campos da Referencia */
        find first credscore where credscore.campo  = "refernaopreench"
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        rrefnp = recatu1.
                    
        update refnp-log             at 10
               refnp-tipo            at 26 format "Perc/Val"
               refnp-operacao        at 36 format "Dim/Som"
               refnp-valor           
               refnp-consparc        at 60 format "Sim/Nao"
            with frame frefpess no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = rrefnp
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "refernaopreench".
         credscore.desc-campo    = "Nao Preenchimento dos Campos da Referencia".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = refnp-tipo.
        credscore.vl-log        = refnp-log.
        credscore.valor         = refnp-valor.
        credscore.consnumparc   = refnp-consparc.
        credscore.operacao      = refnp-operacao.
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "refernaopreench",
                       input recatu1).
                       
    end.

end procedure.


procedure adic.     /*  informacoes adicionais */
def input parameter par-acao as char.
case par-acao:
when "CONSULTA"
    then do:

        /* Plano de Saude */
        find first credscore where credscore.campo = "psaude" 
            no-lock no-error.
        if avail credscore
        then assign vpsaude = credscore.vl-log
                    psaude-tipo = credscore.tipo
                    psaude-operacao = credscore.operacao
                    psaude-valor = credscore.valor
                    psaude-consparc = credscore.consnumparc.
        else vpsaude = no.
        
        qtdpos = 0.
        for each credscore where credscore.campo = "idade" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            idade-tipo[qtdpos]     = credscore.tipo-vl.
            idade-ini[qtdpos]      = credscore.vl-ini.
            idade-fin[qtdpos]      = credscore.vl-fin.
            idade-valor[qtdpos]    = credscore.valor.
            idade-consparc[qtdpos] = credscore.consnumparc.
            idade-operacao[qtdpos] = credscore.operacao.
            idade-obs[qtdpos]      = credscore.observacoes.
        end.    

        disp
        skip(1)
        /***
    "Planos de Saude" 
    ***/
     vpsaude at 20
     help "Possui Planos de Saude ?" 
     psaude-tipo                      format "Perc/Val"   at 26
     psaude-operacao                  format "Dim/Som"    at 36
     psaude-valor
     psaude-consparc                  format "Sim/Nao"    at 60
     skip
             /*
        "   Idade   Perc/Val    Dim/Som Valor   Cons.Num.Parc.Pg"*/
/*idade-obs[1]  format "x(18)"*/
        idade-ini[1] format "99"
        idade-fin[1] format "99"
        idade-tipo[1]   at  20 format "Perc/Val"
        idade-operacao[1]   at  31 format "Dim/Som"
        idade-valor[1]
        idade-consparc[1]   at  54 format "Sim/Nao"
        skip    
        /*   idade-obs[2]    format "x(18)"*/
        idade-ini[2] format "99"
        idade-fin[2] format "99"
        idade-tipo[2]   at  20 format "Perc/Val"
        idade-operacao[2]   at  31 format "Dim/Som"
        idade-valor[2]
        idade-consparc[2]   at  54 format "Sim/Nao" 
skip    
        /*  idade-obs[3]    format "x(18)"*/
        idade-ini[3] format "99"
        idade-fin[3] format "99"
        idade-tipo[3]   at  20 format "Perc/Val"
        idade-operacao[3]   at  31 format "Dim/Som"
        idade-valor[3]
        idade-consparc[3]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[4]    format "x(18)"*/
        idade-ini[4] format "99"
        idade-fin[4] format "99"
        idade-tipo[4]   at  20 format "Perc/Val"
        idade-operacao[4]   at  31 format "Dim/Som"
        idade-valor[4]
        idade-consparc[4]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[5]    format "x(18)"*/
        idade-ini[5] format "99"    
idade-fin[5] format "99"
        idade-tipo[5]   at  20 format "Perc/Val"
        idade-operacao[5]   at  31 format "Dim/Som"
        idade-valor[5]
        idade-consparc[5]   at  54 format "Sim/Nao"
        skip    
        /*  idade-obs[6]    format "x(18)"*/
        idade-ini[6] format "99"
        idade-fin[6] format "99"
        idade-tipo[6]   at  20 format "Perc/Val"
        idade-operacao[6]   at  31 format "Dim/Som"
        idade-valor[6]
        idade-consparc[6]   at  54 format "Sim/Nao"
        with frame fadic no-label
        row 9 size  80 by   14 overlay no-box.
        
    end.
when "MANUTENCAO"
    then do on error undo:
    
        find first credscore where credscore.campo = "psaude"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rpsaude = recatu1.
                
                update skip
                    vpsaude at 20
                    help "Possui Planos de Saude ?" 
                    psaude-tipo                      format "Perc/Val" at 26
                    psaude-operacao                  format "Dim/Som"  at 36
                    psaude-valor
                    psaude-consparc                  format "Sim/Nao"  at 60
                    skip
                    with frame fadic no-label 
                        row 9 size 80 by 14 overlay no-box.

                /* Possui Planos de Saude */
                find first credscore where credscore.campo = "psaude"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "psaude".
                    credscore.desc-campo = "Possui Planos de Saude".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-log        = vpsaude.
                credscore.tipo-vl       = psaude-tipo.
                credscore.valor         = psaude-valor.
                credscore.consnumparc   = psaude-consparc.
                credscore.operacao      = psaude-operacao.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "psaude",
                               input recatu1).    
    
/* Idade */
    do qtdpos = 1 to    6:
    find first credscore where credscore.campo = "idade"
    and credscore.vl-ini = idade-ini[qtdpos]
    and credscore.vl-fin = idade-fin[qtdpos]
    no-lock no-error.
    if avail credscore                      
    then do:
    recatu1 = recid(credscore).
    run p-guardaval (input "Alteracao").
    end.
    else do:
    recatu1 = ?.
    run p-guardaval (input "Inclusao").
    end.
    idade-recid[qtdpos] = recatu1.
update
    idade-ini[qtdpos]
    idade-fin[qtdpos]
    idade-tipo[qtdpos]  format "Perc/Val"
    idade-operacao[qtdpos]  format "Dim/Som"
    idade-valor[qtdpos]
    idade-consparc[qtdpos]  format "Sim/Nao"
    with frame fadic no-label
    row 9 size  80 by   14 overlay no-box.
    
    find first credscore
    where recid(credscore) = idade-recid[qtdpos]
    exclusive-lock no-error.
if not avail credscore
    then do:
    create credscore.
    credscore.campo = "idade".
    credscore.desc-campo    = "Idade".
    vtipoalt = "Inclusao".
    end.
    else vtipoalt = "Alteracao".
    credscore.vl-ini    = idade-ini[qtdpos].
    credscore.vl-fin    = idade-fin[qtdpos].
    credscore.tipo-vl   = idade-tipo[qtdpos].
    credscore.vl-ini    = idade-ini[qtdpos].
    credscore.vl-fin    = idade-fin[qtdpos].
    credscore.valor = idade-valor[qtdpos].
    credscore.consnumparc   = idade-consparc[qtdpos].
    credscore.operacao  = idade-operacao[qtdpos].
    credscore.observacoes   = idade-obs[qtdpos].
    
    recatu1 = recid(credscore). 
run p-compval (input vtipoalt,
    input "idade",
    input recatu1).
    end. /* do qtdpos */    
    end.
end case.

end procedure.


procedure altera-clifor.   /*   alteracao e criacao  de cpfis */
do on error undo.
end.

end procedure.


procedure credito.
end procedure.

procedure contatos.   /* tabela agforcon */
end procedure.

procedure enderecos.   /* tabela cliforend */
end procedure.

procedure cobranca.
def input parameter par-acao as char.

case par-acao:
when "CONSULTA"
    then do:
    end.
when "MANUTENCAO"
    then do on error undo:
    end.
end case.

end procedure.

procedure mostra.
        view frame f-com1.
        view frame f-com2.
end procedure.

procedure p-compval.

def input parameter p-tipoalt as char.
def input parameter p-param   as char.
def input parameter p-recid   as recid.

if p-recid <> ?
then do:
    find first credscore where recid(credscore) = p-recid no-lock. 
    
    dep-campo           = credscore.campo.
    dep-desc-campo      = credscore.desc-campo.
    dep-vl-ini          = credscore.vl-ini.
    dep-vl-fin          = credscore.vl-fin.
    dep-vl-char         = credscore.vl-char.
    dep-vl-log          = credscore.vl-log.
    dep-tipo-vl         = credscore.tipo-vl.
    dep-operacao        = credscore.operacao.
    dep-valor           = credscore.valor.
    dep-consnumparc     = credscore.consnumparc.
    dep-observacoes     = credscore.observacoes.
end.
else do:
    dep-campo           = "".
    dep-desc-campo      = "".
    dep-vl-ini          = 0.
    dep-vl-fin          = 0.
    dep-vl-char         = "".
    dep-vl-log          = ?.
    dep-tipo-vl         = ?.
    dep-operacao        = ?.
    dep-valor           = 0.
    dep-consnumparc     = ?.
    dep-observacoes     = "".
end.

/***
if dep-campo <> ant-campo
then run p-gravalog (input p-param,
                     input "campo",
                     input ant-campo,
                     input dep-campo,
                     input p-tipoalt,
                     input p-recid). 

if dep-desc-campo <> ant-desc-campo
then run p-gravalog (input p-param,
                     input "desc-campo",
                     input ant-desc-campo,
                     input dep-desc-campo,
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-ini <> ant-vl-ini
then run p-gravalog (input p-param,
                     input "vl-ini" ,
                     input string(ant-vl-ini),
                     input string(dep-vl-ini),
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-fin <> ant-vl-fin
then run p-gravalog (input p-param,
                     input "vl-fin" ,
                     input string(ant-vl-fin),
                     input string(dep-vl-fin),
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-char <> ant-vl-char
then run p-gravalog (input p-param,
                     input "vl-char" ,
                     input ant-vl-char,
                     input dep-vl-char,
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-log <> ant-vl-log
then run p-gravalog (input p-param,
                     input "vl-log" ,
                     input string(ant-vl-log),
                     input string(dep-vl-log),
                     input p-tipoalt,
                     input p-recid). 

if dep-tipo-vl <> ant-tipo-vl
then run p-gravalog (input p-param,
                     input "tipo-vl" ,
                     input string(ant-tipo-vl,"Perc/Val"),
                     input string(dep-tipo-vl,"Perc/Val"),
                     input p-tipoalt,
                     input p-recid). 

if dep-operacao <> ant-operacao
then run p-gravalog (input p-param,
                     input "operacao" ,
                     input string(ant-operacao,"Dim/Som"),
                     input string(dep-operacao,"Dim/Som"),
                     input p-tipoalt,
                     input p-recid). 

if dep-valor <> ant-valor
then run p-gravalog (input p-param,
                     input "valor" ,
                     input string(ant-valor),
                     input string(dep-valor),
                     input p-tipoalt,
                     input p-recid). 

if dep-consnumparc <> ant-consnumparc
then run p-gravalog (input p-param,
                     input "consnumparc" ,
                     input string(ant-consnumparc,"Sim/Nao"),
                     input string(dep-consnumparc,"Sim/Nao"),
                     input p-tipoalt,
                     input p-recid). 

if dep-observacoes <> ant-observacoes
then run p-gravalog (input p-param,
                     input "observacoes" ,
                     input ant-observacoes,
                     input dep-observacoes,
                     input p-tipoalt,
                     input p-recid). 
***/

if dep-campo <> ant-campo or
   dep-vl-ini <> ant-vl-ini or
   dep-vl-fin <> ant-vl-fin or
   dep-vl-char <> ant-vl-char or
   dep-vl-log <> ant-vl-log or
   dep-tipo-vl <> ant-tipo-vl or
   dep-operacao <> ant-operacao or
   dep-valor <> ant-valor or
   dep-consnumparc <> ant-consnumparc
then do:   

    find first credscorelog where credscorelog.funcod     = sfuncod
                              and credscorelog.datalog    = today
                              and credscorelog.hora       = time
                                  exclusive-lock no-error.
    if not avail credscorelog
    then do:
        create credscorelog.
        credscorelog.funcod         = sfuncod.
        credscorelog.datalog        = today.
        credscorelog.hora           = time.
    end.

    credscorelog.tipoalt        = p-tipoalt.
    credscorelog.campo          = ant-campo.
    credscorelog.desc-campo     = ant-desc-campo.
    credscorelog.vl-ini         = ant-vl-ini.
    credscorelog.vl-fin         = ant-vl-fin.
    credscorelog.vl-char        = ant-vl-char.
    credscorelog.vl-log         = ant-vl-log.
    credscorelog.tipo-vl        = ant-vl-log.
    credscorelog.operacao       = ant-operacao.
    credscorelog.valor          = ant-valor.
    credscorelog.consnumparc    = ant-consnumparc.
    credscorelog.observacoes    = ant-observacoes.

end.

end procedure.

/***
procedure p-gravalog.

def input parameter p-param   as char.
def input parameter p-campo   as char.
def input parameter p-antes   as char.
def input parameter p-depois  as char.
def input parameter p-tipoalt as char.
def input parameter p-recid   as recid.

find first credscorelog where credscorelog.funcod     = sfuncod
                          and credscorelog.parametro  = p-param
                          and credscorelog.campo      = p-campo
                          and credscorelog.datalog    = today
                          and credscorelog.hora       = time
                              exclusive-lock no-error.

if not avail credscorelog
then do:
    create credscorelog.
    credscorelog.funcod     = sfuncod.
    credscorelog.datalog    = today.
    credscorelog.hora       = time.
    credscorelog.parametro  = p-param.
    credscorelog.campo      = p-campo.
end.

credscorelog.tipoalt        = p-tipoalt.
credscorelog.antes          = p-antes.
credscorelog.depois         = p-depois.
credscorelog.recid-alt      = p-recid.
    
end procedure.
***/

procedure p-guardaval.

def input parameter p-tipoalt as char.

if p-tipoalt = "Inclusao"
then do:
    ant-campo           = "".
    ant-desc-campo      = "".
    ant-vl-ini          = 0.
    ant-vl-fin          = 0.
    ant-vl-char         = "".
    ant-vl-log          = ?.
    ant-tipo-vl         = ?.
    ant-operacao        = ?.
    ant-valor           = 0.
    ant-consnumparc     = ?.
    ant-observacoes     = "".
end.
else do:

    find credscore where recid(credscore) = recatu1 no-lock.
    
    ant-campo           = credscore.campo.
    ant-desc-campo      = credscore.desc-campo.
    ant-vl-ini          = credscore.vl-ini.
    ant-vl-fin          = credscore.vl-fin.
    ant-vl-char         = credscore.vl-char.
    ant-vl-log          = credscore.vl-log.
    ant-tipo-vl         = credscore.tipo-vl.
    ant-operacao        = credscore.operacao.
    ant-valor           = credscore.valor.
    ant-consnumparc     = credscore.consnumparc.
    ant-observacoes     = credscore.observacoes.
end.
end.

procedure dados1.      /*    Referencias Pessoais */
    def input parameter par-acao as char.

    do:
         
        /* Estado Civil */
        qtdpos = 0.
        for each credscore where credscore.campo = "grinstru" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            grinstru-tipo[qtdpos]     = credscore.tipo-vl.
            grinstru-desc[qtdpos]     = credscore.vl-char.
            grinstru-valor[qtdpos]    = credscore.valor.
            grinstru-consparc[qtdpos] = credscore.consnumparc.
            grinstru-operacao[qtdpos] = credscore.operacao.
        end.

        /* Seguros */
        qtdpos = 0.
        for each credscore where credscore.campo = "seguros" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            seguros-tipo[qtdpos]     = credscore.tipo-vl.
            seguros-desc[qtdpos]     = credscore.vl-char.
            seguros-valor[qtdpos]    = credscore.valor.
            seguros-consparc[qtdpos] = credscore.consnumparc.
            seguros-operacao[qtdpos] = credscore.operacao.
        end.        

        disp 
            skip(1)    
   "  Grau de Instrucao    Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            grinstru-desc[1]                    format "x(20)"
            grinstru-tipo[1]                    at 26 format "Perc/Val"
            grinstru-operacao[1]                at 36 format "Dim/Som"
            grinstru-valor[1]                   
            grinstru-consparc[1]                at 60 format "Sim/Nao"
            skip
            grinstru-desc[2]                    format "x(20)"
            grinstru-tipo[2]                    at 26 format "Perc/Val"
            grinstru-operacao[2]                at 36 format "Dim/Som"
            grinstru-valor[2]                   
            grinstru-consparc[2]                at 60 format "Sim/Nao"
            skip
            grinstru-desc[3]                    format "x(20)"
            grinstru-tipo[3]                    at 26 format "Perc/Val"
            grinstru-operacao[3]                at 36 format "Dim/Som"
            grinstru-valor[3]                   
            grinstru-consparc[3]                at 60 format "Sim/Nao"
            skip
            grinstru-desc[4]                    format "x(20)"
            grinstru-tipo[4]                    at 26 format "Perc/Val"
            grinstru-operacao[4]                at 36 format "Dim/Som"
            grinstru-valor[4]                   
            grinstru-consparc[4]                at 60 format "Sim/Nao"
            skip
            grinstru-desc[5]                    format "x(20)"
            grinstru-tipo[5]                    at 26 format "Perc/Val"
            grinstru-operacao[5]                at 36 format "Dim/Som"
            grinstru-valor[5]                   
            grinstru-consparc[5]                at 60 format "Sim/Nao"                       skip(1)
   "    Seguros        Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            seguros-desc[1]                    at 5 format "x(15)"
            seguros-tipo[1]                    at 26 format "Perc/Val"
            seguros-operacao[1]                at 36 format "Dim/Som"
            seguros-valor[1]                   
            seguros-consparc[1]                at 60 format "Sim/Nao"
            seguros-desc[2]                     at 5 format "x(15)"
            seguros-tipo[2]                    at 26 format "Perc/Val"
            seguros-operacao[2]                at 36 format "Dim/Som"
            seguros-valor[2]                   
            seguros-consparc[2]                at 60 format "Sim/Nao"
            seguros-desc[3]                     at 5 format "x(15)"
            seguros-tipo[3]                    at 26 format "Perc/Val"
            seguros-operacao[3]                at 36 format "Dim/Som"
            seguros-valor[3]                   
            seguros-consparc[3]                at 60 format "Sim/Nao"
            seguros-desc[4]                     at 5 format "x(15)"
            seguros-tipo[4]                    at 26 format "Perc/Val"
            seguros-operacao[4]                at 36 format "Dim/Som"
            seguros-valor[4]                   
            seguros-consparc[4]                at 60 format "Sim/Nao"          
            seguros-desc[5]                     at 5 format "x(15)"
            seguros-tipo[5]                    at 26 format "Perc/Val"
            seguros-operacao[5]                at 36 format "Dim/Som"
            seguros-valor[5]                   
            seguros-consparc[5]                at 60 format "Sim/Nao"
            with frame fdados1 no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame frefpess:
        pause 0.
        
    /* Grau de Instrucao */
    do qtdpos = 1 to 5:
        find first credscore where credscore.campo = "grinstru"
                               and credscore.vl-char = grinstru-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        grinstru-recid[qtdpos] = recatu1.
                    
        update grinstru-desc[qtdpos]            
               grinstru-tipo[qtdpos]            at 26 format "Perc/Val"
               grinstru-operacao[qtdpos]        at 36 format "Dim/Som"
               grinstru-valor[qtdpos]           
               grinstru-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados1 no-label 
                row 9 size 80 by 14 overlay no-box.
                           
        find first credscore
            where recid(credscore) = grinstru-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "grinstru".
            credscore.desc-campo    = "Grau de Instrucao".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = grinstru-tipo[qtdpos].
        credscore.vl-char       = grinstru-desc[qtdpos].
        credscore.valor         = grinstru-valor[qtdpos].
        credscore.consnumparc   = grinstru-consparc[qtdpos].
        credscore.operacao      = grinstru-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "grinstru",
                       input recatu1).
    end. /* do qtdpos */
    
    /* Seguros */
    do qtdpos = 1 to 5:
        find first credscore where credscore.campo = "seguros"
                               and credscore.vl-char = seguros-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        seguros-recid[qtdpos] = recatu1.
                    
        update seguros-desc[qtdpos]            at 10
               seguros-tipo[qtdpos]            at 26 format "Perc/Val"
               seguros-operacao[qtdpos]        at 36 format "Dim/Som"
               seguros-valor[qtdpos]           
               seguros-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados1 no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = seguros-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "seguros".
            credscore.desc-campo    = "Seguros".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = seguros-tipo[qtdpos].
        credscore.vl-char       = seguros-desc[qtdpos].
        credscore.valor         = seguros-valor[qtdpos].
        credscore.consnumparc   = seguros-consparc[qtdpos].
        credscore.operacao      = seguros-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "seguros",
                       input recatu1).
    end. /* do qtdpos */    
    
                           
    end.

end procedure.

procedure dados2.      /*    Referencias Pessoais */
    def input parameter par-acao as char.

    do:
         
        /* Tempo de Residencia */
        qtdpos = 0.
        for each credscore where credscore.campo = "tempores" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            tempores-tipo[qtdpos]     = credscore.tipo-vl.
            tempores-ini[qtdpos]      = credscore.vl-ini.
            tempores-fin[qtdpos]      = credscore.vl-fin.  
            tempores-desc[qtdpos]     = credscore.vl-char.
            tempores-valor[qtdpos]    = credscore.valor.
            tempores-consparc[qtdpos] = credscore.consnumparc.
            tempores-operacao[qtdpos] = credscore.operacao.
        end.

        /* Tempo de Trabalho */
        qtdpos = 0.
        for each credscore where credscore.campo = "tempotrab" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            tempotrab-tipo[qtdpos]     = credscore.tipo-vl.
            tempotrab-ini[qtdpos]      = credscore.vl-ini.
            tempotrab-fin[qtdpos]      = credscore.vl-fin.            
            tempotrab-desc[qtdpos]     = credscore.vl-char.
            tempotrab-valor[qtdpos]    = credscore.valor.
            tempotrab-consparc[qtdpos] = credscore.consnumparc.
            tempotrab-operacao[qtdpos] = credscore.operacao.
        end.        

        disp 
            skip(1)    
   "  Tempo de Residencia    Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            /*
            tempores-desc[1]                    at 10 format "x(9)"
            */
            tempores-ini[1]
            tempores-fin[1]
            tempores-tipo[1]                    at 26 format "Perc/Val"
            tempores-operacao[1]                at 36 format "Dim/Som"
            tempores-valor[1]                   
            tempores-consparc[1]                at 60 format "Sim/Nao"
            skip
            /*
            tempores-desc[2]                     at 10 format "x(9)"
            */
            tempores-ini[2]
            tempores-fin[2]            
            tempores-tipo[2]                    at 26 format "Perc/Val"
            tempores-operacao[2]                at 36 format "Dim/Som"
            tempores-valor[2]                   
            tempores-consparc[2]                at 60 format "Sim/Nao"
            skip
            /*
            tempores-desc[3]                     at 10 format "x(9)"
            */
            tempores-ini[3]
            tempores-fin[3]            
            tempores-tipo[3]                    at 26 format "Perc/Val"
            tempores-operacao[3]                at 36 format "Dim/Som"
            tempores-valor[3]                   
            tempores-consparc[3]                at 60 format "Sim/Nao"
            skip(1)
   "  Tempo de Trabalho        Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            /*
            tempotrab-desc[1]                    at 10 format "x(9)"
            */
            tempotrab-ini[1]
            tempotrab-fin[1]            
            tempotrab-tipo[1]                    at 26 format "Perc/Val"
            tempotrab-operacao[1]                at 36 format "Dim/Som"
            tempotrab-valor[1]                   
            tempotrab-consparc[1]                at 60 format "Sim/Nao"
            skip
            /*
            tempotrab-desc[2]                     at 10 format "x(9)"
            */
            tempotrab-ini[2]
            tempotrab-fin[2]            
            tempotrab-tipo[2]                    at 26 format "Perc/Val"
            tempotrab-operacao[2]                at 36 format "Dim/Som"
            tempotrab-valor[2]                   
            tempotrab-consparc[2]                at 60 format "Sim/Nao"
            skip
            /*
            tempotrab-desc[3]                     at 10 format "x(9)"
            */
            tempotrab-ini[3]
            tempotrab-fin[3]            
            tempotrab-tipo[3]                    at 26 format "Perc/Val"
            tempotrab-operacao[3]                at 36 format "Dim/Som"
            tempotrab-valor[3]                   
            tempotrab-consparc[3]                at 60 format "Sim/Nao"
            with frame fdados2 no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame frefpess:
        pause 0.
        
    /* Tempo de Residencia */
    do qtdpos = 1 to 3:
        find first credscore where credscore.campo = "tempores"
                               and credscore.vl-ini = tempores-ini[qtdpos]
                               and credscore.vl-fin = tempores-fin[qtdpos]
                               /*and credscore.vl-char = tempores-desc[qtdpos]*/
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        tempores-recid[qtdpos] = recatu1.
                    
        update /*tempores-desc[qtdpos]            at 10*/
               tempores-ini[qtdpos]
               tempores-fin[qtdpos]
               tempores-tipo[qtdpos]            at 26 format "Perc/Val"
               tempores-operacao[qtdpos]        at 36 format "Dim/Som"
               tempores-valor[qtdpos]           
               tempores-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados2 no-label 
                row 9 size 80 by 14 overlay no-box.
                           
        find first credscore
            where recid(credscore) = tempores-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "tempores".
            credscore.desc-campo    = "Tempo de Residencia".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.vl-ini        = tempores-ini[qtdpos].
        credscore.vl-fin        = tempores-fin[qtdpos].
        credscore.tipo-vl       = tempores-tipo[qtdpos].
        credscore.vl-char       = tempores-desc[qtdpos].
        credscore.valor         = tempores-valor[qtdpos].
        credscore.consnumparc   = tempores-consparc[qtdpos].
        credscore.operacao      = tempores-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "tempores",
                       input recatu1).
    end. /* do qtdpos */
    
    /* Tempo de Trabalho */
    do qtdpos = 1 to 3:
        find first credscore where credscore.campo = "tempotrab"
                               and credscore.vl-ini = tempotrab-ini[qtdpos]
                               and credscore.vl-fin = tempotrab-fin[qtdpos]
                               /*and credscore.vl-char = tempotrab-desc[qtdpos]*/
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        tempotrab-recid[qtdpos] = recatu1.
                    
        update /*tempotrab-desc[qtdpos]            at 10*/
               tempotrab-ini[qtdpos]
               tempotrab-fin[qtdpos]        
               tempotrab-tipo[qtdpos]            at 26 format "Perc/Val"
               tempotrab-operacao[qtdpos]        at 36 format "Dim/Som"
               tempotrab-valor[qtdpos]           
               tempotrab-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados2 no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = tempotrab-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "tempotrab".
            credscore.desc-campo    = "Tempo de Trabalho".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.vl-ini        = tempotrab-ini[qtdpos].
        credscore.vl-fin        = tempotrab-fin[qtdpos].
        credscore.tipo-vl       = tempotrab-tipo[qtdpos].
        credscore.vl-char       = tempotrab-desc[qtdpos].
        credscore.valor         = tempotrab-valor[qtdpos].
        credscore.consnumparc   = tempotrab-consparc[qtdpos].
        credscore.operacao      = tempotrab-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "tempotrab",
                       input recatu1).
    end. /* do qtdpos */    
    
                           
    end.

end procedure.

procedure dados3.
    def input parameter par-acao as char.

    do:
         
        /* Cartoes de Credito */
        qtdpos = 0.
        for each credscore where credscore.campo = "cartoes" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            cartoes-tipo[qtdpos]     = credscore.tipo-vl.
            cartoes-desc[qtdpos]     = credscore.vl-char.
            cartoes-valor[qtdpos]    = credscore.valor.
            cartoes-consparc[qtdpos] = credscore.consnumparc.
            cartoes-operacao[qtdpos] = credscore.operacao.
        end.

        /* Referencias Bancarias */
        qtdpos = 0.
        for each credscore where credscore.campo = "refban" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            refban-ini[qtdpos]      = credscore.vl-ini.
            refban-fin[qtdpos]      = credscore.vl-fin.
            refban-tipo[qtdpos]     = credscore.tipo-vl.
            refban-desc[qtdpos]     = credscore.vl-char.
            refban-valor[qtdpos]    = credscore.valor.
            refban-consparc[qtdpos] = credscore.consnumparc.
            refban-operacao[qtdpos] = credscore.operacao.
        end.
        
        /* Tipo de Conta Bancaria */
        qtdpos = 0.
        for each credscore where credscore.campo = "tipconta" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            tipconta-tipo[qtdpos]     = credscore.tipo-vl.
            tipconta-desc[qtdpos]     = credscore.vl-char.
            tipconta-valor[qtdpos]    = credscore.valor.
            tipconta-consparc[qtdpos] = credscore.consnumparc.
            tipconta-operacao[qtdpos] = credscore.operacao.
        end.        

        disp 
   "  Cartoes de Credito    Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            cartoes-desc[1]                    at 5 format "x(15)"
            cartoes-tipo[1]                    at 26 format "Perc/Val"
            cartoes-operacao[1]                at 36 format "Dim/Som"
            cartoes-valor[1]                   
            cartoes-consparc[1]                at 60 format "Sim/Nao"
            cartoes-desc[2]                     at 5 format "x(15)"
            cartoes-tipo[2]                    at 26 format "Perc/Val"
            cartoes-operacao[2]                at 36 format "Dim/Som"
            cartoes-valor[2]                   
            cartoes-consparc[2]                at 60 format "Sim/Nao"
            cartoes-desc[3]                     at 5 format "x(15)"
            cartoes-tipo[3]                    at 26 format "Perc/Val"
            cartoes-operacao[3]                at 36 format "Dim/Som"
            cartoes-valor[3]                   
            cartoes-consparc[3]                at 60 format "Sim/Nao"
            cartoes-desc[4]                     at 5 format "x(15)"
            cartoes-tipo[4]                    at 26 format "Perc/Val"
            cartoes-operacao[4]                at 36 format "Dim/Som"
            cartoes-valor[4]                   
            cartoes-consparc[4]                at 60 format "Sim/Nao"
            skip(1)
   "  Referencias Bancarias     Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            /*
            refban-desc[1]                    at 10 format "x(9)"
            */
            refban-ini[1]         
            refban-fin[1]
            refban-tipo[1]                    at 26 format "Perc/Val"
            refban-operacao[1]                at 36 format "Dim/Som"
            refban-valor[1]                   
            refban-consparc[1]                at 60 format "Sim/Nao"
            skip
            /*
            refban-desc[2]                     at 10 format "x(9)"
            */
            refban-ini[2]
            refban-fin[2]
            refban-tipo[2]                    at 26 format "Perc/Val"
            refban-operacao[2]                at 36 format "Dim/Som"
            refban-valor[2]                   
            refban-consparc[2]                at 60 format "Sim/Nao"
            skip
            /*
            refban-desc[3]                     at 10 format "x(9)"
            */
            refban-ini[3]
            refban-fin[3]
            refban-tipo[3]                    at 26 format "Perc/Val"
            refban-operacao[3]                at 36 format "Dim/Som"
            refban-valor[3]                   
            refban-consparc[3]                at 60 format "Sim/Nao"
            skip
   "  Tipo de Conta Bancaria  Perc/Val   Dim/Som    Valor    Cons.Num.Parc.Pg"
            skip
            tipconta-desc[1]                    at 10 format "x(9)"
            tipconta-tipo[1]                    at 26 format "Perc/Val"
            tipconta-operacao[1]                at 36 format "Dim/Som"
            tipconta-valor[1]                   
            tipconta-consparc[1]                at 60 format "Sim/Nao"
            tipconta-desc[2]                     at 10 format "x(9)"
            tipconta-tipo[2]                    at 26 format "Perc/Val"
            tipconta-operacao[2]                at 36 format "Dim/Som"
            tipconta-valor[2]                   
            tipconta-consparc[2]                at 60 format "Sim/Nao"                      with frame fdados3 no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame fdados3:
        pause 0.
        
    /* Cartoes de Credito */
    do qtdpos = 1 to 4:
        find first credscore where credscore.campo = "cartoes"
                               and credscore.vl-char = cartoes-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        cartoes-recid[qtdpos] = recatu1.
                    
        update cartoes-desc[qtdpos]            at 10
               cartoes-tipo[qtdpos]            at 26 format "Perc/Val"
               cartoes-operacao[qtdpos]        at 36 format "Dim/Som"
               cartoes-valor[qtdpos]           
               cartoes-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados3 no-label 
                row 9 size 80 by 14 overlay no-box.
                           
        find first credscore
            where recid(credscore) = cartoes-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "cartoes".
            credscore.desc-campo    = "Cartoes de Credito".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = cartoes-tipo[qtdpos].
        credscore.vl-char       = cartoes-desc[qtdpos].
        credscore.valor         = cartoes-valor[qtdpos].
        credscore.consnumparc   = cartoes-consparc[qtdpos].
        credscore.operacao      = cartoes-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "cartoes",
                       input recatu1).
    end. /* do qtdpos */
    
    /* Referencias Bancarias */
    do qtdpos = 1 to 3:
        find first credscore where credscore.campo = "refban"                  
                               and credscore.vl-ini = refban-ini[qtdpos]
                               and credscore.vl-fin = refban-fin[qtdpos]
                              /* and credscore.vl-char = refban-desc[qtdpos]*/
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        refban-recid[qtdpos] = recatu1.
                    
        update /*refban-desc[qtdpos]            at 10*/
               refban-ini[qtdpos]
               refban-fin[qtdpos]
               refban-tipo[qtdpos]            at 26 format "Perc/Val"
               refban-operacao[qtdpos]        at 36 format "Dim/Som"
               refban-valor[qtdpos]           
               refban-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados3 no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = refban-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "refban".
            credscore.desc-campo    = "Referencias Bancarias".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.vl-ini        = refban-ini[qtdpos].
        credscore.vl-fin        = refban-fin[qtdpos].
        credscore.tipo-vl       = refban-tipo[qtdpos].
        credscore.vl-char       = refban-desc[qtdpos].
        credscore.valor         = refban-valor[qtdpos].
        credscore.consnumparc   = refban-consparc[qtdpos].
        credscore.operacao      = refban-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "refban",
                       input recatu1).
    end. /* do qtdpos */    

    
    /* Tipo de Conta Bancaria */
    do qtdpos = 1 to 2:
        find first credscore where credscore.campo = "tipconta"                                                  and credscore.vl-char = tipconta-desc[qtdpos]
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        tipconta-recid[qtdpos] = recatu1.
                    
        update tipconta-desc[qtdpos]            at 10
               tipconta-tipo[qtdpos]            at 26 format "Perc/Val"
               tipconta-operacao[qtdpos]        at 36 format "Dim/Som"
               tipconta-valor[qtdpos]           
               tipconta-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados3 no-label 
                row 9 size 80 by 14 overlay no-box.
                            
        find first credscore
            where recid(credscore) = tipconta-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "tipconta".
            credscore.desc-campo    = "Tipo de Conta Bancaria".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = tipconta-tipo[qtdpos].
        credscore.vl-char       = tipconta-desc[qtdpos].
        credscore.valor         = tipconta-valor[qtdpos].
        credscore.consnumparc   = tipconta-consparc[qtdpos].
        credscore.operacao      = tipconta-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "tipconta",
                       input recatu1).
    end. /* do qtdpos */    
                           
    end.

end procedure.


procedure dados4.      /*    Referencias Pessoais */
    def input parameter par-acao as char.

    do:
         
        /* Possui Carro */
        find first credscore where credscore.campo = "carro" 
            no-lock no-error.
        if avail credscore
        then assign vcarro = credscore.vl-log
                    carro-tipo = credscore.tipo
                    carro-operacao = credscore.operacao
                    carro-valor = credscore.valor
                    carro-consparc = credscore.consnumparc.
        else vcarro = no.
        
        /* Ano de Fabricacao do Carro */
        qtdpos = 0.
        for each credscore where credscore.campo = "anocarro" no-lock
            by credscore.vl-ini.
            qtdpos = qtdpos + 1.
            anocarro-tipo[qtdpos]     = credscore.tipo-vl.
            anocarro-ini[qtdpos]      = credscore.vl-ini.
            anocarro-fin[qtdpos]      = credscore.vl-fin.
            anocarro-desc[qtdpos]     = credscore.vl-char.
            anocarro-valor[qtdpos]    = credscore.valor.
            anocarro-consparc[qtdpos] = credscore.consnumparc.
            anocarro-operacao[qtdpos] = credscore.operacao.
        end.

        disp 
            skip(1)
                    "Possui Carro" 
                     vcarro at 20
                     help "Possui Carro ?" 
                     carro-tipo                      format "Perc/Val"   at 26
                     carro-operacao                  format "Dim/Som"    at 36
                     carro-valor
                     carro-consparc                  format "Sim/Nao"    at 60         
            skip(1)    
   "  Ano de Fabricacao    Perc/Val   Dim/Som    Valor   Cons.Num.Parc.Pg"
            skip
            /*
            anocarro-desc[1]                    at 10 format "x(9)"
            */
            anocarro-ini[1]                     at 5  format ">>9"
            anocarro-fin[1]                     format ">>9"
            anocarro-tipo[1]                    at 26 format "Perc/Val"
            anocarro-operacao[1]                at 36 format "Dim/Som"
            anocarro-valor[1]                   
            anocarro-consparc[1]                at 60 format "Sim/Nao"
            anocarro-ini[2]                     at 5  format ">>9"
            anocarro-fin[2]                     format ">>9"
            /*
            anocarro-desc[2]                     at 10 format "x(9)"
            */
            anocarro-tipo[2]                    at 26 format "Perc/Val"
            anocarro-operacao[2]                at 36 format "Dim/Som"
            anocarro-valor[2]                   
            anocarro-consparc[2]                at 60 format "Sim/Nao"
            anocarro-ini[3]                     at 5  format ">>9"
            anocarro-fin[3]                     format ">>9"
            /*
            anocarro-desc[3]                     at 10 format "x(9)"
            */
            anocarro-tipo[3]                    at 26 format "Perc/Val"
            anocarro-operacao[3]                at 36 format "Dim/Som"
            anocarro-valor[3]                   
            anocarro-consparc[3]                at 60 format "Sim/Nao"                       with frame fdados4 no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame frefpess:
        pause 0.

        find first credscore where credscore.campo = "carro"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rcarro = recatu1.
                
                update skip
                    vcarro at 20
                    help "Possui Carro ?" 
                    carro-tipo                      format "Perc/Val" at 26
                    carro-operacao                  format "Dim/Som"  at 36
                    carro-valor
                    carro-consparc                  format "Sim/Nao"  at 60
                    skip
                    with frame fdados4 no-label 
                        row 9 size 80 by 14 overlay no-box.

                /* Possui Carro */
                find first
                 credscore where credscore.campo = "carro"
                    exclusive-lock no-error.
                if not avail credscore
                then do:
                    create credscore.
                    credscore.campo = "carro".
                    credscore.desc-campo = "Possui Carro".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.vl-log        = vcarro.
                credscore.tipo-vl       = carro-tipo.
                credscore.valor         = carro-valor.
                credscore.consnumparc   = carro-consparc.
                credscore.operacao      = carro-operacao.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "carro",
                               input recatu1).                       
                       
        
    /* Ano de Fabricacao do Carro */
    do qtdpos = 1 to 3:
        find first credscore where credscore.campo = "anocarro"
                               and credscore.vl-ini = anocarro-ini[qtdpos]
                               and credscore.vl-fin = anocarro-fin[qtdpos]
                               /*
                               and credscore.vl-char = anocarro-desc[qtdpos]*/
                                           no-lock no-error.
        if avail credscore
        then do:
            recatu1 = recid(credscore).
            run p-guardaval (input "Alteracao").
        end.    
        else do:
            recatu1 = ?.
            run p-guardaval (input "Inclusao").
        end.    
        anocarro-recid[qtdpos] = recatu1.
                    
        update /*anocarro-desc[qtdpos]            at 10*/
               anocarro-ini[qtdpos]
               anocarro-fin[qtdpos]
               anocarro-tipo[qtdpos]            at 26 format "Perc/Val"
               anocarro-operacao[qtdpos]        at 36 format "Dim/Som"
               anocarro-valor[qtdpos]           
               anocarro-consparc[qtdpos]        at 60 format "Sim/Nao"
            with frame fdados4 no-label 
                row 9 size 80 by 14 overlay no-box.
                           
        find first credscore
            where recid(credscore) = anocarro-recid[qtdpos]
                  exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo         = "anocarro".
            credscore.desc-campo    = "Ano de Fabricacao do Carro".
            vtipoalt = "Inclusao".
        end.
        else vtipoalt = "Alteracao".
        
        credscore.tipo-vl       = anocarro-tipo[qtdpos].
        credscore.vl-char       = anocarro-desc[qtdpos].
        credscore.valor         = anocarro-valor[qtdpos].
        credscore.consnumparc   = anocarro-consparc[qtdpos].
        credscore.operacao      = anocarro-operacao[qtdpos].
                 
        recatu1 = recid(credscore).
        run p-compval (input vtipoalt,
                       input "anocarro",
                       input recatu1).
    end. /* do qtdpos */
    
end.
end procedure.







procedure dados5.      /*   Call Center */
    def input parameter par-acao as char.

    do:
         
        /* CRIIC */
        find first credscore where credscore.campo = "criic" 
            no-lock no-error.
        if avail credscore
        then assign vcriic = credscore.valor.
        else assign vcriic = 0.
        
        /* CRIIC1 */
        find first credscore where credscore.campo = "criic1" 
            no-lock no-error.
        if avail credscore
        then assign vcriic1 = credscore.valor.
        else assign vcriic1 = 0.        

        /* CRIIC 2 */
        find first credscore where credscore.campo = "criic2" 
            no-lock no-error.
        if avail credscore
        then assign vcriic2 = credscore.valor.
        else assign vcriic2 = 0.
                
        disp 
            skip(1)
                    "CRIIC" 
                     vcriic at 20
                     help "Dias para Cobrar pelo CRIIC" 
                     
                    "CRIIC 1" 
                     vcriic1

                    "CRIIC 2" 
                     vcriic2
                
            skip(1)    
~              with frame fdados5 no-label 
                row 9 size 80 by 14 overlay no-box.
         
     end.
if par-acao = "MANUTENCAO"
    then do on error undo with frame fdados5:
        pause 0.

        find first credscore where credscore.campo = "criic"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rcriic = recatu1.
                
                update skip
                    vcriic at 20
                    with frame fdados5 no-label 
                        row 9 size 80 by 14 overlay no-box.

                find first credscore where credscore.campo = "criic"
                    no-error.
                if not avail credscore
                then do:               
                    create credscore.
                    credscore.campo = "criic".
                    credscore.desc-campo = "Dias para Cobrar pelo CRIIC".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.valor = vcriic.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "criic",
                               input recatu1).

                       
                       
                       
        find first credscore where credscore.campo = "criic1"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rcriic1 = recatu1.
                
                update skip
                    vcriic1
                    with frame fdados5 no-label 
                        row 9 size 80 by 14 overlay no-box.

                find first credscore where credscore.campo = "criic1"
                    no-error.
                if not avail credscore
                then do:               
                    create credscore.
                    credscore.campo = "criic1".
                    credscore.desc-campo = "Dias para Cobrar pelo CRIIC 1".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.valor = vcriic1.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "criic1",
                               input recatu1).                       
                       

        find first credscore where credscore.campo = "criic2"
                    no-lock no-error.
                if avail credscore
                then do:
                    recatu1 = recid(credscore).
                    run p-guardaval(input "Alteracao").
                end.    
                else do:
                    recatu1 = ?.
                    run p-guardaval(input "Inclusao").
                end.    
                rcriic2 = recatu1.
                
                update skip
                    vcriic2
                    with frame fdados5 no-label 
                        row 9 size 80 by 14 overlay no-box.

                find first credscore where credscore.campo = "criic2"
                    no-error.
                if not avail credscore
                then do:               
                    create credscore.
                    credscore.campo = "criic2".
                    credscore.desc-campo = "Dias para Cobrar pelo CRIIC 2".
                    vtipoalt = "Inclusao".
                end.
                else vtipoalt = "Alteracao".
                credscore.valor = vcriic2.
            
                recatu1 = recid(credscore).
                run p-compval (input vtipoalt,
                               input "criic2",
                               input recatu1).        
        
        
end.
end procedure.
