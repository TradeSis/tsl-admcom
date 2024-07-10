{admcab.i}

def input parameter par-reclotcre  as recid.

def var vcpfcnpj as log.
def var varquivo as char format "x(20)".
def var vct      as int.

    find lotcre where recid(lotcre) = par-reclotcre no-lock.
    find lotcretp of lotcre no-lock.
    
    for each lotcreag of lotcre exclusive.
        
        lotcreag.ltvalida = "".
        
        /* 
            Verifica dados do cliente
        */

        vcpfcnpj = yes.
        find forne where forne.forcod = lotcreag.clfcod no-lock.
        if dec(forne.forcgc) = 0
        then vcpfcnpj = no.
        /*lotcreag.ltvalida = lotcreag.ltvalida + "CNPJ ".*/
        if length(trim(forne.forcgc)) > 14 or
           length(trim(forne.forcgc)) < 11
        then vcpfcnpj = no.
        /*lotcreag.ltvalida = lotcreag.ltvalida + "CNPJ ".*/
           
        for each lotcretit of lotcreag.
            lotcretit.ltvalidacao = "".
            find titulo2 where titulo2.empcod = wempre.empcod
                           and titulo2.titnat = lotcretp.titnat
                           and titulo2.modcod = lotcretit.modcod
                           and titulo2.etbcod = lotcretit.etbcod
                           and titulo2.clifor = lotcretit.clfcod
                           and titulo2.titnum = lotcretit.titnum
                           and titulo2.titpar = lotcretit.titpar
                         no-lock no-error.
            
            if avail titulo2 and
                vcpfcnpj = no and
                acha("CGCCPF",titulo2.char1) <> ? and
                acha("CGCCPF",titulo2.char1) <> "" and
                length(acha("CGCCPF",titulo2.char1)) <= 14 and
                length(acha("CGCCPF",titulo2.char1)) >= 11
            then vcpfcnpj = yes.    
                           
            if avail titulo2 and
               vcpfcnpj = no and
               titulo2.tippag = 2 and
               titulo2.tipdoc = 5
            then vcpfcnpj = yes.
             
            if not avail titulo2 or
               (titulo2.codbarras = "" and titulo2.modpag = 31)
            then assign
                    lotcreag.ltvalidacao  = "Cod.Barras"
                    lotcretit.ltvalidacao = "Cod.Barras".
            else
                lotcretit.numero = titulo2.codbarras.
        end.
        /*
        message vcpfcnpj par-reclotcre. pause.
        */
        if not vcpfcnpj 
        then lotcreag.ltvalida = lotcreag.ltvalida + "CNPJ ". 
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

    varquivo = "../relat/ltbanrival." + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""LTBRASILVAL""
        &Nom-Sis   = """ADMCOM"""
        &Tit-Rel   = "lotcretp.ltcretnom + "" - LOTE "" + 
                      string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
        &Width     = "96"
        &Form      = "frame f-cabcab"}

    for each lotcreag of lotcre where lotcreag.ltvalida <> "" no-lock.
        find forne where forne.forcod = lotcreag.clfcod no-lock.
        disp lotcreag.clfcod
             forne.fornom
             forne.forcgc
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
