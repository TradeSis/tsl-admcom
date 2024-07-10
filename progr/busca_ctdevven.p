    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    def var vqtd as int.
    if vtabela = "CTDEVVEN"
    then do:
        for each admloja.ctdevven where admloja.ctdevven.dtexp >= vdata:
        do transaction:
            find first adm.ctdevven where 
                       adm.ctdevven.movtdc = admloja.ctdevven.movtdc and
                       adm.ctdevven.etbcod = admloja.ctdevven.etbcod and
                       adm.ctdevven.placod = admloja.ctdevven.placod  and
                    adm.ctdevven.movtdc-ori = admloja.ctdevven.movtdc-ori and
                    adm.ctdevven.etbcod-ori = admloja.ctdevven.etbcod-ori and
                    adm.ctdevven.placod-ori = admloja.ctdevven.placod-ori and
                    adm.ctdevven.movtdc-ven = admloja.ctdevven.movtdc-ven and
                    adm.ctdevven.etbcod-ven = admloja.ctdevven.etbcod-ven and
                    adm.ctdevven.placod-ven = admloja.ctdevven.placod-ven
                       no-error.
            if not avail adm.ctdevven
            then do:
                create adm.ctdevven.
            end. 
            buffer-copy admloja.ctdevven to adm.ctdevven.
            adm.ctdevven.exportado = yes.
            admloja.ctdevven.exportado = yes.
            find current adm.ctdevven no-lock no-error.
            vqtd = vqtd + 1.
            /*
            message admloja.ctdevven.pladat
                    admloja.ctdevven.exportado
                    adm.ctdevven.exportado.
            pause 0.
            */         
        end.
        end.
    end. 
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
