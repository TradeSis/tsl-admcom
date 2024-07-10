{admcab.i}
def var vsequencia like ctpromoc.sequencia.
def var vtime as int.

def buffer bf1-ctpromoc for ctpromoc.

def temp-table tt-produ 
    field procod like produ.procod
    field preco as dec
    index i1 procod.

update vsequencia label "Codigo da promocao"
    with frame f1 side-label.
    
find first ctpromoc where ctpromoc.sequencia = vsequencia and
                    ctpromoc.promocod = 20 and
                    ctpromoc.situacao = "M" no-lock no-error.
if not avail ctpromoc
Then do:
    bell.
    message color red/with
        "Nenhum registro encontrato para promocao."
        view-as alert-box.
    undo.
end.
disp ctpromoc.descricao[1]
     ctpromoc.descricao[2]
     with frame f2 no-label column 5 1 down
        color message no-box.
if ctpromoc.situacao = "L"
then do:
    bell.
    message color red/with
    "Promocao ja esta Liberada."
    view-as alert-box.
    return.
end.
repeat:
    bell.
    sresp = no.
    message color red/with
                 "Confirma alterar situacao da promocao ? "
    update sresp.
    leave.
end.
if keyfunction(lastkey) = "END-ERROR"
THEN return.

def buffer fctpromoc for ctpromoc.
def buffer bclase for clase.
def buffer cclase for clase.

if sresp = yes
then do:
    def buffer pctpromoc for ctpromoc.
    
    vtime = time.
    
    for each pctpromoc where
                                 pctpromoc.sequencia = ctpromoc.sequencia and
                                 pctpromoc.linha > 0 and
                                 pctpromoc.procod > 0 
                                  no-lock:
                if pctpromoc.situacao = "I" or
                   pctpromoc.situacao = "E"
                then next.   
                                disp "Aguarde.... " pctpromoc.procod
                                    with frame f-pro row 16 1 down 
                                    no-label no-box.
                                pause 0.   
                find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 and
                                 fctpromoc.situacao <> "I" and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                if not avail fctpromoc
                then do:
                    for each estab no-lock:
                        find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod = estab.etbcod and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                        if avail fctpromoc then next.
                        
                        run cria-hispre.p(  input estab.etbcod,
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input vtime).
                     end.        
                end.                 
                else   
                for each fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 
                                  no-lock:
                    if pctpromoc.situacao = "I" or
                         pctpromoc.situacao = "E"
                    then next.  
                    
                    run cria-hispre.p(  input fctpromoc.etbcod,
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input vtime).
                end.
    end.
    /**
    for each tt-produ: delete tt-produ. end.

    for each pctpromoc where
                                 pctpromoc.sequencia = ctpromoc.sequencia and
                                 pctpromoc.linha > 0 and
                                 pctpromoc.clacod > 0 
                                  no-lock:
        if pctpromoc.situacao = "I" or
           pctpromoc.situacao = "E"
        then next.
         
        for each produ where produ.clacod = pctpromoc.clacod no-lock:
            create tt-produ.
            tt-produ.procod = produ.procod.
            tt-produ.preco = pctpromoc.precosugerido.
        end.

        for each clase where clase.clasup = pctpromoc.clacod no-lock:
            for each produ where produ.clacod = clase.clacod no-lock:
                create tt-produ.
                tt-produ.procod = produ.procod.
                tt-produ.preco = pctpromoc.precosugerido.
            end.
            for each bclase where bclase.clasup = clase.clacod no-lock:
                for each produ where 
                         produ.clacod = bclase.clacod no-lock:
                    create tt-produ.
                    tt-produ.procod = produ.procod.
                    tt-produ.preco = pctpromoc.precosugerido.
                end.
                for each cclase where cclase.clasup = bclase.clacod no-lock:
                    for each produ where 
                             produ.clacod = cclase.clacod no-lock:
                        create tt-produ.
                        tt-produ.procod = produ.procod.
                        tt-produ.preco = pctpromoc.precosugerido.
                    end.
                end.
            end.        
        end.
    end.
    for each tt-produ no-lock:
             
        disp "Aguarde.... " tt-produ.procod
                                    with frame f-pro1 row 16 1 down 
                                    no-label no-box.
                                pause 0.   

                find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 and
                                 fctpromoc.situacao <> "I" and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                if not avail fctpromoc
                then do:
                    for each estab no-lock:
                        find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod = estab.etbcod and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                        if avail fctpromoc then next.
                        
                        run cria-hispre.p(  input estab.etbcod,
                                        input tt-produ.procod,
                                        input 0,
                                        input tt-produ.preco,
                                        input 0, input vtime).
                     end.        
                end.                 
                else   
                for each fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 
                                  no-lock:
                    if pctpromoc.situacao = "I" or
                         pctpromoc.situacao = "E"
                    then next.  
                    
                    run cria-hispre.p(  input fctpromoc.etbcod,
                                        input tt-produ.procod,
                                        input 0,
                                        input tt-produ.preco,
                                        input 0, input vtime).
                end.
    end.
    ***/
    
    hide frame f-pro no-pause.
    
    run p-libera-promo.

end.
message color red/with
        "PROMOCAO LIBERADA"
        VIEW-AS ALERT-BOX.
    
    
procedure p-libera-promo:

    release bf1-ctpromoc.
    find first bf1-ctpromoc where rowid(bf1-ctpromoc) = rowid(ctpromoc)                                     exclusive-lock.
    
    if avail bf1-ctpromoc
    then assign bf1-ctpromoc.situacao = "L".
    
end procedure. 
