{admcab.i}  

def var vpaccod like pack.paccod.

def var vclfnom-emite like clien.clinom.
def var vclfnom-desti like clien.clinom.

def var cdata   as char format "xxxxx".
def var recatu1         as recid.
def var reccont         as int.

def temp-table tt-packhiest
    field etbcod like estab.etbcod
    field paccod like pack.paccod
    field estatual like packhiest.hiestf

    index x is unique primary etbcod asc paccod asc.

def buffer xestab for estab.
/***
def buffer emiclifor    for clifor.
def buffer desclifor    for clifor.
***/
def buffer emiestab     for estab.
def buffer desestab     for estab.

def var vtitrel as char format "x(120)".
def input param par-rec as char.
                                              
/***
def var vclfcod like clifor.clfcod.
***/
def var vhora as char.
def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vmesfim as int.
def var vano    as int format "9999".
def var vanofim as int.

def var vdti        as date format "99/99/9999".
def var vdtf        as date format "99/99/9999".
def var vdata       as date format "99/99/9999".
def var vtotest     like packhiest.hiestf format "->>>,>>9.99".
def var vestini     like packhiest.hiestf.
def var vtipo       as char format "x".
def var vmovqtm like movimpack.movqtm format "->>>,>>9.99".
/***
def var vctmfim     like packhiest.hiectmfim format "->>>>>9.99".
def var vctmini     like packhiest.hiectmfim format "->>>>>9.99".
***/
def var vnumero     as char.

def temp-table tt-extrato
    field data      as date
    field hora      as int
    field seq       as int
    field emitente  as int
    field destino   as int
    field rec-movim as recid
    field funcod    like func.funcod
    field etb       like estab.etbcod
    field movimento as char
    field numero    as char format "x(10)"
    field clfcod    as int /***like clifor.clfcod***/
    field qtd       like movimpack.movqtm
    field estoque   like estoq.estatual
/***    field custooper like movimpack.movctm
    field efin      like vctmfim***/
    index esquema              data asc
                               hora asc
                               movimento desc.

form
    vpaccod   colon 10
    pack.pacnom no-label format "x(30)"
    with frame fpack 1 down centered side-labels row 4 width 80 no-box.

form    
    vetbcod  label  "Estab" colon 10
    estab.etbnom no-label format "x(22)" 
    vmes no-label space(0) "/" space(0) vano no-label    
    vdti     label "De" format "99/99/9999"
    vdtf     label "A"  format "99/99/9999"
    with frame f-etb
        centered 1 down side-labels row 5 width 80 no-box.
/***
def var vtipmovajuste-entrada-zera as int.
vtipmovajuste-ENTRADA-zera   = int(paramsis("tipmovajuste-ENTRADA-zera")).
***/
repeat.
    clear frame f-browse all no-pause.
    clear frame fsaldoinicial all no-pause.
    clear frame fsaldofinal all no-pause.
    
    if par-rec = "MENU"
    then do: 
        update vpaccod with no-validate with frame fpack.
        find pack where pack.paccod = vpaccod no-lock no-error.
        if not avail pack
        then do.
            message "Pack invalido" view-as alert-box.
            undo.
        end.
    end.
    else find pack where recid(pack) = int(par-rec) no-lock.

    disp 
        pack.pacnom
        with frame fpack.

    repeat.
        for each tt-extrato.
            delete tt-extrato.
        end.

        find estab where estab.etbcod = setbcod no-lock.
        vetbcod = setbcod.

        clear frame f-browse all no-pause.
        clear frame fsaldoinicial all no-pause.
        clear frame fsaldofinal all no-pause. 
        view frame fpack.

        {selestab.i vetbcod f-etb}

        if vetbcod = 0 
        then disp "GERAL" @ estab.etbnom with frame f-etb.
        else do :
            find estab where estab.etbcod = vetbcod no-lock.
            disp estab.etbnom with frame f-etb.
        end.    
        /***vclfcod = estab.clfcod.***/
        vmes = month(today).
        vano = year(today).

        disp
            vmes vano with frame f-etb.
   
        assign vdti = date(vmes,01,vano)
               vdtf = today - 1. 
        vanofim      = vano + if vmes = 12                  
                          then 1                        
                          else 0.
        vmesfim      = if vmes = 12                         
                       then 1                               
                       else vmes + 1.                        
        vdtf         = date(vmesfim,01,vanofim) - 1.

        disp vdti  vdtf   with frame f-etb.
    
        do on error undo. 
            update vdti vdtf
                    with frame f-etb.
            if vdtf < vdti
            then undo.
            if day(vdti) <> 1
            then vdti = date(month(vdti), 01, year(vdti)).
               
            vano = year(vdtf).
            vmes = month(vdtf).
            vanofim      = vano + if vmes = 12                   
                           then 1                         
                           else 0. 
            vmesfim      = if vmes = 12                          
                           then 1                                
                           else vmes + 1.                         
            vdtf         = date(vmesfim,01,vanofim) - 1.
        
            def var pdtf as date. /* contem o ultimo dia do mes inicial */
            vano = year(vdti).
            vmes = month(vdti).

            vanofim      = vano + if vmes = 12                   
                           then 1                         
                           else 0. 
            vmesfim      = if vmes = 12                          
                           then 1                                
                           else vmes + 1.                         
            pdtf         = date(vmesfim,01,vanofim) - 1.

            /**/
            display vdti vdtf
                    with frame f-etb.
        end.    

        recatu1 = ?.
        run monta.

        run tela.
    end.

    if par-rec <> "MENU"
    then leave.
end.

PROCEDURE monta.

    for each tt-extrato.
        delete tt-extrato.
    end.

    def var vseq as int.
    def var vok  as log.
    vseq = 0.                
   
    do vdata = vdti to vdtf:
        for each tipmov no-lock.
            for each movimpack where 
                     movimpack.paccod = pack.paccod  and
                     movimpack.movtdc = tipmov.movtdc and
                     movimpack.movdat = vdata
                     no-lock
                     by movimpack.movhr:

                find plani where plani.etbcod = movimpack.etbcod
                             and plani.placod = movimpack.placod
                           no-lock no-error.
                if not avail plani
                then next.
/*** revisar
                if plani.notsit <> "F"
                then next.
***/
                if plani.numero = ? and
                   plani.movtdc <> 19 and
                   plani.movtdc <> 20 and
                   plani.movtdc <> 37 and
                   plani.movtdc <> 38
                then next.

                vok = yes.
                if vetbcod > 0 and
                   movimpack.etbcod <> vetbcod
                then vok = no.
                
                find func where func.funcod = plani.vencod no-lock no-error.
                if not avail func
                then find func where func.funcod = int(plani.usercod)
                               no-lock no-error.

/***
                /* destino */
                find desclifor where 
                         desclifor.clfcod  = plani.desti no-lock no-error.
                IF AVAIL desCLIFOR
                THEN
                   FIND FIRST desESTAB WHERE desESTAB.CLFCOD = desCLIFOR.CLFCOD
                        NO-LOCK NO-ERROR.

                /* emitente */
                find emiclifor where 
                         emiclifor.clfcod  = plani.emite no-lock no-error.
                IF AVAIL emiCLIFOR
                THEN 
                   FIND FIRST emiESTAB WHERE emiESTAB.CLFCOD = emiCLIFOR.CLFCOD
                                       NO-LOCK NO-ERROR.
***/        
                vnumero = string(plani.serie,"xx") + "/" + string(plani.numero).

                if vok
                then do.
         
                vtipo = if tipmov.tipemite = yes
                        then "-"
                        else "+".
                if not tipmov.movtest
                then vtipo = "".

                vtotest = vtotest + (if vtipo = "+"
                             then movimpack.movqtm
                             else if vtipo = "-"
                                  then -  movimpack.movqtm
                                  else 0).

/***
                vctmfim = vctmfim + if vtipo = "+"  
                            then movimpack.movctm
                            else if vtipo = "-"
                                 then - movimpack.movctm
                                 else 0.
                if vtipmovajuste-entrada-zera = movimpack.movtdc
                then assign
                        vtotest = 0
                        vctmfim = 0
                        vtipo   = "zera".
***/
                vmovqtm = if vtipo = "-"
                      then -1 * movimpack.movqtm
                      else movimpack.movqtm.
                vseq = vseq + 1.
                create tt-extrato.
                assign
                    tt-extrato.rec-movim = recid(movimpack)
                    tt-extrato.destino   = plani.desti
                    tt-extrato.emitente  = plani.emite
/***
                    tt-extrato.destino    = 
                        IF AVAIL desESTAB
                        THEN desESTAB.ETBCOD
                        ELSE if avail desclifor
                             then desclifor.clfcod
                             else 0
                    tt-extrato.emitente    = 
                        IF AVAIL emiESTAB
                        THEN emiESTAB.ETBCOD
                        ELSE if avail emiclifor
                             then emiclifor.clfcod
                             else 0
***/
                    tt-extrato.data      = movimpack.movdat                 
                    tt-extrato.hora      = movimpack.movhr                  
                    tt-extrato.seq       = vseq
                    tt-extrato.funcod    = if avail func
                                           then func.funcod
                                           else 0
                    tt-extrato.numero    = vnumero
/***
                    tt-extrato.clfcod    = if avail plani 
                                           then if avail clifor
                                                then clifor.clfcod
                                                else 0
                                           else 0
***/
                    tt-extrato.qtd       = vmovqtm                      
                    tt-extrato.movimento = vtipo
                    tt-extrato.estoque   = if vtipo <> "" then vtotest else 0 
/***
                    tt-extrato.custooper = movimpack.movctm
                    tt-extrato.efin      = vctmfim***/.
                end.

                /* Transferencia - Destinatario */
                if tipmov.movttra /***and
                   tipmov.movttrcre***/
                then do.
/***
                    if vetbcod > 0 and
                       plani.desti <> vclfcod
                    then next.
***/
                    
                    vtipo = if tipmov.tipemite = yes
                            then "+"
                            else "-".
                    if not tipmov.movtest
                    then vtipo = "".

                    vmovqtm = if vtipo = "-"
                              then -1 * movimpack.movqtm
                              else movimpack.movqtm.

                    vseq = vseq + 1.
                    create tt-extrato.
                    assign 
                         tt-extrato.rec-movim = recid(movimpack)
/***
                         tt-extrato.destino    = 
                                IF AVAIL desESTAB
                                THEN desESTAB.ETBCOD
                                ELSE if avail desclifor 
                                     then desclifor.clfcod  
                                     else 0
                         tt-extrato.emitente    = 
                                IF AVAIL emiESTAB
                                THEN emiESTAB.ETBCOD
                                ELSE if avail emiclifor 
                                     then emiclifor.clfcod  
                                     else 0
***/
                         tt-extrato.data      = movimpack.movdat                 
                         tt-extrato.hora      = movimpack.movhr                  
                         TT-EXTRATO.SEQ       = vseq
                         tt-extrato.funcod    = if avail func
                                                then func.funcod
                                                else 0
                         tt-extrato.numero    = vnumero
/***
                         tt-extrato.clfcod    = if avail clifor
                                                then clifor.clfcod
                                                else 0
***/
                         tt-extrato.qtd       = vmovqtm                      
                         tt-extrato.movimento = vtipo
                         tt-extrato.estoque   = if vtipo <> ""
                                                then vtotest else 0 
/***                         tt-extrato.custooper = movimpack.movctm
                         tt-extrato.efin      = vctmfim***/.
                end. /* transferencia */
            end. /* movim */
        end. /* tipmov */
    end. /* vdata */
end procedure.    


    form
        cdata column-label "Data" help "ENTER = Consulta F8 - Imprime " 
        vhora         format "xxxxx" column-label "Hora"
        func.funape  column-label "Func" format "x(5)"
        plani.opccod column-label "Opc"
        tipmov.movtsig      format "x(5)"          column-label "Movim"
        tt-extrato.numero       column-label "Numero"
        tt-extrato.emitente     column-label "Emite" format ">>>>>999"
        tt-extrato.destino      column-label "Desti" format ">>>>>999"
        tt-extrato.movimento    column-label "" format "x"        
        tt-extrato.qtd          column-label "Qtd.Mov"  format "->>>9.99"
        tt-extrato.estoque      column-label "Saldo"    format "->>>>9.99"
       with frame frame-a overlay width 80 row 7 9 down.

procedure tela.

    def var vtotctm as dec.
    def var vmovdat like movimpack.movdat.

    assign
        vtotest = 0
        vtotctm = 0.
    for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod else true)
                   no-lock.
        find last packhiest where packhiest.etbcod = estab.etbcod and  
                                  packhiest.paccod = pack.paccod and
                                  packhiest.hiedt  < vdti
                        no-lock no-error.
        if avail packhiest
        then do.
            assign
                vtotest = vtotest + packhiest.hiestf.
/***
            if packhiest.hiestf > 0
            then vtotctm = vtotctm + packhiest.hiectmfim.
***/
            if vmovdat = ? or
               vmovdat > packhiest.hiedt
            then vmovdat = packhiest.hiedt.
        end.
    end.
    display " " format "x(15)"
            vmovdat
            "ESTOQUE INICIAL          "
            vtotest 
/***            vtotctm ***/
            with frame fsaldoinicial row 6 color message
                    no-box no-label width 81 overlay.
     
    for each tt-extrato
                            break by tt-extrato.data
                                  by tt-extrato.hora.
        vtotest = vtotest +
                    if tt-extrato.movimento = "+"
                    then tt-extrato.qtd
                    else if tt-extrato.movimento = "-"
                         then tt-extrato.qtd
                         else 0.
        vtotest  = if tt-extrato.movimento = "zera"
                   then if vetbcod = 0 /*** 11/12/09 - Geral ***/
                        then vtotest - tt-extrato.qtd
                        else 0
                   else vtotest.
                          
        tt-extrato.estoque =  vtotest.                     
/***
        vtotctm = vtotctm +                    
                    if tt-extrato.movimento = "+"
                    then tt-extrato.custooper * tt-extrato.qtd
                    else if tt-extrato.movimento = "-"
                         then tt-extrato.custooper * tt-extrato.qtd
                         else 0.
        vtotctm  = if tt-extrato.movimento = "zera"
                   then if vetbcod = 0 /*** 11/12/09 - Geral ***/
                        then vtotctm - (tt-extrato.custooper * tt-extrato.qtd)
                        else 0
                   else vtotctm.
                           
        tt-extrato.efin    = vtotctm.
***/ 
    end.                                  

    find last packhiest where packhiest.etbcod = vetbcod and
                              packhiest.paccod = pack.paccod  and
                              packhiest.hiedt  <= vdtf  no-lock no-error.
    find estab where estab.etbcod = setbcod no-lock.
    if vetbcod > 0
    then vtotest =  if avail packhiest 
                    then packhiest.hiestf 
                    else 0.
                                  
    display if avail packhiest
            then packhiest.hiedt
            else ? @ movimpack.movdat at 19
            "ESTOQUE FINAL" @ tipmov.movtnom format "x(37)"
            vtotest
            with frame fsaldofinal row screen-lines - 1 color message
                     no-box no-label width 81 overlay.
    
    pause 0.

def buffer btt-extrato       for tt-extrato.

bl-princ:
repeat:
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-extrato where recid(tt-extrato) = recatu1 no-lock.
    if not available tt-extrato
    then do:
        message "Nenhum Movimento no Periodo" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-extrato).
    repeat:
        run leitura (input "seg").
        if not available tt-extrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-extrato where recid(tt-extrato) = recatu1 no-lock.

            status default
                    "ENTER = Consulta Nota     F8 = Imprime".

                find movimpack where  recid(movimpack) = tt-extrato.rec-movim
                 no-lock. 
                color display  message
                        tt-extrato.numero 
                        vhora  
                        cdata  
                        plani.opccod  
                        tipmov.movtsig 
                        tt-extrato.numero  
                        func.funape 
                        tt-extrato.qtd  
                        tt-extrato.estoque  
                        tt-extrato.movimento
                        
                        tt-extrato.emitente  
                        tt-extrato.destino  
                        with frame frame-a .

                choose field tt-extrato.numero help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                       PF4 F4 ESC return F8 PF8) .
                color display  normal
                        tt-extrato.numero 
                        vhora  
                        cdata  
                        plani.opccod  
                        tipmov.movtsig 
                        tt-extrato.numero  
                        func.funape 
                        tt-extrato.qtd  
                        tt-extrato.estoque  
                        tt-extrato.movimento
                        tt-extrato.emitente  
                        tt-extrato.destino  
                        with frame frame-a .

            status default "".

            if keyfunction(lastkey) = "clear"
            then do: 
                run relatorio. 
            end.    

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-extrato
                    then leave.
                    recatu1 = recid(tt-extrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-extrato
                    then leave.
                    recatu1 = recid(tt-extrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-extrato
                then next.
                color display white/red tt-extrato.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-extrato
                then next.
                color display white/red tt-extrato.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ. 
        if keyfunction(lastkey) = "return"
        then do: 
            pause 0.
            find movimpack where recid(movimpack) = tt-extrato.rec-movim
             no-lock. 
            find plani where plani.etbcod = movimpack.etbcod
                         and plani.placod = movimpack.placod no-lock.
            run not_consnota.p (recid(plani)). 
        end.
            run frame-a.
        recatu1 = recid(tt-extrato).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame fsaldoinicial no-pause.
hide frame fsaldofinal   no-pause.
hide frame fpack   no-pause.
hide frame f-etb   no-pause.
hide frame frame-a no-pause.

    /*****/
    
end procedure.

procedure frame-a. 
find movimpack where  recid(movimpack) = tt-extrato.rec-movim no-lock. 
find plani where plani.etbcod = movimpack.etbcod
             and plani.placod = movimpack.placod no-lock.

cdata = string( day  (tt-extrato.data)) + "/" + string( month(tt-extrato.data)).
find tipmov of plani no-lock no-error. 
find func where func.funcod = tt-extrato.funcod no-lock no-error. 
/***
find clifor where clifor.clfcod = tt-extrato.clfcod no-lock no-error.  
***/
display tt-extrato.numero
        string(movimpack.movhr,"HH:MM") @ vhora 
        cdata 
        plani.opccod format ">>>9"
        tipmov.movtsig when avail tipmov 
        tt-extrato.numero 
/***
        func.funape when avail func 
***/
        tt-extrato.qtd 
        tt-extrato.estoque 
        tt-extrato.movimento
        tt-extrato.emitente 
        tt-extrato.destino 
        with frame frame-a .
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-extrato use-index esquema no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-extrato  use-index esquema  no-lock no-error.
             
if par-tipo = "up" 
then  find prev tt-extrato use-index esquema  no-lock no-error.
        
end procedure.
 

PROCEDURE relatorio.

def var varqsai as char.
    
find last packhiest where packhiest.etbcod = vetbcod and
                          packhiest.paccod = pack.paccod  and
                          packhiest.hiedt  < vdti no-lock no-error.
if avail packhiest
then assign 
            vtotest  = if packhiest.hiestf = ?
                       then 0
                       else packhiest.hiestf
            vestini  = vtotest
/***
            vctmfim  = if packhiest.hiectmfim = ?
                       then 0
                       else packhiest.hiectmfim
            vctmini  = vctmfim***/.
else assign 
            vtotest  =  0
            vestini  = 0
            /***vctmfim  = 0
            vctmini  = 0***/.
vtitrel = /***" Fabricante " + string(produ.fabcod) + " - " +***/
          string(pack.paccod) + " - " + pack.pacnom +
          " INICIAL: " +  string(vestini,"->>,>>9.99") + " " /***+
          " Custo: " +  string(vctmini,"->>>,>>9.99")***/ .

    varqsai = "../impress/proext" + string(time).
    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""PROEXT""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &tit-rel  = " "" EXTRATO DE MOVIMENTACAO "" +
               ""ESTAB: "" + string(estab.etbcod) + "" "" +
                    estab.etbnom "
        &Tit-Rel1   =  vtitrel 
        &Width     = "150"
        &Form      = "frame f-cabcab"}

/***
    def buffer emite for clifor.
    def buffer desti    for clifor.
***/
    def buffer btt-extrato for tt-extrato.
    
    form
        btt-extrato.data     column-label "Data"    format "99/99/99"
        vhora                column-label "Hora"    format "x(5)"
        func.funape          column-label "Responsavel" format "x(11)"
        tipmov.movtsig       column-label "Movim"
        opcom.opccod         column-label "Opc"
        btt-extrato.numero   column-label "Numero"
        btt-extrato.emitente column-label "Emite"   format ">>>>>>>9"
        vclfnom-emite        no-label               format "x(15)"
        tipmov.tipemite      column-label "E/S"     format "S/E"
        btt-extrato.destino  column-label "Desti"   format ">>>>>>>9"
        vclfnom-desti        column-label "Destinatario"  format "x(15)"
        btt-extrato.qtd      column-label "Mov"     format "->>>>9.99"
        btt-extrato.estoque  column-label "Estoque" format "->>>>9.99"
/***
        btt-extrato.custooper column-label "Custo!Oper." format "->>>9.99"
        btt-extrato.efin     column-label "E.Fin"   format "->>>>>9.99"
        movimpack.movctm
***/
        with frame f-linha width 168 down no-box.

        for each btt-extrato use-index esquema .
            find movimpack where recid(movimpack) = btt-extrato.rec-movim no-lock.   
            find tipmov of movimpack no-lock.
            find plani where plani.etbcod = movimpack.etbcod
                         and plani.placod = movimpack.placod no-lock.
            find opcom where opcom.opccod = string(plani.opccod) no-lock no-error.
/***
            find desti where desti.clfcod  = plani.desti no-lock no-error.
            find first desestab where
                desestab.clfcod = desti.clfcod no-lock no-error.
            find emite where emite.clfcod   = plani.emite no-lock.
            find first emiestab where
                emiestab.clfcod = emite.clfcod no-lock no-error.
 
            find func where func.funcod = btt-extrato.funcod 
                    no-lock no-error.
            vclfnom-emite = if avail emiestab then emiestab.etbnom
                                else if avail emite
                                     then emite.clfnom
                                     else "".
            vclfnom-desti = if avail desestab then desestab.etbnom
                                else if avail desti
                                     then desti.clfnom
                                     else "".
***/
            display
                btt-extrato.data
                string(movimpack.movhr,"HH:MM") format "x(5)" @ vhora
                tipmov.movtsig
                tipmov.tipemite
                opcom.opccod when avail opcom
                vclfnom-emite
                vclfnom-desti
                func.funape when avail func
                btt-extrato.numero
                btt-extrato.qtd
                btt-extrato.estoque
                btt-extrato.emitente   
                btt-extrato.destino  
/***
                btt-extrato.custooper
                btt-extrato.custooper * btt-extrato.estoque @ btt-extrato.efin
                movimpack.movctm    
***/
                    with frame f-linha.
            down with frame f-linha.
        end.
        

    down 3 with frame f-linha.
    find last packhiest where packhiest.etbcod = vetbcod and
                          packhiest.paccod = pack.paccod  and
                          packhiest.hiedt  <= vdtf  no-lock no-error.
        disp if avail packhiest
             then packhiest.hiedt 
             else ? @ btt-extrato.data
             "ESTOQUE FINAL NO SISTEMA" @ vclfnom-emite
             if avail packhiest
             then packhiest.hiestf 
             else 0 @ btt-extrato.estoque
/***
                (if not avail packhiest or packhiest.hiestf = 0
                 then 0
                 else packhiest.hiectmfim / packhiest.hiestf) @ movimpack.movctm
             if avail packhiest
             then packhiest.hiectmfim 
             else 0 @ btt-extrato.efin
***/
                with frame f-linha.
        down with frame f-linha.
                        
/***
    {mdadmrod.i
    {mdad.i
        &Saida     = "value(varqsai)"
        &NomRel    = """PROEXT"""
        &Nom-Rel   = """"
        &Nom-Sis   = """"
        &Tit-Rel   = """"
        &Page-Size = "66"
        &Width     = "128"
        &Traco     = "60"
        &Cond-Var  = "80"
        &Form      = "frame f-rod3"}.
***/
 
end procedure.

