{cabec.i}

def var varquivo    as char.
def var varqini     as char init "/usr3/sigo/work/custom/integra/".
def var varqfin     as char.
def var vdtini      as date.
def var vdtfin      as date.
def var vdata       as date.
def var vhora       as char.
def var vetbcod     like estab.etbcod.
def var vconsulta   as log format "Sim/Nao".
def var vcodempresa as char.
def var vdatahora   as char.
def var ventrada    as log.
def var vpapel      as char.
def var vemp     as int.
def var vopccod  as int.
def var vmovtdc  as int.
def var vpronom  like produ.pronom.
def var vdtrefer as date.
def var vsittrib as char.
def var vopccod2 like plani.opccod.
def var vtbpreco-cod like produ.tbpreco-cod.
def var vnumero     as char.
def var vopccod_ent as char.
def var vopccod_sai as char.
def var vopfcod_ent as int.
def var vopfcod_sai as int.
def var vetbcod_ent as int.
def var vetbcod_sai as int.
def var vttvlrbaseicm as dec.
def var vttvlrcontab  as dec.
def var vcgccpf     as char.
def var vct         as int.
def var vobservacao as char.
def var vplatot     like plani.platot.
def var vbicms as dec.
def buffer bplani   for plani.
def buffer emite    for clifor.
def buffer desti    for clifor.
def buffer bestabd  for estab.

def temp-table ttclifor
    field clfcod    like clifor.clfcod
    index clfcod is primary unique clfcod asc. 
        
def temp-table tt-icms
    field aliqicms  as   dec
    field tbpreco-cod like produ.tbpreco-cod
    field baseicms  as   dec
    field movicms   like movim.movicms
    field vlrcontab as   dec
    field base      as   int
    field tributo   as   char.

def temp-table tt-plani
    field rec       as recid
    field entrada   as log
    field etbcod_ent as char
    field etbcod_sai as char
    field opccod_ent as char
    field opccod_sai as char
    field opfcod_ent as int
    field opfcod_sai as int.

vetbcod = setbcod.
disp varqini label "Local" format "x(40)" colon 17 skip
     with frame f1 width 80 side-label.
update vdtini  label "Data Inicial"    colon 17
       vdtfin  label "Data Final"      colon 50 
       vetbcod label "Estabelecimento" colon 17
       vconsulta label "Somente consulta" colon 17
       validate(vetbcod > 0, "")
       with frame f1.

if setbcod < 100
then assign
        vcodempresa = "00"
        vemp = 1. /* Obino    */
else assign
        vcodempresa = "06"
        vemp = 2. /* Magazine */

vhora     = string(time, "hh:mm:ss").
vdatahora = string(today, "99999999") + 
            substr(vhora, 1, 2) + substr(vhora, 4, 2) + substr(vhora, 7, 2).

def var vin_es as char.

if vconsulta
then varqini = "./".

varqfin = string(today, "999999") + string(vetbcod) + ".txt".
varquivo = varqini + "lfnota" + varqfin.
output to value(varquivo).
run exp-header.

for each tipmov where tipmov.movtdc <> 19 and tipmov.movtdc <> 20 no-lock.
   for each estab no-lock.
/***
      do vdata = vdtini to vdtfin.
***/
         for each plani where plani.movtdc = tipmov.movtdc
                          and plani.etbcod = estab.etbcod
                          and plani.notsit = "F"
                          
/***
                          and plani.dtincl = vdata
                          and plani.horincl > 0
***/
                     no-lock.
        
            if plani.movtdc = 29
            then vdtrefer = plani.pladat. /* transferencia de credito icms */
            else vdtrefer = plani.dtincl.

            if vdtrefer < vdtini or vdtrefer > vdtfin
            then next.

            assign
                ventrada    = not tipmov.tipemite
                vopccod2    = 0
                vopccod_ent = ""
                vopccod_sai = ""
                vopfcod_ent = 0
                vopfcod_sai = 0
                vetbcod_ent = 0
                vetbcod_sai = 0.

            if tipmov.movttra = no
            then do.
                if plani.etbcod <> vetbcod
                then next.
                if ventrada
                then
                    assign
                        vetbcod_ent = plani.etbcod
                        vin_es = "SN".
                else
                    assign
                        vetbcod_sai = plani.etbcod
                        vin_es = "NS".
            end.
            else do. /* transferenia */
                vin_es = "SS".
                vopccod2 = 122.
                case plani.opccod.
                    when 56 then vopccod2 = 122.
                    when 57 then vopccod2 = 123.
                    when 59 then vopccod2 = 125.
                    when 60 then vopccod2 = 126.
                    when 75 then vopccod2 = 131.
                end.
                find desti where desti.clfcod = plani.desti no-lock no-error.
                if not avail desti
                then find desti where desti.clfcod = 1 no-lock.
                find bestabd where bestabd.clfcod = desti.clfcod no-lock.
                assign
                    vetbcod_sai = plani.etbcod
                    vetbcod_ent = bestabd.etbcod.
                if plani.etbcod <> vetbcod
                then do. /* verifica se tem que constar como entrada */
                    if bestabd.etbcod <> vetbcod
                    then next.
                    ventrada    = yes.
                end.
            end.
            
            find emite where emite.clfcod = plani.emite no-lock.
            find desti where desti.clfcod = plani.desti no-lock no-error.
            if not avail desti
            then find desti where desti.clfcod = 1 no-lock.
            find ttclifor where ttclifor.clfcod = emite.clfcod no-error.
            if not avail ttclifor
            then create ttclifor.
            assign ttclifor.clfcod = emite.clfcod.                
            if avail desti
            then do.
                find ttclifor where ttclifor.clfcod = desti.clfcod no-error.
                if not avail ttclifor
                then create ttclifor.
                assign ttclifor.clfcod = desti.clfcod.
            end.

            run obidepara.i.
            if tipmov.movtdc = 4 /* devolucao de venda */
            then vopccod = 100.
            if plani.opccod = 903
            then vopccod = 20.

            if tipmov.movttra = no
            then do.
                if ventrada
                then
                    assign
                        vopccod_ent = string(vopccod)
                        vopfcod_ent = plani.opfcod.
                else
                    assign
                        vopccod_sai = string(vopccod)
                        vopfcod_sai = plani.opfcod.
            end.
            else
                assign
                    vopccod_ent = string(vopccod2)
                    vopfcod_ent = plani.opfcod - 4000
                    vopccod_sai = string(vopccod)
                    vopfcod_sai = plani.opfcod.

            create tt-plani.
            assign
                tt-plani.rec     = recid(plani)
                tt-plani.entrada = ventrada
                tt-plani.opccod_ent = vopccod_ent
                tt-plani.opfcod_ent = vopfcod_ent
                tt-plani.opccod_sai = vopccod_sai
                tt-plani.opfcod_sai = vopfcod_sai.

            run deparaestab (vetbcod_ent, output tt-plani.etbcod_ent).
            run deparaestab (vetbcod_sai, output tt-plani.etbcod_sai).

            if plani.serie = "CF"
            then vnumero = string((if plani.cupfiscal = 0
                                   then plani.numero 
                                   else plani.cupfiscal) ,"9999999").
            else vnumero = string(plani.numero /*, "999999"*/ ).

            vplatot = plani.platot.
            if plani.opccod = 903 /* nota acobertada */
            then vplatot = 0.

            put unformatted
                "NFGERAL"           format "x(10)"
                vcodempresa         format "x(16)"
                tt-plani.etbcod_sai format "x(16)"
                tt-plani.etbcod_ent format "x(16)"
                if plani.serie = "CF" then "CF" else "NF" format "x(10)"
                vnumero             format "x(15)"
                string(plani.emite) format "x(22)"
                string(desti.clfcod) format "x(22)"
                vin_es              format "x(2)"
                plani.pladat        format "99999999"
                plani.dtincl        format "99999999"
                ""                  format "x(6)"
                ""                  format "x(8)"
                vplatot * 100       format "99999999999999999"
                if ventrada = no or tipmov.movttra then "1901" else "" 
                                    format "x(30)" /* EOF */
                if ventrada      or tipmov.movttra then "1901" else "" 
                                    format "x(30)" /* EOF */
                0                   format "99999999999999999"
                ""                  format "x(6)"
                vplatot * 100       format "99999999999999999"
                if ventrada = no or tipmov.movttra then "CCUSTO" else ""
                                    format "x(6)" /* EOF */
                if ventrada      or tipmov.movttra then "CCUSTO" else ""
                                    format "x(6)" /* EOF */
                plani.dtincl        format "99999999" /* data competencia */
                ""                 format "x(22)"
                ""                 format "x(1) "
                ""                 format "x(22)"
                ""                 format "x(20)"
                ""                 format "x(1)"
                ""                 format "x(2)"
                ""                 format "x(80)"
                ""                 format "x(10)"
                ""                 format "x(10)"
                skip.

            for each tt-icms.
               delete tt-icms.
            end.

            for each movim of plani no-lock.
               vtbpreco-cod = 1. /* tributado */
               if tipmov.movttra = no
               then do.
                   find produ of movim no-lock no-error.
                   if avail produ
                   then vtbpreco-cod = produ.ctpreco-cod.
               end.

               find tt-icms where tt-icms.aliqicms = movim.movalicms
                    /*RM 08/09 and tt-icms.tbpreco-cod = vtbpreco-cod */
                            no-error.
               if not avail tt-icms
               then do.
                  create tt-icms.
                  assign
                      tt-icms.aliqicms = movim.movalicms
                      tt-icms.tbpreco-cod = vtbpreco-cod
                      tt-icms.tributo  = "ICMS"
                      tt-icms.base     = if vtbpreco-cod = 17 /* isento */
                                         then 2
                                         else 1.
               end.
               assign
                  tt-icms.baseicms  = tt-icms.baseicms  + movim.xx-precoori
                  tt-icms.movicms   = tt-icms.movicms   + movim.movicms
                  tt-icms.vlrcontab = tt-icms.vlrcontab + movim.xx-precoori 
                                      + movim.movipi.
               if tipmov.movttra
               then
                  assign
                     tt-icms.baseicms  = plani.platot
                     tt-icms.vlrcontab = plani.platot
                     tt-icms.base      = 3.
            end. /* movim */

            vbicms = plani.acfserv + plani.desacess + plani.frete. 
            /***
            if tipmov.movtdc <> 4
            then vbicms = vbicms + plani.acfprod.
            ***/
            if vbicms  > 0 and vplatot > 0 /* DOC */
            then do.
                find first tt-icms where tt-icms.base = 1 no-error.
                if not avail tt-icms
                then do.
                    create tt-icms.
                    assign
                        tt-icms.aliqicms = 17
                        tt-icms.tbpreco-cod = 1
                        tt-icms.tributo  = "ICMS"
                        tt-icms.base     = 1.
                end.
                assign
                    tt-icms.baseicms  = tt-icms.baseicms  + vbicms
                    tt-icms.vlrcontab = tt-icms.vlrcontab + vbicms.
                tt-icms.movicms = round(tt-icms.baseicms * 0.17, 2).
            end.    

            /* Arredondamento */
            find first tt-icms no-error.
            if avail tt-icms
            then
                if abs(plani.platot - tt-icms.baseicms) <= 0.2
                then
                    assign
                        tt-icms.baseicms  = plani.platot
                        tt-icms.vlrcontab = plani.platot.

            assign
                vttvlrbaseicm = 0
                vttvlrcontab  = 0.
            for each tt-icms no-lock.
               vttvlrbaseicm = vttvlrbaseicm + tt-icms.baseicms.
               vttvlrcontab  = vttvlrcontab  + tt-icms.vlrcontab.
            end.

            if (plani.platot - plani.ipi) > vttvlrbaseicm and
               (plani.platot - plani.ipi - vttvlrbaseicm > 0.02) and
               vplatot > 0
            then do.
                create tt-icms.
                assign
                  tt-icms.aliqicms  = 0
                  tt-icms.tributo   = "ICMS"
                  tt-icms.baseicms  = plani.platot - plani.ipi - vttvlrbaseicm
                  tt-icms.movicms   = 0
                  tt-icms.vlrcontab = plani.platot - plani.ipi - vttvlrbaseicm
                  tt-icms.base      = 2.
            end.

            /* IPI 06/09 */
            for each movim of plani where movim.movipi > 0 no-lock.
                find tt-icms where tt-icms.aliqicms = movim.movalipi
                               and tt-icms.tributo  = "IPI"
                             no-error.
                if not avail tt-icms
                then do.
                    create tt-icms.
                    assign
                      tt-icms.aliqicms  = movim.movalipi
                      tt-icms.tributo   = "IPI"
                      tt-icms.base      = 3 /* Retido */.
                end.
                assign
                  tt-icms.baseicms  = tt-icms.baseicms  + 
                                    (movim.movpc * movim.movqtm) - movim.movdes
                  tt-icms.vlrcontab = tt-icms.vlrcontab +
                                    (movim.movpc * movim.movqtm) 
                                    - movim.movdes + movim.movipi
                  tt-icms.movicms   = tt-icms.movicms + movim.movipi.
            end.
            if plani.movtdc = 29
            then do.
                create tt-icms.
                assign
                      tt-icms.aliqicms  = 0
                      tt-icms.tributo   = "ICMS"
                      tt-icms.base      = 1
                      tt-icms.vlrcontab = 0
                      tt-icms.baseicms  = 0
                      tt-icms.movicms   = plani.icms.
            end.        
            for each tt-icms no-lock.
               put unformatted
                   "NFTRIB"            format "x(10)"
                   vcodempresa         format "x(16)"
                   tt-plani.etbcod_sai format "x(16)"
                   tt-plani.etbcod_ent format "x(16)"
                   if plani.serie = "CF" then "CF" else "NF" format "x(10)"
                   vnumero             format "x(15)"
                   string(plani.emite) format "x(22)"
                   string(desti.clfcod) format "x(22)"
                   vin_es              format "x(2)"
                   tt-plani.opccod_ent format "x(10)"
                   tt-plani.opccod_sai format "x(10)"
                   tt-plani.opfcod_ent format "9999"
                   tt-plani.opfcod_sai format "9999"
                   tt-icms.tributo    format "x(4)"
                   if tipmov.movttra or ventrada then tt-icms.base else 0
                                       format "9"
                   if tipmov.movttra or ventrada = no then tt-icms.base else 0
                                        format "9"
                   tt-icms.aliqicms * 100  format "999999"
                   tt-icms.baseicms * 100  format "99999999999999999"
                   tt-icms.movicms * 100   format "99999999999999999"
                   0                       format "99999999999999999"
                   0                       format "99999999999999999"
                   tt-icms.vlrcontab * 100 format "99999999999999999"
                   plani.pladat            format "99999999"
                   skip.
            end. /* tt-icms */
            vobservacao = "".
            if vplatot = 0
            then do.
                find cupom-plani where 
                                   cupom-plani.etbcod-naofiscal = plani.etbcod
                               and cupom-plani.placod-naofiscal = plani.placod
                             no-lock no-error.
                if avail cupom-plani
                then do.
                   find bplani of cupom-plani no-lock.
                   vobservacao = "REFER." + bplani.serie + " " + 
                                 string(bplani.numero) + " R$ " + 
                                 string(bplani.platot,"zzz,zz9.99").
                end.
            end.
                   put unformatted
                       "NFOBS"             format "x(10)"
                       vcodempresa         format "x(16)"
                       tt-plani.etbcod_sai format "x(16)"
                       tt-plani.etbcod_ent format "x(16)"
                       if plani.serie = "CF" then "CF" else "NF" format "x(10)"
                       vnumero             format "x(15)"
                       string(plani.emite) format "x(22)"
                       string(desti.clfcod) format "x(22)"
                       vin_es              format "x(2)"
                       vobservacao         format "x(130)" 
                       plani.dtincl        format "99999999"
                       skip.
         
         end. /* plani */
/***      end. /* vdata */ ***/
   end. /* estab */
end. /* tipmov */
run exp-trailer.
output close.
if opsys = "unix"
then unix silent unix2dos value(varquivo).

/***
    ITENS
***/
varquivo = varqini + "lfitem" + varqfin.
output to value(varquivo).
run exp-header.
for each tt-plani no-lock.
    find plani where recid(plani) = tt-plani.rec no-lock.
    if plani.serie = "CF"
    then vnumero = string(plani.numero,"9999999").
    else vnumero = string(plani.numero /*, "999999"*/ ).

    find tipmov of plani no-lock.
    ventrada = tt-plani.entrada. /*not tipmov.tipemite*/
    if tipmov.movttra
    then vin_es = "SS".
    else if ventrada
         then vin_es = "SN".
         else vin_es = "NS".

    for each movim of plani no-lock.
        find produ of movim no-lock no-error.
        vpronom = if avail produ then produ.pronom else "".

        vsittrib = "000".
        if tipmov.movttra
        then vsittrib = "051".
        else if avail produ
        then do.
            find cer-itr where cer-itr.codtrib = produ.tbpreco-cod no-lock.
            if cer-itr.pertrib = 100
            then vsittrib = "000".
            if cer-itr.pertrib > 0 and cer-itr.pertrib < 100
            then vsittrib = "020".
            if cer-itr.codtrib = 16 /* substrituicao tributaria */
            then vsittrib = "060".
            if cer-itr.codtrib = 17 /* isento */
            then vsittrib = "040".
        end.
        put unformatted
            "NFITEM"            format "x(10)"
            vcodempresa         format "x(16)"
            tt-plani.etbcod_sai format "x(16)"
            tt-plani.etbcod_ent format "x(16)"
            if plani.serie = "CF" then "CF" else "NF" format "x(10)"
            vnumero             format "x(15)"
            string(plani.emite) format "x(22)"
            string(desti.clfcod) format "x(22)"
            vin_es              format "x(2)"
            movim.movseq        format "9999"
            string(movim.procod) format "x(16)"
            vpronom             format "x(100)"
            "QUANT"             format "x(10)"
            movim.movqtm * 100  format "9999999999999"
            movim.movqtm * movim.movpc * 100 
                                format "99999999999999999"
            movim.movdes * 100  format "99999999999999999"
            movim.xx-precoori * 100 
                                format "99999999999999999"
            0                   format "99999999999999999"
            0                   format "99999999999999999"
            movim.movicms * 100 format "99999999999999999"
            vsittrib            format "x(3)"
            0                   format "9999"
            movim.movalicms * 100 format "9999"
            ""                  format "x(8)"
            plani.pladat        format "99999999"
            "1"
            tt-plani.opfcod_ent format "9999"
            0                   format "9999999999999"
            0                   format "9999999999999"
            0                   format "99"
            0                   format "9999999999999"
            0                   format "9999999999999"
            0                   format "99"
            0                   format "9999999999999"
            ""                  format "x(15)"
            0                   format "999999999999999"
            0                   format "99"
            0                   format "99"
            0                   format "999999"
            0                   format "99999999999999999"
            0                   format "99999999999999999"
            ""                  format "x(3)"
            tt-plani.opfcod_sai format "9999"
            0                   format "99"
            0                   format "99"
            tt-plani.opccod_ent format "x(10)"
            tt-plani.opccod_sai format "x(10)"
            ""                  format "x(8)"
            skip.
    end. /* plani */
end. /* tipmov */
run exp-trailer.
output close.
if opsys = "unix"
then unix silent unix2dos value(varquivo).

/***
    PESSOAS
***/
varquivo = varqini + "lfpessoa" + varqfin.
output to value(varquivo).
run exp-header.

def var vok as log.

for each ttclifor no-lock.
    vct = vct + 1.
    find clifor where clifor.clfcod = ttclifor.clfcod no-lock.

    vcgccpf = trim(clifor.cgccpf).
    vok = yes.
    if length(vcgccpf) = 9
    then vcgccpf = "00" + vcgccpf.
    if length(vcgccpf) = 10
    then vcgccpf = "0" + vcgccpf.

    if length(vcgccpf) = 12
    then vcgccpf = "00" + vcgccpf.
    if length(vcgccpf) = 13
    then vcgccpf = "0" + vcgccpf.
   
    if clifor.tippes 
    then run cpf.p (vcgccpf, output vok).
    if dec(clifor.cgccpf) = 0 or vok = no
    then      if vct mod 6 = 0 then vcgccpf = "47541202053".
         else if vct mod 6 = 1 then vcgccpf = "44880499072".
         else if vct mod 6 = 2 then vcgccpf = "58141030000".
         else if vct mod 6 = 3 then vcgccpf = "31409288072".
         else if vct mod 6 = 4 then vcgccpf = "16857984034".
         else if vct mod 6 = 5 then vcgccpf = "48540021072".

    put unformatted
        "PESSOA"                format "x(10)"
        vcodempresa             format "x(16)"
        vdatahora               format "x(14)"
        string(clifor.clfcod)   format "x(22)"
        trim(clifor.clfnom)     format "x(100)"
        (clifor.endereco + " " + clifor.numero + clifor.compl)
                                format "x(40)"
        clifor.bairro           format "x(30)"
        if clifor.cidade = "" then "BAGE" else clifor.cidade
                                format "x(40)"
        clifor.paissig          format "x(10)"
        if clifor.ufecod = "" then "RS" else clifor.ufecod
                                format "x(2)"
        if clifor.cep = "" then "96407200" else clifor.cep
                                format "x(8)"
        if clifor.tippes then "F" else "J"
                                format "x(1)"
        vcgccpf                 format "x(14)"
        if clifor.tippes then "" else clifor.ciinsc
                                format "x(22)"
        clifor.fone             format "x(40)"
        clifor.fax              format "x(40)"
        clifor.dtcad            format "99999999"
        ""                     format "x(8)"
        ""                     format "x(16)"
        ""                     format "x(30)"
        ""                     format "x(100)"
        ""                     format "x(10)"
        ""                     format "x(16)"
        ""                     format "x(1)"
        ""                     format "x(100)"
        ""                     format "x(20)"
        ""                     format "x(16)"
        ""                     format "x(16)"
        skip.

    find tclifor of clifor no-lock.
    vpapel = "".
    if substr(tclifor.tclnom, 1, 3) = "CLI"
    then vpapel = "CLI".
    else vpapel = "FOR".

    put unformatted
        "PESPAPEL"              format "x(10)"
        vcodempresa             format "x(16)"
        vdatahora               format "x(14)"
        string(clifor.clfcod)   format "x(22)"
        vpapel                  format "x(16)"
        skip.
end.
run exp-trailer.
output close.
if opsys = "unix"
then unix silent unix2dos value(varquivo).

if vconsulta = no
then message "Arquivo gerados: lfnota, lfitem e lfpessoa" view-as alert-box.
else run implfsispro.p (varqfin).

procedure exp-header.
    put unformatted
        "HEADER"        format "x(10)"
        vcodempresa     format "x(16)"
        vdatahora       format "x(14)"
        ""              format "x(60)"
        skip.
end procedure.

procedure exp-trailer.
    put unformatted
        "TRAILER"       format "x(10)"
        vcodempresa     format "x(16)"
        vdatahora       format "x(14)"
        skip.
end procedure.

procedure deparaestab.
    def input  parameter par-de   as int.
    def output parameter par-para as char.

    par-para = "".
    case par-de: 
        when 100 then par-para = "06003".
        when 101 then par-para = "06001".
        when 102 then par-para = "06002".
    end.
end procedure.

procedure obidepara.i.


    def buffer xxx-clifor for clifor.
    find xxx-clifor where xxx-clifor.clfcod = plani.desti no-lock
                                no-error.
    vopccod = plani.opccod.
    vopccod = if plani.opccod = 365 then 58     else
              if plani.opccod = 349 then 56     else 
              if plani.opccod = 298 then 66     else
              if plani.opccod = 380 or plani.opccod = 408 then 51     else
              if plani.opccod = 240 or
                 plani.opccod = 242
                 then (if plani.opfcod = 2916
                                         then 120 else 119)    else
              if plani.opccod = 115 
                 then (if plani.opfcod = 2910
                                         then 116 else 115)    else
              if plani.opccod = 109
                 then (if plani.opfcod = 2949
                                         then 110 else 109)    else
                                         
              if plani.opccod = 113 or
                 plani.opccod = 125
                 then (if plani.opfcod = 2917
                                         then 114 else 113)    else
                                         
              if plani.opccod = 351 then 43     else
              if plani.opccod = 509 then
                                    if avail xxx-clifor
                                        and xxx-clifor.tclcod = 2
                                    then 119
                                    else 118
              else                      
              if plani.opccod = 651 then 58 else vopccod.

    vopccod = 
              if plani.opccod = 358 then 58 else
              if plani.opccod = 286 then 147 else
              if 
                 plani.opccod = 298 or
                 plani.opccod = 66 then (if plani.opfcod = 6202
                                          then 67 else 66) 
                 else
              if plani.opccod = 352 then 42 else
              if plani.opccod = 355 then 52 else

              if plani.opccod = 107
                 then (if plani.opfcod = 2202
                                         then 108 else 107)    else
              if plani.opccod = 111
                 then (if plani.opfcod = 2949
                                         then 112 else 111)    else
               
              if plani.opccod = 133
                 then (if plani.opfcod = 2949
                                         then 134 else 133)   
                else vopccod.
    vopccod =                   
              if plani.opccod = 105 or
                 plani.opccod = 781 OR
                 PLANI.OPCCOD = 297
                 then (if plani.ufemi <> "RS"
                                          then 106  else 105)
                                          else
              if plani.opccod = 69  then (if plani.ufdes <> "RS"
                                          then 70  else 69)
                                          else
              if plani.opccod = 152  then (if plani.ufemi <> "RS"
                                          then 153  else 152)
                                          else
                                          
              if plani.opccod = 64  then (if plani.ufdes <> "RS"
                                          then 65  else 64)
                                          else
              if plani.opccod = 73  then (if plani.ufdes <> "RS"
                                          then 74  else 73)
                                          else vopccod.
        vopccod =                                           
              if plani.opccod = 364 then (if plani.opfcod = 6918
                                         then 74 else 73)
                                          else
              if plani.opccod = 534 or
                 plani.opccod = 533 then (if plani.opfcod = 6918
                                         then 74 else 73)
                                    else
              if plani.opccod = 633 or
                 plani.opccod = 634 then (if plani.ufemi <> "RS"
                                         then 167 else 168)
                                    else vopccod.

    /* Devolucoes de venda */
    vopccod = if plani.opccod = 217 then 100    else
              if plani.opccod = 211 then 100    else
              if plani.opccod = 213 then 100    else
              if plani.opccod = 221 then 100    else
              if plani.opccod = 518 then 100    else
              if plani.opccod = 521 then 100    else
              if plani.opccod = 771 then 20     else
              vopccod.
    if plani.movtdc = 32 /* dev.demonstracao */
    then vopccod = 121.

    find opcom where opcom.opccod = vopccod no-lock no-error.              
    if not avail opcom
    then do:
        vmovtdc = if plani.movtdc = 1 then 1 else
                  if plani.movtdc = 2 then 3 else
                  if plani.movtdc = 10 then 4
                  else 2.
    end.
    else do:
        vmovtdc = if opcom.movtdc = 1 then 1 else
                  if opcom.movtdc = 2 then 3 else
                  if opcom.movtdc = 10 then 4
                  else 2.


    end.    
    if vopccod = 289 /* conforme solicitacao 2686 */
    then next. 
 end.
