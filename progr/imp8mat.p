def temp-table l8-titulo like titulo.

def var setbcod as int initial 8.

message "Rodar na Loja 8".
do :
    repeat:
        connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.
        if not connected ("d")
        then do: 
            if i = 5  
            then leave. 
            i = i + 1. 
            next.
        end.  
        else leave.
    end.
end.


input from titulo.mat.8.
repeat.
    create l8-titulo.
    import l8-titulo.


        find titulo where 
             titulo.empcod  = l8-titulo.empcod and
             titulo.titnat  = l8-titulo.titnat and
             titulo.modcod  = l8-titulo.modcod and
             titulo.etbcod  = l8-titulo.etbcod and
             titulo.clifor  = l8-titulo.clifor and
             titulo.titnum  = l8-titulo.titnum and
             titulo.titpar  = l8-titulo.titpar  no-error.
        if not avail titulo
        then do:
            if l8-titulo.clifor <> 1    and
               l8-titulo.titsit = "PAG" and
               l8-titulo.titpar <> 0
            then do:
                find titexporta where  
                            titexporta.empcod  = l8-titulo.empcod and
                            titexporta.titnat  = l8-titulo.titnat and
                            titexporta.modcod  = l8-titulo.modcod and
                            titexporta.etbcod  = l8-titulo.etbcod and
                            titexporta.clifor  = l8-titulo.clifor and
                            titexporta.titnum  = l8-titulo.titnum and
                            titexporta.titpar  = l8-titulo.titpar and
                            titexporta.datexp  = l8-titulo.datexp
                            no-error. 
                if not avail titexporta
                then do:
                   create titexporta.
                   {tt-titexporta.i titexporta l8-titulo}. 
                end.
            end.
            find first flag where flag.clicod = l8-titulo.clifor 
                        no-lock no-error.
            if avail flag and flag.flag1 = yes
            then do:
                if setbcod <> 32
                then do :
                    if connected ("d")
                    then run cardrag.p(recid(l8-titulo)).
                end.    
            end.
            else do:
                create titulo.
                {l8-titulo.i titulo l8-titulo}.
            end.
        end.
        else do:
            if titulo.titsit <> "PAG"
            then {l8-titulo.i titulo l8-titulo}.
        end.
        if avail titulo
        then do :
            if l8-titulo.titdtpag <> ? and
                titulo.titdtpag <> ?
            then do:
                if l8-titulo.titdtpag <> titulo.titdtpag or
                   l8-titulo.titvlpag <> titulo.titvlpag or
                   l8-titulo.etbcobra <> titulo.etbcobra
                then do:
                    create titexporta.
                    {tt-titexporta.i titexporta l8-titulo}.
                end.
            end.
        end.    
        if avail titulo
        then do : 
            if titulo.etbcod = setbcod
            then titulo.exportado = yes.
            else titulo.exportado = no.
        end.
        
        find first fin.titulo where fin.titulo.empcod  = l8-titulo.empcod 
                                and fin.titulo.titnat  = l8-titulo.titnat 
                                and fin.titulo.modcod  = l8-titulo.modcod 
                                and fin.titulo.etbcod  = l8-titulo.etbcod 
                                and fin.titulo.clifor  = l8-titulo.clifor 
                                and fin.titulo.titnum  = l8-titulo.titnum 
                                and fin.titulo.titpar  = l8-titulo.titpar  
                              no-error.
        if avail fin.titulo
        then do :
            if avail titulo 
            then fin.titulo.exportado = yes.
            else if avail titexporta
                 then fin.titulo.exportado = yes.
        end.    
            
        delete l8-titulo.

end.
    
