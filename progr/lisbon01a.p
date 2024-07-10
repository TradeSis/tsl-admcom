{admcab.i}

def var vcont as int.
def var vmes as int format "99".
def var vsit as char format "XXX".
def var vtitulo as char.
def var varquivo as char.
def var vtotcli as int.
def var vtotbon as int.
def var vacaocod like acao.acaocod.

def temp-table tt-digita    no-undo
    field acaocod   like acao.acaocod.

repeat:

    assign vmes    = 0
           vsit    = ""
           vtotcli = 0
           vtotbon = 0.
         
    repeat:
           
        update vacaocod label "Acao....."  
               help "Informe 0 = Geral ou informe as acoes e F4 para Confirmar"
               with frame f-dados 
                    centered side-labels overlay row 3
                    width 80.
                                                            
        if input vacaocod <> 0
        then do:                                                    
            find tt-digita where 
                 tt-digita.acaocod = vacaocod no-error.
            if not avail tt-digita
            then do:
                create tt-digita.
                assign tt-digita.acaocod = vacaocod.
            end.
        end.
        else do:
                for each acao no-lock:
                
                    create tt-digita.
                    assign tt-digita.acaocod = acao.acaocod.

                end.
        end.
        
        clear frame f-digita all.
        hide frame f-digita no-pause.

        if input vacaocod <> 0
        then do:
            for each tt-digita:
                disp tt-digita.acaocod column-label "Acao"
                     with frame f-digita centered 8 down row 10
                                title " Acoes Selecionadas ".
                down with frame f-digita.
            end.
        end.
    end.

hide frame f-digita no-pause.

/*
vacaocod = "".
for each tt-nota:
    vacaocod = vacaocod + tt-digita.acaocod + "/".
end.

vacaocod = "".
disp 
     vacaocod no-label
     with frame f-dados.
*/ 

    find first tt-digita no-lock no-error.
    if avail tt-digita
    then do:
            assign vacaocod:screen-value in frame f-dados = "".   
    end.      
           
    update vmes label "Mes......"
           skip
           vsit label "Situacao."
           "(PAG = Utilizado  LIB = Em Aberto  EXC = Nao Utilizado)"
           with frame f-dados-n width 80 side-labels.

    if vsit <> "" and vsit <> "PAG" and vsit <> "LIB" and vsit <> "EXC"
    then undo, retry.
    
    if vsit = "PAG"
    then vtitulo = "UTILIZADOS".
    if vsit = "LIB"
    then vtitulo = "EM ABERTO".
    if vsit = "EXC"
    then vtitulo = "NAO UTILIZADOS".
    
    if opsys = "UNIX"
    then varquivo = "../relat/lisbon01." + string(time).
    else varquivo = "..\relat\lisbon01." + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""lisbon01""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM DE BONUS - "" 
                   + vtitulo
                   + "" - MES: ""
                   + string(vmes) "
        &Width     = "130"
        &Form      = "frame f-cabcab"}

    for each titulo where titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "BON" no-lock,
        first clien where clien.clicod = titulo.clifor no-lock
                break by day(clien.dtnasc):


        /*
        if vacaocod <> 0
        then
          if vacaocod <> int(substring(titulo.titnum,length(titulo.titnum) - 3))
          then next.
        */
      
      find tt-digita where
           tt-digita.acaocod = 
           int(substring(titulo.titnum,length(titulo.titnum) - 3))
           no-lock no-error.
      if avail tt-digita
      then do:
        
        if vsit <> ""
        then
            if titulo.titsit <> vsit
            then next.
        
        if vmes <> 0
        then
            if month(titulo.titdtemi) <> vmes
            then next.
    
        
        vtotcli = vtotcli + 1.
        vtotbon = vtotbon + titulo.titvlcob.
        
        disp titulo.clifor                    column-label "Codigo"
             clien.clinom    when avail clien column-label "Cliente"
             titulo.titvlcob                  column-label "Valor!Bonus"
             clien.fone                       column-label "Fone"
             clien.fax                        column-label "Celular"
             clien.dtnasc                     column-label "Dt.nasc"
                        format "99/99/9999"
             with frame f-mostra width 130 down.
        down with frame f-mostra.

      end.

    end.
    
    put skip(1)
        "QUANTIDADE DE BONUS: " vtotcli
        skip
        "TOTAL DE BONUS.....: " vtotbon.
        
    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.

end.
