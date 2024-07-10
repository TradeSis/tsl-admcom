/* Validacao Lote Access */
{admcab.i}

def input parameter par-reclotcre  as recid.

def var varquivo as char format "x(20)".
def var vct      as int.

    find lotcre where recid(lotcre) = par-reclotcre no-lock.
    find lotcretp of lotcre no-lock.
    
    for each lotcreag of lotcre exclusive.
        lotcreag.ltvalida = "".
        
        /* 
            Verifica dados do cliente
        */
        
        find clien where clien.clicod = lotcreag.clfcod no-lock no-error.
        
        
        /* Verifica CPF/CNPJ em branco */
        /*
        if dec(clien.ciccgc) = 0
        then lotcreag.ltvalida = lotcreag.ltvalida + "CNPJ ".
        */
        
        for each lotcretit of lotcreag.
            /*
            find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock.
            if titulo.cobcod = 12 /*GLOBAL - Titulo em outra assessoria*/
            then lotcreag.ltvalida = lotcreag.ltvalida + "GLOBAL ".
            */
            lotcretit.ltvalidacao = "".
        end.

        if lotcreag.ltvalida <> ""
        then vct = vct + 1.
    end.
    do on error undo.
        find lotcre where recid(lotcre) = par-reclotcre exclusive.
        assign
            lotcre.ltdtvalida = today
            lotcre.lthrvalida = time
            lotcre.ltfnvalida = sfuncod.
    end.
    find current lotcre no-lock.

if vct = 0
then message "Lote validado com sucesso" view-as alert-box.
else do.
    run message.p (input-output sresp,
                   " Lote validado com " + string(vct) +  
                   " erros. Imprimir relatorio ?",
                   " !! Validacao do Lote !!").
    if sresp
    then run imprime.
end.


procedure imprime.

    varquivo = "../relat/ltaccessval." + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""LTACCESSVAL""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = "lotcretp.ltcretnom + "" - LOTE "" + 
                      string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
        &Width     = "96"
        &Form      = "frame f-cabcab"}

    for each lotcreag of lotcre where lotcreag.ltvalida <> "" no-lock.
        find clien where clien.clicod = lotcreag.clfcod no-lock no-error.
        if avail clien then
        disp lotcreag.clfcod
             clien.clinom
             clien.ciccgc
             lotcreag.ltvalida
             with frame f-lin down width 96 no-box.
    end.

    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
 
end procedure.

