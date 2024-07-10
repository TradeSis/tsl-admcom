/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio


            substituir    pdvmov
                          <tab>
*
*/

def var par-dtini as date.
def var vlistagem as log.
def var vvalor as dec.
def var vmodnom as char.
def var vseq as int.
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
    initial [" Listagem "," ","", " "," "].
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

{cabec.i}

def input parameter  par-cmon-recid     as recid.
def input parameter  par-data           as date format "99/99/9999".

def var vhora               as  char format "x(5)" label "Hora".
def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdata       as date format "99/99/9999".

find CMon   where recid(CMon) = par-CMon-Recid no-lock.
find cmtipo of cmon no-lock.

def temp-table ttmoeda
    field seq as int 
    field modcod    like modal.modcod
    field descrfp as char format "x(20)"
    FIELD valor   as dec  format "->>>,>>>,>>9.99"
    index x is unique primary  descrfp asc seq asc.
 
form            
    ttmoeda.descrfp
    ttmoeda.modcod
    vmodnom format "x(20)"
    ttmoeda.valor
     with frame frame-a 14 down row 5 
                  centered color messages
                 overlay.
 
form            
    ttmoeda.descrfp
    ttmoeda.modcod
    vmodnom format "x(20)"
    ttmoeda.valor
     with frame frame-b down.
     
                 
pause 0.
def shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV"
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

vseq = 0.   
for each pdvsal of cmon where 
                                        pdvsal.datamov = par-data 
                                        no-lock 
        break
              by pdvsal.descrfp.

    find first ttmoeda where 
            ttmoeda.descrfp = pdvsal.descrfp and
            ttmoeda.modcod = pdvsal.modcod no-error.
    if not avail ttmoeda then do:
        vseq = vseq + 1.
        create ttmoeda.
        ttmoeda.seq = vseq.
        ttmoeda.modcod = pdvsal.modcod.
        ttmoeda.descrfp = pdvsal.descrfp.
   end.
   ttmoeda.valor = ttmoeda.valor + pdvsal.valor.

    /*find first ttmoeda where 
            ttmoeda.descrfp = pdvsal.descrfp and
            ttmoeda.modcod = "              Total:" no-error.
    if not avail ttmoeda then do:
        create ttmoeda.
        ttmoeda.seq = 99.
        ttmoeda.modcod = "              Total:".        
        ttmoeda.descrfp = pdvsal.descrfp.
        
   end.
   ttmoeda.valor = ttmoeda.valor + pdvsal.valor.
      */
/*    if par-ctmcod = ""
    then do:
        
       vvalor = if pdvmov.entsai 
                 then pdvsal.valor
                 else (pdvsal.valor * -1).
         find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.modcod = "" no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "MOEDAS".
            ttmoeda.modcod = "".
            ttmoeda.descrfp = "".
       end.
        
        find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.modcod = pdvsal.modcod no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "".
            ttmoeda.modcod = pdvsal.modcod.
            ttmoeda.descrfp = "". /*pdvsal.descrfp.*/
       end.
       ttmoeda.valor = ttmoeda.valor + vvalor.

        find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.modcod = "              Total:"
                no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = 99.
            ttmoeda.modcod = "              Total:".
            ttmoeda.descrfp = "              Total:".
       end.
        ttmoeda.valor = ttmoeda.valor + vvalor.
    end.
*/
   
end.                                        

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    esqascend = yes.
bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first ttmoeda 
                                        no-lock no-error.
        else
            find last ttmoeda
                                        no-lock no-error.
    else
        find ttmoeda where recid(ttmoeda) = recatu1 no-lock.
    if not available ttmoeda
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

    recatu1 = recid(ttmoeda).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.**/
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next ttmoeda where true
                                        no-lock no-error.
        else
            find prev ttmoeda where true
                                        no-lock no-error.
        if not available ttmoeda
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
            find ttmoeda where recid(ttmoeda) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttmoeda.descrfp)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttmoeda.descrfp)
                                        else "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.
            
            display esqcom1
                    with frame f-com1.
            color disp normal
                ttmoeda.modcod
                vmodnom 
                ttmoeda.valor
                with frame frame-a.
                                choose field ttmoeda.descrfp help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      /*tab*/ PF4 F4 ESC return) 
                      color normal.
            color disp messages
                ttmoeda.modcod
                vmodnom 
                ttmoeda.valor
                with frame frame-a.
                     
            status default "".

        end.
        {esquema.i &tabela = "ttmoeda"
                   &campo  = "ttmoeda.descrfp"
                   &where  = "true"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttmoeda
                 with frame f-ttmoeda color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                /*        
                if esqcom1[esqpos1] = " Analitico "
                then do:
                    if ttmoeda.ctmcod = "ZMOE"
                    then do:
                        run pdvcmoe.p (recid(cmon),
                                       par-data,
                                       "",
                                       ttmoeda.modcod).
                    end.
                    else do:
                        if ttmoeda.modcod <> ""
                        then do:
                            run pdvcmoe.p (recid(cmon),
                                           par-data,
                                           ttmoeda.ctmcod,
                                           ttmoeda.modcod).
                        end.
                        else do:
                            run pdvcdoc.p (recid(cmon),
                                           par-data,
                                           ttmoeda.ctmcod). 
                        end.
                    end.
                end.
                */
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
        recatu1 = recid(ttmoeda).
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
            
        find modal of ttmoeda no-lock no-error.
        vmodnom = if avail modal 
                  then modal.modnom
                  else ttmoeda.modcod.

        if vlistagem
        then do:
        display
            ttmoeda.modcod
            vmodnom
            ttmoeda.descrfp
            ttmoeda.valor when ttmoeda.valor <> 0
                    with frame frame-b no-labels.
            down with frame frame-b.
        end.
        else
        display
            ttmoeda.modcod
            vmodnom
            ttmoeda.descrfp
            ttmoeda.valor when ttmoeda.valor <> 0
                    with frame frame-a no-labels.

end procedure.



procedure listagem.
vlistagem = yes.
varqsai = "../impress/pdvtmoe." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvtmov""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - "" +
                    string(cmtipo.cmtnom) + "" ""
                    + cmon.cxanom + "" "" +
                    "" "" + string(par-data,""99/99/9999"")  "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each ttmoeda where true.
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
end procedure.




