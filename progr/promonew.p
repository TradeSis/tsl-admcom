{admcab.i}

def var ss as dec.
def var vpre as dec.
def var vper as dec format ">>9.99 %" label "Perc.".
def buffer bestoq for estoq.
def var vdtfin like plani.pladat.
def var vdtini like plani.pladat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
def var vfincod   like finan.fincod.
def var vcondicao like plani.platot.
def var filtro_filial as log format "Sim/Nao".
def var vetccod like estac.etccod.
def var vfabcod like fabri.fabcod. 
def var vclacod like clase.clacod.

def var vnumero-nf as int format ">>>>>>>>9".
def var vetbemite as int.
def var vetbdesti as int.
def temp-table tt-produ like produ.

def buffer xclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def var    estoque-total like estoq.estatual.


def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.
 

def temp-table wfilial
    field wfil like estab.etbcod.

repeat:
    
    for each wfilial:
        delete wfilial.
    end.        
 
    for each tt-clase:
        delete tt-clase.
    end.
    
        
    filtro_filial = yes.
    update filtro_filial label "Todas Filiais " at 1
                    with frame f1 side-label.

    if filtro_filial = no
    then do:
            
        repeat: 
            create wfilial. 
            update wfilial.wfil label "Filial"
                with frame f-1 side-label centered 10 down.
            find estab where estab.etbcod = wfilial.wfil no-lock.
            display estab.etbnom no-label with frame f-1.
                
        end.
    end.
    else do:
        for each estab no-lock:
            create wfilial.
            assign wfilial.wfil = estab.etbcod.
        end.
    end.
         
    find first wfilial no-error.
    vetbdesti = wfilial.wfil.
     
    update vetccod label "Estacao       " at 01
                    with frame f1 side-label width 80.
    if vetccod = 0
    then display "GERAL" @ estac.etcnom no-label
                with frame f1.
    else do:
        find estac where estac.etccod = vetccod no-lock no-error.
        disp estac.etcnom no-label with frame f1.
    end.

    update vfabcod label "Fabricante    " at 01
                with frame f1 side-label width 80.
    if vfabcod = 0
    then display "GERAL" @ fabri.fabfant no-label with frame f1.
    else do: 
        find fabri where fabri.fabcod = vfabcod no-lock no-error.
        disp fabri.fabfant no-label with frame f1.
    end.

    update vclacod label "Classe        " at 01 with frame f1.
    
    
    if vclacod = 0
    then display "GERAL" @ xclase.clanom with frame f1.
    else do:
        find xclase where xclase.clacod = vclacod no-lock.
        display xclase.clanom no-label with frame f1.
    end.

    for each tt-clase:
        delete tt-clase.
    end.    


    find first clase where clase.clasup = vclacod no-lock no-error.
    if avail clase
    then run cria-tt-clase.
    else do:
        create tt-clase. 
        assign tt-clase.clacod = vclacod 
               tt-clase.clanom = xclase.clanom when avail xclase.
    end.


    procedure cria-tt-clase.
    for each clase where clase.clasup = vclacod no-lock:
        find first bclase where bclase.clasup = clase.clacod no-lock no-error.
        if not avail bclase 
        then do: 
            find tt-clase where tt-clase.clacod = clase.clacod no-error. 
            if not avail tt-clase 
            then do:  
                create tt-clase.  
                assign tt-clase.clacod = clase.clacod  
                       tt-clase.clanom = clase.clanom.
            end.
        end. 
        else do:  
            for each bclase where bclase.clasup = clase.clacod no-lock: 
                find first cclase where cclase.clasup = bclase.clacod 
                                  no-lock no-error.
                if not avail cclase
                then do: 
                    find tt-clase where tt-clase.clacod = bclase.clacod 
                                    no-error. 
                    if not avail tt-clase  
                    then do:  
                        create tt-clase.  
                        assign tt-clase.clacod = bclase.clacod  
                               tt-clase.clanom = bclase.clanom.
                    end.                
                end. 
                else do:  
                    for each cclase where cclase.clasup = bclase.clacod 
                                no-lock: 
                        find first dclase where 
                                   dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
                        if not avail dclase 
                        then do: 
                            find tt-clase where 
                                 tt-clase.clacod = cclase.clacod no-error. 
                            if not avail tt-clase 
                            then do:  
                                create tt-clase.  
                                assign tt-clase.clacod = cclase.clacod 
                                       tt-clase.clanom = cclase.clanom.
                        end.                          
                    end.
                    else do: 
                        for each dclase where 
                                 dclase.clasup = cclase.clacod no-lock: 
                            find first eclase 
                                       where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                            if not avail eclase  
                            then do:  
                                find tt-clase where 
                                     tt-clase.clacod = dclase.clacod no-error.
                                if not avail tt-clase 
                                then do: 
                                    create tt-clase. 
                                    assign tt-clase.clacod = dclase.clacod 
                                           tt-clase.clanom = dclase.clanom. 
                                end.       
                            end. 
                            else do:  
                                for each eclase where 
                                    eclase.clasup = dclase.clacod no-lock:
                    
                                    find first fclase where 
                                         fclase.clasup = eclase.clacod
                                                no-lock no-error.
                                    if not avail fclase 
                                    then do: 
                                        find tt-clase where 
                                             tt-clase.clacod = eclase.clacod
                                                             no-error.
                                        if not avail tt-clase 
                                        then do: 
                                            create tt-clase. 
                                            assign tt-clase.clacod = 
                                                            eclase.clacod 
                                                   tt-clase.clanom = 
                                                            eclase.clanom.
                                        end.                 
                                    end.
                                    else do:       
                                        for each fclase where 
                                            fclase.clasup = eclase.clacod
                                                       no-lock:
                                            find first gclase 
                                                 where gclase.clasup = 
                                                            fclase.clacod 
                                                             no-lock no-error.
                                            if not avail gclase 
                                            then do: 
                                                find tt-clase where 
                                                tt-clase.clacod = fclase.clacod
                                                                 no-error.
                                                if not avail tt-clase 
                                                then do: 
                                                    create tt-clase. 
                                                    assign tt-clase.clacod = 
                                                                 fclase.clacod                                                              tt-clase.clanom = 
                                                               fclase.clanom.
                                                end.
                                            end.
                                            else do:
                                                find tt-clase where 
                                                     tt-clase.clacod = 
                                                      gclase.claco~d no-error.
                                                if not avail tt-clase
                                                then do:
                                                    create tt-clase. 
                                                    assign tt-clase.clacod = 
                                                                 gclase.clacod 
                                                           tt-clase.clanom = 
                                                                gclase.clanom.
                                                end.  
                                            end.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.                                  
            end.
        end.
    end.
    end.
    end procedure.    
    
    
    
    vper = 0.
    update vdtini label "Validade      " at 1
           vdtfin label "Ate"
           vper   label "Perc.         " at 1
            with frame f1 width 80.
    update vfincod label "Plano         " at 1 with frame f1 side-label.
    if vfincod <> 0
    then do:
        
        find finan where finan.fincod = vfincod no-lock no-error.
        if not avail finan 
        then do:
            message "Plano invalido".
            undo, retry.
        end.
        display finan.finnom no-label with frame f1 side-label. 
        update vcondicao label "Val.Parcelas  " at 1 with frame f1.
        
    end.
    else vcondicao = 0.
    

    
    
    vpreco = 0.
    if vclacod = 0 and
       vfabcod  = 0 and
       vetccod  = 0
    then do:
        update vprocod label "Produto       " at 01
                with frame f1 side-label width 80.
        if vprocod > 0
        then do:
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        disp produ.pronom no-label with frame f1.
        find bestoq where bestoq.procod = produ.procod and
                          bestoq.etbcod = 1 no-lock.
                                 
        vpreco     = bestoq.estproper. 
        if vpreco = 0 
        then vpreco = bestoq.estvenda - ( bestoq.estvenda * (vper / 100)). 
        end.
        else if vfabcod = 0 and vetccod = 0
        then do:
            
            update vnumero-nf at 1 label "Numero NF     " 
            help "Informe o numero da NF de transferencia para Filial de slado"
                      with frame f1.
            
            vetbemite = 995.
            disp vetbemite label "Emitente"  with frame f1.
            if vnumero-nf = 0
            then undo, retry.

            find plani where plani.etbcod = 995 and
                             plani.desti  = vetbdesti and
                             plani.numero = vnumero-nf and
                             plani.movtdc = 6
                             no-lock no-error.
            if not avail plani
            then do:
                message color red/with
                "Nota Fiscal não encontrada."
                view-as alert-box.
                undo, retry.
            end.
                             
        end. 
    end.
    update vpreco at 1 label "Preco Promocao"
                with frame f1 side-label.

    for each tt-produ:
        delete tt-produ.
    end.    
             
    message "Confirma Promocao" update sresp.
    if sresp
    then do:
        if vprocod = 0 and
           vnumero-nf <> 0 and
           avail plani
        then do: 
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ then next.
                create tt-produ.
                buffer-copy produ to tt-produ.
            end.                           
        end.
        else
        for each produ where if vprocod = 0
                             then if vfabcod = 0
                                  then if vetccod = 0
                                       then true
                                       else produ.etccod = vetccod
                                  else produ.fabcod = vfabcod     
                             else produ.procod = vprocod no-lock:
            create tt-produ.
            buffer-copy produ to tt-produ.
        end.
        
        for each tt-produ where tt-produ.procod <> 0 no-lock:
            find produ where produ.procod = tt-produ.procod no-lock no-error.
            if not avail produ then next.
            
            if vclacod = 0
            then.
            else do:
                find first tt-clase where 
                                  tt-clase.clacod = produ.clacod no-error.
                if not avail tt-clase
                then next.
            end.     
            
            do transaction:
            
                find func where func.etbcod = 999 and
                                func.funcod = sfuncod no-lock no-error.

                find admprog where 
                            admprog.menpro = string(year(today),"9999") +
                                             string(month(today),"99")  +
                                             string(day(today),"99") +
                                             string(time) + " " + 
                                             string(produ.procod,"999999")
                                                        no-error.
                if not avail admprog
                then do:
                                                        

                    create admprog.
                    assign admprog.menpro = string(year(today),"9999") +
                                            string(month(today),"99")  +
                                            string(day(today),"99") +
                                            string(time) + " " + 
                                            string(produ.procod,"999999").
                    admprog.progtipo = string(produ.procod,"999999") + " " +
                                       string(func.funnom,"x(15)")   + " " +
                                       string(vdtini) + " " +
                                       string(vdtfin) + " " +
                                      " Promocao ".
                end.
            end.


            for each wfilial:
                find estoq where estoq.etbcod = wfilial.wfil and
                                 estoq.procod = produ.procod no-error.
                if not avail estoq
                then next.
                do transaction:
                    if vpreco <> 0
                    then estoq.estproper = vpreco.
                    else do:  
                        estoq.estproper = estoq.estvenda -
                                          (estoq.estvenda * (vper / 100)).
                
                        /*********** arredonda ***************/
                        ss = ( (int(estoq.estproper) - (estoq.estproper)) ) - 
                                round(( (int(estoq.estproper) - 
                                            (estoq.estproper)) ),1).

                        if ss < 0  
                        then ss = 0.10 - (ss * -1). 

                        if ss >= 0.05 
                        then estoq.estproper = estoq.estproper - (0.10 - ss).
                        else estoq.estproper = estoq.estproper + ss.
                        
                        /************************************/
                    end.
                    assign estoq.datexp = today
                           estoq.estprodat = vdtfin 
                           estoq.estbaldat = vdtini 
                           estoq.estmin    = vcondicao 
                           estoq.tabcod    = vfincod
                           estoq.dtaltpromoc = today
                           . 
                
                    find hisprpro where 
                        hisprpro.procod = estoq.procod and
                        hisprpro.etbcod = estoq.etbcod and
                        hisprpro.Data_inicio = estoq.estbaldat
                        no-error.
                    if not avail hisprpro
                    then create hisprpro.
                    ASSIGN 
                        hisprpro.preco_tipo = "P"
                        hisprpro.etbcod     = estoq.etbcod
                        hisprpro.procod     = estoq.procod
                        hisprpro.data_inicio = estoq.estbaldat
                        hisprpro.data_fim    = estoq.estprodat
                        hisprpro.preco_valor = estoq.estproper
                        hisprpro.OFFER_ID    = ?
                        hisprpro.preco_plano  = estoq.tabcod
                        hisprpro.preco_parcela = estoq.estmin
                        hisprpro.PRICE_KEY  = program-name(1)
                        hisprpro.data_inclu = today
                        hisprpro.hora_inclu = time
                         .

                end.
            end.
       
        end.
    end.
end.
