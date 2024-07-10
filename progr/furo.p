{admcab.i}
def var varquivo as char.
def var xx like plani.numero extent 99.
def var x as int.
def var vtalao as char format "x(60)".
def temp-table tt-nota 
    field numero like plani.numero.
def var vserie like plani.serie format "x(4)".
def var vetbcod  like estab.etbcod.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     like plani.pladat.
def var vdti    like plani.pladat initial today.
def var vdtf    like plani.pladat initial today.
def stream sarq.
def var n like plani.numero.
def var d-dtini     like plani.pladat init today         no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
repeat:
    for each tt-nota:
        delete tt-nota.
    end.

    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

    n = 0.
        
    i = 0.
    x = 0.
    do i = 1 to 99:
        xx[i] = 0.
    end.
    i = 0.

    for each plani where plani.movtdc = 5       and
                         plani.etbcod = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.notsit = no no-lock by plani.numero:
        if n <> 0 and 
           plani.numero - n = 1 
        then do:
            n = plani.numero.
            next.
        end.
            
        if n = 0 or
          (plani.numero - n >= 50 or
           plani.numero - n <= -50)
        then do:
            n = plani.numero.
            next.
        end.


                        
        if n >= 10 and
           n <= 99
        then do:
            if int(substring(string(n),1,2)) = 50 or
               int(substring(string(plani.numero),1,2)) = 50
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),1,2)) = 00 or
               int(substring(string(plani.numero),1,2)) = 00
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),1,2)) <= 50 and
               int(substring(string(plani.numero),1,2)) >= 50
            then do:
                n = plani.numero.
                next.
            end.    
            if int(substring(string(n),1,2)) >= 50 and
               int(substring(string(plani.numero),1,2)) <= 50
            then do:
                n = plani.numero.
                next.
            end.
        end.




                
        if n >= 100 and
           n <= 999
        then do:
            if int(substring(string(n),2,2)) = 50 or
               int(substring(string(plani.numero),2,2)) = 50
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),2,2)) = 00 or
               int(substring(string(plani.numero),2,2)) = 00
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),2,2)) <= 50 and
               int(substring(string(plani.numero),2,2)) >= 50
            then do:
                n = plani.numero.
                next.
            end.    
            if int(substring(string(n),2,2)) >= 50 and
               int(substring(string(plani.numero),2,2)) <= 50
            then do:
                n = plani.numero.
                next.
            end.
        end.

 

                
        if n >= 1000 and
           n <= 9999
        then do:
            if int(substring(string(n),3,2)) = 50 or
               int(substring(string(plani.numero),3,2)) = 50
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),3,2)) = 00 or
               int(substring(string(plani.numero),3,2)) = 00
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),3,2)) <= 50 and
               int(substring(string(plani.numero),3,2)) >= 50
            then do:
                n = plani.numero.
                next.
            end.    
            if int(substring(string(n),3,2)) >= 50 and
               int(substring(string(plani.numero),3,2)) <= 50
            then do:
                n = plani.numero.
                next.
            end.
        end.

 


        
        if n >= 10000 and
           n <= 99999
        then do:
            if int(substring(string(n),4,2)) = 50 or
               int(substring(string(plani.numero),4,2)) = 50
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),4,2)) = 00 or
               int(substring(string(plani.numero),4,2)) = 00
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),4,2)) <= 50 and
               int(substring(string(plani.numero),4,2)) >= 50
            then do:
                n = plani.numero.
                next.
            end.    
            if int(substring(string(n),4,2)) >= 50 and
               int(substring(string(plani.numero),4,2)) <= 50
            then do:
                n = plani.numero.
                next.
            end.
        end.

        
        if n >= 100000
        then do:
            if int(substring(string(n),5,2)) = 50 or
               int(substring(string(plani.numero),5,2)) = 50
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),5,2)) = 00 or
               int(substring(string(plani.numero),5,2)) = 00
            then do:
                n = plani.numero.
                next.
            end.
            if int(substring(string(n),5,2)) <= 50 and
               int(substring(string(plani.numero),5,2)) >= 50
            then do:
                n = plani.numero.
                next.
            end.    
            if int(substring(string(n),5,2)) >= 50 and
               int(substring(string(plani.numero),5,2)) <= 50
            then do:
                n = plani.numero.
                next.
            end.
        end.





        do i = (n + 1) to (plani.numero - 1):
        
          find first nota where nota.etbcod = plani.etbcod and
                                nota.movtdc = 5            and
                                nota.movndc = i no-lock no-error.
          if not avail nota
          then do:
          
              
              x = x + 1.
              if x > 99
              then do:
                message "Existem mais de 100 notas para este periodo".
                undo, leave.
              end.


              xx[x] = i.
              disp i format ">>>>>>9" column-label "Numero"
                        with frame f-down 1 down centered.
              pause 0.
              
              create tt-nota.
              assign tt-nota.numero = i.

          end.
        end.

        n = plani.numero.

    end.
    disp xx 
            with frame ff down title "NOTAS NAO ENCONTRADAS" 
                no-label width 80 color message. pause.

    hide frame ff no-pause.
    message "Deseja imprimir" update sresp.
    if not sresp
    then next.
        
    varquivo = "..\relat\furo" + string(estab.etbcod).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = """"
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """FILIAL  "" + estab.etbnom + "" - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    disp xx with frame fff down no-label width 80. 

    
    output close.
    dos silent value("type " + varquivo + "  > prn").




end.
