{admcab.i}
def var vtitnum like titulo.titnum.
def var vclifor like titulo.clifor.
def var vformpaga as int.
def var vcompl as char.
def var v-lancactb as log.
def var vtitnat like titulo.titnat.
vtitnat = yes.

def var vltcrecod like lotcre.LtCreCod format ">>>>>>>>>9".

def buffer blancxa for lancxa.
def var vnumlan like lancxa.numlan.
def var vinclusao as date.
update vltcrecod label "Lote"
    with frame f-lote 1 down side-label width 80.
    
find lotcre where lotcre.LtCreCod = vLtCreCod no-lock.

procedure form-pag:
for each formpag where formpag.tipo = "" no-lock:
        disp string(formpag.codigo,">>>>>>>>9") + " - " + formpag.descricao 
                format "x(30)"
            with frame f-formpag down
            column 35 no-label width 35
            title " FORMAS DE PAGAMENTO ".
    end.
    update vformpaga label "Pagamento"
    help "Informe o codigo da FORMA DE PAGAMENTO".        
    find first formpag where
               formpag.tipo = "" and
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
end procedure.

do:  
  
for each lotcretit of lotcre no-lock:
    find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-lock no-error.
    if not avail titulo 
    then  next.
               

    find forne where forne.forcod = titulo.clifor
                        no-lock no-error.

    find first titpag where
               titpag.empcod = titulo.empcod and
               titpag.titnat = titulo.titnat and
               titpag.modcod = titulo.modcod and
               titpag.etbcod = titulo.etbcod and
               titpag.clifor = titulo.clifor and
               titpag.titnum = titulo.titnum and
               titpag.titpar = titulo.titpar
                 no-lock no-error.
    
    /*
    find first formpag where
               formpag.tipo = "" and
               formpag.codigo = int(titpag.moecod)
               no-lock no-error.
    if not avail formpag
    then do:
        run form-pag.
        find first formpag where
            formpag.tipo = "" and
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
    end. 
    */
    find first formpag where
            formpag.tipo = "" and
            formpag.codigo = 107
            no-lock no-error.
 
    find first fatudesp use-index indx3 where
                               /*fatudesp.etbcod = titulo.etbcod and*/ 
                               fatudesp.inclusao = titulo.titdtemi and
                               fatudesp.clicod = titulo.clifor and
                               fatudesp.fatnum = int(titulo.titnum) 
                               no-lock no-error.
    if avail fatudesp 
    then do:
        disp titulo.titdtpag titulo.titvlpag. pause 0.
        find first lancxa where
                   lancxa.cxacod = formpag.codigo and
                   lancxa.forcod = fatudesp.clicod and
                   lancxa.titnum = string(fatudesp.fatnum) and
                   lancxa.datlan = titulo.titdtpag and
                   lancxa.vallan = titulo.titvlpag
                     no-lock no-error.
        if not avail lancxa
        then do:             
        disp "Despesa" titulo.titnum titulo.titvlcob titulo.titdtpag
        formpag.codigo . pause 0.
        vcompl  = titulo.titnum + "-" + string(titulo.titpar)
                                + " " + forne.fornom.
        /*sresp = no.
        message "Confirma lancamento?" update sresp.
        if sresp
        then*/
        run pag-tit-desp.
        end.
    end.
    else do:
        find first lancxa where
                   lancxa.cxacod = formpag.codigo and
                   lancxa.forcod = titulo.clifor and
                   lancxa.titnum = titulo.titnum and
                   lancxa.datlan = titulo.titdtpag and
                   lancxa.vallan = titulo.titvlpag
                     no-lock no-error.
         disp "Fornecedor" titulo.titnum titulo.titvlcob titulo.titdtpag
        formpag.codigo. pause 0.
        vcompl  = titulo.titnum + "-" + string(titulo.titpar)
                                + " " + forne.fornom.
        /*sresp = no.
        message "Confirma lancamento?" update sresp.
        if sresp
        then */
         run pag-titulo.
    end.
end.         
end.
procedure pag-tit-desp:
    
    find first tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi
             no-lock no-error.
    if avail tituctb
    then for each tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi
             no-lock:
                
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = tituctb.clifor and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
        if avail lancactb
        then do:
            run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            tituctb.modcod,
                            titulo.titdtpag,
                            (tituctb.titvlcob + 
                            tituctb.titvljur -
                            tituctb.titvldes),
                            tituctb.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        end. 
    end. 
    else do:
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
            run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            fatudesp.modctb,
                            titulo.titdtpag,
                            (titulo.titvlcob + 
                            titulo.titvljur -
                            titulo.titvldes),
                            fatudesp.clicod,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        end. 
    end.
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
                            lancactb.contadeb,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        if titulo.agecod = "FRETE"
        then
        run lan-contabil("CAIXA",
                            "559",
                            lancactb.contadeb,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").

        if titulo.titvljur > 0 and vtitnat = yes
        then do:
            run lan-contabil("CAIXA",
                            228,
                            lancactb.contacre,
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
                        
        if titulo.titvldes > 0 and vtitnat = yes
        then do:
            run lan-contabil("CAIXA",
                            lancactb.contacre,
                            235,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvldes,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            12,
                            vcompl,
                            "C").
        end.
    end.    
end procedure. 


procedure lan-contabil:
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

    def buffer elancxa for lancxa.
    /*
    if l-landeb = 448 and
       l-landeb = 447 and
       l-landeb = 362
    then l-hiscod = "262".
    */
           
    if l-tipo = "CAIXA"
    THEN
    do on error undo:

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
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = l-lantipo and
                       lancxa.etbcod = l-etbcod  and
                       lancxa.comhis = l-hiscomp
                        no-error.
            if not avail lancxa
            then do:            
            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-lancre
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-landeb
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = l-lantipo
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
            
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO ON ERROR UNDO:
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"      and
                       lancxa.etbcod = l-etbcod and
                       lancxa.comhis = l-hiscomp
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
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-lancre
                    lancxa.lancod = l-landeb
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

procedure ver-lancactb:
    v-lancactb = yes.
    
    find first fatudesp where 
               fatudesp.clicod = titulo.clifor and
               fatudesp.fatnum = int(titulo.titnum)
               no-lock no-error.
    if not avail fatudesp
    then do:           
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = titulo.etbcod and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
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
    
        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " titulo.modcod
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.

            v-lancactb = no.
        end.
    end.
    else do:
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = fatudesp.etbcod and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
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

        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " fatudesp.modctb
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.
            v-lancactb = no.
        end.
    end.
end procedure.

 