function [m, c] = getLineFromPoints( p1, p2 )


       m = ( p1(2) - p2(2) ) / ( p1(1) - p2(1) );
       
       c = p1(2) - m * p1(1);
       
      