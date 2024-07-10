/* helio 17032022 ajuste pdf */
/* helio 06012022 Chamado 99814 - Programa reimpressão contratos */ 

{admcab.i}

def var vcontnum like fin.contrato.contnum.

repeat:

    update vcontnum format ">>>>>>>>>9"
            at 4 with frame f-1 1 down side-label.

    find contrato where  contrato.contnum = vcontnum no-lock no-error.
    if not avail contrato
    then do:
        bell.
        message color red/with
        "Contrato não encontrado."
        view-as alert-box.
        next.
    end.
    find clien where clien.clicod = contrato.clicod  no-lock no-error.
    disp clien.clicod at 1
         clien.clinom no-label with frame f-1.

    sresp = no.

        if contrato.tpcontrato = "N" or contrato.modcod = "CPN" /*contrato.crecod = 500*/
        then run crd/contratoreimp-novacaoupd.p (input recid(contrato),"epson-contratos").
        else run crd/contratoreimpupd.p         (input recid(contrato),"epson-contratos").
end.