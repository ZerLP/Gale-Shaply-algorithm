
function f = Gale_Shapley( GAMMA_switch, I, GAMMA_controller, J, lammd_expand )

global x_initial
global alpha
global beta
global lammd_expand

% I 交换机的偏好列表，控制器编号，行降序排列
% J 控制器的偏好列表，交换机编号，列降序排列
accept_num = 6;  % 女生最大接受数量
Male = I;
Female = J';
[ M_num, F_num ] = size( I );


x_stable = zeros( M_num, F_num );
x_match = zeros( M_num, F_num );

M_origin = Male;
F_origin = Female;
%% define couple list
M_sg = ones( M_num, 1 );% 交换机的分配标记
M_cp = zeros(M_num,1); 
F_cp = zeros(F_num,1);
Mlove_rank = zeros(M_num,1);
Flove_rank = zeros(F_num,1);
Mlove_score = zeros(1);
Flove_score = zeros(1);
F_mark = zeros(F_num,M_num);  % 提议表，列号表示提议接受方，行号表示接受方对提议的评级


M_favor_rank = F_num;
F_favor_rank = M_num;


times = 0;
while sum(M_sg)>0
 % M: courtship
 for i=1:M_num % 对于每个男生
if M_sg(i)==1  % 如果他当前是单身
     for j=1:M_favor_rank 
            if Male(i,j)~=0 % 男生i最喜欢的女生编号M(i, j)，喜欢等级为j
               for k=1: F_favor_rank  % 女生j对男生i的喜欢等级为k
                  if Female(Male(i,j),k)==i
                           F_mark(Male(i,j),k)=1; % 女生收到的表白书
                               break;
                  end
        end
 break;
 end
 end
 end
 end

 % F: response
  for i=1:F_num   % 女生i  
 if sum(F_mark(i,:)~=0)  % 每个收到情书的女生(不论是否单身)
  for j=1:F_favor_rank
 
 if F_mark(i,j)==1  % 只接受其中最喜欢的男生的情书
  F_cp(i,j)=Female(i,j);   % 于是这个女生有了CP
  M_cp(Female(i,j))=i;   % 对应的男生也有了CP
    M_sg(Female(i,j))=0;  % 同时，那个男生摘掉了单身狗的帽子
  x_match(Female(i,j), i) = 1;%%%需要调整位置


   %if j<accept_num  % 控制器的容量限制 
  maintain_load = sum( lammd_expand.*x_match );  % 计算控制器维持的负载量
 maintain_num = sum( x_match );  % 计算控制器维持的交换机数量
 if maintain_load( 1, i ) > alpha*beta(i)  % 若维持的负载量超过控制器的容量上限
  % if sum( lammd_expand(:,j).*x_match ) > alpha*beta(j) || accept_num < sum( x_match(:, j) )

  while maintain_load( 1, i ) > alpha*beta(i)
 %找到当前最不喜欢的男生
  [ ~, YY_F_cp ] = size( F_cp ); %size返回行，列数
 
  if sum(F_cp(i,j-1))~=0 % 对于每个非单身的女生
 for jj=1:YY_F_cp
 if F_mark(i,jj)~=0
 Flove_rank(i,jj)=jj; % 此女生当前的男友是她第j喜欢的，配合F_cp使用，
 
 end
 end
 end

[X_flag, Y_flag] = max( Flove_rank(i,:) ) ;


 for kk=j:M_num % 对喜欢等级大于j，[j+1，num]的所有男生扔掉表白书
if F_mark(i,kk)==1  % 若之前有收到kk的表白书，则扔掉
F_mark(i,kk)=0;
 for s=1:F_num 
if Male(Female(i,kk),s)==i
Male(F_cp( i, kk ), s)=0; % 然后给该男生发一张好人卡(或和现男友分手)
M_sg( F_cp( i, kk ) )=1; % 于是该男生重新回到单身狗的行列
x_match( F_cp( i, kk ), i ) = 0;
 F_cp( i, kk ) = 0;% 踢掉等级最靠后的交换机
 
 
end
 end
end
  break;
 end
  maintain_load = sum( lammd_expand.*x_match );
  end
 end
%break;
end
 end
 else
 continue; % 先暂时跳过没收到情书的女生
 end

end
times = times+1;
% fprintf('第%d轮匹配完成\n',times);


%% 分析每个人对自己男/女朋友的满意程度
% 对于每个男生
 for iii=1:M_num 
if M_sg(iii)~=1  % 对于每个非单身的男生
for jjj=1:M_favor_rank 
if Male(iii,jjj)~=0
Mlove_rank(iii)=jjj;% 此男生当前的女友是他第j喜欢的
  break;
end
end
end
 end
  % 对于每个女生
 for iii=1:F_num
 if sum(F_mark(iii,:))~=0   % 对于每个非单身的女生
 for j=1:F_favor_rank
 if F_mark(iii,jjj)~=0
  Flove_rank(iii)=jjj;  % 此女生当前的男友是她第j喜欢的
  break;
 end
 end
 end
 end
  % 计算每轮匹配后男女对自己的女友/男友的喜欢程度
  Mlove_score( times )=sum( sum(Mlove_rank) )/M_num;
  Flove_score( times )=sum( sum(Flove_rank) )/F_num;
end
fprintf('全部匹配完成，一共匹配了%d轮\n',times);

f = x_match;
end
