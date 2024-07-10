/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vhora               as  char format "x(5)" label "Hora".
def var vdocumento as char.
def var vi as int.
def var vnome as char.
def var vlistagem as log.
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
    initial [" Consulta "," Moedas "," ", "  ","  "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def var crelatorios     as char format "x(30)" extent 5 initial
           ["Vendas",
            "Recebimentos",
            "Moedas",
            ""].

def input parameter  par-recid-pdvmov   as recid.
def var par-data as date.

def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdata       as date format "99/99/9999".

find pdvmov where recid(pdvmov) = par-recid-pdvmov no-lock.
find cmon of pdvmov no-lock.
find cmtipo of cmon no-lock.
par-data  = pdvmov.datamov.

form                                                                
     pdvmov.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmov.coo                
     pdvmov.ctmcod  column-label "TT"
     pdvtmov.ctmnom format "x(5)"
     pdvmov.codigo_operador column-label "Oper" format "x(06)"
     func.funape format "x(6)"
     pdvmov.valortot    format "(>>>>,>>9.99)"   column-label "Total "  
     pdvmov.valortroco format "->>>9.99" column-label "Troco"
     pdvmov.statusoper format "x(3)" 
     with frame fmov 1 down row 4 overlay  no-box                      
                 width 80 no-underline.      

form   
     pdvdoc.seqreg  format ">9" column-label "Sq"
     pdvdoc.tipo_venda column-label "TV"
     pdvdoc.clifor column-label "Cliente"
     vnome format "x(20)" column-label "Nome"
     pdvdoc.crecod column-label "Cnd" format ">>9"
/**     pdvdoc.fincod column-label "Pla" format ">>9"**/
     vdocumento column-label "Documento" format "x(18)"
     pdvdoc.valor
     pdvdoc.modcod column-label "Mod"
     with frame frame-a 3 down row 6                         
                 width 80 no-underline overlay
                 title pdvtmov.ctmnom.      
    
def temp-table ttforma
    field seqforma like  pdvforma.seqforma
    field seqfp    like  pdvmoeda.seqfp
    field titpar   like  pdvmoeda.titpar
    field primeiraf as log.

def var vp as log.    
for each pdvforma of pdvmov no-lock
    by pdvforma.seqforma desc.
    create ttforma.
    ttforma.seqforma = pdvforma.seqforma.
    ttforma.primeiraf = yes.
    vp = yes.
    for each pdvmoeda of pdvforma no-lock.
        if vp
        then do:
            ttforma.seqfp = pdvmoeda.seqfp.
            ttforma.titpar = pdvmoeda.titpar.
            ttforma.primeiraf = vp.
            vp = no.
        end.
        else do:
            create ttforma.
            ttforma.seqforma = pdvforma.seqforma.
            ttforma.seqfp    = pdvmoeda.seqfp.
            ttforma.titpar   = pdvmoeda.titpar.
            ttforma.primeiraf = no.
        end.
    end.
end.    
def var vforma as char.
def var vtitnum as char format "x(13)".
  
form        
            ttforma.seqforma  format ">>9"
            vforma format "x(10)" column-label "Forma"
            pdvforma.fincod column-label "Plan"
            pdvforma.valor column-label "Valor"
            pdvmoeda.moecod column-label "MOE"
            space(0) "-" space(0)
            moeda.moenom  format "x(8)"
            vtitnum format "x(13)" column-label "Titulo"
            pdvmoeda.titdtven format "999999" column-label "Venc"
            pdvmoeda.valor
     with frame frame-forma 6 down row 12
                no-underline overlay width 80
                 title " Moedas ".

def var par-dtini as date.
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

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
          
    find pdvtmov of pdvmov no-lock.
    find func where func.funcod = int(pdvmov.codigo_operador) no-lock no-error.
        pause 0.

        vhora = string(pdvmov.horamov,"HH:MM").

        display
            pdvmov.sequencia 
            vhora
            pdvmov.coo 
            pdvmov.ctmcod
            pdvtmov.ctmnom when avail pdvtmov
            pdvmov.codigo_operador
            func.funape when avail func
            pdvmov.valortot
            pdvmov.valortroco
            pdvmov.statusoper
                    with frame fmov.

bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first pdvdoc of pdvmov
                                        no-lock no-error.
        else
            find last pdvdoc of pdvmov
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
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next pdvdoc of pdvmov
                                        no-lock no-error.
        else
            find prev pdvdoc of pdvmov
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
            find bfunc where bfunc.funcod = int(pdvmov.codigo_operador) 
                    no-lock no-error.
            if avail bfunc
            then
                vfunape = bfunc.funape.
            else
                vfunape = "".
            find pdvtmov of pdvdoc no-lock.
            if pdvtmov.novacao
            then esqcom1[3] = " Novacao".
            else esqcom1[3] = "". 
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

            color display message 
                 pdvdoc.seqreg  
                 pdvdoc.tipo_venda 
                 pdvdoc.clifor 
                 vnome
                 pdvdoc.crecod 
                 vdocumento 
                 pdvdoc.valor    
                                  with frame frame-a.

            clear frame frame-forma all no-pause.
            pause 0.
            vi = 0.
            
            for each ttforma.
                vi = vi + 1 .
                if vi > 6 then leave.
                run frame-forma. 
            end.
            
            choose field pdvdoc.seqreg help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .

            color display normal 
                 pdvdoc.seqreg  
                 pdvdoc.tipo_venda 
                 pdvdoc.clifor 
                 vnome
                 pdvdoc.crecod 
                 vdocumento 
                 pdvdoc.valor    
                                  with frame frame-a.

            status default "".


        end.
        {esquema.i &tabela = "pdvdoc"
                   &campo  = "pdvdoc.seqreg"
                   &where  = "of pdvmov"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                
                if esqcom1[esqpos1] = " Novacao "
                then do.
                    hide frame  frame-a no-pause.
                        hide frame fmov no-pause.
                        hide frame frame-a no-pause.
                        hide frame frame-forma no-pause.
                        hide frame f-com1 no-pause.
                        hide frame f-com2 no-pause.

                    find pdvtmov where pdvtmov.ctmcod = pdvmov.ctmcod no-lock.
                    if pdvtmov.novacao
                    then run fin/fqnovmov.p (recid(pdvmov)).
                    leave.
                end.

                if esqcom1[esqpos1] = " Consulta "
                then do.
                    find first plani where plani.etbcod = pdvdoc.etbcod and
                                     plani.placod = pdvdoc.placod
                                     no-lock no-error.
                    if avail plani
                    then do:
                        hide frame fmov no-pause.
                        hide frame frame-a no-pause.
                        hide frame frame-forma no-pause.
                        hide frame f-com1 no-pause.
                        hide frame f-com2 no-pause.
                        run not_consnota.p (recid(plani)).
                        view frame fmov.
                        leave.
                    end.
                    else do:
                        find titulo where 
                            titulo.contnum = int(pdvdoc.contnum) and
                            titulo.titpar  = pdvdoc.titpar
                                no-lock no-error.
                        if avail titulo
                        then do:
                            hide frame fmov no-pause.
                            hide frame frame-a no-pause.
                            hide frame frame-forma no-pause.
                        hide frame f-com1 no-pause.
                        hide frame f-com2 no-pause.
                            
                            run bsfqtitulo.p (input recid(titulo)).
                            view frame fmov.
                            leave.
                        end.
                    end.                            
                end.

                if esqcom1[esqpos1] = " Moedas "
                then do:
                    hide frame frame-forma no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run dpdv/pdvcforma.p (input recid(pdvdoc)).
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
                
                /*
                if esqcom1[esqpos1] = " Baixa " and
                   par-movimento = "ELETRONICO"
                then do.
                    run baixa-eletronico.
                        recatu1 = ?.
                        leave.
                end.
                                      
                if esqcom1[esqpos1] = " Estorno "
                then do with frame f-pdvdoc on error undo.
                    run cmdest.p (input recid(pdvdoc)).
                    leave.
                end.                    
                if esqcom1[esqpos1] = " Confirma "
                then do with frame f-pdvdoc on error undo.
                    find pdvdoc where recid(pdvdoc) = recatu1.
                    find pdvdoc where recid(pdvdoc) = pdvdoc.rec.
                    pdvdoc.cmddtconf-tra = pdvdoc.datamov.
                    for each cmonope of pdvdoc.
                        if pdvtmov.cmtdtransf and
                           cmonope.codcod = pdvdoc.cmocod-tra
                           and 
                           (cmon.cmtcod = "CAI" or cmon.cmtcod = "BAN") 
                        then /* Contabiliza a Parte Destino */
                            run cgmodsal.p (input cmon.cmtcod /***RM 05/04/06 cmonope.modcod***/,
                                            input cmonope.codcod,
                                            input pdvdoc.datamov,
                                            input cmonope.cmopenat,
                                            input if pdvdoc.cmdsit = no
                                                  then (cmonope.cmopevlr * -1)
                                                  else cmonope.cmopevlr).
                        find modal of cmonope no-lock.
                        find titulo of cmonope no-lock no-error.
                        if avail titulo
                        then do:
                            if modal.asscod = "C" and
                                cmon.cmtcod = "CAI"
                             then do:
                                if cmonope.codcod = pdvdoc.cmocod-tra
                                then do:
                                    create cmontit.
                                    assign
                                        cmontit.cmocod = pdvdoc.cmocod-tra
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
        recatu1 = recid(pdvdoc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame frame-a          no-pause.
hide frame frame-esquerda   no-pause.
hide frame frame-direita    no-pause.
hide frame f-banco          no-pause.
hide frame f-cmon           no-pause.
hide frame separa           no-pause.
hide frame separa2          no-pause.
hide frame frelatorios      no-pause.
hide frame fcolor           no-pause.

hide frame fmov no-pause.
hide frame frame-forma no-pause.
/* 1 aqui */

PROCEDURE frame-a.
            
            
        find pdvtmov of pdvdoc no-lock.
        find pdvmov of pdvdoc no-lock.
      /***  find pdvtforma of pdvdoc no-lock no-error.***/
        
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
        find clien where clien.clicod = pdvdoc.clifor no-lock no-error.
        vnome = if avail clien 
                then clien.clinom
                else "".
        
        vdocumento = "".
        
        if pdvmov.ctmcod = "VEN"
        then do:
            find plani where
                    plani.etbcod = pdvdoc.etbcod and
                    plani.placod = pdvdoc.placod no-lock no-error.
            if avail plani
            then do:
                vdocumento = "V" + string(plani.numero).
            end.
        end.
        if pdvdoc.contnum <> ""
        then do:
            find titulo where 
                    titulo.contnum = int(pdvdoc.contnum) and
                    titulo.titpar  = pdvdoc.titpar
                    no-lock no-error.
            vdocumento = vdocumento +
                (if vdocumento = ""
                 then ""
                 else "/" )
                + pdvdoc.contnum
                + (if pdvdoc.titpar = 0
                  then ""
                  else "/" + string(pdvdoc.titpar))
                + (if avail titulo
                   then ""
                   else "*").
        end.
                
                
pause 0.
            disp
                pdvdoc.seqreg
                pdvdoc.tipo_venda
                pdvdoc.clifor
                vnome 
                pdvdoc.crecod
/**                pdvdoc.fincod**/
                vdocumento 
                pdvdoc.valor    
                pdvdoc.modcod
                    with frame frame-a.


end procedure.


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



PROCEDURE frame-forma.
            
            
        find pdvforma of pdvmov
            where pdvforma.seqforma = ttforma.seqforma
            no-lock.
        find pdvtforma of pdvforma no-lock no-error.

        vforma = pdvforma.pdvtfcod + "-" + if avail pdvtforma
                                   then pdvtforma.pdvtfnom
                                   else "".

        find first pdvmoeda of pdvforma
            where pdvmoeda.seqfp = ttforma.seqfp and
                  pdvmoeda.titpar = ttforma.titpar
            no-lock no-error.
        vtitnum = "".
        if avail pdvmoeda
        then do:
            find moeda of pdvmoeda no-lock no-error.
            vtitnum = pdvmoeda.titnum +
                        (if pdvmoeda.titpar = 0
                         then ""
                     else ("/" + string(pdvmoeda.titpar))).
        end.
                                      
        disp
            ttforma.seqforma  when ttforma.primeiraf 
            vforma            when ttforma.primeiraf
            pdvforma.fincod   when ttforma.primeiraf
            pdvforma.valor    when ttforma.primeiraf
            pdvmoeda.moecod  when avail pdvmoeda
            moeda.moenom when avail moeda
            vtitnum
            pdvmoeda.titdtven when avail pdvmoeda
            pdvmoeda.valor when avail pdvmoeda

                    with frame frame-forma.
        down with frame frame-forma.
        
end procedure.


