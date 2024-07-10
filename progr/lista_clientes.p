{admcab.i}


def var vcha-filial-ini as character.
def var vcha-filial-fim as character. 

def var vcha-acao-ini   as character.
def var vcha-acao-fim   as character.

def var vint-opsel      as integer.

def var vcha-tipsel     as character format "x(10)"
        extent 2 initial ["   Filial", "   Acao "].

def var varquivo        as character.
def var vtit-rel        as character.
def var vfilial-aux     as integer.

def temp-table tt-cliente no-undo
    field clicod as integer format ">>>>>>>>>>>9"
    field nome   as character format "x(45)"
    field email  as character format "x(45)"
    index idx01 clicod.


form
    vcha-filial-ini format "x(5)" label "Filial"
    " a "
    vcha-filial-fim format "x(5)" no-label skip
       with frame f-01 side-label centered row 10 title " Listagem ".

form    
    vcha-acao-ini   format "x(5)" label "Ação "
    " a "
    vcha-acao-fim   format "x(5)" no-label skip
        with frame f-02 side-label centered row 10 title " Listagem ".

assign vcha-filial-ini = ""
       vcha-filial-fim = ""
       vcha-acao-ini   = ""
       vcha-acao-fim   = "".

disp " " skip
     vcha-tipsel no-label with frame f2 centered color white/cyan
            title "Selecione um filtro " row 5.
choose field vcha-tipsel with frame f2.
assign vint-opsel = frame-index.

if vint-opsel = 1
then do:

    bloco_filial:
    do on error undo,retry:
        update vcha-filial-ini
               vcha-filial-fim
                 with frame f-01.
                 
        if integer(vcha-filial-ini) > integer(vcha-filial-fim)
        then do:
        
            message "A Filhal inicial precisa ser menor que a final.".
            undo,retry.
            
        end.
        leave bloco_filial.
        
    end.
     
end.
else do:
       
    update vcha-acao-ini 
           vcha-acao-fim 
             with frame f-02.

end.

message "Gerando relatório... Por favor aguarde...".

if vint-opsel = 1
then do:

    for each rfvcli where rfvcli.setor = 0
                      and rfvcli.etbcod >= integer(vcha-filial-ini)
                      and rfvcli.etbcod <= integer(vcha-filial-fim) no-lock,
    
        first clien where clien.clicod = rfvcli.clicod  no-lock:

      /*
        last plani where plani.movtdc = 5
                     and plani.desti = clien.clicod use-index plasai  no-lock:
        
        if plani.emite < integer(vcha-filial-ini)
            or plani.emite > integer(vcha-filial-fim)
        then next.      
      */
      
        run p-comum.      

    end.
    
end.
else do:

    for each acao where acao.acaocod >= integer(vcha-acao-ini) 
                    and acao.acaocod <= integer(vcha-acao-fim) no-lock,
    
        each acao-cli where acao-cli.acaocod = acao.acaocod no-lock,
         
        first clien where clien.clicod = acao-cli.clicod no-lock:
         
        run p-comum.
        
    end.

end.

run p-display.

procedure p-display:

    if vint-opsel = 1
    then assign vtit-rel = "FILIAL " +  string(vcha-filial-ini)
                                + " A " + string(vcha-filial-fim).                                
    else assign vtit-rel = "ACAO " + string(vcha-acao-ini)
                                + " A " + string(vcha-acao-fim).
    
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/listmail" + string(time).
    else varquivo = "l:\relat\listmail" + string(time).
                
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "110"
        &Page-Line = "0"
        &Nom-Rel   = ""lista_clientes""
        &Nom-Sis   = """SISTEMA DE CRM"""
        &Tit-Rel   = "vtit-rel"
        &Width     = "110"
        &Form      = "frame f-cabcab"}
                                       
    for each tt-cliente where tt-cliente.clicod > 0 no-lock use-index idx01:
    
        display tt-cliente.clicod column-label "CliCod"
                tt-cliente.nome   column-label "Nome"
                tt-cliente.email  column-label "E-Mail" skip
                with frame f-21 width 160 down no-box.
    
    end. 

    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
       {mrod.i}.
    end.

    message "Arquivo gerado com sucesso em: " varquivo.                        
                            
end procedure.


procedure p-comum:

    def var vmail-ok as logical.
    
    assign vmail-ok = yes.

    run pfval_mail2.p (input  clien.zona,
                       output vmail-ok) no-error.

    if vmail-ok and clien.zona <> ?
    then do:

        create tt-cliente.
        assign tt-cliente.clicod = clien.clicod
               tt-cliente.nome   = clien.clinom
               tt-cliente.email  = clien.zona.  
               
    end.
     
end procedure.


