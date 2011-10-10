function boundBox



for folderNum=1:270,
    for picNum=1:10:99,
        filename = sprintf('/usr/not-backed-up/nicci/forNicci/2b/a%08d/%08d.jpg', folderNum, picNum);
        
        pic = imread(filename);
        [X,Y,I2,rect] = imcrop(pic);
       
        height = round(rect(4));
        width = round(rect(3));
        xStart = round(rect(1));
        yStart = round(rect(2));
        
        ((10^folderNum)-1)+picNum
        string = sprintf('<data:bbox framespan="%d:%d" height="%d" width="%d" x="%d" y="%d"/>',((folderNum-1)*100)+picNum,((folderNum-1)*100)+picNum,height,width,xStart,yStart);
        
        disp(string) 
         
    end
end


% 
% 
% 
% for a =10:91
%     
%     
%     for i = 8:10:99
%         
%         if (i < 10) & (a < 10)
%             filename = strcat('/usr/not-backed-up/nicci/forNicci/2b/a0000000',num2str(a), '/00000',num2str(a-1), '0', num2str(i), '.jpg');
%         elseif (i >= 10) & (a < 10)
%             filename = strcat('/usr/not-backed-up/nicci/forNicci/2b/a0000000',num2str(a), '/00000',num2str(a-1), num2str(i), '.jpg');
%         elseif (i < 10) & (a >= 10)
%             filename = strcat('/usr/not-backed-up/nicci/forNicci/2b/a000000',num2str(a), '/0000',num2str(a-1), '0', num2str(i), '.jpg');
%         elseif (i >= 10) & (a >= 10)
%             filename = strcat('/usr/not-backed-up/nicci/forNicci/2b/a000000',num2str(a), '/0000',num2str(a-1), num2str(i), '.jpg');
%         end
%         
%         pic = imread(filename);
%         [X,Y,I2,rect] = imcrop(pic);
%         
%         height = num2str(round(rect(4)));
%         width = num2str(round(rect(3)));
%         xStart = num2str(round(rect(1)));
%         yStart = num2str(round(rect(2)));
%         
%         if i < 10
%             string = strcat('<data:bbox framespan"',num2str(a-1),'0', num2str(i), ':',num2str(a-1),'0', num2str(i), '" height="' , height, '" width="', width, '" x="', xStart, '" y=', yStart, '"/>');
%         else
%             string = strcat('<data:bbox framespan"', num2str(a-1), num2str(i), ':',num2str(a-1), num2str(i), '" height="' , height, '" width="', width, '" x="', xStart, '" y=', yStart, '"/>');
%         end
%         
%         disp(string)
%     end
%     
%     
% end
% 
% end
