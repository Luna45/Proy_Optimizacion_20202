%Nombres:
%Luna Gabriela Durán Perez
%Dayana Valentina González Vargas.

%PL -> Programa inicial: donde llamara a las otras funciones
%-------------------------------------------------------------------------
%Esta es la Programación lineal
%A -> Matriz de restricciones ya estandarizada (Formato Estandar)
%C -> Costos iniciales segun la función objetivo concatenados con los cero
%de las variables de holgura.
%b -> los valores que deben cumplir las restricciones es decir los que van
%a la derecha de la matriz A.
%p -> me dice si lo que se va a optimizar es minimizar='min' o maximizar='Max'.


%-------------------------------------------------------------------------
%Función PL

%Nos retorna la solución basica factible optima si la hay o si no porque no
%hay, dentro de ella llamamos a las otras funciones
function [sfi, z_0] = PL (A,C,b,p)
[m,n]=size(A);
%Sabemos que maximizar es igual a minimizar la opuesta de la función
%objetivo
if p == 'Max'
    C = (-1)*C
end
%Inicializamos
IB =[];
IN=[];
B = [];

%Verificamos que las dimensiones de las entradas sean validas
if (length(C) ~= n || length(b) ~=m )
    j=('las dimensiones de los parámetros no coinciden por favor revise su problema')
else
[IB,B,outs,An,IA]=Check_I (A);% chequea si A tiene contenida una identidad
%y retorna An que es la matriz con la nueva variable artificial o An=A si
%no fue necesario agregar var artificiales


%Ahora si empieza el codigo
%Aca generamos nuestros Indices NO basicos iniciales con respecto a nuestra
%base inicial
for i =1:n
    if not(ismember(i,IB))
        INaux = [i];
        IN= horzcat(IN,INaux);
    end
end

%outs nos dice si se agregaron var artificiales (out=0) y no (outs=1)
if outs == 0
    %Si agregamos var artificiales iniciamos la fase 1
    j = 'Se agrego una variable artificial';
    disp(j);
    [~,IB,IN,B,kk]= fase1(An,IA,B,IB,p,IN,b)
    if kk== true
        hgg = '------------INICIA LA FASE 2----------------'
        fr = '-----------Simplex ------------------'
        disp(hgg)
        disp(fr)
        [sfi,z_0,~,~,~,~,~]= Simplex(A,B,IB,IN,b,C)
    end
else
    %Si no fue necesario agregar var artificiales iniciamos el simplex
    j = 'No agregaste una variable artificial';
    disp(j);
    [sfi,z_0,~,~,~,~,~]= Simplex(An,B,IB,IN,b,C)
    
end

end

end
%-------------------------------------------------------------------------
%Función Fase1 

function[Slfi,IB,IN,B,kk]= fase1(An,IA,B,I_B,p,IN,b)
[m,n]= size(An);
CXa = EncontCXa(n,IA,p);
AA = 'Nuestra Matriz A es:';
xc = ['Nuestros Nuevos costos iniciales son: ' ,'[', num2str(CXa),']'];
f = ' ----------INICIA LA FASE 1-----------';
disp(f);
disp(AA);
disp(An);
disp(xc);


[Slo,~,IB,IN,B,N,Bb] = Simplex(An,B,I_B,IN,b,CXa)
I_d =[];
C_B = []; %Realizara el cambio si Xa =0 y se encuentra en la base
rr = true; %Va a decirnos si salieron o no las variables artificiales
X_a = 0; %Tomara el valor que este en la base que represente cada inidce
kk = true; %Dira si tiene solución sin variables artificiales para poder hacer el simplex
ff = false; %Nos dira en el cambio o eliminacion de indices si es un Xa = 0  en la base o no
for i = 1:m
    if ismember(IB(i),IA)
        I_d = [I_d i];
        rr = false;
    end
end
[m2,n2]=size(I_d);
if rr == false
    for i = 1:length(I_d)
        if Bb(I_d(i))> 0 
            kk = false;
            Slfi = Bb;
            disp('El problema inicial no tiene solución factible')
        elseif Bb(I_d(i))== 0
            C_B = [C_B I_d(i)];
            ff = true;
            [IB,IN,B]= EliminarXa(IA,IB,IN,ff,C_B,B,N);
            Slfi = Bb;
        end    
    end
else
    [IB,IN,B]= EliminarXa(IA,IB,IN,ff,C_B,B,N);
    Slfi = Bb;
end    



end
%-------------------------------------------------------------------------
%Funcion EliminarXa 

% Esta funcion lo que hara es que eliminara los inidices de las variables 
%aleatorias para inicial la Fase 2

function[IB,IN,B]= EliminarXa(IA,IB,IN,ff,C_B,B,N)
k = 0; % Sera el menor en IN
[m,n]=size(IN);
[m3,n3]=size(IB);
I_NN =[];
I_BB =[];
in2 = 0;
in = 0;
ye = 0;
if ff == true
    [m1,n1]=size(C_B);
    k = min(IN)
    for i = 1:n
        I_NN = [I_NN i];
    end
    in= I_NN(k == IN);
    IN(in)=[];
    for j = 1:n1
       IB(C_B(j))=k;
    end
    for i = 1:n3
        I_BB = [I_BB i];
    end
    in2 = I_BB(IB==k)
    %ye = min(in2);
    B(:,in2)=N(:,in);
    N(:,in)=[];
else
    [m5,n5]=size(IA);
    for i = 1:n
       I_NN = [I_NN i];
    end
    for j = 1:n5
        if ismember(IA(j),IN)
            in = I_NN(IA(j)==IN);
            IN(in)=[];
        end
    end
end

end

%-------------------------------------------------------------------------
%Función Check_I

%Mira si A tiene contenida un matriz identidad de tamaño (mxm) y retona una
%base (B),los indices de la base (I_B)y si aun nuestra base no es (mxm) nos
%agrega de una vez las variables artificiales, la variable outs nos dice
%si se agrego(outs=0) o no (outs=1) una variable artificial. 
%la Matriz An es o nuestra matriz A si no se tuvo que agregar variables
%artificiales o la matriz concatenada con las nuevas variables

function [I_B,B,Outs,An,I_a] = Check_I (A)
[m,n] = size(A);
k = eye(m);
f = zeros(1,m);
r = zeros(m,m);
for i = 1:m
    for j = 1:n
        if A(:,j) == k(:,i) 
            f(i)=j;
            r(:,i)= A(:,j);
        end
    end
end
I_B = f;
B = r;
[m1,n1] = size(B);
I_a = zeros(1,m-m1);
%REviso si se debe o no agregar variables artificiales
Outs = true;
%Agrega las variebles Artificiales
copy=n;
yy = 1;
for i = 1:m
    if I_B(i)== 0
        Outs = false;
        copy = copy+1;
        I_B(i)= copy;
        I_a(yy) = copy;% Es un vector que nos retorna los indices que se agregaron
        yy = yy+1;
        A=[ A, k(:,i) ];
    end
end

for i= 1:m
    h = I_B(i);
    B(:,i)= A(:,h);
end
An = A;%la matriz A modificad o igual

end
%-------------------------------------------------------------------------
%Función Simplex 

%retorna la solución basica factible optima si la hay, su z_0 y el ultimo
%B barra que se creo
function [sfo,z_0, IB,IN,B,N,X_B] = Simplex(An,B,IB,IN,b,Co)
%Inicializamos
[m,n] = size(An);
sfo = zeros(n,1);
IsOp = false;
I_s=0;
I_e=0;
%Creamos un loop que solo acaba cuando la var IsOp es True, esto sucede
%cuando se encuentra una solucion basica optima finita o cuando el proceso
%se acaba por que hay optimos NO finitos.
while IsOp ~= 1
    %Generamos nuestra nueva base dependiendo que indices salieron de IB y
    %cuales entraron de IN
    if I_s ~= 0 && I_e~= 0
        for i =1:m
            if B(:,i)== An(:,I_s)
                 B(:,i)= An(:,I_e);
            end
        end
    end
    %Llamamos a las otras funciones anidadas
    [CN,CB,~,IN,N,IB] = Cost(An,Co,IB,IN,m,n,I_e,I_s);
    [bg, X_B,~,z_0]= Paso_1(CB,b,B,An);
    [I_e,I_s,IsOp]=Cost_reducidos(bg,CB,CN,IB,IN,N,B,An);
    we = ['Nuestros nuevos indices basicos ','[ ' ,num2str(IB),' ]'];
    rre = 'Nuestros nueva base es: ';
    rres = 'Nuestros nueva no base es: ';
    rtr = ['Los costos basicos son: ' ,'[ ' ,num2str(CB),' ]' ];
    wes = ['Nuestros nuevos indices no basicos ','[ ' ,num2str(IN),' ]'];
    rres = 'Nuestros nueva  no base es: ';
    rtrs = ['Los costos no basicos son: ' ,'[ ' ,num2str(CN),' ]' ];
    bgb = ['Nuestro XB es: '];
    z0r = ['El tamaño del paso es: ',num2str(z_0)];
    disp(we);
    disp(rre);
    disp(B);
    disp(rres);
    disp(N);
    disp(rtr);
    disp(wes);
    disp(rres);
    disp(N);
    disp(rtrs);
    disp(bgb);
    disp(X_B);
    disp(z0r);
    
    if I_s ~= 0 && I_e ~= 0
        k = ['A la base entro el indice: ',num2str(I_e)];
        S = ['De la base salio el indice: ',num2str(I_s)];
        disp(k)
        disp(S)
    end
    
end
%Definimos que en caso que no haya soluciones NO finitas (es decir que no 
%sea acotado) z_0 = 0 al igual que la solucion va a ser [0] esto lo ponemos
%como guía para saber que no hay soluciones
if I_s ==0
    %Generamos nuestra solucion basica factible optima en orden
    for i =1:m
        sfo(IB(:,i))= bg(i);
    end
    %Creamos nuestro z_0
end



z_0= Co* sfo;
end 
%-------------------------------------------------------------------------
%Costos reducidos

%Input
%B_b-> B barra 
%CN -> Costos No basicos
%CB -> Costos basicos 
%B -> base , IB -> indices de la base
%N -> no base , IN-> indice de las no base
%IsOp -> es una variable de salida que me dice si es optimo (True) o no 
%(False)la solucion basica dada.
%Nos retorna I_e el indice que entra,I_s el indice que sale (En dado caso 
%que la solución no tenga optimos finitos I_s=0) y si es optimo.

function[I_e,I_s,IsOp]=Cost_reducidos(B_b,CB,CN,IB,IN,N,B,A)

%Inicializamos
I_e = 0;%indice que entra
I_s = 0;%indice que sale
B1 = inv(B) %Inversa de B 
[m1,n1]= size(CN);
C_j = zeros(m1,n1);
Iaux=[];
u = 0; %Este valor tomara el Costo reducido menor si es menor a 0
l=0; %Cambia si hay costos positivos
k=0; %Cambia si hay costos nulos

%Generamos nuestros costos basicos
w = CB*B1 
K = (w*N)
C_j= CN - K;
Cjj = ['Los Costos reducidos son: ','[ ',num2str(C_j),']' ];
disp(Cjj);
%Buscamos cuales son nuestros costos minimos y guardamos sus indices en
%caso de que haya dos indices con costos minimos iguales.
for i = 1:n1
    %si un costo es menor a 0 quiere decir que la solucion todavia no es
    %optima y puede ser mejorada remplazando este indice
    if 0 > C_j(i)
        if u>= C_j(i)
            u = C_j(i);
            Iaux =[Iaux IN(i)];%Va a tomar los indices cuyo costo es el mismo
        end
    %si un costo no es menor a 0 quiere decir que tiene un valor optimo con
    %respecto a ese indice
    elseif 0 < C_j(i)
        l=1;
    %Si es 0 quiere decir que si se remplaza ese indice en nuestra solucion
    %el valor va a ser el mismo es decir que no hay cambio
    elseif C_j(i)== 0 
        k=1;
    end
end
%Tomamos el indice menor que tenga costo minimo por la regla de ciclaje
I_e = min(Iaux)
u
%u es nuestro costo minimo si es menor a 0 luego si u~=0 tenemos que la solucion
% todavia no es optima
if u ~= 0
    I_s = epsilon (B_b , A, B1,I_e,IB)
    if I_s == 0 
        %Definimos anteriormente que I_s =0 sii la solucion es no acotada
        j = 'La solución es NO acotada es decir que no  hay optimos finitos';
        %acaba el proceso
        IsOp = true;
    else
        %Como hay un indice que sale y uno que entra todavia podemos
        %mejorar la solucion
        j= 'la solución aun no es optima';
        %El proceso continua
        IsOp = false;
    end
    

elseif u == 0 && k~= 0
    %u es nuestro costo minimo luego si u=0 y k~=0 es decir que el costo
    %min es 0 tenemos que hay optimos alternos
    j = 'No se puede mejorar más la solución , Encontramos mas de un solo punto optimo';
    IsOp = true;
elseif l ~= 0 && u == 0 && k==0
    %tenemos que solo hay costos positivos y que nuestro costo minimo es
    %mayor estrictamente a 0 luego es optima
    j = 'la solución basica factible es OPTIMA';
    IsOp = true;
end    
   disp(j)
end
%-------------------------------------------------------------------------
 %Función Epsilon 
 
 % B1 -> la inversa de la base
 % A -> la matriz A
 %Nos ayuda a encontrar que indice sale
 
 function [I_sa] = epsilon (B_b , A, B1,I_e,IB)
 %Inicializamos
 I_s = [];
 I_ee = [];
 [m,n]=size(A);
 a = A(:,I_e)
 B1
 Y = B1*a
 Y = transpose(Y);
 yy = ['Nuestro Y',num2str(I_e),' es: ','[',num2str(Y),']'];
 disp(yy);
 B_b = transpose(B_b);
 rMin = [];

 
if not(all(B_b <= 0))  
    for i= 1:m
         if Y(i)>0
            rMin =[rMin B_b(i)/Y(i)];
            I_ee = [I_ee i];
         end
    end
end
razon_min  = min(rMin)
fg = ['La razón minima es:',num2str(razon_min)];
disp(fg);
%I_sa = IB(min(I_ee(rMin==razon_min)))%Toma el menor indice de los indices Basicos teniendo en 
%cuenta cual fue la razon minima
for i = 1:length(rMin)
    if rMin(i)==razon_min
        I_s = [I_s I_ee(i)];
    end
end
if size(I_s)>=1
    I_sa = IB(min(I_s));
else
    I_sa= 0;
end
 end
 %-------------------------------------------------------------------------
 %Función EncontCXa
 
 %En dado caso que tengamos que entrar variables artificiales nos ayuda a 
 %encontrar nuestra nueva función objetivo para la fase 1 expresada en los
 %nuevos costos
 
function [CXa] = EncontCXa(n,IA,p)

%Inicializamos
[m3,n3] = size(IA);
CXa = zeros(1,n); %Nuestros nuevos costos para la fase 1 que cambia la 
%funcion objetivo
%Primero arreglamos los costos para que cumplan la nueva funcion objetivo y
%agregamos 1 
if n3 == 1
    aux = IA(n3);
    CXa(aux)=1;
else
    for j = 1:n3
        aux = IA(j);
        for i = 1:n
            if aux == i
                CXa(i)=1;
            end
        end
    end
end      
%Por si acaso declaramos que sucede si tenemos que maximizar sin embargo en
%la Fase 1 no ha de ser necesaria
%


end
%-------------------------------------------------------------------------
%Función Paso_1 

%Nos retornarna B_barra dependiendo de la base y el b que entre al igual
%que un z_0 inicial

function[bg, X_B,X_N,z_0]= Paso_1(C_B,b,Base,A)
%Inicializamos los valores
    [m,n] =size(A);
    bg = (inv(Base))* b;
    X_B= bg;
    X_N = zeros((n-m), 1);
    z_0= C_B * X_B;
end
%-------------------------------------------------------------------------
%Función Cost

%Encontramos los Costos No basicos, los basicos, costos

function [C_N ,C_B,C,IN,N,IB]= Cost(A,C,IB,IN,m,n, I_e, I_s)
 %Encontrar costos CN , CB , C ,IN , N
 N = zeros(m,n-m);
 C_B= [];
 C_N=[];
 [~,n]= size(A);
 [~,o]= size(C);
 for i = 1:(n-o)
     C=[ C, 0 ];
 end
 
%Da los indices de la no base 
if I_e ~=0 && I_s ~=0
    for i =1:m
        if IB(:,i)==I_s
           IB(:,i)=I_e;
        end
    end
    for j =1:(n-m)
        
        if IN(:,j)==I_e
           IN(:,j)=I_s;
        end
    end
end

for i = 1:m
     C_B =[C_B, C(IB(i))];
 end
 for j = 1:(n-m)
         C_N=[C_N, C(IN(j))];
 end
%Da la no base N
for i = 1: n-m
    aux = IN(i);
    N(:,i) = A (:,aux); 
end            
 
end