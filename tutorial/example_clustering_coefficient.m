A = zeros(5,5);
A(1,2:5)=1; A=A+A';


B = A;
B(3,4)=1; B(4,3)=1;
B(3,1)=1; B(3,2)=1; B(3,5)=1;
B(1,3)=1; B(2,3)=1; B(5,3)=1;


C = ones(5,5);
C(eye(5)==1)=0;
