define variable d{1} as integer format "9" extent 6.
define variable t{1} as integer format "99999".
define variable s{1} as character format "999999".
assign s{1} = string({2},"999999")
       t{1} = integer(substring(s{1},1,5)) + 1
       s{1} = string(t{1},"99999") + "0"
       d{1}[1] = integer(substring(s{1},1,1))
       d{1}[2] = integer(substring(s{1},2,1))
       d{1}[3] = integer(substring(s{1},3,1))
       d{1}[4] = integer(substring(s{1},4,1))
       d{1}[5] = integer(substring(s{1},5,1))
       t{1} = d{1}[1] * 6 + d{1}[2] * 5 + d{1}[3] * 4 +
	      d{1}[4] * 3 + d{1}[5] * 2
       t{1} = t{1} + 10.
if t{1} modulo 11 = 0
 then assign substring(s{1},6,1) = "0".
 else assign substring(s{1},6,1) = string(10 - (t{1} modulo 11),"9").
assign {2} = integer(s{1}).
