if integer(substring(string({1},"999999"),6,1)) ne
   if (integer(substring(string({1},"999999"),1,1)) * 6 +
       integer(substring(string({1},"999999"),2,1)) * 5 +
       integer(substring(string({1},"999999"),3,1)) * 4 +
       integer(substring(string({1},"999999"),4,1)) * 3 +
       integer(substring(string({1},"999999"),5,1)) * 2 + 10) modulo 11 = 0
      then 0
      else
      10 - (integer(substring(string({1},"999999"),1,1)) * 6 +
	    integer(substring(string({1},"999999"),2,1)) * 5 +
	    integer(substring(string({1},"999999"),3,1)) * 4 +
	    integer(substring(string({1},"999999"),4,1)) * 3 +
	    integer(substring(string({1},"999999"),5,1)) * 2 + 10) modulo 11
   then false else true
