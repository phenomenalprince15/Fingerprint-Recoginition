function Y=thinning1(X)
[M,N]=size(X);
Y=zeros(M,N,20);
Z=zeros(M,N,20);
Y(:,:,1)=X;
Z(:,:,1)=X;
for k=2:20
    Y(:,:,k)=Y(:,:,k-1);
        for i=2:M-1
            for j=2:N-1
	 % * * * y11 y12 y13
	 % * @ * y21 y22 y23
	 % * * * y31 y32 y33
                y11=Y(i-1,j-1,k);
                y12=Y(i-1,j,k);
                y13=Y(i-1,j+1,k);
                y21=Y(i,j-1,k);
                y22=Y(i,j,k);
                y23=Y(i,j+1,k);
                y31=Y(i+1,j-1,k);
                y32=Y(i+1,j,k);
                y33=Y(i+1,j+1,k);
                if y22==0
                    if y11==1&&y12==1&&y13==1&&y31==0&&y32==0&&y33==0
                        Y(i,j,k)=1;
                    elseif y11==1&&y13==0&&y21==1&&y23==0&&y31==1&&y33==0
                        Y(i,j,k)=1;
                    elseif y11==0&&y12==0&&y13==0&&y31==1&&y32==1&&y33==1
                        Y(i,j,k)=1;
                    elseif y11==0&&y13==1&&y21==0&&y23==1&&y31==0&&y33==1
                        Y(i,j,k)=1;
                    elseif y12==1&&y13==1&&y21==0&&y23==1&&y32==0
                        Y(i,j,k)=1;
                    elseif y11==1&&y12==1&&y21==1&&y23==0&&y32==0
                        Y(i,j,k)=1;
                    elseif y12==0&&y21==1&&y23==0&&y31==1&&y21==1
                        Y(i,j,k)=1;
                    elseif y12==0&&y21==0&&y23==1&&y32==1&&y33==1
                        Y(i,j,k)=1;
                        %extra
                    elseif y11==0&&y12==0&&y23==1&&y31==1&&y32==1&&y33==1
                        Y(i,j,k)=1;
                    end
                else
                end
            end
        end
        if Y(:,:,k)==Y(:,:,k-1)
            break;
        end
end
Y=Y(:,:,k);