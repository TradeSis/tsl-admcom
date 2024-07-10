{cabec.i}
def var vdir as char format "x(12)" init "/admcom/tmp/" label "Arquivo".
def var varq as char format "x(30)".
def var vlog as char.
def var vclicod  like neuclien.clicod.
def var vvlrlimite   like neuclien.vlrlimite.
def var vvctolimite  like neuclien.vctolimite.
def var vvlrold as dec.
def var vvctoold as date.
disp
    vdir space(0)
    with row 3 side-labels width 80.
vvctolimite = date(12,31,year(today) + 2).
update varq no-label
               vvctolimite.

               if search(vdir + varq) = ?
               then do:
                   message "Arquivo " vdir + varq "nao encontrado"                                 view-as alert-box.
                   return.
               end.

message "confirma atualiação de limites?" update sresp.
if not sresp then return.
vlog = replace(varq,"csv","log").

pause 0 before-hide.
input from value(vdir + varq).
repeat:

        import  delimiter ";"
            vclicod vvlrlimite.
                    
        disp vclicod vvlrlimite.
                   
          find neuclien where neuclien.clicod = vclicod exclusive-lock no-wait no-error.

        if not avail neuclien
                then do:
                   run log(string(vclicod) + " Nao Encontrado neuclien").
                   next.
                end.
                    
        vvlrold     = neuclien.vlrlimite.
        neuclien.vlrlimite = vvlrlimite.
        vvctoold    = neuclien.vctolimite.
        neuclien.vctolimite = vvctolimite.
                                
       run log(string(vclicod) + " Alterado de " + string(vvlrold,">>>>>9.99") + " para " + string(neuclien.vlrlimite,">>>>>9.99")).

        run neuro/gravaneuclilog.p
                    (neuclien.cpfcnpj,
                     "ALTARQ",
                     time,
                     setbcod,
                     0,
                     "",
                     "De " +
                         (if vvlrold = ?
                           then "-"
                          else trim(string(vvlrold,">>>>>9.99"))) +
                         "-"   +
                            (if neuclien.vlrlimite = ?
                             then "-"
                          else trim(string(neuclien.vlrlimite,">>>>>9.99"))) +
                         " " +
                             (if vvctoold = ?
                             then "-"
                          else string(vvctoold,"99/99/9999")) +
                         "-"   +
                             (if neuclien.vctolimite = ?
                             then "-"
                              else string(neuclien.vctolimite,"99/99/9999"))
                        
                                ).
                                
                                
end.
input close.
pause before-hide.
                                
message "Importacao encerrada".
                                
                                
procedure log.
                                
    def input param plog as char.
                                    
   output to value(vdir + vlog) append.
   put unformatted skip
        today " " string(time,"HH:MM:SS") " " varq " - " plog
        skip.
   output close.
            
end procedure.
                                                                       







