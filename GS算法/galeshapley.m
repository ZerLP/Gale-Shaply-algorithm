function stablematch = galeshapley(Dnum,Cnum, due_list, channel_list)
men_free = zeros(Dnum,1);
women_suitor = zeros(Cnum,Dnum);
women_partner = zeros(Cnum,1);
rank = zeros(Dnum,Cnum);
for i = 1:Dnum
    for j = 1:Cnum
        for k = 1:Dnum
        if(channel_list(i,k) == j)
            rank(i,j) = k;
        end
        end
    end
end
while (min(women_partner) == 0)
    for i = 1:Cnum
        if (men_free(i,1) == 0)
            next = find(due_list(i,:) > 0, 1);
            women_suitor(due_list(i,next),i) = i;
            due_list(i,next) = 0;
        end
    end
    for i = 1:Cnum
        for j = 1:Dnum
            if(women_suitor(i,j) ~= 0)
                if(women_partner(i,1) == 0)
                    women_partner(i,1) = women_suitor(i,j);
                    men_free(j,1) = 1;
                end
                if(women_partner(i,1) ~= 0)
                if(rank(i,women_suitor(i,j)) < rank(i,women_partner(i,1)))
                    men_free(women_partner(i,1),1) = 0;
                    women_partner(i,1) = women_suitor(i,j);
                    men_free(j,1) = 1;
                    
                end
                end
            end
        end
    end
end
stablematch = women_partner;
