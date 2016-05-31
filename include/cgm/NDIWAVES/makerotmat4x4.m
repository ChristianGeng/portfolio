function H4x4=makerotmat4x4(H3x3,trans,rotpos)
% pre : H is PREmultiplied
% post: H is POSTmultiplied


usepos='pre';
if nargin > 2
    usepos=rotpos;
end


H4x4=eye(4,4);
H4x4(1:3,1:3)=H3x3;



 switch usepos
     case 'pre'
         H4x4(1,4)=trans(1);
         H4x4(2,4)=trans(2);
         H4x4(3,4)=trans(3);
     case 'post'
         H4x4(4,1)=trans(1);
         H4x4(4,2)=trans(2);
         H4x4(4,3)=trans(3);
     otherwise
         warning('invalid spec for rotposm must be either ''pre'' or ''post''. Returning 4x4 identity!');
         H4x4=eye(4,4);
 end

         
         




