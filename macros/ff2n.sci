function dFF2=ff2n(n,Flag)
// Defines a two level full factorial design with n factors
//
// Calling Sequence
//   dFF2 = ff2n(n) 
//
// Parameters
// n: number of factors
// Design: two level full factorial design for n factors
// Flag: optional Flag=%T (default) will use [-1 1] or [-1 0 1] as levels (otherwise [1 2] is used).
//
// Description
// Returns a two level full factorial design matrix. 
//
// Examples
// dFF2 = ff2n(3) // 2^3 full factorial design
// dFF2alt = ff2n(3,%f) // 2^3 full factorial design with [1 2] as level indicators
//
// See also
//  fullfact
//
// Authors
//  T. Pettersen, top@tpett.com 
// Bibliography
//   http://www.statsoft.com/textbook/experimental-design

    if argn(2)<2 then Flag=%T; end
    apifun_checktype("ff2n",n,"n",1,"constant");
    
    dFF2=fullfact(2*ones(1,n),Flag);
endfunction