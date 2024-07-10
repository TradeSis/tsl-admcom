{admcab.i}

def var vplacod like plani.placod.
def var vmovseq like movcon.movseq.
def buffer bplacon for placon.
def buffer bmovcon for movcon.
def buffer bforne for forne.
def var vpar as int.
def var vetbcgc as char format "99.999.999/9999-99".
def var vrec as recid.
def var vprocod like produ.procod.

def var varqret as char.
    if opsys = "UNIX"
    then.
    else do:
        varqret = sel-arq01().
    end. 
    update varqret format "x(60)" label "Arquivo"
            with frame f-ret 1 down overlay
            side-label centered color message row 10.
    
    if search(varqret) = ?
    then do:
        message color red/with
        "Arquivo nao encontrado."
        view-as alert-box.
        undo.
    end.
    def var sconf as log format "Sim/Nao".
    sconf = no.
    message "Confirma importar arquivo ? " update sconf.
    if not sconf then undo.

    def var varquivo1 as char.
    varquivo1 = varqret + string(time).
    if opsys = "UNIX"
    then unix silent value("quoter -d % " +  varqret  + " > " + varquivo1).
    else dos   
        value("c:\dlc\bin\quoter -d % " +  varqret  + " > " + varquivo1).

    def var vlinha as char.
    def var vi as int.
    def var vj as int.
    def var vcoluna as char extent 50.
    input from value(varquivo1).
    repeat:
        import vlinha.
        do vi = 1 to num-entries(vlinha,";"):
        end.
        vj = 0.
        vcoluna = "".
        
        do vj = 1 to vi - 1.
            vcoluna[vj] = entry(vj,vlinha,";").    
        end.
        if vcoluna[1] = "H"
        then do:
            find first forne where forne.forcgc = vcoluna[2]
                    no-lock no-error.
            find first bforne where bforne.forcgc = vcoluna[23]
                    no-lock no-error.
            vetbcgc = string(vcoluna[6],"99.999.999/9999-99").
            find first estab where estab.etbcgc = vetbcgc
                                no-lock no-error.
            find placon where placon.movtdc = 4 and
                              placon.etbcod = estab.etbcod and
                              placon.emite = forne.forcod and
                              placon.serie = "EL" and
                              placon.numero = int(vcoluna[3])
                              no-error.
            if not avail placon
            then do:                  
                find last bplacon  where
                      bplacon.etbcod = estab.etbcod
                      no-lock no-error.
            
                if avail bplacon
                then vplacod = bplacon.placod + 1.
                else vplacod = estab.etbcod * 1000000.
            
                vcoluna[4] = entry(1,vcoluna[4],".") +
                         entry(2,vcoluna[4],".").
                create placon.
                assign
                    placon.movtdc = 4
                    placon.etbcod = estab.etbcod
                    placon.emite = forne.forcod
                    placon.serie = "EL"
                    placon.numero = int(vcoluna[3])
                    placon.placod = vplacod
                    placon.desti = estab.etbcod
                    placon.opccod = int(vcoluna[4])
                     .
            end.
            assign                     
                placon.pladat = date(vcoluna[5])
                placon.bicms  = int(vcoluna[7]) / 100
                placon.icms   = int(vcoluna[8]) / 100
                placon.bsubst = int(vcoluna[9]) / 100
                placon.icmssubst  = int(vcoluna[10]) / 100
                placon.protot     = int(vcoluna[11]) / 100
                placon.frete      = int(vcoluna[12]) / 100
                placon.seguro     = int(vcoluna[13]) / 100
                placon.descprod   = int(vcoluna[14]) / 100
                placon.acfprod    = int(vcoluna[15]) / 100
                placon.desacess   = int(vcoluna[16]) / 100
                placon.ipi        = int(vcoluna[17]) / 100
                placon.platot     = int(vcoluna[18]) / 100
                placon.nottran    = if avail bforne
                                    then bforne.forcod  else 0
                /**
                placon.           = vcoluna[19]
                placon.tipofrete  = vcoluna[20]
                placon.placa      = vcoluna[21]
                placon.ufveiculo  = vcoluna[22]
                placon.cnpjtransp = vcoluna[23]
                placon.endtransp  = vcoluna[24]
                placon.munictransp = vcoluna[25]
                placon.uftransp    = vcoluna[26]
                placon.inscesttransp = vcoluna[27]
                placon.qtdnota = vcoluna[28]
                placon.especie = vcoluna[29]
                placon.marca = vcoluna[30]
                placon.numero = vcoluna[31]
                placon.pesob  = vcoluna[32]
                placon.pesol  = vcoluna[33]
                placon.ttadicio = vcoluna[34]       
                **/ .
            vpar = 0.
            vrec = recid(placon).
            placon.notobs = "".
        end.
        find placon where recid(placon) = vrec  no-error.
        if vcoluna[1] = "F"
        then do:
            vpar = vpar + 1.
            placon.notobs[1] = placon.notobs[1] +
                "DUP-" + string(vpar,"999") + "=" + vcoluna[2] + "|" +
                "DTV-" + string(vpar,"999") + "=" + vcoluna[3] + "|" +
                "VAL-" + string(vpar,"999") + "=" + vcoluna[4] + "|" .
        end.
        if vcoluna[1] = "P"
        then do:
            find produ where produ.procod = int(vcoluna[2])
                            no-lock no-error.
            if not avail produ
            then find first produ where
                                produ.proindice = vcoluna[3]
                                no-lock no-error.
            if avail produ
            then vprocod = produ.procod.
            else vprocod = int(vcoluna[2]).
            
            find movcon where movcon.etbcod = placon.etbcod and
                              movcon.placod = placon.placod and
                              movcon.procod = int(vcoluna[2])
                              no-error.
            if not avail movcon
            then do:                  
                find last bmovcon where
                      bmovcon.etbcod = placon.etbcod and
                      bmovcon.placod = placon.placod
                      no-lock no-error.
                if avail bmovcon
                then vmovseq = bmovcon.movseq + 1.
                else vmovseq = 1. 
                create movcon.
                assign
                    movcon.etbcod = placon.etbcod
                    movcon.placod = placon.placod
                    movcon.movtdc = placon.movtdc
                    movcon.movdat = placon.pladat
                    movcon.emite = placon.emite
                    movcon.desti = placon.desti
                    movcon.movseq = vmovseq
                    movcon.procod = vprocod.
            end.
            assign                    
                movcon.movctm = dec(vcoluna[3])
                /*movcon.ocnum[1]  = vcoluna[3]
                movcon.ocnum[2]  = vcoluna[4]
                movcon.pronom = vcoluna[5]
                movcon.clafis = vcoluna[6]
                movcon.sittri = vcoluna[7]
                movcon.unida  = vcoluna[8]
                */
                movcon.movqtm = int(vcoluna[9])
                movcon.movpc  = dec(vcoluna[10]) / 100
                movcon.movdes = dec(vcoluna[12]) / 100
                movcon.movacfin = dec(vcoluna[13]) / 100
                movcon.movalicms = dec(vcoluna[14]) / 100
                movcon.movalipi = dec(vcoluna[15]) / 100
                movcon.movipi  = dec(vcoluna[16]) / 100
                .
            placon.notobs[2] = placon.notobs[2] +
                "DES-" + string(vmovseq,"999") + "=" +
                vcoluna[5] + "|".
            placon.notobs[3] = placon.notobs[3] +
                "CFI-" + string(vmovseq,"999") + "=" +
                vcoluna[6] + "|" +
                "STR-" + string(vmovseq,"999") + "=" +
                vcoluna[7] + "|".
                
        end.                   
        disp "Importando ..... "
             placon.numero
             movcon.procod  when avail movcon
             with frame f-imp 1 down centered row 10
             no-box color message.
        pause 0.     
             
    end.           
    input close.
    unix silent value("rm " + varquivo1).

/*** tabelas
notcon
movcon
*****/
