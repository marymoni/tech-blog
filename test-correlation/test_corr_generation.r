corr_matrix_compare = function(m1, m2) {
	abs(sum(m1 - m2)) / length(m1)
}

chol_generation = function(corr_matrix, seed, sims) {

	cnt = nrow(corr_matrix)

	rnd = matrix(rnorm(cnt * sims), nrow = sims, ncol = cnt)
	
	chol_m = tryCatch({ chol(corr_matrix) }, error = function(e) { NULL })
	
	if (is.null(chol_m)) return(list(status = F, res = NA_real_))
	
	rnd = rnd %*% chol_m
	
	cor_rnd = cor(rnd)
	
	res = corr_matrix_compare(cor_rnd, corr_matrix)
	
	list(status = T, res = res)
}

svd_generation = function(corr_matrix, seed, sims) {

	cnt = nrow(corr_matrix)

	rnd = matrix(rnorm(cnt * sims), nrow = sims, ncol = cnt)
	
	svd_m = svd(corr_matrix)
	
	x = svd_m$u %*% diag(sqrt(svd_m$d)) %*% t(svd_m$v)
	
	rnd = rnd %*% x
	
	cor_rnd = cor(rnd)
	
	res = corr_matrix_compare(cor_rnd, corr_matrix)
	
	list(status = T, res = res)
}

corr_matrix = matrix(c(1, 0.6, 0.4,0.6, 1, 0.3,0.4, 0.3, 1), 3, 3)

r1 = svd_generation(corr_matrix, 10000,10000)
r2 = chol_generation(corr_matrix, 10000,10000)

test_cases = data.table(num = c(3, 10, 20, 30, 40, 50, 100, 200, 300, 400), svd_status = NA, chol_status = NA, svd_res = NA_real_, chol_res = NA_real_)

for(i in test_cases$num) {
	
	print(i)
	
	r1 = svd_generation(prices_corr_matrix[1:i, 1:i], 10000,10000)
	r2 = chol_generation(prices_corr_matrix[1:i, 1:i], 10000,10000)
	
	test_cases[num == i, `:=`(svd_status = r1$status, chol_status = r2$status, svd_res = r1$res, chol_res = r2$res)]
}
