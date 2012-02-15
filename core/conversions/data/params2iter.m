function GT_ITER = params2iter(PLANE_PARAMS,pId)

    GT_T	 = PLANE_PARAMS(1,pId);
    GT_P     = PLANE_PARAMS(2,pId);
    GT_D     = PLANE_PARAMS(3,pId);
    GT_ALPHA = PLANE_PARAMS(4,pId);

    GT_N = normalFromAngle( GT_T,GT_P );
    GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];
end