%Graficas

format rat
%format short

%Primera parte programación lineal 
c = [1 1 1 1 1 0 0 0 0];
b = [0; 0 ; 1040 ; 0;100];
A = [-400 100 100 100 50 1 0 0 0;1000 1250 1333 -4800 1000 0 1 0 0;286 0 -270 56 150 0 0 0 0;0.1 -1 0.333 0 0.1 0 0 1 0;2 0 0 1 5 0 0 0 1]
p = 'Max';
%[SolOptima, Valoptimo] = PL(A,c,b,p)

