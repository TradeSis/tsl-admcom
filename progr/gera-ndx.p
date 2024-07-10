{admcab.i new}
    
def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def var varquivo as char.
def var varqexp  as char.

def temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec.
    
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
def var vhist  as char.
  
def temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob
      field titvlpag  like titulo.titvlpag
      index ix is primary unique
                  etbcod   
                  data
                  tipo
      index xx tipo.


def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vdata1 as date.
repeat:
    
    update vetbi label "Filial inicio"     at 3
           vetbf label "Filial fim"
          with frame f1 side-label width 80.
          update vdti label "Data Inicial" colon 16
                 vdtf label "Data Final" colon 16 with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
def var vndx as dec.

    for each tt-estab: delete tt-estab. end.
   
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf
                     no-lock:
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.
    
    run gera-index.

    output to /admcom/progr/diauxcli.ndx append.
    for each tt-index.
        export tt-index.
    end.    
    output close.
end.

procedure gera-index:
    def var vdata as date.
    def var vlvist as dec.
    def var vlpraz as dec.
    def var totecf as dec.
    def var vtottit as dec.
    for each tt-index. delete tt-index. end.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        disp estab.etbcod with frame f-dsp
                1 down no-label side-label.
        pause 0.
        do vdata = vdti to vdtf:
            vlvist = 0.
            vlpraz = 0.
            totecf = 0.
            vtottit = 0.
            disp vdata with frame f-dsp.
            pause 0.
            for each plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata no-lock.
                if plani.crecod = 1
                then vlvist = vlvist + plani.platot.
                if plani.crecod = 2
                then do:
                    vlpraz = vlpraz + plani.platot.
                    find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
                    for each  titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.dest and
                           titulo.titnum = string(contnf.contnum) 
                           no-lock.
                        if titpar = 0 then next.
                        vtottit = vtottit + titulo.titvlcob.
                    end.       
                end.
            end.
            for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
            end.
            if vlpraz > 0
            then do:
                if vlvist < vlpraz
                then do:
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
                end.
                else do:
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
                end.
            end.
            else vlvist = totecf.
            
            find first tt-index where
                       tt-index.etbcod = estab.etbcod and
                       tt-index.data   = vdata
                       no-error.
            if not avail tt-index
            then do:
                create tt-index.
                assign
                    tt-index.etbcod = estab.etbcod
                    tt-index.data = vdata.
            end.     

            if vlpraz > 0 and
               vtottit > 0
            then tt-index.indx = vlpraz / vtottit.
            else tt-index.indx = 0.
        end.
    end.
 
end procedure.

