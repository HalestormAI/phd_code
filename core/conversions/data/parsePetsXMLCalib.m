if ~exist('fn','var')
    fn = input('Filename: ','s');
end

view1 = xml2struct( fn );

geomPos = find(strcmp({view1.Children.Name},'Geometry'));
intrPos = find(strcmp({view1.Children.Name},'Intrinsic'));
extrPos = find(strcmp({view1.Children.Name},'Extrinsic'));


dpx     = str2double(view1.Children(2).Attributes(1).Value)
dpy     = str2double(view1.Children(2).Attributes(2).Value)
dx      = str2double(view1.Children(2).Attributes(3).Value)
dy      = str2double(view1.Children(2).Attributes(4).Value)
p1      = str2double(view1.Children(2).Attributes(5).Value)
Ncx     = str2double(view1.Children(2).Attributes(6).Value)
Nfx     = str2double(view1.Children(2).Attributes(7).Value)
p2      = str2double(view1.Children(2).Attributes(8).Value)

Cx      = str2double(view1.Children(4).Attributes(1).Value)
Cy      = str2double(view1.Children(4).Attributes(2).Value)
f       = str2double(view1.Children(4).Attributes(3).Value)
kappa1  = str2double(view1.Children(4).Attributes(4).Value)
Sx      = str2double(view1.Children(4).Attributes(5).Value)

Rx      = str2double(view1.Children(6).Attributes(1).Value)
Ry      = str2double(view1.Children(6).Attributes(2).Value)
Rz      = str2double(view1.Children(6).Attributes(3).Value)
Tx      = str2double(view1.Children(6).Attributes(4).Value)
Ty      = str2double(view1.Children(6).Attributes(5).Value)
Tz      = str2double(view1.Children(6).Attributes(6).Value)
% 
[fc,cc,kc,alpha_c,Rc_1,Tc_1,omc_1,nx,ny,x_dist,xd] = willson_convert(Ncx,Nfx,dx,dy,dpx,dpy,Cx,Cy,Sx,f,kappa1,Tx,Ty,Tz,Rx,Ry,Rz,p1,p2);
% 
 KK = [fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2) ; 0 0 1];



Rxr = rodrigues([Rx;0;0])
Ryr = rodrigues([0;Ry;0])
Rzr = rodrigues([0;0;Rz])
R = Rzr * Ryr * Rxr;
T = [Tx;Ty;Tz];
C = [Cx;Cy];

