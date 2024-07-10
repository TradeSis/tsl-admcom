/*
*
*    Esqueletao de Programacao
*
*/

/*----------------------------------------------------------------------------*/
def var vsenha like func.senha format "x(10)".
def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{/admcom/progr/admcab.i.ssh new}

def var funcao          as char.
def var parametro       as char.
def var v-ok            as log.
def var vok             as log.

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
vindex-lib = "1=1|2=2|3=3|4=4|5=5|6=6|7=7|8=8|9=9|10=10|11=11|12=12|13=13|14=14|15=15|16=16|17=17|18=18|19=19|20=20|21=21|22=22|23=23|24=24|25=25|26=26|27=27|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|28=28|29=29|30=30|31=31|32=32|33=33|".

repeat:
    def var v-linha as char extent 33 format "x(35)".
    v-linha[1] = "POSICAO DE ESTOQUE".
    v-linha[2] = "EXTRATO MOVIMENTACAO".
    v-linha[3] = "ASSISTENCIA TECNICA".
    v-linha[4] = "CONSULTA PEDIDOS".
    v-linha[5] = "CONFERENCIA DE TRANSFERENCIA".
    v-linha[6] = "POSICAO ESTOQUE FORNE/CLASSE".
    v-linha[7] = "ANALITICO".
    v-linha[8] = "INVENTARIO".
    v-linha[9] = "ARQUIVO DE ESTOQUES CONTROLLER".
    v-linha[10] = "REPOSICAO E PRODUTOS NOVOS".
    v-linha[11] = "PEDIDOS ESPECIAIS".
    v-linha[12] = "PEDIDO MANUAL".
    v-linha[13] = "CONSULTA DE DESCONTO".
    v-linha[14] = "CADASTRO DE SERIAIS(ES N/IMEI)".
    v-linha[15] = "CONSULTA PRECOS ALTERADOS".
    v-linha[16] = "CONSULTA CARTAO LEBES".
    v-linha[17] = "CONSULTA MIX DE PRODUTOS". 
    v-linha[18] = "CONSULTA PRODUTOS FORA DO MIX".
    v-linha[19] = "CONSULTA NOTA FISCAL DE VENDA".
    v-linha[20] = "CONSULTA INTENCAO DE COMPRA".
    v-linha[21] = "CONSULTA INVENTARIO POR NOME".   
    v-linha[22] = "LISTAGEM DE CLIENTES CRM".
    v-linha[23] = "CONSULTA DISPONIBILIDADE DO PRODUTO".
    v-linha[24] = "CADASTRO DE PARTICIPANTES CLUBE BI$". 
    v-linha[25] = "CONSULTAR METAS E ACOES PARA OS SETORES".
    v-linha[26] = "CONSULTAR SERIAIS DE UMA NOTA FISCAL".
    v-linha[27] = "CONSULTA COMISSAO DOS VENDEDORES".    
    v-linha[28] = "POSICAO DE ESTOQUE NEGATIVO ATUAL".
    v-linha[29] = "CONSULTA ESTOQ DISPONIVEL DOS DEPs.".
    v-linha[30] = "CONSULTA COMISSAO MOVEIS".
    v-linha[32] = "LISTAGEM BONUS CRM".
    v-linha[33] = "EXTRATO DE MOVIMENTACAO P/ PRODUTO".
    if setbcod >= 300
    then v-linha[31] = "PEDIDO ENTREGA OUTRA FILIAL".
    

    disp v-linha
        with frame f-linha 1 down centered no-label 1 column
            row 4 title "  V E N D A  ".
    choose field v-linha with frame f-linha.
    
    hide frame f-linha no-pause.

    if string(frame-index) = acha(string(frame-index),vindex-lib)
    then.
    else do:
        message color red/with
        "Menu indisponivel"
        view-as alert-box.
        next.
    end.    

    /*** Ricardo 03/05/2016
    do for menfun transaction:
        find first menfun where menfun.funcod = sfuncod
                            and menfun.mencod = 3000 + frame-index
                          no-error.
        if not avail menfun
        then do:
            create menfun.
            assign
                menfun.funcod = sfuncod
                menfun.mencod = 3000 + frame-index
                menfun.dtacess = today
                menfun.hrinicio = time
                menfun.tty    = v-linha[frame-index].
        end.
        menfun.qtdentradas = menfun.qtdentradas + 1.
    end.***/

    if frame-index = 1
    then do:
        run pesco.p.
        /*
        run posicao-estoque.p
        */
    end.
    else if frame-index = 2
        then do:
            /*
            run extra0_p.p. */
            /*run _extrato10.p.*/
            run _extrato12.p.
        end.
        else if frame-index = 3
            then do:  
                /*run asstec01.p. */
                run asstec_lj.p.   
            end.
            else if frame-index = 4 /*** sshc = 8 ***/
            then do:
                run pedautlj.p.
            end.
            else if frame-index = 5 /*** sshc = 6 ***/
            then do:
                run con-conl.p.
            end.
            else if frame-index = 6
            then do:
            /*    run estloja.p . */
                run posestlj.p.
                            end.
            else if frame-index = 7
            then do:
                run anavenlj.p.
            end.
            else if frame-index = 8
            then do:
                run relinv.p.
            end.
            ELSE IF FRAME-INDEX = 9
            then do:
                run bascontr.p("ESTOQUES").
            end.    
            else if frame-index = 10
            then do:
                run pedrepo0.p.
            end.
            else if frame-index = 11
            then do:
                run pedesp02.p(6).
            end.
            else if frame-index = 14
            then do:
                run cadesn.p.    
            end.
            else if frame-index = 12
            then do:
                run fipedido.p.
            end.
            else if frame-index = 13
            then do:
                run condesmd.p.
            end.
            else if frame-index = 15
            then do:
                run hispre01.p.
            end. 
            ELSE if frame-index = 16 /*** ssh = ***/
            then do:
                 run cocartal.p.
            end.
            ELSE if frame-index = 17
            then do:
                 run conmix-lj.p.
            end.
            ELSE if frame-index = 18
            then do:
                 run semmix-lj.p.
            end.       
            ELSE if frame-index = 19 /***ssh 17 ***/
            then do:
                 run nfvconlj.p. 
            end. 
            ELSE if frame-index = 20
            then do:
                run csintcmp.p.
            end.  
            ELSE if frame-index = 21
            then do:
                run invpnom.p .
            end.     
            ELSE if frame-index = 22    
            then do:
                  
                 message "Conectando ao banco CRM...".
                 if connected ("crm")
                 then disconnect crm.

                 connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm.

                 run lisbon02-ssh.p.

                 if connected ("crm")
                 then disconnect crm.
            
            end.
            ELSE if frame-index = 23    
            then RUN teclar-v.p.
            else if frame-index = 24
            then run cadclub1.p.
            else if frame-index = 25
            then run cadmeta2.p.
            else if frame-index = 26
            then run imeif.p.
            else if frame-index = 27
            then run dreb0631.p.
            else if frame-index = 28
            then run posestl0.p.
            else if frame-index = 29
            then run estoq_retaguarda_loja2.p.
            else if frame-index = 30
            then run plani-4-i-rh.p(3).
            else if frame-index = 31
            then run inped-entoutfil.p.
            else if frame-index = 32
            then run rel-bonus-crm.p.
            else if frame-index = 33
            then run extMovtoProd.p.
end.
quit.
