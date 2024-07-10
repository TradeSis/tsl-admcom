/* def var vdata as date. */
/* def var i as i. */
def var dt-ecf as date.
def var cha11 as char format "x(21)".
def var cha12 as char format "x(21)".
def var cha15 as char format "x(21)".
def var cha18 as char format "x(21)".
def var cha19 as char format "x(21)".
def var cha21 as char format "x(21)".

def var val11 as dec.
def var val12 as dec.
def var val15 as dec.
def var val18 as dec.
def var val19 as dec.
def var val21 as dec.
def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var v01 as char format "x(2)".
def var v02 as char format "x(8)".
def var v03 as char format "x(10)".
def var v04 as char format "x(4)".
def var v05 as char format "x(5)".
def var v06 as char format "x(5)".
def var v07 as char format "x(5)".
def var v08 as char format "x(21)".
def var v09 as char format "x(21)".
def var v10 as char format "x(21)".
def var v11 as char format "x(21)".
def var v12 as char format "x(21)".
def var v13 as char format "x(21)".
def var v14 as char format "x(21)".

def var v15 as char format "x(21)".
def var v16 as char format "x(21)".
def var v17 as char format "x(21)".

def var v18 as char format "x(21)".
def var v19 as char format "x(21)".
def var v20 as char format "x(21)".

def var v21 as char format "x(21)".
def var v22 as char format "x(18)".
def var v23 as char format "x(21)".

def var v24 as char format "x(05)".
def var v25 as char format "x(18)".
def var v26 as char format "x(18)".

def var v27 as char format "x(05)".
def var v28 as char format "x(18)".
def var v29 as char format "x(18)".

def var v30 as char format "x(05)".
def var v31 as char format "x(18)".
def var v32 as char format "x(18)".

def var v33 as char format "x(05)".
def var v34 as char format "x(18)".
def var v35 as char format "x(18)".

def var v36 as char format "x(05)".
def var v37 as char format "x(18)".
def var v38 as char format "x(18)".

def var v39 as char format "x(05)".
def var v40 as char format "x(18)".
def var v41 as char format "x(18)".

def var v42 as char format "x(05)".
def var v43 as char format "x(18)".
def var v44 as char format "x(18)".

def var v45 as char format "x(06)".
def var v46 as char format "x(06)".
def var v47 as char format "x(06)".

def var v48 as char format "x(18)".
def var v49 as char format "x(18)".
def var v50 as char format "x(18)".
def var v51 as char format "x(18)".
def var v52 as char format "x(18)".
def var v53 as char format "x(18)".
def var v54 as char format "x(18)".

def var v55 as char format "x(09)".
def var v56 as char format "x(09)".
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
def workfile warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".
def var vdti as date.
def var vdtf as date.
    
    do dt-ecf = v-dtini to v-dtfin:    
     
        dos silent dir value("..\import\????" + 
                   substring(string(dt-ecf),1,2) + 
                   substring(string(dt-ecf),4,2) + "*.cup") 
                   /s/b > ..\import\arq.
         
    
        for each warquivo:
           delete warquivo.
        end.
        input from ..\import\arq.
        repeat:
            create warquivo.
            import warq.
            dos silent i:\dlc\bin\quoter
                value(warq) > value(substring(warq,1,(length(warq) - 1)) +
                                 "c").
        end.
        input close.

        for each warquivo:
            delete warquivo.
        end.

        dos silent dir value("..\import\*.cuc") /s/b > ..\import\arq.


        input from ..\import\arq.
        repeat:
            create warquivo.
            import warq.
            assign warquivo.wetb = substring(warq,18,2)
                   warquivo.wcxa = substring(warq,20,2)
                   warquivo.wdia = substring(warq,22,2)
                   warquivo.wmes = substring(warq,24,2).
        end.

        xx = 0.

        for each warquivo where warquivo.warq <> "" break by warquivo.wcxa
                                                          by warquivo.wmes
                                                          by warquivo.wdia:
            vdata = date( int(warquivo.wmes),
                          int(warquivo.wdia),
                          year(today)).
            input from value(warq).
            vcont = 0.
            repeat:
                import vlinha.
                vcont = vcont + 1.
                /* if vcont = 1
                then v01 = string(vlinha,"99"). */
                if vcont = 01
                then v02 = string(vlinha,"x(08)").
                if vcont = 02
                then v03 = string(vlinha,"x(10)").
                if vcont = 03
                then v04 = string(vlinha,"x(04)").
                if vcont = 04
                then v05 = string(vlinha,"x(05)").
                if vcont = 05
                then v06 = string(vlinha,"x(05)").
                if vcont = 06
                then v07 = string(vlinha,"x(05)").
                if vcont = 07
                then v08 = string(vlinha).
                if vcont = 08
                then v09 = string(vlinha).
                if vcont = 09
                then v10 = string(vlinha,"x(21)").
                if vcont = 11
                then v11 = string(vlinha).
                if vcont = 12
                then v12 = string(vlinha).
                if vcont = 13
                then v13 = string(vlinha).
                if vcont = 14
                then v14 = string(vlinha,"x(21)").
                if vcont = 15
                then v15 = string(vlinha).
                if vcont = 16
                then v16 = string(vlinha).
                if vcont = 17
                then v17 = string(vlinha).
                if vcont = 18
                then v18 = string(vlinha).
                if vcont = 19
                then v19 = string(vlinha).
                if vcont = 20
                then v20 = string(vlinha).
                if vcont = 21
                then v21 = string(vlinha).
                if vcont = 22
                then v22 = string(vlinha,"x(18)").
                if vcont = 23
                then v23 = string(vlinha).
                if vcont = 24
                then v24 = string(vlinha,"x(05)").
                if vcont = 24
                then v25 = string(vlinha,"x(18)").
                if vcont = 25
                then v26 = string(vlinha,"x(18)").
                if vcont = 26
                then v27 = string(vlinha,"x(05)").
                if vcont = 27
                then v28 = string(vlinha,"x(18)").
                if vcont = 28
                then v29 = string(vlinha,"x(18)").
                if vcont = 29
                then v30 = string(vlinha,"x(05)").
                if vcont = 30
                then v31 = string(vlinha,"x(18)").
                if vcont = 31
                then v32 = string(vlinha,"x(18)").
                if vcont = 32
                then v33 = string(vlinha,"x(05)").
                if vcont = 33
                then v34 = string(vlinha,"x(18)").
                if vcont = 34
                then v35 = string(vlinha,"x(18)").
                if vcont = 35
                then v36 = string(vlinha,"x(05)").
                if vcont = 36
                then v37 = string(vlinha,"x(18)").
                if vcont = 37
                then v38 = string(vlinha,"x(18)").
                if vcont = 38
                then v39 = string(vlinha,"x(05)").
                if vcont = 39
                then v40 = string(vlinha,"x(18)").
                if vcont = 40
                then v41 = string(vlinha,"x(18)").
                if vcont = 41
                then v42 = string(vlinha,"x(05)").
                if vcont = 42
                then v43 = string(vlinha,"x(18)").
                if vcont = 43
                then v44 = string(vlinha,"x(18)").
                if vcont = 44
                then v45 = string(vlinha,"x(06)").
                if vcont = 45
                then v46 = string(vlinha,"x(06)").
                if vcont = 46
                then v47 = string(vlinha,"x(06)").
                if vcont = 47
                then v48 = string(vlinha,"x(18)").
                if vcont = 48
                then v49 = string(vlinha,"x(18)").
                if vcont = 49
                then v50 = string(vlinha,"x(18)").
                if vcont = 50
                then v51 = string(vlinha,"x(18)").
                if vcont = 51
                then v52 = string(vlinha,"x(18)").
                if vcont = 52
                then v53 = string(vlinha,"x(18)").
                if vcont = 53
                then v54 = string(vlinha,"x(18)").
                if vcont = 54
                then v55 = string(vlinha,"x(09)").
                if vcont = 55
                then v56 = string(vlinha,"x(09)").

            end.
            input close.
        
        
            if v02 = ""
            then next.
            ii = 0.

            cha11 = "".
            cha15 = "".
            cha18 = "".
            cha19 = "".
            cha21 = "".
            cha12 = "".
    
            do ii = 1 to 21.
        
                if substring(v11,ii,1) = "." or
                   substring(v11,ii,1) = ","
                then.
                else cha11 = cha11 + substring(v11,ii,1).
        
        
                if substring(v12,ii,1) = "." or
                   substring(v12,ii,1) = ","
                then.
                else cha12 = cha12 + substring(v12,ii,1).
        

                if substring(v15,ii,1) = "." or
                   substring(v15,ii,1) = ","
                then.
                else cha15 = cha15 + substring(v15,ii,1).

                if substring(v18,ii,1) = "." or
                   substring(v18,ii,1) = ","
                then.
                else cha18 = cha18 + substring(v18,ii,1).
        
        
                if substring(v19,ii,1) = "." or
                   substring(v19,ii,1) = ","
                then.
                else cha19 = cha19 + substring(v19,ii,1).

                if substring(v21,ii,1) = "." or
                   substring(v21,ii,1) = ","
                then.
                else cha21 = cha21 + substring(v21,ii,1).
            end.


            val11 = dec(cha11) / 100.
            val12 = dec(cha12) / 100.
            val15 = dec(cha15) / 100.
            val18 = dec(cha18) / 100.
            val19 = dec(cha19) / 100.
            val21 = dec(cha21) / 100.

            val19 = val18 * 0.705889.

            vred = int(v02).
            if vred = 0
            then next.
            val15 = val15 + val21.
            valcon = val18 + val15 + val11.
            valicm = (val19 + val15) * 0.17.
            val12 = val12 + val18 + val19.

            find first serial where serial.etbcod = int(warquivo.wetb) and
                                    serial.cxacod = int(warquivo.wcxa) and
                                    serial.redcod = int(vred) no-error.
            if not avail serial
            then do transaction:

                create serial.
        
                ASSIGN serial.etbcod = int(warquivo.wetb)
                       serial.cxacod = int(warquivo.wcxa)
                       serial.redcod = int(vred)         
                       serial.icm12  = val18             
                       serial.icm17  = val15             
                       serial.sersub = val11             
                       serial.serval = valcon            
                       serial.serdat = vdata.
            end.
        end.
    end.
    dos silent move /y ..\import\*.cu* ..\cupomf . 

