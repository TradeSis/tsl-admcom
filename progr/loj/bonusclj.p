{admcab.i}
def var vclicod like clien.clicod.
update vclicod label "Cliente".

find clien where clien.clicod = vclicod no-lock.
disp clien.clinom no-label with side-label width 80.

def var v-conecta as log.
def var vmens as char.
def var v-arquivo as char.
def var dsresp as log.
def var vdtvenbr as char format "x(15)".
def var vdtvenbd as char format "x(15)".
def var vdtvenbp as char format "x(15)".
def var vdtvenba as char format "x(15)".

    def var vaberto-rea like titulo.titvlcob.
    def var vaberto-per as   dec format "999.99%".
    def var vaberto-pro like titulo.titvlcob.   
    def var vutilizado like titulo.titvlcob.
    def var vtembon as char.
    def var vaniver as log.
    def var vacao as char extent 10.
    def var vi as int.
    
    vdtvenbd    = "".
    vdtvenbr    = "".
    vdtvenbp    = "".
    vdtvenba    = "".
    
    def var val-aniver as char.
    vaniver = no.    
    vi = 10.
/***
    find first titulo where titulo.clifor = vclicod
                           and titulo.empcod = 19
                           and titulo.titnat = yes 
                           and titulo.modcod = "BON" 
                           and  no-lock no-error.
    if avail titulo
    then do:
***/
        for each titulo where titulo.clifor = vclicod
                             and titulo.empcod = 19
                             and titulo.titnat = yes 
                             and titulo.modcod = "BON" 
                        no-lock:
            if titulo.titagepag = "invisivel"
            then next.
            if titulo.titsit = "LIB"
            then do:  
                if titulo.moecod = "PER"
                then do:
                    vaberto-per = vaberto-per + titulo.titvlcob.
                    if titulo.titdtven <> ?
                    then vdtvenbd = " VENC: " 
                                + string(titulo.titdtven).
                    else vdtvenbd = "".
                    vacao[1] = titulo.titobs[1] + "-" +
                               titulo.titchepag.
                    vi = 1.
                end.    
                else do: 
                    if titulo.moecod = "PRO"
                    then do:
                         vaberto-pro = vaberto-pro + titulo.titvlcob.
                         if titulo.titdtven <> ?
                         then vdtvenbp = " VENC: " 
                                    + string(titulo.titdtven).
                         else vdtvenbp = "".
                          vacao[2] = titulo.titobs[1] + "-" +
                               titulo.titchepag.
                         vi = 2.
                    end.
                    else do:
                         if titulo.moecod = "PDM"
                         then.
                         else do:
                            vaberto-rea = vaberto-rea + titulo.titvlcob.
                            if titulo.titdtven <> ?
                            then vdtvenbr = " VENC: " 
                                      + string(titulo.titdtven).
                            else vdtvenbr = "".
                             vacao[3] = titulo.titobs[1] + "-" +
                               titulo.titchepag.
                            vi = 3.
                         end.       
                    end.     
                end.  
            end.
            else if titulo.moecod <> "PDM"
            then assign
                    vutilizado = vutilizado + titulo.titvlpag.
            if titulo.moecod = "PDM" and
               month(titulo.titdtven) = month(today) and
               year(titulo.titdtven) = year(today)
            then vaniver = yes.   
        end. 
        
        vtembon = if vaberto-rea <> 0 or 
                     vaberto-pro <> 0 or 
                     vaberto-per <> 0
                  then "  "
                  else "       CLIENTE NAO POSSUI CARTAO BONUS. ".
        
        if vaniver = yes
        then val-aniver =  "DINHEIRO NA MAO" .
        else val-aniver =  "NAO".
 
        if vaberto-rea <> 0 or 
           vaberto-pro <> 0 or 
           vaberto-per <> 0
        then
            run msg2.p (input-output dsresp,
                    input "PARABENS " + clien.clinom + 
                          " VOCE ESTA PARTICIPANDO DA ACAO " + 
                          string(vacao[vi],"x(60)") + 
                          "!" + 
                          "! BONUS  DISPONIVEL: "
                          +
                          "!          EM REAIS:  "  +
                                    string(vaberto-rea,">>,>>9.99") + "  " +
                          vdtvenbr
                          +
                          "!          DESCONTO:  "  +
                                    string(vaberto-per,">,>>9.99%") + "  " +
                          vdtvenbd
                          +
                          "!          PRODUTO.:  "  +
                                    string(vaberto-pro,">>,>>9.99") + "  " +
                          vdtvenbp +
                          /*
                          "! BONUS JA UTILIZADOS: R$ "  + 
                                    string(vutilizado,">>,>>9.99") + "!" +
                            */
                          "!" +
                          "! ANIVERSARIO......: " + val-aniver 
                          + "!    " 
                          + "!    " ,

                    input " *** DIGA AO CLIENTE *** ",
                    input "     OK").
            else
                run msg2.p (input-output dsresp,
                    input  vtembon +
                          "!" + "!" + 
                          "!        BONUS JA UTILIZADOS: R$ "  + 
                                    string(vutilizado,">>,>>9.99") + "!" +
                            
                          "!" +
                          "!        ANIVERSARIO......: " + val-aniver 
                          + "!    " 
                          + "!    " ,

                    input " ***   A T E N C A O   *** ",
                    input "     OK").
 
/***
    end.
***/
