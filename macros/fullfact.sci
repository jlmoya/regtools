function Design=fullfact(levels,Flag)
// Define a full factorial design matrix.
//
// Calling Sequence
//   Design = fullfact(levels) 
//
// Parameters
// levels: row vector with number of levels for each factor
// Design: full  factorial design matrix
// Flag: optional Flag=%T (default) will use [-1 1] or [-1 0 1] as levels for 2 or 3 level factors (otherwise [1 2] and [1 2 3] is used).
//
// Description
// Returns a full factorial design matrix where number of levels for each
// factor is given by the respective values in levels. 
//
// Examples
// Design23 = fullfact([2 2 2]) // 2^3 full factorial design
// Design32 = fullfact([3 3]) // 3^2 full factorial design
//
// See also
//  ff2n
//
// Authors
//  T. Pettersen, top@tpett.com 
// Bibliography
//   http://www.statsoft.com/textbook/experimental-design

    if argn(2)<2 then Flag=%T; end
    apifun_checktype("fullfact",levels,"levels",1,"constant");
      
    r=prod(levels); 
    c=length(levels);
    Design=zeros(r,c);
    
    nr=r;
    for i=1:length(levels),
        nr=nr/levels(i);
        col=[];
        for j=1:levels(i),
            if Flag & levels(i)==2 then
                ind=[-1 1];
            elseif Flag & levels(i)==3 then
                ind=[-1 0 1];
            else
                ind=1:levels(i);
            end
            col=[col;ind(j)*ones(nr,1)];
        end
        Design(:,i)=repmat(col,r/length(col),1);
    end
endfunction