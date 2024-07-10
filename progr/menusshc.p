/*
*
*    Esqueletao de Programacao
*
*/

/*----------------------------------------------------------------------------*/

{/admcom/progr/loja-com-ecf-def.i} 

def var vsenha like func.senha format "x(10)".
def var vpropath        as char format "x(150)".
input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{/admcom/progr/admcab.i.ssh new}

def var funcao          as char.
def var parametro       as char.

input from /admcom/work/admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
    if funcao = "CAIXA"
    then scxacod = int(parametro).
    if funcao = "CLIEN"
    then scliente = parametro.
    if funcao = "RAMO"
    then stprcod = int(parametro).
    else stprcod = ?.
end.
input close.

setbcod = int(SESSION:PARAMETER).

find admcom where admcom.cliente = scliente no-lock.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

do on error undo, return on endkey undo, retry:
    vsenha = "".
    update vfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    if vfuncod = 0 and
       vsenha  = "proedlinx"
    then next.
    find first func where func.funcod = vfuncod and
                          func.etbcod = 999      and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.
end.
if setbcod = 0
then setbcod = estab.etbcod.

hide frame f-senh no-pause.

/* CHAMA NOVA RETAGUARDA PARA TODAS AS LOJAS */
run sys/tsmmenu.p ("modulo=remoto").
quit.

find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.
display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)  @  wempre.emprazsoc
                    wdata with frame fc1.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

def var vindex-lib as char.
vindex-lib = "1=1|2=2|3=3|4=4|5=5|6=6|7=7|8=8|9=9|10=10|11=11|12=12|13=13|14=14|15=15|16=16|17=17|18=18|19=19|20=20|21=21|22=22|23=23|24=24|25=25|26=26|27=27|28=28|29=29|".

repeat:
    display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)  @  wempre.emprazsoc
                    wdata with frame fc1.
  wtittela = "ADMCOM / MODULO DE RETAGUARDA (ALT + F1 P/ RETORNAR TELA FILIAL)".

    def var v-linha as char extent 29 format "x(40)".
    v-linha[1] = "HISTORICO CLIENTE".
    v-linha[2] = "CONSULTA NOTA DE VENDA".
    v-linha[3] = "VENDA POR CONTRATO ".
    v-linha[4] = "CALL-CENTER - COBRANCAS ".
    v-linha[5] = "CALL-CENTER - COBRANCAS FEITAS  ".
    v-linha[6] = "CONFERENCIA DE TRANSFERENCIA".
    v-linha[7] = "ANALITICO".
    v-linha[8] = "CONSULTA PEDIDOS AUTOMATICOS".
    v-linha[9] = "POSICAO VENCIDOS E A VENCER".
    v-linha[10] = "DESPESAS FINANCEIRAS".
    v-linha[11] = "SIMULACAO DE NOVACAO".
    v-linha[12] = "COMISSAO DOS COBRADORES".
    v-linha[13] = "REPOSICAO E PRODUTOS NOVOS".
    v-linha[14] = "ARQUIVO DE ESTOQUES CONTROLLER".
    v-linha[15] = "PEDIDO MANUAL".
    v-linha[16] = "CONSULTA CARTAO LEBES".
    v-linha[17] = "CONSULTA NOTA FISCAL DE VENDA".
    v-linha[18] = "INCLUSAO DE PREMIOS PARA LIBERACAO".
    v-linha[19] = "INCLUSAO NOTAS FISCAIS DE SERVICO" .
    v-linha[20] = "PLANILHA DE FECHAMENTO GERAL". 
    v-linha[21] = "LISTAGEM DE CLIENTES CRM".
    v-linha[22] = "CADASTRO DE PARTICIPANTES CLUBE BI$". 
    v-linha[23] = "CONSULTAR METAS E ACOES PARA OS SETORES".
    v-linha[24] = "CONSULTA COMISSAO DOS VENDEDORES".
    v-linha[25] = "CONSULTA COMISSAO MOVEIS".
    v-linha[26] = "LISTAGEM DE CLIENTES 2".
    v-linha[27] = "RESUMO LIQUIDACOES DIARIAS P/ PERIODO".
    v-linha[29] = "EXTRATO DE MOVIMENTACAO".

    {/admcom/progr/loja-com-ecf.i setbcod} 
    
    if p-loja-com-ecf
    then v-linha[28] = "Emissao de NFEs".
      
    disp v-linha with frame f-linha 1 down centered no-label 1 column
            row 4 title "    CREDIARIO    ".
    choose field v-linha with frame f-linha.
    
    hide frame f-linha no-pause.

    if string(frame-index) = acha(string(frame-index),vindex-lib)
    then.
    else do:
        message color red/with "Menu indisponivel" view-as alert-box.
        next.
    end. 

    if v-linha[frame-index] = ""
    then next.

    /*** Ricardo 03/05/2016
    do for menfun transaction:
        find first menfun where menfun.funcod = sfuncod
                            and menfun.mencod = 3100 + frame-index
                          no-error.
        if not avail menfun
        then do:
            create menfun.
            assign
                menfun.funcod = sfuncod
                menfun.mencod = 3100 + frame-index
                menfun.dtacess = today
                menfun.hrinicio = time
                menfun.tty    = v-linha[frame-index].
        end.
        menfun.qtdentradas = menfun.qtdentradas + 1.
    end.***/
    
    if frame-index = 1
    then do:
        run hiscli01.p.
    end.
    else if frame-index = 2
    then do:
        run nfvencol.p.
    end.
    else if frame-index = 3
    then do:
        run conco_2.p.
    end.
    else if frame-index = 4
    then do:
        run bstelcli.p.
    end.
    else if frame-index = 5
    then do:
        run bstellig.p.
    end.
    else if frame-index = 6 /*** sshv = 5 ***/
    then do:
        run con-conl.p.
    end.
    else if frame-index = 7
    then do:
        run anavenlj.p.
    end.
    else if frame-index = 8 /*** sshv = 4 ***/
    then do:
        run pedautlj.p.
    end.
    else if frame-index = 9
    then do:
        run pogerlj.p.
    end.
    else if frame-index = 10
    then do:
        run titluclj.p.
    end.
    else if frame-index = 11
    then do:
        run novacaol.p.
    end.
    else if frame-index = 12
    then do:
        run comi-cob.p.
    end.
    ELSE IF frame-index = 13
    then do:
        run pedrepo0.p.
    end.
    ELSE IF FRAME-INDEX = 14
    then do:
        run bascontr.p("ESTOQUES").
    end.
    else if frame-index = 15
    then do:
        run fipedido.p.
    end.
    ELSE if frame-index = 16 /*** ssh = ***/
    then do:
        run cocartal.p.
    end.
    ELSE if frame-index = 17 /***ssh 19 ***/
    then do:
        run nfvconlj.p.
    end.
    ELSE if frame-index = 18
    then do:
        run incpmolj.p.
    end. 
    ELSE if frame-index = 19
    then do:
        run nfentall.p.
    end.
    ELSE if frame-index = 20
    then do:
        run plani-4lj.p.
    end.
    ELSE if frame-index = 21
    then do:
        message "Conectando ao banco CRM...".
        if connected ("crm")
        then disconnect crm.

        connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm.

        run lisbon02-ssh.p.

        if connected ("crm")
        then disconnect crm.
    end.
    else if frame-index = 22
    then do:
        run cadclub1.p.
    end.
    else if frame-index = 23
    then do:
        run cadmeta2.p.
    end.
    else if frame-index = 24
    then do:
        run dreb0631.p.
    end.
    else if frame-index = 25
    then run plani-4-i-rh.p(3).
    else if frame-index=26
    then run rel-bonus-crm.p.
    else if frame-index = 27
    then run relqtdNovo.p.
    else if frame-index = 28  
    then run emis_nfe_remoto.p. /***loj/nftra_NFe.p***/
    else if frame-index = 29
    then run _extrato12.p.
end.

quit.
