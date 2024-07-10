/*

*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio


            substituir    pdvdoc
                          <tab>
*
*/
def var par-dtini as date.
def var vlistagem as log.
def var vnome as char format "x(15)".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Moedas "," Listagem ","", " "," "].
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
find pdvtmov where pdvtmov.ctmcod = par-ctmcod no-lock.

def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdata       as date format "99/99/9999".
def var vdocumento  as char.


find CMon   where recid(CMon) = par-CMon-Recid no-lock.
find cmtipo of cmon no-lock.

form                                                                
     pdvdoc.sequencia  format "->>9"                                    
     pdvdoc.tipo_venda
     pdvdoc.clifor
     vnome format "x(20)"
     pdvdoc.crecod
     pdvdoc.fincod
     vdocumento 
     pdvdoc.valor    
     with frame frame-a 14 down row 4                         
                 width 80 no-underline
                 title pdvtmov.ctmnom.      
form                                                                
     pdvdoc.sequencia  format "->>9"                                    
     pdvdoc.coo                                              
     vnome format "x(40)"
     pdvdoc.valor    
     pdvmov.statusoper
     with frame frame-b down
                 width 80 no-underline
                 title pdvtmov.ctmnom.      


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
def var vtotal as dec.
vtotal = 0.
for each pdvdoc of cmon where 
                                        pdvdoc.datamov = par-data and
                                        pdvdoc.ctmcod  = par-ctmcod
                                        no-lock.
    vtotal = vtotal + pdvdoc.valor.
end.
message "Total " vtotal.
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
            find first pdvdoc of cmon where 
                                        pdvdoc.datamov = par-data and
                                        pdvdoc.ctmcod  = par-ctmcod
                                        no-lock no-error.
        else
            find last pdvdoc of cmon where pdvdoc.datamov = par-data and
                                        pdvdoc.ctmcod = par-ctmcod
                                        no-lock no-error.
    else
        find pdvdoc where recid(pdvdoc) = recatu1 no-lock.
    if not available pdvdoc
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

    recatu1 = recid(pdvdoc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.**/
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next pdvdoc of cmon where pdvdoc.datamov = par-data and
                                           pdvdoc.ctmcod = par-ctmcod                                        no-lock no-error.
        else
            find prev pdvdoc of cmon where pdvdoc.datamov = par-data and
                                           pdvdoc.ctmcod = par-ctmcod  
                                        no-lock no-error.
        if not available pdvdoc
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
            find pdvdoc where recid(pdvdoc) = recatu1 no-lock.
            find pdvmov of pdvdoc no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pdvdoc.datamov)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pdvdoc.datamov)
                                        else "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.

            find pdvtmov of pdvdoc no-lock.
            /* Estorno 
            find bpdvdoc where bpdvdoc.cmocod     = pdvdoc.cmocod and
                               bpdvdoc.cmdcod-est = pdvdoc.cmdcod no-lock
                                                                     no-error.

            if pdvdoc.cmdcod-est <> ? or
               pdvdoc.cmdsit     = no or
               par-movimento = "ABERTOS"  or
               avail bpdvdoc          or
               pdvdoc.cmocod     <> cmon.cmocod
            then esqcom1[2] = "".
            else esqcom1[2] = " Estorno ".
            esqcom1[3] = "".
            */
            
            display esqcom1
                    with frame f-com1.

            color display message pdvdoc.coo
                                  pdvdoc.sequencia
                                  pdvdoc.valor
                                  with frame frame-a.

            choose field pdvdoc.sequencia help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      /*tab*/ PF4 F4 ESC return) .

            color display normal  pdvdoc.coo
                                  pdvdoc.sequencia
                                  pdvdoc.valor
                                  with frame frame-a.

            status default "".

        end.
        {esquema.i &tabela = "pdvdoc"
                   &campo  = "pdvdoc.sequencia"
                   &where  = "pdvdoc.etbcod = cmon.etbcod and
                              pdvdoc.cmocod = cmon.cmocod and
                              pdvdoc.datamov = par-data   and
                              pdvdoc.ctmcod  = par-ctmcod "
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
                 with frame f-pdvdoc color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Moedas "
                then do:
                    run dpdv/pdvtmoe.p (cmon.etbcod, 
                                        recid(cmon),
                                        par-data,
                                        par-data,
                                        par-ctmcod,
                                        par-ctmcod).
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
                    leave.
                end.
                         
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
        recatu1 = recid(pdvdoc).
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
            
        find pdvtmov of pdvdoc no-lock.
        find pdvmov of pdvdoc no-lock.
        
        /*
        vestorno = "".
        if pdvdoc.cmdsit = no
        then vestorno = "Estornado".
        if pdvdoc.cmdcod-est <> ?
        then do:
            find bpdvdoc where bpdvdoc.cmocod = pdvdoc.cmocod and
                                bpdvdoc.cmdcod = pdvdoc.cmdcod-est no-lock
                                                                     no-error.
            find bpdvtmov of bpdvdoc no-lock.
            vestorno = "Estornado - " + " Seq: " +
                        string(bpdvdoc.sequencia) + " Mov. " +
                        string(bpdvdoc.datamov,"99/99/9999").
        end.
        find bpdvdoc where bpdvdoc.cmocod     = pdvdoc.cmocod and
                            bpdvdoc.cmdcod-est = pdvdoc.cmdcod no-lock
                                                                 no-error.
        if avail bpdvdoc
        then vestorno = "Estorno Mov. " + string(bpdvdoc.datamov) +
                                                " Seq " +
                                                string(bpdvdoc.sequencia) .
        */
        
        vnome = "".
        find clien where clien.clicod = int(pdvdoc.clifor) no-lock no-error.
        vnome = if avail clien 
                then clien.clinom
                else "".
                     
        /***
        if pdvmov.ctmcod = "REC"
        then do:
            find titulo where titulo.evecod = pdvdoc.titcod no-lock no-error.
            if avail titulo
            then do:
                vnome = vnome + " " + titulo.modcod + " " +
                        titulo.titnum +
                         if titulo.titpar > 0
                         then ("/" + STRING(titulo.titpar))
                         else "".
            end.
            else do:
                vnome = vnome + " " +
                "    " +
                 pdvdoc.contnum +
                         if pdvdoc.titpar > 0
                         then ("/" + STRING(pdvdoc.titpar))
                         else "".
            end.
        end.
        ***/
        
        vdocumento = "".
        
        if pdvmov.ctmcod = "VEN"
        then do:
            find plani where
                    plani.etbcod = pdvdoc.etbcod and
                    plani.placod = pdvdoc.placod no-lock no-error.
            if avail plani
            then do:
                find opcom where opcom.opccod =  string(plani.opccod) no-lock.
                vdocumento = string(plani.numero).
            end.
        end.
        if pdvdoc.contnum = ""
        then do:
            vdocumento = vdocumento +
                " CONT: " + pdvdoc.contnum.
        end.
        
        /***
        if vlistagem 
        then do:
                display
            pdvdoc.sequencia 
            vhora
            pdvdoc.coo when pdvdoc.coo <> ?
            pdvdoc.valor    format "(>>>>,>>9.99)"   column-label "Total "
            pdvmov.statusoper
                when pdvmov.entsai <> ?
            vnome
                    with frame frame-b.
            down with frame frame-b.
        end.
        else
        ***/

            disp
                pdvdoc.seqreg
                pdvdoc.tipo_venda
                pdvdoc.clifor
                vnome 
                pdvdoc.crecod
                pdvdoc.fincod
                vdocumento 
                pdvdoc.valor    
                    with frame frame-a.

end procedure.



procedure listagem.
/*
vlistagem = yes.
varqsai = "../impress/pdvcdoc." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvcdoc""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - VENDAS "" +
                    string(cmtipo.cmtnom) + "" ""
                    + cmon.cxanom + "" "" +
                    "" "" + string(par-data,""99/99/9999"")  "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each pdvdoc of cmon where 
                                        pdvdoc.datamov = par-data and
                                        pdvdoc.ctmcod  = par-ctmcod
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
*/
end procedure.


