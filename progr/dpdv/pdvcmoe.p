/*

*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio


            substituir    pdvmoe
                          <tab>
*
*/
def var par-dtini as date.
def var vlistagem as log.
def var vnome as char.
def buffer bfunc for func.
def var vfunape  like func.funape.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Totais "," Listagem ","", " "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def var crelatorios     as char format "x(30)" extent 5 initial
           [
            "Lancamento Contabil ",
            "Listagem ",
            "Recibo ",
            "Imp.Cheque",
            ""].

{admcab.i}

def input parameter  par-cmon-recid     as recid.
def input parameter  par-data           as date format "99/99/9999".
def input parameter  par-ctmcod         as char.
def input parameter  par-modcod         as char.    


def var vhora               as  char format "x(5)" label "Hora".
def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdata       as date format "99/99/9999".

find CMon   where recid(CMon) = par-CMon-Recid no-lock.
find cmtipo of cmon no-lock.

form                                                                
     pdvmoe.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmoe.coo                                              
     pdvtmov.ctmnom format "x(08)"
     pdvmoe.moecod column-label "Mod" format "x(03)"
     vnome  format "x(20)"            
     pdvmov.entsai
     pdvmoe.valor
     pdvmov.statusoper
     with frame frame-a 14 down row 4                         
                 width 80 no-underline.


form                                                                
     pdvmoe.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmoe.coo                                              
     pdvtmov.ctmnom format "x(08)"
     pdvmoe.moecod column-label "Mod" format "x(03)"
     vnome  format "x(20)"            
     pdvmov.entsai
     pdvmoe.valor
     pdvmov.statusoper
     with frame frame-b down
                 width 80 no-underline.


def shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

        display cmon.etbcod
                CMon.cxanom
                CMon.cxacod
                cmon.cxadt
                with frame f-CMon.
        vdata = input frame f-cmon cmon.cxadt.

if par-data <> ?
then vdata = par-data.

        display vdata @ CMon.cxadt
                with frame f-CMon.

form
    esqcom1
    with frame f-com1
                 row 21 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

def temp-table tt
    field descrfp as char format "x(20)"
    FIELD valor   as dec.
    
for each pdvmoe of cmon where 
                                        pdvmoe.datamov = par-data 
                                        no-lock .
    find pdvmov of pdvmoe no-lock.
    find first tt where tt.descrfp = pdvmoe.moe no-error.
    if not avail tt then do:
        create tt.
        tt.descrfp = pdvmoe.moecod.
   end.
   tt.valor = tt.valor + pdvmoe.valor.
end.                                        
assign

    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first pdvmoe of cmon where 
                                        pdvmoe.datamov = par-data and
                                      (  if par-modcod = ""
                                        then true
                                        else (pdvmoe.moecod = par-modcod))  and
                                        (if par-ctmcod = ""
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))

                                        no-lock no-error.
        else
            find last pdvmoe of cmon where pdvmoe.datamov = par-data and
                                       ( if par-modcod = ""
                                        then true
                                        else (pdvmoe.moecod = par-modcod))  and
                                      (  if par-ctmcod = ""
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))
                                        
                                        no-lock no-error.
    else
        find pdvmoe where recid(pdvmoe) = recatu1 no-lock.
    if not available pdvmoe
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        message "Nenhuma Movimento".
        pause 1 no-message.
        leave bl-princ.
    end.

    recatu1 = recid(pdvmoe).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.**/
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next pdvmoe of cmon where pdvmoe.datamov = par-data and
                                       ( if par-modcod = ""
                                        then true
                                        else (pdvmoe.moecod = par-modcod)) and
                                       ( if par-ctmcod = ""
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))


                            no-lock no-error.
        else
            find prev pdvmoe of cmon where pdvmoe.datamov = par-data and
                                      (  if par-modcod = ""
                                        then true
                                        else (pdvmoe.moecod = par-modcod)) and
                                     (   if par-ctmcod = ""
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))


                                        no-lock no-error.
        if not available pdvmoe
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
                    
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find pdvmoe where recid(pdvmoe) = recatu1 no-lock.
            find pdvmov of pdvmoe no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pdvmoe.datamov)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pdvmoe.datamov)
                                        else "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.
            /**
            find bfunc where bfunc.funcod = pdvmov.funcod no-lock no-error.
            if avail bfunc
            then
                vfunape = bfunc.funape.
            else
            **/
            
                vfunape = "".
            find pdvtmov of pdvmoe no-lock.
            /* Estorno 
            find bpdvmoe where bpdvmoe.cmocod     = pdvmoe.cmocod and
                               bpdvmoe.cmdcod-est = pdvmoe.cmdcod no-lock
                                                                     no-error.

            if pdvmoe.cmdcod-est <> ? or
               pdvmoe.cmdsit     = no or
               par-movimento = "ABERTOS"  or
               avail bpdvmoe          or
               pdvmoe.cmocod     <> cmon.cmocod
            then esqcom1[2] = "".
            else esqcom1[2] = " Estorno ".
            esqcom1[3] = "".
            */
            
            display esqcom1
                    with frame f-com1.

            color display message pdvmoe.coo
                                  pdvmoe.sequencia
                                  pdvmoe.valor
                                  vhora
                                  with frame frame-a.

            choose field pdvmoe.sequencia help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      /*tab*/ PF4 F4 ESC return) .

            color display normal  pdvmoe.coo
                                  pdvmoe.sequencia
                                  pdvmoe.valor
                                  vhora
                                  with frame frame-a.

            status default "".

        end.
        {esquema.i &tabela = "pdvmoe"
                   &campo  = "pdvmoe.sequencia"
                   &where  = "pdvmoe.etbcod = cmon.etbcod and
                              pdvmoe.cmocod = cmon.cmocod and
                              pdvmoe.datamov = par-data and
                                        (if par-modcod = """"
                                        then true
                                        else (pdvmoe.moecod = par-modcod)) and
                                       ( if par-ctmcod = """"
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))
 "
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvmoe
                 with frame f-pdvmoe color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Totais "
                then do:
                    run dpdv/pdvtmoe.p (cmon.etbcod, recid(cmon),
                                   par-data,
                                   par-data,
                                   "").
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
                    leave.
                end.
                        
                /*
                if esqcom1[esqpos1] = " Relatorios "
                then do.
                    if pdvtmov.programa-listagem <> "" and
                       search(pdvtmov.programa-listagem + ".p") <> ?
                    then crelatorios[2] = "Listagem".
                    else crelatorios[2] = "".
                    if pdvtmov.cmtdimpcheque = yes
                    then crelatorios[4] = "Imp.Cheque".
                    else crelatorios[4] = "".
                    pause 0.
                    display skip(11)
                            with frame fcolor row 10 col 5 width 37 overlay
                                    no-label color message no-box.
                    pause 0.
                    disp skip(1) crelatorios skip(1)
                            with frame frelatorios no-labels 1 col row 11
                                            overlay
                            col 7 width 32
                            title " Relatorios " .
                    choose field crelatorios
                        with frame frelatorios.
                    hide frame fcolor no-pause.
                    hide frame frelatorios no-pause.
                    if frame-index = 1          /* Lancamento contabil   */
                    then
                        run lcmdoc.p (input recid(pdvmoe)).
                    if frame-index = 2          /* Listagem             */
                    then do:
                        if pdvtmov.programa-listagem <> "" and
                           search(pdvtmov.programa-listagem + ".p") <> ?
                        then
                            run value(pdvtmov.programa-listagem + ".p")
                                                    (input recid(pdvmoe)).
                        else
                            run lcmdoc.p (input recid(pdvmoe)).
                    end.
                    if frame-index = 3          /* Recibo             */
                    then run cmdrecib.p (input recid(pdvmoe)).
                    
                    /****
                    if frame-index = 4
                    then do:
                    def var vnominal as char format "x(50)" label "Nominal a".
                    def var vbanco   like banco.bancod.
                    def var vvalor   like titulo.titvlcob.
                    def var cdata    as   date format "99/99/9999".
                    vvalor = 0.
                    for each cmonope of pdvmoe where cmonope.cmopenat = yes
                                                            no-lock.
                        vjurodesc = cmonope.cmopeJuro - cmonope.cmopeDesc.
                        vvalor = vvalor + cmonope.cmopeVlr + vjurodesc.
                    end.
                    cdata = today.
                    vbanco = cmon.bancod.
                    display vvalor       colon 20
                           with frame fcheque centered row 10 side-label
                                            overlay.
                    update
                           vnominal     colon 20
                           cdata    label "Data do Cheque" colon 20
                           with frame fcheque centered row 10 side-label
                                            overlay.
                    vnominal = caps(vnominal).
                    output to ../impress/cheque.
                    put unformatted chr(27) + chr(13).
                    put unformatted chr(27) + chr(160) + vnominal + chr(13).
                    put unformatted chr(27) + chr(161) +
                                                "Porto Alegre" + chr(13).
                    put unformatted chr(27) + chr(162) +
                                                string(vbanco,"999") + chr(13).
                    put unformatted chr(27) + chr(163) +
                                    string(truncate(vvalor,0)) + "," +
                                    substring(string(vvalor,"9999999999.99"),12)
                                     + chr(13).
                    put unformatted chr(27) + chr(164) +
                                    string(day(cdata),"99") + "/" +
                                     string(month(cdata),"99") + "/" +
                                     string(year(cdata) - 1900,"99") +
                                     chr(13).
                    put unformatted chr(27) + chr(176).
                    output close.
                    unix silent lp -s -dcheque ../impress/cheque.
                    end.
                    ****/
                end.
                if esqcom1[esqpos1] = " Baixa " and
                   par-movimento = "ELETRONICO"
                then do.
                    run baixa-eletronico.
                        recatu1 = ?.
                        leave.

                end.
                                      
                if esqcom1[esqpos1] = " Estorno "
                then do with frame f-pdvmoe on error undo.
                    run cmdest.p (input recid(pdvmoe)).
                    leave.
                end.                    
                if esqcom1[esqpos1] = " Confirma "
                then do with frame f-pdvmoe on error undo.
                    find pdvmoe where recid(pdvmoe) = recatu1.
                    find pdvmoe where recid(pdvmoe) = pdvmoe.rec.
                    pdvmoe.cmddtconf-tra = pdvmoe.datamov.
                    for each cmonope of pdvmoe.
                        if pdvtmov.cmtdtransf and
                           cmonope.codcod = pdvmoe.cmocod-tra
                           and 
                           (cmon.cmtcod = "CAI" or cmon.cmtcod = "BAN") 
                        then /* Contabiliza a Parte Destino */
                            run cgmodsal.p (input cmon.cmtcod /***RM 05/04/06 cmonope.modcod***/,
                                            input cmonope.codcod,
                                            input pdvmoe.datamov,
                                            input cmonope.cmopenat,
                                            input if pdvmoe.cmdsit = no
                                                  then (cmonope.cmopevlr * -1)
                                                  else cmonope.cmopevlr).
                        find modal of cmonope no-lock.
                        find titulo of cmonope no-lock no-error.
                        if avail titulo
                        then do:
                            if modal.asscod = "C" and
                                cmon.cmtcod = "CAI"
                             then do:
                                if cmonope.codcod = pdvmoe.cmocod-tra
                                then do:
                                    create cmontit.
                                    assign
                                        cmontit.cmocod = pdvmoe.cmocod-tra
                                        cmontit.titcod = cmonope.titcod.
                                end.
                            end.
                        end.
                    end.
                    leave.
                end.                    
                Fim esqcom1 */
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        /*else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(pdvmoe).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame f-com2           no-pause.
hide frame frame-a          no-pause.
hide frame frame-esquerda   no-pause.
hide frame frame-direita    no-pause.
hide frame f-banco          no-pause.
hide frame f-cmon           no-pause.
hide frame separa           no-pause.
hide frame separa2          no-pause.
hide frame frelatorios      no-pause.
hide frame fcolor           no-pause.

PROCEDURE frame-a.
            
        find pdvtmov of pdvmoe no-lock.
        find pdvmov of pdvmoe no-lock.
        
        /*
        vestorno = "".
        if pdvmoe.cmdsit = no
        then vestorno = "Estornado".
        if pdvmoe.cmdcod-est <> ?
        then do:
            find bpdvmoe where bpdvmoe.cmocod = pdvmoe.cmocod and
                                bpdvmoe.cmdcod = pdvmoe.cmdcod-est no-lock
                                                                     no-error.
            find bpdvtmov of bpdvmoe no-lock.
            vestorno = "Estornado - " + " Seq: " +
                        string(bpdvmoe.sequencia) + " Mov. " +
                        string(bpdvmoe.datamov,"99/99/9999").
        end.
        find bpdvmoe where bpdvmoe.cmocod     = pdvmoe.cmocod and
                            bpdvmoe.cmdcod-est = pdvmoe.cmdcod no-lock
                                                                 no-error.
        if avail bpdvmoe
        then vestorno = "Estorno Mov. " + string(bpdvmoe.datamov) +
                                                " Seq " +
                                                string(bpdvmoe.sequencia) .
        */
        
        vhora = string(pdvmov.horamov,"HH:MM").
        find titbsmoe of pdvmoe no-lock no-error.
        
        vnome = if avail titbsmoe
                then     if titbsmoe.titnum <> ""
                then titbsmoe.titnum + 
                        if pdvmoe.titpar > 0
                        then ("/" + string(pdvmoe.titpar))
                        else ""
                else ""
                else "".
        vnome = vnome +
                    if avail titbsmoe and        
                       titbsmoe.titdtven <> ?
                    then (" Venc: " + string(titbsmoe.titdtven,"99.99.99"))
                    else "".

        if vlistagem
        then do:
        display
            pdvmoe.sequencia 
            vhora
            pdvmoe.coo 
            pdvtmov.ctmnom 
            pdvmov.entsai
            pdvmoe.valor 
            pdvmov.statusoper
                when pdvmov.entsai <> ?
            pdvmoe.moecod
            vnome
                    with frame frame-b.
            down with frame frame-b.                    

        end.
        else
        display
            pdvmoe.sequencia
            vhora
            pdvmoe.coo 
            pdvtmov.ctmnom 
            pdvmov.entsai
            pdvmoe.valor 
            pdvmov.statusoper
                when pdvmov.entsai <> ?
            pdvmoe.moecod
            vnome
                    with frame frame-a.

end procedure.

def var varqsai as char.
procedure listagem.


/**

vlistagem = yes.
varqsai = "../impress/pdvcdoc." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvcdoc""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - "" +
                    string(cmtipo.cmtnom) + "" ""
                    + cmon.cxanom + "" "" +
                    "" "" + string(par-data,""99/99/9999"")  "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each pdvmoe of cmon where 
                                        pdvmoe.datamov = par-data and
                                        (if par-modcod = ""
                                        then true
                                        else (pdvmoe.moecod = par-modcod))  and
                                      (  if par-ctmcod = ""
                                        then true
                                        else (pdvmoe.ctmcod = par-ctmcod))
                                        
                                        no-lock.
    run frame-a.
end.

{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """LISCMD"""
    &Page-Size = "64"
    &Width     = "80"
    &Traco     = "80"
    &Form      = "frame f-rod3"}.
vlistagem = no.
**/

end procedure.



