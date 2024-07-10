/*
#1 07.08.2016 - Compilar todos os programas
*/

def var mprogr as char extent 11
   init ["/admcom/progr/",
         "/admcom/progr/abas/",
         "/admcom/progr/alcis/consult",
         "/admcom/progr/cyb/",
         "/admcom/progr/dpdv/",
         "/admcom/progr/loj/",
         "/admcom/progr/neuro/",
         "/admcom/progr/bol/",
         "/admcom/bs/",
	 "/admcom/bs/not/",
	 "/u/bsip2k/progr/ileb/"].

def var vct  as int.
pause 0 before-hide.
/*** marco/2013 ***/
/*
message "Conectando banco bswms no server.dep93".
connect bswms -N tcp -S 1922 -H server.dep93 -cache ../wms/bswms.csh.
compile WBS-nota-drebes.p save.
compile wmscorte2.p save.
disconnect bswms.
*/

do vct = 1 to 11.
    unix silent value("ls -1 " + mprogr[vct] +  
                      "*.p > /admcom/work/compila.txt").
    run compila.
end.

unix silent rm -f /admcom/progr/not_incos_lj.r.
unix silent rm -f /admcom/progr/logmenp1.r.
unix silent rm -f /admcom/progr/regspcmz.r.
unix silent rm -f /admcom/progr/incspc_l.r.
unix silent rm -f /admcom/progr/canspcmz.r.
unix silent rm -f /admcom/progr/excspc.r.
unix silent rm -f /admcom/progr/excspc_l.r.

unix silent rm -f /admcom/progr/seqspc.r.
unix silent rm -f /admcom/progr/ret_inc.r.
unix silent rm -f /admcom/progr/retinc_l.r.
unix silent rm -f /admcom/progr/le_chp1.r.
unix silent rm -f /admcom/progr/verif11.r.
unix silent rm -f /admcom/progr/arq_042.r.
unix silent rm -f /admcom/progr/devmod10.r.
unix silent rm -f /admcom/progr/seqspc.r.
unix silent rm -f /admcom/progr/logmanp1.r.

unix silent rm -f /admcom/progr/dvmod10.r.

/* #1 run compila_pto_r. */

message "Programas compilados" view-as alert-box.


procedure compila.
    def var v-prog as char format "x(50)".
    input from /admcom/work/compila.txt.
    repeat :
        import v-prog.
        disp v-prog label "Compilando ... " format "x(50)"
             with frame f-compil 1 down centered row 8 no-box color messages
             side-label.
        compile value(v-prog) save no-error.
        pause 0.
    end.
    input close.

end procedure.


/*** #1
procedure compila_pto_r.
unix silent value("find /admcom/progr -name *.r > /admcom/work/compilar.txt").
unix silent value("find /admcom/wms -name *.r >> /admcom/work/compilar.txt").

def var vprograma as char format "x(60)".

input from /admcom/work/compilar.txt.
repeat.
    import vprograma.
    vprograma = replace(vprograma,".r",".p").
        disp vprograma label "Compilando ... " format "x(50)"
             with frame fcompil 1 down centered row 8 no-box color messages
             side-label.

    compile value(vprograma) save no-error.
end. 
input close.

end procedure.
***/
