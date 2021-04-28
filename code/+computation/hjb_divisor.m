function Bk = hjb_divisor(stepsize, deathrate,...
	k, A, inctrans, rho_mat, rebalance_rate)

	states_per_income = size(inctrans, 1);
	i1 = 1 +(k-1) * states_per_income;
	i2 = k * states_per_income;

	Ak = A(i1:i2, i1:i2);
	Bk = stepsize * (rho_mat)...
		+ (1+stepsize * (deathrate + rebalance_rate)) * speye(states_per_income)...
		- stepsize * (Ak + inctrans);
end