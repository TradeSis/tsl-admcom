
    def var dsresp as log.
    def var v-dir as char.
    def var vcont as int.
    def var vcelular as char.
    def var i as int.
    def var vqtd-tot as int format ">>>>>>9".
    
    update vqtd-tot label "Gerar arquivo com ate"
           " celulares."
           with frame f-qtd side-labels centered row 8 overlay.
     
    if opsys = "UNIX"
    then v-dir = "/admcom/relat-crm/crm-fones-vivo.txt".
    else v-dir = "l:\relat-crm\crm-fones-vivo.txt".
    
    output to value(v-dir).

        for each rfvcli where /*
                              rfvcli.nota = "555" or 
                              rfvcli.nota = "554" or 
                              rfvcli.nota = "553" or 
                              rfvcli.nota = "552" or
                              rfvcli.nota = "455" or
                              rfvcli.nota = "445" or
                              rfvcli.nota = "435" or
                              rfvcli.nota = "355" or
                              rfvcli.nota = "425"
                              */
                              rfvcli.nota >= "444"
                              no-lock break by nota desc.
        
            find clien where clien.clicod = rfvcli.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/

            if clien.fax begins "96" or
               clien.fax begins "97" or
               clien.fax begins "98" or
               clien.fax begins "99"
            then.
            else next.
     
            vcelular = "".
            do i = 1 to length(clien.fax):
     
                if substring(clien.fax,i,1) = "0" or
                   substring(clien.fax,i,1) = "1" or
                   substring(clien.fax,i,1) = "2" or
                   substring(clien.fax,i,1) = "3" or
                   substring(clien.fax,i,1) = "4" or
                   substring(clien.fax,i,1) = "5" or
                   substring(clien.fax,i,1) = "6" or
                   substring(clien.fax,i,1) = "7" or
                   substring(clien.fax,i,1) = "8" or
                   substring(clien.fax,i,1) = "9"
                then   
                    vcelular = vcelular + substring(clien.fax,i,1).

            end.
     
            if length(vcelular) < 8 then next.
            if length(vcelular) > 8 then next.        
            
            vcont = vcont + 1.
     
            if vcont = (vqtd-tot + 1)
            then leave.
     
            put "51" vcelular format "x(15)" skip.
        end.
    output close.

    run msg2.p (input-output dsresp, 
                input "    FORAM ENCONTRADOS " + string(vcont - 1)
                    + " CELULARES VIVO ENTRE OS PARTICIPANTES SELECIONADOS."
                    + " !" 
                    + "!    ARQUIVO GERADO EM:" 
                    + "!"
                    + "!       L:~\RELAT-CRM~\CRM-FONES-VIVO.TXT" , 
                    input " *** ATENCAO *** ", 
                    input "    OK").
                                                

