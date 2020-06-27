function f=G_S(Cnum,Dnum,channel_list,due_list)
%D2D为男生M，cue为女生
qmax=3;

F=channel_list;
M=due_list;
x_stable=zeros(Dnum,Cnum);
x_match=zeros(Dnum,Cnum);

M_origin = M;
F_origin = F;
%% define couple list
M_sg = ones(Dnum,1);
M_cp = zeros(Dnum,1);
F_cp = zeros(Cnum,1);
Mlove_rank = zeros(Dnum,1);
Flove_rank = zeros(Cnum,1);
Mlove_score = zeros(1);
Flove_score = zeros(1);
F_mark = zeros(Cnum,Dnum);

M_favor_rank=Cnum;
F_favor_rank=Dnum;

%% maching...
times = 0;
% 当没有男孩是单身狗时，就匹配成功了，同时该匹配也是稳定的
% 其实两个数组 M_sg 和 F_cp 的用处是一样的:
% while 的条件既可以是sum(M_sg)>0，即男生并未全脱单，也可以是
% ~all(F_cp),即女生并未全找到对象
while sum(M_sg)>0
    % M: courtship
    for i=1:Dnum                                 % 对于每个男生
        if M_sg(i)==1                           % 如果男生i当前是单身
            for j=1:M_favor_rank      %Cnum      % 就按喜欢程度从高到低给每位女生排序(不管女生是否单身)，男生i最喜欢的女生编号M(i, j)，喜欢等级为j
                if M(i,j)~=0                    % 如果女生j还没有配对。选择没有拒绝过自己的女生中最喜欢的那一个，女生j对男生i的喜欢等级为k
                    for k=1:F_favor_rank   %Dnum            % 发出情书
                        if F(M(i,j),k)==i      %男生最喜欢的女生M(i，j)的偏好列表中中男生i排第k位      
                            F_mark(M(i,j),k)=1; %暂时接收男k
                            break;
                        end
                    end  %此循环结束后，女生M(i,j)收到多个男生表白
                    break;
                end
            end
        end
    end
    
    % F: response
    for i=1:Cnum                         
        if sum(F_mark(i,:)~=0)                          % 如果女生i已经收到至少一个男生表白
            for j=1:F_favor_rank                        % 对于男生j                
                if F_mark(i,j)==1                       % 如果男生j向女生i表白过
                    F_cp(i)=F(i,j);                     % 女生i接收这个男生F(i,j)
                    M_cp(F(i,j))=i;                     % 对应的男生j也有了女生i
                    M_sg(F(i,j))=0;                     % 同时，那个男生摘掉了单身狗的帽子
                    x_match(F(i,j),i)=1;                % 将结果存入匹配表中                              
                   if j<Dnum                              % 如果女生接受的情书不来自于自己最不喜欢的男生，即对更不喜欢的男生有拒绝权
                        Id2c=sum(x_match(F(i,j),:).*Idc1);
                        dnum=sum(x_match(F(i,j),:));              
                       while (Id2c(1,j)>5.54E-04) && (dnum<=1)   %Ic_th
                           [~,YY_F_cp]=size(F_cp');
                           if (sum(F_cp(i,:)))~=0
                               for jj=1:YY_F_cp
                                   if F_mark(i,jj)~=0
                                       Flove_rank(i,jj)=jj;
                                   end
                               end
                           end
                           %[X_flag,Y_flag]=max(Flove_rank(i,:));
                           for kk=j:Dnum
                               if F_mark(i,kk)==1
                                   F_mark(i,kk)==0;
                                   for s=1:Cnum
                                       if M(F(i,kk),s)==i
                                        M(F(i,kk),s)=0;  % 然后给该男生发一张好人卡(或和现男友分手)
                                        M_sg(F(i,kk),i)=1;
                                        x_match(F(i,kk),i)=0;
                                        F_cp(i,kk)=0;%剔除干扰最大的D2D
                                       end
                                   end
                               end
                               break;
                           end
                            Id2c=sum(x_match(F(i,j),:).*Idc1);
                       end
                end
            end
            continue;
        end
    end

times=times+1;
fprintf('第%d轮匹配完成\n',times);
end
  % F: response
%  for i=1:Cnum                         
%         if sum(F_mark(i,:)~=0)                          % 每个收到情书的女生(不论是否单身)，女生i至少收到一份情书
%             for j=1:F_favor_rank             %Dnum
%                 
%                 if F_mark(i,j)==1                       % 如果女生i收到男生j的情书
%                     F_cp(i)=F(i,j);                     % 于是这个女生有了CP
%                     M_cp(F(i,j))=i;                     % 对应的男生也有了CP
%                     M_sg(F(i,j))=0;                     % 同时，那个男生摘掉了单身狗的帽子
%                     x_match(F(i,j),i)=1;                
%                     if j<qmax                             % 如果女生接受的情书不来自于自己最不喜欢的男生，即对更不喜欢的男生有拒绝权
%                         for k=j+1:Dnum                   % 则查看更不喜欢的男生(们)——很可能不止一个——是否发来了情书
%                             if F_mark(i,k)==1           % 若有
%                                 F_mark(i,k)=0;          % 那么首先扔掉该男生发来的情书(包括之前的情书，即现男友的情书)
%                                 
%                                 for s=1:Cnum             
%                                     if M(F(i,k),s)==i
%                                         M(F(i,k),s)=0;  % 然后给该男生发一张好人卡(或和现男友分手)
%                                         M_sg(F(i,k))=1; % 于是该男生重新回到单身狗的行列
%                                         break;
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                     break;
%                 end
%                 
%             end
%         else
%             continue;                   % 先暂时跳过没收到情书的女生
%         end
%     end
%     times = times+1; 
%     fprintf('%d轮匹配完成\n',times);
%     end
%     f = x_match;
% 

end

                           
                     