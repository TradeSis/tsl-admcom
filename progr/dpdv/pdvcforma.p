/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter  par-recid-pdvdoc   as recid.

def var vi as int.
def var vnome as char.
def var vformanome as char.
def var vlistagem as log.
def buffer bfunc for func.
def var vfunape  like func.funape.

def var par-data as date.
def var vdata       as date format "99/99/9999".
def var vforma as char.
def var par-dtini as date.

find pdvdoc where recid(pdvdoc) = par-recid-pdvdoc no-lock.
find pdvmov of pdvdoc no-lock.
find cmon of pdvmov no-lock.
find cmtipo of cmon no-lock.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "," ", "  ","  "].
def var esqcom2         as char format "x(12)" extent 5.

def var crelatorios     as char format "x(30)" extent 5 initial
           ["Vendas",
            "Recebimentos",
            "Moedas",
            ""].
   
def temp-table ttforma
    field seqforma like  pdvforma.seqforma
    field seqfp    like  pdvmoeda.seqfp
    field titpar   like  pdvmoeda.titpar
    field primeiraf as log

    field titnum   like pdvmoeda.titnum
    field titdtven like pdvmoeda.titdtven
    field modcod   like pdvmoeda.modcod.

form        
            ttforma.seqforma  format ">>9"
            vforma format "x(10)" column-label "Forma"
            pdvforma.fincod column-label "Plan"
            pdvforma.valor  column-label "Valor" format ">>>>>9.99"
            pdvmoeda.moecod column-label "MOE"
            space(0) "-" space(0)
            moeda.moenom  format "x(8)"
            ttforma.titnum format "x(13)" column-label "Titulo"
            ttforma.titdtven format "999999" column-label "Venc"
            pdvmoeda.valor format ">>>>>9.99"
            ttforma.modcod column-label "Mod" format "x(3)"
     with frame frame-a 6 down row 12 
                 width 80 no-underline overlay title " Moedas ".

par-data  = pdvmov.datamov.
if par-data <> ?
then vdata = par-data.

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
          
def var vp as log.    
for each pdvforma of pdvmov no-lock
    by pdvforma.seqforma desc.
    create ttforma.
    assign
        ttforma.seqforma  = pdvforma.seqforma
        ttforma.primeiraf = yes.

    vp = yes.
    for each pdvmoeda of pdvforma no-lock.
        if vp
        then vp = no.
        else do:
            create ttforma.
            assign
                ttforma.seqforma  = pdvforma.seqforma
                ttforma.primeiraf = vp.
        end.
        assign
            ttforma.seqfp     = pdvmoeda.seqfp
            ttforma.titpar    = pdvmoeda.titpar.

         assign
                ttforma.titnum = pdvmoeda.titnum +
                                 (if pdvmoeda.titpar = 0
                                  then "" else ("/" + string(pdvmoeda.titpar)))
                ttforma.titdtven = pdvmoeda.titdtven
                ttforma.modcod   = pdvmoeda.modcod.
    end.
end.    

bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first ttforma no-lock no-error.
        else
            find last ttforma no-lock no-error.
    else
        find ttforma where recid(ttforma) = recatu1 no-lock.
    if not available ttforma
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

    recatu1 = recid(ttforma).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        if esqascend
        then find next ttforma no-lock no-error.
        else find prev ttforma no-lock no-error.
        if not available ttforma
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
                    
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find ttforma where recid(ttforma) = recatu1 no-lock.

            status default "".

            assign
                 esqcom1[1] = ""
                 esqcom1[3] = "".

            if ttforma.titnum <> ""
            then esqcom1[1] = " Consulta ".

/***
            if ttforma.primeiraf and
               ttforma.modcod = "CAR"
            then esqcom1[3] = " Estorno ".
***/

            display esqcom1 with frame f-com1.

            color disp messages
                ttforma.seqforma 
                vforma
                pdvforma.fincod 
                pdvforma.valor
                pdvmoeda.moecod
                moeda.moenom  
                ttforma.titnum 
                ttforma.titdtven 
                pdvmoeda.valor
                with frame frame-a.
            
            clear frame frame-moeda all no-pause.
            pause 0.
            vi = 0.

/***
            if pdvmov.statusoper <> "CAN"
            then
            for each pdvmoeda of pdvforma no-lock.
                vi = vi + 1 .
                if vi > 8 then leave.
                run frame-moeda. 
            end.
***/            
            choose field ttforma.seqforma help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".

            color disp normal
                ttforma.seqforma 
                vforma
                pdvforma.fincod 
                pdvforma.valor
                pdvmoeda.moecod
                moeda.moenom  
                ttforma.titnum 
                ttforma.titdtven 
                pdvmoeda.valor
                with frame frame-a.
        end.

        {esquema.i &tabela = "ttforma"
                   &campo  = "ttforma.seqforma"
                   &where  = " "
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                
                if esqcom1[esqpos1] = " Consulta "
                then do.
                    /*
                    find plani where plani.etbcod = pdvforma.etbcod and
                                     plani.placod = pdvforma.placod
                                     no-lock no-error.
                    if avail plani
                    then do:
                        hide frame frame-a no-pause.
                        hide frame frame-moeda no-pause.
                        run not/consnota.p (recid(plani)).
                        leave.
                    end.
                    else do:
                        find titulo where titulo.evecod = pdvforma.titcod
                            no-lock no-error. 
                        if avail titulo
                        then do:
                            hide frame frame-a no-pause.
                            hide frame frame-moeda no-pause.
                            run fqtitulo.p (input recid(titulo)).
                            leave.
                        end.
                    end.                            
                    */

                    find pdvforma of pdvmov 
                              where pdvforma.seqforma = ttforma.seqforma
                            no-lock.

                    find first pdvmoeda of pdvforma
                        where pdvmoeda.seqfp = ttforma.seqfp and
                              pdvmoeda.titpar = ttforma.titpar
                        no-lock no-error.
                    if avail pdvmoeda
                    then do:
                            find first titulo of pdvmoeda no-lock no-error.
                            if avail titulo
                            then do:
                                hide frame frame-a no-pause.
                                hide frame frame-moeda no-pause.
                                run bsfqtitulo.p (input recid(titulo)).
                                leave.
                            end.
                    end.
                end.

                if esqcom1[esqpos1] = " Estorno "
                then do.
                    sresp = no.
                    message "Confirma MARCAR parcelas como estornadas?"
                        update sresp.
                    if sresp
                    then do.
                        run estorno.
                        recatu1 = ?.
                        leave.
                    end.
                end.
                
                if esqcom1[esqpos1] = " Totais "
                then do.
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
                    
                    if frame-index = 1    
                    then
                        run dpdv/pdvtmoe.p (cmon.etbcod,recid(cmon),
                                       par-data,
                                       "VEN").
                    if frame-index = 2    
                    then
                        run dpdv/pdvtmoe.p (cmon.etbcod,recid(cmon),
                                       par-data,
                                       "REC").
                    if frame-index = 3    
                    then
                        run dpdv/pdvtmoe.p (cmon.etbcod,recid(cmon),
                                       par-data,
                                       "").
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do.
                    run listagem.
                    leave.
                end.                
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttforma).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame frame-a          no-pause.


procedure listagem.
/***
vlistagem = yes.
varqsai = "../impress/pdvcmov." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvcmov""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - "" +
                    string(cmtipo.cmtnom) + "" ""
                    + cmon.cxanom + "" "" +
                    "" "" + string(par-data,""99/99/9999"")  "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each pdvmov of cmon where 
        pdvmov.datamov = par-data
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


PROCEDURE frame-a.
            
    find pdvforma of pdvmov where pdvforma.seqforma = ttforma.seqforma no-lock.
    find pdvtforma of pdvforma no-lock no-error.

    vforma = pdvforma.pdvtfcod + "-" + if avail pdvtforma
                                   then pdvtforma.pdvtfnom
                                   else "".

    find first pdvmoeda of pdvforma
            where pdvmoeda.seqfp  = ttforma.seqfp and
                  pdvmoeda.titpar = ttforma.titpar
            no-lock no-error.
    if avail pdvmoeda
    then find moeda of pdvmoeda no-lock no-error.
                                      
    disp
        ttforma.seqforma  when ttforma.primeiraf 
        vforma            when ttforma.primeiraf
        pdvforma.fincod   when ttforma.primeiraf
        pdvforma.valor    when ttforma.primeiraf
        pdvmoeda.moecod   when avail pdvmoeda
        moeda.moenom      when avail moeda
        ttforma.titnum
        ttforma.titdtven
        pdvmoeda.valor    when avail pdvmoeda
        ttforma.modcod
        with frame frame-a.

end procedure.



