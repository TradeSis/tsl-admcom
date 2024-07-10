/***************************************************************************
** Programa : Correio.p
** Autor ...: Andre Baldini
** Data ....: 06/05/1999
** Descricao: Manutencao do Cadastro de Mensagens
**************************************************************************/

{admcab.i}.
{setbrw.i}.
{anset.i}.

def temp-table tt-cor
    field funcod like func.funcod
    field etbcod like func.etbcod.

def buffer bcorreio for correio.        
def var v-fundes    like func.funcod.
def var v-cod like func.funcod.
def var v-cont as int.
def var vl as char format "x".

def var v-opcao as char format "x(10)"  extent 3 
    initial ["  NOVAS  "," ENVIADAS", "RECEBIDAS"].

def var vetbcod like estab.etbcod.
def var v-funcod like func.funcod.
def var v-senha  like func.senha.
def var vhora as char.
def buffer bfunc for func.
def buffer sfunc for func.
def var varqsai as char.

form
    vetbcod 
    with frame f-lojafunc
        side-labels centered overlay 1 down row 10 
        title "LOJA do FUNCIONARIO" .

form    
    v-opcao[1]
    v-opcao[2]
    v-opcao[3]
    with frame f-opcao
        centered
        1 down
        no-labels
        title " OPCOES " .

form
    an-seelst format "x" column-label "*"
    func.funcod
    func.funape
    func.funfunc
        help " ENTER = Seleciona   F4/F1 = Confirma " 
    with frame f-funcao
        centered
        overlay
        down
        title " POR FUNCAO ".
        
form
    an-seelst format "x" column-label "*"
    func.funcod
    func.funape
        help "ENTER=Seleciona  F4/F1=Confirma"
    with frame f-nome 
        centered
        overlay 
        down
        title " POR NOME ".
        
form
    correio.funemi column-label "Emit"
        help "ENTER=Consulta  F4=Encerra  F8=Imprime  F10=Arquivamento"   
    func.funape    format "x(18)" 
    correio.assunto format "x(29)"
    correio.dtmens
    vhora   column-label "Hora"
    correio.situacao column-label "S" format "x"
    with frame f-receb
        centered
        down
        title " MENSAGENS RECEBIDAS ". 

def var v-opc2 as char format "x(12)" extent 3 initial
    [" POR FUNCAO ", "  POR  NOME " ,  "TODOS"].
    
form
    v-opc2[1]
    v-opc2[2]
    V-opc2[3]
    with frame f-opc2
        centered
        1 down
        no-labels
        overlay.

form
    correio.funcod
         help "ENTER=Consulta  F4=Encerra  F9=Inclusao  F10=Exclusao "   
    func.funape     format "x(20)" 
    func.etbcod     format ">>9" 
    correio.assunto format "x(20)" 
    correio.dtmens
    vhora column-label "Hora" 
    correio.situacao column-label "S"
    with frame f-enviadas
        centered
        down
        title " MENSAGENS ENVIADAS ". 

form
    v-funcod           label "Matricula" 
    func.funape        no-label
    v-senha            label "Senha" 
    with frame f-funcod
        centered
        1 down
        side-labels
        title " FUNCIONARIO " .

form
    correio.assunto 
    with frame f-altera1 
        centered
        1 down
        no-label
        overlay
        title " ASSUNTO " .
        
form
    v-fundes 
    bfunc.funape 
    with frame f-altera2
        centered
        row 9
        1 down
        no-labels
        title " DESTINATARIOS ".
        
form
    correio.mens[1]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[2]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[3]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[4]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[5]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[6]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[7]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[8]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[9]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[10]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[11]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[12]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[13]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[14]
        help "F1=Finaliza  F4=Desiste"
    correio.mens[15]
    with frame f-altera3
        centered
        1 down
        no-labels
        overlay
        title " MENSAGEM " .

    clear frame f-opcao all.
    hide frame f-opcao.      
    find first sfunc where sfunc.funcod = sfuncod no-lock no-error.

    repeat : 
        disp v-opcao with frame f-opcao.
        choose field v-opcao with frame f-opcao.
        if frame-index = 1 
        then  do :
            {menenvi.no}.
            next.
        end.    
        
        if frame-index = 3
        then do :
            hide frame f-opcao.
            assign
                an-seeid = -1 an-recid = -1 an-seerec = ?
                vl = "L".
    
            {anbrowse.i
                &File   = correio
                &CField = correio.funemi
                &Ofield = " func.funape
                            correio.dtmens
                            correio.assunto 
                            vhora
                            correio.situacao "
                &Where = "correio.funcod = sfuncod and
                          correio.situacao <> ""x"" and
                          correio.etbcod = setbcod " 
                &NonCharacter = /*          
                &Aftfnd = "
                    find first func where func.funcod = correio.funemi and
                      func.etbcod = setbcod no-lock.
                    vhora = string(correio.hrmens,""hh:mm:ss"").  " 
                &AftSelect1 =  " 
                    if correio.situacao <> ""o"" then correio.situacao = ""L"".
                    disp  
                correio.mens[1] correio.mens[2] correio.mens[3] correio.mens[4]
                correio.mens[5] correio.mens[6] correio.mens[7] correio.mens[8]
                correio.mens[9] correio.mens[10] correio.mens[11] 
                correio.mens[12]  with frame f-linha centered
                    1 down no-labels title ""MENSAGEM"" row 5. pause.
                an-seeid = -1. clear frame f-linha all.
                hide frame f-linha. next keys-loop.  " 
                &Otherkeys1 = "menrece2.ok" 
                &LockType = "no-lock" 
                &Form = " frame f-receb "
            }. 
            clear frame f-receb all.
            hide frame f-receb.
            clear frame f-altera1 all.
            clear frame f-altera2 all.
            clear frame f-altera3 all.
            hide frame f-altera1.
            hide frame f-altera2.
            hide frame f-altera3.
        end.        
        else do :
            hide frame f-opcao.
            assign
                an-seeid = -1 an-recid = -1 an-seerec = ?.
    
            {anbrowse.i
                &File   = correio
                &CField = correio.funcod
                &Ofield = " func.funape
                            func.etbcod 
                            correio.dtmens
                            vhora
                            correio.assunto correio.situacao  "
                &Where = "correio.funemi = sfuncod and
                          correio.etbemi = setbcod " 
                &NonCharacter = /*          
                &NotFound1 = "menenvi.in" 
                &AfTfnd = "
                    find first func where func.funcod = correio.funcod 
                      and func.etbcod = correio.etbcod no-lock.
                    vhora = string(correio.hrmens,""hh:mm:ss""). " 
                &AftSelect1 = 
                    " disp  
                correio.mens[1] correio.mens[2] correio.mens[3] correio.mens[4]
                correio.mens[5] correio.mens[6] correio.mens[7] correio.mens[8]
                correio.mens[9] correio.mens[10] correio.mens[11] 
                correio.mens[12] correio.mens[13] correio.mens[14]
                correio.mens[15] with frame f-linha. 
                an-seeid = -1. next keys-loop.  " 
                &Otherkeys1 = "menenvi.ok"     
                &LockType = "no-lock "
                &Form = " frame f-enviadas "
            }. 
            clear frame f-receb all.
            hide frame f-receb.
            clear frame f-altera1 all.
            clear frame f-altera2 all.
            clear frame f-altera3 all.
            hide frame f-altera1.
            hide frame f-altera2.
            hide frame f-altera3.
        end.    
    end.       
 

