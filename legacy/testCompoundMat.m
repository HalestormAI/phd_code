function Rc = testCompoundMat( G )

alpha = asin( -G(2) )
beta  = acos( G(3)/cos(alpha) )


RX = [     1         0          0      ;
           0     cos(alpha) sin(alpha) ;
           0    -sin(alpha) cos(alpha) ]
       
RY = [ cos(beta)    0      -sin(beta)  ;
           0        1           0      ;
       sin(beta)    0       cos(beta)  ]

   
Rc = [         cos(beta)          0              -sin(beta)      ;
       sin(alpha)*sin(beta)   cos(alpha)    sin(alpha)*cos(beta) ;
       cos(alpha)*sin(beta)  -sin(alpha)    cos(alpha)*cos(beta) ]
   
RX*RY