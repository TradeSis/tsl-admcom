{admcab.i}

def var vacao1 as int.
def var vacao2 as int.

def var vaux as char format "x(40)".
def var vvalor as dec format ">>>9.99".
def var vperc as dec format ">>9.99 %".

def var vtipo as char format "x(43)" extent 3
        initial [" 1. Gerar Bonus - Percentual de desconto ",
                 " 2. Gerar Bonus - Valor em dinheiro      ",
                 " 3. Gerar Promocao - DINHEIRO NA MAO     "].

do on error undo:
    vacao1 = 0.
    vacao2 = 0.
    
    update vacao1 label "Acao Ini" format ">>>>>9"
           vacao2 label "Acao Fin" format ">>>>>9"
           with frame f-gera side-labels width 80.

    if vacao1 = 0 or
       vacao2 = 0
    then do:
        message "Informe a Faixa das Acoes para gerar os Bonus".
        undo.
    end.
    
end.
def var vindex as int.
disp skip(1)
     vtipo[1] skip
     vtipo[2] SKIP
     VTIPO[3]
     skip(1)
     with frame f-tipo centered no-labels title " Tipo de Bonus ".

choose field vtipo auto-return with frame f-tipo.

hide frame f-tipo no-pause.

vindex = frame-index.

def var svisivel as log format "Sim/Nao" init no.
message "Tornar Bonus visivel na venda?" update svisivel.

if vindex = 1
then do:
    vaux = "Gerando Bonus - Percentual de desconto".
    disp vaux no-label with frame f-gera.

    do on error undo:
        
        update skip 
               vperc label "Percentual de desconto"
               with frame f-gera2 centered side-labels.
               
        if vperc = 0 
        then do:
            message "Informe o Percentual de desconto dos Bonus.".
            undo.
        end.
        
    end.
    
    sresp = no.
    message "Confirma a geracao dos Bonus - Percentual de desconto ?" 
            update sresp.
    if sresp
    then do:
    
        for each acao where acao.acaocod >= vacao1
                        and acao.acaocod <= vacao2 no-lock: 
    
            for each acao-cli where 
                     acao-cli.acaocod = acao.acaocod no-lock:
            
                    create titulo.
                    assign titulo.empcod   = 19
                           titulo.modcod   = "BON"
                           titulo.clifor   = acao-cli.clicod
                           titulo.titnum   = string(acao-cli.clicod)
                                           + string(acao-cli.acaocod,"999999")
                           titulo.titpar   = 1
                           titulo.titnat   = yes
                           titulo.etbcod   = 
int(substring(string(acao-cli.clicod), length(string(acao-cli.clicod)) - 1, 2))
                           titulo.titdtemi = acao.dtini
                           titulo.titdtven = acao.dtfin
                           titulo.titvlcob = vperc
                           titulo.titsit   = "LIB"
                           titulo.moecod   = "PER"
                           titulo.titobs[1] = string(acao-cli.acaocod).
                if not svisivel
                then  titulo.titagepag = "invisivel".     
                
            end.    
        
        end.

        hide message no-pause.
        message "Os Bonus foram gerados com sucesso! Tecle Enter.".
        pause no-message.

    end.
    else leave.
    
end.
else 
if vindex = 2
then do:
    vaux = "Gerando Bonus - Valor em dinheiro".
    disp vaux no-label with frame f-gera.

    do on error undo:
        
        update skip
               vvalor label "Valor em dinheiro"
               with frame f-gera3 centered side-labels.
        if vvalor = 0 
        then do:
            message "Informe o Valor dos Bonus.".
            undo.
        end.
        
    end.
               
    sresp = no.
    message "Confirma a geracao dos Bonus - Valor em Dinheiro ?"
            update sresp.
    if sresp
    then do:
    
        for each acao where acao.acaocod >= vacao1
                        and acao.acaocod <= vacao2 no-lock: 
        
            for each acao-cli where 
                     acao-cli.acaocod = acao.acaocod no-lock:
            
                    find titulo where titulo.empcod = 19 and
                                      titulo.titnat = yes and
                                      titulo.modcod = "BON" and
                                      titulo.etbcod = 
int(substring(string(acao-cli.clicod), length(string(acao-cli.clicod)) - 1, 2))
                                      and
                                      titulo.clifor = acao-cli.clicod and
                                      titulo.titnum  = string(acao-cli.clicod)
                                           + string(acao-cli.acaocod,"999999")
                                   and titulo.titpar = 1
                                   no-error.
                    if not avail titulo
                    then   create titulo.
                    assign titulo.empcod   = 19
                           titulo.modcod   = "BON"
                           titulo.clifor   = acao-cli.clicod
                           titulo.titnum   = string(acao-cli.clicod)
                                           + string(acao-cli.acaocod,"999999")
                           titulo.titpar   = 1
                           titulo.titnat   = yes
                           titulo.etbcod   =
int(substring(string(acao-cli.clicod), length(string(acao-cli.clicod)) - 1, 2))
                           titulo.titdtemi = acao.dtini
                           titulo.titdtven = acao.dtfin
                           titulo.titvlcob = vvalor
                           titulo.titsit   = "LIB"
                           titulo.moecod   = "BON"
                           titulo.titobs[1] = string(acao-cli.acaocod)
                           .
                 if not svisivel
                 then titulo.titagepag = "invisivel".
                 
            end.    
            
        end.
        hide message no-pause.
        message "Os Bonus foram gerados com sucesso! Tecle Enter.".
        pause no-message.
    end.
    else leave.
end.
else 
if vindex = 3
then do:
    vaux = "Gerando " + vtipo[frame-index].

    sresp = no.
    message "Confirma " vtipo[frame-index] " ?"
            update sresp.
    if sresp
    then do:
         
         disp vaux no-label with frame f-gera.

         for each acao where acao.acaocod >= vacao1
                        and acao.acaocod <= vacao2 no-lock: 
        
            for each acao-cli where 
                     acao-cli.acaocod = acao.acaocod no-lock:
            
                    find titulo where titulo.empcod = 19 and
                                      titulo.titnat = yes and
                                      titulo.modcod = "BON" and
                                      titulo.etbcod = 
int(substring(string(acao-cli.clicod), length(string(acao-cli.clicod)) - 1, 2))
                                      and
                                      titulo.clifor = acao-cli.clicod and
                                      titulo.titnum  = string(acao-cli.clicod)
                                           + string(acao-cli.acaocod,"999999")
                                   and titulo.titpar = 1
                                   no-error.
                    if not avail titulo
                    then   create titulo.

                    assign titulo.empcod   = 19
                           titulo.modcod   = "BON"
                           titulo.clifor   = acao-cli.clicod
                           titulo.titnum   = string(acao-cli.clicod)
                                           + string(acao-cli.acaocod,"999999")
                           titulo.titpar   = 1
                           titulo.titnat   = yes
                           titulo.etbcod   =
int(substring(string(acao-cli.clicod), length(string(acao-cli.clicod)) - 1, 2))
                           titulo.titdtemi = acao.dtini
                           titulo.titdtven = acao.dtini
                           titulo.titvlcob = .99
                           titulo.titsit   = "LIB"
                           titulo.moecod   = "PDM"
                           titulo.titobs[1] = string(acao-cli.acaocod)
                           .

                if not svisivel
                then titulo.titagepag = "invisivel".
                
             end.    
            
        end.
        hide message no-pause.
        message "Promocao gerada com sucesso! Tecle Enter.".
        pause no-message.
    end.
    else leave.
end.

