function compareEstResult(c,n,i)
  drawcoords3( c(:,:,i),  sprintf('Coord displacement for noise level %d', i), 1, 'b' );
  hold on;
  drawcoords3( n(:,:,i),  sprintf('Coord displacement for noise level %d', i), 0, 'g' );
  for j=1:size(c,2),
      %plot3( [ c(1,j,i); n(1,j,i)], [ c(2,j,i); n(2,j,i)], [ c(3,j,i); n(3,j,i)], '-r' );
      
      A = linefunc3d(c(:,j,i),n(:,j,i), 300);
      drawcoords3([n(:,j,i),A(2,:)'],'', 0, 'r')
  end
end