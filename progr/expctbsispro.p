{cabec.i}

def var varqini  as char init "/usr3/sigo/work/custom/integra/".
def var vdtini   as date format "99/99/9999" label "Emissao".
def var vdtfin   as date format "99/99/9999" label "ate".
def var vetbcod  like estab.etbcod.
def var vemp     as int.

do on error undo with frame finicio centered row 4 
                            side-label  width 80 color black/cyan
                            title " Exportacao lancamentos contabeis ".
   disp varqini label "Local" format "x(40)" skip.
   update vetbcod validate (vetbcod > 0 , "")
          vdtini  validate (vdtini <> ?,"Data Invalida")
                           help "Informe a Data Inicial".
   update vdtfin validate (vdtfin >= vdtini, "").
end.

if setbcod < 100
then assign
        vemp = 1. /* Obino    */
else assign
        vemp = 2. /* Magazine */

def temp-table tt-mov
    field seq           as int
    field eof2          as char
    field valor         as dec
    field hiscod        like opcomctb.hiscod
    field opctbnat      like opcomctb.opctbnat
    field opccod        like opcomctb.opccod
    field connum        like conta.connum
    field data          as   date

    index lanc  data opccod connum eof2.

def temp-table tt-lote
    field data          as   date
    field seq           as   int
    field totcre        as   dec
    field totdeb        as   dec.

find controle where controle.tipcon = 100 no-error.
if not avail controle
then do.
    create controle.
    controle.tipcon = 100.
    controle.numini = "GE".
end.

def var vseq      as int init 0.
def var vtotcre   as dec.
def var vtotdeb   as dec.
def var vcodmov   as char.
def var varquivo  as char.
def var vvalor    as dec.
def var vconta    as char.
def var veof2     as char.
def var vetbcodh  as char.
def var vetbcodl  as char.
def var vopccod   like opcom.opccod.
def var vdata     as date.

varquivo = (if opsys = "unix" then varqini else "c:~~\temp~\") +
           "ctb" + string(day(vdtini), "99") + string(month(vdtini), "99") +
           string(controle.valor + 1, "9999") + ".txt".
if vemp = 1
then vetbcodh = "00080".
else vetbcodh = "06003".


do vdata = vdtini to vdtfin.
   assign
      vseq = 0
/*
      vtotdeb = 0
      vtotcre = 0
*/
      vcodmov = "INTVEN" + 
                string(year(vdtini), "9999") + 
                string(month(vdtini), "99") + 
                string(day(vdtini), "99") +
                string(controle.valor + 1, "9999") + 
                vetbcodh.

   for each tipmov no-lock.
      for each estab where (if vetbcod > 0 
                            then estab.etbcod = vetbcod else true)
                             no-lock.
         if vemp = 1 and estab.etbcod >= 100 then next.
         if vemp = 2 and estab.etbcod < 100  then next.
         for each plani where plani.movtdc = tipmov.movtdc 
                         and plani.dtincl = vdata
                         and plani.etbcod = estab.etbcod
                         and plani.notsit = "F"
                         and plani.horincl <> 0
                       no-lock.
            find opcom  of plani no-lock.

            veof2 = "".
            for each movim of plani no-lock.
                find produ of movim no-lock no-error.
                if not avail produ then next.
                find clase of produ no-lock.
                if clase.setcod = 1 /* dura */
                then
                    if veof2 = "" or veof2 = "11"
                    then veof2 = "11".
                    else veof2 = "19".

                if clase.setcod = 2 /* mole */
                then
                    if veof2 = "" or veof2 = "12"
                    then veof2 = "12".
                    else veof2 = "19".
            end.
            if veof2 = ""
            then veof2 = "19".

            if tipmov.movtdc = 4
            then vopccod = 100.
            else vopccod = plani.opccod.

            find first opcomctb where opcomctb.opccod = vopccod
                                no-lock no-error.
            if not avail opcomctb
            then do.
                /* vendas */
                if plani.opccod = 1
                then do.
                    run cria-mov (plani.opccod,
                                  "1.1.1.1.01.001",
                                  veof2,
                                  yes, /* Debito */
                                  122,
                                  plani.platot).

                    run cria-mov (plani.opccod,
                                  "3.1.1.1.01.001",
                                  veof2,
                                  no, /* Credito */
                                  154,
                                  plani.platot - plani.frete).
                    run cria-mov (plani.opccod,
                                  "3.2.2.1.01.004",
                                  veof2,
                                  no, /* Credito */
                                  153,
                                  plani.frete).
                end.
                else if opcom.opccod = 20
                then do.
                    run cria-mov (plani.opccod,
                                  "1.1.2.1.01.001",
                                  veof2,
                                  yes, /* Debito */
                                  51,
                                  plani.platot + plani.vljurfinanc).

                    run cria-mov (plani.opccod,
                                  "3.1.1.1.01.002",
                                  veof2,
                                  no, /* Credito */
                                  143,
                                  plani.platot - plani.frete - plani.acfserv
                                  - plani.acfprod).
                    run cria-mov (plani.opccod,
                                  "3.2.1.1.01.004",
                                  veof2,
                                  no, /* Credito */
                                  247,
                                  plani.acfprod + plani.vljurfinanc).
                    run cria-mov (plani.opccod,
                                  "3.2.2.1.01.006",
                                  veof2,
                                  no, /* Credito */
                                  332,
                                  plani.acfserv).
                    run cria-mov (plani.opccod,
                                  "3.2.2.1.01.004",
                                  veof2,
                                  no, /* Credito */
                                  245,
                                  plani.frete).
                end.
                else if opcom.opccod = 63
                then do.
                    run cria-mov (plani.opccod,
                                  "1.1.1.7.01.004",
                                  veof2,
                                  yes, /* Debito */
                                  326,
                                  plani.platot + plani.vljurfinanc).

                    run cria-mov (plani.opccod,
                                  "3.1.1.1.01.003",
                                  veof2,
                                  no, /* Credito */
                                  244,
                                  plani.platot - plani.frete - plani.acfserv
                                  + plani.vljurfinanc).
                    run cria-mov (plani.opccod,
                                  "3.2.2.1.01.006",
                                  veof2,
                                  no, /* Credito */
                                  332,
                                  plani.acfserv).
                    run cria-mov (plani.opccod,
                                  "3.2.2.1.01.004",
                                  veof2,
                                  no, /* Credito */
                                  245~,
                                  plani.frete).
                end.
                else next.
            end.

            for each opcomctb where opcomctb.opccod = vopccod no-lock.
                find conta of opcomctb no-lock.
                assign
                    vvalor    = plani.platot
                    vconta    = conta.connum.

                if opcomctb.opctbformula = "frete"
                then vvalor = plani.frete.

                if opcomctb.opctbformula = "platot - frete"
                then vvalor = plani.platot - plani.frete.
/*
                if opcomctb.opctbformula = "juro"
                then vvalor = plani.acfprod + plani.vljurfinanc.

                if opcomctb.opctbformula = "liquido"
                then vvalor = plani.platot - plani.acfprod.

                if opcomctb.opctbformula = "venda"
                then vvalor = plani.platot + plani.vljurfinanc.

                if vvalor = 0
                then next.

                if substr(vconta, 1, 1) = "1" or substr(vconta, 1, 1) = "2"
                then veof2lcto = "".
*/
                /* */
                /* zona franca de manaus linha dura */
                if vopccod = 105 and opcomctb.opctbnat and plani.ufemi = "AM"
                then vconta = "4.1.1.1.01.020".
                /* */

                run cria-mov (vopccod,
                              vconta,
                              veof2,
                              opcomctb.opctbnat,
                              opcomctb.hiscod,
                              vvalor).
/*
                find tt-mov where tt-mov.opccod = vopccod
                              and tt-mov.connum = conta.connum
                              and tt-mov.eof2   = veof2lcto
                            no-error.
                if not avail tt-mov
                then do.
                    vseq = vseq + 1.
                    create tt-mov.
                    assign
                        tt-mov.opccod   = vopccod 
                        tt-mov.connum   = conta.connum
                        tt-mov.seq      = vseq
                        tt-mov.eof2     = veof2lcto
                        tt-mov.opctbnat = opcomctb.opctbnat
                        tt-mov.hiscod   = opcomctb.hiscod.
                end.
                tt-mov.valor = tt-mov.valor + vvalor.

                if opcomctb.opctbnat
                then vtotdeb = vtotdeb + vvalor.
                else vtotcre = vtotcre + vvalor.
*/
            end.
         end. /* plani */
      end. /* estab */
   end. /* tipmov */
end. /* vdata */

find first tt-mov no-lock no-error.
if not avail tt-mov
then do.
    message "Sem movimentos" view-as alert-box.
    return.
end.

def var vdebcre as log.
def var vdesrec as log.
 
output to value(varquivo).
do vdata = vdtini to vdtfin.
    find first tt-lote where tt-lote.data = vdata no-lock no-error.
    if not avail tt-lote
    then next.
    
    /* Header*/
    put unformatted
       "FISCAL"        format "x(15)"
       " "
       vetbcodh        format "x(20)"
       " "
       vcodmov         format "x(30)"
       " "
       "INTVEN"        format "x(15)"
       " "
       string(controle.valor + 1) format "x(10)"
       " "
       "HEADER"        format "x(10)"
       " "
       tt-lote.seq     format "999999"
       " "
       today           format "99999999"
       " "
       tt-lote.totdeb * 100 format "999999999999999999"
       " "
       tt-lote.totcre * 100 format "999999999999999999"
       " "
       vdtini          format "99999999"
       " "             format "x(723)"
       "000001"
       " "
       skip.

    for each tt-mov where tt-mov.data = vdata no-lock.
        assign
            vconta    = tt-mov.connum
            vdebcre   = tt-mov.opctbnat
            veof2     = tt-mov.eof2
            vseq      = tt-mov.seq
            vvalor    = tt-mov.valor.
        vdesrec = substr(vconta, 1, 1) = "3" or substr(vconta, 1, 1) = "4".

        run deparaestab (vetbcod, output vetbcodl).
        
        put unformatted
            "FISCAL"        format "x(15)"
            " "
            vetbcodh        format "x(20)"
            " "
            vcodmov         format "x(30)"
            " "
            "INTVEN"        format "x(15)"
            " "
            string(controle.valor + 1) format "x(10)"
            " "
            "LANCTO"        format "x(10)"
            " "
            vdata           format "99999999"
            " "
            if vdebcre then vconta else ""               format "x(30)"
            " "             format "x(24)"
            if vdebcre then "" else vconta               format "x(30)"
            " "             format "x(24)"
            if vdebcre then vetbcodl else ""             format "x(20)"
            " "
            if vdebcre then "" else vetbcodl             format "x(20)"
            " "
            if vdebcre and vdesrec then "CCUSTO" else "" format "x(6)"
            " "
            if vdebcre and vdesrec then "1901" else ""   format "x(15)"
            " "
            if vdebcre and vdesrec then "LINHA" else ""  format "x(6)"
            " "
            if vdebcre and vdesrec then veof2 else ""    format "x(15)"
            " "             format "x(93)" /* pos 311 ate 403 */
            if vdebcre = no and vdesrec then "CCUSTO" else "" format "x(6)"
            " "
            if vdebcre = no and vdesrec then "1901"   else "" format "x(15)"
            " "
            if vdebcre = no and vdesrec then "LINHA"  else "" format "x(6)"
            " "
            if vdebcre = no and vdesrec then veof2    else "" format "x(15)"
            " "             format "x(93)" /* pos 449 ate 541 */
            vvalor * 100    format "999999999999999999"
            " "
            string(tt-mov.hiscod) format "x(5)"
            " "
            "*LIVRE@."      format "x(119)"
            " "
            " " /*string(plani.numero)*/  format "x(15)"
            " "             format "x(130)" /* pos 702 ate 831 */ 
            "DIV"
            " "             format "x(57)"  /* pos 835 ate 891 */
            vseq            format "999999"
            " "
            skip.

    end.

    /* Trailler */
    put unformatted
        "FISCAL"        format "x(15)"
        " "
        vetbcodh        format "x(20)"
        " "
        vcodmov         format "x(30)"
        " "
        "INTVEN"        format "x(15)"
        " "
        string(controle.valor + 1) format "x(10)"
        " "
        "TRAILLER"      format "x(10)"
        " "             format "x(786)"
        vseq + 1        format "999999"
        " "
        skip.
    controle.valor = controle.valor + 1.
end.
output close.

if opsys = "unix"
then unix silent unix2dos value(varquivo).


message "ARQUIVO GERADO" varquivo "=> Registros =" vseq
        "=> Credito =" vtotcre "Debito =" vtotdeb 
        view-as alert-box.

procedure deparaestab.
    def input  parameter par-de   as int.
    def output parameter par-para as char.

    case par-de: 
        when 100 then par-para = "06003".
        when 101 then par-para = "06001".
        when 102 then par-para = "06002".
    end.
end procedure.

procedure cria-mov.

    def input parameter par-opccod    like opcomctb.opccod.
    def input parameter par-connum    like conta.connum.
    def input parameter par-eof2      as char.
    def input parameter par-opctbnat  like opcomctb.opctbnat.
    def input parameter par-hiscod    like opcomctb.hiscod.
    def input parameter par-valor     as dec.

    def var veof2lcto as char.

    if par-valor = 0
    then return.

    if substr(par-connum, 1, 1) = "1" or substr(par-connum, 1, 1) = "2"
    then veof2lcto = "".
    else veof2lcto = par-eof2.

    find first tt-lote where tt-lote.data = vdata no-error.

    find tt-mov where tt-mov.data   = vdata
                  and tt-mov.opccod = par-opccod
                  and tt-mov.connum = par-connum
                  and tt-mov.eof2   = veof2lcto /* centro de custo */
                no-error.
    if not avail tt-mov
    then do.
        vseq = vseq + 1.
        create tt-mov.
        assign
            tt-mov.data     = vdata
            tt-mov.opccod   = par-opccod
            tt-mov.connum   = par-connum
            tt-mov.seq      = vseq
            tt-mov.eof2     = veof2lcto
            tt-mov.opctbnat = par-opctbnat
            tt-mov.hiscod   = par-hiscod.

        if not avail tt-lote
        then do.
            create tt-lote.
            tt-lote.data = vdata.
        end.
        tt-lote.seq = tt-lote.seq + 1.
    end.
    tt-mov.valor = tt-mov.valor + par-valor.

    if par-opctbnat
    then tt-lote.totdeb = tt-lote.totdeb + par-valor.
    else tt-lote.totcre = tt-lote.totcre + par-valor.

    if par-opctbnat
    then vtotdeb = vtotdeb + par-valor.
    else vtotcre = vtotcre + par-valor.

end procedure.
 
