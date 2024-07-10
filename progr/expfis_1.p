{admcab.i}
def var varquivo as char.
def var outras-icms as dec format "->>>,>>9.99".
def input parameter vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def input parameter vdti    as date format "99/99/9999".
def input parameter vdtf    as date format "99/99/9999".
def stream sarq.

/*
update vetbcod with frame f1.
*/
find estab where estab.etbcod = vetbcod no-lock.

/*
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.
*/

def var d-dtini     as   date init today                            no-undo.
def var i-nota      like fiscal.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.


varquivo = "m:\livros\entra" + string(estab.etbcod,">>9") + ".txt".
 

output stream sarq to value(varquivo) append.

put stream sarq skip.
 
do vdt = vdti to vdtf:
    display vdt with 1 down. pause 0.
    for each fiscal where fiscal.movtdc = 12           and
                          fiscal.desti  = estab.etbcod and
                          fiscal.plarec = vdt no-lock:

        outras-icms = 0.

        vemp = estab.etbcod.
        if estab.etbcod = 1
        then vemp = 50.
        if estab.etbcod = 95
        then vemp = 122. 
        if estab.etbcod = 996
        then vemp = 54.
        if estab.etbcod = 997
        then vemp = 51.
        if estab.etbcod = 98
        then vemp = 53.
        if estab.etbcod = 999
        then vemp = 52.


        nu = nu + 1.
        put stream sarq unformatted
            nu  at 1                                    ",".
        put stream sarq  unformatted
            vemp ",".

        put stream sarq
        /*d*/       trim(string(year(fiscal.plaemi),"9999") +
                         string(month(fiscal.plaemi),"99")  +
                         string(day(fiscal.plaemi),"99"))        ",".

        put stream sarq
        /*d*/       trim(string(year(fiscal.plarec),"9999") +
                         string(month(fiscal.plarec),"99")  +
                         string(day(fiscal.plarec),"99"))     ",".

        put stream sarq  unformatted
        /*c*/       fiscal.numero ",".
        put stream sarq unformatted
        /*c*/       chr(34) fiscal.serie
            chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    "NF"
                    chr(34) ",".
        
        put stream sarq
        /*n*/       fiscal.platot  format ">>>>>9.99"   ",".
        
        put stream sarq unformatted
        /*c*/       chr(34)
                    "  "
                    chr(34) ",".

        put stream sarq unformatted
        /*c*/       chr(34)
        
        
        substring(string(fiscal.opfcod),1,1) + "." + 
        substring(string(fiscal.opfcod),2,3) + chr(34) ",".

        put stream sarq
        /*n*/      fiscal.bicms  format ">>>>>9.99"  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      fiscal.outras format "->>>>9.99"      ",".
        put stream sarq unformatted
        /*n*/
        fiscal.alicms format "99.99"  ",".
        put stream sarq
        /*n*/      fiscal.icms  format ">>>>9.99"    ",".
        put stream sarq unformatted
        /*n*/      0                                ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      fiscal.ipi    format ">>>>9.99"    ",".
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
                    0   ",".
        put stream sarq unformatted
        /*c*/       chr(34) " "
                    chr(34).

    end.
end.
output stream sarq close.
