/***************************************************************************
** Programa : pendencia.p
** Autor ...: Andre Baldini
** Data ....: 06/05/1999
** Descricao: Manutencao do Cadastro de Mensagens
**************************************************************************/

{admcab.i}.
{setbrw.i}.
{anset.i}.
def var varqsai  as char.
def buffer sofunc for func.
def var varquivo as char.

def temp-table tt-cor
    field funcod like func.funcod.

def var v-op as char format "x(7)" extent 4 initial
    ["URGENTE","  ALTA  "," MEDIA "," BAIXA "].    

form
    v-op[1]
    v-op[2]
    v-op[3]
    v-op[4]
    with frame f-opcao
        centered no-labels 1 down title " PRIORIDADE " overlay row 10.

def buffer bpendencia for pendencia.        
def var v-fundes    like func.funcod.
def var v-cod like func.funcod.
def var v-cont as int.
def var vl as char format "x".

def var v-opcao as char format "x(12)"  extent 4 
    initial ["   NOVAS   ","  ENVIADAS ", "CATALOGADAS"," RESOLVIDAS"].

def var v-num    as int.
def var v-funcod like func.funcod.
def var v-senha  like func.senha.
def var vhora as char.
def buffer bfunc for func.
def buffer sfunc for func.

form
    v-num label "Total de Pendencias" 
    with frame f-total
        centered 1 down side-labels row 21 overlay width 80.

form
    pendencia.aceita        colon 15
    skip
    pendencia.catalog       colon 15
    skip
    pendencia.dtpreten      colon 15
    with frame f-altera5
        centered
        row 12
        title " CATALOGANDO .... " 
        1 down
        overlay
        side-labels.

form
    pendencia.resolvido colon 16
    with frame f-altera6
        centered
        row 12 
        title " RESOLVENDO .... " 
        1 down
        overlay
        side-labels.

form
    pendencia.prior 
    with frame f-altera2
        centered
        1 down
        side-labels
        overlay.

form    
    v-opcao[1]
    v-opcao[2]
    v-opcao[3]                          
    v-opcao[4]
    with frame f-opcao1
        centered
        1 down
        no-labels
        title " OPCOES " .

form
    pendencia.mens[1]
        help "F1=Finaliza  F4=Desiste"
    pendencia.mens[2]
    pendencia.mens[3]
    pendencia.mens[4]
    pendencia.mens[5]
    pendencia.mens[6]
    with frame f-altera66
        centered overlay down
        title "MENSAGEM TECNICA".

form
    pendencia.funemi    column-label "Emit"
       help "ENTER=Consulta  F4=Encerra  F8=Resolve  F9=Imprime  F10=Exclui "   
    func.funape         format "x(10)" 
    sofunc.funape       format "x(10)"
    pendencia.assunto   format "x(20)" 
    pendencia.dtmens
    pendencia.prior     column-label "P" 
    pendencia.catalog   column-label "C" 
    pendencia.dtpreten
    with frame f-receb
        centered overlay 14 down
        title " PENDENCIAS CATALOGADAS ". 

form
    pendencia.funemi    column-label "Emit"
      help "ENTER=Consulta  F4=Encerra  F8=Cataloga  F9=Imprime  F10=Exclui"   
    func.funape         column-label "Emitente" format "x(8)" 
    pendencia.solic     column-label "Sol" format ">>9" 
    sofunc.funape       column-label "Solicit" format "x(8)" 
    pendencia.assunto   format "x(15)" 
    pendencia.dtmens
    vhora               column-label "Hora" 
    pendencia.prior
    pendencia.aceita
    with frame f-enviadas
        centered overlay 14 down
        title " PENDENCIAS ENVIADAS ". 
        
form
    pendencia.funemi    column-label "Emit"
        help "ENTER=Consulta  F4=Encerra F9=Imprime  F10=Exclui"   
    func.funape         column-label "Emitente" format "x(12)" 
    pendencia.solic     column-label "Sol" format ">>9" 
    sofunc.funape       column-label "Solicit" format "x(12)"
    pendencia.assunto   format "x(18)" 
    pendencia.dtpreten  column-label "Dt.Pret"
    pendencia.dtresol   column-label "Dt.Resol"  
    with frame f-resol
        centered 14 down 
        title " PENDENCIAS RESOLVIDAS ". 

form
    pendencia.solic
    pendencia.assunto 
    pendencia.mens1[1]
        help "F1=Finaliza  F4=Desiste"
    pendencia.mens1[2]
    pendencia.mens1[3]
    pendencia.mens1[4]
    pendencia.mens1[5]
    pendencia.mens1[6]
    pendencia.mens1[7]
    pendencia.mens1[8]
    pendencia.mens1[9]
    pendencia.mens1[10]
    pendencia.mens1[11]
    pendencia.mens1[12]
    pendencia.mens1[13]
    pendencia.mens1[14]
    pendencia.mens1[15]
    with frame f-altera3
        centered
        1 down
        row 10
        no-labels
        overlay
        title " PENDENCIA " .

    clear frame f-opcao1 all.
    hide frame f-opcao1.      
    find first sfunc where sfunc.funcod = sfuncod no-lock no-error.

    repeat : 
        disp v-opcao with frame f-opcao1.
        choose field v-opcao with frame f-opcao1.
        if frame-index = 1 
        then  do :
            {penenvi.no}. 
            next.
        end.    
        
        if frame-index = 3
        then do :
            hide frame f-opcao1.
            clear frame f-altera2 all. hide frame f-altera2.
            clear frame f-altera5 all. hide frame f-altera5.
            assign
                an-seeid = -1 an-recid = -1 an-seerec = ? v-num = 0.
            
            for each pendencia where pendencia.aceita = yes
                                 and pendencia.resolvido = no no-lock :
                v-num = v-num + 1.
            end.
            disp v-num with frame f-total.
            
            {anbrowse.i
                &File   = pendencia
                &CField = pendencia.funemi
                &Ofield = "func.funnom pendencia.dtmens pendencia.assunto
        pendencia.prior pendencia.catalog pendencia.dtpreten 
        sofunc.funnom when avail sofunc " 
                &Where = "pendencia.aceita = yes and
                          pendencia.resolvido = no"
                &NonCharacter = /*      
                &Aftfnd = "
                  find first func where func.funcod = pendencia.funemi no-lock.
     find first sofunc where sofunc.funcod = pendencia.solic no-lock no-error." 
                &AftSelect1 =  " 
               disp  pendencia.mens1[1] pendencia.mens1[2] pendencia.mens1[3]
                pendencia.mens1[4] pendencia.mens1[5] pendencia.mens1[6] 
                pendencia.mens1[7] pendencia.mens1[8] pendencia.mens1[9] 
                pendencia.mens1[10] pendencia.mens1[11] pendencia.mens1[12] 
                pendencia.mens1[13] pendencia.mens1[14] pendencia.mens1[15] 
                with frame f-linha centered
                    1 down no-labels title ""PENDENCIA"" row 5.
                an-seeid = -1. clear frame f-linha all.
                hide frame f-linha. next keys-loop.  " 
                &Otherkeys1 = "penresol.ok" 
                &LockType = "use-index catalog no-lock" 
                &Form = " frame f-receb "
            }. 
            clear frame f-receb all. hide frame f-receb.
            clear frame f-altera3 all. hide frame f-altera3.
        end.        
        else do :
            if frame-index = 2 
            then do : 
                hide frame f-opcao1.
                clear frame f-altera2 all. hide frame f-altera2.
                clear frame f-altera5 all. hide frame f-altera5.
                assign
                    an-seeid = -1 an-recid = -1 an-seerec = ?.
                
                for each pendenci where  pendencia.funemi = sfuncod and 
                             pendencia.aceita = no no-lock :  
                    v-num = v-num + 1.
                end.                        
                disp v-num with frame f-total. 
                 
                {anbrowse.i
                    &File   = pendencia
                    &CField = pendencia.funemi 
                    &Ofield = "pendencia.solic sofunc.funnom when avail sofunc
                        func.funape pendencia.dtmens vhora
                            pendencia.assunto pendencia.prior 
                            pendencia.aceita when pendencia.dtreceb <> ? "
                    &Where = "pendencia.funemi = sfuncod and 
                             pendencia.aceita = no " 
                    &NonCharacter = /*          
                    &NotFound1 = "penenvi.in" 
                    &AfTfnd = "
      find first sofunc where sofunc.funcod = pendencia.solic no-lock no-error.
               find first func where func.funcod = pendencia.funcod no-lock.                      vhora = string(pendencia.hrmens,""hh:mm:ss""). " 
                    &AftSelect1 =  " disp  
                   pendencia.mens1[1] pendencia.mens1[2] pendencia.mens1[3] 
                   pendencia.mens1[4] pendencia.mens1[5] pendencia.mens1[6] 
                   pendencia.mens1[7] pendencia.mens1[8] pendencia.mens1[9] 
                   pendencia.mens1[10] pendencia.mens1[11] pendencia.mens1[12] 
                   pendencia.mens1[13] pendencia.mens1[14] pendencia.mens1[15] 
                    with frame f-altera3.  an-seeid = -1. 
                    an-recid = recid(pendencia). next keys-loop.  " 
                    &Otherkeys1 = "penenvi.ok" 
                    &LockType = "use-index solic"
                    &Form = " frame f-enviadas "
                }.  
                clear frame f-receb all. hide frame f-receb.
                clear frame f-altera3 all. hide frame f-altera3.
            end.    
            else do :
                hide frame f-opcao1.
                clear frame f-altera2 all. hide frame f-altera2.
                clear frame f-altera5 all. hide frame f-altera5.
                assign
                    an-seeid = -1 an-recid = -1 an-seerec = ? v-num = 0.
    
                for each pendenci where pendenci.aceita = yes 
                                    and pendenci.resolvido = yes no-lock :
                    v-num = v-num + 1.
                end.                        
                disp v-num with frame f-total. 
                  
                {anbrowse.i
                    &File   = pendencia
                    &CField = pendencia.funemi
                    &Ofield = " func.funape pendencia.assunto
                       pendencia.dtpreten pendencia.dtresol pendenci.solic
                       sofunc.funape when avail sofunc " 
                    &Where = "pendencia.aceita = yes and
                              pendencia.resolvido = yes"
                    &NonCharacter = /*
                    &Aftfnd = "
                  find first func where func.funcod = pendencia.funemi no-lock.
                      vhora = string(pendencia.hrmens,""hh:mm:ss""). 
     find first sofunc where sofunc.funcod = pendencia.solic no-lock no-error." 
                    &AftSelect1 =  " 
                   disp pendencia.mens1[1] pendencia.mens1[2] pendencia.mens1[3]
                   pendencia.mens1[4] pendencia.mens1[5] pendencia.mens1[6] 
                   pendencia.mens1[7] pendencia.mens1[8] pendencia.mens1[9] 
                   pendencia.mens1[10] pendencia.mens1[11] pendencia.mens1[12] 
                   pendencia.mens1[13] pendencia.mens1[14] pendencia.mens1[15] 
                    with frame f-linha centered
                        1 down no-labels title ""PENDENCIA"" row 5.
                    an-seeid = -1. clear frame f-linha all.
                    hide frame f-linha. next keys-loop.  " 
                    &Otherkeys1 = "emipend.ok"
                    &LockType = "use-index resolv no-lock" 
                    &Form = " frame f-resol "
                }.  
                clear frame f-receb all. hide frame f-receb.
                clear frame f-altera3 all. hide frame f-altera3.  
                clear frame f-total all. hide frame f-total.
            end.  
        end.       
    end.
