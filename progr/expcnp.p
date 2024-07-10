{admcab.i}
def var v-val as int format "9999999999999".
def var vgrupo like globa.glogru.
def var i as i.
def var v-hist as char format "x(3)".
def var varquivo as char format "x(20)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def temp-table wgloba
    field wetbcod like estab.etbcod
    field wglodat like globa.glodat
    field wtotal  like globa.gloval
    field wtot    like globa.gloval
    field wpre    like globa.gloval
    field wdin    like globa.gloval.
repeat:
    for each wgloba:
        delete wgloba.
    end.

    update vdti label "Data Inicial"
           vdtf label "Data Final"
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo " side-label.
    output to m:\v12\cnp .
    for each estab no-lock:
        for each globa where globa.glodat >= vdti and
                             globa.glodat <= vdtf and
                             globa.etbcod = estab.etbcod.
                      
            if substring(globa.glocot,1,4) = "8888" or
               substring(globa.glocot,1,4) = "9999" 
            then next.
          
            if substring(globa.glopar,1,6) = "777777" 
            then next.
            if substring(globa.glopar,1,6) = "555555" 
            then next.
          

            v-hist = "071".

            if substring(globa.glopar,1,6) = "666666" 
            then v-hist = "072".
          
            if substring(globa.glopar,1,6) = "444444"
            then v-hist = "073".
            
            vgrupo = globa.glogru.

            i = 0.
            do i = 1 to 8:
                if substring(vgrupo,i,1) = ""
                then substring(vgrupo,i,1) = "0".
            end.

            v-val = globa.gloval * 100.

            put globa.etbcod format "9999"
                year(today) format "9999"
                month(today) format "99"
                day(today) format "99" 

                globa.glogru format "x(4)"
                substring(globa.glocot,1,3) format "999"
                substring(globa.glocot,4,1) format "9"
                v-hist format "999"
                globa.glopar format "999"
                "000"
                "000"
                
                year(globa.glodat)  format "9999"
                month(globa.glodat) format "99"
                day(globa.glodat) format "99"

                v-val  format "9999999999999" skip.
            
        end.
    end.
    output close.
end.
