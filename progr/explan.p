{admcab.i}
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date.
def var vdti    as date initial "06/01/98".
def var vdtf    as date initial "06/30/98".
def temp-table wfnum
        field numero as i
        field serie  as c format "x(2)".
def temp-table wfseq
        field wserie as c format "x(2)"
        field wnumi  as i
        field wnumf  as i
        field wdata  as date format "99999999".
def temp-table bwfseq
        field wserie as c format "x(2)"
        field wnumi  as i
        field wnumf  as i
        field wdata  as date format "99999999".
def buffer bbwfseq for bwfseq.
def stream sarq.
update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.

update vlannum label "Lancamento Inicial" with frame f1.

display "INSIRA O DISQUETE NO DRIVE" WITH FRAME F2 CENTERED ROW 10 .
PAUSE.
HIDE FRAME F2 NO-PAUSE.


output stream sarq to a:019.txt.

for each estab where etbcod = vetbcod no-lock:

    do vdt = vdti to vdtf:

        disp vdt.

        for each wfnum:
            delete wfnum.
        end.

        for each plani where plani.movtdc = 5               and
                             plani.etbcod = estab.etbcod    and
                             plani.pladat = vdt
                             no-lock
                             by plani.serie
                             by plani.numero:

            create wfnum.
            assign wfnum.numero = plani.numero
                   wfnum.serie  = plani.serie.

        end.

        for each nota where nota.movtdc = 5                 and
                            nota.etbcod = estab.etbcod      and
                            nota.notdat = vdt
                            no-lock
                            by nota.notser
                            by nota.notnum:

            create wfnum.
            assign wfnum.numero = nota.notnum.
            if nota.notser   = "1"
            then wfnum.serie = "D1".
            if nota.notser   = "2"
            then wfnum.serie = "D2".
            if nota.notser   = "3"
            then wfnum.serie = "D3".
            if nota.notser   = "4"
            then wfnum.serie = "D4".
            if nota.notser   = "5"
            then wfnum.serie = "U".

        end.

        for each wfnum
                       break by wfnum.serie
                             by wfnum.numero:

            if first-of(wfnum.serie)
            then do:
                create wfseq.
                assign wfseq.wserie = wfnum.serie
                       wfseq.wdata  = vdt
                       wfseq.wnumi  = wfnum.numero.
            end.
            if last-of(wfnum.serie)
            then do:
                find first wfseq where wfseq.wserie = wfnum.serie.
                assign wfseq.wnumf  = wfnum.numero.
            end.

        end.

        for each wfseq break by wfseq.wserie:

            if first-of(wfseq.wserie)
            then assign ni = wfseq.wnumi
                        nf = wfseq.wnumf.

            wni = ni.

            do i = ni to nf:

                disp i with 1 down. pause 0.

                find first wfnum where wfnum.numero = i and
                                       wfnum.serie  = wfseq.wserie no-error.
                if not avail wfnum
                then do:

                    find first bwfseq where bwfseq.wserie = wfseq.wserie and
                                            bwfseq.wnumi  = 0 and
                                            bwfseq.wnumf  = 0 no-error.
                    if not avail bwfseq
                    then do:

                        create bwfseq.
                        assign bwfseq.wserie = wfseq.wserie
                               bwfseq.wdata  = wfseq.wdata
                               bwfseq.wnumi  = 0
                               bwfseq.wnumf  = 0.

                        assign wfseq.wnumf = i - 1.

                        create bbwfseq.
                        assign bbwfseq.wserie = wfseq.wserie
                               bbwfseq.wdata  = wfseq.wdata
                               bbwfseq.wnumi  = wni
                               bbwfseq.wnumf  = wfseq.wnumf.


                    end.
                    else do:

                        next.

                    end.
                end.
                else do:

                    find first bwfseq where bwfseq.wserie = wfseq.wserie and
                                            bwfseq.wnumi  = 0 and
                                            bwfseq.wnumf  = 0 no-error.
                    if avail bwfseq
                    then do:
                        wni = wfnum.numero.
                        bwfseq.wnumi = wfnum.numero.
                        if wfnum.numero = nf
                        then bwfseq.wnumf = nf.

                    end.
                    else do:

                        find first bwfseq no-error.
                        if not avail bwfseq
                        then do:
                            create bwfseq.
                            assign bwfseq.wserie = wfseq.wserie
                                   bwfseq.wdata  = wfseq.wdata
                                   bwfseq.wnumi  = wfnum.numero
                                   bwfseq.wnumf  = 0.
                        end.

                        if wfnum.numero = nf
                        then do:

                            find first bbwfseq where
                                               bbwfseq.wserie = wfseq.wserie and
                                               bbwfseq.wnumf  = 0 no-error.
                            if avail bbwfseq
                            then assign bbwfseq.wnumi = wni
                                        bbwfseq.wnumf = nf.
                        end.
                    end.

                end.

            end.


        end.

        for each wfnum:
            delete wfnum.
        end.
        for each wfseq:
            delete wfseq.
        end.
        for each bwfseq where bwfseq.wnumf = 0:
            delete bwfseq.
        end.
        /*
        for each bwfseq:
            disp bwfseq.
        end.
        */
    end.
    nu = vlannum.
    for each bwfseq by bwfseq.wdata
                    by bwfseq.wserie
                    by bwfseq.wnumi:
        /*
        if first-of(bwfseq.wserie) and
           first-of(bwfseq.wnumi)
        then do:
            i = bwfseq.wnumi.
        end.
        */
        vvlcont = 0.
        do i = bwfseq.wnumi to bwfseq.wnumf:
            find plani where plani.movtdc = 5               and
                             plani.etbcod = estab.etbcod    and
                             plani.emite  = estab.etbcod    and
                             plani.serie  = bwfseq.wserie   and
                             plani.numero = i               no-lock no-error.
            if avail plani
            then do:
                vvlcont = vvlcont + plani.platot.
            end.
            else do:

                find nota where nota.movtdc = 5 and
                                nota.etbcod = estab.etbcod and
                                nota.notser = bwfseq.wserie and
                                nota.notnum = i no-lock no-error.
                if not avail nota
                then next.
            end.
        end.

put stream sarq unformatted
/*n*/       nu  at 1                                    ",".
put stream sarq  unformatted
/*n*/       estab.etbcod                                ",".
put stream sarq
/*d*/       trim(string(year(bwfseq.wdata),"9999") +
                 string(month(bwfseq.wdata),"99")  +
                 string(day(bwfseq.wdata),"99"))        ",".
put stream sarq  unformatted
/*c*/       chr(34)
            string(bwfseq.wnumi)
            chr(34) ",".
put stream sarq  unformatted
/*c*/       chr(34)
            string(bwfseq.wnumf)
            chr(34) ",".
put stream sarq unformatted
/*c*/       chr(34)
            bwfseq.wserie
            chr(34) ",".
put stream sarq unformatted
/*c*/       chr(34)
            "NF"
            chr(34) ",".
put stream sarq
/*n*/       vvlcont  format ">>>>9.99"      ",".
put stream sarq unformatted
/*c*/       chr(34)
            "  "
            chr(34) ",".
put stream sarq unformatted
/*c*/       chr(34)
            "5.12"
            chr(34) ",".
put stream sarq
/*n*/      vvlcont  format ">>>>9.99"  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      "18.00"                            ",".
put stream sarq
/*n*/      ((vvlcont * 18) / 100)  format ">>>>9.99"    ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*n*/      0                                  ",".
put stream sarq unformatted
/*c*/       chr(34)
            " " /*  NFS canceladas */
            chr(34) ",".
put stream sarq unformatted
/*n*/      0                                             ",".
put stream sarq unformatted
/*c*/       chr(34)
            " "
            chr(34) ",".
put stream sarq unformatted
/*c*/       chr(34) " "
            chr(34).

        nu = nu + 1.
    end.
end.
output stream sarq close.
