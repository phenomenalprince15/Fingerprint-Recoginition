clc;
clf;
clear all;
close all;
originalImage = imread('DB1_B/101_6.tif');
[m,n,s] = size(originalImage);

I = originalImage;

if s == 3
    I = rgb2gray(originImage);
end
I = double(I);

figure, imshow(uint8(I));
title('Original Image');
tic;

M = 0;
var = 0;
for x = 1:m
    for y=1:n
        M = M + I(x,y);
    end;
end;
M1 =  M/(m*n);
for x = 1:m
    for y = 1:n
        var = var + (I(x,y)-M1)*(I(x,y)-M1);
    end
end
var1 = var/(300*300);

for x=1:m
    for y=1:n
        if I(x,y) >= M1
            I(x,y) = 150+sqrt(50*(I(x,y)-M1)*(I(x,y)-M1)/var1); % increase the intensity of pixel if intensity is more than average intensity.
        else
            I(x,y) = 150-sqrt(50*(I(x,y)-M1)*(I(x,y)-M1)/var1); % decrease the intensity of pixel if intensity is less than average intensity.
        end
    end
end

figure, imshow(uint8(I));
title('Image Enhancement');

%segmentation
M=12;
H=floor(m/M);
L=floor(n/M);
aveg1 = zeros(H,L);
var1 = zeros(H,L);
for x = 1:H
    for y = 1:L
        aveg = 0;
        var = 0;
        for i=1:M
            for j=1:M
                aveg=I(i+(x-1)*M,j+(y-1)*M)+aveg;
            end
        end
        aveg1(x,y) = aveg/(M*M);
        for i=1:M
            for j=1:M
                var=(I(i+(x-1)*M,j+(y-1)*M)-aveg1(x,y))*(I(i+(x-1)*M,j+(y-1)*M)-aveg1(x,y))+var;
            end
        end
        var1(x,y) = var/(M*M);
    end
end

Gmean = 0;
Vmean = 0;
for x=1:H
    for y=1:L
        Gmean = Gmean + aveg1(x,y);
        Vmean = Vmean + var1(x,y);
    end
end
Gmean = Gmean/(H*L);
Vmean = Vmean/(H*L);
NGF = 0;
TGF = 0;
NVF = 0;
TVF = 0;
for x = 1:H
    for y=1:L
        if Gmean<aveg1(x,y)
            NGF = NGF+1;
            TGF = TGF + aveg1(x,y);
        end
        if Vmean<var1(x,y)
            NVF = NVF+1;
            TVF = TVF + var1(x,y);
        end
    end
end
Gf = TGF/NGF;
Vf = TVF/NVF;

NGb = 0;
TGb = 0;
TVb = 0;
NVb = 0;
for x = 1:H
    for y = 1:L
        if Gmean>aveg1(x,y)
            NGb = NGb+1;
            TGb = TGb + aveg1(x,y);
        end
        if Vmean>var1(x,y)
            NVb = NVb + 1;
            TVb = TVb + var1(x,y);
        end
    end
end
Gb = TGb/NGb;
Vb = TVb/NVb;
ground = zeros(H,L);
T1 = Gb;
T2 = Vb;

for x = 1:H
    for y = 1:L
        if aveg1(x,y)>T1 && var1(x,y)<T2
            ground(x,y) = 1;
        end
    end
end

for x=2:H-1
    for y=2:L-1
        if ground(x,y)==1
            if (ground(x-1,y) + ground(x-1,y+1) + ground(x,y+1) + ground(x+1,y+1) + ground(x+1,y) + ground(x+1,y-1) + ground(x,y-1) + ground(x-1,y-1)) <= 4
                ground(x,y)=0;
            end
        end
    end
end
Icc = ones(m,n);
for x=1:H
    for y=1:L
        if ground(x,y)==1
            for i=1:M
                for j=1:M
                    I(i+(x-1)*M,j+(y-1)*M)=0;
                    Icc(i+(x-1)*M,j+(y-1)*M)=0;
                end
            end
        end
    end
end
figure, imshow(uint8(I))
title('segmentation')

%orientation estimation

w = 12;
Gx = zeros(m,n);
Gy = zeros(m,n);
for x = 2:m-1
    for y = 2:n-1;
        Gx(x,y) = (I(x+1,y)-I(x-1,y))/2; % Difference between (x+1)th and (x-1)th pixel
        Gy(x,y) = (I(x,y+1)-I(x,y-1))/2; % Difference between (y+1)th and (y-1)th pixel
    end
end

Gsx=zeros(m,n);
Gsy=zeros(m,n);

for x=2:m-1
    for y=2:n-1
        Gsx(x,y)=Gx(x,y)^2-Gy(x,y)^2;
        Gsy(x,y)=2*Gx(x,y)*Gy(x,y);
    end
end

p = 31;
q = 32;
Gbx2=zeros(p,q);
Gby2=zeros(p,q);

for h=1:p
    for g=1:q
        for x=1+(h-1)*w:h*w
            for y=1+(g-1)*w:g*w
                Gbx2(h,g)=Gbx2(h,g)+Gsx(x,y);
                Gby2(h,g)=Gby2(h,g)+Gsy(x,y);
            end
        end
    end
end

theta2 = zeros(p,q);
theta3 = zeros(p,q);

for h=1:p
    for g=1:q
        if Gbx2(h,g)>0
            theta2(h,g) = pi/2 + atan(Gby2(h,g)/Gbx2(h,g))/2;
        end
        if Gbx2(h,g)<0 && Gby2(h,g)>=0
            theta2(h,g) = pi/2 + (atan(Gby2(h,g)/Gbx2(h,g))+pi)/2;
        end
        if Gbx2(h,g)<0 && Gby2(h,g)<0
            theta2(h,g) = pi/2 + (atan(Gby2(h,g)/Gbx2(h,g))-pi)/2;
        end
    end
end

for h=1:p
    for g=1:q
        theta3(h,g) = atan(Gby2(h,g)/Gbx2(h,g))/2;
    end
end


%orientation field filtering
Phix = zeros(p,q);
Phiy = zeros(p,q);
for h=1:p
    for g=1:q
        Phix(h,g) = cos(2*theta2(h,g));
        Phiy(h,g) = sin(2*theta2(h,g));
    end
end

f = fspecial('gaussian', 10, 2);
Phix = filter2(f, Phix);
Phiy = filter2(f, Phiy);

O1 = zeros(p,q);
for h=1:p
    for g=1:q
        O1(h,g)=1/2*atan2(Phiy(h,g),Phix(h,g));
    end
end

figure, imshow(uint8(I))
title('Orientation Field')
hold on;
for m=0:p-1
    for n=0:q-1
        plot(w*((n+0.5)+1i*(m+0.5)+1i*10^(-20)+0.3*[-1 1]*exp(1i*(3/2*pi-O1(m+1,n+1)))),'r-');
    end
end
 
%Binarization
[m,n,s] = size(I);
temp=(1/9)*[1 1 1;1 1 1;1 1 1];
Im=double(I);
In=zeros(m,n);

for a=2:m-1
    for b=2:n-1
        In(a,b)=Im(a-1,b-1)*temp(1,1)+Im(a-1,b)*temp(1,2)+Im(a-1,b+1)*temp(1,3)+Im(a,b-1)*temp(2,1)+Im(a,b)*temp(2,2)+Im(a,b+1)*temp(2,3)+Im(a+1,b-1)*temp(3,1)+Im(a+1,b)*temp(3,2)+Im(a+1,b+1)*temp(3,3);
    end
end

I=In;

Im=zeros(m,n);
for x=5:m-5;
    for y=5:n-5;
        sum1=I(x,y-4)+I(x,y-2)+I(x,y+2)+I(x,y+4);
        sum2=I(x-2,y+4)+I(x-1,y+2)+I(x+1,y-2)+I(x+2,y-4);
        sum3=I(x-2,y+2)+I(x-4,y+4)+I(x+2,y-2)+I(x+4,y-4);
        sum4=I(x-2,y+1)+I(x-4,y+2)+I(x+2,y-1)+I(x+4,y-2);
        sum5=I(x-2,y)+I(x-4,y)+I(x+2,y)+I(x+4,y);
        sum6=I(x-4,y-2)+I(x-2,y-1)+I(x+2,y+1)+I(x+4,y+2);
        sum7=I(x-4,y-4)+I(x-2,y-2)+I(x+2,y+2)+I(x+4,y+4);
        sum8=I(x-2,y-4)+I(x-1,y-2)+I(x+1,y+2)+I(x+2,y+4);
        sumi=[sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8];
        summax=max(sumi);
        summin=min(sumi);
        summ=sum(sumi);
        b=summ/8;
        if (summax+summin+4*I(x,y))>(3*(sum1+sum2+sum3+sum4+sum5+sum6+sum7+sum8)/8)
            sumf = summin;
        else
            sumf = summax;
        end
        if sumf > b
            Im(x,y)=128; %Assign 128 to all Im(x,y) which are having sumf more than b 
        else
            Im(x,y)=255; %Assign 255 to all Im(x,y) which are having sumf less than b 
        end
    end
end

for i=1:m
    for j =1:n
        Icc(i,j)=Icc(i,j)*Im(i,j);
    end
end

for i=1:m
    for j =1:n
        if (Icc(i,j)==128)
            Icc(i,j)=0;
        else
            Icc(i,j)=1;
        end
    end
end

figure, imshow(double(Icc))
title('Binarization');

% 
Icc=bwareaopen(Icc,80); %remove lake
Icc=Icc;
Icc=bwareaopen(Icc,80); %remove island
Icc=Icc;

Icc=imdilate(Icc,[1 1; 1 1]);
figure,imshow(double(Icc))
Im=Icc;
In=Im;
for a=1:4
    for i=2:m-1
        for j=2:n-1
            if Im(i,j)==1
                if Im(i-1,j) + Im(i-1,j+1) +Im(i,j+1) + Im(i+1,j+1) + Im(i+1,j) + Im(i+1,j-1) + Im(i,j-1) + Im(i-1,j-1) <= 3
                    In(i,j)=0;
                end
            end
            if Im(i,j)==0
                if (Im(i-1,j-1) + Im(i-1,j) + Im(i-1,j+1) + Im(i,j+1) + Im(i+1,j+1) + Im(i+1,j) + Im(i+1,j-1) + Im(i,j-1)) >= 7
                    In(i,j)=1;
                end
            end
        end
    end
    Im=In;
end
figure,imshow(double(Im))


%Thinning
Icc=thinning1(Icc);
figure,imshow(Icc);
title('thinning');


%Minutiae extraction
Mi=zeros(m,n);
Mi=minu(Icc);


%false minutiae deletion
for m=1:300
    for n=1:300
        if Mi(m,n)==1||Mi(m,n)==2
            d=20;
        if m<d||m+d>300||n<d||n+d>300
            Mi(m,n)=0;
        else
        end
        else
        end
    end
end

for n=1:300
    for m=1:300
        if Mi(m,n)==1||Mi(m,n)==2
            for i=1:300
                for j=1:300
                    if Mi(i,j)==1||Mi(i,j)==2
                        if Mi(m,n)==Mi(i,j)
                            d=10;
                        else
                            d=5;
                        end
                        a=sqrt((m-i)^2+(n-j)^2);
                        if a<d&&a>0
                            Mi(m,n)=0;
                            Mi(i,j)=0;
                        else
                        end
                    end
                end
            end
        else
        end
    end
end

figure(7)
title('Minutiae')
hold on
for m=1:300
    for n=1:300
        if Mi(m,n)==1
            a=round((m-1)/12)+1;
            b=round((n-1)/12)+1;
            plot(1*(n++1i*(m)),'ro','LineWidth',2)
        elseif Mi(m,n)==2
            a=round((m-1)/12)+1;
            b=round((n-1)/12)+1;
            plot(1*(n++1i*(m)),'bo','LineWidth',2)
        end
    end
end