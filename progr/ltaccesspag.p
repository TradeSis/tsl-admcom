/* Programa de selecao Lote Access pagamentos e baixas */
/*      cerselinc.p     */
{admcab.i}

def input-output parameter par-lotcre as recid.
def input parameter par-lotcretp as recid.
def input parameter par-tipo     as char.

def temp-table tt-estab
       field etbcod as int.

def var vdtini      as date format "99/99/9999".
def var vdtfim      as date format "99/99/9999".
def var vdata       as date.
def var vselecao    as char.
def var vetbcod     like estab.etbcod.
def var varquivo as char.
def buffer bestab for estab.
def var vexiste as log.

form vetbcod label "Filial" colon 25 with frame f1 side-label width 80.

find lotcretp where recid(lotcretp) = par-lotcretp no-lock.

for each tt-estab.
    delete tt-estab.
end.

if par-tipo = " selecao "
then do.

    {selestab.i vetbcod f1}.
    
    do on error undo, retry:
          update vdtini to 34  label "Data Inicial"
                 vdtfim label "Data Final" with frame f1.
          if  vdtini > vdtfim
          then do:
                message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
    end.
    vselecao = string(vdtini) + " a " + string(vdtfim).
    
    if vetbcod > 0
    then do:
        for each bestab where bestab.etbcod = vetbcod no-lock:
            create tt-estab.
            buffer-copy bestab to tt-estab.
        end.    
    end.
    else do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        if not avail tt-lj
        then  for each bestab no-lock:
                create tt-estab.
                buffer-copy bestab to tt-estab.
        end. 
        else for each tt-lj where tt-lj.etbcod > 0 no-lock:
                create tt-estab.
                buffer-copy tt-lj to tt-estab.
        end.
    end.

 

    for each tt-estab no-lock.
    
        disp "Estabelecimento :" estab.etbcod no-label
        with frame f4 row 11 centered.
        pause 0.

        for each lotcretit where lotcretp.titnat = no and
                            lotcretit.modcod = "CRE" and
                            lotcretit.etbcod = tt-estab.etbcod and
                            lotcretit.spcretorno = "acionamento de cobranca"                             no-lock.
                                          
            /*acionamento de cobranca filtra apenas os titulos que tiveram                  retorno da access*/ 
                            
                            
            find titulo where titulo.empcod = wempre.empcod
                        and titulo.titnum = lotcretit.titnum
                        and titulo.titnat = lotcretp.titnat
                        and titulo.modcod = lotcretit.modcod
                        and titulo.etbcod = lotcretit.etbcod
                        and titulo.clifor = lotcretit.clfcod
                        and titulo.titpar = lotcretit.titpar
                        and titulo.titdtpag >= vdtini
                        and titulo.titdtpag <= vdtfim
                        and titulo.cobcod = 11 /*ACCESS*/
                        no-lock no-error. 

            if not avail titulo then next. 
                   
            /************************************************************/                 /*Verifica se o titulo esta em algum outro lote de pagamento*/
            /************************************************************/
            /*
            def buffer blotcretp for lotcretp.
            def buffer blotcre   for lotcre.
            def buffer blotcretit for lotcretit.
            
            find blotcretp where blotcretp.ltcretcod = "ACCESS_P" no-lock.
            for each blotcre of blotcretp no-lock.
            
                for each blotcretit of blotcre no-lock.
                    if titulo.titnum = lotcretit.titnum and
                       titulo.modcod = lotcretit.modcod and
                       titulo.titpar = lotcretit.titpar 
                    then do:
                        vexiste = yes.
                        message titulo.titnum + "/" titulo.titpar
                        " existe em outro lote".
                    end.   
                                    
                end.
            
            end.
                               
            if vexiste = yes then next.                   
            
            */
            /*************************************************************/
            if par-lotcre = ?
            then do.
                run lotcria.p (input recid(lotcretp),
                           output par-lotcre).
                do on error undo.
                    find lotcre where recid(lotcre) = par-lotcre exclusive.
                    lotcre.ltselecao = vselecao.
                end.
                find current lotcre no-lock.
            end.

            run lotagcria.p (input par-lotcre,
                             input recid(titulo)).
            run lottitc.p   (input par-lotcre,
                             input recid(titulo),
                             ?,
                             "" /* por cliente, sitcli.titnum = "" */).
        end. /*lotcretit*/
        
        if connected ("d") then disconnect d.
        run conecta_d.p.
        if connected ("d")
        then do:
            run ltaccesspglp.p (input-output par-lotcre,
                                input tt-estab.etbcod,
                                input vdtini,
                                input vdtfim).
            disconnect d.
        end.                     

    end. /*tt-estab*/
    
    if par-lotcre <> ?
    then run value(lotcretp.valida + ".p") (input par-lotcre).
end.
