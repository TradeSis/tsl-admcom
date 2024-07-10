{admcab.i}
def input parameter p-recid as recid.

def var vcompl as char.
def var vnumlan as int.
def buffer blancxa for lancxa.
def var scxacod as int.
def var vformpaga as int.
pause 0.
for each formpag no-lock:
        disp string(formpag.codigo,">>>>>>>>9") + " - " + formpag.descricao 
                format "x(30)"
            with frame f-formpag down
            column 35 no-label width 35
            title " FORMAS DE PAGAMENTO " overlay row 5.
end.
    
update vformpaga label "Pagamento"
help "Informe o codigo fa FORMA DE PAGAMENTO"
        with frame f-inpag overlay row 5.        
find first formpag where
               formpag.codigo = vformpaga
               no-lock no-error.
    if not avail formpag
    then do:
        message color red/with
               "Forma de pagamento nao cadastrada."
               view-as alert-box
               .
        undo.
    end. 
    
hide frame f-formap.
hide frame f-inpag.

if keyfunction(lastkey) = "END-ERROR"
then return.

def buffer btitulo for titulo.

find titulo where recid(titulo) = p-recid
                          no-lock no-error.
if avail titulo
then do:                          

    find forne where forne.forcod = titulo.clifor no-lock no-error.

                find first fatudesp where
                               fatudesp.clicod = titulo.clifor and
                               fatudesp.fatnum = int(titulo.titnum)
                               no-lock no-error.
                if avail fatudesp
                then do on error undo:
                    run pag-tit-desp.
                end.
                else if today >= 09/01/13
                    then do on error undo:
                        vcompl  = titulo.titnum + "-" + string(titulo.titpar)
                                                + " " + forne.fornom.
                        run pag-titulo.
                    end. 
                    
end.

procedure pag-tit-desp:
              
    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
    if avail lancactb
    then do:
        find forne where forne.forcod = fatudesp.clicod no-lock no-error.
        if avail forne
        then vcompl = string(titulo.titnum) + "-" + string(titulo.titpar)
                                            + " " + forne.fornom.
        else vcompl = string(titulo.titnum) + "-" + string(titulo.titpar).
         
        run lan-contabil("CAIXA",
                            lancactb.contacre,
                            formpag.contacre,
                            fatudesp.modctb,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            fatudesp.clicod,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int1,
                            vcompl,
                            "C").
    end. 
    run gera-titpag.
                               
end procedure. 

procedure pag-titulo:
              
    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    
    if avail lancactb
    then do:
        if titulo.agecod <> "FRETE"
        then
        run lan-contabil("CAIXA",
                            lancactb.contacre,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int1,
                            vcompl,
                            "C").
        if titulo.agecod = "FRETE"
        then
        run lan-contabil("CAIXA",
                            "559",
                            lancactb.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int1,
                            vcompl,
                            "C").


        if titulo.titvljur > 0 
        then do:
            run lan-contabil("CAIXA",
                            228,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvljur,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            13,
                            vcompl,
                            "C").

        end.    
                        
        if titulo.titvldes > 0 
        then do:
            run lan-contabil("CAIXA",
                            235,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvljur,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            12,
                            vcompl,
                            "D").
        end.
    end.    
    run gera-titpag.
end procedure. 

procedure lan-contabil:

    def buffer elancxa for lancxa.
    
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like titulo.clifor.
    def input parameter l-titnum like titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.
    def input parameter l-lantipo as char.

    if l-tipo = "CAIXA"
    THEN
    do :

            find first elancxa where 
                       elancxa.cxacod = lancactb.contadeb and
                       elancxa.modcod = l-modcod and
                       elancxa.forcod = l-forcod and
                       elancxa.titnum = l-titnum and
                       elancxa.lantip = "X"
                        no-error.
            if avail elancxa 
            then do on error undo:
                if month(titulo.titdtpag) = month(titulo.titdtemi) and
                   year(titulo.titdtpag) = year(titulo.titdtemi)
                then delete elancxa.
                else if lancactb.contadeb > 0
                then l-landeb = elancxa.lancod.
            end.
            else. /* l-landeb = lancactb.contadeb.*/
 
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.etbcod = l-etbcod and
                       lancxa.comhis = l-hiscomp and
                       lancxa.lantip = "C"
                        no-error.
            if not avail lancxa
            then do:            

            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-landeb
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-lancre
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = "C"
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
        else disp lancxa.
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO :
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.comhis = l-hiscomp and
                       lancxa.lantip = "X"
                        no-error.
            if not avail lancxa
            then do: 
                find last blancxa use-index ind-1
                        where blancxa.numlan <> ? no-lock no-error.
                if not avail blancxa
                then vnumlan = 1.
                else vnumlan = blancxa.numlan + 1.
 
                create lancxa.
                assign
                    lancxa.numlan = vnumlan
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-landeb
                    lancxa.lancod = l-lancre
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
end procedure.
 
procedure gera-titpag:
    find first titpag where
               titpag.empcod = titulo.empcod and
               titpag.titnat = titulo.titnat and
               titpag.modcod = titulo.modcod and
               titpag.etbcod = titulo.etbcod and
               titpag.clifor = titulo.clifor and
               titpag.titnum = titulo.titnum and
               titpag.titpar = titulo.titpar and
               titpag.moecod = string(formpag.codigo)
               no-error.
    if not avail titpag
    then do:
        create titpag.
        assign
            titpag.empcod = titulo.empcod
            titpag.titnat = titulo.titnat
            titpag.modcod = titulo.modcod
            titpag.etbcod = titulo.etbcod
            titpag.clifor = titulo.clifor
            titpag.titnum = titulo.titnum
            titpag.titpar = titulo.titpar
            titpag.moecod = string(formpag.codigo)
            titpag.titvlpag = titulo.titvlpag 
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
    else do:
        assign
            titpag.titvlpag = titulo.titvlpag 
            titpag.moecod = string(formpag.codigo)
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
end procedure. 
