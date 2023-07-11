library(GenSA)
library(genalg)
library(pso)

lower_bound = -1e6
upper_bound = 1e6
max_iter = 1e3
variable_count = 500
init_value = rep(1e6, variable_count)

run_and_save_res = function(expr, desc) {
	cat("Running", desc, as.character(Sys.time()), "\n")
	time = system.time(expr)
	res$time <<- time
	res$max_iter <<- max_iter
	res$variable_count <<- variable_count
	saveRDS(res, desc)
}

cat("Start at", as.character(Sys.time()), "\n")

run_and_save_res({ res <<- psoptim(init_value, rastrigin.md, lower = lower_bound, upper = upper_bound, control = list(maxit = max_iter)) }, "rastrigin.pso")
run_and_save_res({ res <<- psoptim(init_value, sphere.md, lower = lower_bound, upper = upper_bound, control = list(maxit = max_iter)) }, "sphere.pso")
run_and_save_res({ res <<- psoptim(init_value, rosenbrock.md, lower = lower_bound, upper = upper_bound, control = list(maxit = max_iter)) }, "rosenbrock.pso")
run_and_save_res({ res <<- psoptim(init_value, styblinski_tang.md, lower = lower_bound, upper = upper_bound, control = list(maxit = max_iter)) }, "styblinski_tang.pso")

run_and_save_res({ res <<- GenSA(init_value, rastrigin.md, lower = rep(lower_bound, variable_count), upper = rep(upper_bound, variable_count), control = list(maxit = max_iter, smooth = F)) }, "rastrigin.GenSA")
run_and_save_res({ res <<- GenSA(init_value, sphere.md, lower = rep(lower_bound, variable_count), upper = rep(upper_bound, variable_count), control = list(maxit = max_iter, smooth = T)) }, "sphere.GenSA")
run_and_save_res({ res <<- GenSA(init_value, rosenbrock.md, lower = rep(lower_bound, variable_count), upper = rep(upper_bound, variable_count), control = list(maxit = max_iter, smooth = F)) }, "rosenbrock.GenSA")
run_and_save_res({ res <<- GenSA(init_value, styblinski_tang.md, lower = rep(lower_bound, variable_count), upper = rep(upper_bound, variable_count), control = list(maxit = max_iter, smooth = F)) }, "styblinski_tang.GenSA")
 
run_and_save_res({ res <<- optim(init_value, sphere.md, method = "Nelder-Mead", control = list(maxit = max_iter)) }, "sphere.Nelder-Mead")
run_and_save_res({ res <<- optim(init_value, rastrigin.md, method = "Nelder-Mead", control = list(maxit = max_iter)) }, "rastrigin.Nelder-Mead")
run_and_save_res({ res <<- optim(init_value, rosenbrock.md, method = "Nelder-Mead", control = list(maxit = max_iter)) }, "rosenbrock.Nelder-Mead")
run_and_save_res({ res <<- optim(init_value, styblinski_tang.md, method = "Nelder-Mead", control = list(maxit = max_iter)) }, "styblinski_tang.Nelder-Mead")

run_and_save_res({ res <<- optim(init_value, sphere.md, method = "BFGS", control = list(maxit = max_iter)) }, "sphere.BFGS")
run_and_save_res({ res <<- optim(init_value, rastrigin.md, method = "BFGS", control = list(maxit = max_iter)) }, "rastrigin.BFGS")
run_and_save_res({ res <<- optim(init_value, rosenbrock.md, method = "BFGS", control = list(maxit = max_iter)) }, "rosenbrock.BFGS")
run_and_save_res({ res <<- optim(init_value, styblinski_tang.md, method = "BFGS", control = list(maxit = max_iter)) }, "styblinski_tang.BFGS")

run_and_save_res({ res <<- optim(init_value, sphere.md, method = "CG", control = list(maxit = max_iter)) }, "sphere.CG")
run_and_save_res({ res <<- optim(init_value, rastrigin.md, method = "CG", control = list(maxit = max_iter)) }, "rastrigin.CG")
run_and_save_res({ res <<- optim(init_value, rosenbrock.md, method = "CG", control = list(maxit = max_iter)) }, "rosenbrock.CG")
run_and_save_res({ res <<- optim(init_value, styblinski_tang.md, method = "CG", control = list(maxit = max_iter)) }, "styblinski_tang.CG")

run_and_save_res({ res <<- optim(init_value, sphere.md, method = "SANN", control = list(maxit = max_iter)) }, "sphere.SANN")
run_and_save_res({ res <<- optim(init_value, rastrigin.md, method = "SANN", control = list(maxit = max_iter)) }, "rastrigin.SANN")
run_and_save_res({ res <<- optim(init_value, rosenbrock.md, method = "SANN", control = list(maxit = max_iter)) }, "rosenbrock.SANN")
run_and_save_res({ res <<- optim(init_value, styblinski_tang.md, method = "SANN", control = list(maxit = max_iter)) }, "styblinski_tang.SANN")

run_and_save_res({ res <<- rbga(evalFunc = sphere.md, stringMin = rep(lower_bound, variable_count), stringMax = rep(upper_bound, variable_count), iters = max_iter) }, "sphere.rbga")
run_and_save_res({ res <<- rbga(evalFunc = rastrigin.md, stringMin = rep(lower_bound, variable_count), stringMax = rep(upper_bound, variable_count), iters = max_iter) }, "rastrigin.rbga")
run_and_save_res({ res <<- rbga(evalFunc = rosenbrock.md, stringMin = rep(lower_bound, variable_count), stringMax = rep(upper_bound, variable_count), iters = max_iter) }, "rosenbrock.rbga")
run_and_save_res({ res <<- rbga(evalFunc = styblinski_tang.md, stringMin = rep(lower_bound, variable_count), stringMax = rep(upper_bound, variable_count), iters = max_iter) }, "styblinski_tang.rbga")

cat("Finish at", as.character(Sys.time()), "\n")

