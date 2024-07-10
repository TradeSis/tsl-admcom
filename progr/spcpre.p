{admcab.i}

def new shared temp-table tp-contrato like fin.contrato.

def new shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
          titnat
          modcod
          etbcod
          clifor
          titnum
          titpar.
                                                                    
def var vcont as integer.
def var vclicod as integer.

def var par-spc as logical.

def var vlibera as logical.

update vclicod label "Cliente" format ">>>>>>>>>>>>>>>>>9"
        with frame f01 side-labels.

        
find first clien where clien.clicod = vclicod no-lock no-error.
        
if not avail clien
then do:
        
    message "Cliente inválido!" view-as alert-box.
    undo, retry.
                
end.
                
if not avail clien then undo, return.
                        
run p-titulos-filial(input clien.clicod).

run spcpreconsulta.p (?, recid(clien),
                      output par-spc,
                      output vlibera).
                               
assign vcont = 0.
       
find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
       
do vcont = 1 to num-entries(cpclien.var-char11,"|"):
           
    display entry(vcont,cpclien.var-char11,"|") format "x(78)"
               with frame f-log-spc down
               title "LOG DA ULTIMA PRE CONSULTA AO SPC" row 5.
    pause 0.
    
    down with frame f-log-spc.
end.
                    
pause.
                        

procedure p-titulos-filial:
    def input parameter p-clicod like clien.clicod.

    for each titulo where titulo.clifor = p-clicod no-lock:
        if titulo.modcod = "BON" and titulo.titsit = "PAG"
        then do:
            find first tp-titulo where tp-titulo.empcod = 19
                                       and tp-titulo.titnat = yes
                                       and tp-titulo.modcod = titulo.modcod
                                       and tp-titulo.etbcod = titulo.etbcod
                                       and tp-titulo.clifor = titulo.clifor
                                       and tp-titulo.titnum = titulo.titnum
                                       and tp-titulo.titpar = titulo.titpar
                                       no-error.
            if avail tp-titulo
            then do :
                assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro
                           tp-titulo.titvljur = titulo.titvljur
                           tp-titulo.cxacod   = titulo.cxacod
                           tp-titulo.cxmdata  = titulo.cxmdata
                           tp-titulo.etbcobra = titulo.etbcobra
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.


            end.
            next.
        end.

        if titulo.titnat = no
        then do:
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = no
                                   and tp-titulo.modcod = titulo.modcod
                                   and tp-titulo.etbcod = titulo.etbcod
                                   and tp-titulo.clifor = titulo.clifor
                                   and tp-titulo.titnum = titulo.titnum
                                   and tp-titulo.titpar = titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do :
                find first  tp-titulo where
                            tp-titulo.clifor = titulo.clifor
                        and tp-titulo.titnum = titulo.titnum
                        and tp-titulo.titpar > titulo.titpar
                        and tp-titulo.titsit = "PAG" no-error.
                if not avail tp-titulo
                then do:

                if  (titulo.titdtpag <> ? and
                    titulo.titdtpag < today - 5) or
                    titulo.titdtven < today - 60
                then.
                else do:
                create tp-titulo.
                assign
                    tp-titulo.empcod    = titulo.empcod
                    tp-titulo.modcod    = titulo.modcod
                    tp-titulo.Clifor    = titulo.clifor
                    tp-titulo.titnum    = titulo.titnum
                    tp-titulo.titpar    = titulo.titpar
                    tp-titulo.titnat    = titulo.titnat
                    tp-titulo.etbcod    = titulo.etbcod
                    tp-titulo.titdtemi  = titulo.titdtemi
                    tp-titulo.titdtven  = titulo.titdtven
                    tp-titulo.titvlcob  = titulo.titvlcob
                    tp-titulo.titsit    = titulo.titsit
                    tp-titulo.moecod    = titulo.moecod.
                end.
                end.
            end.
            else do:
                if titulo.titsit = "PAG"
                then do:

                    assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro
                           tp-titulo.titvljur = titulo.titvljur
                           tp-titulo.cxacod   = titulo.cxacod
                           tp-titulo.cxmdata  = titulo.cxmdata
                           tp-titulo.etbcobra = titulo.etbcobra
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.

                end.
                else if tp-titulo.titsit = "LIB"   and
                        tp-titulo.tpcontrato <> "" /*titpar > 30*/    and
                        tp-titulo.titdtven < titulo.titdtven
                    then tp-titulo.titdtven = titulo.titdtven.
            end.

        end.
        else do:
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = yes
                                   and tp-titulo.modcod = titulo.modcod
                                   and tp-titulo.etbcod = titulo.etbcod
                                   and tp-titulo.clifor = titulo.clifor
                                   and tp-titulo.titnum = titulo.titnum
                                   and tp-titulo.titpar = titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do :
                create tp-titulo.
                assign
                    tp-titulo.empcod    = titulo.empcod
                    tp-titulo.modcod    = titulo.modcod
                    tp-titulo.Clifor    = titulo.clifor
                    tp-titulo.titnum    = titulo.titnum
                    tp-titulo.titpar    = titulo.titpar
                    tp-titulo.titnat    = titulo.titnat
                    tp-titulo.etbcod    = titulo.etbcod
                    tp-titulo.titdtemi  = titulo.titdtemi
                    tp-titulo.titdtven  = titulo.titdtven
                    tp-titulo.titvlcob  = titulo.titvlcob
                    tp-titulo.titsit    = titulo.titsit
                    tp-titulo.moecod    = titulo.moecod.

            end.
            else do:
                if titulo.titsit = "PAG"
                then do:

                    assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro
                           tp-titulo.titvljur = titulo.titvljur
                           tp-titulo.cxacod   = titulo.cxacod
                           tp-titulo.cxmdata  = titulo.cxmdata
                           tp-titulo.etbcobra = titulo.etbcobra
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.

                end.

            end.
        end.
    end.


end procedure.

                        
