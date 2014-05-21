cla
xy = randn(100,2);                   
mmx = [min(xy(:,1)), max(xy(:,1))];  
mmy = [min(xy(:,2)), max(xy(:,2))];  
scatter(xy(:,1), xy(:,2));           
tufteaxis(mmx, mmy);                 
